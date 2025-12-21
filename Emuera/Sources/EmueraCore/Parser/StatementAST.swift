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

// MARK: - 访问者模式接口

/// 语句访问者协议
public protocol StatementVisitor {
    func visitExpressionStatement(_ statement: ExpressionStatement) throws
    func visitBlockStatement(_ statement: BlockStatement) throws
    func visitIfStatement(_ statement: IfStatement) throws
    func visitWhileStatement(_ statement: WhileStatement) throws
    func visitForStatement(_ statement: ForStatement) throws
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
}

// MARK: - 表达式节点 (复用现有ExpressionNode)

// 注意: ExpressionNode已在ExpressionParser.swift中定义
// 这里我们引用它，不需要重新定义
