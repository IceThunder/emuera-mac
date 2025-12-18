//
//  TokenType.swift
//  EmueraCore
//
//  Token types for script parsing
//  Created on 2025-12-18
//

import Foundation

/// Token types for Emuera script parsing
public enum TokenType: CustomStringConvertible {
    // Keywords
    case keyword(String)
    case command(String)
    case function(String)
    case label(String)      // @LABEL
    case variable(String)   // $VAR, %VAR

    // Literals
    case integer(Int64)
    case string(String)

    // Operators
    case operatorSymbol(Operator)
    case comparator(Comparator)

    // Punctuation
    case comma
    case colon
    case parenthesisOpen
    case parenthesisClose
    case bracketOpen
    case bracketClose

    // Special
    case lineBreak
    case comment
    case whitespace

    // MARK: - Helper enums

    public enum Operator: String {
        case add = "+"
        case subtract = "-"
        case multiply = "*"
        case divide = "/"
        case modulo = "%"
        case power = "**"
        case assign = "="
        case addAssign = "+="
        case subtractAssign = "-="
        case multiplyAssign = "*="
        case divideAssign = "/="
        case equal = "=="
        case notEqual = "!="
        case less = "<"
        case lessEqual = "<="
        case greater = ">"
        case greaterEqual = ">="
        case and = "&&"
        case or = "||"
        case not = "!"
        case bitAnd = "&"
        case bitOr = "|"
        case bitXor = "^"
        case bitNot = "~"
        case shiftLeft = "<<"
        case shiftRight = ">>"
    }

    public enum Comparator: String {
        case equal = "=="
        case notEqual = "!="
        case less = "<"
        case lessEqual = "<="
        case greater = ">"
        case greaterEqual = ">="
    }

    // MARK: - Token

    public struct Token: CustomStringConvertible {
        public let type: TokenType
        public let value: String
        public let position: ScriptPosition?

        public init(type: TokenType, value: String, position: ScriptPosition? = nil) {
            self.type = type
            self.value = value
            self.position = position
        }

        public var description: String {
            let typeStr = String(describing: type)
            if let pos = position {
                return "\(typeStr):\(value)@\(pos.description)"
            }
            return "\(typeStr):\(value)"
        }
    }

    // MARK: - Convenience methods

    public static func fromString(_ str: String) -> TokenType? {
        // Check for operators
        if let op = Operator(rawValue: str) {
            return .operatorSymbol(op)
        }

        // Check for comparators
        if let comp = Comparator(rawValue: str) {
            return .comparator(comp)
        }

        return nil
    }

    // MARK: - CustomStringConvertible
    public var description: String {
        switch self {
        case .keyword(let s): return "keyword(\(s))"
        case .command(let s): return "command(\(s))"
        case .function(let s): return "function(\(s))"
        case .label(let s): return "label(\(s))"
        case .variable(let s): return "variable(\(s))"
        case .integer(let n): return "integer(\(n))"
        case .string(let s): return "string(\(s))"
        case .operatorSymbol(let op): return "operator(\(op.rawValue))"
        case .comparator(let comp): return "comparator(\(comp.rawValue))"
        case .comma: return "comma"
        case .colon: return "colon"
        case .parenthesisOpen: return "parenOpen"
        case .parenthesisClose: return "parenClose"
        case .bracketOpen: return "bracketOpen"
        case .bracketClose: return "bracketClose"
        case .lineBreak: return "lineBreak"
        case .comment: return "comment"
        case .whitespace: return "whitespace"
        }
    }
}