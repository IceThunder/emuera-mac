//
//  Word.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/19.
//

import Foundation

/// Base class for all word types in tokenization
public class Word: CustomStringConvertible {
    public var isMacro: Bool = false

    public func setAsMacro() {
        isMacro = true
    }

    public var description: String {
        return "\(type(of: self))"
    }
}

/// Null/empty word token
public final class NullWord: Word {
    public override var description: String { return "/null/" }
}

/// Identifier word (variable names, function names, etc.)
public final class IdentifierWord: Word {
    public let code: String

    public init(_ code: String) {
        self.code = code
    }

    public override var description: String { return code }
}

/// Integer literal word
public final class LiteralIntegerWord: Word {
    public let value: Int64

    public init(_ value: Int64) {
        self.value = value
    }

    public override var description: String { return "\(value)" }
}

/// String literal word
public final class LiteralStringWord: Word {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public override var description: String { return "\"\(value)\"" }
}

/// Operator word
public final class OperatorWord: Word {
    public let opCode: OperatorCode

    public init(_ opCode: OperatorCode) {
        self.opCode = opCode
    }

    public override var description: String { return opCode.rawValue }
}

/// Symbol word (single character symbols)
public final class SymbolWord: Word {
    public let symbol: Character

    public init(_ symbol: Character) {
        self.symbol = symbol
    }

    public override var description: String { return String(symbol) }
}

/// Macro argument word
public final class MacroWord: Word {
    public let number: Int

    public init(_ number: Int) {
        self.number = number
    }

    public override var description: String { return "Arg\(number)" }
}

/// Operator code enum (simplified from C# version)
public enum OperatorCode: String, CaseIterable {
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
