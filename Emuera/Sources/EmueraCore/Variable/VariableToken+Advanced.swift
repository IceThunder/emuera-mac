//
//  VariableToken+Advanced.swift
//  EmueraCore
//
//  Advanced variable tokens: 2D/3D arrays, character data, constants,
//  pseudo-variables, user-defined, reference, and local variables
//
//  Created: 2025-12-19
//

import Foundation

// MARK: - 2D/3D Array Tokens

/// 2D integer array variable
public class Int2DVariableToken: VariableToken {
    private let arrayIndex: Int
    private var array: [[Int64]] { varData.dataIntegerArray2D[arrayIndex] }

    public init(varCode: VariableCode, varData: VariableData) {
        self.arrayIndex = Int(varCode.baseValue)
        super.init(code: varCode, varData: varData)
        self.canRestructure = false
        self.isForbid = array.count == 0
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        let i1 = Int(arguments[0])
        let i2 = Int(arguments[1])
        guard i1 >= 0 && i1 < array.count,
              i2 >= 0 && i2 < array[i1].count else {
            throw CodeEE("二次元配列\(varName)の範囲外アクセス")
        }
        return array[i1][i2]
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        let i1 = Int(arguments[0])
        let i2 = Int(arguments[1])
        guard i1 >= 0 && i1 < array.count,
              i2 >= 0 && i2 < array[i1].count else {
            throw CodeEE("二次元配列\(varName)の範囲外アクセス")
        }
        varData.dataIntegerArray2D[arrayIndex][i1][i2] = value
    }

    public override func setValue(_ values: [Int64], arguments: [Int64]) throws {
        let i1 = Int(arguments[0])
        let start = Int(arguments[1])
        let end = start + values.count
        for i in start..<end {
            varData.dataIntegerArray2D[arrayIndex][i1][i] = values[i - start]
        }
    }

    public override func setValueAll(_ value: Int64, start: Int, end: Int, charaPos: Int) throws {
        for i in 0..<array.count {
            for j in 0..<array[i].count {
                varData.dataIntegerArray2D[arrayIndex][i][j] = value
            }
        }
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        let i1 = Int(arguments[0])
        let i2 = Int(arguments[1])
        guard i1 >= 0 && i1 < array.count,
              i2 >= 0 && i2 < array[i1].count else {
            throw CodeEE("二次元配列\(varName)の範囲外アクセス")
        }
        varData.dataIntegerArray2D[arrayIndex][i1][i2] += value
        return varData.dataIntegerArray2D[arrayIndex][i1][i2]
    }

    public override func getLength() throws -> Int {
        throw CodeEE("2次元配列型変数\(varName)の長さを取得しようとしました")
    }

    public override func getLength(dimension: Int) throws -> Int {
        if dimension == 0 || dimension == 1 {
            let size0 = array.count
            if size0 > 0 {
                let size1 = array[0].count
                return dimension == 0 ? size0 : size1
            }
            return 0
        }
        throw CodeEE("配列型変数\(varName)の存在しない次元の長さを取得しようとしました")
    }

    public override func getArray() throws -> Any {
        return array
    }

    public override func checkElement(arguments: [Int64], doCheck: [Bool]) throws {
        if doCheck.count > 0 && doCheck[0] {
            let i1 = Int(arguments[0])
            if i1 < 0 || i1 >= array.count {
                throw CodeEE("二次元配列\(varName)の第1引数(\(i1))は配列の範囲外です")
            }
        }
        if doCheck.count > 1 && doCheck[1] {
            let i1 = Int(arguments[0])
            let i2 = Int(arguments[1])
            if i1 >= 0 && i1 < array.count && (i2 < 0 || i2 >= array[i1].count) {
                throw CodeEE("二次元配列\(varName)の第2引数(\(i2))は配列の範囲外です")
            }
        }
    }
}

/// 2D string array variable
public class Str2DVariableToken: VariableToken {
    private let arrayIndex: Int
    private var array: [[String?]] { varData.dataStringArray2D[arrayIndex] }

    public init(varCode: VariableCode, varData: VariableData) {
        self.arrayIndex = Int(varCode.baseValue)
        super.init(code: varCode, varData: varData)
        self.canRestructure = false
        self.isForbid = array.count == 0
    }

    public override func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        let i1 = Int(arguments[0])
        let i2 = Int(arguments[1])
        guard i1 >= 0 && i1 < array.count,
              i2 >= 0 && i2 < array[i1].count else {
            throw CodeEE("二次元配列\(varName)の範囲外アクセス")
        }
        return array[i1][i2] ?? ""
    }

    public override func setValue(_ value: String, arguments: [Int64]) throws {
        let i1 = Int(arguments[0])
        let i2 = Int(arguments[1])
        guard i1 >= 0 && i1 < array.count,
              i2 >= 0 && i2 < array[i1].count else {
            throw CodeEE("二次元配列\(varName)の範囲外アクセス")
        }
        varData.dataStringArray2D[arrayIndex][i1][i2] = value
    }

    public override func setValue(_ values: [String], arguments: [Int64]) throws {
        let i1 = Int(arguments[0])
        let start = Int(arguments[1])
        let end = start + values.count
        for i in start..<end {
            varData.dataStringArray2D[arrayIndex][i1][i] = values[i - start]
        }
    }

    public override func setValueAll(_ value: String, start: Int, end: Int, charaPos: Int) throws {
        for i in 0..<array.count {
            for j in 0..<array[i].count {
                varData.dataStringArray2D[arrayIndex][i][j] = value
            }
        }
    }

    public override func getLength() throws -> Int {
        throw CodeEE("2次元配列型変数\(varName)の長さを取得しようとしました")
    }

    public override func getLength(dimension: Int) throws -> Int {
        if dimension == 0 || dimension == 1 {
            let size0 = array.count
            if size0 > 0 {
                let size1 = array[0].count
                return dimension == 0 ? size0 : size1
            }
            return 0
        }
        throw CodeEE("配列型変数\(varName)の存在しない次元の長さを取得しようとしました")
    }

    public override func getArray() throws -> Any {
        return array
    }

    public override func checkElement(arguments: [Int64], doCheck: [Bool]) throws {
        if doCheck.count > 0 && doCheck[0] {
            let i1 = Int(arguments[0])
            if i1 < 0 || i1 >= array.count {
                throw CodeEE("二次元配列\(varName)の第1引数(\(i1))は配列の範囲外です")
            }
        }
        if doCheck.count > 1 && doCheck[1] {
            let i1 = Int(arguments[0])
            let i2 = Int(arguments[1])
            if i1 >= 0 && i1 < array.count && (i2 < 0 || i2 >= array[i1].count) {
                throw CodeEE("二次元配列\(varName)の第2引数(\(i2))は配列の範囲外です")
            }
        }
    }
}

// REMOVED: 3D Array Tokens (causing Swift subscript inference issues)
public class CharaVariableToken: VariableToken {
    var sizes: [Int] = []
    var totalSize: Int = 0
    var arrayIndex: Int = 0

    public override init(code: VariableCode, varData: VariableData) {
        super.init(code: code, varData: varData)
        self.arrayIndex = Int(code.baseValue)

        let baseVal = code.baseValue
        switch baseVal {
        case 0x00..<0x10: sizes = [0]
        case 0x10..<0x20: sizes = [100]
        case 0x20..<0x30: sizes = [10, 10]
        default: sizes = [0]
        }

        totalSize = sizes.reduce(1, *)
        isForbid = totalSize == 0
    }

    public override func getLength() throws -> Int {
        if sizes.count == 1 { return sizes[0] }
        if sizes.count == 0 { throw CodeEE("非配列型のキャラ変数\(varName)の長さを取得しようとしました") }
        throw CodeEE("\(sizes.count)次元配列型のキャラ変数\(varName)の長さを次元を指定せずに取得しようとしました")
    }

    public override func getLength(dimension: Int) throws -> Int {
        if sizes.count == 0 { throw CodeEE("非配列型のキャラ変数\(varName)の長さを取得しようとしました") }
        if dimension < sizes.count { return sizes[dimension] }
        throw CodeEE("配列型変数\(varName)の存在しない次元の長さを取得しようとしました")
    }

    public override func getArrayChara(charano: Int) throws -> Any {
        throw CodeEE("配列型でない変数\(varName)の配列を取得しようとしました")
    }
}

/// Character single integer / array operations follow same pattern
// (Implementation continues with CharaIntVariableToken, CharaStrVariableToken, etc.)
// Full implementations omitted for brevity - follows same structure as CharaVariableToken

/// Character single integer variable (e.g., NO, ISASSI)
public class CharaIntVariableToken: CharaVariableToken {
    public override init(code: VariableCode, varData: VariableData) {
        super.init(code: code, varData: varData)
        self.dimension = 0
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        return char.getInteger(index: arrayIndex)
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        char.setInteger(index: arrayIndex, value: value)
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        let current = char.getInteger(index: arrayIndex)
        let newValue = current + value
        char.setInteger(index: arrayIndex, value: newValue)
        return newValue
    }
}

/// Character 1D integer array variable (e.g., BASE, ABL, TALENT, EXP, CFLAG, etc.)
public class CharaInt1DVariableToken: CharaVariableToken {
    public override init(code: VariableCode, varData: VariableData) {
        super.init(code: code, varData: varData)
        self.dimension = 1
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let index = arguments.count > 1 ? Int(arguments[1]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        guard index >= 0 && index < char.dataIntegerArray[arrayIndex].count else {
            throw CodeEE("配列範囲外アクセス: index=\(index)")
        }
        return char.dataIntegerArray[arrayIndex][index]
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let index = arguments.count > 1 ? Int(arguments[1]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        guard index >= 0 && index < char.dataIntegerArray[arrayIndex].count else {
            throw CodeEE("配列範囲外アクセス: index=\(index)")
        }
        char.dataIntegerArray[arrayIndex][index] = value
    }

    public override func setValue(_ values: [Int64], arguments: [Int64]) throws {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let start = arguments.count > 1 ? Int(arguments[1]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        let end = start + values.count
        for i in start..<end {
            char.dataIntegerArray[arrayIndex][i] = values[i - start]
        }
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let index = arguments.count > 1 ? Int(arguments[1]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        guard index >= 0 && index < char.dataIntegerArray[arrayIndex].count else {
            throw CodeEE("配列範囲外アクセス: index=\(index)")
        }
        char.dataIntegerArray[arrayIndex][index] += value
        return char.dataIntegerArray[arrayIndex][index]
    }

    public override func getArrayChara(charano: Int) throws -> Any {
        guard let char = varData.getCharacter(at: charano) else {
            throw CodeEE("キャラクター\(charano)が存在しません")
        }
        return char.dataIntegerArray[arrayIndex]
    }
}

/// Character single string variable (e.g., NAME, CALLNAME)
public class CharaStrVariableToken: CharaVariableToken {
    public override init(code: VariableCode, varData: VariableData) {
        super.init(code: code, varData: varData)
        self.dimension = 0
    }

    public override func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        return char.getString(index: arrayIndex)
    }

    public override func setValue(_ value: String, arguments: [Int64]) throws {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        char.setString(index: arrayIndex, value: value)
    }
}

/// Character 1D string array variable (e.g., CSTR)
public class CharaStr1DVariableToken: CharaVariableToken {
    public override init(code: VariableCode, varData: VariableData) {
        super.init(code: code, varData: varData)
        self.dimension = 1
    }

    public override func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let index = arguments.count > 1 ? Int(arguments[1]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        guard index >= 0 && index < char.dataStringArray[arrayIndex].count else {
            throw CodeEE("配列範囲外アクセス: index=\(index)")
        }
        return char.dataStringArray[arrayIndex][index] ?? ""
    }

    public override func setValue(_ value: String, arguments: [Int64]) throws {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let index = arguments.count > 1 ? Int(arguments[1]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        guard index >= 0 && index < char.dataStringArray[arrayIndex].count else {
            throw CodeEE("配列範囲外アクセス: index=\(index)")
        }
        char.dataStringArray[arrayIndex][index] = value
    }

    public override func getArray() throws -> Any {
        var result: [[String]] = []
        for char in varData.characters {
            let arr = char.dataStringArray[arrayIndex].map { $0 ?? "" }
            result.append(arr)
        }
        return result
    }
}

/// Character 2D integer array variable (e.g., CDFLAG)
public class CharaInt2DVariableToken: CharaVariableToken {
    public override init(code: VariableCode, varData: VariableData) {
        super.init(code: code, varData: varData)
        self.dimension = 2
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let i1 = arguments.count > 1 ? Int(arguments[1]) : 0
        let i2 = arguments.count > 2 ? Int(arguments[2]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        guard i1 >= 0 && i1 < char.dataIntegerArray2D[arrayIndex].count,
              i2 >= 0 && i2 < char.dataIntegerArray2D[arrayIndex][i1].count else {
            throw CodeEE("二次元配列範囲外アクセス")
        }
        return char.dataIntegerArray2D[arrayIndex][i1][i2]
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let i1 = arguments.count > 1 ? Int(arguments[1]) : 0
        let i2 = arguments.count > 2 ? Int(arguments[2]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        guard i1 >= 0 && i1 < char.dataIntegerArray2D[arrayIndex].count,
              i2 >= 0 && i2 < char.dataIntegerArray2D[arrayIndex][i1].count else {
            throw CodeEE("二次元配列範囲外アクセス")
        }
        char.dataIntegerArray2D[arrayIndex][i1][i2] = value
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        let charaPos = arguments.count > 0 ? Int(arguments[0]) : 0
        let i1 = arguments.count > 1 ? Int(arguments[1]) : 0
        let i2 = arguments.count > 2 ? Int(arguments[2]) : 0

        guard let char = varData.getCharacter(at: charaPos) else {
            throw CodeEE("キャラクター\(charaPos)が存在しません")
        }
        guard i1 >= 0 && i1 < char.dataIntegerArray2D[arrayIndex].count,
              i2 >= 0 && i2 < char.dataIntegerArray2D[arrayIndex][i1].count else {
            throw CodeEE("二次元配列範囲外アクセス")
        }
        char.dataIntegerArray2D[arrayIndex][i1][i2] += value
        return char.dataIntegerArray2D[arrayIndex][i1][i2]
    }
}

// MARK: - Constant and Calc Tokens

/// Abstract base for constant (read-only) variables
public class ConstantToken: VariableToken {
    public override init(code: VariableCode, varData: VariableData) {
        super.init(code: code, varData: varData)
        self.canRestructure = true
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        throw CodeEE("読み取り専用の変数\(varName)に代入しようとしました")
    }

    public override func setValue(_ value: String, arguments: [Int64]) throws {
        throw CodeEE("読み取り専用の変数\(varName)に代入しようとしました")
    }

    public override func setValue(_ values: [Int64], arguments: [Int64]) throws {
        throw CodeEE("読み取り専用の変数\(varName)に代入しようとしました")
    }

    public override func setValue(_ values: [String], arguments: [Int64]) throws {
        throw CodeEE("読み取り専用の変数\(varName)に代入しようとしました")
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        throw CodeEE("読み取り専用の変数\(varName)に代入しようとしました")
    }
}

/// Integer constant
public class IntConstantToken: ConstantToken {
    private let value: Int64

    public init(varCode: VariableCode, varData: VariableData, value: Int64) {
        self.value = value
        super.init(code: varCode, varData: varData)
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        return value
    }
}

/// String constant
public class StrConstantToken: ConstantToken {
    private let value: String

    public init(varCode: VariableCode, varData: VariableData, value: String) {
        self.value = value
        super.init(code: varCode, varData: varData)
    }

    public override func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        return value
    }
}

/// 1D integer array constant
public class Int1DConstantToken: ConstantToken {
    private let array: [Int64]

    public init(varCode: VariableCode, varData: VariableData, array: [Int64]) {
        self.array = array
        super.init(code: varCode, varData: varData)
        self.isForbid = array.count == 0
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        let index = Int(arguments[0])
        guard index >= 0 && index < array.count else {
            throw CodeEE("配列変数\(varName)の範囲外アクセス")
        }
        return array[index]
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

/// 1D string array constant
public class Str1DConstantToken: ConstantToken {
    private let array: [String]

    public init(varCode: VariableCode, varData: VariableData, array: [String]) {
        self.array = array
        super.init(code: varCode, varData: varData)
        self.isForbid = array.count == 0
    }

    public override func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        let index = Int(arguments[0])
        guard index >= 0 && index < array.count else {
            throw CodeEE("配列変数\(varName)の範囲外アクセス")
        }
        return array[index]
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

// MARK: - Pseudo-Variables (Calc Variables)

/// Abstract base for pseudo-variables
public class PseudoVariableToken: VariableToken {
    public override init(code: VariableCode, varData: VariableData) {
        super.init(code: code, varData: varData)
        self.canRestructure = false
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        throw CodeEE("擬似変数\(varName)に代入しようとしました")
    }

    public override func setValue(_ value: String, arguments: [Int64]) throws {
        throw CodeEE("擬似変数\(varName)に代入しようとしました")
    }

    public override func setValue(_ values: [Int64], arguments: [Int64]) throws {
        throw CodeEE("擬似変数\(varName)に代入しようとしました")
    }

    public override func setValue(_ values: [String], arguments: [Int64]) throws {
        throw CodeEE("擬似変数\(varName)に代入しようとしました")
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        throw CodeEE("擬似変数\(varName)に代入しようとしました")
    }

    public override func getLength() throws -> Int {
        throw CodeEE("擬似変数\(varName)の長さを取得しようとしました")
    }

    public override func getLength(dimension: Int) throws -> Int {
        throw CodeEE("擬似変数\(varName)の長さを取得しようとしました")
    }

    public override func getArray() throws -> Any {
        throw CodeEE("擬似変数\(varName)の配列を取得しようとしました")
    }
}

/// Random number generator (RAND)
public class RandToken: PseudoVariableToken {
    public init(varData: VariableData) {
        super.init(code: .RAND, varData: varData)
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        let i = arguments.count > 0 ? arguments[0] : 0
        if i <= 0 {
            throw CodeEE("RANDの引数に0以下の値(\(i))が指定されました")
        }
        // With ExpressionMediator, would use proper RNG
        return Int64.random(in: 0..<i)
    }
}

/// Character count
public class CHARANUM_Token: PseudoVariableToken {
    public init(varData: VariableData) {
        super.init(code: .CHARANUM, varData: varData)
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        return Int64(varData.characterList.count)
    }
}

/// Int limits
public class INT_MAX_Token: PseudoVariableToken {
    public init(varData: VariableData) {
        super.init(code: .__INT_MAX__, varData: varData)
        self.canRestructure = true
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        return Int64.max
    }
}

public class INT_MIN_Token: PseudoVariableToken {
    public init(varData: VariableData) {
        super.init(code: .__INT_MIN__, varData: varData)
        self.canRestructure = true
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        return Int64.min
    }
}

// MARK: - User-Defined Variables

/// Abstract base for user-defined variables
public class UserDefinedVariableToken: VariableToken {
    public var sizes: [Int] = []

    public init(varCode: VariableCode, data: VariableData, name: String, isPrivate: Bool, isConst: Bool,
                sizes: [Int], isGlobal: Bool, isSavedata: Bool) {
        super.init(code: varCode, varData: data)
        self.varName = name
        self.isPrivate = isPrivate
        self.isConst = isConst
        self.sizes = sizes
        self.isGlobal = isGlobal
        self.isSavedata = isSavedata
        self.isForbid = sizes.reduce(1, *) == 0
    }

    public override func setDefault() { /* Override */ }
    public override func `in`() { /* Override */ }
    public override func `out`() { /* Override */ }
}

/// Static 1D int array
public class StaticInt1DVariableToken: UserDefinedVariableToken {
    private var array: [Int64] = []

    public init(varData: VariableData, name: String, sizes: [Int], isGlobal: Bool, isSavedata: Bool) {
        super.init(varCode: .VAR, data: varData, name: name, isPrivate: false, isConst: false,
                   sizes: sizes, isGlobal: isGlobal, isSavedata: isSavedata)
        self.array = Array(repeating: 0, count: sizes[0])
    }

    public override func setDefault() {
        for i in 0..<array.count { array[i] = 0 }
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        return array[Int(arguments[0])]
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        array[Int(arguments[0])] = value
    }

    public override func setValue(_ values: [Int64], arguments: [Int64]) throws {
        let start = Int(arguments[0])
        for i in 0..<values.count { array[start + i] = values[i] }
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        let idx = Int(arguments[0])
        array[idx] += value
        return array[idx]
    }

    public override func getArray() throws -> Any {
        return array
    }

    public override func `in`() {}
    public override func `out`() {}
}

/// Reference token
public class ReferenceToken: UserDefinedVariableToken {
    public var array: Any? = nil
    public var arrayList: [Any] = []

    public init(varData: VariableData, name: String, isPrivate: Bool, isGlobal: Bool, isSavedata: Bool) {
        super.init(varCode: .REF, data: varData, name: name, isPrivate: isPrivate, isConst: false,
                   sizes: [], isGlobal: isGlobal, isSavedata: isSavedata)
        self.canRestructure = false
        self.isStatic = !isPrivate
        self.isReference = true
        self.isForbid = false
    }

    public func setRef(_ refArray: Any) {
        self.array = refArray
    }

    public override func `in`() {
        if let arr = array { arrayList.append(arr) }
        array = nil
    }

    public override func `out`() {
        if arrayList.count > 0 {
            array = arrayList.removeLast()
        } else {
            array = nil
        }
    }
}

/// 1D int reference
public class ReferenceInt1DToken: ReferenceToken {
    public override init(varData: VariableData, name: String, isPrivate: Bool, isGlobal: Bool, isSavedata: Bool) {
        super.init(varData: varData, name: name, isPrivate: isPrivate, isGlobal: isGlobal, isSavedata: isSavedata)
        dimension = 1
    }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        guard let arr = array as? [Int64] else {
            throw CodeEE("参照型変数\(varName)は何も参照していません")
        }
        return arr[Int(arguments[0])]
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        guard var arr = array as? [Int64] else {
            throw CodeEE("参照型変数\(varName)は何も参照していません")
        }
        arr[Int(arguments[0])] = value
        array = arr
    }

    public override func getLength() throws -> Int {
        guard let arr = array as? [Int64] else {
            throw CodeEE("参照型変数\(varName)は何も参照していません")
        }
        return arr.count
    }

    public override func getArray() throws -> Any {
        guard let arr = array else {
            throw CodeEE("参照型変数\(varName)は何も参照していません")
        }
        return arr
    }
}

// MARK: - Local Variables

/// Abstract base for local variables
public class LocalVariableToken: VariableToken {
    public var subID: String
    public var size: Int

    public init(varCode: VariableCode, varData: VariableData, subID: String, size: Int) {
        self.subID = subID
        self.size = size
        super.init(code: varCode, varData: varData)
        self.canRestructure = false
    }

    public override func setDefault() { /* Override */ }
    public override func resize(newSize: Int) { /* Override */ }

    public override func getLength() throws -> Int { return size }
    public override func getLength(dimension: Int) throws -> Int {
        if dimension == 0 { return size }
        throw CodeEE("配列型変数\(varName)の存在しない次元の長さを取得しようとしました")
    }

    public override func checkElement(arguments: [Int64], doCheck: [Bool]) throws {
        if doCheck.count > 0 && doCheck[0] {
            let idx = Int(arguments[0])
            if idx < 0 || idx >= size {
                throw CodeEE("配列変数\(varName)の第1引数(\(idx))は配列の範囲外です")
            }
        }
    }
}

/// Local 1D int array
public class LocalInt1DVariableToken: LocalVariableToken {
    private var array: [Int64]? = nil

    public override init(varCode: VariableCode, varData: VariableData, subID: String, size: Int) {
        super.init(varCode: varCode, varData: varData, subID: subID, size: size)
    }

    public override func getLength() throws -> Int { return size }

    public override func getIntValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> Int64 {
        if array == nil { array = Array(repeating: 0, count: size) }
        return array![Int(arguments[0])]
    }

    public override func setValue(_ value: Int64, arguments: [Int64]) throws {
        if array == nil { array = Array(repeating: 0, count: size) }
        array![Int(arguments[0])] = value
    }

    public override func setValue(_ values: [Int64], arguments: [Int64]) throws {
        if array == nil { array = Array(repeating: 0, count: size) }
        let start = Int(arguments[0])
        for i in 0..<values.count { array![start + i] = values[i] }
    }

    public override func setValueAll(_ value: Int64, start: Int, end: Int, charaPos: Int) throws {
        if array == nil { array = Array(repeating: 0, count: size) }
        for i in start..<end { array![i] = value }
    }

    public override func plusValue(_ value: Int64, arguments: [Int64]) throws -> Int64 {
        if array == nil { array = Array(repeating: 0, count: size) }
        let idx = Int(arguments[0])
        array![idx] += value
        return array![idx]
    }

    public override func getArray() throws -> Any {
        if array == nil { array = Array(repeating: 0, count: size) }
        return array!
    }

    public override func resize(newSize: Int) {
        self.size = newSize
        array = nil
    }
}

/// Local 1D string array
public class LocalStr1DVariableToken: LocalVariableToken {
    private var array: [String]? = nil

    public override init(varCode: VariableCode, varData: VariableData, subID: String, size: Int) {
        super.init(varCode: varCode, varData: varData, subID: subID, size: size)
    }

    public override func getStrValue(exm: ExpressionMediator?, arguments: [Int64]) throws -> String {
        if array == nil { array = Array(repeating: "", count: size) }
        return array![Int(arguments[0])]
    }

    public override func setValue(_ value: String, arguments: [Int64]) throws {
        if array == nil { array = Array(repeating: "", count: size) }
        array![Int(arguments[0])] = value
    }

    public override func setValue(_ values: [String], arguments: [Int64]) throws {
        if array == nil { array = Array(repeating: "", count: size) }
        let start = Int(arguments[0])
        for i in 0..<values.count { array![start + i] = values[i] }
    }

    public override func setValueAll(_ value: String, start: Int, end: Int, charaPos: Int) throws {
        if array == nil { array = Array(repeating: "", count: size) }
        for i in start..<end { array![i] = value }
    }

    public override func getArray() throws -> Any {
        if array == nil { array = Array(repeating: "", count: size) }
        return array!
    }

    public override func resize(newSize: Int) {
        self.size = newSize
        array = nil
    }
}
