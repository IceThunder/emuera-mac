//
//  DebugSimple.swift
//  Phase2Test
//
//  最简单的调试测试
//

import Foundation
import EmueraCore

@main
public struct DebugSimple {
    public static func main() {
        print("=== 开始测试 ===")

        // 测试1: 只解析函数定义
        print("\n1. 只解析函数定义...")
        do {
            let parser = ScriptParser()
            let script = """
            @ADD, a, b
            RETURN a + b
            """
            let statements = try parser.parse(script)
            print("   ✓ 解析成功，语句数: \(statements.count)")

            for stmt in statements {
                print("   语句类型: \(type(of: stmt))")
                if let funcDef = stmt as? FunctionDefinitionStatement {
                    print("   函数名: \(funcDef.definition.name)")
                    print("   参数: \(funcDef.definition.parameters.map { $0.name })")
                    print("   体语句数: \(funcDef.definition.body.count)")
                    for bodyStmt in funcDef.definition.body {
                        print("     体语句: \(type(of: bodyStmt))")
                    }
                }
            }
        } catch {
            print("   ✗ 错误: \(error)")
        }

        // 测试2: 解析函数调用
        print("\n2. 解析函数调用...")
        do {
            let parser = ScriptParser()
            let script = """
            CALL @ADD, 5, 3
            """
            let statements = try parser.parse(script)
            print("   ✓ 解析成功，语句数: \(statements.count)")

            for stmt in statements {
                print("   语句类型: \(type(of: stmt))")
                if let funcCall = stmt as? FunctionCallStatement {
                    print("   函数名: \(funcCall.functionName)")
                    print("   参数数: \(funcCall.arguments.count)")
                }
            }
        } catch {
            print("   ✗ 错误: \(error)")
        }

        // 测试3: 执行函数调用（不带函数定义）
        print("\n3. 执行内置函数调用...")
        do {
            let parser = ScriptParser()
            let script = "PRINTL RAND(100)"
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("   ✓ 执行成功，输出: \(output)")
        } catch {
            print("   ✗ 错误: \(error)")
        }

        print("\n=== 测试结束 ===")
    }
}