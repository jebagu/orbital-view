import Combine
import Darwin
import Foundation
import OrbisonicTelemetryDashboard
import OrbisonicTelemetryKit

public struct OrbitalViewTelemetryMeterLevel: Equatable, Sendable {
    public var rms: Double
    public var peak: Double
    public var clip: Bool

    public init(rms: Double, peak: Double, clip: Bool = false) {
        self.rms = Self.clamp01(rms)
        self.peak = Self.clamp01(max(peak, rms))
        self.clip = clip
    }

    private static func clamp01(_ value: Double) -> Double {
        guard value.isFinite else { return 0 }
        return min(1, max(0, value))
    }
}

public struct OrbitalViewTelemetryMeterSnapshot: Equatable, Sendable {
    public var sequence: UInt64
    public var producerHostTime: UInt64
    public var levelsByChannel: [Int: OrbitalViewTelemetryMeterLevel]

    public init(
        sequence: UInt64,
        producerHostTime: UInt64,
        levelsByChannel: [Int: OrbitalViewTelemetryMeterLevel]
    ) {
        self.sequence = sequence
        self.producerHostTime = producerHostTime
        self.levelsByChannel = levelsByChannel
    }

    public func level(channel: Int) -> OrbitalViewTelemetryMeterLevel? {
        levelsByChannel[channel]
    }
}

public struct OrbitalViewTelemetryProviderSummary: Identifiable, Equatable, Sendable {
    public var id: String
    public var provider: String
    public var status: String
    public var track: String

    public init(id: String, provider: String, status: String, track: String) {
        self.id = id
        self.provider = provider
        self.status = status
        self.track = track
    }
}

public struct OrbitalViewTelemetryConsumerSnapshot: Equatable, Sendable {
    public static let waiting = OrbitalViewTelemetryConsumerSnapshot(
        providers: [],
        selectedProviderID: nil,
        selectedProviderName: "No Provider",
        status: "Waiting",
        track: "No Metadata",
        displayedMeter: "silent until telemetry arrives",
        meterSnapshot: nil,
        lastError: nil
    )

    public var providers: [OrbitalViewTelemetryProviderSummary]
    public var selectedProviderID: String?
    public var selectedProviderName: String
    public var status: String
    public var track: String
    public var displayedMeter: String
    public var meterSnapshot: OrbitalViewTelemetryMeterSnapshot?
    public var lastError: String?
}

public struct OrbitalViewTelemetryConsumerConfiguration: Sendable {
    public var registryStore: TelemetryRegistryStore
    public var bootIDProvider: @Sendable () -> String
    public var hostTimeProvider: @Sendable () -> UInt64
    public var staleProviderHostTicks: UInt64
    public var staleFrameHostTicks: UInt64

    public init(
        registryStore: TelemetryRegistryStore = TelemetryRegistryStore(),
        bootIDProvider: @escaping @Sendable () -> String = { OrbitalViewTelemetrySystemIdentity.currentBootID() },
        hostTimeProvider: @escaping @Sendable () -> UInt64 = { OrbitalViewTelemetryHostClock.now() },
        staleProviderHostTicks: UInt64 = OrbitalViewTelemetryHostClock.hostTicks(forSeconds: 2),
        staleFrameHostTicks: UInt64 = OrbitalViewTelemetryHostClock.hostTicks(forSeconds: 2)
    ) {
        self.registryStore = registryStore
        self.bootIDProvider = bootIDProvider
        self.hostTimeProvider = hostTimeProvider
        self.staleProviderHostTicks = staleProviderHostTicks
        self.staleFrameHostTicks = staleFrameHostTicks
    }
}

public final class OrbitalViewTelemetryConsumer {
    private let configuration: OrbitalViewTelemetryConsumerConfiguration
    private var attachedProviderID: String?
    private var attachedSegment: SharedTelemetrySegment?
    private var attachedReader: SharedLatestSlotReader?

    public init(configuration: OrbitalViewTelemetryConsumerConfiguration = OrbitalViewTelemetryConsumerConfiguration()) {
        self.configuration = configuration
    }

    public func poll(selectedProviderID: String? = nil) -> OrbitalViewTelemetryConsumerSnapshot {
        let now = configuration.hostTimeProvider()
        let records: [TelemetryProviderRegistryRecord]
        do {
            records = try configuration.registryStore
                .readProviders(currentBootID: configuration.bootIDProvider())
                .records
        } catch {
            detach()
            return Self.snapshot(
                records: [],
                selectedRecord: nil,
                selectedProviderID: nil,
                selectedMeterSnapshot: nil,
                now: now,
                staleProviderHostTicks: configuration.staleProviderHostTicks,
                staleFrameHostTicks: configuration.staleFrameHostTicks,
                errorText: "Registry Error"
            )
        }

        let compatibleRecords = records.filter { record in
            record.slotSummary.contains { $0.slotTypeRawValue == TelemetrySlotType.speakerMeters.rawValue }
        }
        let selectedRecord = selectRecord(
            from: compatibleRecords,
            selectedProviderID: selectedProviderID,
            now: now
        )
        guard let selectedRecord else {
            detach()
            return Self.snapshot(
                records: compatibleRecords,
                selectedRecord: nil,
                selectedProviderID: nil,
                selectedMeterSnapshot: nil,
                now: now,
                staleProviderHostTicks: configuration.staleProviderHostTicks,
                staleFrameHostTicks: configuration.staleFrameHostTicks,
                errorText: nil
            )
        }

        do {
            let reader = try reader(for: selectedRecord)
            let frame = try reader.read()
            let meterSnapshot = try frame.map(Self.decodeSpeakerMeters)
            return Self.snapshot(
                records: compatibleRecords,
                selectedRecord: selectedRecord,
                selectedProviderID: selectedRecord.providerInstanceID,
                selectedMeterSnapshot: meterSnapshot,
                now: now,
                staleProviderHostTicks: configuration.staleProviderHostTicks,
                staleFrameHostTicks: configuration.staleFrameHostTicks,
                errorText: nil
            )
        } catch {
            detach()
            return Self.snapshot(
                records: compatibleRecords,
                selectedRecord: selectedRecord,
                selectedProviderID: selectedRecord.providerInstanceID,
                selectedMeterSnapshot: nil,
                now: now,
                staleProviderHostTicks: configuration.staleProviderHostTicks,
                staleFrameHostTicks: configuration.staleFrameHostTicks,
                errorText: error is TelemetryError ? "Read Error" : "Attach Error"
            )
        }
    }

    private func selectRecord(
        from records: [TelemetryProviderRegistryRecord],
        selectedProviderID: String?,
        now: UInt64
    ) -> TelemetryProviderRegistryRecord? {
        if let selectedProviderID,
           let selected = records.first(where: { $0.providerInstanceID == selectedProviderID }) {
            return selected
        }

        let candidates = records.map(TelemetryProviderCandidate.init(record:))
        let selection = TelemetryProviderSelector.select(
            candidates: candidates,
            context: TelemetryProviderSelectionContext(
                requiredSlots: [.speakerMeters],
                nowHostTime: now,
                staleProviderHostTicks: configuration.staleProviderHostTicks,
                staleFrameHostTicks: configuration.staleFrameHostTicks
            )
        )
        guard let selected = selection.selected else {
            return nil
        }
        return records.first { $0.providerInstanceID == selected.providerInstanceID }
    }

    private func reader(for record: TelemetryProviderRegistryRecord) throws -> SharedLatestSlotReader {
        if attachedProviderID != record.providerInstanceID {
            detach()
            let segment = try SharedTelemetrySegment.openReadOnly(providerRecord: record)
            attachedReader = try segment.reader(for: .speakerMeters)
            attachedSegment = segment
            attachedProviderID = record.providerInstanceID
        }

        guard let attachedReader else {
            throw TelemetryError.notFound("telemetry reader is not attached")
        }
        return attachedReader
    }

    private func detach() {
        attachedReader = nil
        attachedSegment = nil
        attachedProviderID = nil
    }

    private static func snapshot(
        records: [TelemetryProviderRegistryRecord],
        selectedRecord: TelemetryProviderRegistryRecord?,
        selectedProviderID: String?,
        selectedMeterSnapshot: OrbitalViewTelemetryMeterSnapshot?,
        now: UInt64,
        staleProviderHostTicks: UInt64,
        staleFrameHostTicks: UInt64,
        errorText: String?
    ) -> OrbitalViewTelemetryConsumerSnapshot {
        let track = "No Metadata"
        let selectedIsStale = selectedRecord.map {
            now > $0.lastHeartbeatHostTime + staleProviderHostTicks
        } ?? false
        let frameIsStale = selectedMeterSnapshot.map {
            now > $0.producerHostTime + staleFrameHostTicks
        } ?? false
        let status: String
        if let errorText {
            status = errorText
        } else if selectedRecord == nil {
            status = "Waiting"
        } else if selectedIsStale || frameIsStale {
            status = "Stale"
        } else if selectedMeterSnapshot == nil {
            status = "Waiting"
        } else {
            status = "Live"
        }

        let displayedMeter: String
        if selectedMeterSnapshot == nil {
            displayedMeter = "silent until telemetry arrives"
        } else if status == "Stale" {
            displayedMeter = "stale telemetry"
        } else {
            displayedMeter = "live telemetry"
        }

        let providers = records
            .sorted { lhs, rhs in lhs.lastHeartbeatHostTime > rhs.lastHeartbeatHostTime }
            .map { record in
                let providerStatus: String
                if record.providerInstanceID == selectedProviderID {
                    providerStatus = status
                } else if now > record.lastHeartbeatHostTime + staleProviderHostTicks {
                    providerStatus = "Stale"
                } else {
                    providerStatus = "Available"
                }
                return OrbitalViewTelemetryProviderSummary(
                    id: record.providerInstanceID,
                    provider: record.appName,
                    status: providerStatus,
                    track: track
                )
            }

        return OrbitalViewTelemetryConsumerSnapshot(
            providers: providers,
            selectedProviderID: selectedProviderID,
            selectedProviderName: selectedRecord?.appName ?? "No Provider",
            status: status,
            track: track,
            displayedMeter: displayedMeter,
            meterSnapshot: selectedMeterSnapshot,
            lastError: errorText
        )
    }

    private static func decodeSpeakerMeters(
        frame: TelemetryReadFrame
    ) throws -> OrbitalViewTelemetryMeterSnapshot {
        let payload = frame.payload
        let recordByteSize = frame.envelope.recordStride
        let count = Int(frame.envelope.recordCount)
        guard recordByteSize >= UInt32(SpeakerMeterPayloadRecord.byteSize) else {
            throw TelemetryError.invalidFrame("speaker meter record stride is too small")
        }
        guard payload.count >= count * Int(recordByteSize) else {
            throw TelemetryError.invalidFrame("speaker meter payload records are truncated")
        }

        var levels: [Int: OrbitalViewTelemetryMeterLevel] = [:]
        for index in 0..<count {
            let offset = index * Int(recordByteSize)
            let channelID = Int(try payload.readInteger(at: offset, as: UInt32.self))
            guard channelID > 0 else {
                continue
            }
            let rms = Double(try payload.readFloat32(at: offset + 4))
            let peak = Double(try payload.readFloat32(at: offset + 8))
            let clip = (try payload.readUInt8(at: offset + 12)) != 0
            levels[channelID] = OrbitalViewTelemetryMeterLevel(rms: rms, peak: peak, clip: clip)
        }

        return OrbitalViewTelemetryMeterSnapshot(
            sequence: frame.envelope.frameSequence,
            producerHostTime: frame.envelope.producerHostTime,
            levelsByChannel: levels
        )
    }
}

public final class OrbitalViewTelemetryConsumerViewModel: ObservableObject {
    @Published public private(set) var snapshot: OrbitalViewTelemetryConsumerSnapshot = .waiting

    private let consumer: OrbitalViewTelemetryConsumer
    private let pollInterval: TimeInterval
    private var timer: Timer?
    private var selectedProviderID: String?

    public init(
        consumer: OrbitalViewTelemetryConsumer = OrbitalViewTelemetryConsumer(),
        pollInterval: TimeInterval = 0.5
    ) {
        self.consumer = consumer
        self.pollInterval = pollInterval
    }

    public func start() {
        guard timer == nil else { return }
        refreshNow()
        let timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.refreshNow()
        }
        self.timer = timer
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    public func selectProvider(id: String?) {
        selectedProviderID = id
        refreshNow()
    }

    public func refreshNow() {
        snapshot = consumer.poll(selectedProviderID: selectedProviderID)
    }
}

public enum OrbitalViewTelemetrySystemIdentity {
    public static func currentBootID() -> String {
        var bootTime = timeval()
        var size = MemoryLayout<timeval>.stride
        if sysctlbyname("kern.boottime", &bootTime, &size, nil, 0) == 0 {
            return "darwin-boot-\(bootTime.tv_sec)-\(bootTime.tv_usec)"
        }
        return "darwin-boot-unknown"
    }
}

public enum OrbitalViewTelemetryHostClock {
    public static func now() -> UInt64 {
        mach_absolute_time()
    }

    public static func hostTicks(forSeconds seconds: Double) -> UInt64 {
        var timebase = mach_timebase_info_data_t()
        guard mach_timebase_info(&timebase) == 0, timebase.numer > 0 else {
            return UInt64(seconds * 1_000_000_000)
        }

        let nanoseconds = seconds * 1_000_000_000
        let ticks = nanoseconds * Double(timebase.denom) / Double(timebase.numer)
        return UInt64(ticks.rounded())
    }
}

private extension Data {
    func readUInt8(at offset: Int) throws -> UInt8 {
        guard offset >= 0, offset < count else {
            throw TelemetryError.invalidFrame("read outside telemetry payload")
        }
        return self[offset]
    }

    func readInteger<T: FixedWidthInteger>(at offset: Int, as type: T.Type = T.self) throws -> T {
        let size = MemoryLayout<T>.size
        guard offset >= 0, offset + size <= count else {
            throw TelemetryError.invalidFrame("read outside telemetry payload")
        }
        return try withUnsafeBytes { raw in
            guard let baseAddress = raw.baseAddress else {
                throw TelemetryError.invalidFrame("empty telemetry payload")
            }
            let value = baseAddress
                .advanced(by: offset)
                .loadUnaligned(as: T.self)
            return T(littleEndian: value)
        }
    }

    func readFloat32(at offset: Int) throws -> Float {
        Float(bitPattern: try readInteger(at: offset, as: UInt32.self))
    }
}
