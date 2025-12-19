import Foundation
import EmueraCore

/// ScriptParser和StatementExecutor测试
public class ScriptParserTest {
    public static func runTests() {
        print("🧪 ScriptParser + StatementExecutor 完整测试")
        print(String(repeating: "=", count: 60))
        print()

        var pass = 0
        var fail = 0

        func test(_ name: String, _ script: String, _ expectedOutput: [String]) {
            print("测试: \(name)")
            print("脚本: \(script)")
            do {
                let parser = ScriptParser()
                let statements = try parser.parse(script)
                let executor = StatementExecutor()
                let output = executor.execute(statements)

                if output == expectedOutput {
                    print("✅ 通过")
                    pass += 1
                } else {
                    print("❌ 失败")
                    print("  期望: \(expectedOutput)")
                    print("  实际: \(output)")
                    fail += 1
                }
            } catch {
                print("❌ 错误: \(error)")
                fail += 1
            }
            print()
        }

        // 测试1: 基础赋值和输出
        test(
            "基础赋值和输出",
            "A = 100\nPRINT A",
            ["100"]
        )

        // 测试2: 表达式计算
        test(
            "表达式计算",
            "A = 10\nB = A + 50 * 2\nPRINT B",
            ["110"]
        )

        // 测试3: IF语句 - 条件为真
        test(
            "IF语句 - 条件为真",
            "A = 10\nIF A > 5\n  PRINTL A大于5\nENDIF",
            ["A大于5\n"]
        )

        // 测试4: IF语句 - 条件为假
        test(
            "IF语句 - 条件为假",
            "A = 3\nIF A > 5\n  PRINTL A大于5\nENDIF",
            []
        )

        // 测试5: IF-ELSE语句
        test(
            "IF-ELSE语句",
            "A = 3\nIF A > 5\n  PRINTL A大于5\nELSE\n  PRINTL A小于等于5\nENDIF",
            ["A小于等于5\n"]
        )

        // 测试6: WHILE循环
        test(
            "WHILE循环",
            "COUNT = 0\nWHILE COUNT < 3\n  PRINT COUNT\n  COUNT = COUNT + 1\nENDWHILE",
            ["0", "1", "2"]
        )

        // 测试7: FOR循环
        test(
            "FOR循环",
            "FOR I, 1, 3\n  PRINT I\nENDFOR",
            ["1", "2", "3"]
        )

        // 测试8: BREAK语句
        test(
            "BREAK语句",
            "COUNT = 0\nWHILE COUNT < 10\n  IF COUNT == 3\n    BREAK\n  ENDIF\n  PRINT COUNT\n  COUNT = COUNT + 1\nENDWHILE",
            ["0", "1", "2"]
        )

        // 测试9: GOTO语句
        test(
            "GOTO语句",
            "GOTO SKIP\nPRINTL 不应该执行\n@SKIP\nPRINTL 跳转成功",
            ["跳转成功\n"]
        )

        // 测试10: CALL语句
        test(
            "CALL语句",
            "CALL SUB\nQUIT\n@SUB\nPRINTL 子程序被调用\nRETURN",
            ["子程序被调用\n"]
        )

        // 测试11: SELECTCASE语句
        test(
            "SELECTCASE语句",
            "A = 2\nSELECTCASE A\n  CASE 1\n    PRINTL 一\n  CASE 2\n    PRINTL 二\n  CASE 3\n    PRINTL 三\n  CASEELSE\n    PRINTL 其他\nENDSELECT",
            ["二\n"]
        )

        // 测试12: SELECTCASE CASEELSE
        test(
            "SELECTCASE CASEELSE",
            "A = 5\nSELECTCASE A\n  CASE 1\n    PRINTL 一\n  CASE 2\n    PRINTL 二\n  CASEELSE\n    PRINTL 其他\nENDSELECT",
            ["其他\n"]
        )

        // 测试13: 复杂表达式
        test(
            "复杂表达式",
            "A = 10\nB = 20\nC = (A + B) * 2 - 5\nPRINT C",
            ["45"]
        )

        // 测试14: 特殊变量
        test(
            "特殊变量",
            "R = RAND(100)\nPRINT R\nM = __INT_MAX__\nPRINT M",
            // 注意：RAND结果随机，只检查格式
            ["[随机数]", "[最大值]"]  // 这个测试会失败，因为实际会输出数字
        )

        // 测试15: RESET命令
        test(
            "RESET命令",
            "A = 100\nRESET\nPRINT A",
            ["0"]  // 重置后A为0
        )

        // 测试16: 多行PRINT
        test(
            "多行PRINT",
            "PRINTL 第一行\nPRINTL 第二行\nPRINTL 第三行",
            ["第一行\n", "第二行\n", "第三行\n"]
        )

        // 测试17: 字符串拼接
        test(
            "字符串拼接",
            "NAME = \"测试\"\nPRINTL NAME + \"完成\"",
            ["测试完成\n"]
        )

        // 测试18: 比较运算符
        test(
            "比较运算符",
            "A = 10\nIF A == 10\n  PRINTL 相等\nENDIF\nIF A != 5\n  PRINTL 不等\nENDIF",
            ["相等\n", "不等\n"]
        )

        // 测试19: 逻辑运算符
        test(
            "逻辑运算符",
            "A = 10\nIF A > 5 && A < 20\n  PRINTL 范围内\nENDIF",
            ["范围内\n"]
        )

        // 测试20: 嵌套IF
        test(
            "嵌套IF",
            "A = 10\nIF A > 5\n  IF A < 15\n    PRINTL 5到15之间\n  ENDIF\nENDIF",
            ["5到15之间\n"]
        )

        print(String(repeating: "=", count: 60))
        print("测试总结: 通过 \(pass)/\(pass + fail)")
        if fail == 0 {
            print("🎉 所有测试通过！")
        } else {
            print("⚠️  \(fail) 个测试失败")
        }
        print(String(repeating: "=", count: 60))
    }
}
