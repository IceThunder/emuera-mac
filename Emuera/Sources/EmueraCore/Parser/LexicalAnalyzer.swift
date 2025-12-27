//
//  LexicalAnalyzer.swift
//  EmueraCore
//  MVP版词法分析器
//  Created: 2025-12-18
//

import Foundation

public struct LexicalAnalyzer {
    public init() {}

    public func tokenize(_ source: String) -> [TokenType.Token] {
        var tokens: [TokenType.Token] = []
        var index = source.startIndex
        var line = 1

        while index < source.endIndex {
            let c = source[index]

            // 空白处理
            if c.isWhitespace {
                if c == "\n" {
                    line += 1
                    tokens.append(TokenType.Token(type: .lineBreak, value: "\n", position: ScriptPosition(filename: "script", lineNumber: line)))
                }
                source.formIndex(after: &index)
                continue
            }

            // 注释
            if c == ";" {
                while index < source.endIndex && source[index] != "\n" {
                    source.formIndex(after: &index)
                }
                continue
            }

            // 字符串
            if c == "\"" {
                let start = source.index(after: index)
                var current = start
                while current < source.endIndex && source[current] != "\"" {
                    current = source.index(after: current)
                }
                if current < source.endIndex {
                    let value = String(source[start..<current])
                    let token = TokenType.Token(type: .string(value), value: value, position: ScriptPosition(filename: "script", lineNumber: line))
                    tokens.append(token)
                    index = source.index(after: current)
                    continue
                }
            }

            // 数字（只匹配阿拉伯数字0-9，避免中文数字如"一"被错误处理）
            // 支持十六进制（0x前缀）和十进制
            // 但如果数字后紧跟非ASCII字符，整个作为字符串处理
            if c.isNumber && c.isASCII {
                var current = index
                var digits = ""

                // 检查是否是十六进制字面量 (0x...)
                var isHex = false
                if c == "0" && source.index(after: index) < source.endIndex {
                    let nextChar = source[source.index(after: index)]
                    if nextChar == "x" || nextChar == "X" {
                        isHex = true
                        current = source.index(after: index) // 跳过0
                        current = source.index(after: current) // 跳过x/X
                        // 读取十六进制数字
                        while current < source.endIndex {
                            let ch = source[current]
                            if ch.isNumber || (ch >= "a" && ch <= "f") || (ch >= "A" && ch <= "F") {
                                digits.append(ch)
                                current = source.index(after: current)
                            } else {
                                break
                            }
                        }
                    }
                }

                // 如果不是十六进制，读取十进制数字
                if !isHex {
                    while current < source.endIndex && source[current].isNumber && source[current].isASCII {
                        digits.append(source[current])
                        current = source.index(after: current)
                    }
                }

                // 检查数字后是否紧跟非ASCII字符
                if current < source.endIndex && source[current].isASCII == false {
                    // 数字后有中文，作为字符串处理
                    var str = isHex ? "0x\(digits)" : digits
                    while current < source.endIndex {
                        let ch = source[current]
                        if ch.isASCII == false {
                            str.append(ch)
                            current = source.index(after: current)
                        } else if ch.isLetter || ch.isNumber || ch == "_" || ch == "$" || ch == "%" {
                            str.append(ch)
                            current = source.index(after: current)
                        } else {
                            break
                        }
                    }
                    tokens.append(TokenType.Token(type: .string(str), value: str, position: ScriptPosition(filename: "script", lineNumber: line)))
                    index = current
                    continue
                }

                // 转换为整数值
                if isHex {
                    if let value = Int64(digits, radix: 16) {
                        tokens.append(TokenType.Token(type: .integer(value), value: "0x\(digits)", position: ScriptPosition(filename: "script", lineNumber: line)))
                        index = current
                        continue
                    }
                } else {
                    if let value = Int64(digits) {
                        tokens.append(TokenType.Token(type: .integer(value), value: digits, position: ScriptPosition(filename: "script", lineNumber: line)))
                        index = current
                        continue
                    }
                }
            }

            // Check for modulo operator (%) before identifier parsing
            // This must come before identifier check because % is also a variable prefix
            if c == "%" {
                // Check if this is modulo operator (%) or variable prefix (%VAR)
                // Modulo operator: % followed by space, digit, operator, parenthesis, or end
                // Variable prefix: % followed by letter
                let nextIndex = source.index(after: index)
                if nextIndex < source.endIndex {
                    let nextChar = source[nextIndex]
                    if nextChar.isLetter {
                        // This is a variable prefix like %VAR - fall through to identifier parsing
                    } else {
                        // This is modulo operator
                        tokens.append(TokenType.Token(type: .operatorSymbol(.modulo), value: "%", position: ScriptPosition(filename: "script", lineNumber: line)))
                        index = nextIndex
                        continue
                    }
                } else {
                    // % at end of source - treat as modulo operator
                    tokens.append(TokenType.Token(type: .operatorSymbol(.modulo), value: "%", position: ScriptPosition(filename: "script", lineNumber: line)))
                    index = nextIndex
                    continue
                }
            }

            // 标识符（支持Unicode字符如中文作为变量名）
            // 或者处理混合内容如"5到15之间"
            if c.isLetter || c.isASCII == false || c == "$" || c == "%" || c == "@" || c == "_" {
                var current = index
                var identifier = ""
                var hasNonASCII = false

                while current < source.endIndex {
                    let ch = source[current]
                    if ch.isASCII == false {
                        // 非ASCII字符（如中文）
                        identifier.append(ch)
                        hasNonASCII = true
                        current = source.index(after: current)
                    } else if ch.isLetter || ch.isNumber || ch == "_" || ch == "$" || ch == "%" || ch == "@" || ch == "." {
                        // ASCII字母、数字、符号（包括@用于标签，.用于文件名）
                        identifier.append(ch)
                        current = source.index(after: current)
                    } else {
                        break
                    }
                }

                // 如果包含非ASCII字符，作为字符串处理
                if hasNonASCII {
                    tokens.append(TokenType.Token(type: .string(identifier), value: identifier, position: ScriptPosition(filename: "script", lineNumber: line)))
                    index = current
                    continue
                }

                let tokenType: TokenType
                let upper = identifier.uppercased()

                // 检查是否是函数指令 (#DIM, #FUNCTIONS等)
                if identifier.hasPrefix("#") {
                    tokenType = .directive(identifier)
                }
                // 检查是否是关键字 (优先于命令检查，避免WHILE/DO/FOR等被识别为命令)
                else if ["IF", "ELSE", "ELSEIF", "ENDIF",
                         "WHILE", "ENDWHILE",
                         "FOR", "ENDFOR", "NEXT",
                         "DO", "LOOP", "UNTIL",
                         "REPEAT", "ENDREPEAT", "REND",
                         "SELECTCASE", "CASE", "CASEELSE", "ENDSELECT",
                         "BREAK", "CONTINUE", "RETURN", "RESTART", "RETURNF",
                         "GOTO", "CALL", "JUMP", "TRYCALL", "TRYCALLFORM",
                         "TRY", "CATCH", "ENDTRY", "TRYJUMP", "TRYGOTO", "TRYJUMPLIST", "TRYGOTOLIST",
                         "TRYCCALLFORM", "TRYCGOTOFORM", "TRYCJUMPFORM", "TRYCALLLIST",
                         "TO", "PRINTDATA", "DATALIST", "ENDLIST", "ENDDATA",
                         "SAVEDATA", "LOADDATA", "DELDATA", "SAVEVAR", "LOADVAR",
                         "SAVECHARA", "LOADCHARA", "SAVEGAME", "LOADGAME",
                         "SAVELIST", "SAVEEXISTS", "AUTOSAVE", "SAVEINFO",
                         "RESETDATA", "RESETGLOBAL", "PERSIST"].contains(upper) {
                    tokenType = .keyword(identifier)
                }
                // 检查是否是命令 (在关键字检查之后)
                else if CommandType.fromString(identifier) != .UNKNOWN {
                    tokenType = .command(identifier)
                }
                // 检查是否是内置函数
                else if BuiltInFunctions.exists(identifier) {
                    tokenType = .function(identifier)
                }
                // 检查标签（函数定义）
                else if identifier.hasPrefix("@") {
                    tokenType = .label(identifier)
                }
                // 检查变量
                else if identifier.hasPrefix("$") || identifier.hasPrefix("%") {
                    tokenType = .variable(identifier)
                }
                // 纯字母标识符 - 作为变量处理（Emuera兼容）
                else {
                    tokenType = .variable(identifier)
                }

                tokens.append(TokenType.Token(type: tokenType, value: identifier, position: ScriptPosition(filename: "script", lineNumber: line)))
                index = current
                continue
            }

            // 操作符
            let nextIndex = source.index(after: index)
            let twoChar = nextIndex < source.endIndex ? String([c, source[nextIndex]]) : ""

            if twoChar != "" {
                if let op = TokenType.Operator(rawValue: twoChar) {
                    tokens.append(TokenType.Token(type: .operatorSymbol(op), value: twoChar, position: ScriptPosition(filename: "script", lineNumber: line)))
                    index = nextIndex
                    source.formIndex(after: &index)
                    continue
                }

                if let comp = TokenType.Comparator(rawValue: twoChar) {
                    tokens.append(TokenType.Token(type: .comparator(comp), value: twoChar, position: ScriptPosition(filename: "script", lineNumber: line)))
                    index = nextIndex
                    source.formIndex(after: &index)
                    continue
                }
            }

            if let op = TokenType.Operator(rawValue: String(c)) {
                tokens.append(TokenType.Token(type: .operatorSymbol(op), value: String(c), position: ScriptPosition(filename: "script", lineNumber: line)))
                source.formIndex(after: &index)
                continue
            }
            if let comp = TokenType.Comparator(rawValue: String(c)) {
                tokens.append(TokenType.Token(type: .comparator(comp), value: String(c), position: ScriptPosition(filename: "script", lineNumber: line)))
                source.formIndex(after: &index)
                continue
            }

            // 标点
            switch c {
            case ",":
                tokens.append(TokenType.Token(type: .comma, value: ",", position: ScriptPosition(filename: "script", lineNumber: line)))
            case ":":
                tokens.append(TokenType.Token(type: .colon, value: ":", position: ScriptPosition(filename: "script", lineNumber: line)))
            case "[":
                tokens.append(TokenType.Token(type: .bracketOpen, value: "[", position: ScriptPosition(filename: "script", lineNumber: line)))
            case "]":
                tokens.append(TokenType.Token(type: .bracketClose, value: "]", position: ScriptPosition(filename: "script", lineNumber: line)))
            case "(":
                tokens.append(TokenType.Token(type: .parenthesisOpen, value: "(", position: ScriptPosition(filename: "script", lineNumber: line)))
            case ")":
                tokens.append(TokenType.Token(type: .parenthesisClose, value: ")", position: ScriptPosition(filename: "script", lineNumber: line)))
            case "{":
                tokens.append(TokenType.Token(type: .braceOpen, value: "{", position: ScriptPosition(filename: "script", lineNumber: line)))
            case "}":
                tokens.append(TokenType.Token(type: .braceClose, value: "}", position: ScriptPosition(filename: "script", lineNumber: line)))
            default:
                // 处理非ASCII字符（如中文），作为字符串处理
                if c.isASCII == false {
                    // 读取连续的非ASCII字符作为字符串
                    var current = index
                    var str = ""
                    while current < source.endIndex {
                        let ch = source[current]
                        if ch.isASCII == false {
                            str.append(ch)
                            current = source.index(after: current)
                        } else {
                            break
                        }
                    }
                    if !str.isEmpty {
                        tokens.append(TokenType.Token(type: .string(str), value: str, position: ScriptPosition(filename: "script", lineNumber: line)))
                        index = current
                        continue
                    }
                }
            }
            source.formIndex(after: &index)
        }

        return tokens
    }
}
