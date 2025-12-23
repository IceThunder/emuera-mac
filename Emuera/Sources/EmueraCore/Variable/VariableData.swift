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

    /// 获取所有数组（用于同步）
    public func getAllArrays() -> [String: [Int64]] {
        return arrays
    }

    /// 批量设置数组（用于同步）
    public func setAllArrays(_ newArrays: [String: [Int64]]) {
        arrays = newArrays
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

    // MARK: - Serialization for SAVE/LOAD (Phase 3 P1)

    /// Serialize all variables to JSON string
    public func serializeAll() throws -> String {
        let data = try serializeData()
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Serialize specific variables to JSON string
    public func serializeVariables(_ variableNames: [String]) throws -> String {
        let data = try serializeData(variableNames: variableNames)
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Serialize character data to JSON string
    public func serializeCharacters() throws -> String {
        let data = try serializeCharacterData()
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Deserialize all variables from JSON string
    public func deserializeAll(_ jsonString: String) throws {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw EmueraError.runtimeError(message: "Invalid JSON encoding", position: nil)
        }
        guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw EmueraError.runtimeError(message: "Invalid JSON format", position: nil)
        }
        try deserializeData(json)
    }

    /// Deserialize specific variables from JSON string
    public func deserializeVariables(_ jsonString: String, variableNames: [String]) throws {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw EmueraError.runtimeError(message: "Invalid JSON encoding", position: nil)
        }
        guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw EmueraError.runtimeError(message: "Invalid JSON format", position: nil)
        }
        try deserializeData(json, variableNames: variableNames)
    }

    /// Deserialize character data from JSON string
    public func deserializeCharacters(_ jsonString: String) throws {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw EmueraError.runtimeError(message: "Invalid JSON encoding", position: nil)
        }
        guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw EmueraError.runtimeError(message: "Invalid JSON format", position: nil)
        }
        try deserializeCharacterData(json)
    }

    // MARK: - Internal Serialization Methods

    /// Internal method to serialize all data
    private func serializeData(variableNames: [String]? = nil) throws -> [String: Any] {
        var result: [String: Any] = [:]

        // Metadata
        result["metadata"] = [
            "version": "1.0",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "saveType": variableNames == nil ? "full" : "partial"
        ]

        // Variables
        var variables: [String: Any] = [:]

        // Global variables
        if variableNames == nil {
            var globalsData: [String: Any] = [:]
            for (name, value) in globals {
                globalsData[name] = serializeVariableValue(value)
            }
            variables["globals"] = globalsData
        } else {
            // Only serialize specified variables
            var selectedGlobals: [String: Any] = [:]
            for name in variableNames! {
                if let value = globals[name] {
                    selectedGlobals[name] = serializeVariableValue(value)
                }
            }
            if !selectedGlobals.isEmpty {
                variables["globals"] = selectedGlobals
            }
        }

        // Arrays
        if variableNames == nil {
            var arraysData: [String: Any] = [:]
            for (name, array) in arrays {
                arraysData[name] = array
            }
            variables["arrays"] = arraysData
        }

        // System variables (dataInteger, dataString, etc.)
        if variableNames == nil {
            variables["dataInteger"] = dataInteger
            variables["dataString"] = dataString
            variables["dataIntegerArray"] = dataIntegerArray
            variables["dataStringArray"] = dataStringArray
            variables["dataIntegerArray2D"] = dataIntegerArray2D
            variables["dataStringArray2D"] = dataStringArray2D
            variables["dataIntegerArray3D"] = dataIntegerArray3D
            variables["dataStringArray3D"] = dataStringArray3D
        }

        result["variables"] = variables

        return result
    }

    /// Internal method to serialize character data
    private func serializeCharacterData() throws -> [String: Any] {
        var result: [String: Any] = [:]

        // Metadata
        result["metadata"] = [
            "version": "1.0",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "saveType": "characters"
        ]

        // Characters
        var charactersData: [[String: Any]] = []
        for (index, character) in characters.enumerated() {
            var charDict: [String: Any] = [:]
            charDict["id"] = index
            charDict["name"] = character.name
            // Add more character properties as needed
            charactersData.append(charDict)
        }
        result["characters"] = charactersData

        return result
    }

    /// Internal method to deserialize all data
    private func deserializeData(_ json: [String: Any], variableNames: [String]? = nil) throws {
        guard let variables = json["variables"] as? [String: Any] else {
            throw EmueraError.runtimeError(message: "Missing variables section in JSON", position: nil)
        }

        // Deserialize globals
        if let globalsData = variables["globals"] as? [String: Any] {
            for (name, value) in globalsData {
                if variableNames == nil || variableNames!.contains(name) {
                    globals[name] = deserializeVariableValue(value)
                }
            }
        }

        // Deserialize arrays
        if let arraysData = variables["arrays"] as? [String: Any],
           variableNames == nil {
            for (name, value) in arraysData {
                if let array = value as? [Int64] {
                    arrays[name] = array
                }
            }
        }

        // Deserialize system variables (only if full load)
        if variableNames == nil {
            if let di = variables["dataInteger"] as? [Int64] { dataInteger = di }
            if let ds = variables["dataString"] as? [String?] { dataString = ds }
            if let dia = variables["dataIntegerArray"] as? [[Int64]] { dataIntegerArray = dia }
            if let dsa = variables["dataStringArray"] as? [[String?]] { dataStringArray = dsa }
            if let dia2d = variables["dataIntegerArray2D"] as? [[[Int64]]] { dataIntegerArray2D = dia2d }
            if let dsa2d = variables["dataStringArray2D"] as? [[[String?]]] { dataStringArray2D = dsa2d }
            if let dia3d = variables["dataIntegerArray3D"] as? [[[[Int64]]]] { dataIntegerArray3D = dia3d }
            if let dsa3d = variables["dataStringArray3D"] as? [[[[String?]]]] { dataStringArray3D = dsa3d }
        }
    }

    /// Internal method to deserialize character data
    private func deserializeCharacterData(_ json: [String: Any]) throws {
        guard let charactersData = json["characters"] as? [[String: Any]] else {
            throw EmueraError.runtimeError(message: "Missing characters section in JSON", position: nil)
        }

        characters.removeAll()
        for charDict in charactersData {
            let char = CharacterData()
            if let name = charDict["name"] as? String {
                char.name = name
            }
            if let id = charDict["id"] as? Int {
                char.id = id
            }
            characters.append(char)
        }
    }

    /// Serialize a VariableValue to JSON-compatible format
    private func serializeVariableValue(_ value: VariableValue) -> Any {
        switch value {
        case .integer(let int):
            return int
        case .string(let str):
            return str
        case .null:
            return NSNull()
        case .array(let arr):
            // 递归序列化数组中的每个元素
            return arr.map { serializeVariableValue($0) }
        case .character(let char):
            // 序列化角色数据为字典
            return [
                "id": char.id,
                "name": char.name
            ]
        }
    }

    /// Deserialize JSON value to VariableValue
    private func deserializeVariableValue(_ value: Any) -> VariableValue {
        if let int = value as? Int64 {
            return .integer(int)
        } else if let int = value as? Int {
            return .integer(Int64(int))
        } else if let str = value as? String {
            return .string(str)
        } else if let arr = value as? [Any] {
            // 反序列化数组
            return .array(arr.map { deserializeVariableValue($0) })
        } else if let dict = value as? [String: Any] {
            // 反序列化角色数据
            let char = CharacterData()
            if let id = dict["id"] as? Int {
                char.id = id
            }
            if let name = dict["name"] as? String {
                char.name = name
            }
            return .character(char)
        } else {
            return .null
        }
    }

    // MARK: - SAVECHARA/LOADCHARA (Phase 3 P2)

    /// Serialize specific character to JSON string
    /// - Parameters:
    ///   - charaIndex: Character index in characters array
    ///   - filename: Output filename (for metadata only)
    /// - Returns: JSON string
    public func serializeCharacter(charaIndex: Int, filename: String) throws -> String {
        guard charaIndex >= 0 && charaIndex < characters.count else {
            throw EmueraError.runtimeError(
                message: "角色索引超出范围: \(charaIndex), 当前角色数: \(characters.count)",
                position: nil
            )
        }

        let character = characters[charaIndex]
        let data = try serializeSingleCharacter(character, index: charaIndex)
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Deserialize character from JSON string and replace at specified index
    /// - Parameters:
    ///   - jsonString: JSON string containing character data
    ///   - charaIndex: Character index to replace
    public func deserializeCharacter(jsonString: String, charaIndex: Int) throws {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw EmueraError.runtimeError(message: "Invalid JSON encoding", position: nil)
        }
        guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw EmueraError.runtimeError(message: "Invalid JSON format", position: nil)
        }

        try deserializeSingleCharacter(json, charaIndex: charaIndex)
    }

    /// Internal method to serialize a single character with full data
    private func serializeSingleCharacter(_ character: CharacterData, index: Int) throws -> [String: Any] {
        var result: [String: Any] = [:]

        // Metadata
        result["metadata"] = [
            "version": "1.0",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "saveType": "character"
        ]

        // Character data
        var charData: [String: Any] = [:]
        charData["id"] = character.id
        charData["name"] = character.name

        // Character internal data (9-group storage)
        var dataDict: [String: Any] = [:]
        dataDict["integers"] = character.dataInteger
        dataDict["strings"] = character.dataString.map { $0 ?? "" }
        dataDict["intArrays"] = character.dataIntegerArray
        dataDict["strArrays"] = character.dataStringArray.map { $0.map { $0 ?? "" } }
        dataDict["int2D"] = character.dataIntegerArray2D
        dataDict["str2D"] = character.dataStringArray2D.map { $0.map { $0.map { $0 ?? "" } } }
        dataDict["int3D"] = character.dataIntegerArray3D
        dataDict["str3D"] = character.dataStringArray3D.map { $0.map { $0.map { $0.map { $0 ?? "" } } } }

        charData["data"] = dataDict
        result["character"] = charData

        return result
    }

    /// Internal method to deserialize a single character
    private func deserializeSingleCharacter(_ json: [String: Any], charaIndex: Int) throws {
        guard let charData = json["character"] as? [String: Any] else {
            throw EmueraError.runtimeError(message: "Missing character data in JSON", position: nil)
        }

        // Ensure character exists at index
        while characters.count <= charaIndex {
            characters.append(CharacterData())
        }

        let character = characters[charaIndex]

        // Load basic info
        if let id = charData["id"] as? Int {
            character.id = id
        }
        if let name = charData["name"] as? String {
            character.name = name
        }

        // Load internal data
        if let dataDict = charData["data"] as? [String: Any] {
            if let ints = dataDict["integers"] as? [Int64] {
                character.dataInteger = ints
            }
            if let strs = dataDict["strings"] as? [String] {
                character.dataString = strs.map { $0.isEmpty ? nil : $0 }
            }
            if let intArrays = dataDict["intArrays"] as? [[Int64]] {
                character.dataIntegerArray = intArrays
            }
            if let strArrays = dataDict["strArrays"] as? [[String]] {
                character.dataStringArray = strArrays.map { $0.map { $0.isEmpty ? nil : $0 } }
            }
            if let int2D = dataDict["int2D"] as? [[[Int64]]] {
                character.dataIntegerArray2D = int2D
            }
            if let str2D = dataDict["str2D"] as? [[[String]]] {
                character.dataStringArray2D = str2D.map { $0.map { $0.map { $0.isEmpty ? nil : $0 } } }
            }
            if let int3D = dataDict["int3D"] as? [[[[Int64]]]] {
                character.dataIntegerArray3D = int3D
            }
            if let str3D = dataDict["str3D"] as? [[[[String]]]] {
                character.dataStringArray3D = str3D.map { $0.map { $0.map { $0.map { $0.isEmpty ? nil : $0 } } } }
            }
        }
    }

    // MARK: - SAVEGAME/LOADGAME (Phase 3 P3)

    /// Serialize complete game state to JSON string
    /// Includes: all variables, all characters, game state (day, time, etc.)
    public func serializeGameState() throws -> String {
        let data = try serializeGameStateData()
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Deserialize complete game state from JSON string
    public func deserializeGameState(_ jsonString: String) throws {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw EmueraError.runtimeError(message: "Invalid JSON encoding", position: nil)
        }
        guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw EmueraError.runtimeError(message: "Invalid JSON format", position: nil)
        }
        try deserializeGameStateData(json)
    }

    /// Internal method to serialize complete game state
    private func serializeGameStateData() throws -> [String: Any] {
        var result: [String: Any] = [:]

        // Metadata
        result["metadata"] = [
            "version": "1.0",
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "saveType": "full",
            "gameVersion": "1.0"
        ]

        // Variables
        var variables: [String: Any] = [:]

        // Global variables
        var globalsData: [String: Any] = [:]
        for (name, value) in globals {
            globalsData[name] = serializeVariableValue(value)
        }
        variables["globals"] = globalsData

        // Arrays
        var arraysData: [String: Any] = [:]
        for (name, array) in getAllArrays() {
            arraysData[name] = array
        }
        variables["arrays"] = arraysData

        // System variables
        variables["dataInteger"] = dataInteger
        variables["dataString"] = dataString.map { $0 ?? "" }
        variables["dataIntegerArray"] = dataIntegerArray
        variables["dataStringArray"] = dataStringArray.map { $0.map { $0 ?? "" } }
        variables["dataIntegerArray2D"] = dataIntegerArray2D
        variables["dataStringArray2D"] = dataStringArray2D.map { $0.map { $0.map { $0 ?? "" } } }
        variables["dataIntegerArray3D"] = dataIntegerArray3D
        variables["dataStringArray3D"] = dataStringArray3D.map { $0.map { $0.map { $0.map { $0 ?? "" } } } }

        result["variables"] = variables

        // Characters
        var charactersData: [[String: Any]] = []
        for (index, character) in characters.enumerated() {
            let charDict = try serializeSingleCharacter(character, index: index)
            charactersData.append(charDict["character"] as! [String: Any])
        }
        result["characters"] = charactersData

        // Game state (placeholder - would need actual game state from context)
        result["gameState"] = [
            "day": 0,
            "time": 0,
            "randomSeed": 0
        ]

        return result
    }

    /// Internal method to deserialize complete game state
    private func deserializeGameStateData(_ json: [String: Any]) throws {
        // Load variables
        if let variables = json["variables"] as? [String: Any] {
            // Globals
            if let globalsData = variables["globals"] as? [String: Any] {
                for (name, value) in globalsData {
                    globals[name] = deserializeVariableValue(value)
                }
            }

            // Arrays
            if let arraysData = variables["arrays"] as? [String: Any] {
                for (name, value) in arraysData {
                    if let array = value as? [Int64] {
                        setArray(name, values: array)
                    }
                }
            }

            // System variables
            if let di = variables["dataInteger"] as? [Int64] { dataInteger = di }
            if let ds = variables["dataString"] as? [String] { dataString = ds.map { $0.isEmpty ? nil : $0 } }
            if let dia = variables["dataIntegerArray"] as? [[Int64]] { dataIntegerArray = dia }
            if let dsa = variables["dataStringArray"] as? [[String]] { dataStringArray = dsa.map { $0.map { $0.isEmpty ? nil : $0 } } }
            if let dia2d = variables["dataIntegerArray2D"] as? [[[Int64]]] { dataIntegerArray2D = dia2d }
            if let dsa2d = variables["dataStringArray2D"] as? [[[String]]] { dataStringArray2D = dsa2d.map { $0.map { $0.map { $0.isEmpty ? nil : $0 } } } }
            if let dia3d = variables["dataIntegerArray3D"] as? [[[[Int64]]]] { dataIntegerArray3D = dia3d }
            if let dsa3d = variables["dataStringArray3D"] as? [[[[String]]]] { dataStringArray3D = dsa3d.map { $0.map { $0.map { $0.map { $0.isEmpty ? nil : $0 } } } } }
        }

        // Load characters
        if let charactersData = json["characters"] as? [[String: Any]] {
            characters.removeAll()
            for charDict in charactersData {
                let char = CharacterData()
                if let id = charDict["id"] as? Int {
                    char.id = id
                }
                if let name = charDict["name"] as? String {
                    char.name = name
                }
                if let dataDict = charDict["data"] as? [String: Any] {
                    if let ints = dataDict["integers"] as? [Int64] {
                        char.dataInteger = ints
                    }
                    if let strs = dataDict["strings"] as? [String] {
                        char.dataString = strs.map { $0.isEmpty ? nil : $0 }
                    }
                    if let intArrays = dataDict["intArrays"] as? [[Int64]] {
                        char.dataIntegerArray = intArrays
                    }
                    if let strArrays = dataDict["strArrays"] as? [[String]] {
                        char.dataStringArray = strArrays.map { $0.map { $0.isEmpty ? nil : $0 } }
                    }
                    if let int2D = dataDict["int2D"] as? [[[Int64]]] {
                        char.dataIntegerArray2D = int2D
                    }
                    if let str2D = dataDict["str2D"] as? [[[String]]] {
                        char.dataStringArray2D = str2D.map { $0.map { $0.map { $0.isEmpty ? nil : $0 } } }
                    }
                    if let int3D = dataDict["int3D"] as? [[[[Int64]]]] {
                        char.dataIntegerArray3D = int3D
                    }
                    if let str3D = dataDict["str3D"] as? [[[[String]]]] {
                        char.dataStringArray3D = str3D.map { $0.map { $0.map { $0.map { $0.isEmpty ? nil : $0 } } } }
                    }
                }
                characters.append(char)
            }
        }

        // Load game state (placeholder - would set actual game state)
        // if let gameState = json["gameState"] as? [String: Any] { ... }
    }

    // MARK: - SAVELIST/SAVEEXISTS (Phase 3 P4)

    /// 获取存档文件列表
    /// - Returns: [文件名: 元数据字典]，元数据包含时间戳和大小
    public func getSaveFileList() -> [String: [String: Any]] {
        var result: [String: [String: Any]] = [:]

        // 获取应用文档目录
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return [:]
        }

        // saves子目录
        let savesURL = documentsURL.appendingPathComponent("EmueraSaves")

        // 检查目录是否存在
        guard let enumerator = FileManager.default.enumerator(at: savesURL, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]) else {
            return [:]
        }

        for case let fileURL as URL in enumerator {
            // 只处理.json文件
            guard fileURL.pathExtension == "json" else { continue }

            let filename = fileURL.lastPathComponent

            do {
                let attributes = try fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
                var metadata: [String: Any] = [:]

                if let modDate = attributes.contentModificationDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    metadata["modified"] = formatter.string(from: modDate)
                }

                if let fileSize = attributes.fileSize {
                    metadata["size"] = fileSize
                }

                result[filename] = metadata
            } catch {
                // 如果无法获取元数据，仍然返回文件名
                result[filename] = [:]
            }
        }

        return result
    }

    /// 检查存档文件是否存在
    /// - Parameter filename: 文件名（可不带.json扩展名）
    /// - Returns: 是否存在
    public func saveFileExists(_ filename: String) -> Bool {
        // 获取应用文档目录
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }

        // saves子目录
        let savesURL = documentsURL.appendingPathComponent("EmueraSaves")

        // 自动添加.json扩展名如果未指定
        let finalFilename = filename.hasSuffix(".json") ? filename : "\(filename).json"
        let fileURL = savesURL.appendingPathComponent(finalFilename)

        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}