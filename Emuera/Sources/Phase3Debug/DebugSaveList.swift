//
//  DebugSaveList.swift
//  EmueraCore
//
//  测试SAVELIST/SAVEEXISTS存档管理功能
//  Created: 2025-12-24
//

import Foundation
import EmueraCore

/// 测试SAVELIST/SAVEEXISTS功能
@main
struct DebugSaveList {
    static func main() {
        print("=== SAVELIST/SAVEEXISTS功能测试 ===\n")

        // 测试1: SAVELIST - 列出存档（空目录）
        testSaveListEmpty()

        // 测试2: 创建一些存档后测试SAVELIST
        testSaveListWithFiles()

        // 测试3: SAVEEXISTS - 检查存档是否存在
        testSaveExists()

        print("\n=== 所有测试完成 ===")
    }

    /// 测试1: SAVELIST - 空目录
    static func testSaveListEmpty() {
        print("测试1: SAVELIST - 空目录")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 先清理所有存档
            clearAllSaves()

            // 执行SAVELIST
            let script = "SAVELIST"
            let statements = try parser.parse(script)
            try executor.execute(statements, context: context)

            print("  输出:")
            for line in context.output {
                print("    \(line)")
            }

            // 验证
            if context.output.joined().contains("没有找到存档文件") {
                print("  ✓ 验证通过: 正确显示空目录")
            } else {
                print("  ✗ 验证失败")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试2: SAVELIST - 有文件
    static func testSaveListWithFiles() {
        print("测试2: SAVELIST - 有存档文件")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 创建一些测试存档
            varData.setVariable("RESULT", value: .integer(100))
            varData.setArray("TEST", values: [1, 2, 3])

            // 保存多个文件
            let saveScripts = [
                "SAVEDATA \"test1\"",
                "SAVEDATA \"test2\"",
                "SAVEDATA \"test3\""
            ]

            for script in saveScripts {
                let statements = try parser.parse(script)
                try executor.execute(statements, context: context)
            }

            // 清空输出
            context.output.removeAll()

            // 执行SAVELIST
            let listScript = "SAVELIST"
            let listStatements = try parser.parse(listScript)
            try executor.execute(listStatements, context: context)

            print("  输出:")
            for line in context.output {
                print("    \(line)")
            }

            // 验证
            let output = context.output.joined()
            if output.contains("test1") && output.contains("test2") && output.contains("test3") {
                print("  ✓ 验证通过: 正确列出所有存档")
            } else {
                print("  ✗ 验证失败")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试3: SAVEEXISTS - 检查存档是否存在
    static func testSaveExists() {
        print("测试3: SAVEEXISTS - 检查存档是否存在")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 创建一个存档
            varData.setVariable("RESULT", value: .integer(999))
            let saveScript = "SAVEDATA \"exists_test\""
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)

            // 测试存在的存档
            context.output.removeAll()
            let checkExists = "SAVEEXISTS \"exists_test\""
            let existsStatements = try parser.parse(checkExists)
            try executor.execute(existsStatements, context: context)

            print("  检查存在的存档:")
            for line in context.output {
                print("    \(line)")
            }

            let existsResult = context.lastResult
            let existsSuccess = (existsResult == .integer(1))

            // 测试不存在的存档
            context.output.removeAll()
            let checkNotExists = "SAVEEXISTS \"nonexistent\""
            let notExistsStatements = try parser.parse(checkNotExists)
            try executor.execute(notExistsStatements, context: context)

            print("  检查不存在的存档:")
            for line in context.output {
                print("    \(line)")
            }

            let notExistsResult = context.lastResult
            let notExistsSuccess = (notExistsResult == .integer(0))

            // 验证
            if existsSuccess && notExistsSuccess {
                print("  ✓ 验证通过: SAVEEXISTS工作正常")
            } else {
                print("  ✗ 验证失败")
                print("    期望: 存在=1, 不存在=0")
                print("    实际: 存在=\(existsResult), 不存在=\(notExistsResult)")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 辅助函数: 清理所有存档
    static func clearAllSaves() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let savesURL = documentsURL.appendingPathComponent("EmueraSaves")
        try? FileManager.default.removeItem(at: savesURL)
    }
}

// 字符串重复扩展
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}
