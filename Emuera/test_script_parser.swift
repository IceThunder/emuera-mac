#!/usr/bin/env swift

import Foundation
import EmueraCore

print("=" * 60)
print("ScriptParser + StatementExecutor 快速测试")
print("=" * 60)
print()

// 测试1: 基础赋值
print("测试1: 基础赋值")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("A = 100\nPRINT A")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print()
} catch {
    print("错误: \(error)\n")
}

// 测试2: IF语句
print("测试2: IF语句")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("A = 10\nIF A > 5\n  PRINTL A大于5\nENDIF")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print()
} catch {
    print("错误: \(error)\n")
}

// 测试3: WHILE循环
print("测试3: WHILE循环")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("COUNT = 0\nWHILE COUNT < 3\n  PRINT COUNT\n  COUNT = COUNT + 1\nENDWHILE")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print()
} catch {
    print("错误: \(error)\n")
}

// 测试4: FOR循环
print("测试4: FOR循环")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("FOR I, 1, 3\n  PRINT I\nENDFOR")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print()
} catch {
    print("错误: \(error)\n")
}

// 测试5: SELECTCASE
print("测试5: SELECTCASE")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("A = 2\nSELECTCASE A\n  CASE 1\n    PRINTL 一\n  CASE 2\n    PRINTL 二\n  CASEELSE\n    PRINTL 其他\nENDSELECT")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print()
} catch {
    print("错误: \(error)\n")
}

// 测试6: GOTO
print("测试6: GOTO")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("GOTO SKIP\nPRINTL 不应该执行\n@SKIP\nPRINTL 跳转成功")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print()
} catch {
    print("错误: \(error)\n")
}

// 测试7: CALL
print("测试7: CALL")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("CALL SUB\nQUIT\n@SUB\nPRINTL 子程序\nRETURN")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print()
} catch {
    print("错误: \(error)\n")
}

// 测试8: BREAK
print("测试8: BREAK")
do {
    let parser = ScriptParser()
    let statements = try parser.parse("COUNT = 0\nWHILE COUNT < 10\n  IF COUNT == 3\n    BREAK\n  ENDIF\n  PRINT COUNT\n  COUNT = COUNT + 1\nENDWHILE")
    print("解析成功，得到 \(statements.count) 个语句")

    let executor = StatementExecutor()
    let output = executor.execute(statements)
    print("输出: \(output)")
    print()
} catch {
    print("错误: \(error)\n")
}

print("=" * 60)
print("测试完成")
print("=" * 60)

// String扩展
extension String {
    static func *(left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
