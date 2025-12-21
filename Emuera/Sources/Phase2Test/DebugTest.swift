//
//  DebugTest.swift
//  Phase2Test
//
//  调试测试 - 逐步输出定位死循环
//

import Foundation
import EmueraCore

@main
public struct DebugTest {
    public static func main() {
        print("=== 开始调试测试 ===")

        // 测试1: 简单的词法分析
        print("\n1. 词法分析测试...")
        do {
            let lexer = LexicalAnalyzer()
            let script = """
            @ADD, a, b
            RETURN a + b
            """
            print("   输入脚本: \\(script)")
            let tokens = lexer.tokenize(script)
            print("   ✓ Token数量: \\(tokens.count)")
            for (i, token) in tokens.enumerated() {
                print("     [\\(i)]: \\(token.type)")
            }
        } catch {
            print("   ✗ 错误: \\(error)")
        }

        // 测试2: 简单的解析测试
        print("\n2. 简单解析测试...")
        do {
            let parser = ScriptParser()
            let script = "PRINTL 123"
            print("   输入脚本: \\(script)")
            print("   开始解析...")
            let statements = try parser.parse(script)
            print("   ✓ 解析成功，语句数: \\(statements.count)")
        } catch {
            print("   ✗ 错误: \\(error)")
        }

        // 测试3: 函数定义解析
        print("\n3. 函数定义解析测试...")
        do {
            let parser = ScriptParser()
            let script = """
            @ADD, a, b
            RETURN a + b
            """
            print("   输入脚本: \\(script)")
            print("   开始解析...")
            let statements = try parser.parse(script)
            print("   ✓ 解析成功，语句数: \\(statements.count)")

            for (i, stmt) in statements.enumerated() {
                print("     [\\(i)]: \\(type(of: stmt))")
            }
        } catch {
            print("   ✗ 错误: \\(error)")
        }

        print("\n=== 调试测试结束 ===")
    }
}