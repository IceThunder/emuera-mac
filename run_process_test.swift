#!/usr/bin/env swift

import EmueraCore

// 运行Process系统集成测试
print("🧪 Process系统集成测试")
print("=" + String(repeating: "=", count: 50))

let tester = ProcessTest()

// 运行集成测试
print("\n【集成测试】")
let integrationResults = tester.runIntegrationTest()
for line in integrationResults {
    print(line)
}

// 运行标准测试
print("\n【标准测试】")
let standardResults = tester.runAllTests()
for line in standardResults {
    print(line)
}

// 运行性能测试
print("\n【性能测试】")
let perfResults = tester.runPerformanceTest()
for line in perfResults {
    print(line)
}

print("\n" + "=" + String(repeating: "=", count: 50))
print("🎉 所有测试完成！")
