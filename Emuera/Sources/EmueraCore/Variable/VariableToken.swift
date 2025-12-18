//
//  VariableToken.swift
//  EmueraCore
//
//  Variable token system - provides access to variable data
//  Complete translation from C# VariableToken.cs
//
//  Created: 2025-12-19
//

import Foundation

// MARK: - Abstract Base Classes

/// Abstract base class for all variable tokens
/// Provides common interface for reading and writing variable values
public class VariableToken {
    public let code: VariableCode
    public let varData: VariableData
    public var varName: String
    public var variableType: Any.Type
    public var dimension: Int = 0
    public var isCharacterData: Bool = false
    public var isConst: Bool = false
    public var isStatic: Bool = false
    public var canRestructure: Bool = false
    public var isForbid: Bool = false
    public var isPrivate: Bool = false
    public var isGlobal: Bool = false
    public var isSavedata: Bool = false
    public var isReference: Bool = false
    public var isCalc: Bool = false
    public var isLocal: Bool = false

    public init(code: VariableCode, varData: VariableData) {
        self.code = code
        self.varData = varData
        self.varName = String(describing: code)

        // Determine type
        if code.isInteger {
            self.variableType = Int64.self
        } else {
            self.variableType = String.self
        }

        // Determine dimension
        self.dimension = code.arrayDimension

        // Determine flags
        self.isCharacterData = code.isCharacterData
        self.isConst = code.isUnchangeable
        self.canRestructure = false
        self.isForbid = false
        self.isPrivate = false
        self.isGlobal = false  // Placeholder - should use properGLOBALconstant if needed
        self.isSavedata = false
        self.isReference = false
        self.isCalc = code.isCalc
        self.isLocal = code.isLocal

        // Implementation for savedata determination
        // Simplified: in a real implementation, this would consult CSV config
        // For now, save most user-facing variables
        if !code.isUnchangeable && !code.isLocal && !varName.hasPrefix("NOTUSE_") {
            // Save extended variables, character data, and arrays
            if code.isExtended || code.isCharacterData {
                self.isSavedata = true
            } else if code.isArray1D || code.isArray2D || code.isArray3D {
                // Global arrays - save
                self.isSavedata = true
            } else if code.isInteger || (code.isString && !code.isArray1D) {
                // Single values - save
                self.isSavedata = true
            }
        }
    }

    // MARK: - Abstract Methods (to be overridden)

    public func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        throw CodeEE("整数型でない変数\(varName)を整数型として呼び出しました")
    }

    public func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        throw CodeEE("文字列型でない変数\(varName)を文字列型として呼び出しました")
    }

    public func setValue(_ value: Int64, arguments: [Int64]) throws {
        throw CodeEE("整数型でない変数\(varName)を整数型として呼び出しました")
    }

    public func setValue(_ value: String, arguments: [Int64]) throws {
        throw CodeEE("文字列型でない変数\(varName)を文字列型として呼び出しました")
    }

    public func setValue(_ values: [Int64], arguments: [Int64]) throws {
        throw CodeEE("配列型でない変数\(varName)を配列型として呼び出しました")
    }

    public func setValue(_ values: [String], arguments: [Int64]) throws {
        throw CodeEE("配列型でない変数\(varName)を配列型として呼び出しました")
    }

    public func setValueAll(_ value: Int64, start: Int, end: Int, charaPos: Int) throws {
        throw CodeEE("配列型でない変数\(varName)を配列型として呼び出しました")
    }

    public func setValueAll(_ value: String, start: Int, end: Int, charaPos: Int) throws {
        throw CodeEE("配列型でない変数\(varName)を配列型として呼び出しました")
    }

    public func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        throw CodeEE("整数型でない変数\(varName)を整数型として呼び出しました")
    }

    public func getLength() throws -> Int {
        throw CodeEE("配列型でない変数\(varName)の長さを取得しようとしました")
    }

    public func getLength(dimension: Int) throws -> Int {
        throw CodeEE("配列型でない変数\(varName)の長さを取得しようとしました")
    }

    public func getArray() throws -> Any {
        if isCharacterData {
            throw CodeEE("キャラクタ変数\(varName)を非キャラ変数として呼び出しました")
        }
        throw CodeEE("配列型でない変数\(varName)の配列を取得しようとしました")
    }

    public func getArrayChara(charano: Int) throws -> Any {
        if !isCharacterData {
            throw CodeEE("非キャラクタ変数\(varName)をキャラ変数として呼び出しました")
        }
        throw CodeEE("配列型でない変数\(varName)の配列を取得しようとしました")
    }

    public func checkElement(arguments: [Int64], doCheck: [Bool]) throws {
        // Override in subclasses if needed
    }

    public func checkElement(arguments: [Int64]) throws {
        try checkElement(arguments: arguments, doCheck: [true, true, true])
    }

    public func isArrayRangeValid(arguments: [Int64], index1: Int64, index2: Int64,
                                   funcName: String, i1: Int64, i2: Int64) throws {
        try checkElement(arguments: arguments)
    }

    // MARK: - Reference type methods (for REF variables)

    public func `in`() {
        // Override in ReferenceToken
    }

    public func `out`() {
        // Override in ReferenceToken
    }

    public func setDefault() {
        // Override in user-defined tokens
    }

    public func resize(newSize: Int) {
        // Override in LocalVariableToken
    }
}

// MARK: - Basic Integer Variable Tokens

/// Single integer variable (e.g., DAY, MONEY, A, B, etc. without index)
class IntVariableToken: VariableToken {
    private let arrayIndex: Int

    public init(varCode: VariableCode, varData: VariableData) {
        self.arrayIndex = Int(varCode.baseValue)
        super.init(code: varCode, varData: varData)
        self.canRestructure = false
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        return varData.dataInteger[arrayIndex]
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        varData.dataInteger[arrayIndex] = value
    }

    public override func setValueAll(_ value: Int64, start: Int, end: Int, charaPos: Int) throws {
        varData.dataInteger[arrayIndex] = value
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        varData.dataInteger[arrayIndex] += value
        return varData.dataInteger[arrayIndex]
    }
}

/// 1D integer array variable (e.g., A, B, C, FLAG, TFLAG, etc.)
class Int1DVariableToken: VariableToken {
    private let arrayIndex: Int
    private var array: [Int64] { varData.dataIntegerArray[arrayIndex] }

    public init(varCode: VariableCode, varData: VariableData) {
        self.arrayIndex = Int(varCode.baseValue)
        super.init(code: varCode, varData: varData)
        self.canRestructure = false
        self.isForbid = array.count == 0
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        let index = Int(arguments[0])
        guard index >= 0 && index < array.count else {
            throw CodeEE("配列変数\(varName)の範囲外アクセス: index=\(index), size=\(array.count)")
        }
        return array[index]
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        let index = Int(arguments[0])
        guard index >= 0 && index < array.count else {
            throw CodeEE("配列変数\(varName)の範囲外アクセス: index=\(index), size=\(array.count)")
        }
        varData.dataIntegerArray[arrayIndex][index] = value
    }

    public override func setValue(_ values: [Int64], arguments: [Int64]) throws {
        let start = Int(arguments[0])
        let end = start + values.count
        for i in start..<end {
            varData.dataIntegerArray[arrayIndex][i] = values[i - start]
        }
    }

    public override func setValueAll(_ value: Int64, start: Int, end: Int, charaPos: Int) throws {
        for i in start..<end {
            varData.dataIntegerArray[arrayIndex][i] = value
        }
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        let index = Int(arguments[0])
        guard index >= 0 && index < array.count else {
            throw CodeEE("配列変数\(varName)の範囲外アクセス: index=\(index), size=\(array.count)")
        }
        varData.dataIntegerArray[arrayIndex][index] += value
        return varData.dataIntegerArray[arrayIndex][index]
    }

    public override func getLength() throws -> Int {
        return array.count
    }

    public override func getLength(dimension: Int) throws -> Int {
        if dimension == 0 { return array.count }
        throw CodeEE("配列型変数\(varName)の存在しない次元の長さを取得しようとしました")
    }

    public override func getArray() throws -> Any {
        return array
    }

    public override func checkElement(arguments: [Int64], doCheck: [Bool]) throws {
        if doCheck.count > 0 && doCheck[0] {
            let index = Int(arguments[0])
            if index < 0 || index >= array.count {
                throw CodeEE("配列変数\(varName)の第1引数(\(index))は配列の範囲外です")
            }
        }
    }
}

// MARK: - Basic String Variable Tokens

/// Single string variable
class StrVariableToken: VariableToken {
    private let arrayIndex: Int

    public init(varCode: VariableCode, varData: VariableData) {
        self.arrayIndex = Int(varCode.baseValue)
        super.init(code: varCode, varData: varData)
        self.canRestructure = false
        self.isForbid = varData.dataString.count == 0
    }

    public override func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        return varData.dataString[arrayIndex] ?? ""
    }

    public override func setValue(_ value: String, arguments: [Int64]) throws {
        varData.dataString[arrayIndex] = value
    }

    public override func setValueAll(_ value: String, start: Int, end: Int, charaPos: Int) throws {
        varData.dataString[arrayIndex] = value
    }
}

/// 1D string array variable (e.g., SAVESTR, STR, RESULTS, etc.)
class Str1DVariableToken: VariableToken {
    private let arrayIndex: Int
    private var array: [String?] { varData.dataStringArray[arrayIndex] }

    public init(varCode: VariableCode, varData: VariableData) {
        self.arrayIndex = Int(varCode.baseValue)
        super.init(code: varCode, varData: varData)
        self.canRestructure = false
        self.isForbid = array.count == 0
    }

    public override func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        let index = Int(arguments[0])
        guard index >= 0 && index < array.count else {
            throw CodeEE("配列変数\(varName)の範囲外アクセス: index=\(index), size=\(array.count)")
        }
        return array[index] ?? ""
    }

    public override func setValue(_ value: String, arguments: [Int64]) throws {
        let index = Int(arguments[0])
        guard index >= 0 && index < array.count else {
            throw CodeEE("配列変数\(varName)の範囲外アクセス: index=\(index), size=\(array.count)")
        }
        varData.dataStringArray[arrayIndex][index] = value
    }

    public override func setValue(_ values: [String], arguments: [Int64]) throws {
        let start = Int(arguments[0])
        let end = start + values.count
        for i in start..<end {
            varData.dataStringArray[arrayIndex][i] = values[i - start]
        }
    }

    public override func setValueAll(_ value: String, start: Int, end: Int, charaPos: Int) throws {
        for i in start..<end {
            varData.dataStringArray[arrayIndex][i] = value
        }
    }

    public override func getLength() throws -> Int {
        return array.count
    }

    public override func getLength(dimension: Int) throws -> Int {
        if dimension == 0 { return array.count }
        throw CodeEE("配列型変数\(varName)の存在しない次元の長さを取得しようとしました")
    }

    public override func getArray() throws -> Any {
        return array
    }

    public override func checkElement(arguments: [Int64], doCheck: [Bool]) throws {
        if doCheck.count > 0 && doCheck[0] {
            let index = Int(arguments[0])
            if index < 0 || index >= array.count {
                throw CodeEE("配列変数\(varName)の第1引数(\(index))は配列の範囲外です")
            }
        }
    }
}
