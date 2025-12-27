//
//  FixVerificationTest.swift
//  Phase2Test
//
//  验证解析器限制修复
//

import Foundation
import EmueraCore

@main
struct FixVerificationTest {
    static func main() {
        print("=== 解析器限制修复验证 ===\n")

        let executor = StatementExecutor()
        let parser = ScriptParser()

        // 测试修复的命令
        let fixTests = [
            // 1. SET命令修复
            ("SET A = 10", """
            SET A = 10
            PRINTV A
            QUIT
            """),

            // 2. FOR循环支持NEXT
            ("FOR with NEXT", """
            A = 0
            FOR A, 0, 3
                A = A + 1
            NEXT
            PRINTV A
            QUIT
            """),

            // 3. REPEAT循环支持REND
            ("REPEAT with REND", """
            A = 0
            REPEAT 3
                A = A + 1
            REND
            PRINTV A
            QUIT
            """),

            // 4. DO-LOOP WHILE修复
            ("DO-LOOP WHILE", """
            A = 0
            DO
                A = A + 1
            LOOP WHILE A < 3
            PRINTV A
            QUIT
            """),

            // 5. DO-LOOP UNTIL修复
            ("DO-LOOP UNTIL", """
            A = 0
            DO
                A = A + 1
            LOOP UNTIL A >= 3
            PRINTV A
            QUIT
            """),

            // 6. TINPUT多参数支持
            ("TINPUT 4 params", """
            TINPUT 1000, 0, "超时", 1
            QUIT
            """),

            // 7. TINPUTS多参数支持
            ("TINPUTS 4 params", """
            TINPUTS 1000, "default", "超时", 1
            QUIT
            """),

            // 8. TONEINPUT多参数支持
            ("TONEINPUT 3 params", """
            TONEINPUT 1000, 0, 1
            QUIT
            """),

            // 9. TONEINPUTS多参数支持
            ("TONEINPUTS 3 params", """
            TONEINPUTS 1000, "A", 1
            QUIT
            """),

            // 10. SETCOLOR 3参数
            ("SETCOLOR RGB", """
            SETCOLOR 255, 128, 64
            QUIT
            """),

            // 11. SETBGCOLOR 3参数
            ("SETBGCOLOR RGB", """
            SETBGCOLOR 0, 128, 255
            QUIT
            """),
        ]

        var passed = 0
        var failed = 0
        var failedList: [(String, String)] = []

        for (name, script) in fixTests {
            do {
                let statements = try parser.parse(script)
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
        print("通过: \(passed)/\(fixTests.count)")
        print("失败: \(failed)/\(fixTests.count)")

        if failed > 0 {
            print("\n失败列表:")
            for (name, error) in failedList {
                print("  - \(name): \(error)")
            }
        } else {
            print("\n🎉 所有修复验证通过！")
        }
    }
}
