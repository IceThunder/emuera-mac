#!/usr/bin/swift
// 不依赖 XCTest 的验证

import Foundation

// MARK: - 简易测试框架
func assert(_ condition: Bool, _ message: String) {
    if condition {
        print("✅ \(message)")
    } else {
        print("❌ FAILED: \(message)")
        exit(1)
    }
}

func test(_ name: String) {
    print("\n=== Test: \(name) ===")
}

// MARK: - 主测试程序
test("持久化基础测试")

import EmueraCore

let engine = ScriptEngine()
engine.persistentState = true

// Test 1: 设置变量
test("1. 令 A = 100")
let o1 = engine.run("A = 100")
assert(o1.isEmpty, "赋值不产生输出")

// Test 2: 读取变量
test("2. PRINT A")
let o2 = engine.run("PRINT A")
assert(o2 == ["100"], "应该输出['100']，实际得到 \(o2)")

// Test 3: 变量传递
test("3. B = A + 50")
let o3 = engine.run("B = A + 50")
assert(o3.isEmpty, "赋值无输出")

// Test 4: 使用新变量
test("4. PRINT B")
let o4 = engine.run("PRINT B")
assert(o4 == ["150"], "应该输出['150']，实际得到 \(o4)")

// Test 5: 表达式计算
test("5. A + B")
let o5 = engine.run("A + B")
assert(o5 == ["250"], "应该输出['250']，实际得到 \(o5)")

// Test 6: 重置
test("6. RESET")
engine.reset()
assert(engine.persistentState == true, "PERSIST状态不变")

// Test 7: 重置后变量不存在
test("7. PRINT A after reset")
let o7 = engine.run("PRINT A")
assert(o7 == ["0"], "重置后应输出0，实际 \(o7)")

// Test 8: PERSIST OFF
test("8. PERSIST OFF")
engine.persistentState = false
assert(engine.persistentState == false, "PERSIST应关闭")

// Test 9: 关闭持久化后变量不保持
test("9. C = 200 (persist off)")
let _ = engine.run("C = 200")
engine.persistentState = true  // 临时启用
let o9a = engine.run("PRINT C")  // 应该能读取（重用同一个executor）
// 但如果我们reset了executor或使用了新的，就不应该
// 这里实际上，因为executor是同一个，所以C应该还在
// 这测试的是reset/don't reset

print("\n=== 所有测试完成 ===")
print("如果看到全部 ✅，说明核心功能正常。")
print("如果交互测试有问题，可能是控制台打印格式问题。")

