//
//  LogicalLine.swift
//  EmueraCore
//
//  逻辑行基类 - 用于Process执行系统
//  代表解析后的代码行，支持链表结构
//  Created: 2025-12-19
//

import Foundation

// MARK: - LogicalLine (基类)

/// 逻辑行基类 - 代表一行可执行的代码
public class LogicalLine {
    public var nextLine: LogicalLine?
    public var position: ScriptPosition?
    public var isError: Bool = false
    public var errorMessage: String?

    public init(position: ScriptPosition? = nil) {
        self.position = position
    }

    /// 用于调试
    public var debugDescription: String {
        return "LogicalLine"
    }
}

// MARK: - NullLine (文件结束)

/// 文件结束标记
public class NullLine: LogicalLine {
    override public var debugDescription: String {
        return "NullLine(EOF)"
    }
}

// MARK: - GotoLabelLine (标签)

/// GOTO标签行
public class GotoLabelLine: LogicalLine {
    public let labelName: String

    public init(labelName: String, position: ScriptPosition? = nil) {
        self.labelName = labelName
        super.init(position: position)
    }

    override public var debugDescription: String {
        return "GotoLabelLine($\(labelName))"
    }
}

// MARK: - InvalidLine (无效行)

/// 无效的代码行（解析失败）
public class InvalidLine: LogicalLine {
    public let source: String

    public init(source: String, errorMessage: String? = nil, position: ScriptPosition? = nil) {
        self.source = source
        super.init(position: position)
        self.isError = true
        self.errorMessage = errorMessage
    }

    override public var debugDescription: String {
        return "InvalidLine(\(source))"
    }
}

// MARK: - FunctionLabelLine (函数定义)

/// 函数定义行 (@函数名)
public class FunctionLabelLine: LogicalLine {
    public let labelName: String
    public var isMethod: Bool = false  // #FUNCTION
    public var isSingle: Bool = false  // #SINGLE
    public var isOnly: Bool = false    // #ONLY
    public var hasPrivDynamicVar: Bool = false  // 有私有动态变量

    // 引用现有类型，不重新定义
    public var arguments: [Any] = []  // 实际上是 [VariableToken]
    public var defaultArguments: [Any?] = []  // 实际上是 [ExpressionNode?]

    // 函数体语句列表（用于Process执行）
    public var statements: [StatementNode] = []

    public init(labelName: String, position: ScriptPosition? = nil) {
        self.labelName = labelName
        super.init(position: position)
    }

    override public var debugDescription: String {
        return "FunctionLabelLine(@\(labelName))"
    }

    public func `in`() {
        // Setup private dynamic variables
    }

    public func `out`() {
        // Teardown private dynamic variables
    }
}

// MARK: - InstructionLine (指令行)

/// 指令行 - 可执行的命令
public class InstructionLine: LogicalLine {
    public let functionCode: String  // 命令名称
    public var argument: Any?  // 参数（具体类型依赖命令）
    public var jumpTo: LogicalLine?  // 跳转目标
    public var callList: [InstructionLine] = []  // TRYCALLLIST等
    public var dataList: [[InstructionLine]] = []  // STRDATA等

    // Debug flags
    public var isDebug: Bool = false
    public var isPrint: Bool = false

    public init(functionCode: String, position: ScriptPosition? = nil) {
        self.functionCode = functionCode
        super.init(position: position)
    }

    override public var debugDescription: String {
        return "InstructionLine(\(functionCode))"
    }

    public func updateRetAddress(_ line: LogicalLine?) {
        // For function methods
    }

    public var isFlowControl: Bool {
        // Check if this is a flow control function
        return ["CALL", "JUMP", "GOTO", "RETURN", "TRYCALL", "TRYJUMP"].contains(functionCode.uppercased())
    }

    public var isPrintCommand: Bool {
        return functionCode.uppercased().hasPrefix("PRINT")
    }
}

// MARK: - LabelDictionary (标签字典)

/// 标签和函数的字典管理
public class LabelDictionary {
    private var nonEventLabels: [String: FunctionLabelLine] = [:]
    private var eventLabels: [String: [FunctionLabelLine]] = [:]
    private var dollarLabels: [String: [String: LogicalLine]] = [:]  // $标签

    public init() {}

    /// 添加普通函数标签
    public func addNonEventLabel(_ label: String, _ line: FunctionLabelLine) {
        nonEventLabels[label] = line
    }

    /// 添加事件函数标签
    public func addEventLabel(_ label: String, _ line: FunctionLabelLine) {
        if eventLabels[label] == nil {
            eventLabels[label] = []
        }
        eventLabels[label]?.append(line)
    }

    /// 添加GOTO标签
    public func addDollarLabel(_ label: String, _ parent: FunctionLabelLine, _ line: LogicalLine) {
        let parentName = parent.labelName
        if dollarLabels[parentName] == nil {
            dollarLabels[parentName] = [:]
        }
        dollarLabels[parentName]?[label] = line
    }

    /// 获取普通函数
    public func getNonEventLabel(_ label: String) -> FunctionLabelLine? {
        return nonEventLabels[label]
    }

    /// 获取事件函数列表
    public func getEventLabels(_ label: String) -> [FunctionLabelLine]? {
        return eventLabels[label]
    }

    /// 获取GOTO标签
    public func getLabelDollar(_ label: String, _ current: FunctionLabelLine?) -> LogicalLine? {
        guard let parent = current else { return nil }
        return dollarLabels[parent.labelName]?[label]
    }

    /// 清空所有标签
    public func clear() {
        nonEventLabels.removeAll()
        eventLabels.removeAll()
        dollarLabels.removeAll()
    }
}