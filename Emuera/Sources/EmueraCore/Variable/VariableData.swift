//
//  VariableData.swift
//  EmueraCore
//
//  Variable data storage system
//  Created on 2025-12-18
//

import Foundation

/// Variable storage system compatible with Emuera
/// Handles basic storage and provides integration with TokenData for variable access
public class VariableData {
    // Global variables
    private var globals: [String: VariableValue] = [:]

    // Local variables (scoped by function)
    private var locals: [String: [String: VariableValue]] = [:]

    // Arrays for variables like RESULT, SELECTCOM, etc.
    private var arrays: [String: [Int64]] = [:]

    // Single integer values (system variables)
    public var dataInteger: [Int64] = Array(repeating: 0, count: 50)

    // Single string values
    public var dataString: [String?] = Array(repeating: nil, count: 20)

    // 1D Integer arrays (A-Z, FLAG, TFLAG, etc.)
    public var dataIntegerArray: [[Int64]] = Array(repeating: [], count: 50)

    // 1D String arrays (STR, SAVESTR, etc.)
    public var dataStringArray: [[String?]] = Array(repeating: [], count: 20)

    // 2D Integer arrays (for future use)
    public var dataIntegerArray2D: [[[Int64]]] = []

    // 2D String arrays
    public var dataStringArray2D: [[[String?]]] = []

    // 3D Integer arrays
    public var dataIntegerArray3D: [[[Int64]]] = []

    // 3D String arrays
    public var dataStringArray3D: [[[String?]]] = []

    // Character data array
    public var characters: [CharacterData] = []

    // Alias for characterList (used by tokens)
    public var characterList: [CharacterData] { characters }

    // Token manager for variable access
    private var tokenData: TokenData!

    // MARK: - Initialization

    public init() {
        setupDefaults()
        self.tokenData = TokenData(varData: self)
    }

    private func setupDefaults() {
        // Setup legacy arrays (for compatibility)
        arrays["RESULT"] = [0]
        arrays["SELECTCOM"] = Array(repeating: 0, count: 50)

        // Setup default system variables
        globals["RESULT"] = .integer(0)
        globals["RESULTS"] = .string("")
        globals["COUNT"] = .integer(0)
        globals["MASTER"] = .integer(0)
        globals["TARGET"] = .integer(0)
        globals["ASSI"] = .integer(0)

        // Setup dataInteger (system integer variables) - index 0-21
        // These match VariableCode base values
        for i in 0..<dataInteger.count {
            dataInteger[i] = 0
        }

        // Setup dataString (system string variables)
        for i in 0..<dataString.count {
            dataString[i] = nil
        }

        // Setup dataIntegerArray - arrayIndex 0-0x14 (21)
        // Positions: A=0, B=1, ..., Z=25, then system arrays
        let standardSize = 100

        // A-Z arrays (0-25)
        for i in 0...25 {
            dataIntegerArray[i] = Array(repeating: 0, count: standardSize)
        }

        // System arrays (ITEM=26, FLAG=27, TFLAG=28, UP=29, DOWN=30, etc.)
        dataIntegerArray[26] = Array(repeating: 0, count: standardSize) // ITEM
        dataIntegerArray[27] = Array(repeating: 0, count: standardSize) // FLAG
        dataIntegerArray[28] = Array(repeating: 0, count: standardSize) // TFLAG
        dataIntegerArray[29] = Array(repeating: 0, count: standardSize) // UP
        dataIntegerArray[30] = Array(repeating: 0, count: standardSize) // DOWN
        dataIntegerArray[31] = Array(repeating: 0, count: 50) // SELECTCOM
        dataIntegerArray[32] = Array(repeating: 0, count: 50) // PREVCOM
        dataIntegerArray[33] = Array(repeating: 0, count: 50) // NEXTCOM

        // Setup dataStringArray
        for i in 0..<dataStringArray.count {
            dataStringArray[i] = Array(repeating: nil, count: 50)
        }
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

    public func createCharacter() -> CharacterData {
        let char = CharacterData()
        characters.append(char)
        return char
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

    public func clearCharacters() {
        characters.removeAll()
    }

    private func getCharacterVariable(_ name: String) -> VariableValue {
        // Format: CHARA_0_NAME, CHARA_0_AGE, etc.
        // This is a placeholder - ideally should use TokenData for proper variable access
        // For now, just return .null as this is not yet fully implemented
        return .null
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

        // Reset data arrays
        dataInteger = Array(repeating: 0, count: 50)
        dataString = Array(repeating: nil, count: 20)
        dataIntegerArray = Array(repeating: [], count: 50)
        dataStringArray = Array(repeating: [], count: 20)
        dataIntegerArray2D = []
        dataStringArray2D = []
        dataIntegerArray3D = []
        dataStringArray3D = []

        setupDefaults()
        if tokenData != nil {
            tokenData.resetAll()
        }
    }

    // MARK: - Token-based Access

    /// Get the token data manager
    public func getTokenData() -> TokenData {
        return tokenData
    }

    /// Get integer value using token system
    public func getIntegerToken(_ name: String, arguments: [Int64] = []) throws -> Int64 {
        return try tokenData.getIntValue(name, arguments: arguments)
    }

    /// Get string value using token system
    public func getStringToken(_ name: String, arguments: [Int64] = []) throws -> String {
        return try tokenData.getStrValue(name, arguments: arguments)
    }

    /// Set integer value using token system
    public func setIntegerToken(_ name: String, value: Int64, arguments: [Int64] = []) throws {
        try tokenData.setIntValue(name, value: value, arguments: arguments)
    }

    /// Set string value using token system
    public func setStringToken(_ name: String, value: String, arguments: [Int64] = []) throws {
        try tokenData.setStrValue(name, value: value, arguments: arguments)
    }

    /// Check if variable should be saved
    public func isSavedVariable(_ name: String) -> Bool {
        return tokenData.isSavedataVariable(name)
    }

    // MARK: - Legacy Access Methods (for backward compatibility)

    /// Legacy method: Parse array notation and get value
    public func getArrayValue(_ name: String, index: Int = 0) -> Int64 {
        if let colonRange = name.range(of: ":") {
            let baseName = String(name[..<colonRange.lowerBound])
            let idxStr = String(name[colonRange.upperBound...])
            if let idx = Int(idxStr), let array = arrays[baseName] {
                return array.indices.contains(idx) ? array[idx] : 0
            }
        } else if let array = arrays[name] {
            return array.indices.contains(index) ? array[index] : 0
        }
        return 0
    }
}