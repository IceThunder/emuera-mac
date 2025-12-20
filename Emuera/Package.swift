// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Emuera",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "emuera",
            targets: ["EmueraApp"]
        ),
        .library(
            name: "EmueraCore",
            targets: ["EmueraCore"]
        )
    ],
    dependencies: [],
    targets: [
        // Core Engine - 脚本解析和执行引擎
        .target(
            name: "EmueraCore",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
            ]
        ),

        // macOS Application - UI和系统服务
        .executableTarget(
            name: "EmueraApp",
            dependencies: ["EmueraCore"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
            ]
            // Foundation and AppKit are automatically linked on macOS
        ),

        // GUI Application
        .executableTarget(
            name: "EmueraGUI",
            dependencies: ["EmueraCore"],
            path: "Sources/EmueraGUI",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
            ]
        ),

        // Quick Test Target
        .executableTarget(
            name: "QuickTest",
            dependencies: ["EmueraCore"],
            path: "Sources/QuickTest"
        ),

        // Debug Test Target
        .executableTarget(
            name: "DebugTestTarget",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            exclude: ["DebugTest.swift", "TraceTest.swift", "DebugBreak.swift", "DebugLexical.swift"],
            sources: ["DebugParser.swift"]
        ),

        // Print Test Target
        .executableTarget(
            name: "TestPrint",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["TestPrint.swift"]
        ),

        // Simple Test Target
        .executableTarget(
            name: "SimpleTest",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["SimpleTest.swift"]
        ),

        // English Text Test Target
        .executableTarget(
            name: "EnglishTest",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["EnglishTest.swift"]
        ),

        // Mini Test Target
        .executableTarget(
            name: "MiniTest",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["MiniTest.swift"]
        ),

        // FOR Loop Test Target
        .executableTarget(
            name: "ForLoopTest",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["ForLoopTest.swift"]
        ),

        // Debug FOR Loop Target
        .executableTarget(
            name: "DebugForLoop",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["DebugForLoop.swift"]
        ),

        // Print Test Target
        .executableTarget(
            name: "PrintTest",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["PrintTest.swift"]
        ),

        // Debug Collect Target
        .executableTarget(
            name: "DebugCollect",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["DebugCollect.swift"]
        ),

        // Debug Lexical Target
        .executableTarget(
            name: "DebugLexical",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["DebugLexical.swift"]
        ),

        // Debug All Tokens Target
        .executableTarget(
            name: "DebugAllTokens",
            dependencies: ["EmueraCore"],
            path: "Sources/DebugTest",
            sources: ["DebugAllTokens.swift"]
        ),

        // Unit Tests
        .testTarget(
            name: "EmueraCoreTests",
            dependencies: ["EmueraCore"]
        ),

        .testTarget(
            name: "EmueraAppTests",
            dependencies: ["EmueraApp"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)