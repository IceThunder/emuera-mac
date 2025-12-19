//
//  UserDefinedVariableData.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/19.
//

import Foundation

/// User-defined variable data from #DIM/#DIMS directives
public final class UserDefinedVariableData {
    public var name: String?
    public var typeIsStr: Bool = false
    public var reference: Bool = false
    public var dimension: Int = 1
    public var lengths: [Int] = []
    public var defaultInt: [Int64] = []
    public var defaultStr: [String] = []
    public var global: Bool = false
    public var save: Bool = false
    public var `static`: Bool = true
    public var `private`: Bool = false
    public var charaData: Bool = false
    public var `const`: Bool = false

    public init() {}

    /// Create from DimLineData
    public static func create(from dimLine: DimLineData) throws -> UserDefinedVariableData {
        return try create(
            wc: dimLine.wc,
            dims: dimLine.isString,
            isPrivate: dimLine.isPrivate,
            position: dimLine.position
        )
    }

    /// Main creation method
    public static func create(
        wc: WordCollection,
        dims: Bool,
        isPrivate: Bool,
        position: ScriptPosition
    ) throws -> UserDefinedVariableData {
        let dimType = dims ? "#DIMS" : "#DIM"
        let ret = UserDefinedVariableData()
        ret.typeIsStr = dims

        var staticDefined = false
        ret.const = false
        var keyword = dimType

        // Parse keywords before variable name
        keywordLoop: while !wc.eol, let word = wc.current as? IdentifierWord {
            wc.shiftNext()
            keyword = word.code.uppercased()

            switch keyword {
            case "CONST":
                if ret.charaData {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCHARADATAキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.global {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とGLOBALキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.save {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とSAVEDATAキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.reference {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とREFキーワードは同時に指定できません",
                        position: position
                    )
                }
                if !ret.static {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とDYNAMICキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.const {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)キーワードが二重に指定されています",
                        position: position
                    )
                }
                ret.const = true

            case "REF":
                if staticDefined && ret.static {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とSTATICキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.charaData {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCHARADATAキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.global {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とGLOBALキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.save {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とSAVEDATAキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.const {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCONSTキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.reference {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)キーワードが二重に指定されています",
                        position: position
                    )
                }
                ret.reference = true
                ret.static = false

            case "DYNAMIC":
                if !isPrivate {
                    throw EmueraError.headerFileError(
                        message: "広域変数の宣言に\(keyword)キーワードは指定できません",
                        position: position
                    )
                }
                if ret.charaData {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCHARADATAキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.const {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCONSTキーワードは同時に指定できません",
                        position: position
                    )
                }
                if staticDefined {
                    if ret.static {
                        throw EmueraError.headerFileError(
                            message: "STATICとDYNAMICキーワードは同時に指定できません",
                            position: position
                        )
                    } else {
                        throw EmueraError.headerFileError(
                            message: "\(keyword)キーワードが二重に指定されています",
                            position: position
                        )
                    }
                }
                staticDefined = true
                ret.static = false

            case "STATIC":
                if !isPrivate {
                    throw EmueraError.headerFileError(
                        message: "広域変数の宣言に\(keyword)キーワードは指定できません",
                        position: position
                    )
                }
                if ret.charaData {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCHARADATAキーワードは同時に指定できません",
                        position: position
                    )
                }
                if staticDefined {
                    if !ret.static {
                        throw EmueraError.headerFileError(
                            message: "STATICとDYNAMICキーワードは同時に指定できません",
                            position: position
                        )
                    } else {
                        throw EmueraError.headerFileError(
                            message: "\(keyword)キーワードが二重に指定されています",
                            position: position
                        )
                    }
                }
                if ret.reference {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とREFキーワードは同時に指定できません",
                        position: position
                    )
                }
                staticDefined = true
                ret.static = true

            case "GLOBAL":
                if isPrivate {
                    throw EmueraError.headerFileError(
                        message: "ローカル変数の宣言に\(keyword)キーワードは指定できません",
                        position: position
                    )
                }
                if ret.charaData {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCHARADATAキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.reference {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とREFキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.const {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCONSTキーワードは同時に指定できません",
                        position: position
                    )
                }
                if staticDefined {
                    if ret.static {
                        throw EmueraError.headerFileError(
                            message: "STATICとGLOBALキーワードは同時に指定できません",
                            position: position
                        )
                    } else {
                        throw EmueraError.headerFileError(
                            message: "DYNAMICとGLOBALキーワードは同時に指定できません",
                            position: position
                        )
                    }
                }
                ret.global = true

            case "SAVEDATA":
                if isPrivate {
                    throw EmueraError.headerFileError(
                        message: "ローカル変数の宣言に\(keyword)キーワードは指定できません",
                        position: position
                    )
                }
                if staticDefined {
                    if ret.static {
                        throw EmueraError.headerFileError(
                            message: "STATICとSAVEDATAキーワードは同時に指定できません",
                            position: position
                        )
                    } else {
                        throw EmueraError.headerFileError(
                            message: "DYNAMICとSAVEDATAキーワードは同時に指定できません",
                            position: position
                        )
                    }
                }
                if ret.reference {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とREFキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.const {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCONSTキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.save {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)キーワードが二重に指定されています",
                        position: position
                    )
                }
                ret.save = true

            case "CHARADATA":
                if isPrivate {
                    throw EmueraError.headerFileError(
                        message: "ローカル変数の宣言に\(keyword)キーワードは指定できません",
                        position: position
                    )
                }
                if ret.reference {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とREFキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.const {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とCONSTキーワードは同時に指定できません",
                        position: position
                    )
                }
                if staticDefined {
                    if ret.static {
                        throw EmueraError.headerFileError(
                            message: "\(keyword)とSTATICキーワードは同時に指定できません",
                            position: position
                        )
                    } else {
                        throw EmueraError.headerFileError(
                            message: "\(keyword)とDYNAMICキーワードは同時に指定できません",
                            position: position
                        )
                    }
                }
                if ret.global {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)とGLOBALキーワードは同時に指定できません",
                        position: position
                    )
                }
                if ret.charaData {
                    throw EmueraError.headerFileError(
                        message: "\(keyword)キーワードが二重に指定されています",
                        position: position
                    )
                }
                ret.charaData = true

            default:
                ret.name = keyword
                break keywordLoop
            }
        }

        guard let varName = ret.name else {
            throw EmueraError.headerFileError(
                message: "\(keyword)の後に有効な変数名が指定されていません",
                position: position
            )
        }

        // Check variable name conflicts
        var errMes = ""
        var errLevel = -1
        if isPrivate {
            // TODO: Check private variable name
        } else {
            // TODO: Check global variable name
        }

        // Parse array sizes and initial values
        var sizeNum: [Int] = []

        if wc.eol {
            // No size specified
            if ret.const {
                throw EmueraError.headerFileError(
                    message: "CONSTキーワードが指定されていますが初期値が設定されていません",
                    position: position
                )
            }
            sizeNum.append(1)
        } else if wc.current is SymbolWord, (wc.current as! SymbolWord).symbol == "," {
            // Size specified
            while !wc.eol {
                if wc.current is SymbolWord, (wc.current as! SymbolWord).symbol == "=" {
                    break
                }
                if !(wc.current is SymbolWord) || (wc.current as! SymbolWord).symbol != "," {
                    throw EmueraError.headerFileError(
                        message: "書式が間違っています",
                        position: position
                    )
                }
                wc.shiftNext()

                if ret.reference {
                    sizeNum.append(0)
                    if wc.eol { break }
                    if wc.current is SymbolWord, (wc.current as! SymbolWord).symbol == "," {
                        continue
                    }
                }

                if wc.eol {
                    throw EmueraError.headerFileError(
                        message: "カンマの後に有効な定数式が指定されていません",
                        position: position
                    )
                }

                // Parse size expression (simplified - would need ExpressionParser)
                // For now, we'll skip complex expression parsing
                if let intWord = wc.current as? LiteralIntegerWord {
                    let size = intWord.value
                    if size <= 0 || size > 1000000 {
                        throw EmueraError.headerFileError(
                            message: "ユーザー定義変数のサイズは1以上1000000以下でなければなりません",
                            position: position
                        )
                    }
                    sizeNum.append(Int(size))
                    wc.shiftNext()
                } else {
                    throw EmueraError.headerFileError(
                        message: "サイズには整数値を指定してください",
                        position: position
                    )
                }
            }
        }

        // Check for initial values
        if wc.current is SymbolWord, (wc.current as! SymbolWord).symbol == "=" {
            if ret.reference {
                throw EmueraError.headerFileError(
                    message: "参照型変数には初期値を設定できません",
                    position: position
                )
            }
            if sizeNum.count >= 2 {
                throw EmueraError.headerFileError(
                    message: "多次元変数には初期値を設定できません",
                    position: position
                )
            }
            if ret.charaData {
                throw EmueraError.headerFileError(
                    message: "キャラ型変数には初期値を設定できません",
                    position: position
                )
            }

            wc.shiftNext() // Skip =

            // Parse initial values (simplified)
            var values: [String] = []
            while !wc.eol {
                if let strWord = wc.current as? LiteralStringWord {
                    values.append(strWord.value)
                } else if let intWord = wc.current as? LiteralIntegerWord {
                    values.append("\(intWord.value)")
                } else {
                    throw EmueraError.headerFileError(
                        message: "初期値には定数を指定してください",
                        position: position
                    )
                }
                wc.shiftNext()

                if !wc.eol, wc.current is SymbolWord, (wc.current as! SymbolWord).symbol == "," {
                    wc.shiftNext()
                }
            }

            // Validate initial values
            let size = sizeNum.count > 0 ? sizeNum[0] : values.count
            if values.count > size {
                throw EmueraError.headerFileError(
                    message: "初期値の数が配列のサイズを超えています",
                    position: position
                )
            }
            if ret.const && values.count != size {
                throw EmueraError.headerFileError(
                    message: "定数の初期値の数が配列のサイズと一致しません",
                    position: position
                )
            }

            // Store initial values
            if dims {
                ret.defaultStr = values
            } else {
                ret.defaultInt = values.compactMap { Int64($0) }
            }

            if sizeNum.isEmpty {
                sizeNum.append(values.count)
            }
        }

        if !wc.eol {
            throw EmueraError.headerFileError(
                message: "書式が間違っています",
                position: position
            )
        }

        if sizeNum.isEmpty {
            sizeNum.append(1)
        }

        ret.private = isPrivate
        ret.dimension = sizeNum.count

        if ret.const && ret.dimension > 1 {
            throw EmueraError.headerFileError(
                message: "CONSTキーワードが指定された変数を多次元配列にはできません",
                position: position
            )
        }
        if ret.charaData && ret.dimension > 2 {
            throw EmueraError.headerFileError(
                message: "3次元以上のキャラ型変数を宣言することはできません",
                position: position
            )
        }
        if ret.dimension > 3 {
            throw EmueraError.headerFileError(
                message: "4次元以上の配列変数を宣言することはできません",
                position: position
            )
        }

        ret.lengths = sizeNum

        if ret.reference {
            return ret
        }

        // Check total size
        var totalBytes: Int64 = 1
        for len in ret.lengths {
            totalBytes *= Int64(len)
        }
        if totalBytes <= 0 || totalBytes > 1000000 {
            throw EmueraError.headerFileError(
                message: "ユーザー定義変数のサイズは1以上1000000以下でなければなりません",
                position: position
            )
        }

        // Check SAVEDATA compatibility
        if !isPrivate && ret.save {
            if dims && ret.dimension > 1 {
                // Would need Config check
            } else if ret.charaData {
                // Would need Config check
            }
        }

        return ret
    }
}

/// Helper struct for DIM line data
public struct DimLineData {
    public let wc: WordCollection
    public let isString: Bool
    public let isPrivate: Bool
    public let position: ScriptPosition

    public init(wc: WordCollection, isString: Bool, isPrivate: Bool, position: ScriptPosition) {
        self.wc = wc
        self.isString = isString
        self.isPrivate = isPrivate
        self.position = position
    }
}
