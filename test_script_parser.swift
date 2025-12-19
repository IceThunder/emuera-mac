#!/usr/bin/swift

import Foundation

// Add the Sources directory to the import path
import EmueraCore

print("🧪 ScriptParser + StatementExecutor 测试")
print(String(repeating: "=", count: 60))
print()

// 简单测试1: 基础赋值和输出
print("测试1: 基础赋值和输出")
print("脚本: A = 100\\nPRINT A")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("A = 100\nPRINT A")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print("期望: [\"100\"]")
    print("结果: \(output == ["100"] ? "✅ 通过" : "❌ 失败")")
} catch {
    print("❌ 错误: \(error)")
}
print()

// 简单测试2: 表达式计算
print("测试2: 表达式计算")
print("脚本: A = 10\\nB = A + 50 * 2\\nPRINT B")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("A = 10\nB = A + 50 * 2\nPRINT B")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print("期望: [\"110\"]")
    print("结果: \(output == ["110"] ? "✅ 通过" : "❌ 失败")")
} catch {
    print("❌ 错误: \(error)")
}
print()

// 简单测试3: IF语句
print("测试3: IF语句 - 条件为真")
print("脚本: A = 10\\nIF A > 5\\n  PRINTL A大于5\\nENDIF")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("A = 10\nIF A > 5\n  PRINTL A大于5\nENDIF")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print("期望: [\"A大于5\\n\"]")
    print("结果: \(output == ["A大于5\n"] ? "✅ 通过" : "❌ 失败")")
} catch {
    print("❌ 错误: \(error)")
}
print()

print("测试完成")
