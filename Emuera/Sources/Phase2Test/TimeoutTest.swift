//
//  TimeoutTest.swift
//  Phase2Test
//
//  使用超时机制定位挂起点
//

import Foundation
import EmueraCore

func runWithTimeout(_ operation: @escaping () throws -> Void, timeout: TimeInterval = 5.0) {
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "timeout-test")

    group.enter()
    queue.async {
        do {
            try operation()
        } catch {
            print("操作错误: \(error)")
        }
        group.leave()
    }

    let result = group.wait(timeout: .now() + timeout)
    if result == .timedOut {
        print("❌ 操作超时！在 \(timeout) 秒内未完成")
        print("调用栈:")
        Thread.callStackSymbols.forEach { print($0) }
        exit(1)
    } else {
        print("✅ 操作在超时前完成")
    }
}

print("=== TimeoutTest: 开始 ===")
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

print("步骤4: 调用parser.parse()（5秒超时）...")
runWithTimeout({
    let statements = try parser.parse(script)
    print("解析成功，语句数:", statements.count)
}, timeout: 5.0)

print("=== TimeoutTest: 结束 ===")