//
//  VariableData.swift
//  EmueraCore
//
//  Variable data storage system
//  Created on 2025-12-18
//

import Foundation

/// Variable storage system compatible with Emuera
public class VariableData {
    // Global variables
    private var globals: [String: VariableValue] = [:]

    // Local variables (scoped by function)
    private var locals: [String: [String: VariableValue]] = [:]

    // Arrays for variables like RESULT, SELECTCOM, etc.
    private var arrays: [String: [Int64]] = [:]

    // Character data array
    private var characters: [CharacterData] = []

    // MARK: - Initialization

    public init() {
        setupDefaults()
    }

    private func setupDefaults() {
        // Setup default arrays
        arrays["RESULT"] = Array(repeating: 0, count: 10)
        arrays["SELECTCOM"] = Array(repeating: 0, count: 50)
        arrays["RESULT"] = [0]

        // Setup default system variables
        globals["RESULT"] = .integer(0)
        globals["RESULTS"] = .string("")
        globals["COUNT"] = .integer(0)
        globals["MASTER"] = .integer(0)
        globals["TARGET"] = .integer(0)
        globals["ASSI"] = .integer(0)
    }

    // MARK: - Variable Access

    public func getVariable(_ name: String, scope: String? = nil) -> VariableValue {
        // Check local scope first
        if let scope = scope,
           let localVars = locals[scope],
           let value = localVars[name] {
            return value
        }

        // Check arrays first (for array access like RESULT:0)
        if let arrayName = parseArrayName(name),
           let index = parseArrayIndex(name),
           let array = arrays[arrayName] {
            let clampedIndex = max(0, min(index, array.count - 1))
            return .integer(array[clampedIndex])
        }

        // Check global variables
        if let value = globals[name] {
            return value
        }

        // Check character data
        if name.hasPrefix("CHARA_") {
            return getCharacterVariable(name)
        }

        return .null
    }

    public func setVariable(_ name: String, value: VariableValue, scope: String? = nil) {
        // Array assignment (RESULT:0 = value)
        if let arrayName = parseArrayName(name),
           let index = parseArrayIndex(name) {
            if arrays[arrayName] == nil {
                arrays[arrayName] = Array(repeating: 0, count: max(index + 1, 10))
            }
            if case .integer(let intValue) = value {
                if index >= arrays[arrayName]!.count {
                    arrays[arrayName]!.append(contentsOf: Array(repeating: 0, count: index - arrays[arrayName]!.count + 1))
                }
                arrays[arrayName]![index] = intValue
            }
            return
        }

        // Local variable
        if let scope = scope {
            if locals[scope] == nil {
                locals[scope] = [:]
            }
            locals[scope]?[name] = value
            return
        }

        // Global variable
        globals[name] = value

        // If setting RESULT/RESULTS, update as both global and array
        if name == "RESULT", case .integer(let intValue) = value {
            arrays["RESULT"]?[0] = intValue
        }
    }

    // MARK: - Array Operations

    public func getArray(_ name: String) -> [Int64] {
        return arrays[name] ?? []
    }

    public func setArray(_ name: String, values: [Int64]) {
        arrays[name] = values
    }

    public func getArrayElement(_ name: String, index: Int) -> Int64 {
        guard let array = arrays[name],
              index >= 0 && index < array.count else {
            return 0
        }
        return array[index]
    }

    public func setArrayElement(_ name: String, index: Int, value: Int64) {
        if arrays[name] == nil {
            arrays[name] = Array(repeating: 0, count: max(index + 1, 10))
        }
        if index >= arrays[name]!.count {
            arrays[name]!.append(contentsOf: Array(repeating: 0, count: index - arrays[name]!.count + 1))
        }
        arrays[name]![index] = value
    }

    // MARK: - Character Data

    public func addCharacter(_ character: CharacterData) {
        characters.append(character)
    }

    public func getCharacter(at index: Int) -> CharacterData? {
        guard index >= 0 && index < characters.count else {
            return nil
        }
        return characters[index]
    }

    public func getCharacterCount() -> Int {
        return characters.count
    }

    private func getCharacterVariable(_ name: String) -> VariableValue {
        // Format: CHARA_0_NAME, CHARA_0_AGE, etc.
        let parts = name.split(separator: "_")
        guard parts.count >= 3,
              let charIndex = Int(parts[1]),
              let character = getCharacter(at: charIndex) else {
            return .null
        }

        let varName = parts.dropFirst(2).joined(separator: "_")
        return character.getVariable(varName)
    }

    // MARK: - Helper Methods

    private func parseArrayName(_ name: String) -> String? {
        guard let colonRange = name.range(of: ":"),
              colonRange.lowerBound != name.endIndex else {
            return nil
        }
        return String(name[..<colonRange.lowerBound])
    }

    private func parseArrayIndex(_ name: String) -> Int? {
        guard let colonRange = name.range(of: ":"),
              colonRange.upperBound != name.endIndex else {
            return nil
        }
        let indexStr = String(name[colonRange.upperBound...])
        return Int(indexStr)
    }

    // MARK: - Context Management

    public func pushLocalScope(_ scope: String) {
        if locals[scope] == nil {
            locals[scope] = [:]
        }
    }

    public func popLocalScope(_ scope: String) {
        locals.removeValue(forKey: scope)
    }

    // MARK: - Reset

    public func reset() {
        globals.removeAll()
        locals.removeAll()
        arrays.removeAll()
        characters.removeAll()
        setupDefaults()
    }
}