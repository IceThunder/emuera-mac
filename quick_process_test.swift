import EmueraCore

print("🧪 Process系统快速测试")
print("=" * 50)

// 测试1: 创建Process
let variableData = VariableData()
let tokenData = TokenData(varData: variableData)
let labelDictionary = LabelDictionary()
let process = EmueraCore.Process(tokenData: tokenData, labelDictionary: labelDictionary)

print("✅ 测试1: Process创建成功")

// 测试2: 添加函数标签
let funcLine = FunctionLabelLine(labelName: "TEST1")
labelDictionary.addNonEventLabel("TEST1", funcLine)
print("✅ 测试2: 函数标签添加成功")

// 测试3: 调用函数
do {
    let success = try process.callFunction("TEST1", nil as LogicalLine?)
    if success {
        print("✅ 测试3: 函数调用成功")
    } else {
        print("❌ 测试3: 函数调用失败")
    }
} catch {
    print("❌ 测试3: 错误 - \(error)")
}

// 测试4: 运行脚本
do {
    try process.runScriptProc()
    print("✅ 测试4: 脚本执行完成")
} catch {
    print("❌ 测试4: 错误 - \(error)")
}

// 测试5: 重置
process.reset()
print("✅ 测试5: 重置成功")

// 测试6: 检查状态
print("  - 脚本结束: \(process.scriptEnd)")
print("  - 当前行: \(process.currentLine as Any)")

print("=" * 50)
print("🎉 Process系统基本功能测试完成！")
