import Foundation
import OrbitalViewReview

#if os(macOS)
struct BenchmarkCLI {
    var modes: [OrbitalViewportHeadlessBenchmarkMode] = [.idle, .active]
    var warmupFrames = 60
    var measuredFrames = 300
    var width = 1360
    var height = 820
    var targetFramesPerSecond = 120
    var showRibbedSpeakerSphere = false
    var ribbedSphereVerticalRibs = 16
    var ribbedSphereHorizontalRings = 8
    var showHiddenLines = false
    var fogDensity: Double = 20
    var themePaths: [String] = []

    init(arguments: [String]) throws {
        var index = 1
        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--theme":
                index += 1
                guard index < arguments.count else {
                    throw CLIError.missingValue(argument)
                }
                themePaths.append(arguments[index])
            case "--mode":
                index += 1
                guard index < arguments.count else {
                    throw CLIError.missingValue(argument)
                }
                modes = try Self.parseModes(arguments[index])
            case "--warmup":
                index += 1
                warmupFrames = try Self.parseInt(arguments, index: index, option: argument)
            case "--frames":
                index += 1
                measuredFrames = try Self.parseInt(arguments, index: index, option: argument)
            case "--width":
                index += 1
                width = try Self.parseInt(arguments, index: index, option: argument)
            case "--height":
                index += 1
                height = try Self.parseInt(arguments, index: index, option: argument)
            case "--target":
                index += 1
                targetFramesPerSecond = try Self.parseInt(arguments, index: index, option: argument)
            case "--ribbed":
                showRibbedSpeakerSphere = true
            case "--vertical-ribs":
                index += 1
                ribbedSphereVerticalRibs = try Self.parseInt(arguments, index: index, option: argument)
            case "--horizontal-rings":
                index += 1
                ribbedSphereHorizontalRings = try Self.parseInt(arguments, index: index, option: argument)
            case "--show-hidden-lines":
                showHiddenLines = true
            case "--fog-density":
                index += 1
                fogDensity = try Self.parseDouble(arguments, index: index, option: argument)
            case "--help", "-h":
                throw CLIError.helpRequested
            default:
                throw CLIError.unknownOption(argument)
            }
            index += 1
        }
    }

    func run() throws {
        if !themePaths.isEmpty {
            try runThemeProfiles()
            return
        }
        print("OrbitalViewHeadlessBenchmark")
        print(
            "size=\(width)x\(height) warmup=\(warmupFrames) frames=\(measuredFrames) target=\(targetFramesPerSecond) " +
                "ribbed=\(showRibbedSpeakerSphere ? "on" : "off") verticalRibs=\(ribbedSphereVerticalRibs) " +
                "horizontalRings=\(ribbedSphereHorizontalRings) hiddenLines=\(showHiddenLines ? "on" : "off") " +
                "fogDensity=\(fogDensity)"
        )
        for mode in modes {
            let options = OrbitalViewportHeadlessBenchmarkOptions(
                mode: mode,
                warmupFrames: warmupFrames,
                measuredFrames: measuredFrames,
                width: width,
                height: height,
                targetFramesPerSecond: targetFramesPerSecond,
                showRibbedSpeakerSphere: showRibbedSpeakerSphere,
                ribbedSphereVerticalRibs: ribbedSphereVerticalRibs,
                ribbedSphereHorizontalRings: ribbedSphereHorizontalRings,
                showHiddenLines: showHiddenLines,
                fogDensity: fogDensity
            )
            let result = try OrbitalViewportHeadlessBenchmark.run(options: options)
            print(result.summaryLine)
        }
    }

    func runThemeProfiles() throws {
        print("OrbitalViewHeadlessBenchmark theme profile")
        print("size=\(width)x\(height) warmup=\(warmupFrames) frames=\(measuredFrames) spin=on impulse=on")
        for path in themePaths {
            let options = OrbitalViewportThemeProfileOptions(
                themePath: path,
                warmupFrames: warmupFrames,
                measuredFrames: measuredFrames,
                width: width,
                height: height,
                forceSpin: true,
                forceImpulse: true
            )
            let result = try OrbitalViewportThemeProfile.run(options: options)
            for line in result.summaryLines {
                print(line)
            }
        }
    }

    static func usage() -> String {
        """
        Usage: OrbitalViewHeadlessBenchmark [--mode idle|active|both] [--warmup N] [--frames N] [--width N] [--height N] [--target N] [--ribbed] [--vertical-ribs N] [--horizontal-rings N] [--show-hidden-lines] [--fog-density N]
               OrbitalViewHeadlessBenchmark --theme <path-to-theme.json> [--theme <path2.json> ...] [--warmup N] [--frames N] [--width N] [--height N]

        Defaults: --mode both --warmup 60 --frames 300 --width 1360 --height 820 --target 120 --vertical-ribs 16 --horizontal-rings 8 --fog-density 20
        Theme mode drives the saved theme with spin + impulse meters and reports per-aspect render work.
        """
    }

    private static func parseModes(_ value: String) throws -> [OrbitalViewportHeadlessBenchmarkMode] {
        switch value {
        case "both":
            return [.idle, .active]
        case "idle":
            return [.idle]
        case "active":
            return [.active]
        default:
            throw CLIError.invalidValue("--mode", value)
        }
    }

    private static func parseInt(_ arguments: [String], index: Int, option: String) throws -> Int {
        guard index < arguments.count else {
            throw CLIError.missingValue(option)
        }
        guard let value = Int(arguments[index]) else {
            throw CLIError.invalidValue(option, arguments[index])
        }
        return value
    }

    private static func parseDouble(_ arguments: [String], index: Int, option: String) throws -> Double {
        guard index < arguments.count else {
            throw CLIError.missingValue(option)
        }
        guard let value = Double(arguments[index]) else {
            throw CLIError.invalidValue(option, arguments[index])
        }
        return value
    }
}

enum CLIError: LocalizedError {
    case helpRequested
    case missingValue(String)
    case invalidValue(String, String)
    case unknownOption(String)

    var errorDescription: String? {
        switch self {
        case .helpRequested:
            return BenchmarkCLI.usage()
        case let .missingValue(option):
            return "Missing value for \(option).\n\(BenchmarkCLI.usage())"
        case let .invalidValue(option, value):
            return "Invalid value for \(option): \(value).\n\(BenchmarkCLI.usage())"
        case let .unknownOption(option):
            return "Unknown option: \(option).\n\(BenchmarkCLI.usage())"
        }
    }
}

do {
    try BenchmarkCLI(arguments: CommandLine.arguments).run()
} catch CLIError.helpRequested {
    print(BenchmarkCLI.usage())
} catch {
    fputs("\(error.localizedDescription)\n", stderr)
    exit(2)
}
#else
print("OrbitalViewHeadlessBenchmark is only available on macOS.")
#endif
