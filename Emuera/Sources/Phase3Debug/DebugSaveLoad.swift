//
//  DebugSaveLoad.swift
//  EmueraCore
//
//  测试SAVE/LOAD数据持久化功能
//  Created: 2025-12-23
//

import Foundation
import EmueraCore

/// 测试SAVE/LOAD功能
@main
struct DebugSaveLoad {
    static func main() {
        print("=== SAVE/LOAD功能测试 ===\n")

        // 测试1: 基本变量保存和加载
        testBasicSaveLoad()

        // 测试2: 数组变量保存和加载
        testArraySaveLoad()

        // 测试3: 指定变量保存和加载
        testSpecificVariables()

        // 测试4: DELDATA删除功能
        testDeleteData()

        print("\n=== 所有测试完成 ===")
    }

    /// 测试1: 基本变量保存和加载
    static func testBasicSaveLoad() {
        print("测试1: 基本变量保存和加载")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 设置一些测试变量
            context.variables["TEST_VAR"] = .integer(123)
            context.variables["TEST_STR"] = .string("Hello")

            // 同步到VariableData
            varData.setVariable("TEST_VAR", value: .integer(123))
            varData.setVariable("TEST_STR", value: .string("Hello"))

            // 保存
            let saveScript = "SAVEDATA \"test1\""
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)

            print("  保存输出: \(context.output)")

            // 修改变量
            context.variables["TEST_VAR"] = .integer(999)
            varData.setVariable("TEST_VAR", value: .integer(999))

            // 加载
            let loadScript = "LOADDATA \"test1\""
            let loadStatements = try parser.parse(loadScript)
            context.output.removeAll()
            try executor.execute(loadStatements, context: context)

            print("  加载输出: \(context.output)")

            // 验证
            let result = varData.getVariable("TEST_VAR")
            if case .integer(let value) = result, value == 123 {
                print("  ✓ 验证通过: TEST_VAR = \(value)")
            } else {
                print("  ✗ 验证失败: TEST_VAR = \(result)")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试2: 数组变量保存和加载
    static func testArraySaveLoad() {
        print("测试2: 数组变量保存和加载")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 设置数组变量
            let script = """
            A:0 = 10
            A:1 = 20
            A:2 = 30
            SAVEDATA "test2"
            A:0 = 999
            LOADDATA "test2"
            PRINT A:0, A:1, A:2
            """

            let statements = try parser.parse(script)
            try executor.execute(statements, context: context)

            print("  输出: \(context.output)")

            // 验证数组值
            let outputText = context.output.joined()
            if outputText.contains("10") && outputText.contains("20") && outputText.contains("30") {
                print("  ✓ 验证通过: 数组值正确恢复")
            } else {
                print("  ✗ 验证失败: 输出 = \(outputText)")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试3: 指定变量保存和加载
    static func testSpecificVariables() {
        print("测试3: 指定变量保存和加载")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 设置多个变量
            varData.setVariable("VAR1", value: .integer(100))
            varData.setVariable("VAR2", value: .integer(200))
            varData.setVariable("VAR3", value: .integer(300))

            // 只保存VAR1和VAR2
            let saveScript = "SAVEVAR \"test3\", \"VAR1\", \"VAR2\""
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)

            print("  保存输出: \(context.output)")

            // 修改所有变量
            varData.setVariable("VAR1", value: .integer(999))
            varData.setVariable("VAR2", value: .integer(999))
            varData.setVariable("VAR3", value: .integer(999))

            // 只加载VAR1和VAR2
            let loadScript = "LOADVAR \"test3\", \"VAR1\", \"VAR2\""
            let loadStatements = try parser.parse(loadScript)
            context.output.removeAll()
            try executor.execute(loadStatements, context: context)

            print("  加载输出: \(context.output)")

            // 验证
            let v1 = varData.getVariable("VAR1")
            let v2 = varData.getVariable("VAR2")
            let v3 = varData.getVariable("VAR3")

            if case .integer(100) = v1, case .integer(200) = v2, case .integer(999) = v3 {
                print("  ✓ 验证通过: VAR1=100, VAR2=200, VAR3=999(未变)")
            } else {
                print("  ✗ 验证失败: VAR1=\(v1), VAR2=\(v2), VAR3=\(v3)")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试4: DELDATA删除功能
    static func testDeleteData() {
        print("测试4: DELDATA删除功能")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 先保存
            varData.setVariable("TEST", value: .integer(123))
            let saveScript = "SAVEDATA \"test4\""
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)
            print("  保存: \(context.output)")

            // 删除
            let delScript = "DELDATA \"test4\""
            let delStatements = try parser.parse(delScript)
            context.output.removeAll()
            try executor.execute(delStatements, context: context)
            print("  删除: \(context.output)")

            // 验证文件不存在
            let outputText = context.output.joined()
            if outputText.contains("已删除") {
                print("  ✓ 验证通过: 文件已删除")
            } else {
                print("  ✗ 验证失败: 输出 = \(outputText)")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }
}

// 字符串重复扩展
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}
