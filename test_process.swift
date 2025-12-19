#!/usr/bin/env swift

// Standalone Process system test
// Run with: swift test_process.swift

import Foundation

// Import from local package
import EmueraCore

print("🧪 Process系统集成测试")
print("=" + String(repeating: "=", count: 60))
print()

let tester = ProcessTest()

// Run integration tests
print("【集成测试 - Process + StatementExecutor】")
let integrationResults = tester.runIntegrationTest()
for line in integrationResults {
    print(line)
}
print()

print("=" + String(repeating: "=", count: 60))
print("测试完成！")
