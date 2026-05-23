import XCTest
@testable import OrbitalViewCore

final class OrbitalViewCoreTests: XCTestCase {
    func testUnitSphereDirectionValidation() throws {
        let direction = try UnitSphereDirection(x: 1, y: 0, z: 0)
        XCTAssertEqual(direction.x, 1)

        XCTAssertThrowsError(try UnitSphereDirection(x: .nan, y: 0, z: 0)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .nonFiniteValue(field: "x"))
        }

        XCTAssertThrowsError(try UnitSphereDirection(x: 0, y: 0, z: 0)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .zeroVector)
        }

        XCTAssertThrowsError(try UnitSphereDirection(x: 2, y: 0, z: 0)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .invalidUnitVectorMagnitude(2))
        }

        let normalized = try UnitSphereDirection.normalized(x: 2, y: 0, z: 0)
        XCTAssertEqual(normalized, try UnitSphereDirection(x: 1, y: 0, z: 0))
    }

    func testSpeakerValidationRejectsInvalidValues() throws {
        let direction = try UnitSphereDirection(x: 1, y: 0, z: 0)

        XCTAssertThrowsError(
            try OrbitalViewSpeaker(
                id: "s0",
                channel: 0,
                label: "Fey 00",
                anchor: .direction(direction, offsetM: 0.05),
                shape: .sphere(radiusM: 0.02)
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .invalidChannel(0))
        }

        XCTAssertThrowsError(
            try OrbitalViewSpeaker(
                id: "s1",
                channel: 1,
                label: " ",
                anchor: .direction(direction, offsetM: 0.05),
                shape: .sphere(radiusM: 0.02)
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .emptyLabel)
        }

        XCTAssertThrowsError(
            try OrbitalViewSpeaker(
                id: "s1",
                channel: 1,
                label: "Fey 01",
                anchor: .edge(edgeID: "e1", t: 1.5, offsetM: 0.05),
                shape: .sphere(radiusM: 0.02)
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "speaker.anchor.t", value: 1.5, validRange: "0...1")
            )
        }

        XCTAssertThrowsError(
            try OrbitalViewSpeaker(
                id: "s1",
                channel: 1,
                label: "Fey 01",
                anchor: .direction(direction, offsetM: 0.05),
                shape: .sphere(radiusM: 0)
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .nonPositiveValue(field: "speaker.shape.radiusM", value: 0)
            )
        }
    }

    func testSpeakerShapeSupportsSonicSphereCubeAndZScaledPrism() throws {
        let cube = try SpeakerShape.sonicSphereDefault(edgeM: 0.06)
        XCTAssertEqual(cube, .cube(edgeM: 0.06))
        XCTAssertEqual(cube.sonicSphereZScale, 1)

        let prism = try SpeakerShape.sonicSphereRectangularPrism(edgeM: 0.06, zScale: 2)
        XCTAssertEqual(
            prism,
            .rectangularPrism(widthM: 0.06, heightM: 0.06, depthM: 0.12, bevelM: 0)
        )
        XCTAssertEqual(prism.sonicSphereZScale, 2)

        XCTAssertThrowsError(try SpeakerShape.cube(edgeM: 0).validate()) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .nonPositiveValue(field: "speaker.shape.edgeM", value: 0)
            )
        }

        XCTAssertThrowsError(try SpeakerShape.sonicSphereRectangularPrism(edgeM: 0.06, zScale: .nan)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .nonFiniteValue(field: "speaker.shape.zScale"))
        }

        XCTAssertThrowsError(try SpeakerShape.sonicSphereRectangularPrism(edgeM: 0.06, zScale: 2.1)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "speaker.shape.zScale", value: 2.1, validRange: "1...2")
            )
        }
    }

    func testFaceCenterBloomDistanceUsesEachFaceCenter() throws {
        XCTAssertEqual(try SpeakerFaceCenterBloom.normalizedDistanceFromFaceCenter(u: 0.5, v: 0.5), 0)
        XCTAssertEqual(
            try SpeakerFaceCenterBloom.normalizedDistanceFromFaceCenter(u: 0, v: 0),
            1,
            accuracy: 1.0e-12
        )
        XCTAssertEqual(
            try SpeakerFaceCenterBloom.normalizedDistanceFromFaceCenter(u: 1, v: 1),
            1,
            accuracy: 1.0e-12
        )

        XCTAssertThrowsError(try SpeakerFaceCenterBloom.normalizedDistanceFromFaceCenter(u: -0.01, v: 0.5)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "speaker.face.u", value: -0.01, validRange: "0...1")
            )
        }
    }

    func testImportedShellReferenceValidation() throws {
        let nodes = try [
            ShellNode(id: "n1", position: OrbitalViewVector3(x: 0, y: 1, z: 0)),
            ShellNode(id: "n2", position: OrbitalViewVector3(x: 1, y: 0, z: 0)),
            ShellNode(id: "n3", position: OrbitalViewVector3(x: 0, y: 0, z: 1))
        ]

        XCTAssertThrowsError(
            try OrbitalViewImportedShellGeometry(
                radiusM: 1,
                nodes: nodes,
                edges: [
                    try ShellEdge(id: "e1", a: "n1", b: "missing")
                ],
                faces: []
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .unknownNodeID("missing"))
        }

        XCTAssertThrowsError(try ShellFace(id: "f1", nodes: ["n1", "n2"])) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidFaceReference(faceID: "f1", reason: "faces must reference at least three nodes")
            )
        }

        XCTAssertNoThrow(
            try OrbitalViewImportedShellGeometry(
                radiusM: 1,
                nodes: nodes,
                edges: [
                    try ShellEdge(id: "e1", a: "n1", b: "n2")
                ],
                faces: [
                    try ShellFace(id: "f1", nodes: ["n1", "n2", "n3"])
                ]
            )
        )
    }

    func testMeterFramePreservesChannelIdentity() throws {
        let low = try SpeakerMeterLevel(rms: 0.2, peak: 0.3, clip: false)
        let hot = try SpeakerMeterLevel(rms: 0.9, peak: 1.0, clip: true)
        let frame = try SpeakerMeterFrame(timestamp: 42, levelsByChannel: [1: low, 30: hot])

        XCTAssertEqual(frame.levelsByChannel[1], low)
        XCTAssertEqual(frame.levelsByChannel[30], hot)
        XCTAssertNil(frame.levelsByChannel[2])
        XCTAssertEqual(frame.source, .speakerBus)

        XCTAssertThrowsError(try SpeakerMeterLevel(rms: .nan, peak: 0, clip: false)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .nonFiniteValue(field: "meter.rms"))
        }

        XCTAssertThrowsError(try SpeakerMeterFrame(timestamp: 0, levelsByChannel: [0: low])) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .invalidChannel(0))
        }
    }

    func testTelemetrySourceDescriptorDefaultsAndValidation() throws {
        XCTAssertEqual(
            OrbitalViewTelemetrySourceKind.allCases.map(\.displayName),
            [
                "Speaker bus",
                "Object bus",
                "Final output",
                "Hardware tap",
                "Local livestream test generator",
                "External Wavefield stream",
                "Orbisonic prepared meter tap",
                "Splat prepared analysis",
                "Review local audio",
                "Synthetic visual stress"
            ]
        )
        XCTAssertEqual(OrbitalViewTelemetrySourceDescriptor.speakerBus.label, "Speaker bus")
        XCTAssertEqual(OrbitalViewTelemetrySourceDescriptor.objectBus.label, "Object bus")
        XCTAssertTrue(OrbitalViewTelemetrySourceDescriptor.reviewLocalAudio.kind.isReviewOrTestHarness)
        XCTAssertTrue(OrbitalViewTelemetrySourceDescriptor.syntheticVisualStress.kind.isReviewOrTestHarness)
        XCTAssertFalse(OrbitalViewTelemetrySourceDescriptor.orbisonicPreparedMeterTap.kind.isReviewOrTestHarness)

        let custom = try OrbitalViewTelemetrySourceDescriptor(
            kind: .hardwareTap,
            label: " DVS hardware tap ",
            detail: " Prepared by host outside realtime callback "
        )
        XCTAssertEqual(custom.label, "DVS hardware tap")
        XCTAssertEqual(custom.detail, "Prepared by host outside realtime callback")

        let encoded = try JSONEncoder().encode(custom)
        let decoded = try JSONDecoder().decode(OrbitalViewTelemetrySourceDescriptor.self, from: encoded)
        XCTAssertEqual(decoded, custom)

        XCTAssertThrowsError(
            try OrbitalViewTelemetrySourceDescriptor(kind: .speakerBus, label: " ")
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .emptyID(field: "telemetrySource.label"))
        }

        let invalidJSON = #"{"kind":"speakerBus","label":" "}"#.data(using: .utf8)!
        XCTAssertThrowsError(
            try JSONDecoder().decode(OrbitalViewTelemetrySourceDescriptor.self, from: invalidJSON)
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .emptyID(field: "telemetrySource.label"))
        }

        let oversized = String(repeating: "x", count: OrbitalViewTelemetrySourceDescriptor.maxLabelLength + 1)
        XCTAssertThrowsError(
            try OrbitalViewTelemetrySourceDescriptor(kind: .speakerBus, label: oversized)
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(
                    field: "telemetrySource.label",
                    value: Double(OrbitalViewTelemetrySourceDescriptor.maxLabelLength + 1),
                    validRange: "1...\(OrbitalViewTelemetrySourceDescriptor.maxLabelLength)"
                )
            )
        }
    }

    func testSpeakerMeterVisualSettingsValidateDisplayGainAndStyle() throws {
        let defaults = SpeakerMeterVisualSettings.default
        XCTAssertEqual(defaults.visualGainDB, 0)
        XCTAssertEqual(defaults.style, .cubeScalarCenterBloom)
        XCTAssertEqual(defaults.colorScheme, .daftPunkBow)
        XCTAssertEqual(defaults.ringFrontDensity, 3.3)
        XCTAssertEqual(defaults.tileDetail, 10)
        XCTAssertEqual(defaults.inputCalibration, 1)
        XCTAssertEqual(defaults.levelCompression, 1)
        XCTAssertEqual(defaults.displayCeiling, 1)
        XCTAssertEqual(defaults.hotResponse, 1.7)
        XCTAssertEqual(defaults.hotThreshold, 0.68)
        XCTAssertEqual(defaults.hotFillStrength, 0.86)
        XCTAssertEqual(defaults.vuPaletteDrive, 1.7)
        XCTAssertEqual(defaults.idleTint, 0.25)
        XCTAssertEqual(defaults.checkerContrast, 0.08)
        XCTAssertEqual(defaults.memoryCarryover, 0.68)
        XCTAssertEqual(defaults.checkerBandVelocity, 0.826)
        XCTAssertEqual(defaults.checkerBandWidth, 0.831)
        XCTAssertEqual(defaults.speakerZScale, 1)
        XCTAssertEqual(defaults.bloomMin, 0.08)
        XCTAssertEqual(defaults.bloomMax, 0.92)
        XCTAssertEqual(defaults.bloomEdge, 0.16)
        XCTAssertEqual(defaults.responseCurve, 0.72)
        XCTAssertEqual(defaults.peakHoldSeconds, 0.35)
        XCTAssertEqual(defaults.releaseMemory, 0.68)
        XCTAssertEqual(defaults.hotFill, 0.86)
        XCTAssertEqual(defaults.facePixels, 9)
        XCTAssertFalse(defaults.showsDiagnostics)
        XCTAssertEqual(
            SpeakerMeterVisualStyle.builtInStyles,
            [.cubeScalarCenterBloom, .checkerPulseRingAndDiagonalWave, .prismGlow, .warmPulse, .coolPulse]
        )

        let hot = try SpeakerMeterVisualSettings(visualGainDB: 24, style: .warmPulse, speakerZScale: 2)
        XCTAssertEqual(hot.visualGainDB, 24)
        XCTAssertEqual(hot.style.displayName, "Warm Pulse")
        XCTAssertEqual(hot.colorScheme, .daftPunkBow)
        XCTAssertEqual(hot.speakerZScale, 2)

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(visualGainDB: .nan)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .nonFiniteValue(field: "meterVisual.visualGainDB")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(visualGainDB: 24.5)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.visualGainDB", value: 24.5, validRange: "-24...24")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(tileDetail: 2)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.tileDetail", value: 2, validRange: "4...32")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(inputCalibration: 0.2)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.inputCalibration", value: 0.20000000298023224, validRange: "0.25...2")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(levelCompression: 4.2)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.levelCompression", value: 4.199999809265137, validRange: "1...4")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(displayCeiling: 0.4)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.displayCeiling", value: 0.4000000059604645, validRange: "0.5...1")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(speakerZScale: 0.99)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.speakerZScale", value: 0.9900000095367432, validRange: "1...2")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(bloomMin: 0.8, bloomMax: 0.2)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.bloomMax", value: 0.20000000298023224, validRange: ">= bloomMin")
            )
        }

        XCTAssertThrowsError(try SpeakerMeterVisualSettings(facePixels: 65)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.facePixels", value: 65, validRange: "4...64")
            )
        }
    }

    func testCubeVUScalarsFollowBrowserMusicContract() throws {
        let defaults = SpeakerMeterVisualSettings.default
        let identity = SpeakerCubeVUScalars(rawRms: 0.42, settings: defaults)

        XCTAssertEqual(identity.rawRms, 0.42, accuracy: 0.000_001)
        XCTAssertEqual(identity.calibratedRms, 0.42, accuracy: 0.000_001)
        XCTAssertEqual(identity.displayVuScalar, 0.42, accuracy: 0.000_001)
        XCTAssertEqual(identity.hotScalar, 1 - powf(1 - 0.42, defaults.hotResponse), accuracy: 0.000_001)

        let compressed = SpeakerCubeVUScalars(
            rawRms: 0.2,
            settings: try SpeakerMeterVisualSettings(levelCompression: 2)
        )
        XCTAssertGreaterThan(compressed.displayVuScalar, 0.2)

        let capped = SpeakerCubeVUScalars(
            rawRms: 0.9,
            settings: try SpeakerMeterVisualSettings(displayCeiling: 0.65)
        )
        XCTAssertEqual(capped.displayVuScalar, 0.65, accuracy: 0.000_001)
    }

    func testCubeVUHotFillUsesCalibratedRMSNotDisplayCompression() throws {
        let displayHeavy = try SpeakerMeterVisualSettings(
            levelCompression: 4,
            displayCeiling: 0.55,
            hotResponse: 1
        )
        let scalars = SpeakerCubeVUScalars(rawRms: 0.25, settings: displayHeavy)

        XCTAssertGreaterThan(scalars.displayVuScalar, scalars.calibratedRms)
        XCTAssertEqual(scalars.displayVuScalar, 0.55, accuracy: 0.000_001)
        XCTAssertEqual(scalars.hotScalar, scalars.calibratedRms, accuracy: 0.000_001)
    }

    func testPerformanceSettingsDefaultAndValidation() throws {
        let defaults = OrbitalViewPerformanceSettings.default
        XCTAssertEqual(defaults.activeViewportFramesPerSecond, 60)
        XCTAssertEqual(defaults.meterOnlyViewportFramesPerSecond, 10)
        XCTAssertEqual(defaults.inspectorRefreshFramesPerSecond, 10)
        XCTAssertTrue(defaults.drawsOnDemand)

        let thirty = try OrbitalViewPerformanceSettings(
            activeViewportFramesPerSecond: 30,
            meterOnlyViewportFramesPerSecond: 12,
            inspectorRefreshFramesPerSecond: 8,
            drawsOnDemand: false
        )
        XCTAssertEqual(thirty.activeViewportFramesPerSecond, 30)
        XCTAssertEqual(thirty.meterOnlyViewportFramesPerSecond, 12)
        XCTAssertEqual(thirty.inspectorRefreshFramesPerSecond, 8)
        XCTAssertFalse(thirty.drawsOnDemand)

        XCTAssertThrowsError(try OrbitalViewPerformanceSettings(activeViewportFramesPerSecond: 45)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "performance.activeViewportFramesPerSecond", value: 45, validRange: "30 or 60")
            )
        }

        XCTAssertThrowsError(try OrbitalViewPerformanceSettings(meterOnlyViewportFramesPerSecond: 0)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "performance.meterOnlyViewportFramesPerSecond", value: 0, validRange: "1...30")
            )
        }

        XCTAssertThrowsError(try OrbitalViewPerformanceSettings(inspectorRefreshFramesPerSecond: 31)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "performance.inspectorRefreshFramesPerSecond", value: 31, validRange: "1...30")
            )
        }
    }

    func testSpeakerMeterVisualStyleCodableRoundTrip() throws {
        let settings = try SpeakerMeterVisualSettings(visualGainDB: -6, style: .customTBD)
        let encoded = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(SpeakerMeterVisualSettings.self, from: encoded)

        XCTAssertEqual(decoded, settings)

        let invalidJSON = """
        {
            "visualGainDB": 99,
            "style": "checkerPulseRingAndDiagonalWave",
            "colorScheme": "kimiPurple",
            "ringFrontDensity": 3.3,
            "bandSoftness": 0.85,
            "tileDetail": 10,
            "idleTint": 0.36,
            "memoryCarryover": 0.58,
            "checkerBandVelocity": 0.826,
            "checkerBandWidth": 0.831
        }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(SpeakerMeterVisualSettings.self, from: invalidJSON)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "meterVisual.visualGainDB", value: 99, validRange: "-24...24")
            )
        }

        let legacyJSONWithoutSpeakerZScale = """
        {
            "visualGainDB": -3,
            "style": "checkerPulseRingAndDiagonalWave",
            "colorScheme": "kimiPurple",
            "ringFrontDensity": 3.3,
            "bandSoftness": 0.85,
            "tileDetail": 10,
            "idleTint": 0.36,
            "memoryCarryover": 0.58,
            "checkerBandVelocity": 0.826,
            "checkerBandWidth": 0.831
        }
        """.data(using: .utf8)!
        let legacyDecoded = try JSONDecoder().decode(
            SpeakerMeterVisualSettings.self,
            from: legacyJSONWithoutSpeakerZScale
        )
        XCTAssertEqual(legacyDecoded.speakerZScale, 1)
        XCTAssertEqual(legacyDecoded.bloomMin, SpeakerMeterVisualSettings.default.bloomMin)
        XCTAssertEqual(legacyDecoded.style, .checkerPulseRingAndDiagonalWave)

        let partialLegacyJSON = """
        {
            "visualGainDB": 0
        }
        """.data(using: .utf8)!
        let partialLegacyDecoded = try JSONDecoder().decode(SpeakerMeterVisualSettings.self, from: partialLegacyJSON)
        XCTAssertEqual(partialLegacyDecoded.style, .cubeScalarCenterBloom)
        XCTAssertEqual(partialLegacyDecoded.colorScheme, .daftPunkBow)

        let legacyRippleAlias = try JSONDecoder().decode(
            SpeakerMeterVisualStyle.self,
            from: #""checkerRipple""#.data(using: .utf8)!
        )
        XCTAssertEqual(legacyRippleAlias, .checkerPulseRingAndDiagonalWave)
    }

    func testSpeakerMeterFrameSanitizerClampsAndDiagnosesUnsafeHostSamples() throws {
        let sanitizer = SpeakerMeterFrameSanitizer(expectedChannels: [1, 2, 3])
        let result = try sanitizer.sanitize(
            timestamp: .infinity,
            samples: [
                SpeakerMeterSample(channel: 1, rms: -0.25, peak: .infinity, clip: false),
                SpeakerMeterSample(channel: 3, rms: .nan, peak: 1.2, clip: false),
                SpeakerMeterSample(channel: 4, rms: 0.4, peak: 0.5, clip: false),
                SpeakerMeterSample(channel: 0, rms: 0.4, peak: 0.5, clip: false)
            ]
        )

        XCTAssertEqual(result.frame.timestamp, 0)
        XCTAssertEqual(result.frame.levelsByChannel[1]?.rms, 0)
        XCTAssertEqual(result.frame.levelsByChannel[1]?.peak, 0)
        XCTAssertEqual(result.frame.levelsByChannel[3]?.rms, 0)
        XCTAssertEqual(result.frame.levelsByChannel[3]?.peak, 1)
        XCTAssertEqual(result.frame.levelsByChannel[3]?.clip, true)
        XCTAssertEqual(result.diagnostics.missingChannels, [2])
        XCTAssertEqual(result.diagnostics.extraChannels, [4])
        XCTAssertEqual(result.diagnostics.invalidChannels, [0])
        XCTAssertEqual(result.diagnostics.replacedValues.count, 2)
        XCTAssertEqual(result.diagnostics.clampedValues.count, 2)
        XCTAssertTrue(result.diagnostics.timestampReplaced)
        XCTAssertTrue(result.diagnostics.hasIssues)
    }

    func testInputDiagnosticsTrackAllowedTelemetryOverloadActionsOutsideRealtime() throws {
        let diagnostics = OrbitalViewInputDiagnostics(
            overloadActions: [
                .keepLatestCompleteSnapshot,
                .dropStaleFrames,
                .setDiagnosticsOutsideRealtime,
                .dropStaleFrames
            ]
        )

        XCTAssertEqual(
            diagnostics.overloadActions,
            [.dropStaleFrames, .keepLatestCompleteSnapshot, .setDiagnosticsOutsideRealtime]
        )
        XCTAssertTrue(diagnostics.hasIssues)
        XCTAssertEqual(
            OrbitalViewTelemetryOverloadAction.allCases.map(\.displayName),
            [
                "Drop stale frames",
                "Decimate display refresh",
                "Keep latest complete snapshot",
                "Set diagnostics outside realtime"
            ]
        )

        let encoded = try JSONEncoder().encode(diagnostics)
        let decoded = try JSONDecoder().decode(OrbitalViewInputDiagnostics.self, from: encoded)
        XCTAssertEqual(decoded, diagnostics)

        let legacyJSON = #"{"missingChannels":[1],"timestampReplaced":true}"#.data(using: .utf8)!
        let legacyDecoded = try JSONDecoder().decode(OrbitalViewInputDiagnostics.self, from: legacyJSON)
        XCTAssertEqual(legacyDecoded.missingChannels, [1])
        XCTAssertTrue(legacyDecoded.timestampReplaced)
        XCTAssertEqual(legacyDecoded.overloadActions, [])
    }

    func testVisualPresetCodableRoundTripAndDefaultReset() throws {
        let preset = try OrbitalViewVisualPreset(
            id: "bow",
            displayName: "Daft Punk Bow Music",
            settings: SpeakerMeterVisualSettings.default
        )
        let encoded = try JSONEncoder().encode(preset)
        let decoded = try JSONDecoder().decode(OrbitalViewVisualPreset.self, from: encoded)

        XCTAssertEqual(decoded, preset)
        XCTAssertEqual(OrbitalViewVisualPreset.defaultMusic.settings, SpeakerMeterVisualSettings.default)
        XCTAssertEqual(OrbitalViewVisualPreset.resetToDefaultMusic(), .defaultMusic)

        let invalidPresetJSON = """
        {
            "id": " ",
            "displayName": "Invalid",
            "settings": \(String(data: try JSONEncoder().encode(SpeakerMeterVisualSettings.default), encoding: .utf8)!)
        }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(OrbitalViewVisualPreset.self, from: invalidPresetJSON)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .emptyID(field: "visualPreset.id"))
        }
    }

    func testDaftPunkBowThemeTokensAndRampStops() throws {
        let theme = OrbitalViewTheme.daftPunkBow

        XCTAssertEqual(theme.name, "Daft Punk Bow")
        XCTAssertEqual(theme.vuRamp.map(\.position), [0.00, 0.18, 0.34, 0.50, 0.66, 0.82, 1.00])
        XCTAssertEqual(theme.vuRamp.map(\.color), [
            .rgb(0xA78BFA),
            .rgb(0x5B8CFF),
            .rgb(0x22D3EE),
            .rgb(0x34D399),
            .rgb(0xFDE047),
            .rgb(0xFB923C),
            .rgb(0xEF4444)
        ])
        XCTAssertEqual(SpeakerMeterColorScheme.daftPunkBow.displayName, "Daft Punk Bow")
        XCTAssertEqual(SpeakerMeterColorScheme.daftPunkBow.theme, theme)

        let encoded = try JSONEncoder().encode(theme)
        let decoded = try JSONDecoder().decode(OrbitalViewTheme.self, from: encoded)
        XCTAssertEqual(decoded, theme)
    }

    func testThemeDecodesLegacyNameOnlyPayloadWithDefaultTokens() throws {
        let legacyJSON = """
        {
            "name": "Orbital Default"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(OrbitalViewTheme.self, from: legacyJSON)

        XCTAssertEqual(decoded.name, "Orbital Default")
        XCTAssertEqual(decoded.vuRamp, OrbitalViewTheme.default.vuRamp)
        XCTAssertEqual(decoded.accent, OrbitalViewTheme.default.accent)
    }

    func testDaftPunkBowColorSchemeCodableAndTechRainbowMigrationAlias() throws {
        let settings = try SpeakerMeterVisualSettings(colorScheme: .daftPunkBow)
        let encoded = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(SpeakerMeterVisualSettings.self, from: encoded)

        XCTAssertEqual(decoded.colorScheme, .daftPunkBow)
        XCTAssertEqual(decoded.colorScheme.displayName, "Daft Punk Bow")

        let legacyTechRainbowJSON = """
        {
            "visualGainDB": -3,
            "style": "checkerPulseRingAndDiagonalWave",
            "colorScheme": "techRainbow",
            "ringFrontDensity": 3.3,
            "bandSoftness": 0.85,
            "tileDetail": 10,
            "idleTint": 0.36,
            "memoryCarryover": 0.58,
            "checkerBandVelocity": 0.826,
            "checkerBandWidth": 0.831,
            "speakerZScale": 1
        }
        """.data(using: .utf8)!
        let migrated = try JSONDecoder().decode(SpeakerMeterVisualSettings.self, from: legacyTechRainbowJSON)

        XCTAssertEqual(migrated.colorScheme, .daftPunkBow)
        XCTAssertEqual(migrated.colorScheme.displayName, "Daft Punk Bow")
    }

    func testObjectFrameSetValidatesUnitSphereObjectsAndTrailCaps() throws {
        let pose = try UnitSphereDirection(x: 1, y: 0, z: 0)
        let trail = try [
            UnitSphereDirection(x: 0, y: 1, z: 0),
            UnitSphereDirection(x: 0, y: 0, z: 1)
        ]
        let object = try OrbitalViewObjectFrame(
            objectID: 17,
            label: "Lead Object",
            pose: pose,
            width: 0.25,
            trail: trail
        )
        let frameSet = try OrbitalViewObjectFrameSet(
            timestamp: 1,
            activeObjects: [object],
            maxTrailPointsPerObject: 2
        )

        XCTAssertEqual(frameSet.activeObjects.first?.objectID, 17)
        XCTAssertEqual(frameSet.activeObjects.first?.trail.count, 2)
        XCTAssertEqual(OrbitalViewObjectRenderBounds.default.minimum, -5)
        XCTAssertEqual(OrbitalViewObjectRenderBounds.default.maximum, 5)

        XCTAssertThrowsError(
            try OrbitalViewObjectFrame(
                objectID: 129,
                label: "Invalid",
                pose: pose
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .invalidObjectID(129))
        }

        XCTAssertThrowsError(
            try OrbitalViewObjectFrame(
                objectID: 1,
                label: "Negative Width",
                pose: pose,
                width: -0.1
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "object.width", value: -0.10000000149011612, validRange: ">= 0")
            )
        }

        XCTAssertThrowsError(
            try OrbitalViewObjectFrameSet(
                timestamp: 1,
                activeObjects: [object],
                maxTrailPointsPerObject: 1
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "objectFrame.trail", value: 2, validRange: "0...1")
            )
        }
    }

    func testObjectMeterFramePreservesObjectIdentity() throws {
        let quiet = try ObjectMeterLevel(rms: 0.1, peak: 0.2, clip: false)
        let hot = try ObjectMeterLevel(rms: 0.8, peak: 1, clip: true)
        let frame = try ObjectMeterFrame(timestamp: 42, levelsByObjectID: [1: quiet, 128: hot])

        XCTAssertEqual(frame.levelsByObjectID[1], quiet)
        XCTAssertEqual(frame.levelsByObjectID[128], hot)
        XCTAssertNil(frame.levelsByObjectID[2])
        XCTAssertEqual(frame.source, .objectBus)

        XCTAssertThrowsError(try ObjectMeterFrame(timestamp: 0, levelsByObjectID: [0: quiet])) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .invalidObjectID(0))
        }

        XCTAssertThrowsError(try ObjectMeterLevel(rms: .nan, peak: 0, clip: false)) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .nonFiniteValue(field: "objectMeter.rms"))
        }
    }

    func testObjectDisappearIsPreparedAsAbsentActiveObject() throws {
        let objectOne = try OrbitalViewObjectFrame(
            objectID: 1,
            label: "Object 1",
            pose: UnitSphereDirection(x: 1, y: 0, z: 0)
        )
        let objectTwo = try OrbitalViewObjectFrame(
            objectID: 2,
            label: "Object 2",
            pose: UnitSphereDirection(x: 0, y: 1, z: 0)
        )

        let beforeDisappear = try OrbitalViewObjectFrameSet(
            timestamp: 1,
            activeObjects: [objectOne, objectTwo]
        )
        let afterDisappear = try OrbitalViewObjectFrameSet(
            timestamp: 2,
            activeObjects: [objectTwo]
        )

        XCTAssertEqual(beforeDisappear.activeObjects.map(\.objectID), [1, 2])
        XCTAssertEqual(afterDisappear.activeObjects.map(\.objectID), [2])
        XCTAssertFalse(afterDisappear.activeObjects.contains { $0.objectID == 1 })
    }

    func testObjectVisualSettingsDefaultToCappedTrailsAndFiveUnitBounds() throws {
        let defaults = ObjectVisualSettings.default
        XCTAssertEqual(defaults.shape, .orb)
        XCTAssertEqual(defaults.palette, .objectPurple)
        XCTAssertFalse(defaults.trailsEnabled)
        XCTAssertFalse(defaults.glowTrailsEnabled)
        XCTAssertEqual(defaults.maxTrailPointsPerObject, 24)
        XCTAssertEqual(defaults.bounds.halfExtent, 5)

        let tuned = try ObjectVisualSettings(
            shape: .comet,
            palette: .sourceGold,
            trailsEnabled: true,
            maxTrailPointsPerObject: 64,
            glowTrailsEnabled: true,
            glowTrailWidth: 0.15,
            bounds: OrbitalViewObjectRenderBounds(halfExtent: 5)
        )
        XCTAssertEqual(tuned.shape.displayName, "Comet")
        XCTAssertEqual(tuned.palette.displayName, "Source Gold")
        XCTAssertTrue(tuned.trailsEnabled)
        XCTAssertTrue(tuned.glowTrailsEnabled)

        XCTAssertThrowsError(try ObjectVisualSettings(maxTrailPointsPerObject: 257)) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidRange(field: "objectVisual.maxTrailPointsPerObject", value: 257, validRange: "0...256")
            )
        }

        XCTAssertThrowsError(try ObjectVisualSettings(bounds: OrbitalViewObjectRenderBounds(halfExtent: 0))) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .nonPositiveValue(field: "objectBounds.halfExtent", value: 0)
            )
        }
    }

    func testCameraPresetsAreCenterLocked() throws {
        for mode in [OrbitalViewMode.plan, .frontElevation, .sideElevation, .isometric] {
            let camera = try OrbitalViewCameraState.preset(mode)
            XCTAssertEqual(camera.mode, mode)
            XCTAssertTrue(camera.target.isApproximatelyOrigin())
        }

        XCTAssertThrowsError(
            try OrbitalViewCameraState(
                mode: .custom,
                projection: .perspective,
                orbit: OrbitalViewOrbit(yawRadians: 0, pitchRadians: 0, distanceM: 2),
                target: OrbitalViewVector3(x: 0.1, y: 0, z: 0),
                enforceCenterLock: true
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .nonOriginMonitorTarget(try! OrbitalViewVector3(x: 0.1, y: 0, z: 0))
            )
        }
    }

    func testThirtyPhysicalSpeakersPreserveChannelOrder() throws {
        let speakers = try (1...30).map { channel in
            try makeSpeaker(channel: channel)
        }

        let scene = try OrbitalViewSceneBuilder.makeMonitorScene(
            id: "fey-30",
            shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
            speakers: speakers
        )

        XCTAssertEqual(scene.speakers.count, 30)
        XCTAssertEqual(scene.speakers.map(\.channel), Array(1...30))
        XCTAssertEqual(scene.speakers.first?.label, "Fey 01")
        XCTAssertEqual(scene.speakers.last?.label, "Fey 30")
    }

    func testSceneRejectsDuplicatePhysicalChannelsAndIDs() throws {
        let first = try makeSpeaker(channel: 1, id: "speaker-1")
        let duplicateChannel = try makeSpeaker(channel: 1, id: "speaker-2")

        XCTAssertThrowsError(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "duplicate-channel",
                shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
                speakers: [first, duplicateChannel]
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .duplicatePhysicalChannel(1))
        }

        let duplicateID = try makeSpeaker(channel: 2, id: "speaker-1")
        XCTAssertThrowsError(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "duplicate-id",
                shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
                speakers: [first, duplicateID]
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .duplicateID("speaker-1"))
        }
    }

    func testSceneRejectsUnknownStructuralSpeakerAnchor() throws {
        let shell = try OrbitalViewSceneBuilder.makeDefaultOctahedronShell()
        let anchoredSpeaker = try OrbitalViewSpeaker(
            id: "speaker-1",
            channel: 1,
            label: "Fey 01",
            anchor: .node(nodeID: "missing-node", offsetM: 0.05),
            shape: .sphere(radiusM: 0.03)
        )

        XCTAssertThrowsError(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "unknown-anchor",
                shell: shell,
                speakers: [anchoredSpeaker]
            )
        ) { error in
            XCTAssertEqual(error as? OrbitalViewValidationError, .unknownNodeID("missing-node"))
        }

        let parametricAnchor = try OrbitalViewSpeaker(
            id: "speaker-2",
            channel: 2,
            label: "Fey 02",
            anchor: .node(nodeID: "top", offsetM: 0.05),
            shape: .sphere(radiusM: 0.03)
        )

        XCTAssertThrowsError(
            try OrbitalViewSceneBuilder.makeMonitorScene(
                id: "parametric-anchor",
                shell: .parametric(try OrbitalViewParametricShell(kind: .geodesic, radiusM: 1)),
                speakers: [parametricAnchor]
            )
        ) { error in
            XCTAssertEqual(
                error as? OrbitalViewValidationError,
                .invalidAnchorReference("node anchor top requires imported shell geometry")
            )
        }
    }

    private func makeSpeaker(channel: Int, id: String? = nil) throws -> OrbitalViewSpeaker {
        let angle = (Double(channel - 1) / 30.0) * (Double.pi * 2.0)
        let direction = try UnitSphereDirection.normalized(
            x: cos(angle),
            y: 0.2,
            z: sin(angle)
        )

        return try OrbitalViewSpeaker(
            id: id ?? "speaker-\(channel)",
            channel: channel,
            label: String(format: "Fey %02d", channel),
            anchor: .direction(direction, offsetM: 0.05),
            shape: try SpeakerShape.sonicSphereDefault()
        )
    }
}
