//
//  ParserOnlyTest.swift
//  Phase2Test
//
//  测试ScriptParser创建和简单解析
//

import Foundation
import EmueraCore

print("=== ParserOnlyTest: 开始 ===")
print("步骤1: 创建ScriptParser...")

let parser = ScriptParser()
print("步骤2: ScriptParser创建完成")

print("步骤3: 准备解析简单脚本...")
let script = "PRINTL Hello"
print("脚本:", script)

do {
    print("步骤4: 调用parser.parse()...")
    let statements = try parser.parse(script)
    print("步骤5: 解析完成，语句数:", statements.count)
    print("=== ParserOnlyTest: 结束 ===")
} catch {
    print("步骤5: 解析错误:", error)
    print("=== ParserOnlyTest: 结束 ===")
}