//
//  CodeEE.swift
//  EmueraCore
//
//  Emuera exception type for variable system errors
//
//  Created: 2025-12-19
//

import Foundation

/// Emuera exception type - mirrors the C# EmueraException pattern
/// These exceptions indicate variable access violations, range errors, etc.
public struct CodeEE: Error, CustomStringConvertible {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var description: String {
        return "CodeEE: \(message)"
    }
}
