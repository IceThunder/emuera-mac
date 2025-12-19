//
//  ProcessIntegrationTest.swift
//  EmueraApp
//
//  Process系统与StatementExecutor集成测试
//  直接运行以验证完整流程
//  Created: 2025-12-19
//

import Foundation
import EmueraCore

/// 运行Process系统集成测试
public func runProcessIntegrationTests() {
    print("🧪 Process系统集成测试")
    print("=" + String(repeating: "=", count: 60))
    print()

    let tester = ProcessTest()

    // 1. 运行集成测试（使用StatementExecutor）
    print("【集成测试 - Process + StatementExecutor】")
    print()
    let integrationResults = tester.runIntegrationTest()
    for line in integrationResults {
        print(line)
    }
    print()

    // 2. 运行标准测试
    print("【标准测试 - 函数调用栈】")
    print()
    let standardResults = tester.runAllTests()
    for line in standardResults {
        print(line)
    }
    print()

    // 3. 运行性能测试
    print("【性能测试】")
    print()
    let perfResults = tester.runPerformanceTest()
    for line in perfResults {
        print(line)
    }
    print()

    print("=" + String(repeating: "=", count: 60))
    print("🎉 所有Process系统测试完成！")
}
