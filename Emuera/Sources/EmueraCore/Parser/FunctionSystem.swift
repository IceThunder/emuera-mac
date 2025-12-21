//
//  FunctionSystem.swift
//  EmueraCore
//
//  函数系统数据结构 - Phase 2
//  Created: 2025-12-20
//

import Foundation

// MARK: - 函数定义相关

/// 函数参数定义
public struct FunctionParameter {
    public let name: String
    public let type: VariableType
    public let isArray: Bool
    public let arraySize: Int?

    public init(name: String, type: VariableType, isArray: Bool = false, arraySize: Int? = nil) {
        self.name = name
        self.type = type
        self.isArray = isArray
        self.arraySize = arraySize
    }
}

/// 函数指令类型
public enum FunctionDirective {
    case function  // #FUNCTION - 返回值类型
    case functions  // #FUNCTIONS - 字符串返回值
    case dim(name: String, type: VariableType, isArray: Bool, size: ExpressionNode?)  // #DIM, #DIMS
    case dynamic  // #DIMS DYNAMIC
}

/// 函数定义节点
public struct FunctionDefinition {
    public let name: String
    public let parameters: [FunctionParameter]
    public let directives: [FunctionDirective]
    public let body: [StatementNode]
    public let position: ScriptPosition

    /// 计算返回值类型
    public var returnType: VariableType {
        for directive in directives {
            if case .function = directive { return .integer }
            if case .functions = directive { return .string }
        }
        return .integer  // 默认返回整数
    }

    /// 检查是否有特定指令
    public func hasDirective(_ check: (FunctionDirective) -> Bool) -> Bool {
        return directives.contains(where: check)
    }
}

// MARK: - 变量作用域

/// 变量作用域枚举
public enum VariableScope: String, CaseIterable {
    // 局部作用域
    case local = "LOCAL"
    case localString = "LOCALS"

    // 参数作用域
    case arg = "ARG"
    case argString = "ARGS"

    // 返回值作用域
    case result = "RESULT"
    case resultString = "RESULTS"

    // 全局作用域
    case global = "GLOBAL"
    case flag = "FLAG"
    case saveStr = "SAVESTR"

    // 系统数组
    case talent = "TALENT"
    case cflag = "CFLAG"
    case cstr = "CSTR"
    case equip = "EQUIP"
    case item = "ITEM"
    case abl = "ABL"
    case exp = "EXP"
    case PALAM = "PALAM"
    case source = "SOURCE"
    case ex = "EX"
    case tcvar = "TCVAR"
    case tequip = "TEQUIP"
    case tflag = "TFLAG"
    case stain = "STAIN"

    // 普通变量（无作用域前缀）
    case none = ""

    /// 判断是否是局部作用域
    public var isLocal: Bool {
        return [.local, .localString, .arg, .argString].contains(self)
    }

    /// 判断是否是系统数组
    public var isArray: Bool {
        return [.talent, .cflag, .cstr, .equip, .item, .abl, .exp,
                .PALAM, .source, .ex, .tcvar, .tequip, .tflag, .stain].contains(self)
    }

    /// 获取对应的变量类型
    public var variableType: VariableType {
        switch self {
        case .localString, .argString, .resultString, .saveStr, .cstr:
            return .string
        default:
            return .integer
        }
    }

    /// 从变量名解析作用域
    public static func fromVariableName(_ name: String) -> (scope: VariableScope, baseName: String) {
        for scope in VariableScope.allCases {
            if scope != .none, name.hasPrefix(scope.rawValue) {
                let baseName = String(name.dropFirst(scope.rawValue.count))
                return (scope, baseName)
            }
        }
        return (.none, name)
    }
}

/// 带作用域和索引的变量引用
public struct ScopedVariable {
    public let scope: VariableScope
    public let name: String
    public let indices: [ExpressionNode]  // 数组索引

    public init(scope: VariableScope, name: String, indices: [ExpressionNode] = []) {
        self.scope = scope
        self.name = name
        self.indices = indices
    }

    /// 完整变量名（用于调试）
    public var fullName: String {
        if scope == .none {
            return name
        }
        return "\(scope.rawValue)\(name)"
    }
}

// MARK: - 函数调用相关


// MARK: - 函数注册表

/// 函数注册表
public class FunctionRegistry {
    private var functions: [String: FunctionDefinition] = [:]
    private var builtInFunctions: [String: BuiltInFunction] = [:]

    public init() {
        registerDefaultBuiltInFunctions()
    }

    /// 注册用户定义函数
    public func registerFunction(_ definition: FunctionDefinition) {
        functions[definition.name.uppercased()] = definition
    }

    /// 查找函数
    public func resolveFunction(_ name: String) -> FunctionDefinition? {
        return functions[name.uppercased()]
    }

    /// 注册内置函数
    public func registerBuiltIn(_ name: String, handler: @escaping BuiltInFunction.Handler) {
        builtInFunctions[name.uppercased()] = BuiltInFunction(name: name, handler: handler)
    }

    /// 执行内置函数
    public func executeBuiltIn(_ name: String, arguments: [VariableValue], context: ExecutionContext) throws -> VariableValue {
        guard let function = builtInFunctions[name.uppercased()] else {
            throw EmueraError.functionNotFound(name)
        }
        return try function.handler(arguments, context)
    }

    /// 检查函数是否存在
    public func hasFunction(_ name: String) -> Bool {
        return functions[name.uppercased()] != nil || builtInFunctions[name.uppercased()] != nil
    }

    /// 注册默认内置函数
    private func registerDefaultBuiltInFunctions() {
        // 数学函数
        registerBuiltIn("RAND") { args, _ in
            if args.isEmpty { return .integer(0) }
            guard case .integer(let max) = args[0] else { return .integer(0) }
            return .integer(Int64.random(in: 0..<max))
        }

        registerBuiltIn("ABS") { args, _ in
            guard case .integer(let value) = args.first ?? .integer(0) else { return .integer(0) }
            return .integer(value < 0 ? -value : value)
        }

        registerBuiltIn("LIMIT") { args, _ in
            guard args.count >= 3,
                  case .integer(let value) = args[0],
                  case .integer(let minValue) = args[1],
                  case .integer(let maxValue) = args[2] else { return .integer(0) }
            return .integer(Swift.max(minValue, Swift.min(value, maxValue)))
        }

        registerBuiltIn("MIN") { args, _ in
            let values = args.compactMap { if case .integer(let v) = $0 { return v } else { return nil } }
            return .integer(values.min() ?? 0)
        }

        registerBuiltIn("MAX") { args, _ in
            let values = args.compactMap { if case .integer(let v) = $0 { return v } else { return nil } }
            return .integer(values.max() ?? 0)
        }

        // 字符串函数
        registerBuiltIn("STRCOUNT") { args, _ in
            guard args.count >= 2,
                  case .string(let str) = args[0],
                  case .string(let pattern) = args[1] else { return .integer(0) }
            return .integer(Int64(str.components(separatedBy: pattern).count - 1))
        }

        registerBuiltIn("TOSTR") { args, _ in
            guard case .integer(let value) = args.first ?? .integer(0) else { return .string("") }
            return .string(String(value))
        }

        registerBuiltIn("TOINT") { args, _ in
            guard case .string(let value) = args.first ?? .string("") else { return .integer(0) }
            return .integer(Int64(value) ?? 0)
        }

        // 类型转换
        registerBuiltIn("CHARATU") { args, _ in
            guard args.count >= 2,
                  case .string(let str) = args[0],
                  case .integer(let index) = args[1],
                  index >= 0 && index < str.count else { return .string("") }
            let charIndex = str.index(str.startIndex, offsetBy: Int(index))
            return .string(String(str[charIndex]))
        }
    }
}

/// 内置函数结构
public struct BuiltInFunction {
    public typealias Handler = ([VariableValue], ExecutionContext) throws -> VariableValue

    public let name: String
    public let handler: Handler

    public init(name: String, handler: @escaping Handler) {
        self.name = name
        self.handler = handler
    }
}

// MARK: - 函数调用帧

/// 函数调用帧（用于调用栈）
public struct FunctionFrame {
    public let functionName: String
    public let callerIndex: Int  // 调用点在语句列表中的位置
    public let returnIndex: Int?  // 返回后要执行的语句索引
    public var localVariables: [String: VariableValue]
    public var parameters: [String: VariableValue]

    public init(functionName: String, callerIndex: Int, returnIndex: Int? = nil) {
        self.functionName = functionName
        self.callerIndex = callerIndex
        self.returnIndex = returnIndex
        self.localVariables = [:]
        self.parameters = [:]
    }
}

// MARK: - 执行上下文扩展

extension ExecutionContext {
    /// 函数调用栈（使用全局字典存储）
    public var functionStack: [FunctionFrame] {
        get {
            storageLock.lock()
            defer { storageLock.unlock() }
            let id = ObjectIdentifier(self)
            return (executionContextStorage[id]?["functionStack"] as? [FunctionFrame]) ?? []
        }
        set {
            storageLock.lock()
            defer { storageLock.unlock() }
            let id = ObjectIdentifier(self)
            if executionContextStorage[id] == nil {
                executionContextStorage[id] = [:]
            }
            executionContextStorage[id]?["functionStack"] = newValue
        }
    }

    /// 当前函数的局部变量
    public var currentLocalVariables: [String: VariableValue] {
        get {
            storageLock.lock()
            defer { storageLock.unlock() }
            let id = ObjectIdentifier(self)
            return (executionContextStorage[id]?["currentLocalVariables"] as? [String: VariableValue]) ?? [:]
        }
        set {
            storageLock.lock()
            defer { storageLock.unlock() }
            let id = ObjectIdentifier(self)
            if executionContextStorage[id] == nil {
                executionContextStorage[id] = [:]
            }
            executionContextStorage[id]?["currentLocalVariables"] = newValue
        }
    }

    /// 当前函数的参数
    public var currentParameters: [String: VariableValue] {
        get {
            storageLock.lock()
            defer { storageLock.unlock() }
            let id = ObjectIdentifier(self)
            return (executionContextStorage[id]?["currentParameters"] as? [String: VariableValue]) ?? [:]
        }
        set {
            storageLock.lock()
            defer { storageLock.unlock() }
            let id = ObjectIdentifier(self)
            if executionContextStorage[id] == nil {
                executionContextStorage[id] = [:]
            }
            executionContextStorage[id]?["currentParameters"] = newValue
        }
    }

    /// 函数注册表
    public var functionRegistry: FunctionRegistry {
        get {
            storageLock.lock()
            defer { storageLock.unlock() }
            let id = ObjectIdentifier(self)
            if let registry = executionContextStorage[id]?["functionRegistry"] as? FunctionRegistry {
                return registry
            }
            let registry = FunctionRegistry()
            if executionContextStorage[id] == nil {
                executionContextStorage[id] = [:]
            }
            executionContextStorage[id]?["functionRegistry"] = registry
            return registry
        }
        set {
            storageLock.lock()
            defer { storageLock.unlock() }
            let id = ObjectIdentifier(self)
            if executionContextStorage[id] == nil {
                executionContextStorage[id] = [:]
            }
            executionContextStorage[id]?["functionRegistry"] = newValue
        }
    }

    /// 推送函数帧
    public func pushFunctionFrame(_ functionName: String, callerIndex: Int, returnIndex: Int? = nil) {
        var frame = FunctionFrame(functionName: functionName, callerIndex: callerIndex, returnIndex: returnIndex)
        frame.localVariables = currentLocalVariables
        frame.parameters = currentParameters
        var stack = functionStack
        stack.append(frame)
        functionStack = stack
    }

    /// 弹出函数帧
    public func popFunctionFrame() -> FunctionFrame? {
        var stack = functionStack
        guard let frame = stack.popLast() else { return nil }
        functionStack = stack
        return frame
    }

    /// 设置局部变量
    public func setLocalVariable(_ name: String, value: VariableValue) {
        var vars = currentLocalVariables
        vars[name] = value
        currentLocalVariables = vars
    }

    /// 获取局部变量（包括参数）
    public func getLocalVariable(_ name: String) -> VariableValue? {
        if let value = currentLocalVariables[name] {
            return value
        }
        if let value = currentParameters[name] {
            return value
        }
        return nil
    }
}

// MARK: - 关联对象辅助（用于扩展ExecutionContext）

// 为ExecutionContext添加存储属性的私有字典
private var executionContextStorage: [ObjectIdentifier: [String: Any]] = [:]
private var storageLock: NSLock = {
    print("FunctionSystem: Initializing storageLock")
    return NSLock()
}()

private func getAssociatedObject<T>(key: String, default: T) -> T {
    // 获取当前执行上下文的调用栈
    let stack = Thread.callStackSymbols
    if stack.count > 1 {
        // 这是一个简化的实现，实际应该使用真正的关联对象机制
        // 由于Swift extension不能直接添加存储属性，我们使用全局字典
        // 这里我们返回默认值，因为真正的实现需要在extension中使用不同的方法
    }
    return `default`
}

private func setAssociatedObject<T>(key: String, value: T) {
    // 空实现，实际存储在extension中完成
}

// MARK: - 新增错误类型

extension EmueraError {
    public static func functionNotFound(_ name: String) -> EmueraError {
        return .scriptParseError(message: "函数未定义: \(name)", position: ScriptPosition(filename: "unknown", lineNumber: 0))
    }

    public static func invalidFunctionCall(_ name: String, expected: Int, actual: Int) -> EmueraError {
        return .scriptParseError(message: "函数 \(name) 参数数量错误: 期望 \(expected), 实际 \(actual)", position: ScriptPosition(filename: "unknown", lineNumber: 0))
    }
}
