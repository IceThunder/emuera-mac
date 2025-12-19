//
//  StatementExecutor.swift
//  EmueraCore
//
//  语句执行器 - 执行解析后的语句AST
//  支持控制流、变量操作和命令执行
//  Created: 2025-12-19
//

import Foundation

// MARK: - 执行上下文

/// 执行上下文
public class ExecutionContext {
    public var variables: [String: VariableValue]
    public var output: [String]
    public var shouldQuit: Bool
    public var lastResult: VariableValue
    public var shouldBreak: Bool
    public var shouldContinue: Bool
    public var returnValue: VariableValue?
    public var callStack: [String]
    public var labels: [String: Int]
    public var persistEnabled: Bool

    public init() {
        variables = [:]
        output = []
        shouldQuit = false
        lastResult = .null
        shouldBreak = false
        shouldContinue = false
        returnValue = nil
        callStack = []
        labels = [:]
        persistEnabled = false
    }

    public func copy() -> ExecutionContext {
        let newContext = ExecutionContext()
        newContext.variables = variables
        newContext.output = []
        newContext.lastResult = lastResult
        newContext.callStack = callStack
        newContext.labels = labels
        newContext.persistEnabled = persistEnabled
        return newContext
    }

    public func getVariable(_ name: String) -> VariableValue {
        return variables[name] ?? .integer(0)
    }

    public func setVariable(_ name: String, value: VariableValue) {
        variables[name] = value
        lastResult = value
    }
}

// MARK: - 语句执行器

public class StatementExecutor: StatementVisitor {
    private var context: ExecutionContext
    private var statements: [StatementNode] = []
    private var currentStatementIndex: Int = 0

    public init() {
        self.context = ExecutionContext()
    }

    public func execute(_ statements: [StatementNode], context: ExecutionContext? = nil) -> [String] {
        if let ctx = context {
            self.context = ctx
        } else {
            self.context = ExecutionContext()
        }

        self.statements = statements
        self.currentStatementIndex = 0

        collectLabels()

        while currentStatementIndex < statements.count {
            let statement = statements[currentStatementIndex]

            do {
                try statement.accept(visitor: self)

                if self.context.shouldQuit {
                    break
                }

                if self.context.shouldBreak {
                    self.context.shouldBreak = false
                    break
                }

                if self.context.shouldContinue {
                    self.context.shouldContinue = false
                }

                currentStatementIndex += 1

            } catch {
                self.context.output.append("Error: \(error)")
                break
            }
        }

        return self.context.output
    }

    // MARK: - StatementVisitor 协议实现

    public func visitExpressionStatement(_ statement: ExpressionStatement) throws {
        let result = try evaluateExpression(statement.expression)
        context.lastResult = result

        if case .null = result {
            // 不输出
        } else {
            if statement.expression.nodeType == "binary" {
                // 赋值语句不输出
            } else {
                context.output.append(result.description)
            }
        }
    }

    public func visitBlockStatement(_ statement: BlockStatement) throws {
        for stmt in statement.statements {
            try stmt.accept(visitor: self)

            if context.shouldQuit || context.shouldBreak || context.shouldContinue {
                return
            }

            if context.returnValue != nil {
                return
            }
        }
    }

    public func visitIfStatement(_ statement: IfStatement) throws {
        let condition = try evaluateExpression(statement.condition)
        let conditionResult = toBool(condition)

        if conditionResult {
            try statement.thenBlock.accept(visitor: self)
        } else if let elseBlock = statement.elseBlock {
            try elseBlock.accept(visitor: self)
        }
    }

    public func visitWhileStatement(_ statement: WhileStatement) throws {
        while true {
            let condition = try evaluateExpression(statement.condition)
            let conditionResult = toBool(condition)

            if !conditionResult {
                break
            }

            try statement.body.accept(visitor: self)

            if context.shouldBreak {
                context.shouldBreak = false
                break
            }

            if context.shouldContinue {
                context.shouldContinue = false
                continue
            }

            if context.returnValue != nil {
                break
            }

            if context.shouldQuit {
                break
            }
        }
    }

    public func visitForStatement(_ statement: ForStatement) throws {
        let start = try evaluateExpression(statement.start)
        let end = try evaluateExpression(statement.end)
        let stepValue = try statement.step.map { try evaluateExpression($0) } ?? .integer(1)

        guard case .integer(let startVal) = start,
              case .integer(let endVal) = end,
              case .integer(let stepVal) = stepValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        let step = stepVal
        let direction = step > 0 ? 1 : -1

        var current = startVal
        while (direction > 0 && current <= endVal) || (direction < 0 && current >= endVal) {
            context.setVariable(statement.variable, value: .integer(current))

            try statement.body.accept(visitor: self)

            if context.shouldBreak {
                context.shouldBreak = false
                break
            }

            if context.shouldContinue {
                context.shouldContinue = false
            }

            if context.returnValue != nil {
                break
            }

            if context.shouldQuit {
                break
            }

            current += step
        }
    }

    public func visitSelectCaseStatement(_ statement: SelectCaseStatement) throws {
        let testValue = try evaluateExpression(statement.test)

        for caseClause in statement.cases {
            for valueExpr in caseClause.values {
                let caseValue = try evaluateExpression(valueExpr)
                if valuesEqual(testValue, caseValue) {
                    try caseClause.body.accept(visitor: self)
                    return
                }
            }
        }

        if let defaultCase = statement.defaultCase {
            try defaultCase.accept(visitor: self)
        }
    }

    public func visitGotoStatement(_ statement: GotoStatement) throws {
        if let targetIndex = context.labels[statement.label] {
            currentStatementIndex = targetIndex
        } else {
            throw EmueraError.runtimeError(
                message: "标签未找到: \(statement.label)",
                position: statement.position
            )
        }
    }

    public func visitCallStatement(_ statement: CallStatement) throws {
        if let targetIndex = context.labels[statement.target] {
            context.callStack.append("\(currentStatementIndex)")
            currentStatementIndex = targetIndex

            while currentStatementIndex < statements.count {
                let stmt = statements[currentStatementIndex]
                try stmt.accept(visitor: self)

                if context.returnValue != nil {
                    // Get return address before removing from stack
                    let returnAddress = context.callStack.removeLast()
                    if let callerIndex = Int(returnAddress) {
                        currentStatementIndex = callerIndex
                    }
                    return
                }

                if context.shouldQuit {
                    context.callStack.removeLast()
                    return
                }

                currentStatementIndex += 1
            }

            context.callStack.removeLast()
        } else {
            throw EmueraError.functionNotFound(name: statement.target)
        }
    }

    public func visitReturnStatement(_ statement: ReturnStatement) throws {
        if let value = statement.value {
            context.returnValue = try evaluateExpression(value)
        } else {
            context.returnValue = .null
        }

        if let callerIndexStr = context.callStack.last,
           let callerIndex = Int(callerIndexStr) {
            currentStatementIndex = callerIndex + 1
        }
    }

    public func visitBreakStatement(_ statement: BreakStatement) throws {
        context.shouldBreak = true
    }

    public func visitContinueStatement(_ statement: ContinueStatement) throws {
        context.shouldContinue = true
    }

    public func visitLabelStatement(_ statement: LabelStatement) throws {
        // 标签在预处理阶段已收集
    }

    public func visitCommandStatement(_ statement: CommandStatement) throws {
        let cmdType = CommandType.fromString(statement.command)

        switch cmdType {
        case .PRINT:
            let value = try evaluateArguments(statement.arguments)
            context.output.append(value)

        case .PRINTL:
            let value = try evaluateArguments(statement.arguments)
            context.output.append(value + "\n")

        case .PRINTW:
            let value = try evaluateArguments(statement.arguments)
            context.output.append(value)
            context.output.append("按回车继续...\n")

        case .PRINTFORM:
            let value = try evaluateArguments(statement.arguments)
            context.output.append(value)

        case .PRINTFORML:
            let value = try evaluateArguments(statement.arguments)
            context.output.append(value + "\n")

        case .PRINTFORMW:
            let value = try evaluateArguments(statement.arguments)
            context.output.append(value)
            context.output.append("按回车继续...\n")

        case .INPUT:
            context.output.append("[等待输入: 整数]\n")
            context.setVariable("RESULT", value: .integer(0))

        case .INPUTS:
            context.output.append("[等待输入: 字符串]\n")
            context.setVariable("RESULTS", value: .string(""))

        case .WAIT, .WAITANYKEY:
            context.output.append("按回车继续...\n")

        case .ONEINPUT:
            context.output.append("[单键输入]\n")
            context.setVariable("RESULT", value: .integer(0))

        case .ONEINPUTS:
            context.output.append("[单键字符串输入]\n")
            context.setVariable("RESULTS", value: .string(""))

        case .CLEARLINE:
            context.output.append("[清除行]\n")

        case .REUSELASTLINE:
            context.output.append("[重用最后一行]\n")

        case .QUIT:
            context.output.append("程序已退出\n")
            context.shouldQuit = true

        case .RESET:
            context.variables.removeAll()
            context.lastResult = .null
            context.output.append("[变量已重置]\n")

        case .PERSIST:
            context.output.append("[持久状态: \(context.persistEnabled ? "ON" : "OFF")]\n")

        case .DRAWLINE:
            context.output.append(String(repeating: "-", count: 60) + "\n")

        case .CUSTOMDRAWLINE:
            let value = try evaluateArguments(statement.arguments)
            let lineChar = value.isEmpty ? "-" : value
            context.output.append(String(repeating: lineChar, count: 60) + "\n")

        case .DRAWLINEFORM:
            let value = try evaluateArguments(statement.arguments)
            context.output.append(value + "\n")

        case .BAR:
            if statement.arguments.count >= 3 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .integer(let val) = args[0],
                   case .integer(let max) = args[1],
                   case .integer(let len) = args[2] {
                    let ratio = max > 0 ? Double(val) / Double(max) : 0
                    let filled = Int(ratio * Double(len))
                    let bar = String(repeating: "*", count: filled) + String(repeating: ".", count: Int(len) - filled)
                    context.output.append("[\(bar)]\n")
                }
            }

        case .BARL:
            if statement.arguments.count >= 3 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .integer(let val) = args[0],
                   case .integer(let max) = args[1],
                   case .integer(let len) = args[2] {
                    let ratio = max > 0 ? Double(val) / Double(max) : 0
                    let filled = Int(ratio * Double(len))
                    let bar = String(repeating: "*", count: filled) + String(repeating: ".", count: Int(len) - filled)
                    context.output.append("[\(bar)]\n")
                }
            }

        case .SETCOLOR, .RESETCOLOR, .SETBGCOLOR, .RESETBGCOLOR:
            context.output.append("[颜色设置: \(statement.command)]\n")

        case .FONTBOLD, .FONTITALIC, .FONTREGULAR, .SETFONT:
            context.output.append("[字体设置: \(statement.command)]\n")

        case .DEBUGPRINT:
            let value = try evaluateArguments(statement.arguments)
            context.output.append("[DEBUG] \(value)")

        case .DEBUGPRINTL:
            let value = try evaluateArguments(statement.arguments)
            context.output.append("[DEBUG] \(value)\n")

        case .DEBUGCLEAR:
            context.output.append("[DEBUG CLEAR]\n")

        case .ASSERT:
            if statement.arguments.count >= 1 {
                let result = try evaluateExpression(statement.arguments[0])
                if case .integer(0) = result {
                    throw EmueraError.runtimeError(message: "断言失败", position: statement.position)
                }
            }

        case .THROW:
            let value = try evaluateArguments(statement.arguments)
            throw EmueraError.runtimeError(message: "抛出异常: \(value)", position: nil)

        case .SKIPDISP:
            context.output.append("[跳过显示]\n")

        case .NOSKIP:
            context.output.append("[禁止跳过]\n")

        case .ENDNOSKIP:
            context.output.append("[结束禁止跳过]\n")

        case .REDRAW:
            context.output.append("[重绘]\n")

        case .ALIGNMENT:
            context.output.append("[对齐设置]\n")

        case .CLEARTEXTBOX:
            context.output.append("[清空文本框]\n")

        case .TIMES:
            if statement.arguments.count >= 2 {
                context.output.append("[TIMES计算]\n")
            }

        case .POWER:
            if statement.arguments.count >= 3 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .integer(let base) = args[1],
                   case .integer(let exp) = args[2] {
                    let result = Int64(pow(Double(base), Double(exp)))
                    if case .variable(let varName) = statement.arguments[0] {
                        context.setVariable(varName, value: .integer(result))
                    }
                }
            }

        case .RANDOMIZE:
            context.output.append("[随机种子设置]\n")

        case .DUMPRAND:
            context.output.append("[转储随机状态]\n")

        case .INITRAND:
            context.output.append("[初始化随机]\n")

        case .GETTIME:
            let time = Date().timeIntervalSince1970
            context.setVariable("RESULT", value: .integer(Int64(time)))
            context.output.append("[时间: \(Int64(time))]\n")

        case .PRINT_ABL, .PRINT_TALENT, .PRINT_MARK, .PRINT_EXP, .PRINT_PALAM, .PRINT_ITEM:
            let value = try evaluateArguments(statement.arguments)
            context.output.append("[数据: \(value)]\n")

        case .UNKNOWN:
            context.output.append("[未知命令: \(statement.command)]\n")

        default:
            let value = try evaluateArguments(statement.arguments)
            if !value.isEmpty {
                context.output.append("[命令: \(statement.command) 参数: \(value)]\n")
            } else {
                context.output.append("[命令: \(statement.command)]\n")
            }
        }
    }

    public func visitResetStatement(_ statement: ResetStatement) throws {
        context.variables.removeAll()
        context.lastResult = .null
    }

    public func visitPersistStatement(_ statement: PersistStatement) throws {
        context.persistEnabled = statement.enabled
        context.output.append("[持久状态: \(statement.enabled ? "ON" : "OFF")]\n")
    }

    // MARK: - 表达式求值

    private func evaluateExpression(_ expr: ExpressionNode) throws -> VariableValue {
        switch expr {
        case .integer(let value):
            return .integer(value)

        case .string(let value):
            return .string(value)

        case .variable(let name):
            if context.variables[name] == nil {
                if name.contains(where: { $0.unicodeScalars.contains(where: { $0.value > 127 }) }) {
                    return .string(name)
                }
            }
            return context.getVariable(name)

        case .arrayAccess:
            return .integer(0)

        case .functionCall(let name, let arguments):
            return try evaluateFunctionCall(name: name, arguments: arguments)

        case .binary(let op, let left, let right):
            return try evaluateBinary(op: op, left: left, right: right)
        }
    }

    private func evaluateFunctionCall(name: String, arguments: [ExpressionNode]) throws -> VariableValue {
        let evaluatedArgs = try arguments.map { try evaluateExpression($0) }
        return try BuiltInFunctions.execute(
            name: name,
            arguments: evaluatedArgs,
            context: context
        )
    }

    private func evaluateBinary(op: TokenType.Operator, left: ExpressionNode, right: ExpressionNode) throws -> VariableValue {
        let leftVal = try evaluateExpression(left)
        let rightVal = try evaluateExpression(right)

        switch op {
        case .assign:
            if case .variable(let name) = left {
                context.setVariable(name, value: rightVal)
                return rightVal
            }
            throw EmueraError.invalidOperation(message: "赋值左侧必须是变量")

        case .add:
            return try addValues(leftVal, rightVal)
        case .subtract:
            return try subtractValues(leftVal, rightVal)
        case .multiply:
            return try multiplyValues(leftVal, rightVal)
        case .divide:
            return try divideValues(leftVal, rightVal)
        case .modulo:
            return try moduloValues(leftVal, rightVal)
        case .power:
            return try powerValues(leftVal, rightVal)

        case .equal:
            return .integer(valuesEqual(leftVal, rightVal) ? 1 : 0)
        case .notEqual:
            return .integer(valuesEqual(leftVal, rightVal) ? 0 : 1)
        case .less:
            return .integer(try compareValues(leftVal, rightVal) < 0 ? 1 : 0)
        case .lessEqual:
            return .integer(try compareValues(leftVal, rightVal) <= 0 ? 1 : 0)
        case .greater:
            return .integer(try compareValues(leftVal, rightVal) > 0 ? 1 : 0)
        case .greaterEqual:
            return .integer(try compareValues(leftVal, rightVal) >= 0 ? 1 : 0)

        case .and:
            return .integer((toBool(leftVal) && toBool(rightVal)) ? 1 : 0)
        case .or:
            return .integer((toBool(leftVal) || toBool(rightVal)) ? 1 : 0)

        case .bitAnd:
            return try bitAndValues(leftVal, rightVal)
        case .bitOr:
            return try bitOrValues(leftVal, rightVal)
        case .bitXor:
            return try bitXorValues(leftVal, rightVal)
        case .shiftLeft:
            return try shiftLeftValues(leftVal, rightVal)
        case .shiftRight:
            return try shiftRightValues(leftVal, rightVal)

        default:
            throw EmueraError.invalidOperation(message: "不支持的运算符: \(op.rawValue)")
        }
    }

    // MARK: - 值操作辅助方法

    private func addValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        switch (left, right) {
        case (.integer(let l), .integer(let r)):
            return .integer(l + r)
        case (.string(let l), .string(let r)):
            return .string(l + r)
        case (.integer(let l), .string(let r)):
            return .string("\(l)\(r)")
        case (.string(let l), .integer(let r)):
            return .string("\(l)\(r)")
        default:
            throw EmueraError.typeMismatch(expected: "number or string", actual: "other")
        }
    }

    private func subtractValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        return .integer(l - r)
    }

    private func multiplyValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        return .integer(l * r)
    }

    private func divideValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        if r == 0 {
            throw EmueraError.divisionByZero
        }
        return .integer(l / r)
    }

    private func moduloValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        if r == 0 {
            throw EmueraError.divisionByZero
        }
        return .integer(l % r)
    }

    private func powerValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        return .integer(Int64(pow(Double(l), Double(r))))
    }

    private func bitAndValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        return .integer(l & r)
    }

    private func bitOrValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        return .integer(l | r)
    }

    private func bitXorValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        return .integer(l ^ r)
    }

    private func shiftLeftValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        return .integer(l << r)
    }

    private func shiftRightValues(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        return .integer(l >> r)
    }

    private func valuesEqual(_ left: VariableValue, _ right: VariableValue) -> Bool {
        switch (left, right) {
        case (.integer(let l), .integer(let r)): return l == r
        case (.string(let l), .string(let r)): return l == r
        case (.null, .null): return true
        default: return false
        }
    }

    private func compareValues(_ left: VariableValue, _ right: VariableValue) throws -> Int {
        switch (left, right) {
        case (.integer(let l), .integer(let r)):
            if l < r { return -1 }
            if l > r { return 1 }
            return 0
        case (.string(let l), .string(let r)):
            return l.compare(r).rawValue
        default:
            throw EmueraError.typeMismatch(expected: "comparable", actual: "other")
        }
    }

    private func toBool(_ value: VariableValue) -> Bool {
        switch value {
        case .integer(let v): return v != 0
        case .string(let s): return !s.isEmpty
        case .array(let arr): return !arr.isEmpty
        case .character: return true
        case .null: return false
        }
    }

    private func evaluateArguments(_ arguments: [ExpressionNode]) throws -> String {
        if arguments.isEmpty {
            return ""
        }

        var result = ""
        for arg in arguments {
            let value = try evaluateExpression(arg)
            result += value.description
        }
        return result
    }

    // MARK: - 标签收集

    private func collectLabels() {
        for (index, statement) in statements.enumerated() {
            if let labelStmt = statement as? LabelStatement {
                context.labels[labelStmt.name] = index
            }
        }
    }
}
