//
//  CharacterData.swift
//  EmueraCore
//
//  Character data storage - holds per-character variables
//  Complete translation from C# CharacterData.cs
//
//  Created: 2025-12-19
//

import Foundation

/// Character data - equivalent to single row in C# CharacterData
/// Provides both storage system (for tokens) and value properties (for VariableType)
public class CharacterData: Codable, Equatable {
    // Identity properties for VariableType enum and display
    public var id: Int = 0
    public var name: String = "Character"

    // Variable dictionary for type system compat
    public var variables: [String: VariableValue] = [:]

    // 9-group storage system (Per C# CharacterData.cs)
    // Single integer values (0x00-0x15 range)
    public var dataInteger: [Int64] = Array(repeating: 0, count: 22)

    // Single string values (0x00-0x05 range)
    public var dataString: [String?] = Array(repeating: nil, count: 6)

    // 1D Integer arrays (index 0x00-0x14 for various character arrays)
    public var dataIntegerArray: [[Int64]] = []

    // 1D String arrays
    public var dataStringArray: [[String?]] = []

    // 2D Integer arrays: array of 2D arrays
    public var dataIntegerArray2D: [[[Int64]]] = []

    // 2D String arrays: array of 2D arrays
    public var dataStringArray2D: [[[String?]]] = []

    // 3D Integer arrays: array of 3D arrays (for真正3D arrays like DA-DF)
    public var dataIntegerArray3D: [[[[Int64]]]] = []

    // 3D String arrays: array of 3D arrays
    public var dataStringArray3D: [[[[String?]]]] = []

    public init() {
        setupDefaultStructures()
    }

    /// Setup default array structures with appropriate sizes
    private func setupDefaultStructures() {
        // Define array sizes based on VariableCode definitions
        // This would normally come from ConstantData (CSV files)

        // Note: VariableCode uses baseValue 0x00-0x14 for character 1D integer arrays
        // and 0x00-0x05 for 1D string arrays

        // 1D Integer Arrays (indexes 0x00-0x14 = 21 slots)
        // Matches positions: BASE=0, MAXBASE=1, ABL=2, TALENT=3, EXP=4, MARK=5,
        // PALAM=6, SOURCE=7, EX=8, CFLAG=9, JUEL=10, RELATION=11, EQUIP=12,
        // TEQUIP=13, STAIN=14, GOTJUEL=15, NOWEX=16, DOWNBASE=17, CUP=18, CDOWN=19, TCVAR=20
        dataIntegerArray = Array(repeating: [], count: 0x15)  // 21 arrays

        // Standard size for character 1D arrays (default 100)
        for i in 0..<dataIntegerArray.count {
            dataIntegerArray[i] = Array(repeating: 0, count: 100)
        }

        // 1D String Arrays (indexes 0x00-0x11 = 18 slots)
        // CSTR=0, STRNAME=1, etc.
        dataStringArray = Array(repeating: [], count: 0x12)  // 18 arrays
        for i in 0..<dataStringArray.count {
            dataStringArray[i] = Array(repeating: nil, count: 50)
        }

        // 2D Integer Arrays (indexes 0x00-0x0F = 16 slots)
        // CDFLAG=0, DA-DE=1-5, etc.
        dataIntegerArray2D = Array(repeating: [], count: 0x10)  // 16 arrays
        for i in 0..<dataIntegerArray2D.count {
            // Default: 10x10
            dataIntegerArray2D[i] = Array(repeating: Array(repeating: 0, count: 10), count: 10)
        }

        // 2D String Arrays (indexes 0x00-0x05 = 6 slots)
        dataStringArray2D = Array(repeating: [], count: 0x6)  // 6 arrays
        for i in 0..<dataStringArray2D.count {
            dataStringArray2D[i] = Array(repeating: Array(repeating: nil, count: 10), count: 10)
        }

        // 3D Integer Arrays (for future expansion like DA-DF)
        dataIntegerArray3D = Array(repeating: [], count: 0x4)  // 4 arrays of 3D
        for i in 0..<dataIntegerArray3D.count {
            // Default: 5x5x5 (smaller since true 3D is rare)
            dataIntegerArray3D[i] = Array(repeating: Array(repeating: Array(repeating: 0, count: 5), count: 5), count: 5)
        }

        // 3D String Arrays
        dataStringArray3D = Array(repeating: [], count: 0x2)  // 2 arrays of 3D
        for i in 0..<dataStringArray3D.count {
            dataStringArray3D[i] = Array(repeating: Array(repeating: Array(repeating: nil, count: 5), count: 5), count: 5)
        }
    }

    /// Get single integer value
    public func getInteger(index: Int) -> Int64 {
        guard index >= 0 && index < dataInteger.count else { return 0 }
        return dataInteger[index]
    }

    /// Set single integer value
    public func setInteger(index: Int, value: Int64) {
        guard index >= 0 && index < dataInteger.count else { return }
        dataInteger[index] = value
    }

    /// Get single string value
    public func getString(index: Int) -> String {
        guard index >= 0 && index < dataString.count else { return "" }
        return dataString[index] ?? ""
    }

    /// Set single string value
    public func setString(index: Int, value: String) {
        guard index >= 0 && index < dataString.count else { return }
        dataString[index] = value
    }

    /// Get 1D integer array
    public func getIntegerArray(index: Int) -> [Int64] {
        guard index >= 0 && index < dataIntegerArray.count else { return [] }
        return dataIntegerArray[index]
    }

    /// Get 1D string array
    public func getStringArray(index: Int) -> [String?] {
        guard index >= 0 && index < dataStringArray.count else { return [] }
        return dataStringArray[index]
    }

    /// Get 2D integer array
    public func getIntegerArray2D(index: Int) -> [[Int64]] {
        guard index >= 0 && index < dataIntegerArray2D.count else { return [] }
        return dataIntegerArray2D[index]
    }

    /// Get 2D string array
    public func getStringArray2D(index: Int) -> [[String?]] {
        guard index >= 0 && index < dataStringArray2D.count else { return [] }
        return dataStringArray2D[index]
    }

    /// Reset all character data to defaults
    public func reset() {
        // Clear all data first
        dataInteger = Array(repeating: 0, count: 22)
        dataString = Array(repeating: nil, count: 6)
        dataIntegerArray = []
        dataStringArray = []
        dataIntegerArray2D = []
        dataStringArray2D = []
        dataIntegerArray3D = []
        dataStringArray3D = []

        // Re-setup defaults
        setupDefaultStructures()
    }

    /// Batch set all values in an integer array
    public func setValueAll(_ varIndex: Int, _ value: Int64) {
        if varIndex >= 0 && varIndex < dataIntegerArray.count {
            for i in 0..<dataIntegerArray[varIndex].count {
                dataIntegerArray[varIndex][i] = value
            }
        }
    }

    /// Batch set values in 1D range
    public func setValueAll1D(_ varIndex: Int, _ value: Int64, _ start: Int, _ end: Int) {
        if varIndex >= 0 && varIndex < dataIntegerArray.count {
            let array = dataIntegerArray[varIndex]
            for i in start..<min(end, array.count) {
                dataIntegerArray[varIndex][i] = value
            }
        }
    }

    /// Batch set all values in 2D integer array
    public func setValueAll2D(_ varIndex: Int, _ value: Int64) {
        if varIndex >= 0 && varIndex < dataIntegerArray2D.count {
            for i in 0..<dataIntegerArray2D[varIndex].count {
                for j in 0..<dataIntegerArray2D[varIndex][i].count {
                    dataIntegerArray2D[varIndex][i][j] = value
                }
            }
        }
    }

    /// Batch set all values in a string array
    public func setValueAll(_ varIndex: Int, _ value: String) {
        if varIndex >= 0 && varIndex < dataStringArray.count {
            for i in 0..<dataStringArray[varIndex].count {
                dataStringArray[varIndex][i] = value
            }
        }
    }

    /// Batch set values in 1D string range
    public func setValueAll1D(_ varIndex: Int, _ value: String, _ start: Int, _ end: Int) {
        if varIndex >= 0 && varIndex < dataStringArray.count {
            let array = dataStringArray[varIndex]
            for i in start..<min(end, array.count) {
                dataStringArray[varIndex][i] = value
            }
        }
    }

    /// Batch set all values in 2D string array
    public func setValueAll2D(_ varIndex: Int, _ value: String) {
        if varIndex >= 0 && varIndex < dataStringArray2D.count {
            for i in 0..<dataStringArray2D[varIndex].count {
                for j in 0..<dataStringArray2D[varIndex][i].count {
                    dataStringArray2D[varIndex][i][j] = value
                }
            }
        }
    }

    // MARK: - Serialization Support

    /// Get all data for serialization
    public func getSerializationData() -> [String: Any] {
        return [
            "integers": dataInteger,
            "strings": dataString.map { $0 ?? "" },
            "intArrays": dataIntegerArray,
            "strArrays": dataStringArray.map { $0.map { $0 ?? "" } },
            "int2D": dataIntegerArray2D,
            "str2D": dataStringArray2D.map { $0.map { $0.map { $0 ?? "" } } }
        ]
    }

    /// Load data from serialization
    public func loadSerializationData(_ data: [String: Any]) {
        if let ints = data["integers"] as? [Int64] {
            dataInteger = ints
        }
        if let strs = data["strings"] as? [String] {
            dataString = strs.map { $0.isEmpty ? nil : $0 }
        }
        if let intArrays = data["intArrays"] as? [[Int64]] {
            dataIntegerArray = intArrays
        }
        if let strArrays = data["strArrays"] as? [[String]] {
            dataStringArray = strArrays.map { $0.map { $0.isEmpty ? nil : $0 } }
        }
        if let int2D = data["int2D"] as? [[[Int64]]] {
            dataIntegerArray2D = int2D
        }
        if let str2D = data["str2D"] as? [[[String]]] {
            dataStringArray2D = str2D.map { $0.map { $0.map { $0.isEmpty ? nil : $0 } } }
        }
    }
}

// MARK: - Equatable

public func == (lhs: CharacterData, rhs: CharacterData) -> Bool {
    return lhs.id == rhs.id
}

// MARK: - CharacterData Extensions for Debugging

extension CharacterData: CustomStringConvertible {
    public var description: String {
        var result = "CharacterData {\n"
        result += "  integers: \(dataInteger)\n"
        result += "  strings: \(dataString.map { $0 ?? "nil" })\n"
        result += "  intArrays: \(dataIntegerArray.count) arrays\n"
        result += "  ... \n"
        result += "}"
        return result
    }
}
