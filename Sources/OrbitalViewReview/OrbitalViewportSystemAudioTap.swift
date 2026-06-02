#if os(macOS)
import AudioToolbox
import Combine
import CoreAudio
import Foundation

/// Review-only live capture of macOS **system output audio** via a Core Audio process tap
/// (`AudioHardwareCreateProcessTap` / `CATapDescription`, macOS 14.2+). It mirrors the
/// `OrbitalViewportLocalAudioController` contract — `currentMeterSample()` returns the same mono
/// RMS/peak `OrbitalViewportMeterSample` that the Local Song path produces — so it feeds the
/// identical downstream renderers and offers the same `OrbitalViewportAudioRenderMode` options.
///
/// This is a measurement/visual-review input only; it does not change the production meter
/// boundary (`OrbitalViewSwiftUI` / `OrbitalViewRender` still consume host-prepared snapshots).
///
/// On macOS < 14.2 (the package floor is macOS 13) the process-tap API does not exist, so this
/// controller reports unavailable and produces silent meters rather than failing to build.
///
/// Not main-actor isolated (matching `OrbitalViewportLocalAudioController`): `sourceID` and
/// `currentMeterSample()` are read from the nonisolated render path, while `start()`/`stop()` and
/// the `@Published` UI state are driven from the main thread. Cross-thread meter data flows only
/// through the lock-guarded `OrbitalViewportSystemAudioMeterStore`.
final class OrbitalViewportSystemAudioTapController: NSObject, ObservableObject {
    @Published private(set) var isCapturing = false
    @Published private(set) var statusText: String
    private(set) var sourceID = UUID()

    private let meterStore = OrbitalViewportSystemAudioMeterStore()
    private var engine: AnyObject?

    /// Whether the process-tap API is present on this OS. The UI disables Start when false.
    var isAvailable: Bool {
        if #available(macOS 14.2, *) { return true }
        return false
    }

    override init() {
        if #available(macOS 14.2, *) {
            statusText = "System audio idle"
        } else {
            statusText = "Requires macOS 14.2+"
        }
        super.init()
    }

    func meterSource(renderMode: OrbitalViewportAudioRenderMode) -> OrbitalViewportMeterSource {
        guard isCapturing else { return .systemAudioInactive }
        return .systemAudio(self, renderMode: renderMode)
    }

    func footerLabel(renderMode: OrbitalViewportAudioRenderMode) -> String {
        _ = renderMode
        return isCapturing ? "System Audio: capturing" : "System Audio / \(statusText)"
    }

    func start() {
        guard !isCapturing else { return }
        guard #available(macOS 14.2, *) else {
            statusText = "Requires macOS 14.2+"
            return
        }
        do {
            let tapEngine = try OrbitalViewportSystemAudioTapEngine(meterStore: meterStore)
            try tapEngine.start()
            engine = tapEngine
            sourceID = UUID()
            meterStore.reset()
            isCapturing = true
            statusText = "Capturing system audio"
        } catch {
            engine = nil
            isCapturing = false
            statusText = "Capture failed: \((error as? OrbitalViewportSystemAudioTapError)?.message ?? error.localizedDescription)"
        }
    }

    func stop() {
        guard isCapturing else { return }
        if #available(macOS 14.2, *), let tapEngine = engine as? OrbitalViewportSystemAudioTapEngine {
            tapEngine.stop()
        }
        engine = nil
        meterStore.reset()
        isCapturing = false
        statusText = "System audio idle"
    }

    func currentMeterSample() -> OrbitalViewportMeterSample {
        guard isCapturing else { return .silent }
        let snapshot = meterStore.snapshot()
        return OrbitalViewportMeterSample.monoSample(
            averagePowerDB: [OrbitalViewportSystemAudioMeterStore.linearToDB(snapshot.rms)],
            peakPowerDB: [OrbitalViewportSystemAudioMeterStore.linearToDB(snapshot.peak)]
        )
    }
}

/// Thread-safe latest-sample store: the Core Audio IO block (a high-priority audio thread) writes
/// linear RMS/peak; the main thread reads it once per displayed meter frame. A lock is fine here —
/// the critical section is a few scalar stores and the read is at display cadence, not audio rate.
final class OrbitalViewportSystemAudioMeterStore: @unchecked Sendable {
    struct Snapshot {
        var rms: Float
        var peak: Float
    }

    private let lock = NSLock()
    private var rms: Float = 0
    private var peak: Float = 0

    func update(rms: Float, peak: Float) {
        lock.lock()
        // Light smoothing on RMS so the visual meter does not strobe at the audio block rate;
        // peak follows fast and decays via the read side staying at display cadence.
        self.rms = self.rms * 0.6 + rms * 0.4
        self.peak = max(self.peak * 0.7, peak)
        lock.unlock()
    }

    func snapshot() -> Snapshot {
        lock.lock()
        let value = Snapshot(rms: rms, peak: peak)
        // Decay peak on read so it falls back after transients.
        peak *= 0.5
        lock.unlock()
        return value
    }

    func reset() {
        lock.lock()
        rms = 0
        peak = 0
        lock.unlock()
    }

    static func linearToDB(_ linear: Float) -> Float {
        guard linear > 0.0000001 else { return -160 }
        return 20 * log10f(linear)
    }
}

enum OrbitalViewportSystemAudioTapError: Error {
    case tapCreationFailed(OSStatus)
    case aggregateCreationFailed(OSStatus)
    case ioProcCreationFailed(OSStatus)
    case startFailed(OSStatus)

    var message: String {
        switch self {
        case .tapCreationFailed(let status):
            return "process tap not created (status \(status)) — grant audio capture permission"
        case .aggregateCreationFailed(let status):
            return "aggregate device not created (status \(status))"
        case .ioProcCreationFailed(let status):
            return "audio callback not created (status \(status))"
        case .startFailed(let status):
            return "capture did not start (status \(status))"
        }
    }
}

/// The macOS 14.2+ Core Audio implementation: create a global process tap, wrap it in a private
/// aggregate device, and run an IO block that reduces each buffer to linear RMS/peak.
@available(macOS 14.2, *)
final class OrbitalViewportSystemAudioTapEngine {
    private let meterStore: OrbitalViewportSystemAudioMeterStore
    private var tapID = AudioObjectID(kAudioObjectUnknown)
    private var aggregateID = AudioObjectID(kAudioObjectUnknown)
    private var ioProcID: AudioDeviceIOProcID?

    init(meterStore: OrbitalViewportSystemAudioMeterStore) throws {
        self.meterStore = meterStore
    }

    func start() throws {
        // Tap the whole system mix (exclude no processes) as a stereo mixdown.
        let tapDescription = CATapDescription(stereoGlobalTapButExcludeProcesses: [])
        tapDescription.isPrivate = true
        tapDescription.muteBehavior = .unmuted

        var createdTap = AudioObjectID(kAudioObjectUnknown)
        let tapStatus = AudioHardwareCreateProcessTap(tapDescription, &createdTap)
        guard tapStatus == noErr else {
            throw OrbitalViewportSystemAudioTapError.tapCreationFailed(tapStatus)
        }
        tapID = createdTap

        // Wrap the tap in a private aggregate device so we can attach an IO proc to read it.
        let aggregateUID = "com.orbitalviewkit.systemaudiotap.\(UUID().uuidString)"
        let description: [String: Any] = [
            kAudioAggregateDeviceNameKey: "Orbital View System Audio Tap",
            kAudioAggregateDeviceUIDKey: aggregateUID,
            kAudioAggregateDeviceIsPrivateKey: true,
            kAudioAggregateDeviceIsStackedKey: false,
            kAudioAggregateDeviceTapAutoStartKey: true,
            kAudioAggregateDeviceTapListKey: [
                [kAudioSubTapUIDKey: tapDescription.uuid.uuidString]
            ]
        ]

        var createdAggregate = AudioObjectID(kAudioObjectUnknown)
        let aggregateStatus = AudioHardwareCreateAggregateDevice(description as CFDictionary, &createdAggregate)
        guard aggregateStatus == noErr else {
            cleanupTap()
            throw OrbitalViewportSystemAudioTapError.aggregateCreationFailed(aggregateStatus)
        }
        aggregateID = createdAggregate

        let store = meterStore
        var createdProc: AudioDeviceIOProcID?
        let procStatus = AudioDeviceCreateIOProcIDWithBlock(&createdProc, aggregateID, nil) { _, inInputData, _, _, _ in
            OrbitalViewportSystemAudioTapEngine.reduce(inputData: inInputData, into: store)
        }
        guard procStatus == noErr, let proc = createdProc else {
            cleanupAggregate()
            cleanupTap()
            throw OrbitalViewportSystemAudioTapError.ioProcCreationFailed(procStatus)
        }
        ioProcID = proc

        let startStatus = AudioDeviceStart(aggregateID, proc)
        guard startStatus == noErr else {
            cleanupProc()
            cleanupAggregate()
            cleanupTap()
            throw OrbitalViewportSystemAudioTapError.startFailed(startStatus)
        }
    }

    func stop() {
        if let ioProcID {
            AudioDeviceStop(aggregateID, ioProcID)
        }
        cleanupProc()
        cleanupAggregate()
        cleanupTap()
    }

    /// Reduce one IO block's input (32-bit float, interleaved or per-buffer) to linear RMS/peak.
    private static func reduce(
        inputData: UnsafePointer<AudioBufferList>,
        into store: OrbitalViewportSystemAudioMeterStore
    ) {
        let buffers = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer(mutating: inputData))
        var sumSquares: Float = 0
        var peak: Float = 0
        var sampleCount = 0
        for buffer in buffers {
            guard let raw = buffer.mData else { continue }
            let frameCount = Int(buffer.mDataByteSize) / MemoryLayout<Float>.size
            guard frameCount > 0 else { continue }
            let samples = raw.assumingMemoryBound(to: Float.self)
            for index in 0..<frameCount {
                let value = samples[index]
                sumSquares += value * value
                let magnitude = abs(value)
                if magnitude > peak { peak = magnitude }
            }
            sampleCount += frameCount
        }
        guard sampleCount > 0 else { return }
        let rms = sqrtf(sumSquares / Float(sampleCount))
        store.update(rms: rms, peak: peak)
    }

    private func cleanupProc() {
        if let ioProcID {
            AudioDeviceDestroyIOProcID(aggregateID, ioProcID)
        }
        ioProcID = nil
    }

    private func cleanupAggregate() {
        if aggregateID != AudioObjectID(kAudioObjectUnknown) {
            AudioHardwareDestroyAggregateDevice(aggregateID)
        }
        aggregateID = AudioObjectID(kAudioObjectUnknown)
    }

    private func cleanupTap() {
        if tapID != AudioObjectID(kAudioObjectUnknown) {
            AudioHardwareDestroyProcessTap(tapID)
        }
        tapID = AudioObjectID(kAudioObjectUnknown)
    }

    deinit {
        stop()
    }
}
#endif
