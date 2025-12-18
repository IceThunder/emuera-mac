//
//  VariableType.swift
//  EmueraCore
//
//  Variable type system compatible with Emuera
//  Created on 2025-12-18
//

import Foundation

/// Emuera数据类型
public enum VariableType: String, Codable {
    case integer = "INTEGER"      // 整数类型
    case string = "STRING"        // 字符串类型
    case array = "ARRAY"          // 数组类型
    case character = "CHARACTER"  // 角色数据
    case any = "ANY"              // 任意类型

    public var description: String {
        return self.rawValue
    }
}

/// Emuera变量值
public enum VariableValue: Codable, Equatable {
    case integer(Int64)
    case string(String)
    case array([VariableValue])
    case character(CharacterData)
    case null

    // MARK: - Codable Implementation
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "integer":
            let value = try container.decode(Int64.self, forKey: .value)
            self = .integer(value)
        case "string":
            let value = try container.decode(String.self, forKey: .value)
            self = .string(value)
        case "array":
            let value = try container.decode([VariableValue].self, forKey: .value)
            self = .array(value)
        default:
            self = .null
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .integer(let value):
            try container.encode("integer", forKey: .type)
            try container.encode(value, forKey: .value)
        case .string(let value):
            try container.encode("string", forKey: .type)
            try container.encode(value, forKey: .value)
        case .array(let value):
            try container.encode("array", forKey: .type)
            try container.encode(value, forKey: .value)
        case .character(let value):
            try container.encode("character", forKey: .type)
            try container.encode(value, forKey: .value)
        case .null:
            try container.encode("null", forKey: .type)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, value
    }

    // MARK: - Convenience properties
    public var intValue: Int64? {
        if case .integer(let value) = self { return value }
        return nil
    }

    public var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }

    public var arrayValue: [VariableValue]? {
        if case .array(let value) = self { return value }
        return nil
    }

    public var isNull: Bool {
        if case .null = self { return true }
        return false
    }

    // MARK: - Type checking
    public var type: VariableType {
        switch self {
        case .integer: return .integer
        case .string: return .string
        case .array: return .array
        case .character: return .character
        case .null: return .any
        }
    }

    // MARK: - Conversion methods
    public func toInt() -> Int64 {
        switch self {
        case .integer(let value): return value
        case .string(let value): return Int64(value) ?? 0
        case .array(let value): return Int64(value.count)
        case .character: return 1
        case .null: return 0
        }
    }

    public func toString() -> String {
        switch self {
        case .integer(let value): return String(value)
        case .string(let value): return value
        case .array(let value): return value.map { $0.toString() }.joined(separator: ", ")
        case .character(let value): return value.name
        case .null: return ""
        }
    }

    // MARK: - CustomStringConvertible / Description
    public var description: String {
        switch self {
        case .integer(let value): return String(value)
        case .string(let value): return value
        case .array(let value): return value.map { $0.description }.joined(separator: ", ")
        case .character(let value): return value.name
        case .null: return "null"
        }
    }

    // MARK: - Equatable
    public static func == (lhs: VariableValue, rhs: VariableValue) -> Bool {
        switch (lhs, rhs) {
        case (.integer(let l), .integer(let r)): return l == r
        case (.string(let l), .string(let r)): return l == r
        case (.array(let l), .array(let r)):
            guard l.count == r.count else { return false }
            for i in 0..<l.count {
                if l[i] != r[i] { return false }
            }
            return true
        case (.character(let l), .character(let r)): return l.id == r.id
        case (.null, .null): return true
        default: return false
        }
    }
}

// Note: CharacterData is now defined in CharacterData.swift as a class for full storage
// This integrates with the variable token system for per-character data access