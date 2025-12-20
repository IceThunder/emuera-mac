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
        case .command(let cmd):
            return try parseCommandStatement(cmd)

        case .variable:
            return try parseAssignmentOrExpression()

        case .keyword(let keyword):
            return try parseKeywordStatement(keyword)

        case .label:
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
        print("DEBUG: parseCommandStatement called with cmd='\(cmd)'")
        let upperCmd = cmd.uppercased()
        let startPos = getCurrentPosition()

        currentIndex += 1  // 跳过命令token
        print("DEBUG: After skipping command, currentIndex=\(currentIndex)")

        switch upperCmd {
        case "PRINT", "PRINTL", "PRINTW":
            print("DEBUG: PRINT family, calling parsePrintArguments()")
            let args = try parsePrintArguments()
            print("DEBUG: parsePrintArguments returned \(args.count) args")
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

        case "PERSIST":
            return try parsePersistStatement()

        default:
            // 其他命令，作为通用命令处理
            let args = try parseArguments()
            return CommandStatement(command: cmd, arguments: args, position: startPos)
        }
    }

    /// 解析PERSIST ON/OFF
    private func parsePersistStatement() throws -> PersistStatement {
        let startPos = getCurrentPosition()

        // 跳过PERSIST
        currentIndex += 1

        // 跳过空白
        skipWhitespaceAndNewlines()

        // 检查下一个token是否为变量名（ON/OFF）
        guard currentIndex < tokens.count,
              case .variable(let value) = tokens[currentIndex].type else {
            throw EmueraError.scriptParseError(
                message: "PERSIST后需要ON或OFF",
                position: getCurrentPosition()
            )
        }

        let upperValue = value.uppercased()
        let enabled = (upperValue == "ON" || upperValue == "TRUE")

        currentIndex += 1

        return PersistStatement(enabled: enabled, position: startPos)
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

        case "SELECTCASE":
            return try parseSelectCaseStatement()

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

        case "CALL":
            return try parseCallStatement()

        case "GOTO":
            return try parseGotoStatement()

        case "ELSE", "ENDIF", "ENDWHILE", "ENDFOR", "ENDSELECT":
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

    /// 解析SELECTCASE语句
    /// SELECTCASE test
    ///   CASE value1[, value2, ...]
    ///     statements
    ///   CASE value3
    ///     statements
    ///   CASEELSE
    ///     statements
    /// ENDSELECT
    private func parseSelectCaseStatement() throws -> SelectCaseStatement {
        let startPos = getCurrentPosition()

        // 跳过SELECTCASE
        currentIndex += 1

        // 解析测试表达式
        let test = try parseExpression()

        var cases: [CaseClause] = []
        var defaultCase: StatementNode? = nil

        // 解析CASE子句
        while currentIndex < tokens.count {
            skipWhitespaceAndNewlines()

            guard currentIndex < tokens.count else { break }

            let token = tokens[currentIndex]

            if case .keyword(let k) = token.type {
                let upperK = k.uppercased()

                if upperK == "CASE" {
                    currentIndex += 1
                    let values = try parseArgumentList()
                    let body = try parseBlock(until: ["CASE", "CASEELSE", "ENDSELECT"])
                    cases.append(CaseClause(values: values, body: body))

                } else if upperK == "CASEELSE" {
                    currentIndex += 1
                    defaultCase = try parseBlock(until: ["ENDSELECT"])

                } else if upperK == "ENDSELECT" {
                    currentIndex += 1
                    break

                } else {
                    break
                }
            } else {
                break
            }
        }

        return SelectCaseStatement(
            test: test,
            cases: cases,
            defaultCase: defaultCase,
            position: startPos
        )
    }

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

    /// 解析CALL语句
    private func parseCallStatement() throws -> CallStatement {
        let startPos = getCurrentPosition()

        // 跳过CALL
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

        var target: String

        if case .variable(let name) = tokens[currentIndex].type {
            target = name
            currentIndex += 1
        } else if case .label(let name) = tokens[currentIndex].type {
            target = name
            currentIndex += 1
        } else {
            throw EmueraError.scriptParseError(
                message: "CALL后需要函数名或标签名",
                position: getCurrentPosition()
            )
        }

        // 解析参数（可选）
        let args = try parseArguments()

        return CallStatement(target: target, arguments: args, position: startPos)
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

        // 检查是否是标签定义: variable:
        if currentIndex + 1 < tokens.count,
           case .variable(let varName) = tokens[currentIndex].type,
           case .colon = tokens[currentIndex + 1].type {

            currentIndex += 2  // 跳过变量和冒号
            return LabelStatement(name: varName, position: startPos)
        }

        // 尝试解析为赋值: variable = expression
        if currentIndex + 2 < tokens.count,
           case .variable(let varName) = tokens[currentIndex].type,
           case .operatorSymbol(let op) = tokens[currentIndex + 1].type,
           op == .assign {

            currentIndex += 2  // 跳过变量和=

            let expr = try parseExpression()

            return ExpressionStatement(
                expression: .binary(
                    op: .assign,
                    left: .variable(varName),
                    right: expr
                ),
                position: startPos
            )
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
    private func parseBlock(until endKeywords: [String]) throws -> StatementNode {
        var statements: [StatementNode] = []

        while currentIndex < tokens.count {
            // 跳过空白和换行（在检查前）
            skipWhitespaceAndNewlines()

            if currentIndex >= tokens.count {
                break
            }

            // 检查是否遇到结束关键字
            if case .keyword(let k) = tokens[currentIndex].type,
               endKeywords.contains(k.uppercased()) {
                break
            }

            // 检查是否遇到其他块结束关键字（防止越界）
            if case .keyword(let k) = tokens[currentIndex].type {
                let upperK = k.uppercased()
                if ["ENDIF", "ENDWHILE", "ENDFOR", "ENDSELECT", "ELSE", "CASE", "CASEELSE"].contains(upperK) {
                    break
                }
            }

            // 解析语句
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
        return try parser.parse(exprTokens)
    }

    /// 解析可选表达式（可能为空）
    private func parseOptionalExpression() throws -> ExpressionNode? {
        skipWhitespaceAndNewlines()

        // 检查下一个token是否是表达式开始
        guard currentIndex < tokens.count else { return nil }

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
        print("DEBUG: parsePrintArguments() called, currentIndex=\(currentIndex)")
        skipWhitespaceOnly()  // Only skip whitespace, NOT lineBreaks
        print("DEBUG: After skipWhitespaceOnly, currentIndex=\(currentIndex)")

        guard currentIndex < tokens.count else {
            print("DEBUG: No tokens, returning []")
            return []
        }

        // 检查是否遇到换行（无参数）
        if case .lineBreak = tokens[currentIndex].type {
            print("DEBUG: LineBreak found, returning []")
            return []
        }

        // 检查是否以引号开始（显式字符串）
        if case .string = tokens[currentIndex].type {
            print("DEBUG: Starts with string, calling parseArguments()")
            return try parseArguments()
        }

        // 检查是否以表达式开始（变量、数字、括号、命令/关键字作为文本）
        let nextToken = tokens[currentIndex]
        let isExprStart: Bool
        switch nextToken.type {
        case .integer, .variable, .parenthesisOpen, .command, .keyword:
            isExprStart = true
        default:
            isExprStart = false
        }

        if !isExprStart {
            print("DEBUG: Not expression start, returning []")
            return []
        }

        // 记录起始位置
        let startIndex = currentIndex
        print("DEBUG: startIndex=\(startIndex)")

        // 收集所有相关的token直到行结束或遇到命令/关键字
        var exprTokens: [TokenType.Token] = []
        var parenDepth = 0

        tokenLoop: while currentIndex < tokens.count {
            let token = tokens[currentIndex]

            switch token.type {
            case .lineBreak:
                // 换行结束
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
                // 如果有运算符，说明是表达式，需要完整解析
                exprTokens.append(token)
                currentIndex += 1
                // 继续收集直到行结束
                continue tokenLoop

            case .comma:
                // 逗号分隔的参数
                if parenDepth == 0 {
                    // 有逗号说明是多个参数，使用正常解析
                    // 重置到起始位置并使用标准解析
                    currentIndex = startIndex
                    print("DEBUG: Found comma, calling parseArguments()")
                    return try parseArguments()
                }
                exprTokens.append(token)
                currentIndex += 1

            case .integer, .string, .variable:
                exprTokens.append(token)
                currentIndex += 1

            case .colon:
                // 数组访问
                exprTokens.append(token)
                currentIndex += 1

            case .function:
                exprTokens.append(token)
                currentIndex += 1

            case .command:
                // 在PRINT参数中，command token可能是文本的一部分（如"Loop test:"中的Loop）
                // 只有当这是第一个token且不是起始位置时，才作为文本处理
                // 否则，如果遇到真正的下一个命令（在不同行），会由lineBreak处理
                exprTokens.append(token)
                currentIndex += 1
                continue tokenLoop

            case .keyword:
                // 在PRINT参数中，关键字也可能是文本的一部分
                // 例如: "Loop test:" 中的 Loop 可能被识别为关键字
                exprTokens.append(token)
                currentIndex += 1
                continue tokenLoop

            default:
                // 其他token，结束收集
                break tokenLoop
            }
        }

        // 分析收集到的token
        print("DEBUG: Collected \(exprTokens.count) tokens: \(exprTokens)")
        guard !exprTokens.isEmpty else { return [] }

        // 检查是否包含运算符（如果有，说明是表达式，使用ExpressionParser）
        let hasOperator = exprTokens.contains {
            if case .operatorSymbol = $0.type { return true }
            if case .comparator = $0.type { return true }
            return false
        }

        print("DEBUG: hasOperator=\(hasOperator)")

        if hasOperator {
            // 是表达式，使用ExpressionParser
            print("DEBUG: Calling ExpressionParser for operators")
            let parser = ExpressionParser()
            do {
                let expr = try parser.parse(exprTokens)
                return [expr]
            } catch {
                // ExpressionParser失败，说明这不是有效的表达式
                // 例如: "C greater than 15 is true!" 中的 ! 被误判为运算符
                // 退回到字符串字面量处理
                print("DEBUG: ExpressionParser failed, falling back to string literal")
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
        // 如果只有一个token，直接返回它（可能是变量或整数）
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
                // 单个command token作为变量处理（可能是文本）
                return [.variable(cmd)]
            case .keyword(let kw):
                // 单个keyword token作为变量处理（可能是文本）
                return [.variable(kw)]
            default:
                return []
            }
        }

        // 多个token且没有运算符：视为字符串字面量
        // 例如: PRINTL Start complex test → "Start complex test"
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

        print("DEBUG: Returning string literal: '\(text)'")
        return [.string(text)]
    }

    // MARK: - 参数解析

    /// 解析参数列表（用于命令和函数调用）
    private func parseArguments() throws -> [ExpressionNode] {
        skipWhitespaceAndNewlines()

        // 如果没有参数
        guard currentIndex < tokens.count else { return [] }

        // 检查是否以表达式开始
        let nextToken = tokens[currentIndex]
        let isExprStart: Bool
        switch nextToken.type {
        case .integer, .string, .variable, .parenthesisOpen:
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
}
