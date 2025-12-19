import Foundation
import EmueraCore

/// 调试解析器 - 用于诊断问题
@main
struct DebugParser {
    static func main() {
        print("=== Debug Parser ===")

        // 调试BREAK语句
        debugScript("BREAK测试", """
        FOR I, 1, 10
          IF I == 5
            BREAK
          ENDIF
          PRINT I
        ENDFOR
        """)

        // 调试SELECTCASE
        debugScript("SELECTCASE测试", """
        A = 2
        SELECTCASE A
          CASE 1
            PRINTL 一
          CASE 2
            PRINTL 二
          CASE 3
            PRINTL 三
          CASEELSE
            PRINTL 其他
        ENDSELECT
        """)

        // 调试复杂表达式
        debugScript("复杂表达式测试", """
        A = 10
        B = 20
        C = (A + B) * 2 - 5
        PRINT C
        """)

        // 调试嵌套IF
        debugScript("嵌套IF测试", """
        A = 10
        IF A > 5
          IF A < 15
            PRINTL 5到15之间
          ENDIF
        ENDIF
        """)
    }

    static func debugScript(_ name: String, _ script: String) {
        print("\n=== \(name) ===")
        print("脚本:")
        print(script)
        print("\n--- Token分析 ---")

        let engine = ScriptEngine()
        let tokens = engine.getTokens(script)

        for (i, token) in tokens.enumerated() {
            print("  [\(i)]: \(token)")
        }

        print("\n--- 解析结果 ---")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            print("解析到 \(statements.count) 条语句:")
            for (i, stmt) in statements.enumerated() {
                print("  [\(i)]: \(type(of: stmt)) - \(stmt)")
            }

            print("\n--- 执行结果 ---")
            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("输出: \(output)")

        } catch {
            print("错误: \(error)")
        }
    }
}
