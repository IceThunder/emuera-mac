//
//  ExpressionEngineTests.swift
//  EmueraCoreTests
//
//  测试表达式引擎和持久化功能
//

import XCTest
@testable import EmueraCore

final class ExpressionEngineTests: XCTestCase {

    // MARK: - 表达式解析测试

    func testBasicArithmetic() {
        let parser = ExpressionParser()
        let eval = ExpressionEvaluator(variableData: VariableData())

        // 测试: 10 + 20 * 3 = 70
        let lexer = LexerHelper()
        let tokens = lexer.tokenize("10+20*3")
        let node = try! parser.parse(tokens)
        let result = try! eval.evaluate(node)

        XCTAssertEqual(result, .integer(70))
    }

    func testParentheses() {
        let parser = ExpressionParser()
        let eval = ExpressionEvaluator(variableData: VariableData())

        // 测试: (10+20)*3 = 90
        let tokens = LexerHelper().tokenize("(10+20)*3")
        let node = try! parser.parse(tokens)
        let result = try! eval.evaluate(node)

        XCTAssertEqual(result, .integer(90))
    }

    // MARK: - 持久化测试

    func testPersistentEnvironment() {
        let executor = SimpleExecutor()

        // 第一次执行：设置变量
        let tokens1 = LexerHelper().tokenize("A = 100")
        let output1 = executor.execute(tokens: tokens1, usePersistentEnv: true)
        XCTAssertTrue(output1.isEmpty)  // 赋值无输出

        // 第二次执行：读取变量
        let tokens2 = LexerHelper().tokenize("PRINT A")
        let output2 = executor.execute(tokens: tokens2, usePersistentEnv: true)

        // 应该输出["100"]
        XCTAssertEqual(output2, ["100"])
    }

    func testMultipleVariableCalculation() {
        let executor = SimpleExecutor()

        // 执行一系列操作
        let script = """
        A = 50
        PRINT A
        B = 75
        A + B
        """

        let tokens = LexerHelper().tokenize(script)
        let outputs = executor.execute(tokens: tokens, usePersistentEnv: true)

        // 期望: ["50", "125"]
        // 但是PRINT A输出50，裸表达式A+B输出125
        XCTAssertEqual(outputs, ["50", "125"])
    }

    func testResetCommand() {
        let executor = SimpleExecutor()

        // 设置变量
        let _ = executor.execute(tokens: LexerHelper().tokenize("X = 42"), usePersistentEnv: true)

        // 重置
        executor.resetPersistentEnv()

        // 读取应该返回0（未定义）
        let tokens = LexerHelper().tokenize("PRINT X")
        let outputs = executor.execute(tokens: tokens, usePersistentEnv: true)

        // 重置后X未定义，应输出0
        XCTAssertEqual(outputs, ["0"])
    }

    // MARK: - 集成测试

    func testScriptEnginePersistence() {
        let engine = ScriptEngine()
        engine.persistentState = true

        // 第一次运行
        let output1 = engine.run("A = 100")
        XCTAssertTrue(output1.isEmpty)

        // 第二次运行同一个引擎
        let output2 = engine.run("PRINT A")
        XCTAssertEqual(output2, ["100"])

        // 重置测试
        engine.reset()
        let output3 = engine.run("PRINT A")
        XCTAssertEqual(output3, ["0"])  // 变量已清除
    }
}

// 辅助类用于创建测试tokens
private class LexerHelper {
    func tokenize(_ source: String) -> [TokenType.Token] {
        // 简化的tokenizer for testing
        var tokens: [TokenType.Token] = []
        let chars = Array(source)
        var i = 0

        while i < chars.count {
            let c = chars[i]

            if c.isWhitespace {
                i += 1
                continue
            }

            if c.isNumber {
                var digits = ""
                while i < chars.count && chars[i].isNumber {
                    digits.append(chars[i])
                    i += 1
                }
                if let value = Int64(digits) {
                    tokens.append(TokenType.Token(type: .integer(value), value: digits))
                }
                continue
            }

            if c.isLetter || c == "$" || c == "%" {
                var ident = ""
                while i < chars.count {
                    let ch = chars[i]
                    if ch.isLetter || ch.isNumber || ch == "_" {
                        ident.append(ch)
                        i += 1
                    } else { break }
                }
                tokens.append(TokenType.Token(type: .variable(ident), value: ident))
                continue
            }

            // Operator
            var matched = false
            if i + 1 < chars.count {
                let two = String([chars[i], chars[i+1]])
                if let op = TokenType.Operator(rawValue: two) {
                    tokens.append(TokenType.Token(type: .operatorSymbol(op), value: two))
                    i += 2
                    matched = true
                }
            }

            if !matched {
                let one = String(c)
                if let op = TokenType.Operator(rawValue: one) {
                    tokens.append(TokenType.Token(type: .operatorSymbol(op), value: one))
                    i += 1
                    matched = true
                }
            }

            if !matched {
                if c == "(" {
                    tokens.append(TokenType.Token(type: .parenthesisOpen, value: "("))
                    i += 1
                } else if c == ")" {
                    tokens.append(TokenType.Token(type: .parenthesisClose, value: ")"))
                    i += 1
                } else {
                    i += 1
                }
            }
        }

        return tokens
    }
}
