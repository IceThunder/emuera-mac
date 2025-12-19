import Foundation
import EmueraCore

/// 调试测试 - 深入分析问题
@main
struct DebugTest {
    static func main() {
        print("🔍 深入调试 ScriptParser 和 StatementExecutor")
        print(String(repeating: "=", count: 60))

        // 调试测试: B = A + 50 * 2
        print("\n🔍 调试: B = A + 50 * 2")

        // 步骤1: 先设置A = 10
        print("\n步骤1: 设置 A = 10")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("A = 10")
            print("  解析结果: \(statements)")

            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("  执行输出: \(output)")
        } catch {
            print("  ❌ 错误: \(error)")
        }

        // 步骤2: 尝试执行 B = A + 50 * 2
        print("\n步骤2: 执行 B = A + 50 * 2")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("B = A + 50 * 2")
            print("  解析结果: \(statements)")
            print("  语句数量: \(statements.count)")

            // 检查第一个语句的类型
            if let stmt = statements.first as? ExpressionStatement {
                print("  表达式类型: \(type(of: stmt.expression))")
                print("  表达式内容: \(stmt.expression)")
            }

            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("  执行输出: \(output)")
        } catch {
            print("  ❌ 错误: \(error)")
            print("  错误详情: \(error)")
        }

        // 步骤3: 在同一个上下文中执行
        print("\n步骤3: 在同一上下文中执行 A=10, B=A+50*2")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("A = 10\nB = A + 50 * 2")
            print("  解析结果: \(statements.count) 个语句")

            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("  执行输出: \(output)")
        } catch {
            print("  ❌ 错误: \(error)")
        }

        // 步骤4: 测试直接表达式
        print("\n步骤4: 测试 PRINT A + 50 * 2")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("A = 10\nPRINT A + 50 * 2")
            print("  解析结果: \(statements.count) 个语句")

            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("  执行输出: \(output)")
        } catch {
            print("  ❌ 错误: \(error)")
        }

        print("\n" + String(repeating: "=", count: 60))
    }
}
