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

    // Phase 3: 异常处理相关
    public var currentCatchLabel: String?  // 当前CATCH标签
    public var shouldCatch: Bool           // 是否应该捕获异常

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
        currentCatchLabel = nil
        shouldCatch = false
    }

    public func copy() -> ExecutionContext {
        let newContext = ExecutionContext()
        newContext.variables = variables
        newContext.output = []
        newContext.lastResult = lastResult
        newContext.callStack = callStack
        newContext.labels = labels
        newContext.persistEnabled = persistEnabled
        newContext.currentCatchLabel = currentCatchLabel
        newContext.shouldCatch = shouldCatch
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
        collectFunctions()  // Phase 2: 收集函数定义

        while currentStatementIndex < statements.count {
            let statement = statements[currentStatementIndex]

            do {
                try statement.accept(visitor: self)

                if self.context.shouldQuit {
                    break
                }

                // BREAK and CONTINUE are handled by loop statements (WHILE, FOR, REPEAT)
                // SELECTCASE doesn't propagate them, so they remain set
                // Clear them here to prevent issues with subsequent statements
                if self.context.shouldBreak {
                    self.context.shouldBreak = false
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

    /// Debug: Get the current context after execution (for debugging labels/functions)
    public func getContext() -> ExecutionContext {
        return self.context
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
        var executed = false

        for caseClause in statement.cases {
            for valueExpr in caseClause.values {
                let caseValue = try evaluateExpression(valueExpr)
                if valuesEqual(testValue, caseValue) {
                    try caseClause.body.accept(visitor: self)
                    executed = true
                    break
                }
            }
            if executed { break }
        }

        if !executed, let defaultCase = statement.defaultCase {
            try defaultCase.accept(visitor: self)
        }

        // BREAK inside SELECTCASE should exit the SELECTCASE
        // The flag remains set so outer loops can handle it
        // CONTINUE also remains set for outer loops
        // SELECTCASE itself doesn't consume these flags
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
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTFORM:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTFORML:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTFORMW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
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
            // 重置所有变量为默认值（整数为0，字符串为空）
            for key in context.variables.keys {
                if case .string = context.variables[key] {
                    context.variables[key] = .string("")
                } else {
                    context.variables[key] = .integer(0)
                }
            }
            context.lastResult = .null
            context.output.append("[变量已重置]\n")

        case .PERSIST:
            context.output.append("[持久状态: \(context.persistEnabled ? "ON" : "OFF")]\n")

        case .DRAWLINE:
            context.output.append(String(repeating: "-", count: 60) + "\n")

        case .CUSTOMDRAWLINE:
            let values = try evaluateArguments(statement.arguments)
            let lineChar = values.first ?? "-"
            context.output.append(String(repeating: lineChar, count: 60) + "\n")

        case .DRAWLINEFORM:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

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
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[DEBUG] \(values.joined(separator: " "))")

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
            let values = try evaluateArguments(statement.arguments)
            throw EmueraError.runtimeError(message: "抛出异常: \(values.joined(separator: " "))", position: nil)

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
        // 重置所有变量为默认值（整数为0，字符串为空）
        for key in context.variables.keys {
            if case .string = context.variables[key] {
                context.variables[key] = .string("")
            } else {
                context.variables[key] = .integer(0)
            }
        }
        context.lastResult = .null
    }

    public func visitPersistStatement(_ statement: PersistStatement) throws {
        context.persistEnabled = statement.enabled
        // PERSIST statements don't produce visible output
    }

    // MARK: - 表达式求值

    private func evaluateExpression(_ expr: ExpressionNode) throws -> VariableValue {
        switch expr {
        case .integer(let value):
            return .integer(value)

        case .string(let value):
            return .string(value)

        case .variable(let name):
            // 如果变量已定义，返回其值
            if let value = context.variables[name] {
                return value
            }
            // 变量未定义：如果是Unicode字符，返回字符串
            if name.contains(where: { $0.unicodeScalars.contains(where: { $0.value > 127 }) }) {
                return .string(name)
            }
            // ASCII变量名未定义：返回字符串（而不是0）
            // 这样 PRINTL equals 会输出 "equals" 而不是 "0"
            return .string(name)

        case .scopedVariable(let scope, let name, let indices):
            return try resolveScopedVariable(scope: scope, name: name, indices: indices)

        case .arrayAccess(let base, let indices):
            return try evaluateArrayAccess(base: base, indices: indices)

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

    /// 求值数组访问: B:0, A:1:2
    private func evaluateArrayAccess(base: String, indices: [ExpressionNode]) throws -> VariableValue {
        // 求值所有索引
        let indexValues = try indices.map { try evaluateExpression($0) }

        // 检查数组是否存在
        guard let arrayValue = context.variables[base] else {
            return .integer(0)  // 数组不存在，返回0
        }

        // 确保是数组类型
        guard case .array(let arr) = arrayValue else {
            return .integer(0)  // 不是数组，返回0
        }

        // 处理一维数组访问
        if indexValues.count == 1, case .integer(let idx) = indexValues[0] {
            let intIdx = Int(idx)
            if intIdx >= 0 && intIdx < arr.count {
                return arr[intIdx]
            }
            return .integer(0)  // 索引越界
        }

        // 二维数组访问 (A:0:1)
        if indexValues.count == 2,
           case .integer(let idx1) = indexValues[0],
           case .integer(let idx2) = indexValues[1] {
            let intIdx1 = Int(idx1)
            if intIdx1 >= 0 && intIdx1 < arr.count,
               case .array(let innerArr) = arr[intIdx1] {
                let intIdx2 = Int(idx2)
                if intIdx2 >= 0 && intIdx2 < innerArr.count {
                    return innerArr[intIdx2]
                }
            }
            return .integer(0)
        }

        return .integer(0)
    }

    /// 设置数组元素的值: A:0 = 3
    private func setArrayValue(base: String, indices: [ExpressionNode], value: VariableValue) throws {
        // 求值所有索引
        let indexValues = try indices.map { try evaluateExpression($0) }

        // 检查数组是否存在，如果不存在则创建
        var arrayValue = context.variables[base] ?? .array([])

        // 确保是数组类型
        guard case .array(var arr) = arrayValue else {
            throw EmueraError.typeMismatch(expected: "array", actual: "other")
        }

        // 处理一维数组赋值: A:0 = 3
        if indexValues.count == 1, case .integer(let idx) = indexValues[0] {
            let intIdx = Int(idx)
            if intIdx >= 0 {
                // 扩展数组如果需要
                while arr.count <= intIdx {
                    arr.append(.integer(0))
                }
                arr[intIdx] = value
                context.variables[base] = .array(arr)
                return
            }
            throw EmueraError.runtimeError(message: "数组索引不能为负数: \(intIdx)", position: nil)
        }

        // 二维数组赋值: A:0:1 = 3
        if indexValues.count == 2,
           case .integer(let idx1) = indexValues[0],
           case .integer(let idx2) = indexValues[1] {
            let intIdx1 = Int(idx1)
            let intIdx2 = Int(idx2)

            if intIdx1 >= 0 && intIdx2 >= 0 {
                // 扩展外层数组如果需要
                while arr.count <= intIdx1 {
                    arr.append(.array([]))
                }

                // 获取或创建内层数组
                var innerArr: [VariableValue]
                if case .array(let existingInner) = arr[intIdx1] {
                    innerArr = existingInner
                } else {
                    innerArr = []
                }

                // 扩展内层数组如果需要
                while innerArr.count <= intIdx2 {
                    innerArr.append(.integer(0))
                }

                innerArr[intIdx2] = value
                arr[intIdx1] = .array(innerArr)
                context.variables[base] = .array(arr)
                return
            }
            throw EmueraError.runtimeError(message: "数组索引不能为负数: (\(intIdx1), \(intIdx2))", position: nil)
        }

        throw EmueraError.runtimeError(message: "不支持的数组维度", position: nil)
    }

    private func evaluateBinary(op: TokenType.Operator, left: ExpressionNode, right: ExpressionNode) throws -> VariableValue {
        let leftVal = try evaluateExpression(left)
        let rightVal = try evaluateExpression(right)

        switch op {
        case .assign:
            if case .variable(let name) = left {
                context.setVariable(name, value: rightVal)
                return rightVal
            } else if case .arrayAccess(let base, let indices) = left {
                // Handle array assignment: A:0 = 3
                try setArrayValue(base: base, indices: indices, value: rightVal)
                return rightVal
            }
            throw EmueraError.invalidOperation(message: "赋值左侧必须是变量或数组元素")

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

    /// 评估参数列表，返回每个参数的字符串值数组
    /// 用于PRINT等命令，每个参数单独输出
    private func evaluateArguments(_ arguments: [ExpressionNode]) throws -> [String] {
        var results: [String] = []
        for arg in arguments {
            let value = try evaluateExpression(arg)
            results.append(value.description)
        }
        return results
    }

    // MARK: - 标签收集

    private func collectLabels() {
        for (index, statement) in statements.enumerated() {
            if let labelStmt = statement as? LabelStatement {
                context.labels[labelStmt.name] = index
            }
        }
    }

    // MARK: - Phase 2: 函数系统支持

    /// 收集函数定义
    private func collectFunctions() {
        for statement in statements {
            if let funcDefStmt = statement as? FunctionDefinitionStatement {
                let definition = funcDefStmt.definition
                context.functionRegistry.registerFunction(definition)
            }
        }
    }

    /// 访问函数调用语句
    public func visitFunctionCallStatement(_ statement: FunctionCallStatement) throws {
        let evaluatedArgs = try statement.arguments.map { try evaluateExpression($0) }

        // 首先尝试内置函数
        if let builtInResult = try? BuiltInFunctions.execute(
            name: statement.functionName,
            arguments: evaluatedArgs,
            context: context
        ) {
            context.lastResult = builtInResult
            return
        }

        // 然后尝试用户定义函数
        if let functionDefinition = context.functionRegistry.resolveFunction(statement.functionName) {
            // 执行用户定义函数
            let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
            context.lastResult = result
            return
        }

        // 函数未找到
        if statement.tryMode {
            // TRYCALL模式：失败时不抛出错误
            context.lastResult = .integer(0)
            context.output.append("[TRYCALL \(statement.functionName) 失败]\n")
        } else {
            throw EmueraError.functionNotFound(name: statement.functionName)
        }
    }

    /// 执行用户定义函数
    private func executeUserFunction(_ definition: FunctionDefinition, arguments: [VariableValue]) throws -> VariableValue {
        // 创建新的执行上下文
        let oldContext = context
        let newContext = ExecutionContext()
        newContext.callStack = oldContext.callStack

        // 设置参数
        for (index, param) in definition.parameters.enumerated() {
            if index < arguments.count {
                let argValue = arguments[index]
                newContext.variables[param.name] = argValue
                newContext.currentParameters[param.name] = argValue
            }
        }

        // 执行函数体
        let bodyStatements = definition.body
        for stmt in bodyStatements {
            try stmt.accept(visitor: self)

            // 检查是否有返回值
            if let returnValue = context.returnValue {
                context.returnValue = nil  // 清除返回值
                return returnValue
            }

            // 检查是否需要退出
            if context.shouldQuit {
                break
            }
        }

        // 默认返回0
        return .integer(0)
    }

    /// 访问函数定义语句
    public func visitFunctionDefinitionStatement(_ statement: FunctionDefinitionStatement) throws {
        // 函数定义在collectFunctions阶段已注册，这里不需要做任何事
        // 保持方法完整性以符合协议
    }

    /// 访问变量声明语句
    public func visitVariableDeclarationStatement(_ statement: VariableDeclarationStatement) throws {
        // 变量声明在解析阶段处理，执行阶段不需要特殊操作
        // 这里可以添加初始化逻辑
        if let initialValue = statement.initialValue {
            let value = try evaluateExpression(initialValue)
            let fullName = "\(statement.scope.rawValue)\(statement.name)"
            context.variables[fullName] = value
        }
    }

    /// 解析作用域变量
    private func resolveScopedVariable(scope: String, name: String, indices: [ExpressionNode]) throws -> VariableValue {
        let scopeEnum = VariableScope.fromVariableName("\(scope)\(name)").scope
        let fullName = "\(scope)\(name)"

        // 处理数组索引
        if !indices.isEmpty {
            let indexValues = try indices.map { try evaluateExpression($0) }
            // 简化处理：只使用第一个索引
            if case .integer(let idx) = indexValues[0] {
                let arrayKey = "\(fullName)[\(idx)]"
                if let value = context.variables[arrayKey] {
                    return value
                }
                return .integer(0)
            }
        }

        // 普通作用域变量
        if let value = context.variables[fullName] {
            return value
        }

        // 未定义的变量
        if scopeEnum.variableType == .string {
            return .string("")
        }
        return .integer(0)
    }

    // MARK: - TRY/CATCH异常处理 (Phase 3)

    /// 访问TRY/CATCH语句
    public func visitTryCatchStatement(_ statement: TryCatchStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        do {
            // 执行TRY块
            try statement.tryBlock.accept(visitor: self)
        } catch {
            // 发生异常时执行CATCH块
            if let catchBlock = statement.catchBlock {
                // 设置异常处理上下文
                context.currentCatchLabel = statement.catchLabel
                context.shouldCatch = true

                // 执行CATCH块
                try catchBlock.accept(visitor: self)
            }
            // 如果没有CATCH块，异常会向上传播
        }

        // 恢复之前的异常处理上下文
        context.currentCatchLabel = oldCatchLabel
        context.shouldCatch = oldShouldCatch
    }

    /// 访问TRYCALL语句
    public func visitTryCallStatement(_ statement: TryCallStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        do {
            // 尝试执行函数调用
            let evaluatedArgs = try statement.arguments.map { try evaluateExpression($0) }

            // 首先尝试内置函数
            if let builtInResult = try? BuiltInFunctions.execute(
                name: statement.functionName,
                arguments: evaluatedArgs,
                context: context
            ) {
                context.lastResult = builtInResult
            } else if let functionDefinition = context.functionRegistry.resolveFunction(statement.functionName) {
                // 执行用户定义函数
                let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
                context.lastResult = result
            } else {
                // 函数未找到，抛出异常
                throw EmueraError.functionNotFound(name: statement.functionName)
            }
        } catch {
            // 发生异常时跳转到CATCH标签
            if let catchLabel = statement.catchLabel,
               let targetIndex = context.labels[catchLabel] {
                // 设置异常处理上下文
                context.currentCatchLabel = catchLabel
                context.shouldCatch = true

                // 跳转到CATCH标签
                currentStatementIndex = targetIndex
            } else {
                // 没有CATCH标签或标签未找到，异常向上传播
                throw error
            }
        }

        // 恢复之前的异常处理上下文
        context.currentCatchLabel = oldCatchLabel
        context.shouldCatch = oldShouldCatch
    }

    /// 访问TRYJUMP语句
    public func visitTryJumpStatement(_ statement: TryJumpStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        do {
            // 尝试执行JUMP
            if let targetIndex = context.labels[statement.target] {
                // 设置参数（如果有）
                if !statement.arguments.isEmpty {
                    for (index, arg) in statement.arguments.enumerated() {
                        let value = try evaluateExpression(arg)
                        context.setVariable("ARG:\(index)", value: value)
                    }
                }

                // 保存当前调用栈
                context.callStack.append("\(currentStatementIndex)")
                currentStatementIndex = targetIndex

                // 执行目标函数
                while currentStatementIndex < statements.count {
                    let stmt = statements[currentStatementIndex]
                    try stmt.accept(visitor: self)

                    if context.returnValue != nil {
                        // 获取返回地址
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
                throw EmueraError.runtimeError(
                    message: "标签未找到: \\(statement.target)",
                    position: statement.position
                )
            }
        } catch {
            // 发生异常时跳转到CATCH标签
            if let catchLabel = statement.catchLabel,
               let targetIndex = context.labels[catchLabel] {
                // 设置异常处理上下文
                context.currentCatchLabel = catchLabel
                context.shouldCatch = true

                // 跳转到CATCH标签
                currentStatementIndex = targetIndex
            } else {
                // 没有CATCH标签或标签未找到，异常向上传播
                throw error
            }
        }

        // 恢复之前的异常处理上下文
        context.currentCatchLabel = oldCatchLabel
        context.shouldCatch = oldShouldCatch
    }

    /// 访问TRYGOTO语句
    public func visitTryGotoStatement(_ statement: TryGotoStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        do {
            // 尝试执行GOTO
            if let targetIndex = context.labels[statement.label] {
                currentStatementIndex = targetIndex
            } else {
                throw EmueraError.runtimeError(
                    message: "标签未找到: \\(statement.label)",
                    position: statement.position
                )
            }
        } catch {
            // 发生异常时跳转到CATCH标签
            if let catchLabel = statement.catchLabel,
               let targetIndex = context.labels[catchLabel] {
                // 设置异常处理上下文
                context.currentCatchLabel = catchLabel
                context.shouldCatch = true

                // 跳转到CATCH标签
                // 跳转到CATCH标签
                currentStatementIndex = targetIndex
            } else {
                // 没有CATCH标签或标签未找到，异常向上传播
                throw error
            }
        }

        // 恢复之前的异常处理上下文
        context.currentCatchLabel = oldCatchLabel
        context.shouldCatch = oldShouldCatch
    }
}
