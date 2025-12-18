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
    // For brevity, we define the most commonly used variables
    // Each combines: base | flags

    // Single integers
    public static let DAY = VariableCode(rawValue: 0x00020C00)  // 0x00 | INTEGER | 1D | FORBID
    public static let MONEY = VariableCode(rawValue: 0x01020C00)
    public static let RESULT = VariableCode(rawValue: 0x0A020800)  // No FORBID
    public static let COUNT = VariableCode(rawValue: 0x0B020800)
    public static let TARGET = VariableCode(rawValue: 0x0C020800)
    public static let ASSI = VariableCode(rawValue: 0x0D020C00)
    public static let MASTER = VariableCode(rawValue: 0x0E020C00)
    public static let PLAYER = VariableCode(rawValue: 0x18020C00)
    public static let TIME = VariableCode(rawValue: 0x16020C00)
    public static let BOUGHT = VariableCode(rawValue: 0x1B020C00)
    public static let NOITEM = VariableCode(rawValue: 0x0F020C00)

    // A-Z arrays (base starting at 0x1E)
    public static let A = VariableCode(rawValue: 0x1E020C00)
    public static let B = VariableCode(rawValue: 0x1F020C00)
    public static let C = VariableCode(rawValue: 0x20020C00)
    public static let D = VariableCode(rawValue: 0x21020C00)
    public static let E = VariableCode(rawValue: 0x22020C00)
    public static let F = VariableCode(rawValue: 0x23020C00)
    public static let G = VariableCode(rawValue: 0x24020C00)
    public static let H = VariableCode(rawValue: 0x25020C00)
    public static let I = VariableCode(rawValue: 0x26020C00)
    public static let J = VariableCode(rawValue: 0x27020C00)
    public static let K = VariableCode(rawValue: 0x28020C00)
    public static let L = VariableCode(rawValue: 0x29020C00)
    public static let M = VariableCode(rawValue: 0x2A020C00)
    public static let N = VariableCode(rawValue: 0x2B020C00)
    public static let O = VariableCode(rawValue: 0x2C020C00)
    public static let P = VariableCode(rawValue: 0x2D020C00)
    public static let Q = VariableCode(rawValue: 0x2E020C00)
    public static let R = VariableCode(rawValue: 0x2F020C00)
    public static let S = VariableCode(rawValue: 0x30020C00)
    public static let T = VariableCode(rawValue: 0x31020C00)
    public static let U = VariableCode(rawValue: 0x32020C00)
    public static let V = VariableCode(rawValue: 0x33020C00)
    public static let W = VariableCode(rawValue: 0x34020C00)
    public static let X = VariableCode(rawValue: 0x35020C00)
    public static let Y = VariableCode(rawValue: 0x36020C00)
    public static let Z = VariableCode(rawValue: 0x37020C00)

    // System 1D integer arrays
    public static let ITEM = VariableCode(rawValue: 0x02020C00)
    public static let FLAG = VariableCode(rawValue: 0x03020C00)
    public static let TFLAG = VariableCode(rawValue: 0x04020C00)
    public static let UP = VariableCode(rawValue: 0x05020C00)
    public static let DOWN = VariableCode(rawValue: 0x09020C00)
    public static let SELECTCOM = VariableCode(rawValue: 0x11020800)
    public static let PREVCOM = VariableCode(rawValue: 0x13020C00)
    public static let NEXTCOM = VariableCode(rawValue: 0x1A020C00)  // actually 0x19 in some refs

    // String variables
    public static let RESULTS = VariableCode(rawValue: 0x00040800)
    public static let SAVESTR = VariableCode(rawValue: 0x01040800)
    public static let STR = VariableCode(rawValue: 0x02040800)

    // Character 1D integer arrays
    public static let BASE = VariableCode(rawValue: 0x00120C00)  // base=0 | CHARA | INT | 1D
    public static let MAXBASE = VariableCode(rawValue: 0x01120C00)
    public static let ABL = VariableCode(rawValue: 0x02120C00)
    public static let TALENT = VariableCode(rawValue: 0x03120C00)
    public static let EXP = VariableCode(rawValue: 0x04120C00)
    public static let MARK = VariableCode(rawValue: 0x05120C00)
    public static let PALAM = VariableCode(rawValue: 0x06120C00)
    public static let SOURCE = VariableCode(rawValue: 0x07120C00)
    public static let EX = VariableCode(rawValue: 0x08120C00)
    public static let CFLAG = VariableCode(rawValue: 0x09120C00)
    public static let JUEL = VariableCode(rawValue: 0x0A120C00)
    public static let RELATION = VariableCode(rawValue: 0x0B120C00)
    public static let EQUIP = VariableCode(rawValue: 0x0C120C00)
    public static let TEQUIP = VariableCode(rawValue: 0x0D120C00)
    public static let STAIN = VariableCode(rawValue: 0x0E120C00)
    public static let GOTJUEL = VariableCode(rawValue: 0x0F120C00)
    public static let NOWEX = VariableCode(rawValue: 0x10120C00)
    public static let DOWNBASE = VariableCode(rawValue: 0x11120C00)
    public static let CUP = VariableCode(rawValue: 0x12120C00)
    public static let CDOWN = VariableCode(rawValue: 0x13120C00)
    public static let TCVAR = VariableCode(rawValue: 0x14120C00)

    // Character strings
    public static let NAME = VariableCode(rawValue: 0x0044C000)  // CHARA | STRING | CONSTANT
    public static let CALLNAME = VariableCode(rawValue: 0x0144C000)
    public static let NICKNAME = VariableCode(rawValue: 0x0244C000)
    public static let MASTERNAME = VariableCode(rawValue: 0x0344C000)
    public static let CSTR = VariableCode(rawValue: 0x00140C00)  // CHARA | STRING | 1D

    // Character 2D arrays
    public static let CDFLAG = VariableCode(rawValue: 0x00920C00)  // base=0 | CHARA | INT | 2D

    // Calc/pseudo
    public static let RAND = VariableCode(rawValue: 0x00028000)  // INTEGER | CALC
    public static let CHARANUM = VariableCode(rawValue: 0x00028000)  // same type, different token
    public static let __INT_MAX__ = VariableCode(rawValue: 0x00428000)  // INTEGER | CALC | UNCHANGEABLE
    public static let __INT_MIN__ = VariableCode(rawValue: 0x00428000)

    // Character-related single values
    public static let NO = VariableCode(rawValue: 0x00020C00)  // INTEGER | 1D | FORBID (base 0)
    public static let ISASSI = VariableCode(rawValue: 0x00020C00)
    public static let EJAC = VariableCode(rawValue: 0x08020C00)  // base 0x08

    // User defined
    public static let VAR = VariableCode(rawValue: 0x00020800)  // INTEGER | 1D
    public static let REF = VariableCode(rawValue: 0x00020000)  // INTEGER

    // Global variables (fake codes for marker)
    public static let GLOBAL = VariableCode(rawValue: 0x00000000)  // Placeholder

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
            DAY, MONEY, RESULT, COUNT, TARGET, ASSI, MASTER, PLAYER, TIME, BOUGHT,
            A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
            ITEM, FLAG, TFLAG, UP, DOWN, SELECTCOM, PREVCOM, NEXTCOM,
            RESULTS, SAVESTR, STR,
            BASE, MAXBASE, ABL, TALENT, EXP, MARK, PALAM, SOURCE, EX, CFLAG, JUEL, RELATION,
            EQUIP, TEQUIP, STAIN, GOTJUEL, NOWEX, DOWNBASE, CUP, CDOWN, TCVAR,
            NAME, CALLNAME, NICKNAME, MASTERNAME, CSTR,
            CDFLAG,
            RAND, CHARANUM, __INT_MAX__, __INT_MIN__,
            VAR, REF
        ]
    }
}
