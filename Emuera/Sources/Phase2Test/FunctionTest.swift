//
//  FunctionTest.swift
//  Phase2Test
//
//  Phase 2函数定义和调用测试
//

import Foundation
import EmueraCore

@main
public struct FunctionTest {
    public static func main() {
        print("=== Phase 2 函数测试 ===")

        // 测试1: 函数定义解析
        print("\n1. 函数定义解析测试...")
        do {
            let parser = ScriptParser()
            let script = """
            @ADD, a, b
            RETURN a + b
            """
            let statements = try parser.parse(script)
            print("   ✓ 解析成功，语句数: \(statements.count)")

            for stmt in statements {
                if let funcDef = stmt as? FunctionDefinitionStatement {
                    print("   ✓ 函数定义: \(funcDef.definition.name)")
                    print("     参数: \(funcDef.definition.parameters.map { $0.name })")
                    print("     体语句: \(funcDef.definition.body.count)")
                }
            }
        } catch {
            print("   ✗ 错误: \(error)")
        }

        // 测试2: 函数调用解析
        print("\n2. 函数调用解析测试...")
        do {
            let parser = ScriptParser()
            let script = """
            @ADD, a, b
            RETURN a + b

            CALL @ADD, 5, 3
            """
            let statements = try parser.parse(script)
            print("   ✓ 解析成功，语句数: \(statements.count)")

            for stmt in statements {
                if let funcCall = stmt as? FunctionCallStatement {
                    print("   ✓ 函数调用: \(funcCall.functionName)")
                    print("     参数: \(funcCall.arguments.count)")
                } else if let funcDef = stmt as? FunctionDefinitionStatement {
                    print("   ✓ 函数定义: \(funcDef.definition.name)")
                }
            }
        } catch {
            print("   ✗ 错误: \(error)")
        }

        // 测试3: 函数执行
        print("\n3. 函数执行测试...")
        do {
            let parser = ScriptParser()
            let script = """
            @ADD, a, b
            RETURN a + b

            PRINTL 结果:
            PRINT @ADD, 5, 3
            PRINTL
            """
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            print("   ✓ 执行成功")
            print("   输出:")
            for line in output {
                print("     \(line)")
            }
        } catch {
            print("   ✗ 错误: \(error)")
        }

        // 测试4: 递归函数（阶乘）
        print("\n4. 递归函数测试（阶乘）...")
        do {
            let parser = ScriptParser()
            let script = """
            @FACTORIAL, n
            IF n <= 1
                RETURN 1
            ENDIF
            RETURN n * @FACTORIAL, n - 1

            PRINTL 5! =
            PRINT @FACTORIAL, 5
            PRINTL
            """
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            print("   ✓ 执行成功")
            print("   输出:")
            for line in output {
                print("     \(line)")
            }
        } catch {
            print("   ✗ 错误: \(error)")
        }

        print("\n=== 测试完成 ===")
    }
}