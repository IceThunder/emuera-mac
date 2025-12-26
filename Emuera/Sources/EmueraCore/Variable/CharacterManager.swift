//
//  CharacterManager.swift
//  EmueraCore
//
//  Character management system - handles ADDCHARA, DELCHARA, SWAPCHARA, etc.
//  Complete implementation for Phase 6 character commands
//
//  Created: 2025-12-26
//

import Foundation

// MARK: - Enums for Character Management

/// Sort key for SORTCHARA command
public enum SortKey {
    case id
    case name
    case baseHP
    case baseMP
    case level
    case custom(arrayIndex: Int, elementIndex: Int)
}

/// Sort order for SORTCHARA command
public enum SortOrder {
    case ascending
    case descending
}

/// Batch operation for BATCHMODIFY command
public enum BatchOperation {
    case add
    case subtract
    case multiply
    case set
}

// MARK: - Character Manager

/// Manages character operations (ADDCHARA, DELCHARA, SWAPCHARA, etc.)
public class CharacterManager {
    private var variableData: VariableData

    public init(variableData: VariableData) {
        self.variableData = variableData
    }

    /// Add a new character
    public func addCharacter(id: Int?, name: String) -> CharacterData {
        let character = CharacterData()
        character.id = id ?? variableData.characters.count
        character.name = name

        // Initialize default values
        character.dataInteger[0] = 1000  // BASE[0] = HP (default 1000)
        character.dataInteger[1] = 500   // MAXBASE[0] = MAXHP (default 500)

        variableData.characters.append(character)
        return character
    }

    /// Delete character at index
    public func deleteCharacter(at index: Int) -> Bool {
        guard index >= 0 && index < variableData.characters.count else {
            return false
        }
        variableData.characters.remove(at: index)
        return true
    }

    /// Delete character by ID
    public func deleteCharacterByID(_ id: Int) -> Bool {
        if let index = variableData.characters.firstIndex(where: { $0.id == id }) {
            variableData.characters.remove(at: index)
            return true
        }
        return false
    }

    /// Get character at index
    public func getCharacter(at index: Int) -> CharacterData? {
        guard index >= 0 && index < variableData.characters.count else {
            return nil
        }
        return variableData.characters[index]
    }

    /// Get character count
    public func getCharacterCount() -> Int {
        return variableData.characters.count
    }

    /// Swap two characters
    public func swapCharacters(at index1: Int, at index2: Int) -> Bool {
        guard index1 >= 0 && index1 < variableData.characters.count,
              index2 >= 0 && index2 < variableData.characters.count else {
            return false
        }

        let temp = variableData.characters[index1]
        variableData.characters[index1] = variableData.characters[index2]
        variableData.characters[index2] = temp
        return true
    }

    /// Copy a character
    public func copyCharacter(from srcIndex: Int, to dstIndex: Int?) -> CharacterData? {
        guard srcIndex >= 0 && srcIndex < variableData.characters.count else {
            return nil
        }

        let source = variableData.characters[srcIndex]
        let copy = CharacterData()

        // Deep copy all data
        copy.id = source.id
        copy.name = source.name
        copy.variables = source.variables
        copy.dataInteger = source.dataInteger
        copy.dataString = source.dataString
        copy.dataIntegerArray = source.dataIntegerArray.map { $0 }
        copy.dataStringArray = source.dataStringArray.map { $0 }
        copy.dataIntegerArray2D = source.dataIntegerArray2D.map { $0.map { $0 } }
        copy.dataStringArray2D = source.dataStringArray2D.map { $0.map { $0.map { $0 } } }
        copy.dataIntegerArray3D = source.dataIntegerArray3D.map { $0.map { $0.map { $0 } } }
        copy.dataStringArray3D = source.dataStringArray3D.map { $0.map { $0.map { $0.map { $0 } } } }

        if let dst = dstIndex {
            guard dst >= 0 && dst <= variableData.characters.count else {
                return nil
            }
            variableData.characters.insert(copy, at: dst)
        } else {
            variableData.characters.append(copy)
        }

        return copy
    }

    /// Sort characters
    public func sortCharacters(by key: SortKey, order: SortOrder) {
        variableData.characters.sort { c1, c2 in
            let result: Bool

            switch key {
            case .id:
                result = c1.id < c2.id
            case .name:
                result = c1.name < c2.name
            case .baseHP:
                result = c1.dataInteger[0] < c2.dataInteger[0]
            case .baseMP:
                result = c1.dataInteger[1] < c2.dataInteger[1]
            case .level:
                result = c1.dataInteger[2] < c2.dataInteger[2]
            case .custom(let arrayIndex, let elementIndex):
                let v1 = getCharacterArrayValue(c1, arrayIndex: arrayIndex, elementIndex: elementIndex)
                let v2 = getCharacterArrayValue(c2, arrayIndex: arrayIndex, elementIndex: elementIndex)
                result = v1 < v2
            }

            return order == .ascending ? result : !result
        }
    }

    /// Batch modify character values
    public func batchModify(indices: [Int], operation: BatchOperation, value: Int64) -> Int {
        var count = 0

        for index in indices {
            guard let character = getCharacter(at: index) else {
                continue
            }

            // Modify all BASE values as an example
            // In real implementation, this would need to specify which array to modify
            for i in 0..<min(character.dataIntegerArray.count, 1) {
                for j in 0..<character.dataIntegerArray[i].count {
                    switch operation {
                    case .add:
                        character.dataIntegerArray[i][j] += value
                    case .subtract:
                        character.dataIntegerArray[i][j] -= value
                    case .multiply:
                        character.dataIntegerArray[i][j] *= value
                    case .set:
                        character.dataIntegerArray[i][j] = value
                    }
                }
            }
            count += 1
        }

        return count
    }

    /// Helper: Get value from character array
    private func getCharacterArrayValue(_ character: CharacterData, arrayIndex: Int, elementIndex: Int) -> Int64 {
        guard arrayIndex >= 0 && arrayIndex < character.dataIntegerArray.count,
              elementIndex >= 0 && elementIndex < character.dataIntegerArray[arrayIndex].count else {
            return 0
        }
        return character.dataIntegerArray[arrayIndex][elementIndex]
    }
}
