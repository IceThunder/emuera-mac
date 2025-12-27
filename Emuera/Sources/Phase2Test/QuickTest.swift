//
//  QuickTest.swift
//  Phase2Test
//
//  快速状态检查
//

import Foundation
import EmueraCore

@main
struct QuickTest {
    static func main() {
        print("=== 快速状态检查 ===\n")

        let executor = StatementExecutor()
        let parser = ScriptParser()

        // 测试关键命令
        let criticalTests = [
            ("TINPUT", "TINPUT 1000, 0, \"超时\""),
            ("TINPUTS", "TINPUTS 1000, \"default\", \"超时\""),
            ("TONEINPUT", "TONEINPUT 1000, 0"),
            ("TONEINPUTS", "TONEINPUTS 1000, \"A\""),
            ("SETCOLOR", "SETCOLOR 255, 255, 255"),
            ("SETBGCOLOR", "SETBGCOLOR 255, 255, 255"),
            ("DO-LOOP WHILE", "DO\n    A = A + 1\nLOOP WHILE A < 5"),
            ("DO-LOOP UNTIL", "DO\n    A = A + 1\nLOOP UNTIL A >= 5"),
            ("SIF", "SIF 1 PRINTL \"Test\""),
            ("WAIT", "WAIT"),
            ("WAITANYKEY", "WAITANYKEY"),
            ("PRINTV", "PRINTV 123"),
            ("PRINTVL", "PRINTVL 123"),
            ("PRINTVW", "PRINTVW 123"),
            ("PRINTS", "PRINTS \"ABC\""),
            ("PRINTSL", "PRINTSL \"ABC\""),
            ("PRINTSW", "PRINTSW \"ABC\""),
            ("PRINTFORMS", "PRINTFORMS \"ABC\""),
            ("PRINTFORMSL", "PRINTFORMSL \"ABC\""),
            ("PRINTFORMSW", "PRINTFORMSW \"ABC\""),
            ("SET", "SET A = 10"),
            ("VARSET", "VARSET A, 0"),
            ("VARSIZE", "VARSIZE A"),
            ("SWAP", "SWAP A, B"),
            ("STRLEN", "STRLEN \"ABC\""),
            ("SPLIT", "SPLIT \"A,B,C\", \",\""),
            ("SAVECHARA", "SAVECHARA 0"),
            ("LOADCHARA", "LOADCHARA 0"),
            ("SAVEGAME", "SAVEGAME 0"),
            ("LOADGAME", "LOADGAME 0"),
            ("CHARACOUNT", "CHARACOUNT"),
            ("CHARAEXISTS", "CHARAEXISTS 0"),
        ]

        var passed = 0
        var failed = 0
        var failedList: [(String, String)] = []

        for (name, script) in criticalTests {
            do {
                let statements = try parser.parse(script + "\nQUIT")
                _ = executor.execute(statements)
                print("✓ \(name)")
                passed += 1
            } catch {
                print("✗ \(name): \(error)")
                failed += 1
                failedList.append((name, "\(error)"))
            }
        }

        print("\n=== 结果 ===")
        print("通过: \(passed)/\(criticalTests.count)")
        print("失败: \(failed)/\(criticalTests.count)")

        if failed > 0 {
            print("\n失败列表:")
            for (name, error) in failedList {
                print("  - \(name): \(error)")
            }
        }
    }
}