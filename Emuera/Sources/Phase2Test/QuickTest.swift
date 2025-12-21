//
//  QuickTest.swift
//  Phase2Test
//
//  快速Phase 2功能测试
//

import Foundation
import EmueraCore

@main
public struct QuickTest {
    public static func main() {
        print("=== Phase 2 快速测试开始 ===")
        print("测试1: 基础解析")

        do {
            let parser = ScriptParser()
            let statements = try parser.parse("PRINTL Hello")
            print("解析成功，语句数: \(statements.count)")
        } catch {
            print("解析错误: \(error)")
        }

        print("测试2: 执行")
        do {
            let parser = ScriptParser()
            let statements = try parser.parse("PRINTL Hello")
            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("执行成功，输出: \(output)")
        } catch {
            print("执行错误: \(error)")
        }

        print("=== 测试结束 ===")
    }
}