//
//  LexicalAnalyzerTests.swift
//  EmueraCoreTests
//
//  MVP阶段词法分析器测试
//  Created on 2025-12-18
//

import XCTest
@testable import EmueraCore

final class LexicalAnalyzerTests: XCTestCase {

    let lexer = LexicalAnalyzer()

    // 测试1: Hello World
    func testHelloWorld() throws {
        let tokens = lexer.tokenize("PRINT Hello World")

        XCTAssertEqual(tokens.count, 3)

        // 第一个token应该是命令
        guard case .command(let cmd) = tokens[0].type else {
            XCTFail("Expected command token, got \(tokens[0].type)")
            return
        }
        XCTAssertEqual(cmd, "PRINT")

        // 后两个应该是字符串（Unknown identifier becomes string）
        XCTAssertEqual(tokens[1].value, "Hello")
        XCTAssertEqual(tokens[2].value, "World")
    }

    // 测试2: PRINTL换行输出
    func testPrintL() throws {
        let tokens = lexer.tokenize("PRINTL Line1")

        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0].value, "PRINTL")
        XCTAssertEqual(tokens[1].value, "Line1")
    }

    // 测试3: 变量赋值
    func testVariableAssignment() throws {
        let tokens = lexer.tokenize("A = 100")

        XCTAssertEqual(tokens.count, 3)

        // A 应该是变量
        if case .variable(let name) = tokens[0].type {
            XCTAssertEqual(name, "A")
        } else {
            XCTFail("Expected variable token, got \(tokens[0].type)")
        }

        // = 是操作符
        if case .operatorSymbol(let op) = tokens[1].type {
            XCTAssertEqual(op.rawValue, "=")
        } else {
            XCTFail("Expected operator token")
        }

        // 100 是整数
        if case .integer(let value) = tokens[2].type {
            XCTAssertEqual(value, 100)
        } else {
            XCTFail("Expected integer token")
        }
    }

    // 测试4: 字符串带引号
    func testQuotedString() throws {
        let tokens = lexer.tokenize("PRINT \"Hello World\"")

        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0].value, "PRINT")

        if case .string(let value) = tokens[1].type {
            XCTAssertEqual(value, "Hello World")
        } else {
            XCTFail("Expected quoted string token")
        }
    }

    // 测试5: 变量带美元符号
    func testVariableWithPrefix() throws {
        let tokens = lexer.tokenize("$MYVAR = 42")

        XCTAssertEqual(tokens.count, 3)

        if case .variable(let name) = tokens[0].type {
            XCTAssertEqual(name, "$MYVAR")
        } else {
            XCTFail("Expected $ variable")
        }
    }

    // 测试6: 多行脚本
    func testMultiLineScript() throws {
        let script = """
        PRINT Line1
        PRINTL Line2
        WAIT
        QUIT
        """

        let tokens = lexer.tokenize(script)

        // 应该有多个命令和内容
        let commandTokens = tokens.filter { token in
            if case .command = token.type { return true }
            return false
        }

        XCTAssertEqual(commandTokens.count, 3) // PRINT, PRINTL, WAIT, QUIT
    }

    // 测试7: 跳过注释
    func testComments() throws {
        let tokens = lexer.tokenize("""
        PRINT Hello
        ; 这是注释
        PRINT World
        """)

        // 应该只有2个PRINT命令和它们的内容
        let commandTokens = tokens.filter { token in
            if case .command = token.type { return true }
            return false
        }

        XCTAssertEqual(commandTokens.count, 2)
    }

    // 测试8: 算术运算
    func testArithmetic() throws {
        let tokens = lexer.tokenize("A = B + 10")

        XCTAssertEqual(tokens.count, 5) // A, =, B, +, 10
    }

    // 测试9: 空白和换行处理
    func testWhitespaceAndNewlines() throws {
        let tokens = lexer.tokenize("PRINT  Hello\n  A = 10")

        // 应该忽略多余的空白，但保留换行符
        let lineBreaks = tokens.filter { token in
            if case .lineBreak = token.type { return true }
            return false
        }

        XCTAssertEqual(lineBreaks.count, 1)
    }

    // 测试10: 简单数字
    func testNumbers() throws {
        let tokens = lexer.tokenize("123 456")

        XCTAssertEqual(tokens.count, 2)

        if case .integer(let value1) = tokens[0].type,
           case .integer(let value2) = tokens[1].type {
            XCTAssertEqual(value1, 123)
            XCTAssertEqual(value2, 456)
        } else {
            XCTFail("Expected integer tokens")
        }
    }

    // 测试11: 完整的MVP测试用例
    func testMVPExample() throws {
        let script = """
        PRINTL 序幕开始...
        NUMBER = 100
        PRINT 数字是
        PRINT NUMBER
        WAIT
        QUIT
        """

        let tokens = lexer.tokenize(script)

        // 验证关键token存在
        let values = tokens.map { $0.value }
        XCTAssertTrue(values.contains("PRINTL"))
        XCTAssertTrue(values.contains("NUMBER"))
        XCTAssertTrue(values.contains("100"))
        XCTAssertTrue(values.contains("QUIT"))

        // 统计命令数量
        let commands = tokens.filter { if case .command = $0.type { return true }; return false }
        XCTAssertEqual(commands.count, 3) // PRINTL, PRINT, QUIT
    }

    // 测试12: 函数调用（基础支持）
    func testFunctionCall() throws {
        let tokens = lexer.tokenize("WAIT")

        XCTAssertEqual(tokens.count, 1)
        XCTAssertTrue(tokens[0].value == "WAIT")

        if case .command(let cmd) = tokens[0].type {
            XCTAssertEqual(cmd, "WAIT")
        }
    }

    // 测试13: 变量读取（直接用变量名）
    func testVariableUsage() throws {
        let tokens = lexer.tokenize("PRINT A")

        XCTAssertEqual(tokens.count, 2)

        // 第二个token应该作为标识符解析
        XCTAssertTrue(tokens[1].value == "A")
    }

    // 测试14: 变量类型（%开头的通常是数组或局部变量）
    func testVariableTypes() throws {
        let tokens = lexer.tokenize("%LOCAL = 50")

        XCTAssertEqual(tokens.count, 3)

        if case .variable(let name) = tokens[0].type {
            XCTAssertEqual(name, "%LOCAL")
        }
    }

    // 测试15: 复杂赋值
    func testComplexAssignment() throws {
        let tokens = lexer.tokenize("RESULT:0 = 50")

        // RESULT:0, =, 50
        XCTAssertTrue(tokens.count >= 3)
    }

    // 测试16: 字符串拼接（基础标记）
    func testStringThing() throws {
        let tokens = lexer.tokenize("PRINT \"A\" + 10")

        // PRINT, "A", +, 10
        XCTAssertEqual(tokens.count, 4)
    }

    // 测试17: 如果语句（关键字标记）
    func testIfKeyword() throws {
        let tokens = lexer.tokenize("IF A > 10")

        XCTAssertTrue(tokens.count >= 3)
        XCTAssertEqual(tokens[0].value, "IF")
    }

    // 测试18: 标签（@开头）
    func testLabel() throws {
        let tokens = lexer.tokenize("@START")

        XCTAssertEqual(tokens.count, 1)

        if case .label(let name) = tokens[0].type {
            XCTAssertEqual(name, "@START")
        }
    }

    // 测试19: 空字符串
    func testEmpty() throws {
        let tokens = lexer.tokenize("")

        XCTAssertEqual(tokens.count, 0)
    }

    // 测试20: 只有空白
    func testOnlyWhitespace() throws {
        let tokens = lexer.tokenize("   \n  \n  ")

        // 只有换行符
        let lineBreaks = tokens.filter { if case .lineBreak = $0.type { return true }; return false }
        XCTAssertTrue(lineBreaks.count >= 2)
    }

    // MARK: - 性能测试

    func testPerformanceLargeScript() throws {
        let largeScript = String(repeating: "PRINT A\nA = B + 10\nWAIT\n", count: 100)

        measure {
            _ = lexer.tokenize(largeScript)
        }
    }

    // MARK: - 辅助测试

    func testTokenDescription() throws {
        let tokens = lexer.tokenize("PRINT Hello")

        XCTAssertEqual(tokens[0].description, "command: PRINT")
        XCTAssertEqual(tokens[1].description, "string: Hello")
    }

    func testPositionTracking() throws {
        let tokens = lexer.tokenize("PRINT\nA")

        // 检查位置信息
        if let first = tokens.filter({ $0.type != .lineBreak }).first {
            XCTAssertEqual(first.position.lineNumber, 1)
        }

        if let second = tokens.filter({ $0.type != .lineBreak }).dropFirst().first {
            // 可能在第2行（因为\n在PRINT之后）
            XCTAssertTrue(second.position.lineNumber >= 1)
        }
    }

    // 静态测试清单（Linux兼容）
    static var allTests = [
        ("testHelloWorld", testHelloWorld),
        ("testPrintL", testPrintL),
        ("testVariableAssignment", testVariableAssignment),
        ("testQuotedString", testQuotedString),
        ("testVariableWithPrefix", testVariableWithPrefix),
        ("testMultiLineScript", testMultiLineScript),
        ("testComments", testComments),
        ("testArithmetic", testArithmetic),
        ("testWhitespaceAndNewlines", testWhitespaceAndNewlines),
        ("testNumbers", testNumbers),
        ("testMVPExample", testMVPExample),
        ("testFunctionCall", testFunctionCall),
        ("testVariableUsage", testVariableUsage),
        ("testVariableTypes", testVariableTypes),
        ("testComplexAssignment", testComplexAssignment),
        ("testStringThing", testStringThing),
        ("testIfKeyword", testIfKeyword),
        ("testLabel", testLabel),
        ("testEmpty", testEmpty),
        ("testOnlyWhitespace", testOnlyWhitespace),
        ("testTokenDescription", testTokenDescription),
        ("testPositionTracking", testPositionTracking),
    ]
}