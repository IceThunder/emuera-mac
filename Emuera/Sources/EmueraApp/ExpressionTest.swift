//
//  ExpressionTest.swift
//  EmueraApp
//
//  表达式解析器完整测试
//  Created: 2025-12-19
//

import Foundation
import EmueraCore

/// 表达式解析器完整测试
public class ExpressionTest {

    public static func runTests() {
        fputs("=== 表达式解析器测试 ===\n", stderr)
        fputs("Step 1: Creating parser\n", stderr)

        let parser = ExpressionParser()
        fputs("Parser created\n", stderr)

        // 测试1: 基本算术运算
        print("测试1: 基本算术运算")
        let arithmeticTests = [
            ("10 + 20", 30),
            ("10 + 20 * 3", 70),
            ("(10 + 20) * 3", 90),
            ("100 / 10", 10),
            ("15 % 4", 3),
            ("2 ** 3", 8)
        ]

        for (expr, expected) in arithmeticTests {
            do {
                let ast = try parser.parseString(expr)
                print("  ✅ \(expr) -> \(ast.description)")
            } catch {
                print("  ❌ \(expr) - 错误: \(error)")
            }
        }
        print()

        // 测试2: 变量和数组语法
        print("测试2: 变量和数组语法")
        let varTests = [
            "A:5",
            "BASE:0",
            "CFLAG:0:5",
            "RAND(100)",
            "ABS(-5)",
            "A:5 + 10"
        ]

        for expr in varTests {
            do {
                let ast = try parser.parseString(expr)
                print("  ✅ \(expr) -> \(ast.description)")
            } catch {
                print("  ❌ \(expr) - 错误: \(error)")
            }
        }
        print()

        // 测试3: 完整求值
        fputs("Step 2: Creating VariableData\n", stderr)
        let varData = VariableData()

        // Debug: Check array state
        fputs("DEBUG: dataIntegerArray count = \(varData.dataIntegerArray.count)\n", stderr)
        if varData.dataIntegerArray.count > 0x1E {
            fputs("DEBUG: Array at 0x1E (A) count = \(varData.dataIntegerArray[0x1E].count)\n", stderr)
        }

        fputs("Step 3: Setting A=10\n", stderr)
        // Debug: Check token first
        let tokenData = varData.getTokenData()
        if let token = tokenData.getToken("A") {
            fputs("DEBUG: Token for A found: code=\(token.code), baseValue=\(token.code.baseValue), isForbid=\(token.isForbid)\n", stderr)
        } else {
            fputs("DEBUG: Token for A not found\n", stderr)
        }

        // Try to set value
        try? varData.setIntegerToken("A", value: 10)
        fputs("Step 4: Setting B=20\n", stderr)
        try? varData.setIntegerToken("B", value: 20)
        fputs("Step 5: Setting DAY=5\n", stderr)
        try? varData.setIntegerToken("DAY", value: 5)

        // 设置数组值
        try? tokenData.setIntValue("A", value: 30, arguments: [5])  // A:5 = 30
        try? tokenData.setIntValue("BASE", value: 100, arguments: [0])  // BASE:0 = 100
        try? tokenData.setIntValue("CFLAG", value: 999, arguments: [0, 5])  // CFLAG:0:5 = 999

        let evaluator = ExpressionEvaluator(variableData: varData)

        let evalTests = [
            ("10 + 20", 30),
            ("A + B", 30),
            ("DAY * 2", 10),
            ("(A + B) * 2", 60),
            ("A:5", 30),
            ("BASE:0", 100),
            ("CFLAG:0:5", 999),
            ("A:5 + 10", 40)
        ]

        for (expr, expected) in evalTests {
            do {
                let ast = try parser.parseString(expr)
                let result = try evaluator.evaluate(ast)
                if case .integer(let value) = result {
                    if value == expected {
                        print("  ✅ \(expr) = \(value)")
                    } else {
                        print("  ❌ \(expr) = \(value) (期望: \(expected))")
                    }
                } else {
                    print("  ❌ \(expr) = \(result) (期望: \(expected))")
                }
            } catch {
                print("  ❌ \(expr) - 错误: \(error)")
            }
        }

        print("\n=== 测试完成 ===")
    }
}
