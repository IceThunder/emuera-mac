import Foundation
import EmueraCore

/// 调试BREAK问题
@main
struct DebugBreak {
    static func main() {
        print("=== Debug BREAK ===")

        let script = """
        FOR I, 1, 10
          IF I == 5
            BREAK
          ENDIF
          PRINT I
        ENDFOR
        """

        print("脚本:")
        print(script)
        print()

        // 使用ScriptEngine获取tokens
        let engine = ScriptEngine()
        let tokens = engine.getTokens(script)

        print("Tokens:")
        for (i, token) in tokens.enumerated() {
            print("  [\(i)]: \(token)")
        }
        print()

        // 尝试解析
        print("解析:")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            print("成功！解析到 \(statements.count) 条语句")
            for (i, stmt) in statements.enumerated() {
                print("  [\(i)]: \(type(of: stmt))")
            }
        } catch {
            print("错误: \(error)")
        }
    }
}
