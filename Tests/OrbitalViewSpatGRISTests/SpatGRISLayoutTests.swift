import XCTest
@testable import OrbitalViewCore
@testable import OrbitalViewSpatGRIS

final class SpatGRISLayoutTests: XCTestCase {
    func testCurrentSpeakerSetupImportsReceiverLayoutAndBounds() throws {
        let setup = try SpatGRISXML.parseSpeakerSetup(data: Data(Self.currentSpeakerXML.utf8))

        XCTAssertEqual(setup.version, SpatGRISSpeakerSetup.currentSpeakerSetupVersion)
        XCTAssertEqual(setup.spatMode, .dome)
        XCTAssertEqual(setup.sortedSpeakers.map(\.patchID), [1, 2])
        XCTAssertEqual(setup.bounds.halfExtent, 1, accuracy: 0.000_001)

        let scene = try setup.coreScene(id: "receiver")
        XCTAssertEqual(scene.coordinateSystem, .spatGRIS)
        XCTAssertEqual(scene.speakers.count, 2)
        if case .cartesian(let position, _) = scene.speakers[0].anchor {
            XCTAssertEqual(position.y, 1, accuracy: 0.000_001)
        } else {
            XCTFail("Expected cartesian anchor")
        }
    }

    func testLegacySpeakerSetupImportsSpeakerNLayout() throws {
        let setup = try SpatGRISXML.parseSpeakerSetup(data: Data(Self.legacySpeakerXML.utf8))

        XCTAssertEqual(setup.spatMode, .cube)
        XCTAssertEqual(setup.sortedSpeakers.map(\.patchID), [1, 2])
        XCTAssertEqual(setup.sortedSpeakers[1].position.x, -1, accuracy: 0.000_001)
    }

    func testProjectMetadataImportsSourceStateColorAndDirectOut() throws {
        let project = try SpatGRISXML.parseProject(data: Data(Self.projectXML.utf8))

        XCTAssertEqual(project.spatMode, .cube)
        XCTAssertEqual(project.sources.count, 2)
        XCTAssertEqual(project.sources[0].sourceID, 1)
        XCTAssertEqual(project.sources[0].state, .solo)
        XCTAssertEqual(project.sources[0].argbColor, 4_294_901_760)
        XCTAssertEqual(project.sources[0].directOutPatchID, 7)
        XCTAssertEqual(project.sources[1].hybridSpatMode, .dome)
    }

    func testOSCTextMessagesParseCartesianDegreesAndRadians() throws {
        let cartesian = try XCTUnwrap(SpatGRISOSCParser.parseTextLine("/spat/serv car 1 0.25 0.5 -0.75 0.1 0.2"))
        XCTAssertEqual(cartesian.kind, .cartesian)
        XCTAssertEqual(cartesian.position?.x ?? -1, 0.25, accuracy: 0.000_001)
        XCTAssertEqual(cartesian.horizontalSpan, 0.1, accuracy: 0.000_001)

        let degrees = try XCTUnwrap(SpatGRISOSCParser.parseTextLine("/spat/serv deg 2 0 0 1 0 0"))
        XCTAssertEqual(degrees.kind, .degrees)
        XCTAssertEqual(degrees.position?.y ?? -1, 1, accuracy: 0.000_001)

        let radians = try XCTUnwrap(SpatGRISOSCParser.parseTextLine("/spat/serv pol 3 1.5707963267948966 0 1 0 0"))
        XCTAssertEqual(radians.kind, .radians)
        XCTAssertEqual(radians.position?.x ?? -1, 1, accuracy: 0.000_001)
    }

    func testExportRoundTripsAsCurrentSpeakerSetup() throws {
        let setup = try SpatGRISXML.parseSpeakerSetup(data: Data(Self.currentSpeakerXML.utf8))
        let exported = SpatGRISXML.exportSpeakerSetup(setup)
        let roundTrip = try SpatGRISXML.parseSpeakerSetup(data: Data(exported.utf8))

        XCTAssertTrue(exported.contains(#"SPEAKER_SETUP_VERSION="4.0.0""#))
        XCTAssertEqual(roundTrip.spatMode, setup.spatMode)
        XCTAssertEqual(roundTrip.sortedSpeakers.map(\.patchID), [1, 2])
        XCTAssertEqual(roundTrip.sortedSpeakers[0].position.magnitude, 1, accuracy: 0.000_001)
    }

    func testInvalidXMLDiagnosticsRejectUnsafeDuplicateAndPort() {
        XCTAssertThrowsError(try SpatGRISXML.parseSpeakerSetup(data: Data(Self.unsafeXML.utf8))) { error in
            XCTAssertEqual(error as? SpatGRISLayoutError, .unsafeXML)
        }
        XCTAssertThrowsError(try SpatGRISXML.parseSpeakerSetup(data: Data(Self.duplicateXML.utf8))) { error in
            XCTAssertEqual(error as? SpatGRISLayoutError, .duplicatePatchID(1))
        }
        XCTAssertThrowsError(try SpatGRISOSC.validatePort(1023)) { error in
            XCTAssertEqual(error as? SpatGRISLayoutError, .invalidPort(1023))
        }
    }

    func testDerivedSceneBoundsReflectLargeLayouts() throws {
        let speakerA = try SpatGRISSpeaker(
            patchID: 1,
            position: try OrbitalViewVector3(x: -3, y: 0, z: 0)
        )
        let speakerB = try SpatGRISSpeaker(
            patchID: 2,
            position: try OrbitalViewVector3(x: 3, y: 2, z: -2)
        )
        let setup = try SpatGRISSpeakerSetup(spatMode: .cube, speakers: [speakerA, speakerB])

        XCTAssertEqual(setup.bounds.halfExtent, 3, accuracy: 0.000_001)
        let scene = try setup.coreScene(id: "large")
        if case .parametric(let shell) = scene.shell {
            XCTAssertEqual(shell.radiusM, 3, accuracy: 0.000_001)
        } else {
            XCTFail("Expected parametric shell")
        }
    }

    private static let currentSpeakerXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <SPEAKER_SETUP SPEAKER_SETUP_VERSION="4.0.0" SPAT_MODE="Dome" DIFFUSION="0" GENERAL_MUTE="0" UUID="fixture-speakers">
      <SPEAKER_GROUP SPEAKER_GROUP_NAME="MAIN_SPEAKER_GROUP_NAME" CARTESIAN_POSITION="(0, 0, 0)" UUID="fixture-group">
        <SPEAKER SPEAKER_PATCH_ID="1" IO_STATE="normal" GAIN="0" DIRECT_OUT_ONLY="0" CARTESIAN_POSITION="(0, 1, 0)" UUID="speaker-1"/>
        <SPEAKER SPEAKER_PATCH_ID="2" IO_STATE="muted" GAIN="-3" DIRECT_OUT_ONLY="0" CARTESIAN_POSITION="(1, 0, 0)" UUID="speaker-2"/>
      </SPEAKER_GROUP>
    </SPEAKER_SETUP>
    """

    private static let legacySpeakerXML = """
    <SPEAKER_SETUP VERSION="3.0.0" SPAT_MODE="Cube" DIFFUSION="0">
      <SPEAKER_1 STATE="normal" GAIN="0">
        <POSITION X="1" Y="0" Z="0"/>
      </SPEAKER_1>
      <SPEAKER_2 STATE="muted" GAIN="-1">
        <POSITION X="-1" Y="0" Z="0"/>
      </SPEAKER_2>
    </SPEAKER_SETUP>
    """

    private static let projectXML = """
    <SPAT_GRIS_PROJECT_DATA SPAT_MODE="Cube">
      <SOURCES>
        <SOURCE_1 STATE="solo" COLOR="4294901760" DIRECT_OUT="7"/>
        <SOURCE_2 STATE="muted" COLOR="4278255360" HYBRID_SPAT_MODE="Dome"/>
      </SOURCES>
    </SPAT_GRIS_PROJECT_DATA>
    """

    private static let unsafeXML = """
    <!DOCTYPE SPEAKER_SETUP [ <!ENTITY xxe SYSTEM "file:///etc/passwd"> ]>
    <SPEAKER_SETUP SPEAKER_SETUP_VERSION="4.0.0" SPAT_MODE="Dome"/>
    """

    private static let duplicateXML = """
    <SPEAKER_SETUP SPEAKER_SETUP_VERSION="4.0.0" SPAT_MODE="Dome">
      <SPEAKER_GROUP CARTESIAN_POSITION="(0, 0, 0)">
        <SPEAKER SPEAKER_PATCH_ID="1" IO_STATE="normal" GAIN="0" DIRECT_OUT_ONLY="0" CARTESIAN_POSITION="(0, 1, 0)"/>
        <SPEAKER SPEAKER_PATCH_ID="1" IO_STATE="normal" GAIN="0" DIRECT_OUT_ONLY="0" CARTESIAN_POSITION="(1, 0, 0)"/>
      </SPEAKER_GROUP>
    </SPEAKER_SETUP>
    """
}
