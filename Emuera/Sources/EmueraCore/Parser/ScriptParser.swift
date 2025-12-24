//
//  ScriptParser.swift
//  EmueraCore
//
//  语法解析器 - 将Token流解析为语句AST
//  支持IF/WHILE/CALL/GOTO等控制流结构
//  Created: 2025-12-19
//

import Foundation

// MARK: - 脚本解析器

/// 语法解析器
/// 将Token序列解析为语句AST
public class ScriptParser {
    private var tokens: [TokenType.Token] = []
    private var currentIndex: Int = 0
    private var currentLine: Int = 1

    // Phase 2: 函数系统
    private var functionDefinitions: [String: FunctionDefinition] = [:]  // 收集到的函数定义
    private var currentFunctionName: String? = nil  // 当前正在解析的函数名

    public init() {}

    /// 解析脚本，返回语句列表
    public func parse(_ source: String) throws -> [StatementNode] {
        let lexer = LexicalAnalyzer()
        self.tokens = lexer.tokenize(source)
        self.currentIndex = 0
        self.currentLine = 1

        var statements: [StatementNode] = []

        while currentIndex < tokens.count {
            // 跳过空白和换行
            skipWhitespaceAndNewlines()

            if currentIndex >= tokens.count {
                break
            }

            // 解析单个语句
            if let statement = try parseStatement() {
                statements.append(statement)
            }
        }

        return statements
    }

    // MARK: - 语句解析

    /// 解析单个语句
    private func parseStatement() throws -> StatementNode? {
        let token = tokens[currentIndex]

        switch token.type {
        case .directive(let directive):
            return try parseDirectiveStatement(directive)

        case .command(let cmd):
            return try parseCommandStatement(cmd)

        case .variable:
            return try parseAssignmentOrExpression()

        case .function:
            // 函数名在语句开头可能是赋值（如 LIMIT = 5）或表达式
            return try parseAssignmentOrExpression()

        case .keyword(let keyword):
            return try parseKeywordStatement(keyword)

        case .caseKeyword, .caseElse, .endSelect:
            // 这些应该在SELECTCASE解析时处理，不应该单独出现
            throw EmueraError.scriptParseError(
                message: "未匹配的SELECTCASE关键字: \(token.value)",
                position: getCurrentPosition()
            )

        case .label:
            // 检查是否是函数定义 (@函数名)
            if case .label(let name) = token.type, name.hasPrefix("@") {
                // 检查下一个token
                if currentIndex + 1 < tokens.count {
                    let nextToken = tokens[currentIndex + 1]
                    switch nextToken.type {
                    case .comma:
                        // @Func, param1, param2 ... 是函数定义
                        return try parseFunctionDefinition()
                    case .lineBreak:
                        // @Func\n 后面跟 #DIM 或 RETURN 等是函数定义
                        // @Label\n 后面跟 PRINT/GOTO/TRYGOTO 等是标签
                        // 需要向前看更多token来判断
                        if let remainingTokens = getTokensAfter(currentIndex + 2),
                           isFunctionDefinitionStart(remainingTokens) {
                            return try parseFunctionDefinition()
                        }
                    default:
                        break
                    }
                }
            }
            return try parseLabelStatement()

        case .integer, .string:
            // 裸表达式
            return try parseExpressionStatement()

        default:
            // 未知token，跳过
            currentIndex += 1
            return nil
        }
    }

    // MARK: - 命令语句解析

    /// 解析命令语句 (PRINT, PRINTL, WAIT, QUIT等)
    private func parseCommandStatement(_ cmd: String) throws -> StatementNode {
        let upperCmd = cmd.uppercased()
        let startPos = getCurrentPosition()

        currentIndex += 1  // 跳过命令token

        switch upperCmd {
        case "PRINT", "PRINTL", "PRINTW":
            let args = try parsePrintArguments()
            return CommandStatement(command: cmd, arguments: args, position: startPos)

        case "INPUT", "INPUTS":
            // INPUT没有参数，或者可能有提示字符串
            let args = try parseArguments()
            return CommandStatement(command: cmd, arguments: args, position: startPos)

        case "WAIT", "WAITANYKEY":
            return CommandStatement(command: cmd, arguments: [], position: startPos)

        case "QUIT":
            return CommandStatement(command: cmd, arguments: [], position: startPos)

        case "RESET":
            return ResetStatement(position: startPos)

        case "SAVEDATA", "LOADDATA", "DELDATA":
            return try parseSaveLoadCommand(upperCmd)

        case "SAVEVAR", "LOADVAR":
            return try parseSaveVarCommand(upperCmd)

        case "SAVECHARA", "LOADCHARA":
            return try parseSaveCharaCommand(upperCmd)

        case "SAVEGAME", "LOADGAME":
            return try parseSaveGameCommand(upperCmd)

        case "RESETDATA":
            return ResetDataStatement(position: startPos)

        case "RESETGLOBAL":
            return ResetGlobalStatement(position: startPos)

        case "PERSIST":
            return try parsePersistCommand()

        default:
            // 其他命令，作为通用命令处理
            let args = try parseArguments()
            return CommandStatement(command: cmd, arguments: args, position: startPos)
        }
    }

    /// 解析PERSIST ON/OFF
    private func parsePersistStatement() throws -> PersistStatement {
        let startPos = getCurrentPosition()

        // parseCommandStatement已经跳过了PERSIST token，currentIndex现在指向ON/OFF
        // 只需要跳过空白
        skipWhitespaceAndNewlines()

        // 检查是否有参数（支持无参数的情况）
        guard currentIndex < tokens.count else {
            // 无参数：默认开启持久化
            return PersistStatement(enabled: true, position: startPos)
        }

        let token = tokens[currentIndex]

        // 检查是否是变量（ON/OFF）
        if case .variable(let value) = token.type {
            let upperValue = value.uppercased()
            let enabled = (upperValue == "ON" || upperValue == "TRUE" || upperValue == "1")
            currentIndex += 1
            return PersistStatement(enabled: enabled, position: startPos)
        }

        // 其他情况，默认开启
        return PersistStatement(enabled: true, position: startPos)
    }

    // MARK: - 关键字语句解析

    /// 解析关键字语句 (IF, WHILE, FOR等)
    private func parseKeywordStatement(_ keyword: String) throws -> StatementNode {
        let upperKeyword = keyword.uppercased()

        switch upperKeyword {
        case "IF":
            return try parseIfStatement()

        case "WHILE":
            return try parseWhileStatement()

        case "FOR":
            return try parseForStatement()

        case "DO":
            return try parseDoLoopStatement()

        case "REPEAT":
            return try parseRepeatStatement()

        case "SELECTCASE":
            return try parseSelectCaseStatement()

        case "PRINTDATA":
            return try parsePrintDataStatement()

        case "BREAK":
            currentIndex += 1
            return BreakStatement(position: getCurrentPosition())

        case "CONTINUE":
            currentIndex += 1
            return ContinueStatement(position: getCurrentPosition())

        case "RETURN":
            currentIndex += 1
            let value = try parseOptionalExpression()
            return ReturnStatement(value: value, position: getCurrentPosition())

        case "RETURNF":
            currentIndex += 1
            let value = try parseOptionalExpression()
            return ReturnStatement(value: value, position: getCurrentPosition(), isFunctionReturn: true)

        case "CALL", "TRYCALL":
            return try parseCallStatement()

        case "GOTO":
            return try parseGotoStatement()

        case "TRY":
            return try parseTryCatchStatement()

        case "TRYJUMP":
            return try parseTryJumpStatement()

        case "TRYGOTO":
            return try parseTryGotoStatement()

        case "SAVELIST":
            return try parseSaveListCommand()

        case "SAVEEXISTS":
            return try parseSaveExistsCommand()

        case "AUTOSAVE":
            return try parseAutoSaveCommand()

        case "SAVEINFO":
            return try parseSaveInfoCommand()

        case "RESETDATA":
            return try parseResetDataCommand()

        case "RESETGLOBAL":
            return try parseResetGlobalCommand()

        case "PERSIST":
            return try parsePersistCommand()

        case "CATCH", "ENDTRY", "TRYJUMPLIST", "TRYGOTOLIST":
            // 这些应该在TRY/CATCH解析时处理，不应该单独出现
            throw EmueraError.scriptParseError(
                message: "未匹配的TRY/CATCH关键字: \\(keyword)",
                position: getCurrentPosition()
            )

        case "ELSE", "ENDIF", "ENDWHILE", "ENDFOR", "ENDREPEAT", "CASE", "CASEELSE", "ENDSELECT":
            // 这些应该在解析对应结构时处理，不应该单独出现
            throw EmueraError.scriptParseError(
                message: "未匹配的结束关键字: \(keyword)",
                position: getCurrentPosition()
            )

        default:
            // 未知关键字，跳过
            currentIndex += 1
            return ExpressionStatement(
                expression: .variable(keyword),
                position: getCurrentPosition()
            )
        }
    }

    // MARK: - IF语句解析

    /// 解析IF语句
    /// IF condition
    ///   statements
    /// ELSE
    ///   statements
    /// ENDIF
    private func parseIfStatement() throws -> IfStatement {
        let startPos = getCurrentPosition()

        // 跳过IF
        currentIndex += 1

        // 解析条件表达式
        let condition = try parseExpression()

        // 解析THEN块
        let thenBlock = try parseBlock(until: ["ELSE", "ENDIF"])

        var elseBlock: StatementNode? = nil

        // 检查是否有ELSE
        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "ELSE" {
            currentIndex += 1  // 跳过ELSE
            elseBlock = try parseBlock(until: ["ENDIF"])
        }

        // 消耗ENDIF
        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "ENDIF" {
            currentIndex += 1
        } else {
            throw EmueraError.scriptParseError(
                message: "IF语句缺少ENDIF",
                position: getCurrentPosition()
            )
        }

        return IfStatement(
            condition: condition,
            thenBlock: thenBlock,
            elseBlock: elseBlock,
            position: startPos
        )
    }

    // MARK: - WHILE语句解析

    /// 解析WHILE语句
    /// WHILE condition
    ///   statements
    /// ENDWHILE
    private func parseWhileStatement() throws -> WhileStatement {
        let startPos = getCurrentPosition()

        // 跳过WHILE
        currentIndex += 1

        // 解析条件表达式
        let condition = try parseExpression()

        // 解析循环体
        let body = try parseBlock(until: ["ENDWHILE"])

        // 消耗ENDWHILE
        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "ENDWHILE" {
            currentIndex += 1
        } else {
            throw EmueraError.scriptParseError(
                message: "WHILE语句缺少ENDWHILE",
                position: getCurrentPosition()
            )
        }

        return WhileStatement(condition: condition, body: body, position: startPos)
    }

    // MARK: - FOR语句解析

    /// 解析FOR语句
    /// FOR variable, start, end [, step]
    ///   statements
    /// ENDFOR
    private func parseForStatement() throws -> ForStatement {
        let startPos = getCurrentPosition()

        // 跳过FOR
        currentIndex += 1

        // 解析参数: variable, start, end [, step]
        let params = try parseArgumentList()

        guard params.count >= 3 else {
            throw EmueraError.scriptParseError(
                message: "FOR语句需要至少3个参数: variable, start, end",
                position: getCurrentPosition()
            )
        }

        // 提取参数
        guard case .variable(let varName) = params[0] else {
            throw EmueraError.scriptParseError(
                message: "FOR第一个参数必须是变量名",
                position: getCurrentPosition()
            )
        }

        let start = params[1]
        let end = params[2]
        let step = params.count > 3 ? params[3] : nil

        // 解析循环体
        let body = try parseBlock(until: ["ENDFOR"])

        // 消耗ENDFOR
        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "ENDFOR" {
            currentIndex += 1
        } else {
            throw EmueraError.scriptParseError(
                message: "FOR语句缺少ENDFOR",
                position: getCurrentPosition()
            )
        }

        return ForStatement(
            variable: varName,
            start: start,
            end: end,
            step: step,
            body: body,
            position: startPos
        )
    }

    // MARK: - SELECTCASE语句解析


    // MARK: - 跳转语句解析

    /// 解析GOTO语句
    private func parseGotoStatement() throws -> GotoStatement {
        let startPos = getCurrentPosition()

        // 跳过GOTO
        currentIndex += 1

        // 跳过空白
        skipWhitespaceAndNewlines()

        // 期望一个标签名（可以是@label或variable）
        guard currentIndex < tokens.count else {
            throw EmueraError.scriptParseError(
                message: "GOTO后需要标签名",
                position: getCurrentPosition()
            )
        }

        let label: String
        switch tokens[currentIndex].type {
        case .label(let l):
            label = l
        case .variable(let v):
            label = v
        default:
            throw EmueraError.scriptParseError(
                message: "GOTO后需要标签名",
                position: getCurrentPosition()
            )
        }

        currentIndex += 1

        return GotoStatement(label: label, position: startPos)
    }

    /// 解析CALL语句 - 支持传统标签跳转和函数调用
    private func parseCallStatement() throws -> StatementNode {
        let startPos = getCurrentPosition()

        // 检查是CALL还是TRYCALL
        let isTryCall: Bool
        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "TRYCALL" {
            isTryCall = true
        } else {
            isTryCall = false
        }

        // 跳过CALL/TRYCALL
        currentIndex += 1

        // 跳过空白
        skipWhitespaceAndNewlines()

        // 期望一个函数名或标签名
        guard currentIndex < tokens.count else {
            throw EmueraError.scriptParseError(
                message: "CALL后需要函数名",
                position: getCurrentPosition()
            )
        }

        var functionName: String
        var isFunctionCall = false

        if case .variable(let name) = tokens[currentIndex].type {
            functionName = name
            currentIndex += 1
        } else if case .label(let name) = tokens[currentIndex].type {
            functionName = name
            currentIndex += 1
            // @开头的标签是函数调用
            if functionName.hasPrefix("@") {
                isFunctionCall = true
                functionName = String(functionName.dropFirst()) // 移除@前缀
            }
        } else {
            throw EmueraError.scriptParseError(
                message: "CALL后需要函数名或标签名",
                position: getCurrentPosition()
            )
        }

        // 解析参数（可选）
        let args = try parseArguments()

        // 对于TRYCALL，检查是否有CATCH标签
        if isTryCall {
            skipWhitespaceAndNewlines()
            var catchLabel: String? = nil

            if currentIndex < tokens.count,
               case .keyword(let k) = tokens[currentIndex].type,
               k.uppercased() == "CATCH" {
                currentIndex += 1  // 跳过CATCH

                // 获取标签名
                skipWhitespaceAndNewlines()
                if currentIndex < tokens.count,
                   case .label(let name) = tokens[currentIndex].type {
                    catchLabel = name  // 保留@前缀
                    currentIndex += 1
                } else if currentIndex < tokens.count,
                          case .variable(let name) = tokens[currentIndex].type {
                    catchLabel = name
                    currentIndex += 1
                }
            }

            // 如果有CATCH标签，返回TryCallStatement
            if let catchLabel = catchLabel {
                return TryCallStatement(
                    functionName: functionName,
                    arguments: args,
                    catchLabel: catchLabel,
                    position: startPos
                )
            }

            // 没有CATCH标签，作为tryMode的FunctionCallStatement
            return FunctionCallStatement(
                functionName: functionName,
                arguments: args,
                tryMode: true,
                position: startPos
            )
        }

        // 根据是否是函数调用返回不同类型的语句
        if isFunctionCall {
            return FunctionCallStatement(
                functionName: functionName,
                arguments: args,
                tryMode: false,
                position: startPos
            )
        } else {
            return CallStatement(target: functionName, arguments: args, position: startPos)
        }
    }

    /// 解析标签定义
    private func parseLabelStatement() throws -> LabelStatement {
        let startPos = getCurrentPosition()

        guard case .label(let name) = tokens[currentIndex].type else {
            throw EmueraError.scriptParseError(
                message: "预期标签",
                position: getCurrentPosition()
            )
        }

        currentIndex += 1

        return LabelStatement(name: name, position: startPos)
    }

    // MARK: - 赋值和表达式语句

    /// 解析赋值或表达式语句
    private func parseAssignmentOrExpression() throws -> StatementNode {
        let startPos = getCurrentPosition()

        // 优先检查数组赋值: A:0 = 3 或 A:0:1 = 3
        // 也支持 function:0 = 3 (因为函数名可能被误识别为函数)
        // 必须在标签定义检查之前，因为两者都以 variable: 开头
        if currentIndex + 3 < tokens.count,
           case .colon = tokens[currentIndex + 1].type {

            var varName: String? = nil

            switch tokens[currentIndex].type {
            case .variable(let name):
                varName = name
            case .function(let name):
                varName = name
            default:
                varName = nil
            }

            if let name = varName {
                // 收集数组索引: A:0:1:2...
                var indices: [ExpressionNode] = []
                var tempIndex = currentIndex + 2

                // 收集所有索引（用冒号分隔）
                while tempIndex < tokens.count {
                    // 从当前tempIndex开始，收集到下一个冒号或等号之前的内容
                    let startIndex = tempIndex
                    var endIndex = startIndex

                    collectLoop: while endIndex < tokens.count {
                        let token = tokens[endIndex]
                        switch token.type {
                        case .colon, .operatorSymbol, .lineBreak:
                            // 遇到冒号、等号或换行，停止收集
                            break collectLoop
                        default:
                            endIndex += 1
                        }
                    }

                    // 提取索引token
                    if endIndex > startIndex {
                        let indexTokens = Array(tokens[startIndex..<endIndex])
                        let parser = ExpressionParser()
                        if let indexExpr = try? parser.parse(indexTokens) {
                            indices.append(indexExpr)
                        }
                    }

                    // 移动到下一个位置
                    tempIndex = endIndex

                    // 检查是否还有冒号（下一个索引）
                    if tempIndex < tokens.count,
                       case .colon = tokens[tempIndex].type {
                        tempIndex += 1  // 跳过冒号，继续下一个索引
                    } else {
                        break  // 没有更多索引
                    }
                }

                // 检查是否以等号结束（赋值）
                if tempIndex < tokens.count,
                   case .operatorSymbol(let op) = tokens[tempIndex].type,
                   op == .assign {

                    currentIndex = tempIndex + 1  // 跳过等号
                    let expr = try parseExpression()

                    return ExpressionStatement(
                        expression: .binary(
                            op: .assign,
                            left: .arrayAccess(base: name, indices: indices),
                            right: expr
                        ),
                        position: startPos
                    )
                }
            }
        }

        // 尝试解析为赋值: variable = expression
        // 也支持 function = expression (因为函数名可能被误识别为函数，如 LIMIT = 5)
        if currentIndex + 2 < tokens.count,
           case .operatorSymbol(let op) = tokens[currentIndex + 1].type,
           op == .assign {

            var varName: String? = nil

            // 检查是否是变量或函数（函数名在赋值上下文中应作为变量处理）
            switch tokens[currentIndex].type {
            case .variable(let name):
                varName = name
            case .function(let name):
                varName = name
            default:
                varName = nil
            }

            if let name = varName {
                currentIndex += 2  // 跳过变量和=

                let expr = try parseExpression()

                return ExpressionStatement(
                    expression: .binary(
                        op: .assign,
                        left: .variable(name),
                        right: expr
                    ),
                    position: startPos
                )
            }
        }

        // 检查是否是标签定义: variable: (后面是换行，不是表达式)
        // 也支持 function: (因为函数名可能被误识别为函数)
        // 只有当 variable: 后面不是有效的表达式/赋值时，才是标签
        if currentIndex + 1 < tokens.count,
           case .colon = tokens[currentIndex + 1].type {

            var varName: String? = nil

            switch tokens[currentIndex].type {
            case .variable(let name):
                varName = name
            case .function(let name):
                varName = name
            default:
                varName = nil
            }

            if let name = varName {
                // 检查冒号后面的内容
                let afterColonIndex = currentIndex + 2
                if afterColonIndex >= tokens.count {
                    // 冒号后没有内容，是标签
                    currentIndex += 2
                    return LabelStatement(name: name, position: startPos)
                }

                // 检查冒号后面是否是换行或空白（标签定义）
                let nextToken = tokens[afterColonIndex]
                switch nextToken.type {
                case .lineBreak, .whitespace, .comment:
                    currentIndex += 2
                    return LabelStatement(name: name, position: startPos)
                default:
                    // 否则是数组访问，但上面的数组检查没匹配，说明格式不对
                    // 继续执行，让后面的表达式解析处理
                    break
                }
            }
        }

        // 检查是否是无冒号标签: variable 后面直接是换行
        // 也支持 function 后面直接是换行
        // 这种情况在Emuera中是合法的标签定义
        if currentIndex < tokens.count {
            var varName: String? = nil

            switch tokens[currentIndex].type {
            case .variable(let name):
                varName = name
            case .function(let name):
                varName = name
            default:
                varName = nil
            }

            if let name = varName {
                // 检查下一个token
                if currentIndex + 1 >= tokens.count {
                    // 文件末尾，是标签
                    currentIndex += 1
                    return LabelStatement(name: name, position: startPos)
                }

                let nextToken = tokens[currentIndex + 1]
                switch nextToken.type {
                case .lineBreak, .whitespace, .comment:
                    // 后面是空白/换行，是标签
                    currentIndex += 1
                    return LabelStatement(name: name, position: startPos)
                default:
                    // 否则是表达式
                    break
                }
            }
        }

        // 否则是表达式语句
        return try parseExpressionStatement()
    }

    /// 解析表达式语句
    private func parseExpressionStatement() throws -> ExpressionStatement {
        let expr = try parseExpression()
        return ExpressionStatement(expression: expr, position: getCurrentPosition())
    }

    // MARK: - 块解析

    /// 解析代码块，直到遇到指定的结束关键字
    /// 这个函数会正确处理嵌套的 IF/WHILE/FOR/SELECTCASE 结构
    private func parseBlock(until endKeywords: [String]) throws -> StatementNode {
        var statements: [StatementNode] = []

        while currentIndex < tokens.count {
            // 跳过空白和换行
            skipWhitespaceAndNewlines()

            if currentIndex >= tokens.count {
                break
            }

            let token = tokens[currentIndex]

            // 首先检查是否是当前块的结束关键字
            // 这些检查必须在 parseStatement 之前，否则会错误地消耗结束标记

            // 检查标准关键字结束符 (ENDIF, ENDWHILE, ENDFOR, ELSE, CASE, CASEELSE, ENDSELECT)
            if case .keyword(let k) = token.type,
               endKeywords.contains(k.uppercased()) {
                break
            }

            // 检查 SELECTCASE 相关结束符 (legacy token types)
            if case .endSelect = token.type,
               endKeywords.contains("ENDSELECT") {
                break
            }
            if case .caseKeyword = token.type,
               endKeywords.contains("CASE") {
                break
            }
            if case .caseElse = token.type,
               endKeywords.contains("CASEELSE") {
                break
            }

            // 如果不是结束符，解析语句
            // parseStatement 会处理嵌套块（IF/WHILE/FOR/SELECTCASE）
            if let statement = try parseStatement() {
                statements.append(statement)
            }
        }

        return BlockStatement(statements: statements, position: getCurrentPosition())
    }

    // MARK: - 表达式解析

    /// 解析表达式
    private func parseExpression() throws -> ExpressionNode {
        // 收集表达式相关的token
        let exprTokens = collectExpressionTokens()
        guard !exprTokens.isEmpty else {
            throw EmueraError.scriptParseError(
                message: "预期表达式",
                position: getCurrentPosition()
            )
        }

        // 使用ExpressionParser解析
        let parser = ExpressionParser()
        let result = try parser.parse(exprTokens)
        return result
    }

    /// 解析可选表达式（可能为空）
    private func parseOptionalExpression() throws -> ExpressionNode? {
        skipWhitespaceAndNewlines()

        // 检查下一个token是否是表达式开始
        guard currentIndex < tokens.count else {
            return nil
        }

        let nextToken = tokens[currentIndex]
        let isExprStart: Bool
        switch nextToken.type {
        case .integer, .string, .variable, .parenthesisOpen:
            isExprStart = true
        default:
            isExprStart = false
        }

        if isExprStart {
            return try parseExpression()
        }

        return nil
    }

    /// 收集表达式相关的token（直到遇到非表达式token）
    private func collectExpressionTokens() -> [TokenType.Token] {
        var exprTokens: [TokenType.Token] = []
        var parenDepth = 0

        while currentIndex < tokens.count {
            let token = tokens[currentIndex]

            switch token.type {
            case .lineBreak:
                // 换行符：如果括号深度为0，表达式结束；否则继续（表达式跨行）
                if parenDepth == 0 {
                    currentIndex += 1
                    return exprTokens
                }
                currentIndex += 1
                continue

            case .whitespace:
                // 空白总是跳过
                currentIndex += 1
                continue

            case .comment:
                currentIndex += 1
                continue

            case .parenthesisOpen:
                parenDepth += 1
                exprTokens.append(token)
                currentIndex += 1

            case .parenthesisClose:
                parenDepth -= 1
                exprTokens.append(token)
                currentIndex += 1

            case .comma:
                // 逗号在参数列表中使用，不在单个表达式中
                if parenDepth == 0 {
                    return exprTokens
                }
                exprTokens.append(token)
                currentIndex += 1

            case .operatorSymbol, .comparator:
                exprTokens.append(token)
                currentIndex += 1

            case .integer, .string, .variable:
                exprTokens.append(token)
                currentIndex += 1

            case .colon:
                // 数组访问中的冒号: A:5
                exprTokens.append(token)
                currentIndex += 1

            case .function:
                // 函数名
                exprTokens.append(token)
                currentIndex += 1

            case .label:
                // 标签（用于函数调用、跳转等）
                exprTokens.append(token)
                currentIndex += 1

            default:
                // 遇到其他token，表达式结束
                return exprTokens
            }

            // 如果括号深度为0且遇到命令或关键字，表达式结束
            if parenDepth == 0 && currentIndex < tokens.count {
                let nextToken = tokens[currentIndex]
                switch nextToken.type {
                case .command, .keyword:
                    return exprTokens
                default:
                    break
                }
            }
        }

        return exprTokens
    }

    // MARK: - PRINT参数解析

    /// 解析PRINT命令的参数（特殊处理：连续变量视为字符串字面量）
    /// PRINTL Start complex test → 输出 "Start complex test"
    /// PRINTL A → 输出变量A的值
    /// PRINTL A + B → 输出 A+B 的计算结果
    /// PRINTL "Hello" → 输出 "Hello"
    private func parsePrintArguments() throws -> [ExpressionNode] {
        skipWhitespaceOnly()  // Only skip whitespace, NOT lineBreaks

        guard currentIndex < tokens.count else {
            return []
        }

        // 检查是否遇到换行（无参数）
        if case .lineBreak = tokens[currentIndex].type {
            return []
        }

        // 检查是否以引号开始（显式字符串）
        if case .string(let value) = tokens[currentIndex].type {
            currentIndex += 1  // 消耗字符串token

            // 检查后面是否还有内容
            if currentIndex < tokens.count {
                let nextToken = tokens[currentIndex]
                if case .lineBreak = nextToken.type {
                    return [.string(value)]
                }

                // 后面还有内容，收集所有token直到行尾
                var text = value
                collectLoop: while currentIndex < tokens.count {
                    let token = tokens[currentIndex]
                    switch token.type {
                    case .lineBreak:
                        currentIndex += 1
                        break collectLoop
                    case .whitespace:
                        currentIndex += 1
                        text += " "
                    case .integer(let i):
                        currentIndex += 1
                        text += String(i)
                    case .string(let s):
                        currentIndex += 1
                        text += s
                    case .variable(let v):
                        currentIndex += 1
                        text += v
                    case .operatorSymbol(let op):
                        currentIndex += 1
                        text += op.rawValue
                    case .comparator(let comp):
                        currentIndex += 1
                        text += comp.rawValue
                    case .command(let cmd):
                        currentIndex += 1
                        text += cmd
                    case .keyword(let kw):
                        currentIndex += 1
                        text += kw
                    case .colon:
                        currentIndex += 1
                        text += ":"
                    case .parenthesisOpen:
                        currentIndex += 1
                        text += "("
                    case .parenthesisClose:
                        currentIndex += 1
                        text += ")"
                    default:
                        currentIndex += 1
                    }
                }
                return [.string(text)]
            }

            return [.string(value)]
        }

        // 检查是否以表达式开始
        let nextToken = tokens[currentIndex]
        let isExprStart: Bool
        switch nextToken.type {
        case .integer, .string, .variable, .parenthesisOpen, .command, .keyword, .operatorSymbol, .comparator, .function:
            isExprStart = true
        default:
            isExprStart = false
        }

        if !isExprStart {
            return []
        }

        // 记录起始位置
        let startIndex = currentIndex

        // 收集所有相关的token直到行结束或遇到命令/关键字
        var exprTokens: [TokenType.Token] = []
        var parenDepth = 0

        tokenLoop: while currentIndex < tokens.count {
            let token = tokens[currentIndex]

            switch token.type {
            case .lineBreak:
                currentIndex += 1
                break tokenLoop

            case .whitespace, .comment:
                currentIndex += 1
                continue tokenLoop

            case .parenthesisOpen:
                parenDepth += 1
                exprTokens.append(token)
                currentIndex += 1

            case .parenthesisClose:
                parenDepth -= 1
                exprTokens.append(token)
                currentIndex += 1

            case .operatorSymbol, .comparator:
                exprTokens.append(token)
                currentIndex += 1
                continue tokenLoop

            case .comma:
                if parenDepth == 0 {
                    currentIndex = startIndex
                    return try parseArguments()
                }
                exprTokens.append(token)
                currentIndex += 1

            case .integer, .string, .variable:
                exprTokens.append(token)
                currentIndex += 1

            case .colon:
                exprTokens.append(token)
                currentIndex += 1

            case .function:
                exprTokens.append(token)
                currentIndex += 1
                continue tokenLoop

            case .command:
                exprTokens.append(token)
                currentIndex += 1
                continue tokenLoop

            case .keyword:
                exprTokens.append(token)
                currentIndex += 1
                continue tokenLoop

            default:
                break tokenLoop
            }
        }

        guard !exprTokens.isEmpty else { return [] }

        // 检查是否包含运算符
        let hasOperator = exprTokens.contains {
            if case .operatorSymbol = $0.type { return true }
            if case .comparator = $0.type { return true }
            return false
        }

        // 检查是否是函数调用
        let isFunctionCall: Bool
        if exprTokens.count >= 2 {
            let first = exprTokens[0]
            let second = exprTokens[1]
            let firstIsCallable = (try? {
                if case .function = first.type { return true }
                if case .variable = first.type { return true }
                if case .command = first.type { return true }
                return false
            }()) ?? false
            let secondIsParenOpen = (try? {
                if case .parenthesisOpen = second.type { return true }
                return false
            }()) ?? false
            isFunctionCall = firstIsCallable && secondIsParenOpen
        } else {
            isFunctionCall = false
        }

        // 检查是否是数组访问 (variable:integer 或 variable:integer:integer)
        let isArrayAccess: Bool
        if exprTokens.count >= 3 {
            let first = exprTokens[0]
            let second = exprTokens[1]
            let firstIsVariable = (try? {
                if case .variable = first.type { return true }
                if case .function = first.type { return true }
                return false
            }()) ?? false
            let secondIsColon = (try? {
                if case .colon = second.type { return true }
                return false
            }()) ?? false
            isArrayAccess = firstIsVariable && secondIsColon
        } else {
            isArrayAccess = false
        }

        // 如果有运算符、函数调用或数组访问，使用ExpressionParser
        if hasOperator || isFunctionCall || isArrayAccess {
            let parser = ExpressionParser()
            do {
                let expr = try parser.parse(exprTokens)
                return [expr]
            } catch {
                // 退回到字符串字面量处理
                let text = exprTokens.map { token -> String in
                    switch token.type {
                    case .variable(let v): return v
                    case .integer(let i): return String(i)
                    case .string(let s): return s
                    case .operatorSymbol(let op): return op.rawValue
                    case .comparator(let comp): return comp.rawValue
                    case .command(let cmd): return cmd
                    case .keyword(let kw): return kw
                    default: return ""
                    }
                }.joined(separator: " ")
                return [.string(text)]
            }
        }

        // 没有运算符的情况
        if exprTokens.count == 1 {
            let token = exprTokens[0]
            switch token.type {
            case .variable(let name):
                return [.variable(name)]
            case .integer(let value):
                return [.integer(value)]
            case .string(let value):
                return [.string(value)]
            case .command(let cmd):
                return [.variable(cmd)]
            case .keyword(let kw):
                return [.variable(kw)]
            case .function(let name):
                // 处理特殊常量 __INT_MAX__, __INT_MIN__
                if name.uppercased() == "__INT_MAX__" {
                    return [.integer(Int64.max)]
                }
                if name.uppercased() == "__INT_MIN__" {
                    return [.integer(Int64.min)]
                }
                // 其他函数作为变量处理
                return [.variable(name)]
            default:
                return []
            }
        }

        // 多个token且没有运算符：视为字符串字面量
        let text = exprTokens.map { token -> String in
            switch token.type {
            case .variable(let v): return v
            case .integer(let i): return String(i)
            case .string(let s): return s
            case .command(let cmd): return cmd
            case .keyword(let kw): return kw
            default: return ""
            }
        }.joined(separator: " ")

        return [.string(text)]
    }

    // MARK: - 参数解析

    /// 解析参数列表（用于命令和函数调用）
    private func parseArguments() throws -> [ExpressionNode] {
        skipWhitespaceAndNewlines()

        // 如果没有参数
        guard currentIndex < tokens.count else {
            return []
        }

        // 检查是否以表达式开始
        let nextToken = tokens[currentIndex]
        let isExprStart: Bool
        switch nextToken.type {
        case .integer, .string, .variable, .parenthesisOpen, .function:
            isExprStart = true
        default:
            isExprStart = false
        }

        if !isExprStart {
            return []
        }

        return try parseArgumentList()
    }

    /// 解析逗号分隔的参数列表
    private func parseArgumentList() throws -> [ExpressionNode] {
        var arguments: [ExpressionNode] = []

        while currentIndex < tokens.count {
            skipWhitespaceAndNewlines()

            // 检查是否结束
            guard currentIndex < tokens.count else { break }

            let token = tokens[currentIndex]

            // 检查是否遇到命令或关键字，如果是则停止解析参数
            switch token.type {
            case .command, .keyword:
                return arguments
            default:
                break
            }

            // 解析单个参数
            let argTokens = collectExpressionTokens()
            if argTokens.isEmpty {
                break
            }

            let parser = ExpressionParser()
            let arg = try parser.parse(argTokens)
            arguments.append(arg)

            // 检查是否有逗号
            skipWhitespaceAndNewlines()
            if currentIndex < tokens.count,
               case .comma = tokens[currentIndex].type {
                currentIndex += 1
            } else {
                break
            }
        }

        return arguments
    }

    // MARK: - 辅助方法

    /// 跳过空白和换行
    private func skipWhitespaceAndNewlines() {
        while currentIndex < tokens.count {
            let token = tokens[currentIndex]
            switch token.type {
            case .whitespace:
                currentIndex += 1
            case .lineBreak:
                currentLine += 1
                currentIndex += 1
            case .comment:
                currentIndex += 1
            default:
                return
            }
        }
    }

    /// 仅跳过空白（不跳过换行）- 用于PRINT参数解析
    private func skipWhitespaceOnly() {
        while currentIndex < tokens.count {
            let token = tokens[currentIndex]
            if case .whitespace = token.type {
                currentIndex += 1
            } else {
                return
            }
        }
    }

    /// 获取当前位置
    private func getCurrentPosition() -> ScriptPosition {
        if currentIndex < tokens.count,
           let pos = tokens[currentIndex].position {
            return pos
        }
        return ScriptPosition(filename: "script", lineNumber: currentLine)
    }

    // MARK: - Phase 2: 函数系统解析

    /// 解析指令语句 (#DIM, #FUNCTIONS, #INCLUDE等)
    private func parseDirectiveStatement(_ directive: String) throws -> StatementNode? {
        let upperDirective = directive.uppercased()
        let startPos = getCurrentPosition()

        currentIndex += 1  // 跳过指令

        switch upperDirective {
        case "#DIM", "#DIMS":
            // 解析: #DIM LCOUNT 或 #DIMS MEMOS, 10
            return try parseVariableDeclaration(type: upperDirective == "#DIM" ? .integer : .string)

        case "#FUNCTION", "#FUNCTIONS":
            // 这些应该在函数定义头部，单独出现时标记当前函数的返回类型
            // 但实际解析在parseFunctionDefinition中处理
            // 这里只是消耗token
            skipWhitespaceAndNewlines()
            return nil

        case "#INCLUDE":
            // 解析: #INCLUDE "header.erh"
            return try parseIncludeStatement()

        case "#DEFINE":
            // 解析: #DEFINE MAX_HP 1000 或 #DEFINE DAMAGE(x) (x * 2)
            return try parseDefineStatement()

        case "#GLOBAL":
            // 解析: #GLOBAL MY_VAR 或 #GLOBAL MY_ARRAY, 100
            return try parseGlobalStatement()

        default:
            // 未知指令，跳过
            return nil
        }
    }

    /// 解析 #INCLUDE 指令
    private func parseIncludeStatement() throws -> IncludeStatement {
        let startPos = getCurrentPosition()

        // 跳过空白
        skipWhitespaceAndNewlines()

        // 期望一个字符串字面量（文件路径）
        guard currentIndex < tokens.count,
              case .string(let path) = tokens[currentIndex].type else {
            throw EmueraError.scriptParseError(
                message: "#INCLUDE需要带引号的文件路径",
                position: getCurrentPosition()
            )
        }

        currentIndex += 1  // 跳过字符串

        return IncludeStatement(path: path, position: startPos)
    }

    /// 解析 #DEFINE 指令
    private func parseDefineStatement() throws -> DefineMacroStatement {
        let startPos = getCurrentPosition()

        // 跳过空白
        skipWhitespaceAndNewlines()

        // 读取宏名称
        guard currentIndex < tokens.count,
              case .variable(let name) = tokens[currentIndex].type else {
            throw EmueraError.scriptParseError(
                message: "#DEFINE需要宏名称",
                position: getCurrentPosition()
            )
        }

        currentIndex += 1

        // 检查是否有参数（函数式宏）
        skipWhitespaceAndNewlines()
        var parameters: [String] = []

        if currentIndex < tokens.count,
           case .parenthesisOpen = tokens[currentIndex].type {
            currentIndex += 1  // 跳过 (

            // 解析参数列表
            while currentIndex < tokens.count {
                skipWhitespaceAndNewlines()

                if case .parenthesisClose = tokens[currentIndex].type {
                    currentIndex += 1
                    break
                }

                if case .variable(let paramName) = tokens[currentIndex].type {
                    parameters.append(paramName)
                    currentIndex += 1
                }

                skipWhitespaceAndNewlines()

                if case .comma = tokens[currentIndex].type {
                    currentIndex += 1
                }
            }
        }

        // 读取宏体（剩余部分直到行尾）
        skipWhitespaceAndNewlines()
        var bodyParts: [String] = []

        while currentIndex < tokens.count {
            let token = tokens[currentIndex]
            switch token.type {
            case .lineBreak:
                currentIndex += 1
                break
            case .whitespace:
                currentIndex += 1
                bodyParts.append(" ")
            case .integer(let value):
                currentIndex += 1
                bodyParts.append(String(value))
            case .string(let value):
                currentIndex += 1
                bodyParts.append("\"\(value)\"")
            case .variable(let value), .function(let value), .command(let value), .keyword(let value):
                currentIndex += 1
                bodyParts.append(value)
            case .operatorSymbol(let op):
                currentIndex += 1
                bodyParts.append(op.rawValue)
            case .comparator(let comp):
                currentIndex += 1
                bodyParts.append(comp.rawValue)
            case .comma:
                currentIndex += 1
                bodyParts.append(",")
            case .colon:
                currentIndex += 1
                bodyParts.append(":")
            case .parenthesisOpen:
                currentIndex += 1
                bodyParts.append("(")
            case .parenthesisClose:
                currentIndex += 1
                bodyParts.append(")")
            default:
                currentIndex += 1
            }
        }

        let body = bodyParts.joined()

        return DefineMacroStatement(name: name, body: body, parameters: parameters, position: startPos)
    }

    /// 解析 #GLOBAL 指令
    private func parseGlobalStatement() throws -> GlobalVariableStatement {
        let startPos = getCurrentPosition()

        // 跳过空白
        skipWhitespaceAndNewlines()

        // 读取变量名
        guard currentIndex < tokens.count,
              case .variable(let name) = tokens[currentIndex].type else {
            throw EmueraError.scriptParseError(
                message: "#GLOBAL需要变量名称",
                position: getCurrentPosition()
            )
        }

        currentIndex += 1

        // 检查是否有数组大小
        skipWhitespaceAndNewlines()
        var isArray = false
        var size: ExpressionNode? = nil

        if currentIndex < tokens.count,
           case .comma = tokens[currentIndex].type {
            currentIndex += 1  // 跳过逗号
            isArray = true

            // 解析数组大小表达式
            size = try parseExpression()
        }

        return GlobalVariableStatement(name: name, isArray: isArray, size: size, position: startPos)
    }

    /// 解析变量声明 (#DIM, #DIMS)
    private func parseVariableDeclaration(type: VariableType) throws -> VariableDeclarationStatement {
        let startPos = getCurrentPosition()

        // 获取变量名
        skipWhitespaceAndNewlines()
        guard currentIndex < tokens.count,
              case .variable(let name) = tokens[currentIndex].type else {
            throw EmueraError.scriptParseError(
                message: "变量声明需要变量名",
                position: getCurrentPosition()
            )
        }
        currentIndex += 1

        // 检查是否有数组大小
        var isArray = false
        var size: ExpressionNode? = nil

        skipWhitespaceAndNewlines()
        if currentIndex < tokens.count,
           case .comma = tokens[currentIndex].type {
            currentIndex += 1  // 跳过逗号
            skipWhitespaceAndNewlines()

            // 解析数组大小
            size = try parseExpression()
            isArray = true
        }

        return VariableDeclarationStatement(
            scope: .local,  // #DIM声明的是局部变量
            name: name,
            isArray: isArray,
            size: size,
            initialValue: nil,
            position: startPos
        )
    }

    /// 解析函数定义 (@函数名, 参数)
    private func parseFunctionDefinition() throws -> FunctionDefinitionStatement {
        let startPos = getCurrentPosition()
        let debugStartIndex = currentIndex

        // 获取函数名
        guard currentIndex < tokens.count,
              case .label(let name) = tokens[currentIndex].type else {
            throw EmueraError.scriptParseError(
                message: "函数定义需要以@开头",
                position: getCurrentPosition()
            )
        }

        let funcName = String(name.dropFirst())  // 移除@前缀
        currentIndex += 1

        // 解析参数列表
        var parameters: [FunctionParameter] = []
        var directives: [FunctionDirective] = []

        // 检查是否有参数
        if currentIndex < tokens.count,
           case .comma = tokens[currentIndex].type {
            currentIndex += 1  // 跳过逗号

            // 解析参数列表
            while currentIndex < tokens.count {
                skipWhitespaceAndNewlines()

                // 检查是否结束（遇到换行或指令）
                if currentIndex >= tokens.count {
                    break
                }
                if case .lineBreak = tokens[currentIndex].type {
                    break
                }
                if case .directive = tokens[currentIndex].type {
                    break
                }

                // 解析单个参数
                if case .variable(let paramName) = tokens[currentIndex].type {
                    currentIndex += 1

                    // 检查是否有数组标记 (:)
                    var isArray = false
                    if currentIndex < tokens.count,
                       case .colon = tokens[currentIndex].type {
                        isArray = true
                        currentIndex += 1
                    }

                    parameters.append(FunctionParameter(
                        name: paramName,
                        type: .integer,  // 默认整数
                        isArray: isArray
                    ))
                }

                // 检查是否有逗号
                skipWhitespaceAndNewlines()
                if currentIndex < tokens.count,
                   case .comma = tokens[currentIndex].type {
                    currentIndex += 1
                } else {
                    break
                }
            }
        }

        // 跳过到函数体开始（换行）
        skipWhitespaceAndNewlines()

        // 收集函数体直到遇到下一个函数定义或文件结束
        var body: [StatementNode] = []
        var functionDepth = 1

        while currentIndex < tokens.count {
            // 检查是否是新的函数定义
            if case .label(let nextName) = tokens[currentIndex].type,
               nextName.hasPrefix("@") {
                break
            }

            // 检查是否是函数指令（#FUNCTION等）
            if case .directive(let dir) = tokens[currentIndex].type {
                let upperDir = dir.uppercased()
                if upperDir == "#FUNCTION" || upperDir == "#FUNCTIONS" {
                    directives.append(upperDir == "#FUNCTION" ? .function : .functions)
                    currentIndex += 1
                    skipWhitespaceAndNewlines()
                    continue
                }
                if upperDir == "#DIM" || upperDir == "#DIMS" {
                    if let stmt = try parseDirectiveStatement(dir) as? VariableDeclarationStatement {
                        // 将局部变量声明转换为函数指令
                        directives.append(.dim(
                            name: stmt.name,
                            type: stmt.scope.variableType,
                            isArray: stmt.isArray,
                            size: stmt.size
                        ))
                    }
                    continue
                }
            }

            // 解析函数体语句
            if let stmt = try parseStatement() {
                body.append(stmt)
            } else {
                // parseStatement() already handled incrementing currentIndex for unknown tokens
            }
        }

        // 创建函数定义
        let definition = FunctionDefinition(
            name: funcName,
            parameters: parameters,
            directives: directives,
            body: body,
            position: startPos
        )

        // 注册函数
        functionDefinitions[funcName] = definition

        // 返回函数定义语句（用于后续注册到执行器）
        return FunctionDefinitionStatement(definition: definition, position: startPos)
    }

    // MARK: - TRY/CATCH异常处理解析 (Phase 3)

    /// 解析TRY/CATCH异常处理语句
    /// TRY
    ///   statements
    /// CATCH
    ///   statements
    /// ENDTRY
    private func parseTryCatchStatement() throws -> TryCatchStatement {
        let startPos = getCurrentPosition()

        // 跳过TRY
        currentIndex += 1

        // 解析TRY块
        let tryBlock = try parseBlock(until: ["CATCH", "ENDTRY"])

        var catchBlock: StatementNode? = nil
        var catchLabel: String? = nil

        // 检查是否有CATCH
        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "CATCH" {
            currentIndex += 1  // 跳过CATCH

            // 检查CATCH后面是否有标签名（可选）
            skipWhitespaceAndNewlines()
            if currentIndex < tokens.count,
               case .label(let name) = tokens[currentIndex].type {
                catchLabel = name  // 保留@前缀
                currentIndex += 1
            }

            // 解析CATCH块
            catchBlock = try parseBlock(until: ["ENDTRY"])
        }

        // 消耗ENDTRY
        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "ENDTRY" {
            currentIndex += 1
        } else {
            throw EmueraError.scriptParseError(
                message: "TRY语句缺少ENDTRY",
                position: getCurrentPosition()
            )
        }

        return TryCatchStatement(
            tryBlock: tryBlock,
            catchBlock: catchBlock,
            catchLabel: catchLabel,
            position: startPos
        )
    }

    /// 解析TRYJUMP语句
    /// TRYJUMP target, arg1, arg2... CATCH label
    private func parseTryJumpStatement() throws -> TryJumpStatement {
        let startPos = getCurrentPosition()

        // 跳过TRYJUMP
        currentIndex += 1

        // 解析参数列表
        let arguments = try parseArgumentList()

        // 检查是否有CATCH标签
        var catchLabel: String? = nil
        skipWhitespaceAndNewlines()

        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "CATCH" {
            currentIndex += 1  // 跳过CATCH

            // 获取标签名
            skipWhitespaceAndNewlines()
            if currentIndex < tokens.count,
               case .label(let name) = tokens[currentIndex].type {
                catchLabel = name  // 保留@前缀
                currentIndex += 1
            } else if currentIndex < tokens.count,
                      case .variable(let name) = tokens[currentIndex].type {
                catchLabel = name
                currentIndex += 1
            }
        }

        // 提取目标和参数
        guard !arguments.isEmpty else {
            throw EmueraError.scriptParseError(
                message: "TRYJUMP需要目标参数",
                position: getCurrentPosition()
            )
        }

        // 第一个参数是目标
        let targetExpr = arguments[0]
        let target: String

        if case .variable(let name) = targetExpr {
            target = name
        } else if case .string(let name) = targetExpr {
            target = name
        } else {
            throw EmueraError.scriptParseError(
                message: "TRYJUMP目标必须是变量或字符串",
                position: getCurrentPosition()
            )
        }

        // 剩余参数
        let remainingArgs = Array(arguments.dropFirst())

        return TryJumpStatement(
            target: target,
            arguments: remainingArgs,
            catchLabel: catchLabel,
            position: startPos
        )
    }

    /// 解析TRYGOTO语句
    /// TRYGOTO label CATCH label
    private func parseTryGotoStatement() throws -> TryGotoStatement {
        let startPos = getCurrentPosition()

        // 跳过TRYGOTO
        currentIndex += 1

        // 跳过空白
        skipWhitespaceAndNewlines()

        // 获取目标标签
        guard currentIndex < tokens.count else {
            throw EmueraError.scriptParseError(
                message: "TRYGOTO需要标签名",
                position: getCurrentPosition()
            )
        }

        let label: String
        switch tokens[currentIndex].type {
        case .label(let name):
            label = name  // 保留@前缀
            currentIndex += 1
        case .variable(let name):
            label = name
            currentIndex += 1
        default:
            throw EmueraError.scriptParseError(
                message: "TRYGOTO后需要标签名",
                position: getCurrentPosition()
            )
        }

        // 检查是否有CATCH标签
        var catchLabel: String? = nil
        skipWhitespaceAndNewlines()

        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "CATCH" {
            currentIndex += 1  // 跳过CATCH

            // 获取标签名
            skipWhitespaceAndNewlines()
            if currentIndex < tokens.count,
               case .label(let name) = tokens[currentIndex].type {
                catchLabel = name  // 保留@前缀
                currentIndex += 1
            } else if currentIndex < tokens.count,
                      case .variable(let name) = tokens[currentIndex].type {
                catchLabel = name
                currentIndex += 1
            }
        }

        return TryGotoStatement(
            label: label,
            catchLabel: catchLabel,
            position: startPos
        )
    }

    // MARK: - SELECTCASE语句解析 (Phase 3)

    /// 解析SELECTCASE多分支选择语句
    /// SELECTCASE A
    ///     CASE 1
    ///         PRINT "One"
    ///     CASE 2 TO 5
    ///         PRINT "Two to Five"
    ///     CASEELSE
    ///         PRINT "Other"
    /// ENDSELECT
    private func parseSelectCaseStatement() throws -> SelectCaseStatement {
        let startPos = getCurrentPosition()

        // 跳过SELECTCASE
        currentIndex += 1

        // 解析测试表达式
        let testExpression = try parseExpression()

        // 准备收集CASE子句
        var cases: [CaseClause] = []
        var defaultCase: StatementNode? = nil

        // 循环解析CASE子句
        while currentIndex < tokens.count {
            skipWhitespaceAndNewlines()

            if currentIndex >= tokens.count {
                break
            }

            let token = tokens[currentIndex]

            // 检查是否是ENDSELECT结束
            if case .keyword(let k) = token.type, k.uppercased() == "ENDSELECT" {
                currentIndex += 1
                break
            }

            // 检查是否是CASE
            if case .keyword(let k) = token.type, k.uppercased() == "CASE" {
                currentIndex += 1  // 跳过CASE

                // 解析CASE的值列表
                let values = try parseCaseValues()

                // 解析CASE块
                let body = try parseBlock(until: ["CASE", "CASEELSE", "ENDSELECT"])

                cases.append(CaseClause(values: values, body: body))
                continue
            }

            // 检查是否是CASEELSE
            if case .keyword(let k) = token.type, k.uppercased() == "CASEELSE" {
                currentIndex += 1  // 跳过CASEELSE

                // 解析默认块
                defaultCase = try parseBlock(until: ["ENDSELECT"])
                continue
            }

            // 未知token，跳过
            currentIndex += 1
        }

        return SelectCaseStatement(
            test: testExpression,
            cases: cases,
            defaultCase: defaultCase,
            position: startPos
        )
    }

    /// 解析CASE的值列表
    /// 支持格式:
    /// - CASE 1
    /// - CASE 1, 2, 3
    /// - CASE 2 TO 5
    /// - CASE "A", "B"
    private func parseCaseValues() throws -> [ExpressionNode] {
        var values: [ExpressionNode] = []
        var hasMore = true

        while hasMore && currentIndex < tokens.count {
            skipWhitespaceAndNewlines()

            if currentIndex >= tokens.count {
                break
            }

            // 检查是否是结束关键字
            let token = tokens[currentIndex]
            if case .keyword(let k) = token.type {
                let upper = k.uppercased()
                if upper == "CASE" || upper == "CASEELSE" || upper == "ENDSELECT" {
                    break
                }
            }

            // 收集当前值的token（直到逗号或换行）
            var exprTokens: [TokenType.Token] = []
            var foundTO = false
            var toIndex = -1

            while currentIndex < tokens.count {
                let t = tokens[currentIndex]

                // 检查是否应该停止收集
                switch t.type {
                case .comma:
                    // 逗号：继续收集下一个值
                    currentIndex += 1
                    hasMore = true
                    break
                case .lineBreak:
                    // 换行：结束当前CASE的值列表
                    currentIndex += 1
                    hasMore = false
                    break
                case .keyword(let k):
                    let upper = k.uppercased()
                    if upper == "CASE" || upper == "CASEELSE" || upper == "ENDSELECT" {
                        // 遇到下一个CASE关键字，结束
                        hasMore = false
                        break
                    } else if upper == "TO" {
                        // TO用于范围
                        foundTO = true
                        toIndex = exprTokens.count
                        exprTokens.append(t)
                        currentIndex += 1
                        continue
                    } else {
                        // 其他关键字，作为表达式的一部分
                        exprTokens.append(t)
                        currentIndex += 1
                    }
                case .whitespace:
                    currentIndex += 1
                    continue
                case .comment:
                    currentIndex += 1
                    continue
                default:
                    exprTokens.append(t)
                    currentIndex += 1
                    continue
                }

                // 如果遇到逗号、换行或CASE关键字，停止收集当前值
                switch t.type {
                case .comma, .lineBreak:
                    break
                case .keyword(let k):
                    let upper = k.uppercased()
                    if upper == "CASE" || upper == "CASEELSE" || upper == "ENDSELECT" {
                        break
                    }
                default:
                    continue
                }
                break
            }

            if exprTokens.isEmpty {
                continue
            }

            // 处理TO范围或普通表达式
            if foundTO && toIndex >= 0 {
                let leftTokens = Array(exprTokens[0..<toIndex])
                let rightTokens = Array(exprTokens[(toIndex + 1)...])

                if !leftTokens.isEmpty && !rightTokens.isEmpty {
                    let parser = ExpressionParser()
                    let leftExpr = try parser.parse(leftTokens)
                    let rightExpr = try parser.parse(rightTokens)

                    let rangeExpr = ExpressionNode.functionCall(
                        name: "__RANGE__",
                        arguments: [leftExpr, rightExpr]
                    )
                    values.append(rangeExpr)
                }
            } else {
                let parser = ExpressionParser()
                let expr = try parser.parse(exprTokens)
                values.append(expr)
            }
        }

        return values
    }

    // MARK: - DO-LOOP语句解析 (Phase 3)

    /// 解析DO-LOOP循环语句
    /// DO
    ///     statements
    /// LOOP [WHILE condition | UNTIL condition]
    private func parseDoLoopStatement() throws -> DoLoopStatement {
        let startPos = getCurrentPosition()

        // 跳过DO
        currentIndex += 1

        // 解析循环体
        let body = try parseBlock(until: ["LOOP"])

        // 检查LOOP关键字
        guard currentIndex < tokens.count,
              case .keyword(let k) = tokens[currentIndex].type,
              k.uppercased() == "LOOP" else {
            throw EmueraError.scriptParseError(
                message: "DO语句缺少LOOP",
                position: getCurrentPosition()
            )
        }

        currentIndex += 1  // 跳过LOOP

        // 检查是否有WHILE或UNTIL条件
        skipWhitespaceAndNewlines()

        var condition: ExpressionNode? = nil
        var isWhile: Bool? = nil

        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type {
            let upper = k.uppercased()
            if upper == "WHILE" || upper == "UNTIL" {
                currentIndex += 1  // 跳过WHILE/UNTIL
                condition = try parseExpression()
                isWhile = (upper == "WHILE")
            }
        }

        return DoLoopStatement(
            body: body,
            condition: condition,
            isWhile: isWhile,
            position: startPos
        )
    }

    // MARK: - REPEAT语句解析 (Phase 3)

    /// 解析REPEAT循环语句
    /// REPEAT count
    ///     statements (COUNT available)
    /// ENDREPEAT
    private func parseRepeatStatement() throws -> RepeatStatement {
        let startPos = getCurrentPosition()

        // 跳过REPEAT
        currentIndex += 1

        // 解析循环次数
        let count = try parseExpression()

        // 解析循环体
        let body = try parseBlock(until: ["ENDREPEAT"])

        // 消耗ENDREPEAT
        if currentIndex < tokens.count,
           case .keyword(let k) = tokens[currentIndex].type,
           k.uppercased() == "ENDREPEAT" {
            currentIndex += 1
        } else {
            throw EmueraError.scriptParseError(
                message: "REPEAT语句缺少ENDREPEAT",
                position: getCurrentPosition()
            )
        }

        return RepeatStatement(
            count: count,
            body: body,
            position: startPos
        )
    }

    // MARK: - PRINTDATA/DATALIST语句解析 (Phase 3)

    /// 解析PRINTDATA语句
    /// PRINTDATA
    ///     DATALIST
    ///         PRINT "text1"
    ///     ENDLIST
    ///     DATALIST
    ///         PRINT "text2"
    ///     ENDLIST
    /// ENDDATA
    private func parsePrintDataStatement() throws -> PrintDataStatement {
        let startPos = getCurrentPosition()

        // 跳过PRINTDATA
        currentIndex += 1

        // 准备收集DATALIST子句
        var dataLists: [DataListClause] = []

        // 循环解析DATALIST子句
        while currentIndex < tokens.count {
            skipWhitespaceAndNewlines()

            if currentIndex >= tokens.count {
                break
            }

            let token = tokens[currentIndex]

            // 检查是否是ENDDATA结束
            if case .keyword(let k) = token.type, k.uppercased() == "ENDDATA" {
                currentIndex += 1
                break
            }

            // 检查是否是DATALIST
            if case .keyword(let k) = token.type, k.uppercased() == "DATALIST" {
                currentIndex += 1  // 跳过DATALIST

                // 解析DATALIST块
                let body = try parseBlock(until: ["ENDLIST"])

                // 消耗ENDLIST
                if currentIndex < tokens.count,
                   case .keyword(let k) = tokens[currentIndex].type,
                   k.uppercased() == "ENDLIST" {
                    currentIndex += 1
                } else {
                    throw EmueraError.scriptParseError(
                        message: "DATALIST缺少ENDLIST",
                        position: getCurrentPosition()
                    )
                }

                dataLists.append(DataListClause(body: body))
                continue
            }

            // 未知token，跳过
            currentIndex += 1
        }

        return PrintDataStatement(
            dataLists: dataLists,
            position: startPos
        )
    }

    // MARK: - 辅助方法

    /// 获取指定索引之后的token数组
    private func getTokensAfter(_ index: Int) -> [TokenType.Token]? {
        guard index < tokens.count else { return nil }
        return Array(tokens[index...])
    }

    /// 判断token序列是否是函数定义的开始
    /// 函数定义特征: 以 #DIM, #FUNCTION, RETURN, RETURNF, 变量赋值等开始
    /// 标签定义特征: 以 PRINT, IF, WHILE, FOR, GOTO, CALL, TRYGOTO 等语句开始
    private func isFunctionDefinitionStart(_ remainingTokens: [TokenType.Token]) -> Bool {
        guard let firstToken = remainingTokens.first else { return false }

        // 跳过空白和换行
        var index = 0
        while index < remainingTokens.count {
            let token = remainingTokens[index]
            switch token.type {
            case .whitespace, .lineBreak, .comment:
                index += 1
                continue
            default:
                break
            }
            break
        }

        guard index < remainingTokens.count else { return false }
        let firstNonWhitespace = remainingTokens[index]

        // 检查是否是函数相关的指令或语句
        switch firstNonWhitespace.type {
        case .directive(let dir):
            // #DIM, #FUNCTION 等指令
            let upper = dir.uppercased()
            return upper.hasPrefix("#DIM") || upper.hasPrefix("#FUNCTION") || upper == "#FUNCTIONS"

        case .keyword(let keyword):
            let upper = keyword.uppercased()
            // 函数中常见的返回语句
            if upper == "RETURN" || upper == "RETURNF" || upper == "RESTART" {
                return true
            }
            // Phase 3: 明确的标签起始关键字（总是标签，不是函数定义）
            let labelStartKeywords: Set<String> = [
                "IF", "WHILE", "FOR", "REPEAT", "DO",
                "SELECTCASE", "PRINTDATA",
                "TRY", "BREAK", "CONTINUE"
            ]
            if labelStartKeywords.contains(upper) {
                return false
            }
            return false

        case .variable:
            // 变量赋值: VAR = value
            // 检查下一个token是否是赋值操作符
            if index + 1 < remainingTokens.count {
                let nextToken = remainingTokens[index + 1]
                if case .operatorSymbol(let op) = nextToken.type, op == .assign {
                    // 变量赋值后，继续查找是否有标签起始关键字或函数返回语句
                    // 例如: A = 10\nPRINTDATA → 是标签，不是函数 (返回 false)
                    // 例如: A = 10\nRETURN → 是函数 (返回 true)
                    for i in (index + 2)..<remainingTokens.count {
                        let t = remainingTokens[i]
                        switch t.type {
                        case .whitespace, .comment, .lineBreak:
                            continue
                        case .keyword(let k):
                            let upper = k.uppercased()
                            // 标签起始关键字 - 说明是标签定义
                            let labelStartKeywords: Set<String> = [
                                "IF", "WHILE", "FOR", "REPEAT", "DO",
                                "SELECTCASE", "PRINTDATA",
                                "TRY", "BREAK", "CONTINUE",
                                "PRINT", "PRINTL", "PRINTW", "PRINTFORM", "PRINTFORML", "PRINTFORMW",
                                "INPUT", "INPUTS", "WAIT", "WAITANYKEY",
                                "GOTO", "CALL", "TRYCALL", "TRYGOTO", "TRYJUMP",
                                "DRAWLINE", "BAR", "BARL",
                                "QUIT", "RESET", "PERSIST",
                                "DEBUGPRINT", "DEBUGPRINTL",
                                "THROW", "ASSERT"
                            ]
                            if labelStartKeywords.contains(upper) {
                                return false  // 是标签，不是函数
                            }
                            // 函数返回语句 - 说明是函数
                            if upper == "RETURN" || upper == "RETURNF" || upper == "RESTART" {
                                return true  // 是函数
                            }
                            // 其他关键字（如 ENDLIST, ENDDATA, ENDIF 等），继续查找
                            continue
                        case .directive(let d):
                            let upper = d.uppercased()
                            if upper.hasPrefix("#DIM") || upper.hasPrefix("#FUNCTION") || upper == "#FUNCTIONS" {
                                return true  // 是函数
                            }
                            continue  // 其他指令，继续查找
                        case .command(let c):
                            let upper = c.uppercased()
                            // 命令列表
                            let commandsAlwaysLabel: Set<String> = [
                                "PRINT", "PRINTL", "PRINTW", "PRINTFORM", "PRINTFORML", "PRINTFORMW",
                                "INPUT", "INPUTS", "WAIT", "WAITANYKEY",
                                "GOTO", "CALL", "TRYCALL", "TRYGOTO", "TRYJUMP",
                                "DRAWLINE", "BAR", "BARL",
                                "QUIT", "RESET", "PERSIST",
                                "DEBUGPRINT", "DEBUGPRINTL",
                                "THROW", "ASSERT"
                            ]
                            if commandsAlwaysLabel.contains(upper) {
                                return false  // 标签起始命令
                            }
                            continue  // 其他命令，继续查找
                        default:
                            // 其他 token，不能确定，保守返回 false（作为标签处理）
                            return false
                        }
                    }
                    // 没有找到明确的标签起始或函数起始，可能是纯赋值后结束
                    return false
                }
            }
            return false

        case .command(let cmd):
            // 检查命令类型
            let upper = cmd.uppercased()

            // 明确的标签起始命令（总是标签）
            let labelStartCommands: Set<String> = [
                "PRINT", "PRINTL", "PRINTW", "PRINTC", "PRINTLC",
                "PRINTFORM", "PRINTFORML", "PRINTFORMW",
                "INPUT", "INPUTS", "WAIT", "WAITANYKEY",
                "IF", "WHILE", "FOR", "REPEAT",
                "GOTO", "CALL", "TRYCALL", "TRYGOTO", "TRYJUMP",
                "TRY", "BREAK", "CONTINUE",
                "DRAWLINE", "BAR", "BARL",
                "QUIT", "RESET", "PERSIST",
                "DEBUGPRINT", "DEBUGPRINTL",
                "THROW", "ASSERT"
            ]

            // 模糊命令：需要看后续内容来判断是标签还是函数
            let ambiguousCommands: Set<String> = [
                "PRINT", "PRINTL", "PRINTW", "PRINTFORM", "PRINTFORML", "PRINTFORMW"
            ]

            if ambiguousCommands.contains(upper) {
                // PRINTL "text" 后面跟 RETURN 是函数定义，跟其他命令是标签
                // 简化逻辑：查找 RETURN 关键字
                for token in remainingTokens.dropFirst() {  // Skip PRINTL itself
                    switch token.type {
                    case .keyword(let k):
                        let kUpper = k.uppercased()
                        if kUpper == "RETURN" || kUpper == "RETURNF" || kUpper == "RESTART" {
                            return true
                        }
                        // 遇到其他关键字（如PRINTL、GOTO等）说明是标签
                        if kUpper == "PRINTL" || kUpper == "PRINT" || kUpper == "GOTO" ||
                           kUpper == "CALL" || kUpper == "IF" || kUpper == "WHILE" ||
                           kUpper == "FOR" || kUpper == "TRY" || kUpper == "TRYGOTO" {
                            return false
                        }
                    case .directive:
                        return true
                    case .command(let c):
                        // 遇到命令说明是标签
                        let cUpper = c.uppercased()
                        if cUpper == "PRINTL" || cUpper == "PRINT" || cUpper == "GOTO" ||
                           cUpper == "CALL" || cUpper == "INPUT" || cUpper == "WAIT" {
                            return false
                        }
                    case .lineBreak:
                        continue
                    case .whitespace, .comment:
                        continue
                    default:
                        continue
                    }
                }
                return false
            }

            // 明确的标签起始命令
            if labelStartCommands.contains(upper) {
                return false
            }

            // 其他命令（如变量赋值、函数调用等）可能是函数定义
            return true

        default:
            return false
        }
    }

    // MARK: - SAVE/LOAD数据持久化解析 (Phase 3 P1)

    /// 解析SAVEDATA/LOADDATA/DELDATA命令
    /// 注意：currentIndex已指向命令之后的第一个token
    private func parseSaveLoadCommand(_ cmd: String) throws -> StatementNode {
        let startPos = getCurrentPosition()

        // 解析参数列表
        let arguments = try parseArgumentList()

        guard !arguments.isEmpty else {
            throw EmueraError.scriptParseError(
                message: "\(cmd)需要文件名参数",
                position: getCurrentPosition()
            )
        }

        // 第一个参数是文件名
        let filename = arguments[0]

        // 剩余参数是要保存/加载的变量列表
        let variables = Array(arguments.dropFirst())

        // 根据命令返回对应的语句
        switch cmd {
        case "SAVEDATA":
            return SaveDataStatement(filename: filename, variables: variables, position: startPos)
        case "LOADDATA":
            return LoadDataStatement(filename: filename, variables: variables, position: startPos)
        case "DELDATA":
            if !variables.isEmpty {
                throw EmueraError.scriptParseError(
                    message: "DELDATA只接受文件名参数",
                    position: getCurrentPosition()
                )
            }
            return DelDataStatement(filename: filename, position: startPos)
        default:
            throw EmueraError.scriptParseError(
                message: "未知的SAVE/LOAD命令: \(cmd)",
                position: getCurrentPosition()
            )
        }
    }

    /// 解析SAVEVAR/LOADVAR命令
    private func parseSaveVarCommand(_ cmd: String) throws -> StatementNode {
        let startPos = getCurrentPosition()

        // 解析参数列表
        let arguments = try parseArgumentList()

        guard arguments.count >= 2 else {
            throw EmueraError.scriptParseError(
                message: "\(cmd)需要文件名和至少一个变量",
                position: getCurrentPosition()
            )
        }

        // 第一个参数是文件名
        let filename = arguments[0]

        // 剩余参数是要保存/加载的变量
        let variables = Array(arguments.dropFirst())

        // 根据命令返回对应的语句
        switch cmd {
        case "SAVEVAR":
            return SaveDataStatement(filename: filename, variables: variables, position: startPos)
        case "LOADVAR":
            return LoadDataStatement(filename: filename, variables: variables, position: startPos)
        default:
            throw EmueraError.scriptParseError(
                message: "未知的SAVE/LOAD命令: \(cmd)",
                position: getCurrentPosition()
            )
        }
    }

    /// 解析SAVECHARA/LOADCHARA命令
    /// SAVECHARA filename, charaIndex
    /// LOADCHARA filename, charaIndex
    private func parseSaveCharaCommand(_ cmd: String) throws -> StatementNode {
        let startPos = getCurrentPosition()

        // 解析参数列表
        let arguments = try parseArgumentList()

        guard arguments.count >= 2 else {
            throw EmueraError.scriptParseError(
                message: "\(cmd)需要文件名和角色索引参数",
                position: getCurrentPosition()
            )
        }

        // 第一个参数是文件名
        let filename = arguments[0]
        // 第二个参数是角色索引
        let charaIndex = arguments[1]

        // 根据命令返回对应的语句
        switch cmd {
        case "SAVECHARA":
            return SaveCharaStatement(filename: filename, charaIndex: charaIndex, position: startPos)
        case "LOADCHARA":
            return LoadCharaStatement(filename: filename, charaIndex: charaIndex, position: startPos)
        default:
            throw EmueraError.scriptParseError(
                message: "未知的SAVE/LOAD命令: \(cmd)",
                position: getCurrentPosition()
            )
        }
    }

    /// 解析SAVEGAME/LOADGAME命令
    /// SAVEGAME filename
    /// LOADGAME filename
    private func parseSaveGameCommand(_ cmd: String) throws -> StatementNode {
        let startPos = getCurrentPosition()

        // 解析参数列表
        let arguments = try parseArgumentList()

        guard arguments.count >= 1 else {
            throw EmueraError.scriptParseError(
                message: "\(cmd)需要存档文件名参数",
                position: getCurrentPosition()
            )
        }

        // 第一个参数是文件名
        let filename = arguments[0]

        // 根据命令返回对应的语句
        switch cmd {
        case "SAVEGAME":
            return SaveGameStatement(filename: filename, position: startPos)
        case "LOADGAME":
            return LoadGameStatement(filename: filename, position: startPos)
        default:
            throw EmueraError.scriptParseError(
                message: "未知的SAVE/LOAD命令: \(cmd)",
                position: getCurrentPosition()
            )
        }
    }

    /// 解析SAVELIST命令 - 列出所有存档文件
    /// SAVELIST
    private func parseSaveListCommand() throws -> StatementNode {
        let startPos = getCurrentPosition()
        currentIndex += 1  // 跳过SAVELIST
        // SAVELIST没有参数，直接返回语句
        return SaveListStatement(position: startPos)
    }

    /// 解析SAVEEXISTS命令 - 检查存档是否存在
    /// SAVEEXISTS filename
    private func parseSaveExistsCommand() throws -> StatementNode {
        let startPos = getCurrentPosition()
        currentIndex += 1  // 跳过SAVEEXISTS

        // 解析文件名参数
        let arguments = try parseArguments()
        guard arguments.count == 1 else {
            throw EmueraError.scriptParseError(
                message: "SAVEEXISTS需要一个文件名参数",
                position: getCurrentPosition()
            )
        }

        let filename = arguments[0]
        return SaveExistsStatement(filename: filename, position: startPos)
    }

    /// 解析AUTOSAVE命令 - 自动保存游戏状态
    /// AUTOSAVE filename
    private func parseAutoSaveCommand() throws -> StatementNode {
        let startPos = getCurrentPosition()
        currentIndex += 1  // 跳过AUTOSAVE

        // 解析文件名参数
        let arguments = try parseArguments()
        guard arguments.count == 1 else {
            throw EmueraError.scriptParseError(
                message: "AUTOSAVE需要一个文件名参数",
                position: getCurrentPosition()
            )
        }

        let filename = arguments[0]
        return AutoSaveStatement(filename: filename, position: startPos)
    }

    /// 解析SAVEINFO命令 - 显示存档详细信息
    /// SAVEINFO filename
    private func parseSaveInfoCommand() throws -> StatementNode {
        let startPos = getCurrentPosition()
        currentIndex += 1  // 跳过SAVEINFO

        // 解析文件名参数
        let arguments = try parseArguments()
        guard arguments.count == 1 else {
            throw EmueraError.scriptParseError(
                message: "SAVEINFO需要一个文件名参数",
                position: getCurrentPosition()
            )
        }

        let filename = arguments[0]
        return SaveInfoStatement(filename: filename, position: startPos)
    }

    /// 解析RESETDATA命令 - 重置所有变量
    /// RESETDATA
    private func parseResetDataCommand() throws -> StatementNode {
        let startPos = getCurrentPosition()
        currentIndex += 1  // 跳过RESETDATA
        return ResetDataStatement(position: startPos)
    }

    /// 解析RESETGLOBAL命令 - 重置全局变量数组
    /// RESETGLOBAL
    private func parseResetGlobalCommand() throws -> StatementNode {
        let startPos = getCurrentPosition()
        currentIndex += 1  // 跳过RESETGLOBAL
        return ResetGlobalStatement(position: startPos)
    }

    /// 解析PERSIST命令 - 持久化状态控制
    /// PERSIST [option]
    /// PERSIST ON/OFF
    /// 注意：currentIndex已指向命令之后的第一个token
    private func parsePersistCommand() throws -> StatementNode {
        let startPos = getCurrentPosition()

        // 检查是否有参数
        if currentIndex >= tokens.count {
            // 无参数：默认开启持久化
            return PersistEnhancedStatement(enabled: true, option: nil, position: startPos)
        }

        // 检查下一个token是否是变量（ON/OFF或其他选项）
        let nextToken = tokens[currentIndex]

        if case .variable(let value) = nextToken.type {
            currentIndex += 1
            let option = ExpressionNode.variable(value)

            // 判断是ON还是OFF
            let upperValue = value.uppercased()
            if upperValue == "ON" || upperValue == "1" || upperValue == "TRUE" {
                return PersistEnhancedStatement(enabled: true, option: option, position: startPos)
            } else if upperValue == "OFF" || upperValue == "0" || upperValue == "FALSE" {
                return PersistEnhancedStatement(enabled: false, option: option, position: startPos)
            } else {
                // 其他选项参数
                return PersistEnhancedStatement(enabled: true, option: option, position: startPos)
            }
        }

        // 默认开启
        return PersistEnhancedStatement(enabled: true, option: nil, position: startPos)
    }
}
