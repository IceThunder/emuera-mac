//
//  FlowControlTest.swift
//  Phase2Test
//
//  Day 2 流程控制命令测试
//

import Foundation
import EmueraCore

@main
struct FlowControlTest {
    static func main() {
        print("=== Day 2 流程控制命令测试 ===\n")

        let executor = StatementExecutor()
        let parser = ScriptParser()

        // 测试用例
        let tests: [(String, String)] = [
            // 1. IF/ELSE/ENDIF - 基本条件分支
            ("IF基本条件", """
            A = 10
            IF A > 5
                PRINTL "A大于5"
            ELSE
                PRINTL "A小于等于5"
            ENDIF
            QUIT
            """),

            // 2. IF/ELSEIF/ENDIF - 多条件分支
            ("IF多条件", """
            A = 5
            IF A > 10
                PRINTL "大于10"
            ELSEIF A > 0
                PRINTL "大于0但小于等于10"
            ELSE
                PRINTL "小于等于0"
            ENDIF
            QUIT
            """),

            // 3. WHILE/ENDWHILE - 基本循环
            ("WHILE循环", """
            A = 0
            WHILE A < 3
                A = A + 1
                PRINTV A
                PRINTL " "
            ENDWHILE
            QUIT
            """),

            // 4. FOR/NEXT - 计数循环
            ("FOR循环", """
            FOR I, 1, 5
                PRINTV I
                PRINTL " "
            NEXT
            QUIT
            """),

            // 5. FOR/NEXT - 带步长
            ("FOR带步长", """
            FOR I, 0, 10, 2
                PRINTV I
                PRINTL " "
            NEXT
            QUIT
            """),

            // 6. DO/LOOP WHILE - 先执行后判断
            ("DO LOOP WHILE", """
            A = 0
            DO
                A = A + 1
                PRINTV A
                PRINTL " "
            LOOP WHILE A < 3
            QUIT
            """),

            // 7. DO/LOOP UNTIL - 先执行后判断(反向)
            ("DO LOOP UNTIL", """
            A = 0
            DO
                A = A + 1
                PRINTV A
                PRINTL " "
            LOOP UNTIL A >= 3
            QUIT
            """),

            // 8. REPEAT/REND - 重复执行
            ("REPEAT循环", """
            REPEAT 5
                PRINTL "重复"
            REND
            QUIT
            """),

            // 9. REPEAT/REND - 带计数器
            ("REPEAT带计数", """
            REPEAT 3
                PRINTV COUNT
                PRINTL " "
            REND
            QUIT
            """),

            // 10. SELECTCASE/ENDSELECT - 基本选择
            ("SELECTCASE基本", """
            A = 2
            SELECTCASE A
                CASE 1
                    PRINTL "一"
                CASE 2
                    PRINTL "二"
                CASE 3
                    PRINTL "三"
                CASEELSE
                    PRINTL "其他"
            ENDSELECT
            QUIT
            """),

            // 11. SELECTCASE - 多值匹配
            ("SELECTCASE多值", """
            A = 5
            SELECTCASE A
                CASE 1, 3, 5
                    PRINTL "奇数"
                CASE 2, 4, 6
                    PRINTL "偶数"
                CASEELSE
                    PRINTL "其他"
            ENDSELECT
            QUIT
            """),

            // 12. BREAK - 跳出循环
            ("BREAK跳出", """
            A = 0
            WHILE A < 10
                A = A + 1
                IF A == 3
                    BREAK
                ENDIF
                PRINTV A
                PRINTL " "
            ENDWHILE
            PRINTL "完成"
            QUIT
            """),

            // 13. CONTINUE - 跳过本次
            ("CONTINUE跳过", """
            A = 0
            WHILE A < 5
                A = A + 1
                IF A == 3
                    CONTINUE
                ENDIF
                PRINTV A
                PRINTL " "
            ENDWHILE
            QUIT
            """),

            // 14. 嵌套IF
            ("嵌套IF", """
            A = 10
            B = 5
            IF A > 5
                IF B > 3
                    PRINTL "A>5且B>3"
                ELSE
                    PRINTL "A>5但B<=3"
                ENDIF
            ENDIF
            QUIT
            """),

            // 15. 嵌套循环
            ("嵌套循环", """
            FOR I, 1, 3
                FOR J, 1, 2
                    PRINTV I
                    PRINTS ":"
                    PRINTV J
                    PRINTL " "
                NEXT
            NEXT
            QUIT
            """),

            // 16. WHILE嵌套FOR
            ("WHILE嵌套FOR", """
            A = 0
            WHILE A < 2
                A = A + 1
                FOR I, 1, 3
                    PRINTV A
                    PRINTS ":"
                    PRINTV I
                    PRINTL " "
                NEXT
            ENDWHILE
            QUIT
            """),

            // 17. IF在循环中
            ("循环内IF", """
            FOR I, 1, 5
                IF I % 2 == 0
                    PRINTV I
                    PRINTL " 是偶数"
                ELSE
                    PRINTV I
                    PRINTL " 是奇数"
                ENDIF
            NEXT
            QUIT
            """),

            // 18. 复杂条件表达式
            ("复杂条件", """
            A = 10
            B = 20
            C = 5
            IF A > 5 && B < 30 || C == 5
                PRINTL "条件成立"
            ELSE
                PRINTL "条件不成立"
            ENDIF
            QUIT
            """),

            // 19. 循环中的BREAK和CONTINUE组合
            ("BREAK+CONTINUE", """
            FOR I, 1, 10
                IF I == 3
                    CONTINUE
                ENDIF
                IF I == 8
                    BREAK
                ENDIF
                PRINTV I
                PRINTL " "
            NEXT
            QUIT
            """),

            // 20. 空循环体
            ("空循环体", """
            A = 0
            WHILE A < 3
                A = A + 1
            ENDWHILE
            PRINTL "完成"
            QUIT
            """),
        ]

        var passed = 0
        var failed = 0
        var failedList: [(String, String)] = []

        for (name, script) in tests {
            do {
                let statements = try parser.parse(script)
                let _ = executor.execute(statements)
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
            print("\n🎉 Day 2所有流程控制命令测试通过！")
        }
    }
}
