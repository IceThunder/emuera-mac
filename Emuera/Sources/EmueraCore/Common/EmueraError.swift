//
//  EmueraError.swift
//  EmueraCore
//
//  Compatibility layer for Emuera engine errors
//  Created on 2025-12-18
//

import Foundation

/// Emuera运行时错误类型
public enum EmueraError: Error, LocalizedError {
    case scriptParseError(message: String, position: ScriptPosition?)
    case runtimeError(message: String, position: ScriptPosition?)
    case fileNotFoundError(path: String)
    case invalidSyntax(message: String)
    case variableNotFound(name: String)
    case functionNotFound(name: String)
    case typeMismatch(expected: String, actual: String)
    case divisionByZero
    case invalidOperation(message: String)
    case duplicateMacro(name: String)
    case duplicateVariable(name: String)
    case duplicateFunction(name: String)
    case reservedNameUsed(name: String)
    case headerFileError(message: String, position: ScriptPosition?)

    public var errorDescription: String? {
        switch self {
        case .scriptParseError(let message, let position):
            if let pos = position {
                return "Parse Error at \(pos.filename):\(pos.lineNumber): \(message)"
            }
            return "Parse Error: \(message)"

        case .runtimeError(let message, let position):
            if let pos = position {
                return "Runtime Error at \(pos.filename):\(pos.lineNumber): \(message)"
            }
            return "Runtime Error: \(message)"

        case .fileNotFoundError(let path):
            return "File not found: \(path)"

        case .invalidSyntax(let message):
            return "Invalid syntax: \(message)"

        case .variableNotFound(let name):
            return "Variable not found: \(name)"

        case .functionNotFound(let name):
            return "Function not found: \(name)"

        case .typeMismatch(let expected, let actual):
            return "Type mismatch: expected \(expected), got \(actual)"

        case .divisionByZero:
            return "Division by zero"

        case .invalidOperation(let message):
            return "Invalid operation: \(message)"
        case .duplicateMacro(let name):
            return "Duplicate macro definition: \(name)"
        case .duplicateVariable(let name):
            return "Duplicate variable definition: \(name)"
        case .duplicateFunction(let name):
            return "Duplicate function definition: \(name)"
        case .reservedNameUsed(let name):
            return "Reserved name used: \(name)"
        case .headerFileError(let message, let position):
            if let pos = position {
                return "Header file error at \(pos.description): \(message)"
            }
            return "Header file error: \(message)"
        }
    }
}

/// 脚本位置信息（兼容原版Emuera）
public struct ScriptPosition: Codable, Equatable {
    public let filename: String
    public let lineNumber: Int
    public let line: String?
    public let column: Int?

    public init(filename: String, lineNumber: Int, line: String? = nil, column: Int? = nil) {
        self.filename = filename
        self.lineNumber = lineNumber
        self.line = line
        self.column = column
    }

    public var description: String {
        if let col = column {
            return "\(filename):\(lineNumber):\(col)"
        }
        return "\(filename):\(lineNumber)"
    }
}

/// 用于诊断信息的可选位置
typealias OptionalPosition = ScriptPosition?