//
//  FunctionDefTest.swift
//  Phase2Test
//
//  测试函数定义解析
//

import Foundation
import EmueraCore

@main
public struct FunctionDefTest {
    public static func main() {
        print("=== 函数定义测试开始 ===")

        let parser = ScriptParser()

        // 测试1: 简单函数定义
        print("\n1. 简单函数定义...")
        do {
            let script = """
            @ADD, a, b
            RETURN a + b
            """
            print("脚本: \\(script)")
            let statements = try parser.parse(script)
            print("✓ 解析成功，语句数: \\(statements.count)")
            for stmt in statements {
                print("  类型: \\(type(of: stmt))")
            }
        } catch {
            print("✗ 错误: \\(error)")
        }

        print("\n=== 函数定义测试结束 ===")
    }
}