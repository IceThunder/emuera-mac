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
        }
    }
}

/// 脚本位置信息（兼容原版Emuera）
public struct ScriptPosition: Codable, Equatable {
    public let filename: String
    public let lineNumber: Int

    public init(filename: String, lineNumber: Int) {
        self.filename = filename
        self.lineNumber = lineNumber
    }

    public var description: String {
        return "\(filename):\(lineNumber)"
    }
}

/// 用于诊断信息的可选位置
typealias OptionalPosition = ScriptPosition?