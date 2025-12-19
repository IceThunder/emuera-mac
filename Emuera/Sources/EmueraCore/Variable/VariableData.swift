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

    // 2D Integer arrays - indexed by VariableCode baseValue
    public var dataIntegerArray2D: [[[Int64]]] = []

    // 2D String arrays - indexed by VariableCode baseValue
    public var dataStringArray2D: [[[String?]]] = []

    // 3D Integer arrays - indexed by VariableCode baseValue
    public var dataIntegerArray3D: [[[[Int64]]]] = []

    // 3D String arrays - indexed by VariableCode baseValue
    public var dataStringArray3D: [[[[String?]]]] = []

    // Character data array
    public var characters: [CharacterData] = []

    // Alias for characterList (used by tokens)
    public var characterList: [CharacterData] { characters }

    // Token manager for variable access
    private var tokenData: TokenData!

    // MARK: - Initialization

    public init() {
        print("VariableData.init start")
        setupDefaults()
        print("About to create TokenData")
        print("dataIntegerArray.count = \(dataIntegerArray.count)")
        self.tokenData = TokenData(varData: self)
        print("VariableData.init complete")
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

        // Setup dataInteger (system integer variables)
        // Following C#: dataInteger has 22 elements (0x00-0x15)
        // But we'll use larger array to accommodate all base values up to 0x37
        dataInteger = Array(repeating: 0, count: 0x38)  // 56 elements for 0x00-0x37

        // Setup dataString (system string variables)
        dataString = Array(repeating: nil, count: 0x03)  // RESULTS, SAVESTR, STR

        // Setup dataIntegerArray - following C# VariableData structure
        // Each index corresponds to VariableCode baseValue
        // We need enough slots for all variables up to the highest baseValue we define

        // First, ensure the array has enough capacity
        let requiredCapacity = 0x41  // Enough for all defined variables (0x00-0x40)
        if dataIntegerArray.count < requiredCapacity {
            dataIntegerArray = Array(repeating: [], count: requiredCapacity)
        }

        let standardSize = 100  // Default array size for most variables

        // Single integer variables that are actually 1D arrays (base 0x00-0x1B)
        // These are stored in dataIntegerArray, accessed via IntVariableToken
        dataIntegerArray[0x00] = Array(repeating: 0, count: 1)  // DAY
        dataIntegerArray[0x01] = Array(repeating: 0, count: 1)  // MONEY
        dataIntegerArray[0x02] = Array(repeating: 0, count: standardSize)  // ITEM
        dataIntegerArray[0x03] = Array(repeating: 0, count: standardSize)  // FLAG
        dataIntegerArray[0x04] = Array(repeating: 0, count: standardSize)  // TFLAG
        dataIntegerArray[0x05] = Array(repeating: 0, count: standardSize)  // UP
        dataIntegerArray[0x06] = Array(repeating: 0, count: standardSize)  // PALAMLV
        dataIntegerArray[0x07] = Array(repeating: 0, count: standardSize)  // EXPLV
        dataIntegerArray[0x08] = Array(repeating: 0, count: standardSize)  // EJAC
        dataIntegerArray[0x09] = Array(repeating: 0, count: standardSize)  // DOWN
        dataIntegerArray[0x0A] = Array(repeating: 0, count: 1)  // RESULT
        dataIntegerArray[0x0B] = Array(repeating: 0, count: 1)  // COUNT
        dataIntegerArray[0x0C] = Array(repeating: 0, count: 1)  // TARGET
        dataIntegerArray[0x0D] = Array(repeating: 0, count: 1)  // ASSI
        dataIntegerArray[0x0E] = Array(repeating: 0, count: 1)  // MASTER
        dataIntegerArray[0x0F] = Array(repeating: 0, count: 1)  // NOITEM
        dataIntegerArray[0x10] = Array(repeating: 0, count: 1)  // LOSEBASE
        dataIntegerArray[0x11] = Array(repeating: 0, count: standardSize)  // SELECTCOM
        dataIntegerArray[0x12] = Array(repeating: 0, count: 1)  // ASSIPLAY
        dataIntegerArray[0x13] = Array(repeating: 0, count: standardSize)  // PREVCOM
        dataIntegerArray[0x14] = Array(repeating: 0, count: 1)  // NOTUSE
        dataIntegerArray[0x15] = Array(repeating: 0, count: 1)  // NOTUSE
        dataIntegerArray[0x16] = Array(repeating: 0, count: 1)  // TIME
        dataIntegerArray[0x17] = Array(repeating: 0, count: 1)  // ITEMSALES
        dataIntegerArray[0x18] = Array(repeating: 0, count: 1)  // PLAYER
        dataIntegerArray[0x19] = Array(repeating: 0, count: standardSize)  // NEXTCOM
        dataIntegerArray[0x1A] = Array(repeating: 0, count: 1)  // PBAND
        dataIntegerArray[0x1B] = Array(repeating: 0, count: 1)  // BOUGHT
        // 0x1C-0x1D: NOTUSE

        // A-Z arrays (0x1E-0x37)
        for i in 0x1E...0x37 {
            dataIntegerArray[i] = Array(repeating: 0, count: standardSize)
        }

        // Extended arrays (0x3C+)
        dataIntegerArray[0x3C] = Array(repeating: 0, count: standardSize)  // ITEMPRICE
        dataIntegerArray[0x3D] = Array(repeating: 0, count: standardSize)  // LOCAL
        dataIntegerArray[0x3E] = Array(repeating: 0, count: standardSize)  // ARG
        dataIntegerArray[0x3F] = Array(repeating: 0, count: standardSize)  // GLOBAL
        dataIntegerArray[0x40] = Array(repeating: 0, count: standardSize)  // RANDDATA

        // Setup dataStringArray
        if dataStringArray.count < 3 {
            dataStringArray = Array(repeating: [], count: 3)
        }
        dataStringArray[0x00] = Array(repeating: nil, count: 50)  // RESULTS
        dataStringArray[0x01] = Array(repeating: nil, count: 50)  // SAVESTR
        dataStringArray[0x02] = Array(repeating: nil, count: 50)  // STR

        // Setup 2D Integer Arrays
        // CDFLAG = 0x0000 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_2D__
        // baseValue = 0x00
        if dataIntegerArray2D.count < 1 {
            dataIntegerArray2D = Array(repeating: [], count: 1)
        }
        // Default: 10x10 for CDFLAG
        dataIntegerArray2D[0x00] = Array(repeating: Array(repeating: 0, count: 10), count: 10)

        // Setup 2D String Arrays
        if dataStringArray2D.count < 1 {
            dataStringArray2D = Array(repeating: [], count: 1)
        }
        dataStringArray2D[0x00] = Array(repeating: Array(repeating: nil, count: 10), count: 10)

        // Setup 3D Integer Arrays (for future expansion)
        if dataIntegerArray3D.count < 1 {
            dataIntegerArray3D = Array(repeating: [], count: 1)
        }
        dataIntegerArray3D[0x00] = Array(repeating: Array(repeating: Array(repeating: 0, count: 5), count: 5), count: 5)

        // Setup 3D String Arrays
        if dataStringArray3D.count < 1 {
            dataStringArray3D = Array(repeating: [], count: 1)
        }
        dataStringArray3D[0x00] = Array(repeating: Array(repeating: Array(repeating: nil, count: 5), count: 5), count: 5)
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

        // Reset data arrays to empty
        dataInteger = []
        dataString = []
        dataIntegerArray = []
        dataStringArray = []
        dataIntegerArray2D = []
        dataStringArray2D = []
        dataIntegerArray3D = []
        dataStringArray3D = []

        // Reinitialize with defaults
        setupDefaults()
        if tokenData != nil {
            tokenData.resetAll()
        }
    }

    // MARK: - 2D/3D Array Access Methods

    /// Get 2D integer array element
    public func get2DInt(_ baseValue: Int, _ i: Int, _ j: Int) -> Int64 {
        guard baseValue >= 0 && baseValue < dataIntegerArray2D.count,
              i >= 0 && i < dataIntegerArray2D[baseValue].count,
              j >= 0 && j < dataIntegerArray2D[baseValue][i].count else {
            return 0
        }
        return dataIntegerArray2D[baseValue][i][j]
    }

    /// Set 2D integer array element
    public func set2DInt(_ baseValue: Int, _ i: Int, _ j: Int, _ value: Int64) {
        guard baseValue >= 0 && baseValue < dataIntegerArray2D.count,
              i >= 0 && i < dataIntegerArray2D[baseValue].count,
              j >= 0 && j < dataIntegerArray2D[baseValue][i].count else {
            return
        }
        dataIntegerArray2D[baseValue][i][j] = value
    }

    /// Get 3D integer array element
    public func get3DInt(_ baseValue: Int, _ i: Int, _ j: Int, _ k: Int) -> Int64 {
        guard baseValue >= 0 && baseValue < dataIntegerArray3D.count,
              i >= 0 && i < dataIntegerArray3D[baseValue].count,
              j >= 0 && j < dataIntegerArray3D[baseValue][i].count,
              k >= 0 && k < dataIntegerArray3D[baseValue][i][j].count else {
            return 0
        }
        return dataIntegerArray3D[baseValue][i][j][k]
    }

    /// Set 3D integer array element
    public func set3DInt(_ baseValue: Int, _ i: Int, _ j: Int, _ k: Int, _ value: Int64) {
        guard baseValue >= 0 && baseValue < dataIntegerArray3D.count,
              i >= 0 && i < dataIntegerArray3D[baseValue].count,
              j >= 0 && j < dataIntegerArray3D[baseValue][i].count,
              k >= 0 && k < dataIntegerArray3D[baseValue][i][j].count else {
            return
        }
        dataIntegerArray3D[baseValue][i][j][k] = value
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