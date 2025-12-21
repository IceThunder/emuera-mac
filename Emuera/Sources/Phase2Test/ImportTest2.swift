//
//  ImportTest2.swift
//  Phase2Test
//
//  测试EmueraCore导入是否导致挂起
//

import Foundation

func debugPrint(_ message: String) {
    fputs(message + "\n", stderr)
    fflush(stderr)
}

debugPrint("步骤1: 开始")

// 立即输出，不等待
let start = Date()

debugPrint("步骤2: 准备导入EmueraCore...")

// 检查是否有循环依赖
import EmueraCore

let afterImport = Date()
debugPrint("步骤3: 导入完成，耗时: \(afterImport.timeIntervalSince(start))秒")

// 检查是否是ExecutionContext扩展导致的问题
debugPrint("步骤4: 检查ExecutionContext类...")
let context = ExecutionContext()
debugPrint("ExecutionContext创建完成")

// 检查是否是storageLock导致的问题
debugPrint("步骤5: 检查FunctionSystem扩展...")
// 尝试访问扩展属性
let hasStack = context.functionStack
debugPrint("functionStack访问完成: \(hasStack.count)")

// 检查是否是FunctionRegistry导致的问题
debugPrint("步骤6: 检查FunctionRegistry...")
let registry = context.functionRegistry
debugPrint("FunctionRegistry访问完成")

debugPrint("步骤7: 测试完成")
