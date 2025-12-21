//
//  SimplePhase2Test.swift
//  Phase2Test
//
//  简化的Phase 2测试
//

import Foundation
import EmueraCore

@main
public struct SimplePhase2Test {
    public static func main() {
        print("=== Phase 2 简单测试开始 ===")

        // 测试1: 基础解析
        print("\n1. 基础解析测试...")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("PRINTL Hello")
            print("   ✓ 解析成功，语句数: \(statements.count)")
        } catch {
            print("   ✗ 错误: \(error)")
        }

        // 测试2: 内置函数
        print("\n2. 内置函数测试...")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("PRINTL RAND(100)")
            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("   ✓ 执行成功，输出: \(output)")
        } catch {
            print("   ✗ 错误: \(error)")
        }

        // 测试3: 函数定义解析
        print("\n3. 函数定义解析...")
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
                }
            }
        } catch {
            print("   ✗ 错误: \(error)")
        }

        print("\n=== 测试完成 ===")
    }
}
