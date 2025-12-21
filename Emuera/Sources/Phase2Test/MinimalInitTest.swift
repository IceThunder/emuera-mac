//
//  MinimalInitTest.swift
//  Phase2Test
//
//  测试最简单的初始化
//

import Foundation
import EmueraCore

print("=== MinimalInitTest: 开始 ===")
print("步骤1: 准备创建ScriptParser...")

let parser = ScriptParser()
print("步骤2: ScriptParser创建完成")

print("步骤3: 准备创建ExecutionContext...")
let context = ExecutionContext()
print("步骤4: ExecutionContext创建完成")

print("=== MinimalInitTest: 结束 ===")
