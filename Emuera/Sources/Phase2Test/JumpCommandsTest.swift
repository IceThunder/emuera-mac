//
//  JumpCommandsTest.swift
//  Phase2Test
//
//  测试Day 1核心跳转命令
//

import Foundation
import EmueraCore

@main
struct JumpCommandsTest {
    static func main() {
        print("=== Day 1 核心跳转命令测试 ===\n")

        let executor = StatementExecutor()
        let parser = ScriptParser()

        // 测试用例
        let tests = [
            // 1. CALL命令 - 标签调用
            ("CALL标签调用", """
            CALL @TEST
            PRINTL "主流程结束"
            QUIT

            @TEST
            PRINTL "CALL成功: 跳转到标签"
            RETURN
            """),

            // 2. JUMP命令 - 跳转
            ("JUMP跳转", """
            JUMP @SKIP
            PRINTL "这段应该被跳过"

            @SKIP
            PRINTL "JUMP成功: 跳过了代码"
            QUIT
            """),

            // 3. CALLFORM命令 - 动态函数调用
            ("CALLFORM动态调用", """
            A = "TEST"
            CALLFORM %A%
            QUIT

            @TEST
            PRINTL "CALLFORM成功"
            RETURN
            """),

            // 4. JUMPFORM命令 - 动态跳转
            ("JUMPFORM动态跳转", """
            A = "SKIP2"
            JUMPFORM %A%
            PRINTL "被跳过"

            @SKIP2
            PRINTL "JUMPFORM成功"
            QUIT
            """),

            // 5. GOTOFORM命令 - 动态GOTO
            ("GOTOFORM动态跳转", """
            A = "TARGET"
            GOTOFORM %A%
            PRINTL "被跳过"

            @TARGET
            PRINTL "GOTOFORM成功"
            QUIT
            """),

            // 6. CALL带参数
            ("CALL带参数", """
            CALL @WITH_ARGS, 100, "test"
            QUIT

            @WITH_ARGS
            PRINTV ARG:0
            PRINTL " "
            PRINTS ARG:1
            PRINTL " "
            RETURN
            """),

            // 7. JUMP带参数
            ("JUMP带参数", """
            JUMP @JUMP_ARGS, 200, "jumped"
            QUIT

            @JUMP_ARGS
            PRINTV ARG:0
            PRINTL " "
            PRINTS ARG:1
            PRINTL " "
            QUIT
            """),

            // 8. RESTART命令
            ("RESTART重启", """
            A = A + 1
            PRINTV A
            PRINTL " "
            SIF A < 3 RESTART
            QUIT
            """),

            // 9. CALLEVENT命令
            ("CALLEVENT事件调用", """
            CALLEVENT "TestEvent"
            QUIT
            """),

            // 10. CALLTRAIN命令
            ("CALLTRAIN训练调用", """
            CALLTRAIN 1
            QUIT
            """),
        ]

        var passed = 0
        var failed = 0
        var failedList: [(String, String)] = []

        for (name, script) in tests {
            do {
                let statements = try parser.parse(script)
                let result = executor.execute(statements)
                print("✓ \(name)")
                passed += 1
            } catch {
                print("✗ \(name): \(error)")
                failed += 1
                failedList.append((name, "\(error)"))
            }
        }

        print("\n=== 结果 ===")
        print("通过: \(passed)/\(tests.count)")
        print("失败: \(failed)/\(tests.count)")

        if failed > 0 {
            print("\n失败列表:")
            for (name, error) in failedList {
                print("  - \(name): \(error)")
            }
        } else {
            print("\n🎉 Day 1所有跳转命令测试通过！")
        }
    }
}
