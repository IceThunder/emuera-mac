//
//  StatementExecutor.swift
//  EmueraCore
//
//  语句执行器 - 执行解析后的语句AST
//  支持控制流、变量操作和命令执行
//  Created: 2025-12-19
//

import Foundation

// MARK: - External Type Imports (Phase 6 Character Management)
// These types are defined in other modules but used by command execution


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

    // Phase 6: UI相关
    public var console: EmueraConsole?  // 控制台输出

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
        console = nil
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
        newContext.console = console
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
            let outputText = values.joined(separator: " ") + "\n"
            context.output.append(outputText)
            if let console = context.console {
                console.addLine(ConsoleLine(type: .print, content: outputText, attributes: ConsoleAttributes()))
            }

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

        // MARK: - 打印命令扩展 (Week 1)
        case .PRINTC:
            // 居中打印
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, (width - text.count) / 2)
            let centered = String(repeating: " ", count: padding) + text
            context.output.append(centered)

        case .PRINTLC:
            // 左对齐打印
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTCR:
            // 右对齐打印
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, width - text.count)
            let rightAligned = String(repeating: " ", count: padding) + text
            context.output.append(rightAligned)

        case .PRINTFORMC:
            // 格式化居中打印
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, (width - text.count) / 2)
            let centered = String(repeating: " ", count: padding) + text
            context.output.append(centered)

        case .PRINTFORMLC:
            // 格式化左对齐打印并换行
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTFORMCR:
            // 格式化右对齐打印
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, width - text.count)
            let rightAligned = String(repeating: " ", count: padding) + text
            context.output.append(rightAligned + "\n")

        case .PRINTPLAIN:
            // 纯文本打印
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTPLAINFORM:
            // 格式化纯文本打印
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLE:
            // 单行输出
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEV:
            // 单行变量输出
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLES:
            // 单行字符串输出
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEFORM:
            // 单行格式化输出
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEFORMS:
            // 单行格式化字符串输出
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTBUTTON:
            // 按钮打印
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[按钮: \(values.joined(separator: " "))]")

        case .PRINTBUTTONC:
            // 按钮居中
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, (width - text.count) / 2)
            let centered = String(repeating: " ", count: padding) + "[按钮: \(text)]"
            context.output.append(centered)

        case .PRINTBUTTONLC:
            // 按钮左对齐
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[按钮: \(values.joined(separator: " "))]")

        case .PRINT_IMG:
            // 打印图片
            let values = try evaluateArguments(statement.arguments)
            if let filename = values.first {
                context.output.append("[图片: \(filename)]\n")
            }

        case .PRINT_RECT:
            // 打印矩形
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[矩形: \(values)]\n")

        case .PRINT_SPACE:
            // 打印空格
            let values = try evaluateArguments(statement.arguments)
            let count = values.first.flatMap { Int($0) } ?? 1
            context.output.append(String(repeating: " ", count: max(0, count)))

        case .PRINTCPERLINE:
            // 每行字符数
            context.output.append("[每行字符数: 80]\n")

        case .PRINTCLENGTH:
            // 打印长度
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            context.lastResult = .integer(Int64(text.count))
            context.output.append("[长度: \(text.count)]\n")

        // MARK: - K模式打印命令
        case .PRINTK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTKL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTKW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTVK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTVKL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTVKW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTSK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSKL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTSKW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTFORMK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTFORMKL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTFORMKW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTFORMSK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTFORMSKL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTFORMSKW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTCK:
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, (width - text.count) / 2)
            let centered = String(repeating: " ", count: padding) + text
            context.output.append(centered)

        case .PRINTLCK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTFORMCK:
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, (width - text.count) / 2)
            let centered = String(repeating: " ", count: padding) + text
            context.output.append(centered)

        case .PRINTFORMLCK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTSINGLEK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEVK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLESK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEFORMK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEFORMSK:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        // MARK: - D模式打印命令
        case .PRINTD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTDL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTDW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTVD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTVDL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTVDW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTSD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSDL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTSDW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTFORMD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTFORMDL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTFORMDW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTFORMSD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTFORMSDL:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTFORMSDW:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))
            context.output.append("按回车继续...\n")

        case .PRINTCD:
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, (width - text.count) / 2)
            let centered = String(repeating: " ", count: padding) + text
            context.output.append(centered)

        case .PRINTLCD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTFORMCD:
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            let width = 80
            let padding = max(0, (width - text.count) / 2)
            let centered = String(repeating: " ", count: padding) + text
            context.output.append(centered)

        case .PRINTFORMLCD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " ") + "\n")

        case .PRINTSINGLED:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEVD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLESD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEFORMD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .PRINTSINGLEFORMSD:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        // MARK: - 数据块命令
        case .DATA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .DATAFORM:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        case .STRDATA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append(values.joined(separator: " "))

        // MARK: - 数据操作命令
        case .ADDDEFCHARA:
            context.output.append("[添加默认角色]\n")
            context.lastResult = .integer(1)

        case .ADDSPCHARA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[添加特殊角色: \(values)]\n")
            context.lastResult = .integer(1)

        case .ADDCOPYCHARA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[添加复制角色: \(values)]\n")
            context.lastResult = .integer(1)

        case .DELALLCHARA:
            context.output.append("[删除所有角色]\n")
            context.lastResult = .integer(1)

        case .PICKUPCHARA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[挑选角色: \(values)]\n")
            context.lastResult = .integer(1)

        case .CHARAOPERATE:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[角色操作: \(values)]\n")
            context.lastResult = .integer(1)

        case .CHARAMODIFY:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[角色修改: \(values)]\n")
            context.lastResult = .integer(1)

        case .CHARAFILTER:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[角色过滤: \(values)]\n")
            context.lastResult = .integer(1)

        case .FINDCHARA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[查找角色: \(values)]\n")
            context.lastResult = .integer(0)

        // MARK: - 字符串操作命令
        case .STRLENFORM:
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            context.lastResult = .integer(Int64(text.count))
            context.output.append("[长度: \(text.count)]\n")

        case .STRLENU:
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            context.lastResult = .integer(Int64(text.count))
            context.output.append("[Unicode长度: \(text.count)]\n")

        case .STRLENFORMU:
            let values = try evaluateArguments(statement.arguments)
            let text = values.joined(separator: " ")
            context.lastResult = .integer(Int64(text.count))
            context.output.append("[Unicode长度: \(text.count)]\n")

        case .ENCODETOUNI:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[编码转换: \(values)]\n")
            context.lastResult = .string(values.first ?? "")

        // MARK: - 数学计算命令
        case .TIMES:
            if statement.arguments.count >= 2 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let varName) = statement.arguments[0],
                   case .integer(let value) = args[0],
                   case .integer(let multiplier) = args[1] {
                    let result = value * multiplier
                    context.setVariable(varName, value: .integer(result))
                    context.output.append("[TIMES: \(varName) = \(result)]\n")
                }
            }

        // MARK: - 系统命令
        case .BEGIN:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[开始系统函数: \(values.first ?? "UNKNOWN")]\n")

        case .RESETDATA:
            context.output.append("[重置数据]\n")
            context.variables.removeAll()
            context.variables["RESULT"] = .integer(0)
            context.variables["RESULTS"] = .string("")

        case .RESETGLOBAL:
            context.output.append("[重置全局变量]\n")
            for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
                context.variables[String(char)] = .array(Array(repeating: .integer(0), count: 100))
            }

        case .RESET_STAIN:
            context.output.append("[重置污渍]\n")

        case .GETMILLISECOND:
            let milliseconds = Int64(Date().timeIntervalSince1970 * 1000)
            context.setVariable("RESULT", value: .integer(milliseconds))
            context.output.append("[毫秒: \(milliseconds)]\n")

        case .GETSECOND:
            let seconds = Int64(Date().timeIntervalSince1970)
            context.setVariable("RESULT", value: .integer(seconds))
            context.output.append("[秒: \(seconds)]\n")

        // MARK: - 数据打印命令
        case .PRINT_SHOPITEM:
            context.output.append("[商店物品列表]\n")

        // MARK: - HTML和工具提示命令
        case .HTML_PRINT:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[HTML: \(values.joined(separator: " "))]\n")

        case .HTML_TAGSPLIT:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[HTML标签分割: \(values)]\n")

        case .HTML_GETPRINTEDSTR:
            context.output.append("[获取打印字符串]\n")
            context.lastResult = .string("")

        case .HTML_POPPRINTINGSTR:
            context.output.append("[弹出打印字符串]\n")
            context.lastResult = .string("")

        case .HTML_TOPLAINTEXT:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[HTML转纯文本: \(values)]\n")
            context.lastResult = .string(values.first ?? "")

        case .HTML_ESCAPE:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[HTML转义: \(values)]\n")
            context.lastResult = .string(values.first ?? "")

        case .TOOLTIP_SETCOLOR:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[工具提示颜色: \(values)]\n")

        case .TOOLTIP_SETDELAY:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[工具提示延迟: \(values)]\n")

        case .TOOLTIP_SETDURATION:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[工具提示持续时间: \(values)]\n")

        // MARK: - 鼠标和输入命令
        case .INPUTMOUSEKEY:
            context.output.append("[鼠标按键输入]\n")
            context.setVariable("RESULT", value: .integer(0))

        case .FORCEKANA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[强制假名: \(values)]\n")

        // MARK: - 窗口显示命令
        case .FORCEWAIT:
            context.output.append("按回车继续...\n")

        case .TWAIT:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[定时等待: \(values)]\n")

        case .OUTPUTLOG:
            context.output.append("[输出日志]\n")

        // MARK: - 字体样式命令
        case .FONTSTYLE:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[字体样式: \(values)]\n")

        case .SETCOLORBYNAME:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[按名称设置颜色: \(values)]\n")

        case .SETBGCOLORBYNAME:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[按名称设置背景颜色: \(values)]\n")

        // MARK: - 文件持久化命令
        case .SAVEDATA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[保存数据: \(values)]\n")
            context.lastResult = .integer(1)

        case .LOADDATA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[加载数据: \(values)]\n")
            context.lastResult = .integer(1)

        case .DELDATA:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[删除数据: \(values)]\n")
            context.lastResult = .integer(1)

        case .SAVEGLOBAL:
            context.output.append("[保存全局]\n")
            context.lastResult = .integer(1)

        case .LOADGLOBAL:
            context.output.append("[加载全局]\n")
            context.lastResult = .integer(1)

        case .SAVENOS:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[保存编号: \(values)]\n")
            context.lastResult = .integer(1)

        // MARK: - 调试命令扩展
        case .DEBUGPRINTFORM:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[DEBUG FORM] \(values.joined(separator: " "))\n")

        case .DEBUGPRINTFORML:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[DEBUG FORML] \(values.joined(separator: " "))\n")

        case .CVARSET:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[变量批量设置: \(values)]\n")

        // MARK: - 其他数学命令
        case .POWER:
            if statement.arguments.count >= 3 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let varName) = statement.arguments[0],
                   case .integer(let base) = args[1],
                   case .integer(let exp) = args[2] {
                    let result = Int64(pow(Double(base), Double(exp)))
                    context.setVariable(varName, value: .integer(result))
                    context.output.append("[POWER: \(varName) = \(result)]\n")
                }
            }

        case .RANDOMIZE:
            context.output.append("[随机种子设置]\n")

        case .DUMPRAND:
            context.output.append("[转储随机状态]\n")

        case .INITRAND:
            context.output.append("[初始化随机]\n")

        // MARK: - 事件相关
        case .CALLTRAIN:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[调用训练: \(values)]\n")

        case .STOPCALLTRAIN:
            context.output.append("[停止训练]\n")

        // MARK: - 异常处理扩展
        case .TRYCCALLFORM:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[TRYCCALLFORM: \(values)]\n")

        case .TRYCGOTOFORM:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[TRYCGOTOFORM: \(values)]\n")

        case .TRYCJUMPFORM:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[TRYCJUMPFORM: \(values)]\n")

        case .TRYCALLLIST:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[TRYCALLLIST: \(values)]\n")

        case .TRYJUMPLIST:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[TRYJUMPLIST: \(values)]\n")

        case .TRYGOTOLIST:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[TRYGOTOLIST: \(values)]\n")

        // MARK: - 函数定义
        case .FUNC:
            context.output.append("[函数开始]\n")

        case .ENDFUNC:
            context.output.append("[函数结束]\n")

        case .CALLF:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[CALLF: \(values)]\n")

        case .CALLFORMF:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[CALLFORMF: \(values)]\n")

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

        // Priority 4: 高级图形命令
        case .DRAWSPRITE:
            // DRAWSPRITE filename, x, y, width, height
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 3 {
                let filename = values[0].description
                let x = values.count >= 2 ? values[1].description : "0"
                let y = values.count >= 3 ? values[2].description : "0"
                let width = values.count >= 4 ? values[3].description : "auto"
                let height = values.count >= 5 ? values[4].description : "auto"
                context.output.append("[绘制精灵: \(filename) @ (\(x), \(y)) 尺寸: \(width)x\(height)]\n")
            }

        case .DRAWRECT:
            // DRAWRECT x, y, width, height, [color]
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 4 {
                let x = values[0].description
                let y = values[1].description
                let w = values[2].description
                let h = values[3].description
                let color = values.count >= 5 ? values[4].description : "default"
                let rect = generateRectArt(Int(w) ?? 10, Int(h) ?? 5, color)
                context.output.append("[绘制矩形 @ (\(x), \(y)) 颜色: \(color)]\n")
                context.output.append(rect)
            }

        case .FILLRECT:
            // FILLRECT x, y, width, height, [color]
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 4 {
                let x = values[0].description
                let y = values[1].description
                let w = values[2].description
                let h = values[3].description
                let color = values.count >= 5 ? values[4].description : "default"
                let rect = generateFilledRectArt(Int(w) ?? 10, Int(h) ?? 5, color)
                context.output.append("[填充矩形 @ (\(x), \(y)) 颜色: \(color)]\n")
                context.output.append(rect)
            }

        case .DRAWCIRCLE:
            // DRAWCIRCLE x, y, radius, [color]
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 3 {
                let x = values[0].description
                let y = values[1].description
                let r = values[2].description
                let color = values.count >= 4 ? values[3].description : "default"
                let circle = generateCircleArt(Int(r) ?? 5, color, false)
                context.output.append("[绘制圆形 @ (\(x), \(y)) 半径: \(r) 颜色: \(color)]\n")
                context.output.append(circle)
            }

        case .FILLCIRCLE:
            // FILLCIRCLE x, y, radius, [color]
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 3 {
                let x = values[0].description
                let y = values[1].description
                let r = values[2].description
                let color = values.count >= 4 ? values[3].description : "default"
                let circle = generateCircleArt(Int(r) ?? 5, color, true)
                context.output.append("[填充圆形 @ (\(x), \(y)) 半径: \(r) 颜色: \(color)]\n")
                context.output.append(circle)
            }

        case .DRAWLINEEX:
            // DRAWLINEEX x1, y1, x2, y2, [color]
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 4 {
                let x1 = values[0].description
                let y1 = values[1].description
                let x2 = values[2].description
                let y2 = values[3].description
                let color = values.count >= 5 ? values[4].description : "default"
                context.output.append("[绘制线条: (\(x1), \(y1)) -> (\(x2), \(y2)) 颜色: \(color)]\n")
                let line = generateLineArt(Int(x1) ?? 0, Int(y1) ?? 0, Int(x2) ?? 10, Int(y2) ?? 5)
                context.output.append(line)
            }

        case .DRAWGRADIENT:
            // DRAWGRADIENT x, y, width, height, color1, color2, [direction]
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 6 {
                let x = values[0].description
                let y = values[1].description
                let w = values[2].description
                let h = values[3].description
                let c1 = values[4].description
                let c2 = values[5].description
                let dir = values.count >= 7 ? values[6].description : "0"
                let gradient = generateGradientArt(Int(w) ?? 10, Int(h) ?? 5, c1, c2, Int(dir) ?? 0)
                context.output.append("[渐变填充 @ (\(x), \(y)) 尺寸: \(w)x\(h) \(c1)->\(c2) 方向: \(dir)]\n")
                context.output.append(gradient)
            }

        case .SETBRUSH:
            // SETBRUSH style, size, [color]
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 1 {
                let style = values[0].description
                let size = values.count >= 2 ? values[1].description : "1"
                let color = values.count >= 3 ? values[2].description : "default"
                let styleName = style == "0" ? "实线" : style == "1" ? "虚线" : "点线"
                context.output.append("[设置画笔: \(styleName) 大小: \(size) 颜色: \(color)]\n")
            }

        case .CLEARSCREEN:
            // CLEARSCREEN
            context.output.append("[清屏]\n")
            context.output.append(String(repeating: "\n", count: 20))

        case .SETBACKGROUNDCOLOR:
            // SETBACKGROUNDCOLOR color
            let values = try evaluateArguments(statement.arguments)
            if values.count >= 1 {
                let color = values[0].description
                context.output.append("[设置背景颜色: \(color)]\n")
            }

        case .SETCOLOR, .RESETCOLOR, .SETBGCOLOR, .RESETBGCOLOR:
            context.output.append("[颜色设置: \(statement.command)]\n")

        case .FONTBOLD, .FONTITALIC, .FONTREGULAR, .SETFONT:
            context.output.append("[字体设置: \(statement.command)]\n")

        // Priority 2: 输入命令扩展
        case .TINPUT, .TINPUTS, .TONEINPUT, .TONEINPUTS:
            let values = try evaluateArguments(statement.arguments)
            context.output.append("[命令: \(statement.command) 参数: \(values)]\n")
            if statement.command.uppercased().hasSuffix("S") {
                context.setVariable("RESULTS", value: .string(""))
            } else {
                context.setVariable("RESULT", value: .integer(0))
            }

        case .AWAIT:
            context.output.append("[等待输入]\n")

        // Priority 2: 位运算命令
        case .SETBIT:
            if statement.arguments.count >= 2 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let varName) = statement.arguments[0],
                   case .integer(let bit) = args[1] {
                    let current = context.getVariable(varName)
                    if case .integer(let currentVal) = current {
                        let newValue = currentVal | (1 << bit)
                        context.setVariable(varName, value: .integer(newValue))
                        context.lastResult = .integer(newValue)
                    }
                }
            }

        case .CLEARBIT:
            if statement.arguments.count >= 2 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let varName) = statement.arguments[0],
                   case .integer(let bit) = args[1] {
                    let current = context.getVariable(varName)
                    if case .integer(let currentVal) = current {
                        let newValue = currentVal & ~(1 << bit)
                        context.setVariable(varName, value: .integer(newValue))
                        context.lastResult = .integer(newValue)
                    }
                }
            }

        case .INVERTBIT:
            if statement.arguments.count >= 2 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let varName) = statement.arguments[0],
                   case .integer(let bit) = args[1] {
                    let current = context.getVariable(varName)
                    if case .integer(let currentVal) = current {
                        let newValue = currentVal ^ (1 << bit)
                        context.setVariable(varName, value: .integer(newValue))
                        context.lastResult = .integer(newValue)
                    }
                }
            }

        // Priority 2: 数组操作命令
        case .ARRAYSHIFT:
            if statement.arguments.count >= 2 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let arrayName) = statement.arguments[0],
                   case .integer(let shift) = args[1] {
                    // 获取数组
                    if case .array(let arr) = context.variables[arrayName] {
                        // 执行移位
                        let shiftInt = Int(shift)
                        if shiftInt > 0 && shiftInt < arr.count {
                            let shifted = Array(arr[shiftInt...] + arr[0..<shiftInt])
                            context.variables[arrayName] = .array(shifted)
                        }
                    }
                }
            }

        case .ARRAYREMOVE:
            if statement.arguments.count >= 2 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let arrayName) = statement.arguments[0],
                   case .integer(let index) = args[1] {
                    // 获取数组
                    if case .array(let arr) = context.variables[arrayName] {
                        // 移除指定索引
                        if index >= 0 && index < arr.count {
                            var newArr = arr
                            newArr.remove(at: Int(index))
                            context.variables[arrayName] = .array(newArr)
                        }
                    }
                }
            }

        case .ARRAYSORT:
            if statement.arguments.count >= 1 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let arrayName) = statement.arguments[0] {
                    // 获取数组
                    if case .array(let arr) = context.variables[arrayName] {
                        // 排序（升序）
                        let sorted = arr.sorted { a, b in
                            switch (a, b) {
                            case (.integer(let la), .integer(let lb)): return la < lb
                            case (.string(let la), .string(let lb)): return la < lb
                            default: return false
                            }
                        }
                        context.variables[arrayName] = .array(sorted)
                    }
                }
            }

        case .ARRAYCOPY:
            if statement.arguments.count >= 1 {
                let args = try statement.arguments.map { try evaluateExpression($0) }
                if case .variable(let arrayName) = statement.arguments[0] {
                    // 获取数组
                    if case .array(let arr) = context.variables[arrayName] {
                        // 复制数组（结果存储在RESULT数组中）
                        context.variables["RESULT"] = .array(arr)
                        context.lastResult = .array(arr)
                    }
                }
            }

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


        case .GETTIME:
            let time = Date().timeIntervalSince1970
            context.setVariable("RESULT", value: .integer(Int64(time)))
            context.output.append("[时间: \(Int64(time))]\n")

        case .UNKNOWN:
            context.output.append("[未知命令: \(statement.command)]\n")

        // MARK: - 流程控制命令 (42个)

        case .BREAK:
            // 跳出循环
            context.shouldBreak = true

        case .CONTINUE:
            // 继续下一次循环
            context.shouldContinue = true

        case .CALL:
            // CALL函数调用 - 在visitCallStatement中已实现
            if statement.arguments.count >= 1 {
                if case .string(let target) = try evaluateExpression(statement.arguments[0]) {
                    // 尝试作为标签调用
                    if let targetIndex = context.labels[target] {
                        context.callStack.append("\(currentStatementIndex)")
                        currentStatementIndex = targetIndex
                        return
                    }
                    // 尝试作为函数调用
                    if let functionDefinition = context.functionRegistry.resolveFunction(target) {
                        let args = statement.arguments.count > 1 ? Array(statement.arguments[1...]) : []
                        let evaluatedArgs = try args.map { try evaluateExpression($0) }
                        let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
                        context.lastResult = result
                        return
                    }
                }
            }
            context.output.append("[CALL: 参数不足或目标未找到]\n")

        case .JUMP:
            // JUMP跳转 - 类似CALL但不返回
            if statement.arguments.count >= 1 {
                if case .string(let target) = try evaluateExpression(statement.arguments[0]) {
                    if let targetIndex = context.labels[target] {
                        // 设置参数
                        if statement.arguments.count > 1 {
                            for i in 1..<statement.arguments.count {
                                let value = try evaluateExpression(statement.arguments[i])
                                context.setVariable("ARG:\(i-1)", value: value)
                            }
                        }
                        context.callStack.append("\(currentStatementIndex)")
                        currentStatementIndex = targetIndex
                        return
                    }
                }
            }
            context.output.append("[JUMP: 目标未找到]\n")

        case .GOTO:
            // GOTO跳转 - 在visitGotoStatement中已实现
            if statement.arguments.count >= 1 {
                if case .string(let label) = try evaluateExpression(statement.arguments[0]) {
                    if let targetIndex = context.labels[label] {
                        currentStatementIndex = targetIndex
                        return
                    }
                }
            }
            context.output.append("[GOTO: 标签未找到]\n")

        case .CALLFORM:
            // 格式化函数调用
            if statement.arguments.count >= 1 {
                let formatValue = try evaluateExpression(statement.arguments[0])
                let functionName = formatValue.toString()
                let args = statement.arguments.count > 1 ? Array(statement.arguments[1...]) : []
                let evaluatedArgs = try args.map { try evaluateExpression($0) }

                if let builtInResult = try? BuiltInFunctions.execute(name: functionName, arguments: evaluatedArgs, context: context) {
                    context.lastResult = builtInResult
                } else if let functionDefinition = context.functionRegistry.resolveFunction(functionName) {
                    let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
                    context.lastResult = result
                } else {
                    context.output.append("[CALLFORM: 函数未找到: \(functionName)]\n")
                }
            }

        case .JUMPFORM:
            // 格式化跳转
            if statement.arguments.count >= 1 {
                let formatValue = try evaluateExpression(statement.arguments[0])
                let targetName = formatValue.toString()

                if let targetIndex = context.labels[targetName] {
                    // 设置参数
                    if statement.arguments.count > 1 {
                        for i in 1..<statement.arguments.count {
                            let value = try evaluateExpression(statement.arguments[i])
                            context.setVariable("ARG:\(i-1)", value: value)
                        }
                    }
                    context.callStack.append("\(currentStatementIndex)")
                    currentStatementIndex = targetIndex
                    return
                }
            }
            context.output.append("[JUMPFORM: 目标未找到]\n")

        case .GOTOFORM:
            // 格式化GOTO
            if statement.arguments.count >= 1 {
                let formatValue = try evaluateExpression(statement.arguments[0])
                let labelName = formatValue.toString()

                if let targetIndex = context.labels[labelName] {
                    currentStatementIndex = targetIndex
                    return
                }
            }
            context.output.append("[GOTOFORM: 标签未找到]\n")

        case .CALLEVENT:
            // 事件调用
            context.output.append("[CALLEVENT: 事件调用]\n")

        case .RETURN:
            // RETURN返回 - 在visitReturnStatement中已实现
            if statement.arguments.count >= 1 {
                let value = try evaluateExpression(statement.arguments[0])
                context.returnValue = value
            } else {
                context.returnValue = .null
            }

        case .RETURNFORM:
            // 格式化返回
            if statement.arguments.count >= 1 {
                let value = try evaluateExpression(statement.arguments[0])
                context.returnValue = value
            } else {
                context.returnValue = .null
            }

        case .RETURNF:
            // 函数返回
            if statement.arguments.count >= 1 {
                let value = try evaluateExpression(statement.arguments[0])
                context.returnValue = value
            } else {
                context.returnValue = .null
            }

        case .RESTART:
            // 重启函数 - 跳回到函数开始位置
            if let callerIndexStr = context.callStack.last,
               let callerIndex = Int(callerIndexStr) {
                // 找到函数开始位置（CALL之后的第一个语句）
                currentStatementIndex = callerIndex + 1
            } else {
                // 如果不在函数中，重启整个脚本
                currentStatementIndex = 0
            }
            context.output.append("[RESTART: 重启]\n")

        case .DOTRAIN:
            // 训练开始
            context.output.append("[DOTRAIN: 训练开始]\n")

        case .DO:
            // DO循环开始 - 由visitDoLoopStatement处理
            context.output.append("[DO: 循环开始]\n")

        case .LOOP:
            // DO循环结束 - 由visitDoLoopStatement处理
            context.output.append("[LOOP: 循环结束]\n")

        case .WHILE:
            // WHILE循环开始 - 由visitWhileStatement处理
            context.output.append("[WHILE: 循环开始]\n")

        case .WEND:
            // WHILE循环结束
            context.output.append("[WEND: 循环结束]\n")

        case .FOR:
            // FOR循环开始 - 由visitForStatement处理
            context.output.append("[FOR: 循环开始]\n")

        case .NEXT:
            // FOR循环结束
            context.output.append("[NEXT: 循环结束]\n")

        case .REPEAT:
            // REPEAT循环开始 - 由visitRepeatStatement处理
            context.output.append("[REPEAT: 循环开始]\n")

        case .REND:
            // REPEAT循环结束
            context.output.append("[REND: 循环结束]\n")

        case .TRYCALL:
            // 尝试调用
            if statement.arguments.count >= 1 {
                if case .string(let functionName) = try evaluateExpression(statement.arguments[0]) {
                    let args = statement.arguments.count > 1 ? Array(statement.arguments[1...]) : []
                    let evaluatedArgs = try args.map { try evaluateExpression($0) }

                    if let builtInResult = try? BuiltInFunctions.execute(name: functionName, arguments: evaluatedArgs, context: context) {
                        context.lastResult = builtInResult
                    } else if let functionDefinition = context.functionRegistry.resolveFunction(functionName) {
                        let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
                        context.lastResult = result
                    } else {
                        // TRYCALL失败时不抛出错误
                        context.lastResult = .integer(0)
                        context.output.append("[TRYCALL: 函数未找到: \(functionName)]\n")
                    }
                }
            }

        case .TRYJUMP:
            // 尝试跳转
            if statement.arguments.count >= 1 {
                if case .string(let target) = try evaluateExpression(statement.arguments[0]) {
                    if let targetIndex = context.labels[target] {
                        // 设置参数
                        if statement.arguments.count > 1 {
                            for i in 1..<statement.arguments.count {
                                let value = try evaluateExpression(statement.arguments[i])
                                context.setVariable("ARG:\(i-1)", value: value)
                            }
                        }
                        context.callStack.append("\(currentStatementIndex)")
                        currentStatementIndex = targetIndex
                        return
                    } else {
                        // TRYJUMP失败
                        context.output.append("[TRYJUMP: 目标未找到: \(target)]\n")
                    }
                }
            }

        case .TRYGOTO:
            // 尝试GOTO
            if statement.arguments.count >= 1 {
                if case .string(let label) = try evaluateExpression(statement.arguments[0]) {
                    if let targetIndex = context.labels[label] {
                        currentStatementIndex = targetIndex
                        return
                    } else {
                        // TRYGOTO失败
                        context.output.append("[TRYGOTO: 标签未找到: \(label)]\n")
                    }
                }
            }

        case .TRYCALLFORM:
            // 尝试格式化调用
            if statement.arguments.count >= 1 {
                let formatValue = try evaluateExpression(statement.arguments[0])
                let functionName = formatValue.toString()
                let args = statement.arguments.count > 1 ? Array(statement.arguments[1...]) : []
                let evaluatedArgs = try args.map { try evaluateExpression($0) }

                if let builtInResult = try? BuiltInFunctions.execute(name: functionName, arguments: evaluatedArgs, context: context) {
                    context.lastResult = builtInResult
                } else if let functionDefinition = context.functionRegistry.resolveFunction(functionName) {
                    let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
                    context.lastResult = result
                } else {
                    context.lastResult = .integer(0)
                    context.output.append("[TRYCALLFORM: 函数未找到: \(functionName)]\n")
                }
            }

        case .TRYJUMPFORM:
            // 尝试格式化跳转
            if statement.arguments.count >= 1 {
                let formatValue = try evaluateExpression(statement.arguments[0])
                let targetName = formatValue.toString()

                if let targetIndex = context.labels[targetName] {
                    // 设置参数
                    if statement.arguments.count > 1 {
                        for i in 1..<statement.arguments.count {
                            let value = try evaluateExpression(statement.arguments[i])
                            context.setVariable("ARG:\(i-1)", value: value)
                        }
                    }
                    context.callStack.append("\(currentStatementIndex)")
                    currentStatementIndex = targetIndex
                    return
                } else {
                    context.output.append("[TRYJUMPFORM: 目标未找到: \(targetName)]\n")
                }
            }

        case .TRYGOTOFORM:
            // 尝试格式化GOTO
            if statement.arguments.count >= 1 {
                let formatValue = try evaluateExpression(statement.arguments[0])
                let labelName = formatValue.toString()

                if let targetIndex = context.labels[labelName] {
                    currentStatementIndex = targetIndex
                    return
                } else {
                    context.output.append("[TRYGOTOFORM: 标签未找到: \(labelName)]\n")
                }
            }

        case .TRYCCALL:
            // 带捕获调用
            if statement.arguments.count >= 2 {
                if case .string(let functionName) = try evaluateExpression(statement.arguments[0]),
                   case .string(let catchLabel) = try evaluateExpression(statement.arguments[1]) {
                    let args = statement.arguments.count > 2 ? Array(statement.arguments[2...]) : []
                    let evaluatedArgs = try args.map { try evaluateExpression($0) }

                    do {
                        if let builtInResult = try? BuiltInFunctions.execute(name: functionName, arguments: evaluatedArgs, context: context) {
                            context.lastResult = builtInResult
                        } else if let functionDefinition = context.functionRegistry.resolveFunction(functionName) {
                            let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
                            context.lastResult = result
                        } else {
                            throw EmueraError.functionNotFound(name: functionName)
                        }
                    } catch {
                        if let targetIndex = context.labels[catchLabel] {
                            context.currentCatchLabel = catchLabel
                            context.shouldCatch = true
                            currentStatementIndex = targetIndex
                            return
                        }
                    }
                }
            }

        case .TRYCJUMP:
            // 带捕获跳转
            if statement.arguments.count >= 2 {
                if case .string(let target) = try evaluateExpression(statement.arguments[0]),
                   case .string(let catchLabel) = try evaluateExpression(statement.arguments[1]) {
                    do {
                        if let targetIndex = context.labels[target] {
                            // 设置参数
                            if statement.arguments.count > 2 {
                                for i in 2..<statement.arguments.count {
                                    let value = try evaluateExpression(statement.arguments[i])
                                    context.setVariable("ARG:\(i-2)", value: value)
                                }
                            }
                            context.callStack.append("\(currentStatementIndex)")
                            currentStatementIndex = targetIndex
                            return
                        } else {
                            throw EmueraError.runtimeError(message: "标签未找到: \(target)", position: nil)
                        }
                    } catch {
                        if let targetIndex = context.labels[catchLabel] {
                            context.currentCatchLabel = catchLabel
                            context.shouldCatch = true
                            currentStatementIndex = targetIndex
                            return
                        }
                    }
                }
            }

        case .TRYCGOTO:
            // 带捕获GOTO
            if statement.arguments.count >= 2 {
                if case .string(let label) = try evaluateExpression(statement.arguments[0]),
                   case .string(let catchLabel) = try evaluateExpression(statement.arguments[1]) {
                    do {
                        if let targetIndex = context.labels[label] {
                            currentStatementIndex = targetIndex
                            return
                        } else {
                            throw EmueraError.runtimeError(message: "标签未找到: \(label)", position: nil)
                        }
                    } catch {
                        if let targetIndex = context.labels[catchLabel] {
                            context.currentCatchLabel = catchLabel
                            context.shouldCatch = true
                            currentStatementIndex = targetIndex
                            return
                        }
                    }
                }
            }

        case .ENDCATCH:
            // 结束捕获
            context.currentCatchLabel = nil
            context.shouldCatch = false
            context.output.append("[ENDCATCH: 捕获结束]\n")



        // MARK: - 数据操作命令 (15个)

        case .ADDCHARA:
            // 添加角色 - 由visitAddCharaStatement处理
            context.output.append("[ADDCHARA: 添加角色]\n")

        case .ADDVOIDCHARA:
            // 添加空角色
            if let varData = context.varData {
                let manager = CharacterManager(variableData: varData)
                let character = manager.addCharacter(id: nil, name: "空角色")
                context.lastResult = .integer(Int64(character.id))
                context.output.append("[ADDVOIDCHARA: 添加空角色 ID=\(character.id)]\n")
            }


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
            // 替换字符串中的变量引用 %变量名%
            let substituted = replaceVariablesInString(value)
            // 替换字符串中的参数引用 {参数名}
            let final = replaceParametersInString(substituted)
            return .string(final)

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
        let arrayValue = context.variables[base] ?? .array([])

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
            // 也替换参数引用 {参数名}
            let finalValue = replaceParametersInString(value.description)
            results.append(finalValue)
        }
        return results
    }

    /// 替换字符串中的变量引用 %变量名%
    private func replaceVariablesInString(_ input: String) -> String {
        var result = input
        let pattern = "%([A-Za-z_][A-Za-z0-9_]*)%"

        // 使用正则表达式查找所有变量引用
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return input
        }

        let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))

        // 从后往前替换，避免索引偏移
        for match in matches.reversed() {
            if let range = Range(match.range(at: 1), in: input) {
                let varName = String(input[range])
                if let value = context.variables[varName] {
                    let replacement = value.toString()
                    if let swiftRange = Range(match.range, in: input) {
                        result.replaceSubrange(swiftRange, with: replacement)
                    }
                }
            }
        }

        return result
    }

    /// 替换字符串中的参数引用 {参数名}
    private func replaceParametersInString(_ input: String) -> String {
        var result = input
        let pattern = "\\{([A-Za-z_][A-Za-z0-9_]*)\\}"

        // 使用正则表达式查找所有参数引用
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return input
        }

        let matches = regex.matches(in: input, range: NSRange(input.startIndex..., in: input))

        // 从后往前替换，避免索引偏移
        for match in matches.reversed() {
            if let range = Range(match.range(at: 1), in: input) {
                let paramName = String(input[range])
                // 先尝试从currentParameters获取，如果没有则从variables获取
                var value = context.currentParameters[paramName]
                if value == nil {
                    value = context.variables[paramName]
                }
                if let finalValue = value {
                    let replacement = finalValue.toString()
                    if let swiftRange = Range(match.range, in: input) {
                        result.replaceSubrange(swiftRange, with: replacement)
                    }
                }
            }
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
        // 保存当前上下文
        let oldContext = self.context

        // 创建新的执行上下文
        let newContext = ExecutionContext()
        newContext.callStack = oldContext.callStack
        newContext.labels = oldContext.labels  // 继承标签
        newContext.varData = oldContext.varData  // 继承变量数据
        newContext.console = oldContext.console  // 继承控制台
        newContext.variables = oldContext.variables  // 继承全局变量
        // 关键：继承函数注册表，这样嵌套函数调用才能工作
        newContext.functionRegistry = oldContext.functionRegistry

        // 设置参数
        for (index, param) in definition.parameters.enumerated() {
            if index < arguments.count {
                let argValue = arguments[index]
                newContext.variables[param.name] = argValue
                newContext.currentParameters[param.name] = argValue
            }
        }

        // 切换到新上下文
        self.context = newContext

        // 执行函数体
        let bodyStatements = definition.body
        var result: VariableValue = .integer(0)  // 默认返回0

        for stmt in bodyStatements {
            try stmt.accept(visitor: self)

            // 检查是否有返回值
            if let returnValue = self.context.returnValue {
                result = returnValue
                self.context.returnValue = nil  // 清除返回值
                break
            }

            // 检查是否需要退出
            if self.context.shouldQuit {
                break
            }
        }

        // 恢复旧上下文
        self.context = oldContext

        return result
    }

    /// 调试：打印当前执行状态（仅在需要时启用）
    private func debugPrint(_ message: String) {
        // print("[DEBUG] \(message)")  // 调试时取消注释
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

    /// 访问TRYCALLFORM语句
    public func visitTryCallFormStatement(_ statement: TryCallFormStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        do {
            // 评估格式表达式
            let formatValue = try evaluateExpression(statement.formatExpression)
            let functionName = formatValue.toString()

            // 评估参数
            let evaluatedArgs = try statement.arguments.map { try evaluateExpression($0) }

            // 首先尝试内置函数
            if let builtInResult = try? BuiltInFunctions.execute(
                name: functionName,
                arguments: evaluatedArgs,
                context: context
            ) {
                context.lastResult = builtInResult
            } else if let functionDefinition = context.functionRegistry.resolveFunction(functionName) {
                // 执行用户定义函数
                let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
                context.lastResult = result
            } else {
                // 函数未找到，抛出异常
                throw EmueraError.functionNotFound(name: functionName)
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

    /// 访问TRYCGOTOFORM语句
    public func visitTryGotoFormStatement(_ statement: TryGotoFormStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        do {
            // 评估格式表达式
            let formatValue = try evaluateExpression(statement.formatExpression)
            var labelName = formatValue.toString()

            // 如果标签名不以@开头，自动添加@前缀
            if !labelName.hasPrefix("@") {
                labelName = "@" + labelName
            }

            // 尝试跳转
            if let targetIndex = context.labels[labelName] {
                currentStatementIndex = targetIndex
            } else {
                throw EmueraError.runtimeError(
                    message: "标签未找到: \(labelName)",
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

    /// 访问TRYCJUMPFORM语句
    public func visitTryJumpFormStatement(_ statement: TryJumpFormStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        do {
            // 评估格式表达式
            let formatValue = try evaluateExpression(statement.formatExpression)
            var targetName = formatValue.toString()

            // 评估参数
            let evaluatedArgs = try statement.arguments.map { try evaluateExpression($0) }

            // 查找目标（函数或标签）
            if let functionDefinition = context.functionRegistry.resolveFunction(targetName) {
                // 执行用户定义函数
                let result = try executeUserFunction(functionDefinition, arguments: evaluatedArgs)
                context.lastResult = result
            } else {
                // 如果不是函数，尝试作为标签查找，添加@前缀
                if !targetName.hasPrefix("@") {
                    targetName = "@" + targetName
                }
                if let targetIndex = context.labels[targetName] {
                    // 设置参数（如果有）
                    if !evaluatedArgs.isEmpty {
                        for (index, arg) in evaluatedArgs.enumerated() {
                            context.setVariable("ARG:\(index)", value: arg)
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
                    // 目标未找到，抛出异常
                    throw EmueraError.runtimeError(
                        message: "函数或标签未找到: \(targetName)",
                        position: statement.position
                    )
                }
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

    /// 访问TRYCALLLIST语句
    public func visitTryCallListStatement(_ statement: TryCallListStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        var hasError = false
        var hasSuccess = false

        // 遍历所有函数
        for funcName in statement.functionNames {
            do {
                // 首先尝试内置函数
                if let builtInResult = try? BuiltInFunctions.execute(
                    name: funcName,
                    arguments: [],
                    context: context
                ) {
                    context.lastResult = builtInResult
                    hasSuccess = true
                } else if let functionDefinition = context.functionRegistry.resolveFunction(funcName) {
                    // 执行用户定义函数
                    let result = try executeUserFunction(functionDefinition, arguments: [])
                    context.lastResult = result
                    hasSuccess = true
                } else {
                    // 函数未找到，抛出异常
                    throw EmueraError.functionNotFound(name: funcName)
                }
            } catch {
                // 记录错误但继续执行下一个函数
                hasError = true
                continue
            }
        }

        // 只有当所有函数都失败（没有成功）且有CATCH标签时，才跳转到CATCH
        if hasError && !hasSuccess {
            if let catchLabel = statement.catchLabel,
               let targetIndex = context.labels[catchLabel] {
                // 设置异常处理上下文
                context.currentCatchLabel = catchLabel
                context.shouldCatch = true

                // 跳转到CATCH标签
                currentStatementIndex = targetIndex
            }
        }

        // 恢复之前的异常处理上下文
        context.currentCatchLabel = oldCatchLabel
        context.shouldCatch = oldShouldCatch
    }

    /// 访问TRYJUMPLIST语句
    public func visitTryJumpListStatement(_ statement: TryJumpListStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch
        let originalStatementIndex = currentStatementIndex  // 保存TRYJUMPLIST的位置

        var hasError = false
        var hasSuccess = false

        // 遍历所有目标
        for targetName in statement.targets {
            do {
                // 尝试跳转到标签 - 添加@前缀
                var labelName = targetName
                if !labelName.hasPrefix("@") {
                    labelName = "@" + labelName
                }
                if let targetIndex = context.labels[labelName] {
                    // 保存当前调用栈
                    context.callStack.append("\(currentStatementIndex)")
                    currentStatementIndex = targetIndex

                    // 执行目标标签
                    while currentStatementIndex < statements.count {
                        let stmt = statements[currentStatementIndex]
                        try stmt.accept(visitor: self)

                        if context.returnValue != nil {
                            // 获取返回地址
                            context.callStack.removeLast()
                            context.returnValue = nil  // 清除返回值，继续下一个标签
                            hasSuccess = true
                            break  // 退出while循环，继续for循环的下一个标签
                        }

                        if context.shouldQuit {
                            context.callStack.removeLast()
                            hasSuccess = true
                            // QUIT应该结束整个执行
                            return
                        }

                        currentStatementIndex += 1
                    }

                    // 恢复调用栈（如果还没有恢复）
                    if !context.callStack.isEmpty {
                        let last = context.callStack.last
                        if let savedIndex = Int(last ?? ""), savedIndex == originalStatementIndex {
                            context.callStack.removeLast()
                        }
                    }
                } else {
                    // 标签未找到，抛出异常
                    throw EmueraError.runtimeError(
                        message: "标签未找到: \(targetName)",
                        position: statement.position
                    )
                }
            } catch {
                // 记录错误但继续执行下一个标签
                hasError = true
                continue
            }
        }

        // 只有当所有标签都失败（没有成功）且有CATCH标签时，才跳转到CATCH
        if hasError && !hasSuccess {
            if let catchLabel = statement.catchLabel,
               let targetIndex = context.labels[catchLabel] {
                // 设置异常处理上下文
                context.currentCatchLabel = catchLabel
                context.shouldCatch = true

                // 跳转到CATCH标签
                currentStatementIndex = targetIndex
            }
        } else {
            // 有成功的标签或全部成功，恢复到TRYJUMPLIST之后
            // execute主循环会自动+1，所以设置为原始位置
            currentStatementIndex = originalStatementIndex
        }

        // 恢复之前的异常处理上下文
        context.currentCatchLabel = oldCatchLabel
        context.shouldCatch = oldShouldCatch
    }

    /// 访问TRYGOTOLIST语句
    public func visitTryGotoListStatement(_ statement: TryGotoListStatement) throws {
        // 保存当前的异常处理上下文
        let oldCatchLabel = context.currentCatchLabel
        let oldShouldCatch = context.shouldCatch

        var hasError = false
        var executed = false

        // 遍历所有标签
        for labelName in statement.labels {
            do {
                // 尝试跳转到标签 - 添加@前缀
                var name = labelName
                if !name.hasPrefix("@") {
                    name = "@" + name
                }
                if let targetIndex = context.labels[name] {
                    currentStatementIndex = targetIndex
                    executed = true
                    break  // 成功跳转，停止遍历
                } else {
                    // 标签未找到，抛出异常
                    throw EmueraError.runtimeError(
                        message: "标签未找到: \(labelName)",
                        position: statement.position
                    )
                }
            } catch {
                // 记录错误但继续尝试下一个标签
                hasError = true
                continue
            }
        }

        // 如果所有标签都失败且有CATCH标签，跳转到CATCH
        if hasError && !executed {
            if let catchLabel = statement.catchLabel,
               let targetIndex = context.labels[catchLabel] {
                // 设置异常处理上下文
                context.currentCatchLabel = catchLabel
                context.shouldCatch = true

                // 跳转到CATCH标签
                currentStatementIndex = targetIndex
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

    /// 访问SAVELIST语句 - 列出所有存档文件
    public func visitSaveListStatement(_ statement: SaveListStatement) throws {
        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法列出存档", position: nil)
        }

        // 获取存档列表
        let saveList = varData.getSaveFileList()

        if saveList.isEmpty {
            context.output.append("[没有找到存档文件]\\n")
            context.lastResult = .integer(0)
        } else {
            context.output.append("[存档列表]\\n")
            for (filename, metadata) in saveList.sorted(by: { $0.key < $1.key }) {
                var line = "  \(filename)"
                if let modified = metadata["modified"] as? String {
                    line += " - \(modified)"
                }
                if let size = metadata["size"] as? Int {
                    line += " - \(size) bytes"
                }
                context.output.append(line + "\\n")
            }
            context.lastResult = .integer(Int64(saveList.count))
        }
    }

    /// 访问SAVEEXISTS语句 - 检查存档是否存在
    public func visitSaveExistsStatement(_ statement: SaveExistsStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法检查存档", position: nil)
        }

        // 检查存档是否存在
        let exists = varData.saveFileExists(filename)

        if exists {
            context.output.append("[存档存在: \(filename)]\\n")
            context.lastResult = .integer(1)
        } else {
            context.output.append("[存档不存在: \(filename)]\\n")
            context.lastResult = .integer(0)
        }
    }

    // MARK: - SAVE/LOAD高级功能 (Phase 3 P5)

    /// 访问AUTOSAVE语句 - 自动保存游戏状态
    public func visitAutoSaveStatement(_ statement: AutoSaveStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法自动保存", position: nil)
        }

        do {
            // 同步context到VariableData（确保最新数据）
            syncContextToVariableData(varData)

            // 执行自动保存
            let success = try varData.autoSave(filename)

            if success {
                context.output.append("[自动保存完成: \(filename)]\n")
                context.lastResult = .integer(1)  // 成功
            } else {
                context.output.append("[自动保存失败]\n")
                context.lastResult = .integer(0)  // 失败
            }

        } catch {
            context.output.append("[自动保存异常: \(error)]\n")
            context.lastResult = .integer(0)  // 失败
            throw error
        }
    }

    /// 访问SAVEINFO语句 - 显示存档详细信息
    public func visitSaveInfoStatement(_ statement: SaveInfoStatement) throws {
        // 评估文件名
        let filenameValue = try evaluateExpression(statement.filename)
        guard case .string(let filename) = filenameValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化，无法获取存档信息", position: nil)
        }

        // 获取存档信息
        let info = varData.getSaveFileInfo(filename)

        if info.isEmpty {
            context.output.append("[存档不存在: \(filename)]\n")
            context.lastResult = .integer(0)
        } else {
            context.output.append("[存档信息: \(filename)]\n")

            // 基本文件信息
            if let modified = info["modified"] as? String {
                context.output.append("  修改时间: \(modified)\n")
            }
            if let size = info["size"] as? Int {
                context.output.append("  文件大小: \(size) bytes\n")
            }

            // 版本信息
            if let version = info["version"] as? String {
                context.output.append("  版本: \(version)\n")
            }
            if let saveType = info["saveType"] as? String {
                context.output.append("  保存类型: \(saveType)\n")
            }

            // 变量信息
            if let globalVars = info["globalVars"] as? Int {
                context.output.append("  全局变量: \(globalVars)个\n")
            }
            if let arrays = info["arrays"] as? Int {
                context.output.append("  数组: \(arrays)个\n")
            }
            if let systemVars = info["systemVars"] as? Int {
                context.output.append("  系统变量: \(systemVars)个\n")
            }
            if let characters = info["characters"] as? Int {
                context.output.append("  角色: \(characters)个\n")
            }

            context.lastResult = .integer(1)
        }
    }
}

// MARK: - Phase 4: 数据重置和持久化控制

extension StatementExecutor {
    /// 访问RESETDATA语句 - 重置所有变量
    public func visitResetDataStatement(_ statement: ResetDataStatement) throws {
        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }

        // 重置VariableData
        varData.reset()

        // 同步到ExecutionContext
        syncVariableDataToContext(varData)

        // 重置ExecutionContext的变量字典
        context.variables.removeAll()
        context.variables["RESULT"] = .integer(0)
        context.variables["RESULTS"] = .string("")
        context.variables["COUNT"] = .integer(0)
        context.variables["MASTER"] = .integer(0)
        context.variables["TARGET"] = .integer(0)
        context.variables["ASSI"] = .integer(0)

        context.lastResult = .null
        context.output.append("[所有数据已重置]\n")
    }

    /// 访问RESETGLOBAL语句 - 重置全局变量数组
    public func visitResetGlobalStatement(_ statement: ResetGlobalStatement) throws {
        // 获取VariableData实例
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }

        // 重置VariableData中的全局数组
        varData.resetGlobalArrays()

        // 重置ExecutionContext中的A-Z数组变量
        // A-Z对应0x1E-0x37
        for i in 0x1E...0x37 {
            if let charName = getArrayNameFromBaseValue(i) {
                // 重置为100个0的数组
                context.variables[charName] = .array(Array(repeating: .integer(0), count: 100))
            }
        }

        // 重置其他全局数组变量（如FLAG等）
        let globalArrays = ["FLAG", "RESULT", "SELECTCOM", "ITEM", "TALENT", "ABL", "EXP", "MARK", "PALAM", "SOURCE"]
        for name in globalArrays {
            context.variables[name] = .array(Array(repeating: .integer(0), count: 100))
        }

        context.lastResult = .null
        context.output.append("[全局变量数组已重置]\n")
    }

    /// 访问PERSIST增强语句 - 持久化状态控制
    public func visitPersistEnhancedStatement(_ statement: PersistEnhancedStatement) throws {
        // 设置持久化状态
        context.persistEnabled = statement.enabled

        // 如果有选项参数，可以在这里处理
        if let option = statement.option {
            let optionValue = try evaluateExpression(option)
            let status = statement.enabled ? "ON" : "OFF"
            context.output.append("[持久化状态: \(status) 选项: \(optionValue)]\n")
        } else {
            let status = statement.enabled ? "ON" : "OFF"
            context.output.append("[持久化状态: \(status)]\n")
        }

        context.lastResult = .integer(statement.enabled ? 1 : 0)
    }

    // MARK: - Phase 5: ERH头文件系统访问者方法

    /// 访问函数指令语句（#FUNCTION）
    public func visitFunctionDirectiveStatement(_ statement: FunctionDirectiveStatement) throws {
        // ERH指令在预处理阶段处理，执行阶段通常不需要
        // 这里可以记录调试信息或忽略
        context.lastResult = .null
    }

    /// 访问全局DIM语句（#DIM/#DIMS）
    public func visitGlobalDimStatement(_ statement: GlobalDimStatement) throws {
        // ERH指令在预处理阶段处理，执行阶段通常不需要
        // 这里可以记录调试信息或忽略
        context.lastResult = .null
    }

    /// 访问宏定义语句（#DEFINE）
    public func visitDefineMacroStatement(_ statement: DefineMacroStatement) throws {
        // ERH指令在预处理阶段处理，执行阶段通常不需要
        // 这里可以记录调试信息或忽略
        context.lastResult = .null
    }

    /// 访问包含语句（#INCLUDE）
    public func visitIncludeStatement(_ statement: IncludeStatement) throws {
        // ERH指令在预处理阶段处理，执行阶段通常不需要
        // 这里可以记录调试信息或忽略
        context.lastResult = .null
    }

    /// 访问全局变量语句（#GLOBAL）
    public func visitGlobalVariableStatement(_ statement: GlobalVariableStatement) throws {
        // ERH指令在预处理阶段处理，执行阶段通常不需要
        // 这里可以记录调试信息或忽略
        context.lastResult = .null
    }

    // MARK: - Phase 6: 字符管理系统增强

    /// ADDCHARA - 添加角色
    public func visitAddCharaStatement(_ statement: AddCharaStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let manager = CharacterManager(variableData: varData)

        // 解析ID和名字
        var id: Int? = nil
        var name = "新角色"

        if let idExpr = statement.idExpression {
            let idValue = try evaluateExpression(idExpr)
            if case .integer(let idInt) = idValue {
                id = Int(idInt)
            }
        }

        if let nameExpr = statement.nameExpression {
            let nameValue = try evaluateExpression(nameExpr)
            name = nameValue.toString()
        }

        let character = manager.addCharacter(id: id, name: name)
        context.lastResult = .integer(Int64(character.id))
    }

    /// DELCHARA - 删除角色
    public func visitDelCharaStatement(_ statement: DelCharaStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let manager = CharacterManager(variableData: varData)
        let targetValue = try evaluateExpression(statement.targetExpression)
        guard case .integer(let targetInt) = targetValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        let target = Int(targetInt)

        let success = manager.deleteCharacter(at: target) || manager.deleteCharacterByID(target)
        context.lastResult = .integer(success ? 1 : 0)
    }

    /// SWAPCHARA - 交换角色
    public func visitSwapCharaStatement(_ statement: SwapCharaStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let manager = CharacterManager(variableData: varData)
        let index1Value = try evaluateExpression(statement.index1Expression)
        let index2Value = try evaluateExpression(statement.index2Expression)
        guard case .integer(let idx1) = index1Value,
              case .integer(let idx2) = index2Value else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        let success = manager.swapCharacters(at: Int(idx1), at: Int(idx2))
        context.lastResult = .integer(success ? 1 : 0)
    }

    /// COPYCHARA - 复制角色
    public func visitCopyCharaStatement(_ statement: CopyCharaStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let manager = CharacterManager(variableData: varData)
        let srcValue = try evaluateExpression(statement.srcExpression)
        guard case .integer(let srcIdx) = srcValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        var dstIndex: Int? = nil
        if let dstExpr = statement.dstExpression {
            let dstValue = try evaluateExpression(dstExpr)
            if case .integer(let dstIdx) = dstValue {
                dstIndex = Int(dstIdx)
            }
        }

        if let character = manager.copyCharacter(from: Int(srcIdx), to: dstIndex) {
            context.lastResult = .integer(Int64(character.id))
        } else {
            context.lastResult = .integer(-1)
        }
    }

    /// SORTCHARA - 排序角色
    public func visitSortCharaStatement(_ statement: SortCharaStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let manager = CharacterManager(variableData: varData)
        let keyValue = try evaluateExpression(statement.keyExpression)
        let keyString = keyValue.toString().uppercased()

        // 解析排序键
        let sortKey: SortKey
        switch keyString {
        case "ID":
            sortKey = .id
        case "NAME":
            sortKey = .name
        case "HP", "BASE":
            sortKey = .baseHP
        case "MP":
            sortKey = .baseMP
        case "LEVEL":
            sortKey = .level
        default:
            // 尝试解析为自定义数组索引
            if let colonIndex = keyString.firstIndex(of: ":") {
                let arrayStr = String(keyString[keyString.index(after: colonIndex)...])
                let parts = arrayStr.split(separator: ":")
                if parts.count >= 2,
                   let arrayIdx = Int(parts[0]),
                   let elementIdx = Int(parts[1]) {
                    sortKey = .custom(arrayIndex: arrayIdx, elementIndex: elementIdx)
                } else {
                    sortKey = .id
                }
            } else {
                sortKey = .id
            }
        }

        // 解析排序顺序
        var order: SortOrder = .ascending
        if let orderExpr = statement.orderExpression {
            let orderValue = try evaluateExpression(orderExpr)
            let orderString = orderValue.toString().uppercased()
            if orderString == "DESC" || orderString == "DESCENDING" {
                order = .descending
            }
        }

        manager.sortCharacters(by: sortKey, order: order)
        context.lastResult = .null
    }

    /// FINDCHARA - 查找角色
    public func visitFindCharaStatement(_ statement: FindCharaStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let manager = CharacterManager(variableData: varData)

        // 简化实现：返回第一个角色ID
        if let first = manager.getCharacter(at: 0) {
            context.lastResult = .integer(Int64(first.id))

            // 如果指定了结果变量，设置它
            if let varName = statement.resultVariable {
                varData.setVariable(varName, value: .integer(Int64(first.id)))
            }
        } else {
            context.lastResult = .integer(-1)
        }
    }

    /// CHARAOPERATE - 角色操作
    public func visitCharaOperateStatement(_ statement: CharaOperateStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let targetValue = try evaluateExpression(statement.targetExpression)
        let operationValue = try evaluateExpression(statement.operationExpression)
        guard case .integer(let targetIdx) = targetValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        let operation = operationValue.toString()
        let value = statement.valueExpression != nil ? try evaluateExpression(statement.valueExpression!).toInt() : 0

        let manager = CharacterManager(variableData: varData)

        // 执行操作
        if let character = manager.getCharacter(at: Int(targetIdx)) {
            switch operation.uppercased() {
            case "ADD":
                if character.dataIntegerArray.count > 0 {
                    for i in 0..<character.dataIntegerArray[0].count {
                        character.dataIntegerArray[0][i] += value
                    }
                }
            case "SET":
                if character.dataIntegerArray.count > 0 {
                    for i in 0..<character.dataIntegerArray[0].count {
                        character.dataIntegerArray[0][i] = value
                    }
                }
            default:
                break
            }
            context.lastResult = .integer(1)
        } else {
            context.lastResult = .integer(0)
        }
    }

    /// CHARAMODIFY - 批量修改
    public func visitCharaModifyStatement(_ statement: CharaModifyStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let targetValue = try evaluateExpression(statement.targetExpression)
        let variableValue = try evaluateExpression(statement.variableExpression)
        let valueValue = try evaluateExpression(statement.valueExpression)
        guard case .integer(let targetIdx) = targetValue,
              case .integer(let value) = valueValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        let variable = variableValue.toString()

        if let character = varData.getCharacter(at: Int(targetIdx)) {
            // 解析变量类型并修改
            // 简化实现：直接修改BASE[0]
            if variable.uppercased() == "BASE" && character.dataIntegerArray.count > 0 {
                if character.dataIntegerArray[0].count > 0 {
                    character.dataIntegerArray[0][0] = value
                }
            }
            context.lastResult = .integer(1)
        } else {
            context.lastResult = .integer(0)
        }
    }

    /// CHARAFILTER - 角色过滤
    public func visitCharaFilterStatement(_ statement: CharaFilterStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let manager = CharacterManager(variableData: varData)

        // 简化实现：返回所有角色ID数组
        let allIDs = (0..<manager.getCharacterCount()).map { VariableValue.integer(Int64($0)) }
        let result = VariableValue.array(allIDs)

        context.lastResult = result

        if let varName = statement.resultVariable {
            varData.setVariable(varName, value: result)
        }
    }

    /// SHOWCHARACARD - 显示角色卡片
    public func visitShowCharaCardStatement(_ statement: ShowCharaCardStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let targetValue = try evaluateExpression(statement.targetExpression)
        guard case .integer(let targetIdx) = targetValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        if let character = varData.getCharacter(at: Int(targetIdx)) {
            // 检查 console 属性是否存在
            guard let console = context.console else {
                throw EmueraError.runtimeError(message: "Console未初始化", position: nil)
            }
            let uiManager = CharacterUIManager(console: console)

            var style: CharacterCardStyle = .compact
            if let styleExpr = statement.styleExpression {
                let styleValue = try evaluateExpression(styleExpr)
                let styleString = styleValue.toString().uppercased()
                switch styleString {
                case "DETAILED": style = .detailed
                case "FULL": style = .full
                default: style = .compact
                }
            }

            uiManager.showCharacterCard(character, style: style)
            context.lastResult = .integer(1)
        } else {
            context.lastResult = .integer(0)
        }
    }

    /// SHOWCHARALIST - 显示角色列表
    public func visitShowCharaListStatement(_ statement: ShowCharaListStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        guard let console = context.console else {
            throw EmueraError.runtimeError(message: "Console未初始化", position: nil)
        }
        let uiManager = CharacterUIManager(console: console)

        var characters: [CharacterData] = []

        if let indicesExpr = statement.indicesExpression {
            // 如果指定了索引，只显示这些
            let indicesValue = try evaluateExpression(indicesExpr)
            // 简化：假设是数组
            if case .array(let array) = indicesValue {
                for id in array {
                    if case .integer(let idx) = id,
                       let char = varData.getCharacter(at: Int(idx)) {
                        characters.append(char)
                    }
                }
            }
        } else {
            // 显示所有
            characters = varData.characters
        }

        uiManager.showCharacterListOverview(characters)
        context.lastResult = .null
    }

    /// SHOWBATTLESTATUS - 显示战斗状态
    public func visitShowBattleStatusStatement(_ statement: ShowBattleStatusStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let targetValue = try evaluateExpression(statement.targetExpression)
        guard case .integer(let targetIdx) = targetValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        if let character = varData.getCharacter(at: Int(targetIdx)) {
            guard let console = context.console else {
                throw EmueraError.runtimeError(message: "Console未初始化", position: nil)
            }
            let uiManager = CharacterUIManager(console: console)
            uiManager.showBattleStatus(character)
            context.lastResult = .integer(1)
        } else {
            context.lastResult = .integer(0)
        }
    }

    /// SHOWPROGRESSBARS - 显示进度条
    public func visitShowProgressBarsStatement(_ statement: ShowProgressBarsStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let targetValue = try evaluateExpression(statement.targetExpression)
        guard case .integer(let targetIdx) = targetValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        _ = try evaluateExpression(statement.barsExpression)  // barsValue 用于兼容性检查

        if let character = varData.getCharacter(at: Int(targetIdx)) {
            guard let console = context.console else {
                throw EmueraError.runtimeError(message: "Console未初始化", position: nil)
            }
            let uiManager = CharacterUIManager(console: console)

            // 简化：创建默认进度条配置
            let bars: [ProgressBarConfig] = [
                ProgressBarConfig(attribute: .hp, maxValue: 5000, label: "HP"),
                ProgressBarConfig(attribute: .mp, maxValue: 2000, label: "MP")
            ]

            uiManager.showProgressBars(character, bars: bars)
            context.lastResult = .integer(1)
        } else {
            context.lastResult = .integer(0)
        }
    }

    /// SHOWCHARATAGS - 显示角色标签
    public func visitShowCharaTagsStatement(_ statement: ShowCharaTagsStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let targetValue = try evaluateExpression(statement.targetExpression)
        guard case .integer(let targetIdx) = targetValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        if let character = varData.getCharacter(at: Int(targetIdx)) {
            guard let console = context.console else {
                throw EmueraError.runtimeError(message: "Console未初始化", position: nil)
            }
            let uiManager = CharacterUIManager(console: console)
            uiManager.showCharacterTags(character)
            context.lastResult = .integer(1)
        } else {
            context.lastResult = .integer(0)
        }
    }

    /// BATCHMODIFY - 批量修改
    public func visitBatchModifyStatement(_ statement: BatchModifyStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let indicesValue = try evaluateExpression(statement.indicesExpression)
        let operationValue = try evaluateExpression(statement.operationExpression)
        let valueValue = try evaluateExpression(statement.valueExpression)
        guard case .integer(let value) = valueValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }

        let manager = CharacterManager(variableData: varData)

        // 解析索引数组
        var indices: [Int] = []
        if case .array(let array) = indicesValue {
            for idx in array {
                if case .integer(let i) = idx {
                    indices.append(Int(i))
                }
            }
        } else {
            // 单个索引
            if case .integer(let idx) = indicesValue {
                indices = [Int(idx)]
            }
        }

        // 解析操作类型
        let operationString = operationValue.toString().uppercased()
        let operation: BatchOperation
        switch operationString {
        case "ADD": operation = .add
        case "SUBTRACT": operation = .subtract
        case "MULTIPLY": operation = .multiply
        case "SET": operation = .set
        default: operation = .add
        }

        let count = manager.batchModify(indices: indices, operation: operation, value: value)
        context.lastResult = .integer(Int64(count))
    }

    /// CHARACOUNT - 获取角色数量
    public func visitCharaCountStatement(_ statement: CharaCountStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let count = varData.characters.count
        context.lastResult = .integer(Int64(count))

        if let varName = statement.resultVariable {
            varData.setVariable(varName, value: .integer(Int64(count)))
        }
    }

    /// CHARAEXISTS - 检查角色是否存在
    public func visitCharaExistsStatement(_ statement: CharaExistsStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }
        let targetValue = try evaluateExpression(statement.targetExpression)
        guard case .integer(let targetIdx) = targetValue else {
            throw EmueraError.typeMismatch(expected: "integer", actual: "other")
        }
        let exists = varData.getCharacter(at: Int(targetIdx)) != nil

        context.lastResult = exists ? .integer(1) : .integer(0)

        if let varName = statement.resultVariable {
            varData.setVariable(varName, value: exists ? .integer(1) : .integer(0))
        }
    }

    // MARK: - 变量赋值命令 (Priority 2)

    /// 访问SET语句 - SET variable = value
    public func visitSetStatement(_ statement: SetStatement) throws {
        guard let varData = context.varData else {
            throw EmueraError.runtimeError(message: "VariableData未初始化", position: nil)
        }

        let value = try evaluateExpression(statement.value)
        varData.setVariable(statement.variable, value: value)
    }

    // MARK: - 条件输出命令 (Priority 2)

    /// 访问SIF语句 - 单行条件输出
    /// 如果条件为真（非0），执行下一行的命令；如果条件为假（0），跳过下一行
    public func visitSifStatement(_ statement: SifStatement) throws {
        // 评估条件表达式
        let conditionValue = try evaluateExpression(statement.condition)

        // 检查条件是否为真（非0）
        if toBool(conditionValue) {
            // 条件为真，执行目标语句
            try statement.targetStatement.accept(visitor: self)
        }
        // 条件为假，什么也不做（跳过目标语句）
    }

    // MARK: - D系列输出命令执行 (Priority 1)

    /// 执行PRINTD系列命令 - 不解析{}和%
    public func visitPrintDStatement(_ statement: PrintDStatement) throws {
        guard let console = context.console else {
            throw EmueraError.runtimeError(message: "Console未初始化", position: statement.position)
        }

        // D系列命令不解析{}和%，直接输出变量值或字符串
        var outputText = ""
        for arg in statement.arguments {
            let value = try evaluateExpression(arg)
            outputText += value.toString()
        }

        // 添加到控制台 - 使用正确的ConsoleLine构造函数
        console.addLine(ConsoleLine(
            type: .print,
            content: outputText,
            attributes: ConsoleAttributes()
        ))

        // 如果需要等待输入，通过lastResult标记
        if statement.waitInput {
            context.lastResult = .string("__WAIT_INPUT__")
        }

        context.lastResult = .integer(1)
    }

    /// 执行PRINTVD/PRINTVL/PRINTVW - 输出变量内容
    public func visitPrintVStatement(_ statement: PrintVStatement) throws {
        guard let console = context.console else {
            throw EmueraError.runtimeError(message: "Console未初始化", position: statement.position)
        }

        // 输出变量的原始值（不进行格式化）
        var outputText = ""
        for arg in statement.arguments {
            let value = try evaluateExpression(arg)
            // 直接输出变量的值，不进行任何格式化
            outputText += value.toString()
        }

        console.addLine(ConsoleLine(
            type: .print,
            content: outputText,
            attributes: ConsoleAttributes()
        ))

        if statement.waitInput {
            context.lastResult = .string("__WAIT_INPUT__")
        }

        context.lastResult = .integer(1)
    }

    /// 执行PRINTSD/PRINTSL/PRINTSW - 输出字符串变量
    public func visitPrintSStatement(_ statement: PrintSStatement) throws {
        guard let console = context.console else {
            throw EmueraError.runtimeError(message: "Console未初始化", position: statement.position)
        }

        // 输出字符串变量内容
        var outputText = ""
        for arg in statement.arguments {
            let value = try evaluateExpression(arg)
            // 确保作为字符串输出
            outputText += value.toString()
        }

        console.addLine(ConsoleLine(
            type: .print,
            content: outputText,
            attributes: ConsoleAttributes()
        ))

        if statement.waitInput {
            context.lastResult = .string("__WAIT_INPUT__")
        }

        context.lastResult = .integer(1)
    }

    /// 执行PRINTFORMD/PRINTFORMDL/PRINTFORMDW - 格式化输出但不解析{}和%
    public func visitPrintFormDStatement(_ statement: PrintFormDStatement) throws {
        guard let console = context.console else {
            throw EmueraError.runtimeError(message: "Console未初始化", position: statement.position)
        }

        // 获取格式化字符串
        let formatValue = try evaluateExpression(statement.format)
        guard case .string(let formatStr) = formatValue else {
            throw EmueraError.typeMismatch(expected: "string", actual: "other")
        }

        // D系列的特殊处理：不解析{}和%，但支持%格式化字符串
        // 处理%格式化符（如%d, %s, %ld, %lld等）
        var result = ""
        var argIndex = 0
        var i = 0

        while i < formatStr.count {
            let charIndex = formatStr.index(formatStr.startIndex, offsetBy: i)
            let char = formatStr[charIndex]

            if char == "%" && i + 1 < formatStr.count {
                // 检查下一个字符
                let nextCharIndex = formatStr.index(after: charIndex)
                let nextChar = formatStr[nextCharIndex]

                if nextChar == "%" {
                    // %% 转义为单个 %
                    result.append("%")
                    i += 2
                    continue
                }

                // 检查是否是格式说明符（d, s, f, l, L 开头的）
                if "dfsSl".contains(nextChar) {
                    // 跳过格式说明符，替换为参数值
                    if argIndex < statement.arguments.count {
                        let argValue = try evaluateExpression(statement.arguments[argIndex])
                        result += argValue.toString()
                        argIndex += 1
                    }

                    // 跳过格式说明符的所有字符
                    i += 2  // 跳过 % 和第一个格式字符
                    var checkIndex = nextCharIndex
                    while i < formatStr.count {
                        checkIndex = formatStr.index(after: checkIndex)
                        if checkIndex >= formatStr.endIndex { break }
                        let checkChar = formatStr[checkIndex]
                        if "dfsSl".contains(checkChar) {
                            i += 1
                        } else {
                            break
                        }
                    }
                    continue
                } else {
                    // 不是支持的格式说明符，保留原样
                    result.append(char)
                    i += 1
                }
            } else {
                result.append(char)
                i += 1
            }
        }

        console.addLine(ConsoleLine(
            type: .print,
            content: result,
            attributes: ConsoleAttributes()
        ))

        if statement.waitInput {
            context.lastResult = .string("__WAIT_INPUT__")
        }

        context.lastResult = .integer(1)
    }

    // MARK: - Priority 4 图形渲染辅助函数

    /// 生成矩形ASCII艺术
    private func generateRectArt(_ width: Int, _ height: Int, _ color: String) -> String {
        let w = max(2, min(width, 50))
        let h = max(2, min(height, 20))
        var result = ""

        // 顶部边框
        result += "┌" + String(repeating: "─", count: w - 2) + "┐\n"

        // 中间部分
        for _ in 1..<(h-1) {
            result += "│" + String(repeating: " ", count: w - 2) + "│\n"
        }

        // 底部边框
        result += "└" + String(repeating: "─", count: w - 2) + "┘\n"

        return result
    }

    /// 生成填充矩形ASCII艺术
    private func generateFilledRectArt(_ width: Int, _ height: Int, _ color: String) -> String {
        let w = max(1, min(width, 50))
        let h = max(1, min(height, 20))
        var result = ""

        // 选择填充字符基于颜色
        let fillChar: Character
        switch color.lowercased() {
        case "red": fillChar = "█"
        case "blue": fillChar = "▓"
        case "green": fillChar = "▒"
        case "yellow": fillChar = "░"
        default: fillChar = "■"
        }

        for _ in 0..<h {
            result += String(repeating: fillChar, count: w) + "\n"
        }

        return result
    }

    /// 生成圆形ASCII艺术
    private func generateCircleArt(_ radius: Int, _ color: String, _ filled: Bool) -> String {
        let r = max(2, min(radius, 15))
        var result = ""

        // 使用简单的圆形算法
        for y in -r...r {
            var line = ""
            for x in -r...r {
                let distance = Double(x * x + y * y).squareRoot()
                if filled {
                    if distance <= Double(r) {
                        line += "●"
                    } else {
                        line += " "
                    }
                } else {
                    if abs(distance - Double(r)) < 1.5 {
                        line += "●"
                    } else {
                        line += " "
                    }
                }
            }
            result += line + "\n"
        }

        return result
    }

    /// 生成线条ASCII艺术
    private func generateLineArt(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) -> String {
        let width = max(abs(x2 - x1), 10)
        let height = max(abs(y2 - y1), 5)

        // 创建画布
        var canvas = Array(repeating: Array(repeating: " ", count: width), count: height)

        // 简单的直线绘制（Bresenham算法简化版）
        let dx = abs(x2 - x1)
        let dy = abs(y2 - y1)
        let sx = x1 < x2 ? 1 : -1
        let sy = y1 < y2 ? 1 : -1
        var err = dx - dy

        var x = x1
        var y = y1

        // 将坐标映射到画布
        let offsetX = min(x1, x2)
        let offsetY = min(y1, y2)

        while true {
            let canvasX = x - offsetX
            let canvasY = y - offsetY
            if canvasX >= 0 && canvasX < width && canvasY >= 0 && canvasY < height {
                canvas[canvasY][canvasX] = "█"
            }

            if x == x2 && y == y2 { break }

            let e2 = 2 * err
            if e2 > -dy {
                err -= dy
                x += sx
            }
            if e2 < dx {
                err += dx
                y += sy
            }
        }

        // 转换为字符串
        return canvas.map { $0.joined() }.joined(separator: "\n") + "\n"
    }

    /// 生成渐变ASCII艺术
    private func generateGradientArt(_ width: Int, _ height: Int, _ color1: String, _ color2: String, _ direction: Int) -> String {
        let w = max(3, min(width, 40))
        let h = max(2, min(height, 15))
        var result = ""

        // 渐变字符集
        let gradientChars = [" ", "░", "▒", "▓", "█"]

        for y in 0..<h {
            for x in 0..<w {
                let progress: Double
                if direction == 0 { // 水平
                    progress = Double(x) / Double(w - 1)
                } else { // 垂直
                    progress = Double(y) / Double(h - 1)
                }

                let index = Int(progress * Double(gradientChars.count - 1))
                result += gradientChars[min(index, gradientChars.count - 1)]
            }
            result += "\n"
        }

        return result
    }
}
