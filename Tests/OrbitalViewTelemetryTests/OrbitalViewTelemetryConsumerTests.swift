import Foundation
import OrbisonicTelemetryKit
@testable import OrbitalViewTelemetry
import XCTest

final class OrbitalViewTelemetryConsumerTests: XCTestCase {
    private var segments: [SharedTelemetrySegment] = []
    private var temporaryRoots: [URL] = []

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
        meters: [SpeakerMeterRecordModel]
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
