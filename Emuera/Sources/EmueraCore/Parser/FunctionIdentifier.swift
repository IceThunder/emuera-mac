//
//  FunctionIdentifier.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/20.
//

import Foundation

/// Represents a user-defined function from #FUNCTION/#FUNCTIONS directives
public final class FunctionIdentifier {
    public let name: String
    public let isGlobal: Bool
    public let isPrivate: Bool
    public let isReference: Bool
    public let argCount: Int
    public let returnType: FunctionReturnType
    public let position: ScriptPosition?

    public enum FunctionReturnType {
        case integer
        case string
        case void
    }

    public init(
        name: String,
        isGlobal: Bool = false,
        isPrivate: Bool = false,
        isReference: Bool = false,
        argCount: Int = 0,
        returnType: FunctionReturnType = .void,
        position: ScriptPosition? = nil
    ) {
        self.name = name
        self.isGlobal = isGlobal
        self.isPrivate = isPrivate
        self.isReference = isReference
        self.argCount = argCount
        self.returnType = returnType
        self.position = position
    }

    /// Create from #FUNCTION line
    public static func create(from stream: StringStream, isFunctions: Bool, position: ScriptPosition) throws -> FunctionIdentifier {
        // Parse keywords before function name
        var isGlobal = false
        var isPrivate = false
        var isReference = false
        var argCount = 0
        var returnType: FunctionReturnType = .void

        // #FUNCTIONS implies a return value
        if isFunctions {
            returnType = .integer  // Default to integer, can be overridden by INT/STR keywords
        }

        // Parse optional keywords
        while !stream.eol {
            stream.skipWhitespace()
            guard let current = stream.current else { break }

            if current.isLetter || current == "_" {
                // Try to read an identifier
                if let identifier = stream.readIdentifier()?.uppercased() {
                    switch identifier {
                    case "GLOBAL":
                        isGlobal = true
                        continue
                    case "PRIVATE":
                        isPrivate = true
                        continue
                    case "REF":
                        isReference = true
                        continue
                    case "INT":
                        returnType = .integer
                        continue
                    case "STR":
                        returnType = .string
                        continue
                    default:
                        // This is the function name
                        let funcName = identifier
                        // Check for argument count specification
                        stream.skipWhitespace()
                        if let char = stream.current, char.isNumber {
                            if let count = stream.readInteger() {
                                argCount = Int(count)
                            }
                        }

                        return FunctionIdentifier(
                            name: funcName,
                            isGlobal: isGlobal,
                            isPrivate: isPrivate,
                            isReference: isReference,
                            argCount: argCount,
                            returnType: returnType,
                            position: position
                        )
                    }
                }
            } else {
                break
            }
        }

        throw EmueraError.headerFileError(message: "Missing function name", position: position)
    }
}
