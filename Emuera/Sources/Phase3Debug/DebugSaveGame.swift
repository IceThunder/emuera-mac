//
//  DebugSaveGame.swift
//  EmueraCore
//
//  测试SAVEGAME/LOADGAME完整游戏状态持久化功能
//  Created: 2025-12-24
//

import Foundation
import EmueraCore

/// 测试SAVEGAME/LOADGAME功能
@main
struct DebugSaveGame {
    static func main() {
        print("=== SAVEGAME/LOADGAME功能测试 ===\n")

        // 测试1: 基本游戏状态保存和加载
        testBasicGameSaveLoad()

        // 测试2: 包含角色的完整游戏状态
        testGameWithCharacters()

        // 测试3: 游戏状态恢复验证
        testGameStateRecovery()

        print("\n=== 所有测试完成 ===")
    }

    /// 测试1: 基本游戏状态保存和加载
    static func testBasicGameSaveLoad() {
        print("测试1: 基本游戏状态保存和加载")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 设置一些全局变量
            context.variables["RESULT"] = .integer(100)
            context.variables["MASTER"] = .integer(0)
            context.variables["TARGET"] = .integer(1)

            // 同步到VariableData
            varData.setVariable("RESULT", value: .integer(100))
            varData.setVariable("MASTER", value: .integer(0))
            varData.setVariable("TARGET", value: .integer(1))

            // 设置系统变量
            varData.dataInteger[0x00] = 10  // DAY
            varData.dataInteger[0x01] = 1000  // MONEY

            // 设置数组
            varData.setArray("SELECTCOM", values: [1, 2, 3])

            print("  设置变量:")
            print("    RESULT: 100")
            print("    DAY: 10, MONEY: 1000")
            print("    SELECTCOM: [1, 2, 3]")

            // 保存游戏
            let saveScript = "SAVEGAME \"test_game\""
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)

            print("  保存输出: \(context.output)")

            // 修改所有数据
            context.variables["RESULT"] = .integer(999)
            varData.setVariable("RESULT", value: .integer(999))
            varData.dataInteger[0x00] = 99
            varData.dataInteger[0x01] = 9999
            varData.setArray("SELECTCOM", values: [999])

            print("  修改后: RESULT=999, DAY=99, SELECTCOM=[999]")

            // 加载游戏
            let loadScript = "LOADGAME \"test_game\""
            let loadStatements = try parser.parse(loadScript)
            context.output.removeAll()
            try executor.execute(loadStatements, context: context)

            print("  加载输出: \(context.output)")

            // 验证
            let result = varData.getVariable("RESULT")
            let day = varData.dataInteger[0x00]
            let money = varData.dataInteger[0x01]
            let selectcom = varData.getArray("SELECTCOM")

            if case .integer(100) = result, day == 10, money == 1000, selectcom == [1, 2, 3] {
                print("  ✓ 验证通过: 游戏状态正确恢复")
            } else {
                print("  ✗ 验证失败: result=\(result), day=\(day), money=\(money), selectcom=\(selectcom)")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试2: 包含角色的完整游戏状态
    static func testGameWithCharacters() {
        print("测试2: 包含角色的完整游戏状态")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 设置变量
            varData.setVariable("RESULT", value: .integer(50))
            varData.dataInteger[0x00] = 5  // DAY
            varData.setArray("A", values: [10, 20, 30])

            // 创建角色
            let char1 = varData.createCharacter()
            char1.name = "角色A"
            char1.id = 0
            char1.dataInteger[0] = 100  // BASE

            let char2 = varData.createCharacter()
            char2.name = "角色B"
            char2.id = 1
            char2.dataInteger[0] = 200

            print("  初始状态:")
            print("    变量: RESULT=50, DAY=5, A=[10,20,30]")
            print("    角色: 0=\(char1.name)(BASE=\(char1.dataInteger[0])), 1=\(char2.name)(BASE=\(char2.dataInteger[0]))")

            // 保存游戏
            let saveScript = "SAVEGAME \"full_game\""
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)

            print("  保存完成")

            // 修改所有数据
            varData.setVariable("RESULT", value: .integer(999))
            varData.dataInteger[0x00] = 99
            varData.setArray("A", values: [999])
            char1.name = "修改A"
            char1.dataInteger[0] = 999
            char2.name = "修改B"

            // 加载游戏
            let loadScript = "LOADGAME \"full_game\""
            let loadStatements = try parser.parse(loadScript)
            try executor.execute(loadStatements, context: context)

            // 验证
            let result = varData.getVariable("RESULT")
            let day = varData.dataInteger[0x00]
            let arrayA = varData.getArray("A")
            let loadedChar1 = varData.characters[0]
            let loadedChar2 = varData.characters[1]

            if case .integer(50) = result,
               day == 5,
               arrayA == [10, 20, 30],
               loadedChar1.name == "角色A" && loadedChar1.dataInteger[0] == 100,
               loadedChar2.name == "角色B" && loadedChar2.dataInteger[0] == 200 {
                print("  ✓ 验证通过: 完整游戏状态正确恢复")
            } else {
                print("  ✗ 验证失败")
                print("    变量: RESULT=\(result), DAY=\(day), A=\(arrayA)")
                print("    角色: 0=\(loadedChar1.name), 1=\(loadedChar2.name)")
            }

        } catch {
            print("  ✗ 测试失败: \(error)")
        }
        print()
    }

    /// 测试3: 游戏状态恢复验证
    static func testGameStateRecovery() {
        print("测试3: 游戏状态恢复验证")
        print("-" * 40)

        do {
            let parser = ScriptParser()
            let executor = StatementExecutor()
            let varData = VariableData()
            let context = ExecutionContext()
            context.varData = varData

            // 设置复杂数据
            // 系统变量
            varData.dataInteger[0x00] = 1  // DAY
            varData.dataInteger[0x01] = 500  // MONEY
            varData.dataInteger[0x0A] = 42  // RESULT

            // 数组
            varData.setArray("FLAG", values: [1, 0, 1, 0, 1])
            varData.setArray("TFLAG", values: [10, 20, 30])

            // 2D数组
            varData.dataIntegerArray2D[0x00] = [[1, 2], [3, 4]]  // CDFLAG

            // 角色
            let char = varData.createCharacter()
            char.name = "测试角色"
            char.dataInteger[0] = 100
            char.dataIntegerArray[0] = [10, 20, 30]

            print("  保存前数据:")
            print("    系统: DAY=\(varData.dataInteger[0x00]), MONEY=\(varData.dataInteger[0x01]), RESULT=\(varData.dataInteger[0x0A])")
            print("    数组: FLAG=\(varData.getArray("FLAG")), TFLAG=\(varData.getArray("TFLAG"))")
            print("    2D数组: CDFLAG=\(varData.dataIntegerArray2D[0x00])")
            print("    角色: \(char.name), BASE=\(char.dataInteger[0]), BASE数组=\(char.dataIntegerArray[0])")

            // 保存
            let saveScript = "SAVEGAME \"complex_game\""
            let saveStatements = try parser.parse(saveScript)
            try executor.execute(saveStatements, context: context)

            // 破坏所有数据
            varData.dataInteger = Array(repeating: 999, count: varData.dataInteger.count)
            varData.setArray("FLAG", values: [999])
            varData.setArray("TFLAG", values: [999])
            varData.dataIntegerArray2D[0x00] = [[999]]
            char.name = "破坏"
            char.dataInteger[0] = 999
            char.dataIntegerArray[0] = [999]

            // 加载
            let loadScript = "LOADGAME \"complex_game\""
            let loadStatements = try parser.parse(loadScript)
            try executor.execute(loadStatements, context: context)

            // 验证
            print("  加载后数据:")
            print("    系统: DAY=\(varData.dataInteger[0x00]), MONEY=\(varData.dataInteger[0x01]), RESULT=\(varData.dataInteger[0x0A])")
            print("    数组: FLAG=\(varData.getArray("FLAG")), TFLAG=\(varData.getArray("TFLAG"))")
            print("    2D数组: CDFLAG=\(varData.dataIntegerArray2D[0x00])")
            print("    角色数量: \(varData.characters.count)")
            if varData.characters.count > 0 {
                let loadedChar = varData.characters[0]
                print("    角色[0]: name=\(loadedChar.name), BASE=\(loadedChar.dataInteger[0]), BASE数组=\(loadedChar.dataIntegerArray[0])")
            }

            // 验证时使用加载后的角色数据，而不是原始char引用
            let loadedChar = varData.characters.count > 0 ? varData.characters[0] : nil
            let success = varData.dataInteger[0x00] == 1 &&
                         varData.dataInteger[0x01] == 500 &&
                         varData.dataInteger[0x0A] == 42 &&
                         varData.getArray("FLAG") == [1, 0, 1, 0, 1] &&
                         varData.getArray("TFLAG") == [10, 20, 30] &&
                         varData.dataIntegerArray2D[0x00] == [[1, 2], [3, 4]] &&
                         loadedChar?.name == "测试角色" &&
                         loadedChar?.dataInteger[0] == 100 &&
                         loadedChar?.dataIntegerArray[0] == [10, 20, 30]

            if success {
                print("  ✓ 验证通过: 复杂游戏状态完整恢复")
            } else {
                print("  ✗ 验证失败: 部分数据未恢复")
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
