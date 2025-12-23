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

    // Phase 3 P1: 数据持久化相关
    public var varData: VariableData?  // 变量数据存储（用于SAVE/LOAD）

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
        varData = nil
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
        newContext.varData = varData
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
                // 检查是否是范围匹配 (CASE 2 TO 5)
                if case .functionCall(let name, let arguments) = valueExpr,
                   name == "__RANGE__" && arguments.count == 2 {
                    // 处理范围匹配
                    let leftValue = try evaluateExpression(arguments[0])
                    let rightValue = try evaluateExpression(arguments[1])

                    if try isValueInRange(testValue, leftValue, rightValue) {
                        try caseClause.body.accept(visitor: self)
                        executed = true
                        break
                    }
                } else {
                    // 普通值匹配
                    let caseValue = try evaluateExpression(valueExpr)
                    if valuesEqual(testValue, caseValue) {
                        try caseClause.body.accept(visitor: self)
                        executed = true
                        break
                    }
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

    /// 检查值是否在范围内（包含边界）
    private func isValueInRange(_ value: VariableValue, _ left: VariableValue, _ right: VariableValue) throws -> Bool {
        switch (value, left, right) {
        case (.integer(let v), .integer(let l), .integer(let r)):
            return v >= l && v <= r
        case (.string(let v), .string(let l), .string(let r)):
            return v >= l && v <= r
        default:
            throw EmueraError.typeMismatch(expected: "same type for range comparison", actual: "mixed types")
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

    /// 访问PRINTDATA语句
    /// 随机选择一个DATALIST块执行
    public func visitPrintDataStatement(_ statement: PrintDataStatement) throws {
        guard !statement.dataLists.isEmpty else {
            // 没有DATALIST子句，什么也不做
            return
        }

        // 随机选择一个DATALIST块
        let randomIndex = Int.random(in: 0..<statement.dataLists.count)
        let selectedList = statement.dataLists[randomIndex]

        // 执行选中的DATALIST块
        try selectedList.body.accept(visitor: self)
    }

    /// 访问DO-LOOP循环语句
    /// DO
    ///     statements
    /// LOOP [WHILE condition | UNTIL condition]
    public func visitDoLoopStatement(_ statement: DoLoopStatement) throws {
        // 循环执行
        while true {
            // 执行循环体
            try statement.body.accept(visitor: self)

            // 检查是否需要跳出循环
            if context.shouldBreak {
                context.shouldBreak = false
                break
            }

            // 检查是否需要继续（跳过本次剩余部分，直接进入下一次迭代）
            if context.shouldContinue {
                context.shouldContinue = false
                continue  // 继续下一次迭代
            }

            // 检查循环条件（如果有）
            if let condition = statement.condition,
               let isWhile = statement.isWhile {
                let result = try evaluateExpression(condition)

                // LOOP WHILE: 条件为true时继续
                // LOOP UNTIL: 条件为false时继续
                let shouldContinue = isWhile ? toBool(result) : !toBool(result)

                if !shouldContinue {
                    break
                }
            } else {
                // 无条件的DO-LOOP，需要BREAK才能退出
                // 这里我们不自动退出，继续等待BREAK
            }
        }
    }

    /// 访问REPEAT循环语句
    /// REPEAT count
    ///     statements (COUNT available)
    /// ENDREPEAT
    public func visitRepeatStatement(_ statement: RepeatStatement) throws {
        // 评估循环次数
        let countValue = try evaluateExpression(statement.count)
        guard case .integer(let count) = countValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        // 执行循环
        for i in 0..<Int(count) {
            // 设置COUNT变量
            context.setVariable("COUNT", value: .integer(Int64(i)))

            // 执行循环体
            try statement.body.accept(visitor: self)

            // 检查是否需要跳出循环
            if context.shouldBreak {
                context.shouldBreak = false
                break
            }

            // 检查是否需要继续（跳过本次剩余部分，直接进入下一次迭代）
            if context.shouldContinue {
                context.shouldContinue = false
                continue  // 继续下一次迭代
            }

            // 检查返回值
            if context.returnValue != nil {
                break
            }

            // 检查是否退出
            if context.shouldQuit {
                break
            }
        }
    }

    // MARK: - SAVE/LOAD数据持久化 (Phase 3 P1)

    /// 访问SAVEDATA语句 - 保存变量到文件
    public func visitSaveDataStatement(_ statement: SaveDataStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法保存数据", position: nil)
        }

        // 评估变量列表
        var variableNames: [String] = []
        for expr in statement.variables {
            let value = try evaluateExpression(expr)
            if case .string(let name) = value {
                variableNames.append(name)
            }
        }

        // 在保存前，先同步context.variables到VariableData
        syncContextToVariableData(varData)

        do {
            let jsonString: String
            if variableNames.isEmpty {
                // 保存所有变量
                jsonString = try varData.serializeAll()
            } else {
                // 保存指定变量
                jsonString = try varData.serializeVariables(variableNames)
            }

            // 写入文件
            let fileURL = getSaveFileURL(filename)
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)

            context.output.append("[已保存到: \(filename)]\n")
            context.lastResult = .integer(1)  // 成功

        } catch {
            context.output.append("[保存失败: \(error)]\n")
            context.lastResult = .integer(0)  // 失败
            throw error
        }
    }

    /// 访问LOADDATA语句 - 从文件加载变量
    public func visitLoadDataStatement(_ statement: LoadDataStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法加载数据", position: nil)
        }

        // 评估变量列表
        var variableNames: [String] = []
        for expr in statement.variables {
            let value = try evaluateExpression(expr)
            if case .string(let name) = value {
                variableNames.append(name)
            }
        }

        do {
            // 读取文件
            let fileURL = getSaveFileURL(filename)
            let jsonString = try String(contentsOf: fileURL, encoding: .utf8)

            if variableNames.isEmpty {
                // 加载所有变量
                try varData.deserializeAll(jsonString)
            } else {
                // 加载指定变量
                try varData.deserializeVariables(jsonString, variableNames: variableNames)
            }

            // 同步VariableData到ExecutionContext（可选，用于后续访问）
            syncVariableDataToContext(varData)

            context.output.append("[已从: \(filename) 加载]\n")
            context.lastResult = .integer(1)  // 成功

        } catch {
            context.output.append("[加载失败: \(error)]\n")
            context.lastResult = .integer(0)  // 失败
            throw error
        }
    }

    /// 访问DELDATA语句 - 删除存档文件
    public func visitDelDataStatement(_ statement: DelDataStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        do {
            let fileURL = getSaveFileURL(filename)

            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                context.output.append("[已删除: \(filename)]\n")
                context.lastResult = .integer(1)  // 成功
            } else {
                context.output.append("[文件不存在: \(filename)]\n")
                context.lastResult = .integer(0)  // 失败
            }

        } catch {
            context.output.append("[删除失败: \(error)]\n")
            context.lastResult = .integer(0)  // 失败
            throw error
        }
    }

    /// 访问SAVECHARA语句 - 保存角色数据到文件
    public func visitSaveCharaStatement(_ statement: SaveCharaStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 评估角色索引
        let charaIndexValue = try evaluateExpression(statement.charaIndex)
        guard case .integer(let charaIndex) = charaIndexValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法保存角色数据", position: nil)
        }

        do {
            // 序列化角色数据
            let jsonString = try varData.serializeCharacter(charaIndex: Int(charaIndex), filename: filename)

            // 写入文件
            let fileURL = getSaveFileURL(filename)
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)

            context.output.append("[角色已保存到: \(filename)]\n")
            context.lastResult = .integer(1)  // 成功

        } catch {
            context.output.append("[角色保存失败: \(error)]\n")
            context.lastResult = .integer(0)  // 失败
            throw error
        }
    }

    /// 访问LOADCHARA语句 - 从文件加载角色数据
    public func visitLoadCharaStatement(_ statement: LoadCharaStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 评估角色索引
        let charaIndexValue = try evaluateExpression(statement.charaIndex)
        guard case .integer(let charaIndex) = charaIndexValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法加载角色数据", position: nil)
        }

        do {
            // 读取文件
            let fileURL = getSaveFileURL(filename)
            let jsonString = try String(contentsOf: fileURL, encoding: .utf8)

            // 反序列化角色数据
            try varData.deserializeCharacter(jsonString: jsonString, charaIndex: Int(charaIndex))

            context.output.append("[已从: \(filename) 加载角色]\n")
            context.lastResult = .integer(1)  // 成功

        } catch {
            context.output.append("[角色加载失败: \(error)]\n")
            context.lastResult = .integer(0)  // 失败
            throw error
        }
    }

    /// 访问SAVEGAME语句 - 保存完整游戏状态到文件
    public func visitSaveGameStatement(_ statement: SaveGameStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法保存游戏状态", position: nil)
        }

        do {
            // 同步context到VariableData（确保最新数据）
            syncContextToVariableData(varData)

            // 序列化完整游戏状态
            let jsonString = try varData.serializeGameState()

            // 写入文件
            let fileURL = getSaveFileURL(filename)
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)

            context.output.append("[游戏已保存到: \(filename)]\n")
            context.lastResult = .integer(1)  // 成功

        } catch {
            context.output.append("[游戏保存失败: \(error)]\n")
            context.lastResult = .integer(0)  // 失败
            throw error
        }
    }

    /// 访问LOADGAME语句 - 从文件加载完整游戏状态
    public func visitLoadGameStatement(_ statement: LoadGameStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法加载游戏状态", position: nil)
        }

        do {
            // 读取文件
            let fileURL = getSaveFileURL(filename)
            let jsonString = try String(contentsOf: fileURL, encoding: .utf8)

            // 反序列化完整游戏状态
            try varData.deserializeGameState(jsonString)

            // 同步VariableData到context（用于后续访问）
            syncVariableDataToContext(varData)

            context.output.append("[已从: \(filename) 加载游戏]\n")
            context.lastResult = .integer(1)  // 成功

        } catch {
            context.output.append("[游戏加载失败: \(error)]\n")
            context.lastResult = .integer(0)  // 失败
            throw error
        }
    }

    // MARK: - 辅助方法

    /// 获取保存文件的URL（保存在应用目录下的saves文件夹）
    private func getSaveFileURL(_ filename: String) -> URL {
        // 获取应用文档目录
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths[0]

        // 创建saves子目录
        let savesURL = documentsURL.appendingPathComponent("EmueraSaves")

        // 确保目录存在
        try? FileManager.default.createDirectory(at: savesURL, withIntermediateDirectories: true)

        // 返回文件URL（自动添加.json扩展名如果未指定）
        let finalFilename = filename.hasSuffix(".json") ? filename : "\(filename).json"
        return savesURL.appendingPathComponent(finalFilename)
    }

    /// 将VariableData中的数据同步到ExecutionContext（用于后续访问）
    private func syncVariableDataToContext(_ varData: VariableData) {
        // 同步VariableData的arrays到context.variables
        // 这样表达式求值就能访问到正确的数组数据

        // 同步普通数组（RESULT, SELECTCOM等）
        for (name, array) in varData.getAllArrays() {
            // 转换为VariableValue.array格式
            let variableArray = array.map { VariableValue.integer($0) }
            context.variables[name] = .array(variableArray)
        }

        // 同步dataIntegerArray（系统变量如A-Z, FLAG等）
        // 这些需要通过TokenData访问，但为了兼容性也同步到context
        // 注意：dataIntegerArray的索引对应VariableCode的baseValue
        // 这里我们只同步常用的A-Z数组（索引0x1E-0x37）
        for i in 0x1E...0x37 {
            if i < varData.dataIntegerArray.count {
                let array = varData.dataIntegerArray[i]
                if !array.isEmpty {
                    // 将索引转换为字符名 (0x1E = 'A', 0x1F = 'B', etc.)
                    if let charName = getArrayNameFromBaseValue(i) {
                        let variableArray = array.map { VariableValue.integer($0) }
                        context.variables[charName] = .array(variableArray)
                    }
                }
            }
        }
    }

    /// 从VariableCode baseValue获取数组名（如A, B, C等）
    private func getArrayNameFromBaseValue(_ baseValue: Int) -> String? {
        // A-Z对应0x1E-0x37
        if baseValue >= 0x1E && baseValue <= 0x37 {
            let offset = baseValue - 0x1E
            if let scalar = UnicodeScalar("A".unicodeScalars.first!.value + UInt32(offset)) {
                return String(Character(scalar))
            }
        }
        return nil
    }

    /// 将ExecutionContext的变量同步到VariableData（用于保存）
    private func syncContextToVariableData(_ varData: VariableData) {
        // 同步context.variables中的数组到VariableData
        for (name, value) in context.variables {
            if case .array(let array) = value {
                // 转换为Int64数组
                let intArray = array.compactMap { val -> Int64? in
                    if case .integer(let intVal) = val {
                        return intVal
                    }
                    return nil
                }
                if !intArray.isEmpty {
                    // 检查是否是系统变量（A-Z）
                    if name.count == 1, let char = name.first, char.isUppercase, char >= "A" && char <= "Z" {
                        // A-Z系统变量，使用dataIntegerArray
                        let offset = Int(char.asciiValue! - Character("A").asciiValue!)
                        let baseValue = 0x1E + offset
                        if baseValue < varData.dataIntegerArray.count {
                            varData.dataIntegerArray[baseValue] = intArray
                        }
                    } else {
                        // 普通数组变量
                        varData.setArray(name, values: intArray)
                    }
                }
            }
        }
    }
}
