//
//  ImportOnlyTest.swift
//  Phase2Test
//
//  测试仅导入EmueraCore是否会导致挂起
//

import Foundation

print("=== ImportOnlyTest: 开始 ===")
print("步骤1: 准备导入EmueraCore...")

// 延迟导入，看是否是导入导致的问题
import EmueraCore

print("步骤2: EmueraCore导入完成")
print("步骤3: 调用logDebug...")

logDebug("测试日志")

print("步骤4: logDebug调用完成")
print("=== ImportOnlyTest: 结束 ===")