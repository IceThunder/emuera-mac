//
//  MinimalTest.swift
//  Phase2Test
//
//  测试函数定义解析
//

import Foundation
import EmueraCore

@main
public struct MinimalTest {
    public static func main() {
        print("=== 测试函数定义解析 ===")
        print("DEBUG: Creating ScriptParser...")
        let parser = ScriptParser()
        print("DEBUG: ScriptParser created")
        let script = """
        @ADD, a, b
        RETURN a + b
        """
        print("脚本:", script)
        do {
            print("DEBUG: About to call parser.parse()...")
            let statements = try parser.parse(script)
            print("解析成功，语句数量:", statements.count)
        } catch {
            print("解析错误:", error)
        }
        print("=== 测试结束 ===")
    }
}