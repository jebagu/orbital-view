import Combine
import Darwin
import Foundation
import OrbisonicTelemetryDashboard
import OrbisonicTelemetryKit

public struct OrbitalViewTelemetryMeterLevel: Equatable, Sendable {
    public var rms: Double
    public var peak: Double
    public var clip: Bool
    public var recordFlags: UInt8
    public var dvsChannel: Int?
    public var stateFlags: UInt32
    public var displayDriveOverride: Double?
    public var vuNormalized: Double?
    public var vuDbFS: Double?

    public init(
        rms: Double,
        peak: Double,
        clip: Bool = false,
        recordFlags: UInt8 = 0,
        dvsChannel: Int? = nil,
        stateFlags: UInt32 = 0,
        displayDriveOverride: Double? = nil,
        vuNormalized: Double? = nil,
        vuDbFS: Double? = nil
    ) {
        self.rms = Self.clamp01(rms)
        self.peak = Self.clamp01(max(peak, rms))
        self.clip = clip
        self.recordFlags = recordFlags
        self.dvsChannel = dvsChannel
        self.stateFlags = stateFlags
        self.displayDriveOverride = displayDriveOverride.map(Self.clamp01)
        self.vuNormalized = vuNormalized.map(Self.clamp01)
        self.vuDbFS = vuDbFS?.isFinite == true ? vuDbFS : nil
    }

    public var hasValidVUDisplayDrive: Bool {
        (recordFlags & OrbitalViewTelemetryRecordFlags.vuNormalizedValid) != 0
    }

    public var displayDrive: Double {
        if hasValidVUDisplayDrive {
            return vuNormalized ?? rms
        }
        return displayDriveOverride ?? rms
    }

    private static func clamp01(_ value: Double) -> Double {
        guard value.isFinite else { return 0 }
        return min(1, max(0, value))
    }
}

public enum OrbitalViewTelemetryRecordFlags {
    public static let vuNormalizedValid: UInt8 = 1 << 0
}

public enum OrbitalViewTelemetryMeterSlotKind: String, Equatable, Sendable {
    case speakerMeters
    case sourceLaneMeters

    public var title: String {
        switch self {
        case .speakerMeters:
            return "Speaker meters"
        case .sourceLaneMeters:
            return "Source lane meters"
        }
    }

    public var displayedMeterText: String {
        switch self {
        case .speakerMeters:
            return "live telemetry"
        case .sourceLaneMeters:
            return "live source-lane telemetry"
        }
    }
}

public struct OrbitalViewTelemetryMeterSnapshot: Equatable, Sendable {
    public var sequence: UInt64
    public var producerHostTime: UInt64
    public var sampleRate: Double
    public var frameCount: UInt32
    public var recordCount: Int
    public var slotKind: OrbitalViewTelemetryMeterSlotKind
    public var levelsByChannel: [Int: OrbitalViewTelemetryMeterLevel]

    public init(
        sequence: UInt64,
        producerHostTime: UInt64,
        sampleRate: Double = 0,
        frameCount: UInt32 = 0,
        recordCount: Int? = nil,
        slotKind: OrbitalViewTelemetryMeterSlotKind = .speakerMeters,
        levelsByChannel: [Int: OrbitalViewTelemetryMeterLevel]
    ) {
        self.sequence = sequence
        self.producerHostTime = producerHostTime
        self.sampleRate = sampleRate
        self.frameCount = frameCount
        self.recordCount = recordCount ?? levelsByChannel.count
        self.slotKind = slotKind
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
    public var meterSlotKind: OrbitalViewTelemetryMeterSlotKind
    public var routeLabel: String?
    public var sourceLabel: String?

    public init(
        id: String,
        provider: String,
        status: String,
        track: String,
        meterSlotKind: OrbitalViewTelemetryMeterSlotKind = .speakerMeters,
        routeLabel: String? = nil,
        sourceLabel: String? = nil
    ) {
        self.id = id
        self.provider = provider
        self.status = status
        self.track = track
        self.meterSlotKind = meterSlotKind
        self.routeLabel = routeLabel
        self.sourceLabel = sourceLabel
    }
}

public struct OrbitalViewTelemetryConsumerSnapshot: Equatable, Sendable {
    public static let waiting = OrbitalViewTelemetryConsumerSnapshot(
        providers: [],
        selectedProviderID: nil,
        selectedProviderName: "No Provider",
        status: "Waiting",
        track: "No Metadata",
        selectedMeterSlotKind: nil,
        displayedMeter: "silent until telemetry arrives",
        meterSnapshot: nil,
        lastError: nil
    )

    public var providers: [OrbitalViewTelemetryProviderSummary]
    public var selectedProviderID: String?
    public var selectedProviderName: String
    public var status: String
    public var track: String
    public var selectedMeterSlotKind: OrbitalViewTelemetryMeterSlotKind?
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
    private var attachedSlotType: TelemetrySlotType?
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

        let compatibleRecords = records.filter { Self.supportedMeterSlotType(for: $0) != nil }
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
            let slotType = Self.supportedMeterSlotType(for: selectedRecord) ?? .speakerMeters
            let reader = try reader(for: selectedRecord, slotType: slotType)
            let frame = try reader.read()
            let meterSnapshot = try frame.map { try Self.decodeMeters(frame: $0, slotType: slotType) }
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

        if let selected = selectRecord(
            from: records.filter { Self.supportedMeterSlotType(for: $0) == .speakerMeters },
            now: now,
            requiredSlots: [.speakerMeters]
        ) {
            return selected
        }

        return selectRecord(
            from: records.filter { Self.supportedMeterSlotType(for: $0) == .sourceLaneMeters },
            now: now,
            requiredSlots: [.sourceLaneMeters]
        )
    }

    private func selectRecord(
        from records: [TelemetryProviderRegistryRecord],
        now: UInt64,
        requiredSlots: Set<TelemetrySlotType>
    ) -> TelemetryProviderRegistryRecord? {
        guard !records.isEmpty else { return nil }
        let candidates = records.map(TelemetryProviderCandidate.init(record:))
        let selection = TelemetryProviderSelector.select(
            candidates: candidates,
            context: TelemetryProviderSelectionContext(
                requiredSlots: requiredSlots,
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

    private func reader(
        for record: TelemetryProviderRegistryRecord,
        slotType: TelemetrySlotType
    ) throws -> SharedLatestSlotReader {
        if attachedProviderID != record.providerInstanceID || attachedSlotType != slotType {
            detach()
            let segment = try SharedTelemetrySegment.openReadOnly(providerRecord: record)
            attachedReader = try segment.reader(for: slotType)
            attachedSegment = segment
            attachedProviderID = record.providerInstanceID
            attachedSlotType = slotType
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
        attachedSlotType = nil
    }

    private static func supportedMeterSlotType(for record: TelemetryProviderRegistryRecord) -> TelemetrySlotType? {
        let slotTypes = Set(record.slotSummary.map(\.slotTypeRawValue))
        if slotTypes.contains(TelemetrySlotType.speakerMeters.rawValue) {
            return .speakerMeters
        }
        if slotTypes.contains(TelemetrySlotType.sourceLaneMeters.rawValue) {
            return .sourceLaneMeters
        }
        return nil
    }

    private static func meterSlotKind(for slotType: TelemetrySlotType) -> OrbitalViewTelemetryMeterSlotKind {
        switch slotType {
        case .sourceLaneMeters:
            return .sourceLaneMeters
        default:
            return .speakerMeters
        }
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
        } else if let selectedMeterSnapshot {
            displayedMeter = selectedMeterSnapshot.slotKind.displayedMeterText
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
                    track: track,
                    meterSlotKind: supportedMeterSlotType(for: record).map(meterSlotKind(for:)) ?? .speakerMeters,
                    routeLabel: record.humanRouteLabel,
                    sourceLabel: record.humanSourceLabel
                )
            }

        return OrbitalViewTelemetryConsumerSnapshot(
            providers: providers,
            selectedProviderID: selectedProviderID,
            selectedProviderName: selectedRecord?.appName ?? "No Provider",
            status: status,
            track: track,
            selectedMeterSlotKind: selectedMeterSnapshot?.slotKind
                ?? selectedRecord.flatMap { supportedMeterSlotType(for: $0).map(meterSlotKind(for:)) },
            displayedMeter: displayedMeter,
            meterSnapshot: selectedMeterSnapshot,
            lastError: errorText
        )
    }

    private static func decodeMeters(
        frame: TelemetryReadFrame,
        slotType: TelemetrySlotType
    ) throws -> OrbitalViewTelemetryMeterSnapshot {
        switch slotType {
        case .sourceLaneMeters:
            return try decodeSourceLaneMeters(frame: frame)
        default:
            return try decodeSpeakerMeters(frame: frame)
        }
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
            let recordFlags = recordByteSize >= 14
                ? try payload.readUInt8(at: offset + 13)
                : 0
            let dvsChannel = recordByteSize >= 20
                ? Int(try payload.readInteger(at: offset + 16, as: UInt32.self))
                : nil
            let stateFlags = recordByteSize >= 24
                ? try payload.readInteger(at: offset + 20, as: UInt32.self)
                : 0
            let vuNormalized = recordByteSize >= 28
                ? Double(try payload.readFloat32(at: offset + 24))
                : nil
            let vuDbFS = recordByteSize >= 32
                ? Double(try payload.readFloat32(at: offset + 28))
                : nil
            guard (stateFlags & OrbitalViewTelemetryDVSStateFlags.disabled) == 0 else {
                continue
            }
            levels[channelID] = OrbitalViewTelemetryMeterLevel(
                rms: rms,
                peak: peak,
                clip: clip,
                recordFlags: recordFlags,
                dvsChannel: dvsChannel,
                stateFlags: stateFlags,
                vuNormalized: vuNormalized,
                vuDbFS: vuDbFS
            )
        }

        return OrbitalViewTelemetryMeterSnapshot(
            sequence: frame.envelope.frameSequence,
            producerHostTime: frame.envelope.producerHostTime,
            sampleRate: frame.envelope.sampleRate,
            frameCount: frame.envelope.frameCount,
            recordCount: count,
            slotKind: .speakerMeters,
            levelsByChannel: levels
        )
    }

    private static func decodeSourceLaneMeters(
        frame: TelemetryReadFrame
    ) throws -> OrbitalViewTelemetryMeterSnapshot {
        let payload = frame.payload
        let recordByteSize = frame.envelope.recordStride
        let count = Int(frame.envelope.recordCount)
        guard recordByteSize >= UInt32(SourceLaneMeterPayloadRecord.byteSize) else {
            throw TelemetryError.invalidFrame("source lane meter record stride is too small")
        }
        guard payload.count >= count * Int(recordByteSize) else {
            throw TelemetryError.invalidFrame("source lane meter payload records are truncated")
        }

        var levels: [Int: OrbitalViewTelemetryMeterLevel] = [:]
        for index in 0..<count {
            let offset = index * Int(recordByteSize)
            let sourceLaneID = Int(try payload.readInteger(at: offset, as: UInt32.self))
            guard sourceLaneID > 0 else {
                continue
            }
            let rms = Double(try payload.readFloat32(at: offset + 20))
            let peak = Double(try payload.readFloat32(at: offset + 24))
            let clip = (try payload.readUInt8(at: offset + 28)) != 0
            levels[sourceLaneID] = OrbitalViewTelemetryMeterLevel(
                rms: rms,
                peak: peak,
                clip: clip,
                displayDriveOverride: sourceLaneDisplayDrive(forRMS: rms)
            )
        }

        return OrbitalViewTelemetryMeterSnapshot(
            sequence: frame.envelope.frameSequence,
            producerHostTime: frame.envelope.producerHostTime,
            sampleRate: frame.envelope.sampleRate,
            frameCount: frame.envelope.frameCount,
            recordCount: count,
            slotKind: .sourceLaneMeters,
            levelsByChannel: levels
        )
    }

    private static func sourceLaneDisplayDrive(forRMS rms: Double) -> Double {
        let floorDb = -50.0
        let ceilingDb = 0.0
        let floorLinear = pow(10.0, floorDb / 20.0)
        let safeRMS = max(rms, floorLinear)
        let db = 20.0 * log10(safeRMS)
        return min(1.0, max(0.0, (db - floorDb) / (ceilingDb - floorDb)))
    }
}

private enum OrbitalViewTelemetryDVSStateFlags {
    static let disabled: UInt32 = 1 << 1
}

public final class OrbitalViewTelemetryConsumerViewModel: ObservableObject {
    @Published public private(set) var snapshot: OrbitalViewTelemetryConsumerSnapshot = .waiting

    private let consumer: OrbitalViewTelemetryConsumer
    private let pollInterval: TimeInterval
    private var timer: Timer?
    private var selectedProviderID: String?

    public init(
        consumer: OrbitalViewTelemetryConsumer = OrbitalViewTelemetryConsumer(),
        pollInterval: TimeInterval = 1.0 / 30.0
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
