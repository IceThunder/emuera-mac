import Foundation
import EmueraCore

/// 快速测试ScriptParser和StatementExecutor
@main
struct QuickTest {
    static func main() {
        print("🧪 Emuera 快速综合测试")
        print(String(repeating: "=", count: 60))

        var pass = 0
        var fail = 0

        func test(_ name: String, _ script: String, _ expected: [String]) {
            print("\n测试: \(name)")
            do {
                let parser = ScriptParser()
                let statements = try parser.parse(script)
                let executor = StatementExecutor()
                let output = executor.execute(statements)

                if output == expected {
                    print("✅ 通过")
                    pass += 1
                } else {
                    print("❌ 失败")
                    print("   期望: \(expected)")
                    print("   实际: \(output)")
                    fail += 1
                }
            } catch {
                print("❌ 错误: \(error)")
                fail += 1
            }
        }

        // 基础测试
        test("基础赋值和输出", "A = 100\nPRINT A", ["100"])
        test("表达式计算", "A = 10\nB = A + 50 * 2\nPRINT B", ["110"])
        test("IF条件为真", "A = 10\nIF A > 5\n  PRINTL A大于5\nENDIF", ["A大于5\n"])
        test("IF条件为假", "A = 3\nIF A > 5\n  PRINTL A大于5\nENDIF", [])
        test("IF-ELSE", "A = 3\nIF A > 5\n  PRINTL A大于5\nELSE\n  PRINTL A小于等于5\nENDIF", ["A小于等于5\n"])

        // 循环测试
        test("WHILE循环", "COUNT = 0\nWHILE COUNT < 3\n  PRINT COUNT\n  COUNT = COUNT + 1\nENDWHILE", ["0", "1", "2"])
        test("FOR循环", "FOR I, 1, 3\n  PRINT I\nENDFOR", ["1", "2", "3"])

        // 跳转测试
        test("GOTO跳转", "A = 10\nGOTO SKIP\nA = 20\nSKIP:\nPRINT A", ["10"])
        test("CALL子程序", "A = 100\nPRINT A\nCALL SUB\nPRINT A\n\nSUB:\n  A = A + 50\n  RETURN", ["100", "150"])

        // 高级控制流
        test("BREAK", "FOR I, 1, 10\n  IF I == 5\n    BREAK\n  ENDIF\n  PRINT I\nENDFOR", ["1", "2", "3", "4"])
        test("CONTINUE", "FOR I, 1, 5\n  IF I == 3\n    CONTINUE\n  ENDIF\n  PRINT I\nENDFOR", ["1", "2", "4", "5"])

        // SELECTCASE
        test("SELECTCASE", "A = 2\nSELECTCASE A\n  CASE 1\n    PRINTL 一\n  CASE 2\n    PRINTL 二\n  CASE 3\n    PRINTL 三\n  CASEELSE\n    PRINTL 其他\nENDSELECT", ["二\n"])

        // 复杂表达式
        test("复杂表达式", "A = 10\nB = 20\nC = (A + B) * 2 - 5\nPRINT C", ["55"])
        test("比较运算符", "A = 10\nIF A == 10\n  PRINTL 相等\nENDIF\nIF A != 5\n  PRINTL 不等\nENDIF", ["相等\n", "不等\n"])
        test("逻辑运算符", "A = 10\nIF A > 5 && A < 20\n  PRINTL 范围内\nENDIF", ["范围内\n"])

        // 嵌套测试
        test("嵌套IF", "A = 10\nIF A > 5\n  IF A < 15\n    PRINTL 5到15之间\n  ENDIF\nENDIF", ["5到15之间\n"])
        test("复杂嵌套", "A = 0\nWHILE A < 2\n  A = A + 1\n  FOR I, 1, 2\n    PRINT A\n    PRINT I\n  ENDFOR\nENDWHILE", ["1", "1", "1", "2", "2", "1", "2", "2"])

        // 标签和GOTO
        test("标签和GOTO", "GOTO START\nPRINTL 跳过\nSTART:\nPRINTL 开始\nGOTO END\nPRINTL 也跳过\nEND:\nPRINTL 结束", ["开始\n", "结束\n"])

        // RESET命令
        test("RESET命令", "A = 100\nRESET\nPRINT A", ["0"])

        // 多行输出
        test("多行PRINT", "PRINTL 第一行\nPRINTL 第二行\nPRINTL 第三行", ["第一行\n", "第二行\n", "第三行\n"])

        print("\n" + String(repeating: "=", count: 60))
        print("测试总结: 通过 \(pass)/\(pass + fail)")
        if fail == 0 {
            print("🎉 所有测试通过！")
        } else {
            print("⚠️  \(fail) 个测试失败")
        }
        print(String(repeating: "=", count: 60))
    }
}
