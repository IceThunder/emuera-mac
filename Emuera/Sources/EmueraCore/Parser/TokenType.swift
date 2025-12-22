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

    // Function directives (Phase 2)
    case directive(String)  // #DIM, #DIMS, #FUNCTION, #FUNCTIONS

    // SELECTCASE statement (Phase 3)
    case selectcase
    case caseKeyword
    case caseElse
    case endSelect

    // TRY/CATCH exception handling (Phase 3)
    case tryKeyword
    case catchKeyword
    case endTry
    case tryCall
    case tryJump
    case tryGoto
    case tryCallList
    case tryJumpList
    case tryGotoList

    // PRINTDATA/DATALIST (Phase 3)
    case printData
    case dataList
    case endList
    case endData

    // DO-LOOP循环 (Phase 3)
    case doKeyword
    case loopKeyword

    // Special
    case lineBreak
    case comment
    case whitespace

    // MARK: - Helper enums

    public enum Operator: String, CaseIterable {
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

        /// 运算符优先级 (数值越大优先级越高)
        public var precedence: Int {
            switch self {
            case .power: return 10  // **
            case .not, .bitNot: return 9  // !, ~ (一元运算符，暂不实现)
            case .multiply, .divide, .modulo: return 8  // *, /, %
            case .add, .subtract: return 7  // +, -
            case .shiftLeft, .shiftRight: return 6  // <<, >>
            case .bitAnd: return 5  // &
            case .bitXor: return 4  // ^
            case .bitOr: return 3  // |
            case .equal, .notEqual, .less, .lessEqual, .greater, .greaterEqual: return 2  // 比较
            case .and: return 1  // &&
            case .or: return 0  // ||
            case .assign, .addAssign, .subtractAssign, .multiplyAssign, .divideAssign: return -1  // 赋值
            }
        }

        /// 是否是赋值类运算符
        public var isAssignment: Bool {
            switch self {
            case .assign, .addAssign, .subtractAssign, .multiplyAssign, .divideAssign:
                return true
            default:
                return false
            }
        }

        /// 是否是二元运算符（需要左右操作数）
        public var isBinary: Bool {
            return !isAssignment && self != .not && self != .bitNot
        }
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
        case .directive(let s): return "directive(\(s))"
        case .selectcase: return "selectcase"
        case .caseKeyword: return "caseKeyword"
        case .caseElse: return "caseElse"
        case .endSelect: return "endSelect"
        case .tryKeyword: return "tryKeyword"
        case .catchKeyword: return "catchKeyword"
        case .endTry: return "endTry"
        case .tryCall: return "tryCall"
        case .tryJump: return "tryJump"
        case .tryGoto: return "tryGoto"
        case .tryCallList: return "tryCallList"
        case .tryJumpList: return "tryJumpList"
        case .tryGotoList: return "tryGotoList"
        case .printData: return "printData"
        case .dataList: return "dataList"
        case .endList: return "endList"
        case .endData: return "endData"
        case .doKeyword: return "doKeyword"
        case .loopKeyword: return "loopKeyword"
        case .lineBreak: return "lineBreak"
        case .comment: return "comment"
        case .whitespace: return "whitespace"
        }
    }
}