//
//  StatementAST.swift
//  EmueraCore
//
//  语句抽象语法树节点定义
//  支持IF/WHILE/CALL/GOTO等控制流结构
//  Created: 2025-12-19
//

import Foundation

// MARK: - 基础语句节点

/// 语句节点基类
public class StatementNode {
    public let position: ScriptPosition?

    public init(position: ScriptPosition? = nil) {
        self.position = position
    }

    public func accept(visitor: StatementVisitor) throws {
        // Override in subclasses
    }
}

/// 表达式语句 (A = 10, PRINT A, A + B)
public class ExpressionStatement: StatementNode {
    public let expression: ExpressionNode

    public init(expression: ExpressionNode, position: ScriptPosition? = nil) {
        self.expression = expression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitExpressionStatement(self)
    }
}

/// 块语句 (多条语句的集合)
public class BlockStatement: StatementNode {
    public let statements: [StatementNode]

    public init(statements: [StatementNode], position: ScriptPosition? = nil) {
        self.statements = statements
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitBlockStatement(self)
    }
}

// MARK: - 控制流语句

/// IF语句
public class IfStatement: StatementNode {
    public let condition: ExpressionNode
    public let thenBlock: StatementNode
    public let elseBlock: StatementNode?

    public init(condition: ExpressionNode,
                thenBlock: StatementNode,
                elseBlock: StatementNode? = nil,
                position: ScriptPosition? = nil) {
        self.condition = condition
        self.thenBlock = thenBlock
        self.elseBlock = elseBlock
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitIfStatement(self)
    }
}

/// WHILE循环语句
public class WhileStatement: StatementNode {
    public let condition: ExpressionNode
    public let body: StatementNode

    public init(condition: ExpressionNode,
                body: StatementNode,
                position: ScriptPosition? = nil) {
        self.condition = condition
        self.body = body
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitWhileStatement(self)
    }
}

/// FOR循环语句
public class ForStatement: StatementNode {
    public let variable: String
    public let start: ExpressionNode
    public let end: ExpressionNode
    public let step: ExpressionNode?
    public let body: StatementNode

    public init(variable: String,
                start: ExpressionNode,
                end: ExpressionNode,
                step: ExpressionNode? = nil,
                body: StatementNode,
                position: ScriptPosition? = nil) {
        self.variable = variable
        self.start = start
        self.end = end
        self.step = step
        self.body = body
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitForStatement(self)
    }
}

/// DO-LOOP循环语句
/// DO
///     statements
/// LOOP [WHILE condition | UNTIL condition]
public class DoLoopStatement: StatementNode {
    public let body: StatementNode
    public let condition: ExpressionNode?  // WHILE或UNTIL条件
    public let isWhile: Bool?              // true: LOOP WHILE, false: LOOP UNTIL, nil: 无条件

    public init(body: StatementNode,
                condition: ExpressionNode? = nil,
                isWhile: Bool? = nil,
                position: ScriptPosition? = nil) {
        self.body = body
        self.condition = condition
        self.isWhile = isWhile
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitDoLoopStatement(self)
    }
}

/// REPEAT循环语句
/// REPEAT count
///     statements (COUNT available)
/// ENDREPEAT
public class RepeatStatement: StatementNode {
    public let count: ExpressionNode  // 循环次数
    public let body: StatementNode    // 循环体

    public init(count: ExpressionNode,
                body: StatementNode,
                position: ScriptPosition? = nil) {
        self.count = count
        self.body = body
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitRepeatStatement(self)
    }
}

/// SELECTCASE语句
public class SelectCaseStatement: StatementNode {
    public let test: ExpressionNode
    public let cases: [CaseClause]
    public let defaultCase: StatementNode?

    public init(test: ExpressionNode,
                cases: [CaseClause],
                defaultCase: StatementNode? = nil,
                position: ScriptPosition? = nil) {
        self.test = test
        self.cases = cases
        self.defaultCase = defaultCase
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSelectCaseStatement(self)
    }
}

/// CASE子句
public class CaseClause {
    public let values: [ExpressionNode]
    public let body: StatementNode

    public init(values: [ExpressionNode], body: StatementNode) {
        self.values = values
        self.body = body
    }
}

// MARK: - 跳转语句

/// GOTO语句
public class GotoStatement: StatementNode {
    public let label: String

    public init(label: String, position: ScriptPosition? = nil) {
        self.label = label
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitGotoStatement(self)
    }
}

/// CALL语句
public class CallStatement: StatementNode {
    public let target: String
    public let arguments: [ExpressionNode]

    public init(target: String,
                arguments: [ExpressionNode] = [],
                position: ScriptPosition? = nil) {
        self.target = target
        self.arguments = arguments
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitCallStatement(self)
    }
}

/// 函数调用语句 (Phase 2)
public class FunctionCallStatement: StatementNode {
    public let functionName: String
    public let arguments: [ExpressionNode]
    public let tryMode: Bool

    public init(functionName: String,
                arguments: [ExpressionNode] = [],
                tryMode: Bool = false,
                position: ScriptPosition? = nil) {
        self.functionName = functionName
        self.arguments = arguments
        self.tryMode = tryMode
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitFunctionCallStatement(self)
    }
}

/// 函数定义语句 (Phase 2)
public class FunctionDefinitionStatement: StatementNode {
    public let definition: FunctionDefinition

    public init(definition: FunctionDefinition, position: ScriptPosition? = nil) {
        self.definition = definition
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        // 函数定义在解析阶段处理，执行阶段不需要
    }
}

/// 变量声明语句 (Phase 2)
public class VariableDeclarationStatement: StatementNode {
    public let scope: VariableScope
    public let name: String
    public let isArray: Bool
    public let size: ExpressionNode?
    public let initialValue: ExpressionNode?

    public init(scope: VariableScope,
                name: String,
                isArray: Bool = false,
                size: ExpressionNode? = nil,
                initialValue: ExpressionNode? = nil,
                position: ScriptPosition? = nil) {
        self.scope = scope
        self.name = name
        self.isArray = isArray
        self.size = size
        self.initialValue = initialValue
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitVariableDeclarationStatement(self)
    }
}

/// RETURN语句
public class ReturnStatement: StatementNode {
    public let value: ExpressionNode?
    public let isFunctionReturn: Bool  // true: RETURNF, false: RETURN

    public init(value: ExpressionNode? = nil, position: ScriptPosition? = nil, isFunctionReturn: Bool = false) {
        self.value = value
        self.isFunctionReturn = isFunctionReturn
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitReturnStatement(self)
    }
}

/// BREAK语句
public class BreakStatement: StatementNode {
    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitBreakStatement(self)
    }
}

/// CONTINUE语句
public class ContinueStatement: StatementNode {
    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitContinueStatement(self)
    }
}

// MARK: - 标签和命令

/// 标签定义
public class LabelStatement: StatementNode {
    public let name: String

    public init(name: String, position: ScriptPosition? = nil) {
        self.name = name
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitLabelStatement(self)
    }
}

/// 命令语句 (PRINT, PRINTL, WAIT, QUIT等)
public class CommandStatement: StatementNode {
    public let command: String
    public let arguments: [ExpressionNode]

    public init(command: String,
                arguments: [ExpressionNode] = [],
                position: ScriptPosition? = nil) {
        self.command = command
        self.arguments = arguments
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitCommandStatement(self)
    }
}

// MARK: - D系列输出命令 (Phase 7 Priority 1)

/// D系列输出命令 - 不解析{}和%
/// 与普通PRINT的区别: 不进行格式化，直接输出变量值或字符串
public class PrintDStatement: StatementNode {
    public let arguments: [ExpressionNode]
    public let waitInput: Bool
    public let newLine: Bool

    public init(arguments: [ExpressionNode], waitInput: Bool = false, newLine: Bool = false, position: ScriptPosition? = nil) {
        self.arguments = arguments
        self.waitInput = waitInput
        self.newLine = newLine
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitPrintDStatement(self)
    }
}

/// PRINTVD/PRINTVL/PRINTVW - 输出变量内容
public class PrintVStatement: StatementNode {
    public let arguments: [ExpressionNode]
    public let waitInput: Bool
    public let newLine: Bool

    public init(arguments: [ExpressionNode], waitInput: Bool = false, newLine: Bool = false, position: ScriptPosition? = nil) {
        self.arguments = arguments
        self.waitInput = waitInput
        self.newLine = newLine
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitPrintVStatement(self)
    }
}

/// PRINTSD/PRINTSL/PRINTSW - 输出字符串变量
public class PrintSStatement: StatementNode {
    public let arguments: [ExpressionNode]
    public let waitInput: Bool
    public let newLine: Bool

    public init(arguments: [ExpressionNode], waitInput: Bool = false, newLine: Bool = false, position: ScriptPosition? = nil) {
        self.arguments = arguments
        self.waitInput = waitInput
        self.newLine = newLine
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitPrintSStatement(self)
    }
}

/// PRINTFORMD/PRINTFORMDL/PRINTFORMDW - 格式化输出但不解析{}和%
public class PrintFormDStatement: StatementNode {
    public let format: ExpressionNode
    public let arguments: [ExpressionNode]
    public let waitInput: Bool
    public let newLine: Bool

    public init(format: ExpressionNode, arguments: [ExpressionNode], waitInput: Bool = false, newLine: Bool = false, position: ScriptPosition? = nil) {
        self.format = format
        self.arguments = arguments
        self.waitInput = waitInput
        self.newLine = newLine
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitPrintFormDStatement(self)
    }
}

// MARK: - 条件输出命令 (Priority 2)

/// SIF语句 - 单行条件输出
/// SIF 条件 命令
/// 如果条件为真（非0），执行下一行的命令；如果条件为假（0），跳过下一行
public class SifStatement: StatementNode {
    public let condition: ExpressionNode
    public let targetStatement: StatementNode  // 下一行要执行的语句

    public init(condition: ExpressionNode, targetStatement: StatementNode, position: ScriptPosition? = nil) {
        self.condition = condition
        self.targetStatement = targetStatement
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSifStatement(self)
    }
}

// MARK: - 特殊语句

/// RESET语句
public class ResetStatement: StatementNode {
    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitResetStatement(self)
    }
}

/// PERSIST语句
public class PersistStatement: StatementNode {
    public let enabled: Bool

    public init(enabled: Bool, position: ScriptPosition? = nil) {
        self.enabled = enabled
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitPersistStatement(self)
    }
}

// MARK: - TRY/CATCH异常处理 (Phase 3)

/// TRY/CATCH异常处理语句
/// TRY
///   statements
/// CATCH
///   statements
/// ENDTRY
public class TryCatchStatement: StatementNode {
    public let tryBlock: StatementNode
    public let catchBlock: StatementNode?
    public let catchLabel: String?  // CATCH标签，用于TRYCALL等

    public init(tryBlock: StatementNode,
                catchBlock: StatementNode? = nil,
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.tryBlock = tryBlock
        self.catchBlock = catchBlock
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryCatchStatement(self)
    }
}

/// TRYCALL语句 - 带异常处理的函数调用
public class TryCallStatement: StatementNode {
    public let functionName: String
    public let arguments: [ExpressionNode]
    public let catchLabel: String?  // 异常时跳转的标签

    public init(functionName: String,
                arguments: [ExpressionNode] = [],
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.functionName = functionName
        self.arguments = arguments
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryCallStatement(self)
    }
}

/// TRYJUMP语句 - 带异常处理的跳转
public class TryJumpStatement: StatementNode {
    public let target: String
    public let arguments: [ExpressionNode]
    public let catchLabel: String?

    public init(target: String,
                arguments: [ExpressionNode] = [],
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.target = target
        self.arguments = arguments
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryJumpStatement(self)
    }
}

/// TRYGOTO语句 - 带异常处理的GOTO
public class TryGotoStatement: StatementNode {
    public let label: String
    public let catchLabel: String?

    public init(label: String,
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.label = label
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryGotoStatement(self)
    }
}

/// 异常处理结果 - 用于在执行时传递异常信息
public struct ExceptionContext {
    public let error: EmueraError
    public let catchLabel: String
}

// MARK: - TRYC系列异常处理扩展 (Priority 1)

/// TRYCCALLFORM语句 - 格式化函数调用
/// TRYCCALLFORM "FUNCTION_%A%", arg1, arg2... CATCH @label
public class TryCallFormStatement: StatementNode {
    public let formatExpression: ExpressionNode
    public let arguments: [ExpressionNode]
    public let catchLabel: String?

    public init(formatExpression: ExpressionNode,
                arguments: [ExpressionNode] = [],
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.formatExpression = formatExpression
        self.arguments = arguments
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryCallFormStatement(self)
    }
}

/// TRYCGOTOFORM语句 - 格式化跳转
/// TRYCGOTOFORM "LABEL_%A%" CATCH @label
public class TryGotoFormStatement: StatementNode {
    public let formatExpression: ExpressionNode
    public let catchLabel: String?

    public init(formatExpression: ExpressionNode,
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.formatExpression = formatExpression
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryGotoFormStatement(self)
    }
}

/// TRYCJUMPFORM语句 - 格式化JUMP
/// TRYCJUMPFORM "LABEL_%A%", arg1, arg2... CATCH @label
public class TryJumpFormStatement: StatementNode {
    public let formatExpression: ExpressionNode
    public let arguments: [ExpressionNode]
    public let catchLabel: String?

    public init(formatExpression: ExpressionNode,
                arguments: [ExpressionNode] = [],
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.formatExpression = formatExpression
        self.arguments = arguments
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryJumpFormStatement(self)
    }
}

/// TRYCALLLIST语句 - 函数调用列表
/// TRYCALLLIST func1, func2, func3 CATCH @label
public class TryCallListStatement: StatementNode {
    public let functionNames: [String]
    public let arguments: [ExpressionNode]
    public let catchLabel: String?

    public init(functionNames: [String],
                arguments: [ExpressionNode] = [],
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.functionNames = functionNames
        self.arguments = arguments
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryCallListStatement(self)
    }
}

/// TRYJUMPLIST语句 - JUMP列表
/// TRYJUMPLIST label1, label2, label3 CATCH @label
public class TryJumpListStatement: StatementNode {
    public let targets: [String]
    public let arguments: [ExpressionNode]
    public let catchLabel: String?

    public init(targets: [String],
                arguments: [ExpressionNode] = [],
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.targets = targets
        self.arguments = arguments
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryJumpListStatement(self)
    }
}

/// TRYGOTOLIST语句 - GOTO列表
/// TRYGOTOLIST label1, label2, label3 CATCH @label
public class TryGotoListStatement: StatementNode {
    public let labels: [String]
    public let catchLabel: String?

    public init(labels: [String],
                catchLabel: String? = nil,
                position: ScriptPosition? = nil) {
        self.labels = labels
        self.catchLabel = catchLabel
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitTryGotoListStatement(self)
    }
}

// MARK: - PRINTDATA/DATALIST (Phase 3)

/// PRINTDATA语句 - 随机选择一个DATALIST块执行
/// PRINTDATA
///     DATALIST
///         PRINT "text1"
///     ENDLIST
///     DATALIST
///         PRINT "text2"
///     ENDLIST
/// ENDDATA
public class PrintDataStatement: StatementNode {
    public let dataLists: [DataListClause]

    public init(dataLists: [DataListClause], position: ScriptPosition? = nil) {
        self.dataLists = dataLists
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitPrintDataStatement(self)
    }
}

/// DATALIST子句 - 包含一组要执行的语句
public class DataListClause {
    public let body: StatementNode

    public init(body: StatementNode) {
        self.body = body
    }
}

// MARK: - SAVE/LOAD数据持久化 (Phase 3 P1)

/// SAVEDATA语句 - 保存变量到文件
/// SAVEDATA filename
/// SAVEDATA filename, var1, var2, ...
public class SaveDataStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式
    public let variables: [ExpressionNode]  // 要保存的变量列表（可选，为空则保存所有）

    public init(filename: ExpressionNode, variables: [ExpressionNode] = [], position: ScriptPosition? = nil) {
        self.filename = filename
        self.variables = variables
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSaveDataStatement(self)
    }
}

/// LOADDATA语句 - 从文件加载变量
/// LOADDATA filename
/// LOADDATA filename, var1, var2, ...
public class LoadDataStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式
    public let variables: [ExpressionNode]  // 要加载的变量列表（可选，为空则加载所有）

    public init(filename: ExpressionNode, variables: [ExpressionNode] = [], position: ScriptPosition? = nil) {
        self.filename = filename
        self.variables = variables
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitLoadDataStatement(self)
    }
}

/// DELDATA语句 - 删除存档文件
/// DELDATA filename
public class DelDataStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式

    public init(filename: ExpressionNode, position: ScriptPosition? = nil) {
        self.filename = filename
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitDelDataStatement(self)
    }
}

/// SAVECHARA语句 - 保存角色数据到文件
/// SAVECHARA filename, charaIndex
public class SaveCharaStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式
    public let charaIndex: ExpressionNode  // 角色索引表达式

    public init(filename: ExpressionNode, charaIndex: ExpressionNode, position: ScriptPosition? = nil) {
        self.filename = filename
        self.charaIndex = charaIndex
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSaveCharaStatement(self)
    }
}

/// LOADCHARA语句 - 从文件加载角色数据
/// LOADCHARA filename, charaIndex
public class LoadCharaStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式
    public let charaIndex: ExpressionNode  // 角色索引表达式

    public init(filename: ExpressionNode, charaIndex: ExpressionNode, position: ScriptPosition? = nil) {
        self.filename = filename
        self.charaIndex = charaIndex
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitLoadCharaStatement(self)
    }
}

/// SAVEGAME语句 - 保存完整游戏状态到文件
/// SAVEGAME filename
public class SaveGameStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式

    public init(filename: ExpressionNode, position: ScriptPosition? = nil) {
        self.filename = filename
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSaveGameStatement(self)
    }
}

/// LOADGAME语句 - 从文件加载完整游戏状态
/// LOADGAME filename
public class LoadGameStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式

    public init(filename: ExpressionNode, position: ScriptPosition? = nil) {
        self.filename = filename
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitLoadGameStatement(self)
    }
}

/// SAVELIST语句 - 列出所有存档文件
/// SAVELIST
public class SaveListStatement: StatementNode {
    public override init(position: ScriptPosition? = nil) {
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSaveListStatement(self)
    }
}

/// SAVEEXISTS语句 - 检查存档是否存在
/// SAVEEXISTS filename
public class SaveExistsStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式

    public init(filename: ExpressionNode, position: ScriptPosition? = nil) {
        self.filename = filename
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSaveExistsStatement(self)
    }
}

/// AUTOSAVE语句 - 自动保存游戏状态
/// AUTOSAVE filename
public class AutoSaveStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式

    public init(filename: ExpressionNode, position: ScriptPosition? = nil) {
        self.filename = filename
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitAutoSaveStatement(self)
    }
}

/// SAVEINFO语句 - 显示存档详细信息
/// SAVEINFO filename
public class SaveInfoStatement: StatementNode {
    public let filename: ExpressionNode  // 文件名表达式

    public init(filename: ExpressionNode, position: ScriptPosition? = nil) {
        self.filename = filename
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSaveInfoStatement(self)
    }
}

/// RESETDATA - 重置所有变量
public class ResetDataStatement: StatementNode {
    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitResetDataStatement(self)
    }
}

/// RESETGLOBAL - 重置全局变量数组
public class ResetGlobalStatement: StatementNode {
    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitResetGlobalStatement(self)
    }
}

/// PERSIST - 持久化状态控制
public class PersistEnhancedStatement: StatementNode {
    public let enabled: Bool
    public let option: ExpressionNode?  // 可选的选项参数

    public init(enabled: Bool, option: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.enabled = enabled
        self.option = option
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitPersistEnhancedStatement(self)
    }
}

// MARK: - Phase 5: ERH头文件系统

/// #FUNCTION指令定义语句
public class FunctionDirectiveStatement: StatementNode {
    public let name: String
    public let parameters: [FunctionParameter]
    public let returnType: VariableType
    public let body: [StatementNode]

    public init(name: String, parameters: [FunctionParameter], returnType: VariableType, body: [StatementNode], position: ScriptPosition? = nil) {
        self.name = name
        self.parameters = parameters
        self.returnType = returnType
        self.body = body
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitFunctionDirectiveStatement(self)
    }
}

/// #DIM/#DIMS全局变量声明语句
public class GlobalDimStatement: StatementNode {
    public let name: String
    public let type: VariableType
    public let isArray: Bool
    public let size: ExpressionNode?

    public init(name: String, type: VariableType, isArray: Bool = false, size: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.name = name
        self.type = type
        self.isArray = isArray
        self.size = size
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitGlobalDimStatement(self)
    }
}

/// #DEFINE宏定义语句
public class DefineMacroStatement: StatementNode {
    public let name: String
    public let body: String
    public let parameters: [String]

    public init(name: String, body: String, parameters: [String] = [], position: ScriptPosition? = nil) {
        self.name = name
        self.body = body
        self.parameters = parameters
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitDefineMacroStatement(self)
    }
}

/// #INCLUDE头文件包含语句
public class IncludeStatement: StatementNode {
    public let path: String

    public init(path: String, position: ScriptPosition? = nil) {
        self.path = path
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitIncludeStatement(self)
    }
}

/// #GLOBAL全局变量声明语句
public class GlobalVariableStatement: StatementNode {
    public let name: String
    public let isArray: Bool
    public let size: ExpressionNode?

    public init(name: String, isArray: Bool = false, size: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.name = name
        self.isArray = isArray
        self.size = size
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitGlobalVariableStatement(self)
    }
}

// MARK: - Phase 6: 字符管理系统增强语句

/// ADDCHARA - 添加角色语句
public class AddCharaStatement: StatementNode {
    public let idExpression: ExpressionNode?
    public let nameExpression: ExpressionNode?

    public init(idExpression: ExpressionNode? = nil, nameExpression: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.idExpression = idExpression
        self.nameExpression = nameExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitAddCharaStatement(self)
    }
}

/// DELCHARA - 删除角色语句
public class DelCharaStatement: StatementNode {
    public let targetExpression: ExpressionNode

    public init(targetExpression: ExpressionNode, position: ScriptPosition? = nil) {
        self.targetExpression = targetExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitDelCharaStatement(self)
    }
}

/// SWAPCHARA - 交换角色语句
public class SwapCharaStatement: StatementNode {
    public let index1Expression: ExpressionNode
    public let index2Expression: ExpressionNode

    public init(index1Expression: ExpressionNode, index2Expression: ExpressionNode, position: ScriptPosition? = nil) {
        self.index1Expression = index1Expression
        self.index2Expression = index2Expression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSwapCharaStatement(self)
    }
}

/// COPYCHARA - 复制角色语句
public class CopyCharaStatement: StatementNode {
    public let srcExpression: ExpressionNode
    public let dstExpression: ExpressionNode?

    public init(srcExpression: ExpressionNode, dstExpression: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.srcExpression = srcExpression
        self.dstExpression = dstExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitCopyCharaStatement(self)
    }
}

/// SORTCHARA - 排序角色语句
public class SortCharaStatement: StatementNode {
    public let keyExpression: ExpressionNode
    public let orderExpression: ExpressionNode?

    public init(keyExpression: ExpressionNode, orderExpression: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.keyExpression = keyExpression
        self.orderExpression = orderExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSortCharaStatement(self)
    }
}

/// FINDCHARA - 查找角色语句
public class FindCharaStatement: StatementNode {
    public let conditionExpression: ExpressionNode
    public let resultVariable: String?

    public init(conditionExpression: ExpressionNode, resultVariable: String? = nil, position: ScriptPosition? = nil) {
        self.conditionExpression = conditionExpression
        self.resultVariable = resultVariable
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitFindCharaStatement(self)
    }
}

/// CHARAOPERATE - 角色操作语句
public class CharaOperateStatement: StatementNode {
    public let targetExpression: ExpressionNode
    public let operationExpression: ExpressionNode
    public let valueExpression: ExpressionNode?

    public init(targetExpression: ExpressionNode, operationExpression: ExpressionNode, valueExpression: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.targetExpression = targetExpression
        self.operationExpression = operationExpression
        self.valueExpression = valueExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitCharaOperateStatement(self)
    }
}

/// CHARAMODIFY - 批量修改角色语句
public class CharaModifyStatement: StatementNode {
    public let targetExpression: ExpressionNode
    public let variableExpression: ExpressionNode
    public let valueExpression: ExpressionNode
    public let indicesExpression: ExpressionNode?

    public init(targetExpression: ExpressionNode, variableExpression: ExpressionNode, valueExpression: ExpressionNode, indicesExpression: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.targetExpression = targetExpression
        self.variableExpression = variableExpression
        self.valueExpression = valueExpression
        self.indicesExpression = indicesExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitCharaModifyStatement(self)
    }
}

/// CHARAFILTER - 角色过滤语句
public class CharaFilterStatement: StatementNode {
    public let conditionExpression: ExpressionNode
    public let resultVariable: String?

    public init(conditionExpression: ExpressionNode, resultVariable: String? = nil, position: ScriptPosition? = nil) {
        self.conditionExpression = conditionExpression
        self.resultVariable = resultVariable
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitCharaFilterStatement(self)
    }
}

/// SHOWCHARACARD - 显示角色卡片语句
public class ShowCharaCardStatement: StatementNode {
    public let targetExpression: ExpressionNode
    public let styleExpression: ExpressionNode?

    public init(targetExpression: ExpressionNode, styleExpression: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.targetExpression = targetExpression
        self.styleExpression = styleExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitShowCharaCardStatement(self)
    }
}

/// SHOWCHARALIST - 显示角色列表语句
public class ShowCharaListStatement: StatementNode {
    public let indicesExpression: ExpressionNode?

    public init(indicesExpression: ExpressionNode? = nil, position: ScriptPosition? = nil) {
        self.indicesExpression = indicesExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitShowCharaListStatement(self)
    }
}

/// SHOWBATTLESTATUS - 显示战斗状态语句
public class ShowBattleStatusStatement: StatementNode {
    public let targetExpression: ExpressionNode

    public init(targetExpression: ExpressionNode, position: ScriptPosition? = nil) {
        self.targetExpression = targetExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitShowBattleStatusStatement(self)
    }
}

/// SHOWPROGRESSBARS - 显示进度条语句
public class ShowProgressBarsStatement: StatementNode {
    public let targetExpression: ExpressionNode
    public let barsExpression: ExpressionNode

    public init(targetExpression: ExpressionNode, barsExpression: ExpressionNode, position: ScriptPosition? = nil) {
        self.targetExpression = targetExpression
        self.barsExpression = barsExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitShowProgressBarsStatement(self)
    }
}

/// SHOWCHARATAGS - 显示角色标签语句
public class ShowCharaTagsStatement: StatementNode {
    public let targetExpression: ExpressionNode

    public init(targetExpression: ExpressionNode, position: ScriptPosition? = nil) {
        self.targetExpression = targetExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitShowCharaTagsStatement(self)
    }
}

/// BATCHMODIFY - 批量修改语句
public class BatchModifyStatement: StatementNode {
    public let indicesExpression: ExpressionNode
    public let operationExpression: ExpressionNode
    public let valueExpression: ExpressionNode

    public init(indicesExpression: ExpressionNode, operationExpression: ExpressionNode, valueExpression: ExpressionNode, position: ScriptPosition? = nil) {
        self.indicesExpression = indicesExpression
        self.operationExpression = operationExpression
        self.valueExpression = valueExpression
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitBatchModifyStatement(self)
    }
}

/// CHARACOUNT - 获取角色数量语句
public class CharaCountStatement: StatementNode {
    public let resultVariable: String?

    public init(resultVariable: String? = nil, position: ScriptPosition? = nil) {
        self.resultVariable = resultVariable
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitCharaCountStatement(self)
    }
}

/// CHARAEXISTS - 检查角色是否存在语句
public class CharaExistsStatement: StatementNode {
    public let targetExpression: ExpressionNode
    public let resultVariable: String?

    public init(targetExpression: ExpressionNode, resultVariable: String? = nil, position: ScriptPosition? = nil) {
        self.targetExpression = targetExpression
        self.resultVariable = resultVariable
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitCharaExistsStatement(self)
    }
}

/// SET命令语句: SET variable = value
public class SetStatement: StatementNode {
    public let variable: String
    public let value: ExpressionNode

    public init(variable: String, value: ExpressionNode, position: ScriptPosition? = nil) {
        self.variable = variable
        self.value = value
        super.init(position: position)
    }

    public override func accept(visitor: StatementVisitor) throws {
        try visitor.visitSetStatement(self)
    }
}

// MARK: - 访问者模式接口

/// 语句访问者协议
public protocol StatementVisitor {
    func visitExpressionStatement(_ statement: ExpressionStatement) throws
    func visitBlockStatement(_ statement: BlockStatement) throws
    func visitIfStatement(_ statement: IfStatement) throws
    func visitWhileStatement(_ statement: WhileStatement) throws
    func visitForStatement(_ statement: ForStatement) throws
    func visitDoLoopStatement(_ statement: DoLoopStatement) throws
    func visitRepeatStatement(_ statement: RepeatStatement) throws
    func visitSelectCaseStatement(_ statement: SelectCaseStatement) throws
    func visitGotoStatement(_ statement: GotoStatement) throws
    func visitCallStatement(_ statement: CallStatement) throws
    func visitFunctionCallStatement(_ statement: FunctionCallStatement) throws  // Phase 2
    func visitFunctionDefinitionStatement(_ statement: FunctionDefinitionStatement) throws  // Phase 2
    func visitVariableDeclarationStatement(_ statement: VariableDeclarationStatement) throws  // Phase 2
    func visitReturnStatement(_ statement: ReturnStatement) throws
    func visitBreakStatement(_ statement: BreakStatement) throws
    func visitContinueStatement(_ statement: ContinueStatement) throws
    func visitLabelStatement(_ statement: LabelStatement) throws
    func visitCommandStatement(_ statement: CommandStatement) throws
    func visitResetStatement(_ statement: ResetStatement) throws
    func visitPersistStatement(_ statement: PersistStatement) throws
    // Phase 3: TRY/CATCH异常处理
    func visitTryCatchStatement(_ statement: TryCatchStatement) throws
    func visitTryCallStatement(_ statement: TryCallStatement) throws
    func visitTryJumpStatement(_ statement: TryJumpStatement) throws
    func visitTryGotoStatement(_ statement: TryGotoStatement) throws

    // Priority 1: TRYC系列扩展
    func visitTryCallFormStatement(_ statement: TryCallFormStatement) throws
    func visitTryGotoFormStatement(_ statement: TryGotoFormStatement) throws
    func visitTryJumpFormStatement(_ statement: TryJumpFormStatement) throws
    func visitTryCallListStatement(_ statement: TryCallListStatement) throws
    func visitTryJumpListStatement(_ statement: TryJumpListStatement) throws
    func visitTryGotoListStatement(_ statement: TryGotoListStatement) throws

    // Phase 3: PRINTDATA/DATALIST
    func visitPrintDataStatement(_ statement: PrintDataStatement) throws

    // Phase 3: SAVE/LOAD数据持久化
    func visitSaveDataStatement(_ statement: SaveDataStatement) throws
    func visitLoadDataStatement(_ statement: LoadDataStatement) throws
    func visitDelDataStatement(_ statement: DelDataStatement) throws

    // Phase 3 P2: SAVECHARA/LOADCHARA角色数据持久化
    func visitSaveCharaStatement(_ statement: SaveCharaStatement) throws
    func visitLoadCharaStatement(_ statement: LoadCharaStatement) throws

    // Phase 3 P3: SAVEGAME/LOADGAME完整游戏状态持久化
    func visitSaveGameStatement(_ statement: SaveGameStatement) throws
    func visitLoadGameStatement(_ statement: LoadGameStatement) throws

    // Phase 3 P4: SAVELIST/SAVEEXISTS存档管理增强
    func visitSaveListStatement(_ statement: SaveListStatement) throws
    func visitSaveExistsStatement(_ statement: SaveExistsStatement) throws

    // Phase 3 P5: AUTOSAVE/SAVEINFO高级存档功能
    func visitAutoSaveStatement(_ statement: AutoSaveStatement) throws
    func visitSaveInfoStatement(_ statement: SaveInfoStatement) throws

    // Phase 4: 数据重置和持久化控制
    func visitResetDataStatement(_ statement: ResetDataStatement) throws
    func visitResetGlobalStatement(_ statement: ResetGlobalStatement) throws
    func visitPersistEnhancedStatement(_ statement: PersistEnhancedStatement) throws

    // Phase 5: ERH头文件系统
    func visitFunctionDirectiveStatement(_ statement: FunctionDirectiveStatement) throws
    func visitGlobalDimStatement(_ statement: GlobalDimStatement) throws
    func visitDefineMacroStatement(_ statement: DefineMacroStatement) throws
    func visitIncludeStatement(_ statement: IncludeStatement) throws
    func visitGlobalVariableStatement(_ statement: GlobalVariableStatement) throws

    // Phase 6: 字符管理系统增强
    func visitAddCharaStatement(_ statement: AddCharaStatement) throws
    func visitDelCharaStatement(_ statement: DelCharaStatement) throws
    func visitSwapCharaStatement(_ statement: SwapCharaStatement) throws
    func visitCopyCharaStatement(_ statement: CopyCharaStatement) throws
    func visitSortCharaStatement(_ statement: SortCharaStatement) throws
    func visitFindCharaStatement(_ statement: FindCharaStatement) throws
    func visitCharaOperateStatement(_ statement: CharaOperateStatement) throws
    func visitCharaModifyStatement(_ statement: CharaModifyStatement) throws
    func visitCharaFilterStatement(_ statement: CharaFilterStatement) throws
    func visitShowCharaCardStatement(_ statement: ShowCharaCardStatement) throws
    func visitShowCharaListStatement(_ statement: ShowCharaListStatement) throws
    func visitShowBattleStatusStatement(_ statement: ShowBattleStatusStatement) throws
    func visitShowProgressBarsStatement(_ statement: ShowProgressBarsStatement) throws
    func visitShowCharaTagsStatement(_ statement: ShowCharaTagsStatement) throws
    func visitBatchModifyStatement(_ statement: BatchModifyStatement) throws
    func visitCharaCountStatement(_ statement: CharaCountStatement) throws
    func visitCharaExistsStatement(_ statement: CharaExistsStatement) throws

    // Priority 2: 变量赋值命令
    func visitSetStatement(_ statement: SetStatement) throws

    // Priority 1: D系列输出命令
    func visitPrintDStatement(_ statement: PrintDStatement) throws
    func visitPrintVStatement(_ statement: PrintVStatement) throws
    func visitPrintSStatement(_ statement: PrintSStatement) throws
    func visitPrintFormDStatement(_ statement: PrintFormDStatement) throws

    // Priority 2: 条件输出命令
    func visitSifStatement(_ statement: SifStatement) throws
}

// MARK: - 表达式节点 (复用现有ExpressionNode)

// 注意: ExpressionNode已在ExpressionParser.swift中定义
// 这里我们引用它，不需要重新定义
