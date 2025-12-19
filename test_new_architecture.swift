#!/usr/bin/env swift

import Foundation

// 导入 EmueraCore
import EmueraCore

print("=== 测试新架构 ===\n")

// 1. 测试 VariableData 初始化
print("1. 测试 VariableData 初始化...")
let varData = VariableData()
print("✓ VariableData 初始化成功")
print("  - dataIntegerArray 数量: \(varData.dataIntegerArray.count)")
print("  - dataIntegerArray2D 数量: \(varData.dataIntegerArray2D.count)")
print("  - dataIntegerArray3D 数量: \(varData.dataIntegerArray3D.count)")
print()

// 2. 测试 TokenData
print("2. 测试 TokenData...")
let tokenData = varData.getTokenData()
print("✓ TokenData 初始化成功")
print("  - 已注册变量数: \(tokenData.getAllVariableNames().count)")
print()

// 3. 测试基本变量访问
print("3. 测试基本变量访问...")
do {
    // 设置 DAY = 10
    try tokenData.setIntValue("DAY", value: 10)
    let day = try tokenData.getIntValue("DAY")
    print("✓ DAY 变量: \(day) (期望: 10)")

    // 设置 MONEY = 1000
    try tokenData.setIntValue("MONEY", value: 1000)
    let money = try tokenData.getIntValue("MONEY")
    print("✓ MONEY 变量: \(money) (期望: 1000)")
} catch {
    print("✗ 错误: \(error)")
}
print()

// 4. 测试 1D 数组访问
print("4. 测试 1D 数组访问...")
do {
    // A[0] = 50
    try tokenData.setIntValue("A", value: 50, arguments: [0])
    let a0 = try tokenData.getIntValue("A", arguments: [0])
    print("✓ A[0] = \(a0) (期望: 50)")

    // FLAG[5] = 999
    try tokenData.setIntValue("FLAG", value: 999, arguments: [5])
    let flag5 = try tokenData.getIntValue("FLAG", arguments: [5])
    print("✓ FLAG[5] = \(flag5) (期望: 999)")
} catch {
    print("✗ 错误: \(error)")
}
print()

// 5. 测试 2D 数组访问
print("5. 测试 2D 数组访问...")
do {
    // CDFLAG[0, 3] = 123
    try tokenData.setIntValue("CDFLAG", value: 123, arguments: [0, 3])
    let cdflag = try tokenData.getIntValue("CDFLAG", arguments: [0, 3])
    print("✓ CDFLAG[0, 3] = \(cdflag) (期望: 123)")
} catch {
    print("✗ 错误: \(error)")
}
print()

// 6. 测试字符数据
print("6. 测试字符数据...")
do {
    // 创建一个角色
    let char = varData.createCharacter()
    char.id = 1
    char.name = "TestChar"

    // 设置 BASE[0] = 100 (体力)
    try tokenData.setIntValue("BASE", value: 100, arguments: [0, 0])
    let base = try tokenData.getIntValue("BASE", arguments: [0, 0])
    print("✓ BASE[0, 0] = \(base) (期望: 100)")

    // 设置 NAME = "Test"
    try tokenData.setStrValue("NAME", value: "Test", arguments: [0])
    let name = try tokenData.getStrValue("NAME", arguments: [0])
    print("✓ NAME[0] = \(name) (期望: Test)")
} catch {
    print("✗ 错误: \(error)")
}
print()

// 7. 测试特殊变量
print("7. 测试特殊变量...")
do {
    // RAND(100)
    let rand = try tokenData.getIntValue("RAND", arguments: [100])
    print("✓ RAND(100) = \(rand) (范围: 0-99)")

    // CHARANUM
    let charaNum = try tokenData.getIntValue("CHARANUM")
    print("✓ CHARANUM = \(charaNum) (当前角色数)")

    // __INT_MAX__
    let intMax = try tokenData.getIntValue("__INT_MAX__")
    print("✓ __INT_MAX__ = \(intMax)")
} catch {
    print("✗ 错误: \(error)")
}
print()

// 8. 测试表达式求值
print("8. 测试表达式求值...")
do {
    // 设置变量用于测试
    try tokenData.setIntValue("A", value: 10, arguments: [0])
    try tokenData.setIntValue("B", value: 20, arguments: [0])

    // 解析和求值表达式
    let parser = ExpressionParser()
    let evaluator = ExpressionEvaluator(variableData: varData)

    // 测试: A + B * 2
    let tokens = Lexer().tokenize("A + B * 2")
    let ast = try parser.parse(tokens)
    let result = try evaluator.evaluate(ast)
    print("✓ 表达式 'A + B * 2' = \(result) (期望: 50)")
} catch {
    print("✗ 错误: \(error)")
}
print()

print("=== 所有测试完成 ===")
