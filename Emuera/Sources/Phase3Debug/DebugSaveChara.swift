//
//  DebugSaveChara.swift
//  EmueraCore
//
//  测试SAVECHARA/LOADCHARA角色数据持久化功能
//  Created: 2025-12-24
//

import Foundation
import EmueraCore

/// 测试SAVECHARA/LOADCHARA功能
@main
struct DebugSaveChara {
    static func main() {
        print("=== SAVECHARA/LOADCHARA功能测试 ===\n")

        // 测试1: 基本角色保存和加载
        testBasicCharaSaveLoad()

        // 测试2: 角色数据完整性验证
        testCharaDataIntegrity()

        // 测试3: 覆盖角色数据
        testCharaOverwrite()

        print("\n=== 所有测试完成 ===")
    }

    /// 测试1: 基本角色保存和加载
    static func testBasicCharaSaveLoad() {
        print("测试1: 基本角色保存和加载")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 创建并设置角色数据
            let char = varData.createCharacter()
            char.name = "测试角色"
            char.id = 0
            char.dataInteger[0] = 100  // BASE
            char.dataInteger[1] = 500  // MAXBASE
            char.dataIntegerArray[0] = [10, 20, 30]  // BASE数组

            print("  创建角色: \(char.name), ID: \(char.id)")
            print("  BASE[0]: \(char.dataInteger[0])")
            print("  BASE数组: \(char.dataIntegerArray[0])")

            // 保存角色
            let saveScript = "SAVECHARA \"test_chara\", 0"
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)

            print("  保存输出: \(context.output)")

            // 修改角色数据
            char.name = "修改后的角色"
            char.dataInteger[0] = 999
            char.dataIntegerArray[0] = [999, 999, 999]

            print("  修改后 - BASE[0]: \(char.dataInteger[0])")

            // 加载角色
            let loadScript = "LOADCHARA \"test_chara\", 0"
            let loadStatements = try parser.parse(loadScript)
            context.output.removeAll()
            try executor.execute(loadStatements, context: context)

            print("  加载输出: \(context.output)")

            // 验证
            let loadedChar = varData.characters[0]
            if loadedChar.name == "测试角色" &&
               loadedChar.dataInteger[0] == 100 &&
               loadedChar.dataIntegerArray[0] == [10, 20, 30] {
                print("  ✓ 验证通过: 角色数据正确恢复")
            } else {
                print("  ✗ 验证失败: name=\(loadedChar.name), base=\(loadedChar.dataInteger[0]), array=\(loadedChar.dataIntegerArray[0])")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试2: 角色数据完整性验证
    static func testCharaDataIntegrity() {
        print("测试2: 角色数据完整性验证")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 创建角色并设置所有类型的数据
            let char = varData.createCharacter()
            char.name = "完整角色"
            char.id = 5

            // 设置单值
            char.dataInteger[0] = 123
            char.dataInteger[1] = 456
            char.dataString[0] = "测试字符串"

            // 设置1D数组
            char.dataIntegerArray[0] = [1, 2, 3, 4, 5]
            char.dataStringArray[0] = ["A", "B", "C"]

            // 设置2D数组
            char.dataIntegerArray2D[0] = [[1, 2], [3, 4]]

            print("  原始数据:")
            print("    integers: \(char.dataInteger.prefix(2))")
            print("    strings: \(char.dataString.prefix(1))")
            print("    intArrays[0]: \(char.dataIntegerArray[0])")
            print("    strArrays[0]: \(char.dataStringArray[0])")
            print("    int2D[0]: \(char.dataIntegerArray2D[0])")

            // 保存
            let saveScript = "SAVECHARA \"test_full\", 0"
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)

            // 修改所有数据
            char.dataInteger[0] = 999
            char.dataInteger[1] = 999
            char.dataString[0] = "已修改"
            char.dataIntegerArray[0] = [999]
            char.dataStringArray[0] = ["X"]
            char.dataIntegerArray2D[0] = [[999]]

            // 加载
            let loadScript = "LOADCHARA \"test_full\", 0"
            let loadStatements = try parser.parse(loadScript)
            try executor.execute(loadStatements, context: context)

            // 验证
            let loadedChar = varData.characters[0]
            let success = loadedChar.dataInteger[0] == 123 &&
                         loadedChar.dataInteger[1] == 456 &&
                         loadedChar.dataString[0] == "测试字符串" &&
                         loadedChar.dataIntegerArray[0] == [1, 2, 3, 4, 5] &&
                         loadedChar.dataStringArray[0] == ["A", "B", "C"] &&
                         loadedChar.dataIntegerArray2D[0] == [[1, 2], [3, 4]]

            if success {
                print("  ✓ 验证通过: 所有数据类型完整恢复")
            } else {
                print("  ✗ 验证失败: 部分数据未正确恢复")
                print("    加载后数据: \(loadedChar.dataInteger.prefix(2))")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试3: 覆盖角色数据
    static func testCharaOverwrite() {
        print("测试3: 覆盖角色数据")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 创建两个角色
            let char1 = varData.createCharacter()
            char1.name = "角色1"
            char1.dataInteger[0] = 100

            let char2 = varData.createCharacter()
            char2.name = "角色2"
            char2.dataInteger[0] = 200

            print("  初始状态: 角色0=\(char1.name), 角色1=\(char2.name)")

            // 保存角色0
            let saveScript1 = "SAVECHARA \"char0\", 0"
            let saveStatements1 = try parser.parse(saveScript1)
            try executor.execute(saveStatements1, context: context)
            print("  保存角色0: \(context.output.last ?? "")")

            // 保存角色1
            let saveScript2 = "SAVECHARA \"char1\", 1"
            let saveStatements2 = try parser.parse(saveScript2)
            context.output.removeAll()
            try executor.execute(saveStatements2, context: context)
            print("  保存角色1: \(context.output.last ?? "")")

            // 修改角色0的数据
            char1.name = "角色0_修改"
            char1.dataInteger[0] = 999

            // 将角色1加载到角色0的位置（覆盖）
            let loadScript = "LOADCHARA \"char1\", 0"
            let loadStatements = try parser.parse(loadScript)
            context.output.removeAll()
            try executor.execute(loadStatements, context: context)
            print("  加载角色1到位置0: \(context.output.last ?? "")")

            // 验证
            if varData.characters[0].name == "角色2" && varData.characters[0].dataInteger[0] == 200 {
                print("  ✓ 验证通过: 角色数据正确覆盖")
            } else {
                print("  ✗ 验证失败: \(varData.characters[0].name)")
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
