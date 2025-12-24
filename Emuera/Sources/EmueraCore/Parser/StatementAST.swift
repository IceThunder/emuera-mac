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
}

// MARK: - 表达式节点 (复用现有ExpressionNode)

// 注意: ExpressionNode已在ExpressionParser.swift中定义
// 这里我们引用它，不需要重新定义
