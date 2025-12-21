//
//  DebugFunctionDef.swift
//  Phase2Test
//
//  调试函数定义解析的详细跟踪
//

import Foundation
import EmueraCore

@main
public struct DebugFunctionDef {
    public static func main() {
        print("=== 调试函数定义解析 ===")

        // 测试脚本
        let script = """
        @ADD, a, b
        RETURN a + b
        """

        print("测试脚本:")
        print(script)
        print("\n--- 开始词法分析 ---")

        // 先进行词法分析，查看token流
        print("开始词法分析...")
        let lexical = LexicalAnalyzer()
        let tokens = lexical.tokenize(script)
        print("词法分析完成，Token数量:", tokens.count)

        // 简单打印每个token的类型
        for (i, token) in tokens.enumerated() {
            print("Token", i, ":", token.type.description, "value:", token.value)
        }

        print("\n=== 调试结束 ===")
    }
}