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

        // Debug Hex Literal Target
        .executableTarget(
            name: "DebugHex",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugHex.swift"]
        ),

        // Debug Hex Conversion Target
        .executableTarget(
            name: "DebugHexConv",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugHexConv.swift"]
        ),

        // Debug BARSTRING Target
        .executableTarget(
            name: "DebugBARSTRING",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugBARSTRING.swift"]
        ),

        // Debug Constants Target
        .executableTarget(
            name: "DebugConstants",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugConstants.swift"]
        ),

        // Debug Constants Execution Target
        .executableTarget(
            name: "DebugConstantsExec",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugConstantsExec.swift"]
        ),

        // Debug Constants Execution Target 2
        .executableTarget(
            name: "DebugConstantsExec2",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugConstantsExec2.swift"]
        ),

        // Phase 2 Function System Test Target
        .executableTarget(
            name: "Phase2Test",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            exclude: ["FunctionSystemTest.swift", "MinimalTest.swift", "main.swift"],
            sources: ["ParseTest.swift"]
        ),

        // Phase 2 Built-in Functions Test Target
        .executableTarget(
            name: "FunctionTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["FunctionTest.swift"]
        ),

        // Debug ISNULL Target
        .executableTarget(
            name: "DebugISNULL",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugISNULL.swift"]
        ),

        // Debug ESCAPE Target
        .executableTarget(
            name: "DebugESCAPE",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugESCAPE.swift"]
        ),

        // Debug ESCAPE 2 Target
        .executableTarget(
            name: "DebugESCAPE2",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugESCAPE2.swift"]
        ),

        // Debug ESCAPE 3 Target
        .executableTarget(
            name: "DebugESCAPE3",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugESCAPE3.swift"]
        ),

        // Debug Array Target
        .executableTarget(
            name: "DebugArray",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugArray.swift"]
        ),

        // Debug Constants Exec 3 Target
        .executableTarget(
            name: "DebugConstantsExec3",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugConstantsExec3.swift"]
        ),

        // Debug Array 2 Target
        .executableTarget(
            name: "DebugArray2",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugArray2.swift"]
        ),

        // Debug REPEAT Target
        .executableTarget(
            name: "DebugRepeat",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugRepeat.swift"]
        ),

        // Debug ARRAYMULTISORT Target
        .executableTarget(
            name: "DebugArraySort",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugArraySort.swift"]
        ),

        // Debug Print Tokens Target
        .executableTarget(
            name: "DebugPrintTokens",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugPrintTokens.swift"]
        ),

        // Debug SELECTCASE Target
        .executableTarget(
            name: "DebugSelectCase",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugSelectCase.swift", "RunSelectCaseTests.swift"]
        ),

        // Debug BitAnd Target
        .executableTarget(
            name: "DebugBitAnd",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugBitAnd.swift"]
        ),

        // Debug Parse Target
        .executableTarget(
            name: "DebugParse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugParse.swift"]
        ),

        // Simple debug target
        .executableTarget(
            name: "DebugSimpleSelect",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugSimpleSelect.swift"]
        ),

        // Debug Test 25 Target
        .executableTarget(
            name: "DebugTest25",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugTest25.swift"]
        ),

        // Debug Test 34-35 Target
        .executableTarget(
            name: "DebugTest34_35",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugTest34_35.swift"]
        ),

        // Debug PERSIST Target
        .executableTarget(
            name: "DebugPersist",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugPersist.swift"]
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