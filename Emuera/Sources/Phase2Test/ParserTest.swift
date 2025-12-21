//
//  ParserTest.swift
//  Phase2Test
//
//  测试ScriptParser
//

import Foundation
import EmueraCore

@main
public struct ParserTest {
    public static func main() {
        print("=== Parser测试开始 ===")

        print("创建ScriptParser...")
        let parser = ScriptParser()
        print("✓ 创建成功")

        print("准备解析简单脚本...")
        let script = "PRINTL 123"
        print("脚本: \\(script)")

        do {
            print("开始解析...")
            let statements = try parser.parse(script)
            print("✓ 解析成功，语句数: \\(statements.count)")
        } catch {
            print("✗ 解析错误: \\(error)")
        }

        print("=== Parser测试结束 ===")
    }
}