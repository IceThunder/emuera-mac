//
//  VariableCode.swift
//  EmueraCore
//
//  Variable code system translated from C# VariableCode.cs
//  Uses struct with computed properties instead of bit-field enum
//
//  Created: 2025-12-19
//

import Foundation

/// Variable system code definition
public struct VariableCode: Equatable, Hashable {
    public let rawValue: Int64

    public init(rawValue: Int64) {
        self.rawValue = rawValue
    }

    // MARK: - Computed Properties

    public var isInteger: Bool {
        return (rawValue & VariableCode.__INTEGER__) != 0
    }

    public var isString: Bool {
        return (rawValue & VariableCode.__STRING__) != 0
    }

    public var isCharacterData: Bool {
        return (rawValue & VariableCode.__CHARACTER_DATA__) != 0
    }

    public var isArray1D: Bool {
        return (rawValue & VariableCode.__ARRAY_1D__) != 0
    }

    public var isArray2D: Bool {
        return (rawValue & VariableCode.__ARRAY_2D__) != 0
    }

    public var isArray3D: Bool {
        return (rawValue & VariableCode.__ARRAY_3D__) != 0
    }

    public var arrayDimension: Int {
        if isArray3D { return 3 }
        if isArray2D { return 2 }
        if isArray1D { return 1 }
        return 0
    }

    public var isForbid: Bool {
        return (rawValue & VariableCode.__CAN_FORBID__) != 0
    }

    public var isUnchangeable: Bool {
        return (rawValue & VariableCode.__UNCHANGEABLE__) != 0
    }

    public var isCalc: Bool {
        return (rawValue & VariableCode.__CALC__) != 0
    }

    public var isExtended: Bool {
        return (rawValue & VariableCode.__EXTENDED__) != 0
    }

    public var isLocal: Bool {
        return (rawValue & VariableCode.__LOCAL__) != 0
    }

    public var isGlobal: Bool {
        return (rawValue & VariableCode.__GLOBAL__) != 0
    }

    public func hasFlag(_ flag: Int64) -> Bool {
        return (rawValue & flag) != 0
    }

    public var baseValue: Int64 {
        // Extract lower 16 bits (matching C# VarCodeInt = (int)(varCode & VariableCode.__LOWERCASE__))
        // This is used as the array index in VariableData
        return rawValue & VariableCode.__LOWERCASE__
    }

    public var flagBits: Int64 {
        return rawValue & VariableCode.__UPPERCASE__
    }

    // MARK: - Constants

    public static let __NULL__: Int64 = 0x00000000
    public static let __CAN_FORBID__: Int64 = 0x00010000
    public static let __INTEGER__: Int64 = 0x00020000
    public static let __STRING__: Int64 = 0x00040000
    public static let __ARRAY_1D__: Int64 = 0x00080000
    public static let __CHARACTER_DATA__: Int64 = 0x00100000
    public static let __UNCHANGEABLE__: Int64 = 0x00400000
    public static let __CALC__: Int64 = 0x00800000
    public static let __EXTENDED__: Int64 = 0x01000000
    public static let __LOCAL__: Int64 = 0x02000000
    public static let __GLOBAL__: Int64 = 0x04000000
    public static let __ARRAY_2D__: Int64 = 0x08000000
    public static let __SAVE_EXTENDED__: Int64 = 0x10000000
    public static let __ARRAY_3D__: Int64 = 0x20000000
    public static let __CONSTANT__: Int64 = 0x40000000

    public static let __UPPERCASE__: Int64 = 0x7FFF0000
    public static let __LOWERCASE__: Int64 = 0x0000FFFF

    // MARK: - Predefined Variables
    // Following C# encoding: (baseValue | flags)
    // baseValue is in lower 16 bits, flags in upper bits

    // Single integers (base 0-21)
    public static let DAY = VariableCode(rawValue: 0x0000 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)  // 0x00
    public static let MONEY = VariableCode(rawValue: 0x0001 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x01
    public static let ITEM = VariableCode(rawValue: 0x0002 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)  // 0x02
    public static let FLAG = VariableCode(rawValue: 0x0003 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)  // 0x03
    public static let TFLAG = VariableCode(rawValue: 0x0004 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x04
    public static let UP = VariableCode(rawValue: 0x0005 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)   // 0x05
    public static let PALAMLV = VariableCode(rawValue: 0x0006 | __INTEGER__ | __ARRAY_1D__)               // 0x06
    public static let EXPLV = VariableCode(rawValue: 0x0007 | __INTEGER__ | __ARRAY_1D__)                // 0x07
    public static let EJAC = VariableCode(rawValue: 0x0008 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x08
    public static let DOWN = VariableCode(rawValue: 0x0009 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x09
    public static let RESULT = VariableCode(rawValue: 0x000A | __INTEGER__ | __ARRAY_1D__)                // 0x0A
    public static let COUNT = VariableCode(rawValue: 0x000B | __INTEGER__ | __ARRAY_1D__)                 // 0x0B
    public static let TARGET = VariableCode(rawValue: 0x000C | __INTEGER__ | __ARRAY_1D__)                // 0x0C
    public static let ASSI = VariableCode(rawValue: 0x000D | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)  // 0x0D
    public static let MASTER = VariableCode(rawValue: 0x000E | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x0E
    public static let NOITEM = VariableCode(rawValue: 0x000F | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x0F
    public static let LOSEBASE = VariableCode(rawValue: 0x0010 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x10
    public static let SELECTCOM = VariableCode(rawValue: 0x0011 | __INTEGER__ | __ARRAY_1D__)              // 0x11
    public static let ASSIPLAY = VariableCode(rawValue: 0x0012 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x12
    public static let PREVCOM = VariableCode(rawValue: 0x0013 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x13
    // 0x14-0x15: NOTUSE (RAND, CHARANUM in old eramaker)
    public static let TIME = VariableCode(rawValue: 0x0016 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)   // 0x16
    public static let ITEMSALES = VariableCode(rawValue: 0x0017 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__) // 0x17
    public static let PLAYER = VariableCode(rawValue: 0x0018 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)   // 0x18
    public static let NEXTCOM = VariableCode(rawValue: 0x0019 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)  // 0x19
    public static let PBAND = VariableCode(rawValue: 0x001A | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)    // 0x1A
    public static let BOUGHT = VariableCode(rawValue: 0x001B | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)   // 0x1B
    // 0x1C-0x1D: NOTUSE

    // A-Z arrays (0x1E-0x37)
    public static let A = VariableCode(rawValue: 0x001E | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let B = VariableCode(rawValue: 0x001F | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let C = VariableCode(rawValue: 0x0020 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let D = VariableCode(rawValue: 0x0021 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let E = VariableCode(rawValue: 0x0022 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let F = VariableCode(rawValue: 0x0023 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let G = VariableCode(rawValue: 0x0024 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let H = VariableCode(rawValue: 0x0025 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let I = VariableCode(rawValue: 0x0026 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let J = VariableCode(rawValue: 0x0027 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let K = VariableCode(rawValue: 0x0028 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let L = VariableCode(rawValue: 0x0029 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let M = VariableCode(rawValue: 0x002A | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let N = VariableCode(rawValue: 0x002B | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let O = VariableCode(rawValue: 0x002C | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let P = VariableCode(rawValue: 0x002D | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let Q = VariableCode(rawValue: 0x002E | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let R = VariableCode(rawValue: 0x002F | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let S = VariableCode(rawValue: 0x0030 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let T = VariableCode(rawValue: 0x0031 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let U = VariableCode(rawValue: 0x0032 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let V = VariableCode(rawValue: 0x0033 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let W = VariableCode(rawValue: 0x0034 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let X = VariableCode(rawValue: 0x0035 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let Y = VariableCode(rawValue: 0x0036 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let Z = VariableCode(rawValue: 0x0037 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)

    // Extended 1D integer arrays (0x3C+)
    public static let ITEMPRICE = VariableCode(rawValue: 0x003C | __INTEGER__ | __ARRAY_1D__ | __UNCHANGEABLE__ | __EXTENDED__ | __CAN_FORBID__)
    public static let LOCAL = VariableCode(rawValue: 0x003D | __INTEGER__ | __ARRAY_1D__ | __LOCAL__ | __EXTENDED__ | __CAN_FORBID__)
    public static let ARG = VariableCode(rawValue: 0x003E | __INTEGER__ | __ARRAY_1D__ | __LOCAL__ | __EXTENDED__ | __CAN_FORBID__)
    public static let GLOBAL = VariableCode(rawValue: 0x003F | __INTEGER__ | __ARRAY_1D__ | __GLOBAL__ | __EXTENDED__ | __CAN_FORBID__)
    public static let RANDDATA = VariableCode(rawValue: 0x0040 | __INTEGER__ | __ARRAY_1D__ | __SAVE_EXTENDED__ | __EXTENDED__)

    // String variables
    public static let RESULTS = VariableCode(rawValue: 0x0000 | __STRING__ | __ARRAY_1D__)
    public static let SAVESTR = VariableCode(rawValue: 0x0001 | __STRING__ | __ARRAY_1D__)
    public static let STR = VariableCode(rawValue: 0x0002 | __STRING__ | __ARRAY_1D__)

    // Character 1D integer arrays
    public static let BASE = VariableCode(rawValue: 0x0000 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let MAXBASE = VariableCode(rawValue: 0x0001 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let ABL = VariableCode(rawValue: 0x0002 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let TALENT = VariableCode(rawValue: 0x0003 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let EXP = VariableCode(rawValue: 0x0004 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let MARK = VariableCode(rawValue: 0x0005 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let PALAM = VariableCode(rawValue: 0x0006 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let SOURCE = VariableCode(rawValue: 0x0007 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let EX = VariableCode(rawValue: 0x0008 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let CFLAG = VariableCode(rawValue: 0x0009 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let JUEL = VariableCode(rawValue: 0x000A | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let RELATION = VariableCode(rawValue: 0x000B | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let EQUIP = VariableCode(rawValue: 0x000C | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let TEQUIP = VariableCode(rawValue: 0x000D | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let STAIN = VariableCode(rawValue: 0x000E | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let GOTJUEL = VariableCode(rawValue: 0x000F | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let NOWEX = VariableCode(rawValue: 0x0010 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let DOWNBASE = VariableCode(rawValue: 0x0011 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let CUP = VariableCode(rawValue: 0x0012 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let CDOWN = VariableCode(rawValue: 0x0013 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)
    public static let TCVAR = VariableCode(rawValue: 0x0014 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_1D__)

    // Character strings
    public static let NAME = VariableCode(rawValue: 0x0000 | __CHARACTER_DATA__ | __STRING__ | __CONSTANT__)
    public static let CALLNAME = VariableCode(rawValue: 0x0001 | __CHARACTER_DATA__ | __STRING__ | __CONSTANT__)
    public static let NICKNAME = VariableCode(rawValue: 0x0002 | __CHARACTER_DATA__ | __STRING__ | __CONSTANT__)
    public static let MASTERNAME = VariableCode(rawValue: 0x0003 | __CHARACTER_DATA__ | __STRING__ | __CONSTANT__)
    public static let CSTR = VariableCode(rawValue: 0x0000 | __CHARACTER_DATA__ | __STRING__ | __ARRAY_1D__)

    // Character 2D arrays
    public static let CDFLAG = VariableCode(rawValue: 0x0000 | __CHARACTER_DATA__ | __INTEGER__ | __ARRAY_2D__)

    // Calc/pseudo variables
    public static let RAND = VariableCode(rawValue: 0x0000 | __INTEGER__ | __CALC__)
    public static let CHARANUM = VariableCode(rawValue: 0x0001 | __INTEGER__ | __CALC__)
    public static let __INT_MAX__ = VariableCode(rawValue: 0x0000 | __INTEGER__ | __CALC__ | __UNCHANGEABLE__)
    public static let __INT_MIN__ = VariableCode(rawValue: 0x0001 | __INTEGER__ | __CALC__ | __UNCHANGEABLE__)

    // Character-related single values
    public static let NO = VariableCode(rawValue: 0x0000 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)
    public static let ISASSI = VariableCode(rawValue: 0x0001 | __INTEGER__ | __ARRAY_1D__ | __CAN_FORBID__)

    // User defined
    public static let VAR = VariableCode(rawValue: 0x0000 | __INTEGER__ | __ARRAY_1D__)
    public static let REF = VariableCode(rawValue: 0x0000 | __INTEGER__)

    // MARK: - Equatable

    public static func == (lhs: VariableCode, rhs: VariableCode) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        return String(format: "VariableCode(0x%08X)", rawValue)
    }
}

// MARK: - CaseIterable conformance for iteration
extension VariableCode: CaseIterable {
    /// This is a hack - in real usage we'd need separate storage for all defined codes
    /// For now, only include the ones that are commonly referenced
    public static var allCases: [VariableCode] {
        return [
            DAY, MONEY, ITEM, FLAG, TFLAG, UP, PALAMLV, EXPLV, EJAC, DOWN, RESULT, COUNT, TARGET, ASSI, MASTER, NOITEM, LOSEBASE, SELECTCOM, ASSIPLAY, PREVCOM, TIME, ITEMSALES, PLAYER, NEXTCOM, PBAND, BOUGHT,
            A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
            ITEMPRICE, LOCAL, ARG, GLOBAL, RANDDATA,
            RESULTS, SAVESTR, STR,
            BASE, MAXBASE, ABL, TALENT, EXP, MARK, PALAM, SOURCE, EX, CFLAG, JUEL, RELATION,
            EQUIP, TEQUIP, STAIN, GOTJUEL, NOWEX, DOWNBASE, CUP, CDOWN, TCVAR,
            NAME, CALLNAME, NICKNAME, MASTERNAME, CSTR,
            CDFLAG,
            RAND, CHARANUM, __INT_MAX__, __INT_MIN__,
            NO, ISASSI,
            VAR, REF
        ]
    }
}
