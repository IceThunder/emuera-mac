//
//  IdentifierDictionary.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/19.
//

import Foundation

/// Manages identifiers (macros, variables, functions) and detects name conflicts
public final class IdentifierDictionary {
    private enum DefinedNameType {
        case none
        case reserved
        case systemVariable
        case systemMethod
        case systemInstrument
        case userGlobalVariable
        case userMacro
        case userRefMethod
        case nameSpace
    }

    private static let badSymbolAsIdentifier: [Character] = [
        "+", "-", "*", "/", "%", "=", "!", "<", ">", "|", "&", "^", "~",
        " ", "　", "\t", "\"", "(", ")", "{", "}", "[", "]", ",", ".", ":",
        "\\", "@", "$", "#", "?", ";", "'"
    ]

    private var nameDic: [String: DefinedNameType] = [:]
    private var macroDic: [String: DefineMacro] = [:]
    private var userDefinedVariables: [String: VariableToken] = [:]
    private var functionDic: [String: FunctionIdentifier] = [:]

    public init() {
        initializeReservedWords()
    }

    private func initializeReservedWords() {
        let reserved = ["IS", "TO", "INT", "STR", "REFFUNC", "STATIC", "DYNAMIC",
                       "GLOBAL", "PRIVATE", "SAVEDATA", "CHARADATA", "REF",
                       "__DEBUG__", "__SKIP__", "_"]
        for word in reserved {
            nameDic[word] = .reserved
        }
    }

    /// Check if a name is valid as an identifier
    public static func isValidIdentifier(_ name: String) -> Bool {
        if name.isEmpty { return false }
        if name.contains(where: { badSymbolAsIdentifier.contains($0) }) { return false }
        // Check first character
        guard let first = name.first else { return false }
        if !first.isLetter && first != "_" { return false }
        return true
    }

    /// Check if a name is an event label
    public static func isEventLabelName(_ labelName: String) -> Bool {
        let eventLabels = ["EVENTFIRST", "EVENTTRAIN", "EVENTSHOP", "EVENTBUY",
                          "EVENTCOM", "EVENTTURNEND", "EVENTCOMEND", "EVENTEND", "EVENTLOAD"]
        return eventLabels.contains(labelName)
    }

    /// Check if a name is a system label
    public static func isSystemLabelName(_ labelName: String) -> Bool {
        let systemLabels = ["EVENTFIRST", "EVENTTRAIN", "EVENTSHOP", "EVENTBUY",
                           "EVENTCOM", "EVENTTURNEND", "EVENTCOMEND", "EVENTEND",
                           "SHOW_STATUS", "SHOW_USERCOM", "USERCOM", "SOURCE_CHECK",
                           "CALLTRAINEND", "SHOW_JUEL", "SHOW_ABLUP_SELECT", "USERABLUP",
                           "SHOW_SHOP", "SAVEINFO", "USERSHOP", "EVENTLOAD",
                           "TITLE_LOADGAME", "SYSTEM_AUTOSAVE", "SYSTEM_TITLE", "SYSTEM_LOADEND"]
        return systemLabels.contains(labelName)
    }

    /// Add a macro
    public func addMacro(_ macro: DefineMacro) throws {
        let key = macro.keyword
        if let existing = nameDic[key] {
            if existing == .userMacro {
                throw EmueraError.duplicateMacro(name: key)
            }
            if existing == .reserved {
                throw EmueraError.reservedNameUsed(name: key)
            }
        }
        nameDic[key] = .userMacro
        macroDic[key] = macro
    }

    /// Check user macro name for conflicts
    public func checkUserMacroName(ref errMes: inout String, ref errLevel: inout Int, name: String) {
        errMes = ""
        errLevel = -1

        if let existing = nameDic[name] {
            switch existing {
            case .reserved:
                errMes = "予約語\"\(name)\"は使用できません"
                errLevel = 2
            case .systemVariable, .systemMethod, .systemInstrument:
                errMes = "システム定義\"\(name)\"と衝突します"
                errLevel = 2
            case .userGlobalVariable:
                errMes = "ユーザー定義変数\"\(name)\"と衝突します"
                errLevel = 2
            case .userMacro:
                errMes = "マクロ\"\(name)\"が重複定義されています"
                errLevel = 2
            case .userRefMethod:
                errMes = "ユーザー定義関数\"\(name)\"と衝突します"
                errLevel = 2
            case .nameSpace:
                errMes = "名前空間\"\(name)\"と衝突します"
                errLevel = 2
            default:
                break
            }
        }
    }

    /// Add user-defined variable
    public func addUserDefinedVariable(_ variable: VariableToken) throws {
        let name = variable.varName
        if let existing = nameDic[name] {
            if existing == .userGlobalVariable {
                throw EmueraError.duplicateVariable(name: name)
            }
            if existing == .reserved {
                throw EmueraError.reservedNameUsed(name: name)
            }
        }
        nameDic[name] = .userGlobalVariable
        userDefinedVariables[name] = variable
    }

    /// Get a macro by name
    public func getMacro(_ name: String) -> DefineMacro? {
        return macroDic[name]
    }

    /// Get a variable by name
    public func getVariable(_ name: String) -> VariableToken? {
        return userDefinedVariables[name]
    }

    /// Check if name exists
    public func contains(_ name: String) -> Bool {
        return nameDic[name] != nil
    }

    /// Add user-defined function
    public func addFunction(_ function: FunctionIdentifier) throws {
        let name = function.name
        if let existing = nameDic[name] {
            if existing == .userRefMethod {
                throw EmueraError.duplicateFunction(name: name)
            }
            if existing == .reserved {
                throw EmueraError.reservedNameUsed(name: name)
            }
            if existing == .userGlobalVariable {
                throw EmueraError.duplicateVariable(name: name)
            }
            if existing == .userMacro {
                throw EmueraError.duplicateMacro(name: name)
            }
        }
        nameDic[name] = .userRefMethod
        functionDic[name] = function
    }

    /// Get a function by name
    public func getFunction(_ name: String) -> FunctionIdentifier? {
        return functionDic[name]
    }

    /// Clear all definitions
    public func clear() {
        nameDic.removeAll()
        macroDic.removeAll()
        userDefinedVariables.removeAll()
        functionDic.removeAll()
        initializeReservedWords()
    }
}
