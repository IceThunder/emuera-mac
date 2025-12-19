//
//  ExpressionParser.swift
//  EmueraCore
//
//  表达式解析器 - 支持算术运算、变量引用和字符串操作
//  Created: 2025-12-18
//

import Foundation

// MARK: - AST节点定义

/// 表达式抽象语法树节点
public indirect enum ExpressionNode: CustomStringConvertible {
    case integer(Int64)
    case string(String)
    case variable(String)
    case arrayAccess(base: String, indices: [ExpressionNode])  // A:5, BASE:0, CDFLAG:0:5
    case functionCall(name: String, arguments: [ExpressionNode])  // RAND(100), ABS(-5)
    case binary(op: TokenType.Operator, left: ExpressionNode, right: ExpressionNode)

    public var description: String {
        switch self {
        case .integer(let value): return "\(value)"
        case .string(let value): return "\"\(value)\""
        case .variable(let name): return "var(\(name))"
        case .arrayAccess(let base, let indices):
            let idxStr = indices.map { $0.description }.joined(separator: ", ")
            return "\(base)[\(idxStr)]"
        case .functionCall(let name, let args):
            let argStr = args.map { $0.description }.joined(separator: ", ")
            return "\(name)(\(argStr))"
        case .binary(let op, let left, let right):
            return "(\(left.description) \(op.rawValue) \(right.description))"
        }
    }

    /// 判断节点类型（用于类型检查）
    public var nodeType: String {
        switch self {
        case .integer: return "integer"
        case .string: return "string"
        case .variable: return "variable"
        case .arrayAccess: return "arrayAccess"
        case .functionCall: return "functionCall"
        case .binary: return "binary"
        }
    }
}

// MARK: - 表达式解析器

/// 表达式解析器
/// 使用递归下降算法 + 运算符优先级
public class ExpressionParser {

    private var tokens: [TokenType.Token] = []
    private var currentIndex: Int = 0

    public init() {}

    /// 解析Token序列，返回表达式AST
    public func parse(_ tokens: [TokenType.Token]) throws -> ExpressionNode {
        self.tokens = tokens.filter {
            // 移除空白、换行和注释，保留有意义的token
            switch $0.type {
            case .whitespace, .lineBreak, .comment: return false
            default: return true
            }
        }
        self.currentIndex = 0

        guard !self.tokens.isEmpty else {
            throw ExpressionParseError.emptyExpression
        }

        let result = try parseExpression(minPrecedence: 0)

        // 确保所有token都被消耗 - 使用过滤后的tokens进行检查
        if currentIndex < self.tokens.count {
            throw ExpressionParseError.unexpectedToken(self.tokens[currentIndex])
        }

        return result
    }

    // MARK: - 核心解析算法 (递归下降 + 运算符优先级)

    /// 解析表达式
    /// - Parameter minPrecedence: 最小优先级，低于此优先级的运算符不解析
    private func parseExpression(minPrecedence: Int) throws -> ExpressionNode {
        // 1. 解析左侧操作数
        var left = try parsePrimary()

        // 2. 循环处理二元运算符 (Prim's Algorithm)
        while currentIndex < tokens.count {
            // 检查当前token是否为运算符
            guard case .operatorSymbol(let op) = tokens[currentIndex].type,
                  op.isBinary else {
                break
            }

            // 检查优先级
            guard op.precedence >= minPrecedence else {
                break
            }

            // 获取运算符并前进
            currentIndex += 1

            // 递归解析右侧表达式 (优先级: 当前优先级 + 1，避免左结合问题)
            let right = try parseExpression(minPrecedence: op.precedence + 1)

            // 构建二元节点
            left = .binary(op: op, left: left, right: right)
        }

        return left
    }

    /// 解析主要表达式 (数值、字符串、变量、括号表达式、数组访问、函数调用)
    private func parsePrimary() throws -> ExpressionNode {
        guard currentIndex < tokens.count else {
            throw ExpressionParseError.unexpectedEnd
        }

        let token = tokens[currentIndex]

        switch token.type {
        case .integer(let value):
            currentIndex += 1
            return .integer(value)

        case .string(let value):
            currentIndex += 1
            return .string(value)

        case .variable(let name):
            currentIndex += 1

            // 检查后续token以确定是变量、数组访问还是函数调用
            if currentIndex < tokens.count {
                let nextToken = tokens[currentIndex]

                // 函数调用: RAND(100)
                if case .parenthesisOpen = nextToken.type {
                    currentIndex += 1
                    let arguments = try parseArgumentList()
                    return .functionCall(name: name, arguments: arguments)
                }

                // 数组访问: A:5 或 BASE:0
                if case .colon = nextToken.type {
                    currentIndex += 1
                    let indices = try parseArrayIndices()
                    return .arrayAccess(base: name, indices: indices)
                }
            }

            // 普通变量
            return .variable(name)

        case .parenthesisOpen:
            currentIndex += 1
            let expr = try parseExpression(minPrecedence: 0)
            guard currentIndex < tokens.count,
                  case .parenthesisClose = tokens[currentIndex].type else {
                throw ExpressionParseError.missingClosingParenthesis
            }
            currentIndex += 1
            return expr

        case .command(let name):
            // 命令作为变量处理
            currentIndex += 1
            return .variable(name)

        default:
            throw ExpressionParseError.invalidToken(token)
        }
    }

    /// 解析函数调用的参数列表: (100, 200)
    private func parseArgumentList() throws -> [ExpressionNode] {
        var arguments: [ExpressionNode] = []

        // 空参数列表
        if currentIndex < tokens.count,
           case .parenthesisClose = tokens[currentIndex].type {
            currentIndex += 1
            return arguments
        }

        // 解析第一个参数
        arguments.append(try parseExpression(minPrecedence: 0))

        // 解析后续参数
        while currentIndex < tokens.count {
            let token = tokens[currentIndex]

            if case .comma = token.type {
                currentIndex += 1
                arguments.append(try parseExpression(minPrecedence: 0))
            } else if case .parenthesisClose = token.type {
                currentIndex += 1
                break
            } else {
                throw ExpressionParseError.unexpectedToken(token)
            }
        }

        return arguments
    }

    /// 解析数组索引: 5, 0:5
    private func parseArrayIndices() throws -> [ExpressionNode] {
        var indices: [ExpressionNode] = []

        // 第一个索引
        indices.append(try parseExpression(minPrecedence: 0))

        // 检查是否有更多索引（2D/3D数组）
        while currentIndex < tokens.count {
            let token = tokens[currentIndex]

            if case .colon = token.type {
                currentIndex += 1
                indices.append(try parseExpression(minPrecedence: 0))
            } else {
                break
            }
        }

        return indices
    }

    // MARK: - 便捷方法

    /// 解析字符串表达式
    public func parseString(_ expression: String) throws -> ExpressionNode {
        let lexer = Lexer()
        let tokens = lexer.tokenize(expression)
        return try parse(tokens)
    }
}

// MARK: - 错误定义

public enum ExpressionParseError: Error, LocalizedError {
    case emptyExpression
    case unexpectedToken(TokenType.Token)
    case unexpectedEnd
    case missingClosingParenthesis
    case invalidToken(TokenType.Token)
    case unknownOperator(String)

    public var errorDescription: String? {
        switch self {
        case .emptyExpression:
            return "表达式为空"
        case .unexpectedToken(let token):
            return "意外的token: \(token.description)"
        case .unexpectedEnd:
            return "表达式意外结束"
        case .missingClosingParenthesis:
            return "缺少右括号 )"
        case .invalidToken(let token):
            return "无效的表达式token: \(token.description)"
        case .unknownOperator(let op):
            return "未知运算符: \(op)"
        }
    }
}

// MARK: - 词法分析器封装 (用于简单解析)

/// 临时的简单词法分析器，用于表达式字符串解析
/// 注意: 这里使用简化的词法分析，不依赖完整LexicalAnalyzer
private class Lexer {
    func tokenize(_ source: String) -> [TokenType.Token] {
        var tokens: [TokenType.Token] = []
        let chars = Array(source)
        var i = 0

        while i < chars.count {
            let c = chars[i]

            // 空白
            if c.isWhitespace {
                i += 1
                continue
            }

            // 数字
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

            // 字符串
            if c == "\"" {
                i += 1
                var str = ""
                while i < chars.count && chars[i] != "\"" {
                    str.append(chars[i])
                    i += 1
                }
                if i < chars.count {
                    i += 1  // 跳过 closing "
                }
                tokens.append(TokenType.Token(type: .string(str), value: str))
                continue
            }

            // 变量 (标识符)
            if c.isLetter || c == "$" || c == "%" || c == "@" {
                var ident = ""
                while i < chars.count {
                    let ch = chars[i]
                    if ch.isLetter || ch.isNumber || ch == "_" || ch == "$" || ch == "%" || ch == "@" {
                        ident.append(ch)
                        i += 1
                    } else {
                        break
                    }
                }

                // 检查是否是已知的运算符 (注意: true/false/null 等可能是关键字)
                if let op = TokenType.Operator(rawValue: ident) {
                    tokens.append(TokenType.Token(type: .operatorSymbol(op), value: ident))
                } else if ["true", "false", "null"].contains(ident.lowercased()) {
                    // 特殊常量
                    if ident.lowercased() == "true" {
                        tokens.append(TokenType.Token(type: .integer(1), value: "1"))
                    } else if ident.lowercased() == "false" {
                        tokens.append(TokenType.Token(type: .integer(0), value: "0"))
                    } else {
                        tokens.append(TokenType.Token(type: .integer(0), value: "0"))
                    }
                } else {
                    // 变量引用
                    tokens.append(TokenType.Token(type: .variable(ident), value: ident))
                }
                continue
            }

            // 运算符
            var matched = false

            // 尝试匹配两字符运算符
            if i + 1 < chars.count {
                let twoChar = String([chars[i], chars[i+1]])
                if let op = TokenType.Operator(rawValue: twoChar) {
                    tokens.append(TokenType.Token(type: .operatorSymbol(op), value: twoChar))
                    i += 2
                    matched = true
                } else if TokenType.Comparator(rawValue: twoChar) != nil {
                    // 比较器也是运算符的一种，这里统一处理为operator
                    tokens.append(TokenType.Token(type: .operatorSymbol(TokenType.Operator(rawValue: twoChar) ?? .equal), value: twoChar))
                    i += 2
                    matched = true
                }
            }

            // 单字符运算符
            if !matched {
                let oneChar = String(c)
                if let op = TokenType.Operator(rawValue: oneChar) {
                    tokens.append(TokenType.Token(type: .operatorSymbol(op), value: oneChar))
                    i += 1
                    matched = true
                } else if TokenType.Comparator(rawValue: oneChar) != nil {
                    tokens.append(TokenType.Token(type: .operatorSymbol(TokenType.Operator(rawValue: oneChar) ?? .equal), value: oneChar))
                    i += 1
                    matched = true
                }
            }

            // 标点符号
            if !matched {
                switch c {
                case "(":
                    tokens.append(TokenType.Token(type: .parenthesisOpen, value: "("))
                    i += 1
                case ")":
                    tokens.append(TokenType.Token(type: .parenthesisClose, value: ")"))
                    i += 1
                case ",":
                    tokens.append(TokenType.Token(type: .comma, value: ","))
                    i += 1
                case ":":
                    tokens.append(TokenType.Token(type: .colon, value: ":"))
                    i += 1
                case "[":
                    tokens.append(TokenType.Token(type: .bracketOpen, value: "["))
                    i += 1
                case "]":
                    tokens.append(TokenType.Token(type: .bracketClose, value: "]"))
                    i += 1
                default:
                    i += 1  // 跳过未知字符
                }
            }
        }

        return tokens
    }
}
