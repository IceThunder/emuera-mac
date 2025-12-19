//
//  TokenData.swift
//  EmueraCore
//
//  Manager for all variable tokens
//  Provides lookup and access to variables by name
//
//  Created: 2025-12-19
//

import Foundation

/// Manages all variable tokens and provides access to variables by name
public class TokenData {
    private let varData: VariableData
    private var tokens: [String: VariableToken] = [:]
    private var tokenCache: [String: VariableToken] = [:]

    public init(varData: VariableData) {
        print("TokenData.init start")
        self.varData = varData
        print("VariableData.dataIntegerArray.count = \(varData.dataIntegerArray.count)")
        print("About to initialize tokens")
        initializeAllTokens()
        print("TokenData.init complete")
    }

    /// Initialize all built-in variable tokens
    private func initializeAllTokens() {
        // MARK: - Single Integer Variables (stored as 1-element arrays in dataIntegerArray)
        // These use IntVariableToken which accesses array[0]
        createIntTokens([
            (.DAY, "DAY"), (.MONEY, "MONEY"), (.EJAC, "EJAC"),
            (.RESULT, "RESULT"), (.COUNT, "COUNT"), (.TARGET, "TARGET"),
            (.ASSI, "ASSI"), (.MASTER, "MASTER"), (.NOITEM, "NOITEM"),
            (.PLAYER, "PLAYER"), (.TIME, "TIME"), (.BOUGHT, "BOUGHT"),
            (.LOSEBASE, "LOSEBASE"), (.ASSIPLAY, "ASSIPLAY"), (.ITEMSALES, "ITEMSALES"),
            (.PBAND, "PBAND"), (.NO, "NO"), (.ISASSI, "ISASSI")
        ])

        // MARK: - 1D Integer Array Variables (A-Z)
        // These use Int1DVariableToken which accesses array[index]
        print("DEBUG: VariableCode.A = \(VariableCode.A), baseValue = \(VariableCode.A.baseValue)")
        createInt1DTokens([
            (.A, "A"), (.B, "B"), (.C, "C"), (.D, "D"), (.E, "E"), (.F, "F"),
            (.G, "G"), (.H, "H"), (.I, "I"), (.J, "J"), (.K, "K"), (.L, "L"),
            (.M, "M"), (.N, "N"), (.O, "O"), (.P, "P"), (.Q, "Q"), (.R, "R"),
            (.S, "S"), (.T, "T"), (.U, "U"), (.V, "V"), (.W, "W"), (.X, "X"),
            (.Y, "Y"), (.Z, "Z")
        ])

        // MARK: - System 1D Integer Arrays
        createInt1DTokens([
            (.ITEM, "ITEM"), (.FLAG, "FLAG"), (.TFLAG, "TFLAG"),
            (.UP, "UP"), (.DOWN, "DOWN"), (.SELECTCOM, "SELECTCOM"),
            (.PREVCOM, "PREVCOM"), (.NEXTCOM, "NEXTCOM"),
            (.PALAMLV, "PALAMLV"), (.EXPLV, "EXPLV")
        ])

        // MARK: - Extended 1D Integer Arrays
        createInt1DTokens([
            (.ITEMPRICE, "ITEMPRICE"), (.LOCAL, "LOCAL"), (.ARG, "ARG"),
            (.GLOBAL, "GLOBAL"), (.RANDDATA, "RANDDATA")
        ])

        // MARK: - Single String Variables
        createStrTokens([
            (.RESULTS, "RESULTS")
        ])

        // MARK: - 1D String Arrays
        createStr1DTokens([
            (.SAVESTR, "SAVESTR"), (.STR, "STR")
        ])

        // MARK: - Character Data Variables (Single Integer)
        // These need special handling - placeholder for now
        tokens["NO"] = CharaIntVariableToken(code: .NO, varData: varData)
        tokens["ISASSI"] = CharaIntVariableToken(code: .ISASSI, varData: varData)

        // MARK: - Character Data 1D Integer Arrays
        tokens["BASE"] = CharaInt1DVariableToken(code: .BASE, varData: varData)
        tokens["MAXBASE"] = CharaInt1DVariableToken(code: .MAXBASE, varData: varData)
        tokens["ABL"] = CharaInt1DVariableToken(code: .ABL, varData: varData)
        tokens["TALENT"] = CharaInt1DVariableToken(code: .TALENT, varData: varData)
        tokens["EXP"] = CharaInt1DVariableToken(code: .EXP, varData: varData)
        tokens["MARK"] = CharaInt1DVariableToken(code: .MARK, varData: varData)
        tokens["PALAM"] = CharaInt1DVariableToken(code: .PALAM, varData: varData)
        tokens["SOURCE"] = CharaInt1DVariableToken(code: .SOURCE, varData: varData)
        tokens["EX"] = CharaInt1DVariableToken(code: .EX, varData: varData)
        tokens["CFLAG"] = CharaInt1DVariableToken(code: .CFLAG, varData: varData)
        tokens["JUEL"] = CharaInt1DVariableToken(code: .JUEL, varData: varData)
        tokens["RELATION"] = CharaInt1DVariableToken(code: .RELATION, varData: varData)
        tokens["EQUIP"] = CharaInt1DVariableToken(code: .EQUIP, varData: varData)
        tokens["TEQUIP"] = CharaInt1DVariableToken(code: .TEQUIP, varData: varData)
        tokens["STAIN"] = CharaInt1DVariableToken(code: .STAIN, varData: varData)
        tokens["GOTJUEL"] = CharaInt1DVariableToken(code: .GOTJUEL, varData: varData)
        tokens["NOWEX"] = CharaInt1DVariableToken(code: .NOWEX, varData: varData)
        tokens["DOWNBASE"] = CharaInt1DVariableToken(code: .DOWNBASE, varData: varData)
        tokens["CUP"] = CharaInt1DVariableToken(code: .CUP, varData: varData)
        tokens["CDOWN"] = CharaInt1DVariableToken(code: .CDOWN, varData: varData)
        tokens["TCVAR"] = CharaInt1DVariableToken(code: .TCVAR, varData: varData)

        // MARK: - Character Data Single String
        tokens["NAME"] = CharaStrVariableToken(code: .NAME, varData: varData)
        tokens["CALLNAME"] = CharaStrVariableToken(code: .CALLNAME, varData: varData)
        tokens["NICKNAME"] = CharaStrVariableToken(code: .NICKNAME, varData: varData)
        tokens["MASTERNAME"] = CharaStrVariableToken(code: .MASTERNAME, varData: varData)

        // MARK: - Character Data 1D String Array
        tokens["CSTR"] = CharaStr1DVariableToken(code: .CSTR, varData: varData)

        // MARK: - Character Data 2D Integer Array
        tokens["CDFLAG"] = CharaInt2DVariableToken(code: .CDFLAG, varData: varData)

        // MARK: - Special Calc Variables
        tokens["RAND"] = RandToken(varData: varData)
        tokens["CHARANUM"] = CHARANUM_Token(varData: varData)
        tokens["__INT_MAX__"] = INT_MAX_Token(varData: varData)
        tokens["__INT_MIN__"] = INT_MIN_Token(varData: varData)

        // MARK: - User-Defined Places (would be loaded from CSV/headers)
        // These would be initialized from actual game content
    }

    private func createIntTokens(_ pairs: [(VariableCode, String)]) {
        for (code, name) in pairs {
            tokens[name] = IntVariableToken(varCode: code, varData: varData)
        }
    }

    private func createInt1DTokens(_ pairs: [(VariableCode, String)]) {
        for (code, name) in pairs {
            tokens[name] = Int1DVariableToken(varCode: code, varData: varData)
        }
    }

    private func createStrTokens(_ pairs: [(VariableCode, String)]) {
        for (code, name) in pairs {
            tokens[name] = StrVariableToken(varCode: code, varData: varData)
        }
    }

    private func createStr1DTokens(_ pairs: [(VariableCode, String)]) {
        for (code, name) in pairs {
            tokens[name] = Str1DVariableToken(varCode: code, varData: varData)
        }
    }

    /// Get a token by name (with caching)
    public func getToken(_ name: String) -> VariableToken? {
        // Check cache first
        if let cached = tokenCache[name] {
            return cached
        }

        // Check predefined tokens
        if let token = tokens[name] {
            tokenCache[name] = token
            return token
        }

        // Handle array syntax: NAME:INDEX
        if let colonRange = name.range(of: ":") {
            let baseName = String(name[..<colonRange.lowerBound])
            if let baseToken = tokens[baseName] {
                // Note: For array accesses like A:5, the index is passed in arguments
                // The token itself handles the index validation
                return baseToken
            }
        }

        // Handle user-defined variables (would need to check dynamic registry)
        // For now, return nil
        return nil
    }

    /// Get or create and cache a token
    public func getOrLoadToken(_ name: String) -> VariableToken? {
        if let token = getToken(name) {
            return token
        }

        // Try to parse as array index
        if let colonRange = name.range(of: ":") {
            let baseName = String(name[..<colonRange.lowerBound])
            if let baseToken = getToken(baseName) {
                tokenCache[name] = baseToken
                return baseToken
            }
        }

        return nil
    }

    /// Get integer value from variable
    public func getIntValue(_ name: String, arguments: [Int64] = [], exm: ExpressionMediator? = nil) throws -> Int64 {
        guard let token = getOrLoadToken(name) else {
            throw CodeEE("未定義の変数'\(name)'です")
        }
        return try token.getIntValue(exm: exm, arguments: arguments)
    }

    /// Get string value from variable
    public func getStrValue(_ name: String, arguments: [Int64] = [], exm: ExpressionMediator? = nil) throws -> String {
        guard let token = getOrLoadToken(name) else {
            throw CodeEE("未定義の変数'\(name)'です")
        }
        return try token.getStrValue(exm: exm, arguments: arguments)
    }

    /// Set integer value to variable
    public func setIntValue(_ name: String, value: Int64, arguments: [Int64] = []) throws {
        guard let token = getOrLoadToken(name) else {
            throw CodeEE("未定義の変数'\(name)'です")
        }
        try token.setValue(value, arguments: arguments)
    }

    /// Set string value to variable
    public func setStrValue(_ name: String, value: String, arguments: [Int64] = []) throws {
        guard let token = getOrLoadToken(name) else {
            throw CodeEE("未定義の変数'\(name)'です")
        }
        try token.setValue(value, arguments: arguments)
    }

    /// Add +1 value to integer variable (++)
    public func plusOne(_ name: String, arguments: [Int64] = []) throws -> Int64 {
        guard let token = getOrLoadToken(name) else {
            throw CodeEE("未定義の変数'\(name)'です")
        }
        return try token.plusValue(1, arguments: arguments)
    }

    /// Add value to integer variable (+=)
    public func plusValue(_ name: String, value: Int64, arguments: [Int64] = []) throws -> Int64 {
        guard let token = getOrLoadToken(name) else {
            throw CodeEE("未定義の変数'\(name)'です")
        }
        return try token.plusValue(value, arguments: arguments)
    }

    /// Is variable saved in save data?
    public func isSavedataVariable(_ name: String) -> Bool {
        guard let token = getToken(name) else { return false }
        return token.isSavedata
    }

    /// Reset all tokens to default values (when starting new game)
    public func resetAll() {
        tokenCache.removeAll()
        for token in tokens.values {
            token.setDefault()
        }
    }

    /// Get all variable names for debugging
    public func getAllVariableNames() -> [String] {
        return Array(tokens.keys).sorted()
    }

    /// Print all token information (for debugging)
    public func dumpTokens() {
        print("=== Token Registry Dump ===")
        for (name, token) in tokens.sorted(by: { $0.key < $1.key }) {
            print("\(name): \(token.code) - type=\(token.code.isInteger ? "int" : "str"), dim=\(token.dimension)")
        }
    }

    // MARK: - Dynamic Registration Methods

    /// Register a new 2D integer array variable
    public func register2DIntVariable(_ name: String, baseValue: Int64) {
        let code = VariableCode(rawValue: baseValue | VariableCode.__INTEGER__ | VariableCode.__ARRAY_2D__)
        tokens[name] = Int2DVariableToken(varCode: code, varData: varData)
    }

    /// Register a new character 1D array variable
    public func registerCharaInt1DVariable(_ name: String, baseValue: Int64) {
        let code = VariableCode(rawValue: baseValue | VariableCode.__CHARACTER_DATA__ | VariableCode.__INTEGER__ | VariableCode.__ARRAY_1D__)
        tokens[name] = CharaInt1DVariableToken(code: code, varData: varData)
    }

    /// Register a user-defined variable from #DIM/#DIMS
    public func registerUserDefinedVariable(_ data: UserDefinedVariableData) throws {
        guard let name = data.name else {
            throw EmueraError.headerFileError(message: "Variable name is nil", position: nil)
        }

        // Build VariableCode based on properties
        var rawValue: Int64 = 0

        // Type flags
        if data.typeIsStr {
            rawValue |= VariableCode.__STRING__
        } else {
            rawValue |= VariableCode.__INTEGER__
        }

        // Dimension flags
        if data.dimension == 2 {
            rawValue |= VariableCode.__ARRAY_2D__
        } else if data.dimension == 1 {
            rawValue |= VariableCode.__ARRAY_1D__
        }

        // Character data flag
        if data.charaData {
            rawValue |= VariableCode.__CHARACTER_DATA__
        }

        // Special flags
        if data.`const` {
            rawValue |= VariableCode.__CONSTANT__
        }

        // Create VariableCode
        let code = VariableCode(rawValue: rawValue)

        // Create appropriate token based on properties
        let token: VariableToken

        if data.reference {
            // Reference token
            token = ReferenceToken(varData: varData, name: name, isPrivate: data.`private`, isGlobal: data.global, isSavedata: data.save)
        } else if data.`static` && !data.global && data.dimension == 1 && !data.typeIsStr && !data.charaData {
            // Static 1D int array
            token = StaticInt1DVariableToken(varData: varData, name: name, sizes: data.lengths, isGlobal: data.global, isSavedata: data.save)
        } else if data.charaData {
            // Character data - use UserDefinedVariableToken base class
            token = UserDefinedVariableToken(varCode: code, data: varData, name: name, isPrivate: data.`private`, isConst: data.`const`,
                                           sizes: data.lengths, isGlobal: data.global, isSavedata: data.save)
            token.isCharacterData = true
            token.dimension = data.dimension
        } else if data.typeIsStr {
            // String variable - use UserDefinedVariableToken
            token = UserDefinedVariableToken(varCode: code, data: varData, name: name, isPrivate: data.`private`, isConst: data.`const`,
                                           sizes: data.lengths, isGlobal: data.global, isSavedata: data.save)
            token.dimension = data.dimension
        } else {
            // Integer variable
            if data.dimension == 2 {
                // 2D int array
                token = UserDefinedVariableToken(varCode: code, data: varData, name: name, isPrivate: data.`private`, isConst: data.`const`,
                                               sizes: data.lengths, isGlobal: data.global, isSavedata: data.save)
                token.dimension = 2
            } else if data.dimension == 1 {
                // 1D int array - use StaticInt1DVariableToken if static, otherwise UserDefinedVariableToken
                if data.`static` && !data.global {
                    token = StaticInt1DVariableToken(varData: varData, name: name, sizes: data.lengths, isGlobal: data.global, isSavedata: data.save)
                } else {
                    token = UserDefinedVariableToken(varCode: code, data: varData, name: name, isPrivate: data.`private`, isConst: data.`const`,
                                                   sizes: data.lengths, isGlobal: data.global, isSavedata: data.save)
                    token.dimension = 1
                }
            } else {
                // Single value
                token = UserDefinedVariableToken(varCode: code, data: varData, name: name, isPrivate: data.`private`, isConst: data.`const`,
                                               sizes: [1], isGlobal: data.global, isSavedata: data.save)
                token.dimension = 0
            }
        }

        // Add to dictionary
        tokens[name] = token
    }
}
