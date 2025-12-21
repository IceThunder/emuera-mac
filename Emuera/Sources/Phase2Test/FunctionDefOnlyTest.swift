//
//  FunctionDefOnlyTest.swift
//  Phase2Test
//
//  测试函数定义解析
//

import Foundation
import EmueraCore

print("=== FunctionDefOnlyTest: 开始 ===")
print("步骤1: 创建ScriptParser...")

let parser = ScriptParser()
print("步骤2: ScriptParser创建完成")

print("步骤3: 准备解析函数定义脚本...")
let script = """
@ADD, a, b
RETURN a + b
"""
print("脚本:")
print(script)

print("步骤4: 调用parser.parse()...")
do {
    let statements = try parser.parse(script)
    print("步骤5: 解析完成，语句数:", statements.count)
    for stmt in statements {
        print("  语句类型:", type(of: stmt))
        if let funcDef = stmt as? FunctionDefinitionStatement {
            print("  函数名:", funcDef.definition.name)
            print("  参数:", funcDef.definition.parameters.map { $0.name })
            print("  体语句数:", funcDef.definition.body.count)
        }
    }
} catch {
    print("步骤5: 解析错误:", error)
}
print("=== FunctionDefOnlyTest: 结束 ===")