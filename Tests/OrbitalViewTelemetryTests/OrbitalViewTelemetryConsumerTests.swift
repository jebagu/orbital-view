import Foundation
import OrbisonicTelemetryKit
@testable import OrbitalViewTelemetry
import XCTest

final class OrbitalViewTelemetryConsumerTests: XCTestCase {
    private var segments: [SharedTelemetrySegment] = []
    private var temporaryRoots: [URL] = []
    private struct ExtendedSpeakerMeterFields {
        var recordFlags: UInt8 = 0
        var dvsChannel: UInt32
        var stateFlags: UInt32 = 0
        var vuNormalized: Float
        var vuDbFS: Float
    }
    private struct SourceLaneMeterRecordModel {
        var sourceLaneID: UInt32
        var rms: Float
        var peak: Float
        var clip: Bool = false
    }

    override func tearDown() {
        segments.removeAll()
        for root in temporaryRoots {
            try? FileManager.default.removeItem(at: root)
        }
        temporaryRoots.removeAll()
        super.tearDown()
    }

    func testNoProvidersWaitsWithSilentMeterState() throws {
        let root = try makeTemporaryRegistryRoot()
        let consumer = makeConsumer(root: root, bootID: "boot", now: 1_000)

        let snapshot = consumer.poll()

        XCTAssertEqual(snapshot.providers, [])
        XCTAssertEqual(snapshot.selectedProviderName, "No Provider")
        XCTAssertEqual(snapshot.status, "Waiting")
        XCTAssertEqual(snapshot.track, "No Metadata")
        XCTAssertEqual(snapshot.displayedMeter, "silent until telemetry arrives")
        XCTAssertNil(snapshot.meterSnapshot)
    }

    func testLiveProviderAttachesReadOnlyAndPublishesChannelMeters() throws {
        let bootID = "boot"
        let root = try makeTemporaryRegistryRoot()
        let provider = try makeProvider(
            root: root,
            bootID: bootID,
            appName: "Orbisonic",
            providerInstanceID: "orbisonic-main",
            heartbeat: 1_000,
            sequence: 42,
            producerHostTime: 1_050,
            meters: [
                SpeakerMeterRecordModel(channelID: 1, rms: 0.25, peak: 0.5),
                SpeakerMeterRecordModel(channelID: 7, rms: 0.7, peak: 0.9, clip: true)
            ]
        )
        try TelemetryRegistryStore(registryRootURL: root).writeProvider(provider)
        let consumer = makeConsumer(root: root, bootID: bootID, now: 1_100)

        let snapshot = consumer.poll()

        XCTAssertEqual(snapshot.providers.count, 1)
        XCTAssertEqual(snapshot.selectedProviderID, "orbisonic-main")
        XCTAssertEqual(snapshot.selectedProviderName, "Orbisonic")
        XCTAssertEqual(snapshot.status, "Live")
        XCTAssertEqual(snapshot.displayedMeter, "live telemetry")
        XCTAssertEqual(snapshot.providers[0].status, "Live")
        XCTAssertEqual(snapshot.meterSnapshot?.sequence, 42)
        XCTAssertEqual(snapshot.meterSnapshot?.producerHostTime, 1_050)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 1)?.rms ?? -1, 0.25, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 1)?.peak ?? -1, 0.5, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 7)?.rms ?? -1, 0.7, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 7)?.peak ?? -1, 0.9, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 7)?.clip, true)
    }

    func testExtendedSpeakerMeterFieldsDecodeDisplayDriveAndDVSState() throws {
        let bootID = "boot"
        let root = try makeTemporaryRegistryRoot()
        let provider = try makeProvider(
            root: root,
            bootID: bootID,
            appName: "Orbisonic",
            providerInstanceID: "orbisonic-main",
            heartbeat: 1_000,
            sequence: 43,
            producerHostTime: 1_050,
            meters: [
                SpeakerMeterRecordModel(channelID: 2, rms: 0.1, peak: 0.4),
                SpeakerMeterRecordModel(channelID: 4, rms: 0.6, peak: 0.9)
            ],
            extendedMeters: [
                2: ExtendedSpeakerMeterFields(
                    dvsChannel: 31,
                    vuNormalized: 0.95,
                    vuDbFS: -3.5
                ),
                4: ExtendedSpeakerMeterFields(
                    dvsChannel: 32,
                    stateFlags: 1 << 1,
                    vuNormalized: 1,
                    vuDbFS: -0.25
                )
            ]
        )
        try TelemetryRegistryStore(registryRootURL: root).writeProvider(provider)
        let consumer = makeConsumer(root: root, bootID: bootID, now: 1_100)

        let snapshot = consumer.poll()
        let level = try XCTUnwrap(snapshot.meterSnapshot?.level(channel: 2))

        XCTAssertEqual(level.rms, 0.1, accuracy: 0.000_001)
        XCTAssertEqual(level.peak, 0.4, accuracy: 0.000_001)
        XCTAssertEqual(level.dvsChannel, 31)
        XCTAssertEqual(level.recordFlags, 0)
        XCTAssertEqual(level.stateFlags, 0)
        XCTAssertEqual(level.vuNormalized ?? -1, 0.95, accuracy: 0.000_001)
        XCTAssertEqual(level.vuDbFS ?? 99, -3.5, accuracy: 0.000_001)
        XCTAssertFalse(level.hasValidVUDisplayDrive)
        XCTAssertEqual(level.displayDrive, 0.1, accuracy: 0.000_001)
        XCTAssertNil(snapshot.meterSnapshot?.level(channel: 4))
    }

    func testExtendedSpeakerMeterFieldsUseExplicitVUValidRecordFlag() throws {
        let bootID = "boot"
        let root = try makeTemporaryRegistryRoot()
        let provider = try makeProvider(
            root: root,
            bootID: bootID,
            appName: "Orbisonic",
            providerInstanceID: "orbisonic-main",
            heartbeat: 1_000,
            sequence: 44,
            producerHostTime: 1_050,
            meters: [
                SpeakerMeterRecordModel(channelID: 2, rms: 0.2, peak: 0.4),
                SpeakerMeterRecordModel(channelID: 3, rms: 0.3, peak: 0.5)
            ],
            extendedMeters: [
                2: ExtendedSpeakerMeterFields(
                    recordFlags: OrbitalViewTelemetryRecordFlags.vuNormalizedValid,
                    dvsChannel: 31,
                    vuNormalized: 0,
                    vuDbFS: -80
                ),
                3: ExtendedSpeakerMeterFields(
                    recordFlags: OrbitalViewTelemetryRecordFlags.vuNormalizedValid,
                    dvsChannel: 32,
                    vuNormalized: 0.8,
                    vuDbFS: -3
                )
            ]
        )
        try TelemetryRegistryStore(registryRootURL: root).writeProvider(provider)
        let consumer = makeConsumer(root: root, bootID: bootID, now: 1_100)

        let snapshot = consumer.poll()

        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 2)?.displayDrive ?? -1, 0, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 3)?.displayDrive ?? -1, 0.8, accuracy: 0.000_001)
    }

    func testTelemetryDisplayDriveIgnoresUntrustedVUSlots() throws {
        let absent = OrbitalViewTelemetryMeterLevel(rms: 0.2, peak: 0.45)
        let zeroFilled = OrbitalViewTelemetryMeterLevel(rms: 0.2, peak: 0.45, vuNormalized: 0, vuDbFS: 0)
        let nonzeroButUntrusted = OrbitalViewTelemetryMeterLevel(rms: 0.2, peak: 0.45, vuNormalized: 0.9)
        let localOverride = OrbitalViewTelemetryMeterLevel(rms: 0.2, peak: 0.45, displayDriveOverride: 0.72)

        XCTAssertNil(absent.vuNormalized)
        XCTAssertEqual(absent.displayDrive, 0.2, accuracy: 0.000_001)
        XCTAssertEqual(zeroFilled.vuNormalized, 0)
        XCTAssertEqual(zeroFilled.displayDrive, 0.2, accuracy: 0.000_001)
        XCTAssertEqual(nonzeroButUntrusted.displayDrive, 0.2, accuracy: 0.000_001)
        XCTAssertEqual(localOverride.displayDriveOverride ?? -1, 0.72, accuracy: 0.000_001)
        XCTAssertEqual(localOverride.displayDrive, 0.72, accuracy: 0.000_001)
    }

    func testTelemetryDisplayDriveUsesExplicitVUValidFlag() throws {
        let silentByDisplayIntent = OrbitalViewTelemetryMeterLevel(
            rms: 0.2,
            peak: 0.45,
            recordFlags: OrbitalViewTelemetryRecordFlags.vuNormalizedValid,
            vuNormalized: 0,
            vuDbFS: -80
        )
        let displayDriven = OrbitalViewTelemetryMeterLevel(
            rms: 0.2,
            peak: 0.45,
            recordFlags: OrbitalViewTelemetryRecordFlags.vuNormalizedValid,
            displayDriveOverride: 0.1,
            vuNormalized: 0.9,
            vuDbFS: -1
        )

        XCTAssertTrue(silentByDisplayIntent.hasValidVUDisplayDrive)
        XCTAssertEqual(silentByDisplayIntent.displayDrive, 0, accuracy: 0.000_001)
        XCTAssertEqual(displayDriven.displayDrive, 0.9, accuracy: 0.000_001)
    }

    func testSelectedProviderIsHonoredWhenMultipleProvidersAreCompatible() throws {
        let bootID = "boot"
        let root = try makeTemporaryRegistryRoot()
        let store = TelemetryRegistryStore(registryRootURL: root)
        try store.writeProvider(
            makeProvider(
                root: root,
                bootID: bootID,
                appName: "Orbisonic Main",
                providerInstanceID: "orbisonic-main",
                heartbeat: 1_000,
                sequence: 1,
                producerHostTime: 1_000,
                meters: [SpeakerMeterRecordModel(channelID: 1, rms: 0.1, peak: 0.2)]
            )
        )
        try store.writeProvider(
            makeProvider(
                root: root,
                bootID: bootID,
                appName: "Orbisonic Alt",
                providerInstanceID: "orbisonic-alt",
                heartbeat: 900,
                sequence: 2,
                producerHostTime: 900,
                meters: [SpeakerMeterRecordModel(channelID: 3, rms: 0.6, peak: 0.8)]
            )
        )
        let consumer = makeConsumer(root: root, bootID: bootID, now: 1_100)

        let snapshot = consumer.poll(selectedProviderID: "orbisonic-alt")

        XCTAssertEqual(snapshot.providers.count, 2)
        XCTAssertEqual(snapshot.selectedProviderID, "orbisonic-alt")
        XCTAssertEqual(snapshot.selectedProviderName, "Orbisonic Alt")
        XCTAssertEqual(snapshot.status, "Live")
        XCTAssertNil(snapshot.meterSnapshot?.level(channel: 1))
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 3)?.rms ?? -1, 0.6, accuracy: 0.000_001)
    }

    func testSourceLaneOnlyProviderIsCompatibleAndDecodesThirtyLanes() throws {
        let bootID = "boot"
        let root = try makeTemporaryRegistryRoot()
        let sourceLaneRecords = (1...30).map { lane in
            SourceLaneMeterRecordModel(
                sourceLaneID: UInt32(lane),
                rms: Float(lane) / 100,
                peak: Float(lane) / 50,
                clip: lane == 30
            )
        }
        let provider = try makeSourceLaneProvider(
            root: root,
            bootID: bootID,
            appName: "Wave Relay",
            providerInstanceID: "wave-relay-main",
            heartbeat: 1_000,
            sequence: 100,
            producerHostTime: 1_050,
            meters: sourceLaneRecords
        )
        try TelemetryRegistryStore(registryRootURL: root).writeProvider(provider)
        let consumer = makeConsumer(root: root, bootID: bootID, now: 1_100)

        let snapshot = consumer.poll()

        XCTAssertEqual(snapshot.providers.count, 1)
        XCTAssertEqual(snapshot.providers[0].meterSlotKind, .sourceLaneMeters)
        XCTAssertEqual(snapshot.selectedProviderID, "wave-relay-main")
        XCTAssertEqual(snapshot.selectedProviderName, "Wave Relay")
        XCTAssertEqual(snapshot.selectedMeterSlotKind, .sourceLaneMeters)
        XCTAssertEqual(snapshot.status, "Live")
        XCTAssertEqual(snapshot.displayedMeter, "live source-lane telemetry")
        XCTAssertEqual(snapshot.meterSnapshot?.slotKind, .sourceLaneMeters)
        XCTAssertEqual(snapshot.meterSnapshot?.recordCount, 30)
        XCTAssertEqual(snapshot.meterSnapshot?.levelsByChannel.count, 30)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 1)?.rms ?? -1, 0.01, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 1)?.displayDrive ?? -1, 0.2, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 30)?.peak ?? -1, 0.6, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 30)?.clip, true)
        XCTAssertNil(snapshot.meterSnapshot?.level(channel: 31))
        XCTAssertNil(snapshot.meterSnapshot?.level(channel: 32))
    }

    func testSourceLaneDisplayDriveUsesWaveRelayDBWindow() throws {
        let bootID = "boot"
        let root = try makeTemporaryRegistryRoot()
        let provider = try makeSourceLaneProvider(
            root: root,
            bootID: bootID,
            appName: "Wave Relay",
            providerInstanceID: "wave-relay-main",
            heartbeat: 1_000,
            sequence: 101,
            producerHostTime: 1_050,
            meters: [
                SourceLaneMeterRecordModel(sourceLaneID: 1, rms: 0, peak: 0),
                SourceLaneMeterRecordModel(sourceLaneID: 2, rms: 0.003_162_277_7, peak: 0.004),
                SourceLaneMeterRecordModel(sourceLaneID: 3, rms: 0.01, peak: 0.02),
                SourceLaneMeterRecordModel(sourceLaneID: 4, rms: 0.031_622_776, peak: 0.04),
                SourceLaneMeterRecordModel(sourceLaneID: 5, rms: 0.1, peak: 0.2),
                SourceLaneMeterRecordModel(sourceLaneID: 6, rms: 1, peak: 1)
            ]
        )
        try TelemetryRegistryStore(registryRootURL: root).writeProvider(provider)
        let consumer = makeConsumer(root: root, bootID: bootID, now: 1_100)

        let snapshot = consumer.poll()

        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 1)?.rms ?? -1, 0, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 1)?.displayDrive ?? -1, 0, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 2)?.displayDrive ?? -1, 0, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 3)?.displayDrive ?? -1, 0.2, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 4)?.displayDrive ?? -1, 0.4, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 5)?.displayDrive ?? -1, 0.6, accuracy: 0.000_001)
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 6)?.displayDrive ?? -1, 1, accuracy: 0.000_001)
    }

    func testSpeakerMetersRemainPreferredButSelectedSourceLaneProviderCanBeChosen() throws {
        let bootID = "boot"
        let root = try makeTemporaryRegistryRoot()
        let store = TelemetryRegistryStore(registryRootURL: root)
        try store.writeProvider(
            makeSourceLaneProvider(
                root: root,
                bootID: bootID,
                appName: "Wave Relay",
                providerInstanceID: "wave-relay-main",
                heartbeat: 1_100,
                sequence: 200,
                producerHostTime: 1_100,
                meters: [SourceLaneMeterRecordModel(sourceLaneID: 1, rms: 0.8, peak: 0.9)]
            )
        )
        try store.writeProvider(
            makeProvider(
                root: root,
                bootID: bootID,
                appName: "Orbisonic Main",
                providerInstanceID: "orbisonic-main",
                heartbeat: 1_000,
                sequence: 201,
                producerHostTime: 1_000,
                meters: [SpeakerMeterRecordModel(channelID: 2, rms: 0.2, peak: 0.3)]
            )
        )
        let consumer = makeConsumer(root: root, bootID: bootID, now: 1_150)

        let automatic = consumer.poll()
        let selectedSourceLane = consumer.poll(selectedProviderID: "wave-relay-main")

        XCTAssertEqual(automatic.selectedProviderID, "orbisonic-main")
        XCTAssertEqual(automatic.selectedMeterSlotKind, .speakerMeters)
        XCTAssertEqual(automatic.meterSnapshot?.level(channel: 2)?.rms ?? -1, 0.2, accuracy: 0.000_001)
        XCTAssertEqual(selectedSourceLane.selectedProviderID, "wave-relay-main")
        XCTAssertEqual(selectedSourceLane.selectedMeterSlotKind, .sourceLaneMeters)
        XCTAssertEqual(selectedSourceLane.meterSnapshot?.level(channel: 1)?.rms ?? -1, 0.8, accuracy: 0.000_001)
    }

    func testStaleProviderKeepsTelemetrySamplesButLabelsDisplayedMeterStale() throws {
        let bootID = "boot"
        let root = try makeTemporaryRegistryRoot()
        let provider = try makeProvider(
            root: root,
            bootID: bootID,
            appName: "Orbisonic",
            providerInstanceID: "orbisonic-main",
            heartbeat: 100,
            sequence: 9,
            producerHostTime: 100,
            meters: [SpeakerMeterRecordModel(channelID: 1, rms: 0.2, peak: 0.4)]
        )
        try TelemetryRegistryStore(registryRootURL: root).writeProvider(provider)
        let consumer = makeConsumer(root: root, bootID: bootID, now: 2_000, staleTicks: 250)

        let snapshot = consumer.poll()

        XCTAssertEqual(snapshot.status, "Stale")
        XCTAssertEqual(snapshot.displayedMeter, "stale telemetry")
        XCTAssertEqual(snapshot.meterSnapshot?.level(channel: 1)?.peak ?? -1, 0.4, accuracy: 0.000_001)
    }

    private func makeConsumer(
        root: URL,
        bootID: String,
        now: UInt64,
        staleTicks: UInt64 = 1_000
    ) -> OrbitalViewTelemetryConsumer {
        OrbitalViewTelemetryConsumer(
            configuration: OrbitalViewTelemetryConsumerConfiguration(
                registryStore: TelemetryRegistryStore(registryRootURL: root),
                bootIDProvider: { bootID },
                hostTimeProvider: { now },
                staleProviderHostTicks: staleTicks,
                staleFrameHostTicks: staleTicks
            )
        )
    }

    private func makeProvider(
        root: URL,
        bootID: String,
        appName: String,
        providerInstanceID: String,
        heartbeat: UInt64,
        sequence: UInt64,
        producerHostTime: UInt64,
        meters: [SpeakerMeterRecordModel],
        extendedMeters: [UInt32: ExtendedSpeakerMeterFields] = [:]
    ) throws -> TelemetryProviderRegistryRecord {
        _ = root
        let identity = TelemetryEndpointIdentity(
            appID: "audio.orbisonic.app.current",
            appName: appName,
            providerInstanceID: providerInstanceID,
            bootID: bootID
        )
        let recordCapacity = UInt32(max(1, meters.count))
        let segment = try SharedTelemetrySegment.create(
            identity: identity,
            slots: [
                TelemetrySlotConfiguration(
                    slotType: .speakerMeters,
                    recordCapacity: recordCapacity,
                    payloadCapacity: Int(recordCapacity) * SpeakerMeterPayloadRecord.byteSize
                )
            ],
            name: "/ovt\(String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(11)).lowercased())"
        )
        let payloadByteSize = meters.count * SpeakerMeterPayloadRecord.byteSize
        let publisher = try segment.publisher(for: .speakerMeters)
        try publisher.publish(
            sequence: sequence,
            producerHostTime: producerHostTime,
            recordCount: UInt32(meters.count),
            payloadByteSize: payloadByteSize
        ) { payload in
            for (index, meter) in meters.enumerated() {
                let offset = index * SpeakerMeterPayloadRecord.byteSize
                payload.writeInteger(meter.channelID, at: offset)
                payload.writeFloat32(meter.rms, at: offset + 4)
                payload.writeFloat32(meter.peak, at: offset + 8)
                payload.writeUInt8(meter.clip ? 1 : 0, at: offset + 12)
                if let extended = extendedMeters[meter.channelID] {
                    payload.writeUInt8(extended.recordFlags, at: offset + 13)
                    payload.writeInteger(extended.dvsChannel, at: offset + 16)
                    payload.writeInteger(extended.stateFlags, at: offset + 20)
                    payload.writeFloat32(extended.vuNormalized, at: offset + 24)
                    payload.writeFloat32(extended.vuDbFS, at: offset + 28)
                }
            }
            return payloadByteSize
        }
        segments.append(segment)

        return TelemetryProviderRegistryRecord(
            identity: identity,
            capabilityBits: [.speakerMeters],
            sharedMemoryName: segment.name,
            segmentByteSize: segment.byteSize,
            createdHostTime: heartbeat,
            lastHeartbeatHostTime: heartbeat,
            humanRouteLabel: "Orbisonic Live",
            humanSourceLabel: "Orbisonic Live",
            slotSummary: [
                TelemetryRegistrySlotSummary(
                    slotType: .speakerMeters,
                    recordCapacity: recordCapacity
                )
            ]
        )
    }

    private func makeSourceLaneProvider(
        root: URL,
        bootID: String,
        appName: String,
        providerInstanceID: String,
        heartbeat: UInt64,
        sequence: UInt64,
        producerHostTime: UInt64,
        meters: [SourceLaneMeterRecordModel]
    ) throws -> TelemetryProviderRegistryRecord {
        _ = root
        let identity = TelemetryEndpointIdentity(
            appID: "com.sonicsphere.waverelay",
            appName: appName,
            providerInstanceID: providerInstanceID,
            bootID: bootID
        )
        let recordCapacity = UInt32(max(1, meters.count))
        let segment = try SharedTelemetrySegment.create(
            identity: identity,
            slots: [
                TelemetrySlotConfiguration(
                    slotType: .sourceLaneMeters,
                    recordCapacity: recordCapacity,
                    payloadCapacity: Int(recordCapacity) * SourceLaneMeterPayloadRecord.byteSize
                )
            ],
            name: "/ovt\(String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(11)).lowercased())"
        )
        let payloadByteSize = meters.count * SourceLaneMeterPayloadRecord.byteSize
        let publisher = try segment.publisher(for: .sourceLaneMeters)
        try publisher.publish(
            sequence: sequence,
            producerHostTime: producerHostTime,
            recordCount: UInt32(meters.count),
            payloadByteSize: payloadByteSize
        ) { payload in
            for (index, meter) in meters.enumerated() {
                let offset = index * SourceLaneMeterPayloadRecord.byteSize
                payload.writeInteger(meter.sourceLaneID, at: offset)
                payload.writeInteger(UInt32(0), at: offset + 4)
                payload.writeInteger(UInt32(0), at: offset + 8)
                payload.writeInteger(UInt32(0), at: offset + 12)
                payload.writeInteger(UInt32(0), at: offset + 16)
                payload.writeFloat32(meter.rms, at: offset + 20)
                payload.writeFloat32(meter.peak, at: offset + 24)
                payload.writeUInt8(meter.clip ? 1 : 0, at: offset + 28)
                payload.writeInteger(UInt64(0), at: offset + 32)
            }
            return payloadByteSize
        }
        segments.append(segment)

        return TelemetryProviderRegistryRecord(
            identity: identity,
            capabilityBits: [.sourceLaneMeters],
            sharedMemoryName: segment.name,
            segmentByteSize: segment.byteSize,
            createdHostTime: heartbeat,
            lastHeartbeatHostTime: heartbeat,
            humanRouteLabel: "Wave Relay Source Lanes",
            humanSourceLabel: "sourceLaneMeters CH001-CH030",
            slotSummary: [
                TelemetryRegistrySlotSummary(
                    slotType: .sourceLaneMeters,
                    recordCapacity: recordCapacity
                )
            ]
        )
    }

    private func makeTemporaryRegistryRoot() throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("OrbitalViewTelemetryTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        temporaryRoots.append(root)
        return root
    }
}

private extension UnsafeMutableRawBufferPointer {
    func writeUInt8(_ value: UInt8, at offset: Int) {
        self[offset] = value
    }

    func writeInteger<T: FixedWidthInteger>(_ value: T, at offset: Int) {
        var littleEndianValue = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndianValue) { raw in
            for index in 0..<raw.count {
                self[offset + index] = raw[index]
            }
        }
    }

    func writeFloat32(_ value: Float, at offset: Int) {
        writeInteger(value.bitPattern, at: offset)
    }
}
