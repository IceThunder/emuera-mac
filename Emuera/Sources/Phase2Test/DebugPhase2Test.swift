//
//  DebugPhase2Test.swift
//  Phase2Test
//
//  调试Phase 2功能
//

import Foundation
import EmueraCore

@main
public struct DebugPhase2Test {
    public static func main() {
        print("=== Phase 2 调试测试 ===")

        // 测试1: 基础解析
        print("\n1. 测试基础解析...")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("PRINTL Hello")
            print("   ✓ 解析成功，语句数: \(statements.count)")
            for stmt in statements {
                print("   语句类型: \(type(of: stmt))")
            }
        } catch {
            print("   ✗ 错误: \(error)")
            print("   详细错误: \(error)")
        }

        // 测试2: 执行测试
        print("\n2. 测试执行...")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("PRINTL Hello")
            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("   ✓ 执行成功，输出: \(output)")
        } catch {
            print("   ✗ 执行错误: \(error)")
            print("   详细错误: \(error)")
        }

        // 测试3: 内置函数
        print("\n3. 测试内置函数...")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("PRINTL RAND(100)")
            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("   ✓ 执行成功，输出: \(output)")
        } catch {
            print("   ✗ 错误: \(error)")
            print("   详细错误: \(error)")
        }

        // 测试4: 函数定义解析
        print("\n4. 测试函数定义解析...")
        do {
            let parser = ScriptParser()
            let script = """
            @TEST, a, b
            RETURN a + b
            """
            let statements = try parser.parse(script)
            print("   ✓ 解析成功，语句数: \(statements.count)")

            for stmt in statements {
                if let funcDef = stmt as? FunctionDefinitionStatement {
                    print("   ✓ 发现函数: \(funcDef.definition.name)")
                    print("     参数: \(funcDef.definition.parameters.map { $0.name })")
                    print("     体语句: \(funcDef.definition.body.count)")
                } else {
                    print("   语句类型: \(type(of: stmt))")
                }
            }
        } catch {
            print("   ✗ 错误: \(error)")
            print("   详细错误: \(error)")
        }

        print("\n=== 测试完成 ===")
    }
}