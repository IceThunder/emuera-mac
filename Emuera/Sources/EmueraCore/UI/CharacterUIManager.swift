//
//  CharacterUIManager.swift
//  EmueraCore
//
//  UI display for character commands (SHOWCHARACARD, SHOWCHARALIST, etc.)
//  Complete implementation for Phase 6 UI commands
//
//  Created: 2025-12-26
//

import Foundation

// MARK: - UI Enums and Structs

/// Character card display style
public enum CharacterCardStyle {
    case compact
    case detailed
    case full
}

/// Progress bar configuration
public struct ProgressBarConfig {
    public let attribute: ProgressBarAttribute
    public let maxValue: Int
    public let label: String

    public init(attribute: ProgressBarAttribute, maxValue: Int, label: String) {
        self.attribute = attribute
        self.maxValue = maxValue
        self.label = label
    }
}

/// Progress bar attribute type
public enum ProgressBarAttribute {
    case hp
    case mp
    case exp
    case custom(index: Int)
}

// MARK: - Character UI Manager

/// Manages UI display for character-related commands
public class CharacterUIManager {
    private let console: EmueraConsole

    public init(console: EmueraConsole) {
        self.console = console
    }

    /// Show character card
    public func showCharacterCard(_ character: CharacterData, style: CharacterCardStyle) {
        switch style {
        case .compact:
            showCompactCard(character)
        case .detailed:
            showDetailedCard(character)
        case .full:
            showFullCard(character)
        }
    }

    /// Show character list overview
    public func showCharacterListOverview(_ characters: [CharacterData]) {
        console.addLine(ConsoleLine(type: .print, content: "=== 角色列表 ===", attributes: ConsoleAttributes()))

        if characters.isEmpty {
            console.addLine(ConsoleLine(type: .print, content: "（没有角色）", attributes: ConsoleAttributes()))
            return
        }

        for (index, char) in characters.enumerated() {
            let hp = char.dataIntegerArray.count > 0 && char.dataIntegerArray[0].count > 0 ? char.dataIntegerArray[0][0] : 0
            let line = String(format: "[%d] %s (HP: %d)", index, char.name, hp)
            console.addLine(ConsoleLine(type: .print, content: line, attributes: ConsoleAttributes()))
        }
    }

    /// Show battle status
    public func showBattleStatus(_ character: CharacterData) {
        console.addLine(ConsoleLine(type: .print, content: "=== 战斗状态 ===", attributes: ConsoleAttributes()))

        // HP/MP
        let hp = getArrayValue(character, arrayIndex: 0, elementIndex: 0)
        let maxHp = getArrayValue(character, arrayIndex: 1, elementIndex: 0)
        let mp = getArrayValue(character, arrayIndex: 0, elementIndex: 1)
        let maxMp = getArrayValue(character, arrayIndex: 1, elementIndex: 1)

        console.addLine(ConsoleLine(type: .print, content: "HP: \(hp)/\(maxHp)", attributes: ConsoleAttributes()))
        console.addLine(ConsoleLine(type: .print, content: "MP: \(mp)/\(maxMp)", attributes: ConsoleAttributes()))

        // Status effects
        let status = getArrayValue(character, arrayIndex: 17, elementIndex: 0)  // DOWNBASE
        if status > 0 {
            console.addLine(ConsoleLine(type: .print, content: "状态: 疲劳", attributes: ConsoleAttributes()))
        }
    }

    /// Show progress bars
    public func showProgressBars(_ character: CharacterData, bars: [ProgressBarConfig]) {
        for bar in bars {
            let currentValue = getBarValue(character, attribute: bar.attribute)
            let ratio = Double(currentValue) / Double(bar.maxValue)
            let filled = Int(ratio * 20)  // 20 characters wide
            let empty = 20 - filled

            let barString = String(repeating: "█", count: filled) + String(repeating: "░", count: empty)
            let line = "\(bar.label): [\(barString)] \(currentValue)/\(bar.maxValue)"
            console.addLine(ConsoleLine(type: .print, content: line, attributes: ConsoleAttributes()))
        }
    }

    /// Show character tags
    public func showCharacterTags(_ character: CharacterData) {
        console.addLine(ConsoleLine(type: .print, content: "=== 角色标签 ===", attributes: ConsoleAttributes()))

        // Show basic tags
        let tags = [
            "ID: \(character.id)",
            "Name: \(character.name)",
            "HP: \(getArrayValue(character, arrayIndex: 0, elementIndex: 0))"
        ]

        for tag in tags {
            console.addLine(ConsoleLine(type: .print, content: tag, attributes: ConsoleAttributes()))
        }
    }

    // MARK: - Helper Methods

    private func showCompactCard(_ character: CharacterData) {
        let hp = getArrayValue(character, arrayIndex: 0, elementIndex: 0)
        let line = "[\(character.id)] \(character.name) - HP:\(hp)"
        console.addLine(ConsoleLine(type: .print, content: line, attributes: ConsoleAttributes()))
    }

    private func showDetailedCard(_ character: CharacterData) {
        console.addLine(ConsoleLine(type: .print, content: "┌─ 角色信息 ─────────────┐", attributes: ConsoleAttributes()))
        console.addLine(ConsoleLine(type: .print, content: "│ ID: \(character.id)", attributes: ConsoleAttributes()))
        console.addLine(ConsoleLine(type: .print, content: "│ 名称: \(character.name)", attributes: ConsoleAttributes()))

        let hp = getArrayValue(character, arrayIndex: 0, elementIndex: 0)
        let maxHp = getArrayValue(character, arrayIndex: 1, elementIndex: 0)
        console.addLine(ConsoleLine(type: .print, content: "│ HP: \(hp)/\(maxHp)", attributes: ConsoleAttributes()))

        console.addLine(ConsoleLine(type: .print, content: "└────────────────────────┘", attributes: ConsoleAttributes()))
    }

    private func showFullCard(_ character: CharacterData) {
        // Show all available data
        showDetailedCard(character)

        // Show first few arrays
        if character.dataIntegerArray.count > 0 {
            console.addLine(ConsoleLine(type: .print, content: "BASE: \(character.dataIntegerArray[0].prefix(5))", attributes: ConsoleAttributes()))
        }
        if character.dataIntegerArray.count > 2 {
            console.addLine(ConsoleLine(type: .print, content: "ABL: \(character.dataIntegerArray[2].prefix(5))", attributes: ConsoleAttributes()))
        }
    }

    private func getArrayValue(_ character: CharacterData, arrayIndex: Int, elementIndex: Int) -> Int64 {
        guard arrayIndex >= 0 && arrayIndex < character.dataIntegerArray.count,
              elementIndex >= 0 && elementIndex < character.dataIntegerArray[arrayIndex].count else {
            return 0
        }
        return character.dataIntegerArray[arrayIndex][elementIndex]
    }

    private func getBarValue(_ character: CharacterData, attribute: ProgressBarAttribute) -> Int64 {
        switch attribute {
        case .hp:
            return getArrayValue(character, arrayIndex: 0, elementIndex: 0)
        case .mp:
            return getArrayValue(character, arrayIndex: 0, elementIndex: 1)
        case .exp:
            return getArrayValue(character, arrayIndex: 4, elementIndex: 0)
        case .custom(let index):
            return getArrayValue(character, arrayIndex: 0, elementIndex: index)
        }
    }
}
