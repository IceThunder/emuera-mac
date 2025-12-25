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

        // Try/CATCH Test Target (Phase 3)
        .executableTarget(
            name: "TryCatchTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["TryCatchTest.swift"]
        ),

        // Debug TRY/CATCH Parsing
        .executableTarget(
            name: "DebugTryCatchParse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugTryCatchParse.swift"]
        ),

        // Debug TRYGOTO Parsing
        .executableTarget(
            name: "DebugTryGotoParse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugTryGotoParse.swift"]
        ),

        // Quick Try/Catch Test
        .executableTarget(
            name: "QuickTryCatch",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["QuickTryCatch.swift"]
        ),

        // Parse Only Test
        .executableTarget(
            name: "ParseOnlyTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["ParseOnlyTest.swift"]
        ),

        // Debug Simple Test
        .executableTarget(
            name: "DebugSimple",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugSimple.swift"]
        ),

        // Debug TRYCALL Parsing
        .executableTarget(
            name: "DebugTryCallParse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase2Debug",
            sources: ["DebugTryCallParse.swift"]
        ),

        // SELECTCASE Test Target (Phase 3)
        .executableTarget(
            name: "SelectCaseTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["SelectCaseTest.swift"]
        ),

        // Debug SELECTCASE Parsing
        .executableTarget(
            name: "DebugSelectCaseParse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSelectCaseParse.swift"]
        ),

        // Debug Case Values
        .executableTarget(
            name: "DebugCaseValues",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugCaseValues.swift"]
        ),

        // PRINTDATA Test Target (Phase 3)
        .executableTarget(
            name: "PrintDataTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["PrintDataTest.swift"]
        ),

        // Debug PRINTDATA Simple
        .executableTarget(
            name: "DebugPrintDataSimple",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugPrintDataSimple.swift"]
        ),

        // Debug PRINTDATA Final
        .executableTarget(
            name: "DebugPrintDataFinal",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugPrintDataFinal.swift"]
        ),

        // Debug PRINTDATA Variables
        .executableTarget(
            name: "DebugPrintDataVariables",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugPrintDataVariables.swift"]
        ),

        // Debug PRINTDATA Tag
        .executableTarget(
            name: "DebugPrintDataTag",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugPrintDataTag.swift"]
        ),

        // Debug isFunctionDefinitionStart
        .executableTarget(
            name: "DebugIsFunction",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugIsFunction.swift"]
        ),

        // DO-LOOP Test Target (Phase 3)
        .executableTarget(
            name: "DoLoopTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DoLoopTest.swift"]
        ),

        // Debug DO-LOOP Simple Target
        .executableTarget(
            name: "DebugDoLoop",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugDoLoop.swift"]
        ),

        // Debug Tokens Target
        .executableTarget(
            name: "DebugTokens",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugTokens.swift"]
        ),

        // Debug Test 6 Target
        .executableTarget(
            name: "DebugTest6",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugTest6.swift"]
        ),

        // Debug Assignment Target
        .executableTarget(
            name: "DebugAssignment",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugAssignment.swift"]
        ),

        // Debug REPEAT Target
        .executableTarget(
            name: "DebugRepeat",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugRepeat.swift"]
        ),

        // Debug Tokens 2 Target
        .executableTarget(
            name: "DebugTokens2",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugTokens2.swift"]
        ),

        // Debug SAVE/LOAD Target (Phase 3 P1)
        .executableTarget(
            name: "DebugSaveLoad",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSaveLoad.swift"]
        ),

        // Debug SAVE/LOAD Parse Target
        .executableTarget(
            name: "DebugSaveLoadParse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSaveLoadParse.swift"]
        ),

        // Debug SAVE/LOAD Token Target
        .executableTarget(
            name: "DebugSaveLoadToken",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSaveLoadToken.swift"]
        ),

        // Debug SAVE/LOAD Detailed Target
        .executableTarget(
            name: "DebugSaveLoadDetailed",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSaveLoadDetailed.swift"]
        ),

        // Debug SAVECHARA/LOADCHARA Target (Phase 3 P2)
        .executableTarget(
            name: "DebugSaveChara",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSaveChara.swift"]
        ),

        // Debug SAVEGAME/LOADGAME Target (Phase 3 P3)
        .executableTarget(
            name: "DebugSaveGame",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSaveGame.swift"]
        ),

        // Debug SAVELIST/SAVEEXISTS Target (Phase 3 P4)
        .executableTarget(
            name: "DebugSaveList",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSaveList.swift"]
        ),

        // Debug AUTOSAVE/SAVEINFO Target (Phase 3 P5)
        .executableTarget(
            name: "DebugSaveInfo",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugSaveInfo.swift"]
        ),

        // Debug Phase 4 Target (数据重置和持久化控制)
        .executableTarget(
            name: "DebugPhase4",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugPhase4.swift"]
        ),

        // Debug Phase 4 Parse Target (解析调试)
        .executableTarget(
            name: "DebugPhase4Parse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase3Debug",
            sources: ["DebugPhase4Parse.swift"]
        ),

        // ERH Test Target (Phase 5)
        .executableTarget(
            name: "ERHTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase5Debug",
            sources: ["ERHTest.swift"]
        ),

        // GUI Enhanced Test Target (Phase 5)
        .executableTarget(
            name: "GUIEnhancedTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase5Debug",
            sources: ["GUIEnhancedTest.swift"]
        ),

        // Theme Test Target (Phase 5)
        .executableTarget(
            name: "ThemeTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase5Debug",
            sources: ["ThemeTest.swift"]
        ),

        // GUI Integration Test Target (Phase 5)
        .executableTarget(
            name: "GUIIntegrationTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase5Debug",
            sources: ["GUIIntegrationTest.swift"]
        ),

        // Character Manager Test Target (Phase 6)
        .executableTarget(
            name: "CharacterManagerTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase6Debug",
            sources: ["CharacterManagerTest.swift"]
        ),

        // Phase 6 Parser Test Target
        .executableTarget(
            name: "Phase6ParserTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase6Debug",
            sources: ["Phase6ParserTest.swift"]
        ),

        // Debug Parser Target
        .executableTarget(
            name: "DebugParser",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase6Debug",
            sources: ["DebugParser.swift"]
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

        // D系列输出命令测试 Target (Priority 1)
        .executableTarget(
            name: "PrintDTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["PrintDTest.swift"]
        ),

        // PRINTFORMD调试 Target
        .executableTarget(
            name: "DebugPrintFormD",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugPrintFormD.swift"]
        ),

        // SIF命令测试 Target (Priority 2)
        .executableTarget(
            name: "SifTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["SifTest.swift"]
        ),

        // TRYC系列异常处理测试 Target (Priority 1)
        .executableTarget(
            name: "TryCTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["TryCTest.swift"]
        ),

        // Debug Parameter Substitution
        .executableTarget(
            name: "DebugParamSub",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugParamSub.swift"]
        ),

        // Test 1 Debug Target
        .executableTarget(
            name: "Test1Debug",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["Test1Debug.swift"]
        ),

        // TRYC解析调试 Target
        .executableTarget(
            name: "DebugTryCParse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugTryCParse.swift"]
        ),

        // TRYC执行调试 Target
        .executableTarget(
            name: "DebugTryCExecute",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugTryCExecute.swift"]
        ),

        // Debug Test 3 Target
        .executableTarget(
            name: "DebugTest3",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugTest3.swift"]
        ),

        // Debug Test 9 Target
        .executableTarget(
            name: "DebugTest9",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugTest9.swift"]
        ),

        // Array Functions Test Target (Priority 1)
        .executableTarget(
            name: "ArrayFunctionsTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["ArrayFunctionsTest.swift"]
        ),

        // Debug Array Functions
        .executableTarget(
            name: "DebugArrayFuncs",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugArrayFuncs.swift"]
        ),

        // Debug Tokenize
        .executableTarget(
            name: "DebugTokenize",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugTokenize.swift"]
        ),

        // Debug Script Parser
        .executableTarget(
            name: "DebugScriptParser",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugScriptParser.swift"]
        ),

        // String Functions Test
        .executableTarget(
            name: "StringFunctionsTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["StringFunctionsTest.swift"]
        ),

        // Debug String Functions
        .executableTarget(
            name: "DebugStringFuncs",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugStringFuncs.swift"]
        ),

        // Priority 2 Test Target
        .executableTarget(
            name: "Priority2Test",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["Priority2Test.swift"]
        ),

        // Priority 3 Test Target
        .executableTarget(
            name: "Priority3Test",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["Priority3Test.swift"]
        ),

        // Priority 4 Graphics Test Target
        .executableTarget(
            name: "GraphicsTest",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["GraphicsTest.swift"]
        ),

        // Debug Priority 2 Parse Target
        .executableTarget(
            name: "DebugPriority2Parse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugPriority2Parse.swift"]
        ),

        // Debug Parse Step Target
        .executableTarget(
            name: "DebugParseStep",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugParseStep.swift"]
        ),

        // Debug Parse Detail Target
        .executableTarget(
            name: "DebugParseDetail",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugParseDetail.swift"]
        ),

        // Debug Collect Target
        .executableTarget(
            name: "DebugCollect",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugCollect.swift"]
        ),

        // Debug Collect 2 Target
        .executableTarget(
            name: "DebugCollect2",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugCollect2.swift"]
        ),

        // Debug Collect 3 Target
        .executableTarget(
            name: "DebugCollect3",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugCollect3.swift"]
        ),

        // Debug Collect 4 Target
        .executableTarget(
            name: "DebugCollect4",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugCollect4.swift"]
        ),

        // Debug Real Parser Target
        .executableTarget(
            name: "DebugRealParser",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugRealParser.swift"]
        ),

        // Debug Graphics Parse Target
        .executableTarget(
            name: "DebugGraphicsParse",
            dependencies: ["EmueraCore"],
            path: "Sources/Phase7Debug",
            sources: ["DebugGraphicsParse.swift"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)