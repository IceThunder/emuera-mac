//
//  Preprocessor.swift
//  EmueraCore
//
//  预处理器 - 处理ERH头文件中的宏定义和全局变量
//  支持 #DIM, #DEFINE, #FUNCTION 等指令
//  Created: 2025-12-25
//

import Foundation

/// 预处理器状态
public enum PreprocessorState {
    case normal          // 正常处理
    case inFunction      // 在函数定义中
    case inMacro         // 在宏定义中
}

/// 预处理器 - 负责ERH头文件的预处理
public final class Preprocessor {

    // MARK: - 属性

    /// 宏定义存储
    private var macros: [String: DefineMacro] = [:]

    /// 全局变量定义
    private var globalVariables: [String: GlobalVariableDef] = [:]

    /// 函数定义存储
    private var functionDefinitions: [String: FunctionDefinition] = [:]

    /// 头文件依赖关系
    private var dependencies: [String: [String]] = [:]

    /// 已加载的头文件
    private var loadedHeaders: Set<String> = []

    /// 循环依赖检测
    private var loadingStack: [String] = []

    /// 错误收集
    private var errors: [PreprocessError] = []

    /// 是否启用缓存
    private var enableCache: Bool = true

    /// 缓存目录
    private var cacheDirectory: String?

    // MARK: - 初始化

    public init() {}

    // MARK: - 公共接口

    /// 预处理ERH文件
    /// - Parameter filePath: ERH文件路径
    /// - Returns: 预处理后的代码
    public func preprocess(filePath: String) throws -> String {
        let content = try readFile(filePath)
        return try preprocessContent(content, source: filePath)
    }

    /// 预处理ERH内容
    /// - Parameter content: ERH文件内容
    /// - Parameter source: 来源标识（用于错误报告）
    /// - Returns: 预处理后的代码
    public func preprocessContent(_ content: String, source: String = "unknown") throws -> String {
        errors.removeAll()

        let lines = content.components(separatedBy: .newlines)
        var result: [String] = []
        var lineIndex = 0

        for line in lines {
            lineIndex += 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // 跳过空行和注释
            if trimmed.isEmpty || trimmed.hasPrefix(";") {
                result.append(line)
                continue
            }

            // 必须以#开头
            guard trimmed.hasPrefix("#") else {
                throw PreprocessError.invalidDirective(
                    message: "头文件行必须以#开头",
                    source: source,
                    line: lineIndex
                )
            }

            // 解析指令
            let processed = try processDirective(line, source: source, line: lineIndex)
            result.append(processed)
        }

        guard errors.isEmpty else {
            throw PreprocessError.multipleErrors(errors: errors)
        }

        return result.joined(separator: "\n")
    }

    /// 获取宏定义
    public func getMacro(_ name: String) -> DefineMacro? {
        return macros[name.uppercased()]
    }

    /// 获取所有宏
    public func getAllMacros() -> [String: DefineMacro] {
        return macros
    }

    /// 获取全局变量
    public func getGlobalVariable(_ name: String) -> GlobalVariableDef? {
        return globalVariables[name.uppercased()]
    }

    /// 获取所有全局变量
    public func getAllGlobalVariables() -> [String: GlobalVariableDef] {
        return globalVariables
    }

    /// 获取函数定义
    public func getFunctionDefinition(_ name: String) -> FunctionDefinition? {
        return functionDefinitions[name.uppercased()]
    }

    /// 获取所有函数定义
    public func getAllFunctionDefinitions() -> [String: FunctionDefinition] {
        return functionDefinitions
    }

    /// 获取依赖关系
    public func getDependencies() -> [String: [String]] {
        return dependencies
    }

    /// 获取错误列表
    public func getErrors() -> [PreprocessError] {
        return errors
    }

    /// 清除所有缓存
    public func clearCache() {
        macros.removeAll()
        globalVariables.removeAll()
        functionDefinitions.removeAll()
        dependencies.removeAll()
        loadedHeaders.removeAll()
        loadingStack.removeAll()
        errors.removeAll()
    }

    // MARK: - 私有方法

    /// 处理单个指令
    private func processDirective(_ lineText: String, source: String, line: Int) throws -> String {
        let scanner = StringScanner(lineText)

        // 跳过#
        scanner.skip(1)
        scanner.skipWhitespace()

        // 读取指令标识符
        guard let directive = scanner.readIdentifier()?.uppercased() else {
            throw PreprocessError.invalidDirective(
                message: "无法解析指令",
                source: source,
                line: line
            )
        }

        scanner.skipWhitespace()

        switch directive {
        case "INCLUDE":
            return try processInclude(scanner, source: source, line: line)

        case "DEFINE":
            try processDefine(scanner, source: source, line: line)
            return "" // 宏定义在预处理阶段被移除

        case "FUNCTION", "FUNCTIONS":
            try processFunction(scanner, source: source, line: line)
            return lineText // 保留函数定义

        case "DIM", "DIMS":
            try processDim(scanner, source: source, line: line, isString: directive == "DIMS")
            return lineText // 保留变量声明

        case "GLOBAL":
            try processGlobal(scanner, source: source, line: line)
            return "" // 全局变量定义在预处理阶段被移除

        default:
            throw PreprocessError.unknownDirective(
                directive: directive,
                source: source,
                line: line
            )
        }
    }

    /// 处理 #INCLUDE 指令
    private func processInclude(_ scanner: StringScanner, source: String, line: Int) throws -> String {
        scanner.skipWhitespace()

        // 读取文件路径
        guard let relativePath = scanner.readQuotedString() else {
            throw PreprocessError.invalidInclude(
                message: "INCLUDE需要带引号的文件路径",
                source: source,
                line: line
            )
        }

        // 基于源文件路径解析相对路径
        let sourceURL = URL(fileURLWithPath: source)
        let includeURL = URL(fileURLWithPath: relativePath, relativeTo: sourceURL.deletingLastPathComponent())
        let resolvedPath = includeURL.path

        // 检查循环依赖
        if loadingStack.contains(resolvedPath) {
            throw PreprocessError.circularDependency(
                path: resolvedPath,
                stack: loadingStack,
                source: source,
                line: line
            )
        }

        // 如果已加载，跳过
        if loadedHeaders.contains(resolvedPath) {
            return ""
        }

        // 记录依赖关系
        if dependencies[source] == nil {
            dependencies[source] = []
        }
        dependencies[source]?.append(resolvedPath)

        // 加载并递归预处理
        loadingStack.append(resolvedPath)
        defer { loadingStack.removeLast() }

        let includedContent = try readFile(resolvedPath)
        let preprocessed = try preprocessContent(includedContent, source: resolvedPath)

        loadedHeaders.insert(resolvedPath)

        return preprocessed
    }

    /// 处理 #DEFINE 指令
    private func processDefine(_ scanner: StringScanner, source: String, line: Int) throws {
        // 读取宏名称
        guard let name = scanner.readIdentifier() else {
            throw PreprocessError.invalidDefine(
                message: "DEFINE需要宏名称",
                source: source,
                line: line
            )
        }

        scanner.skipWhitespace()

        // 检查是否有参数（函数式宏）
        let hasArgs = scanner.current == "("
        var argCount = 0

        if hasArgs {
            // 解析参数列表
            scanner.skip(1) // 跳过(
            argCount = try parseMacroArguments(scanner)
            scanner.skipWhitespace()
        }

        // 读取宏体
        let body = scanner.remainder()

        // 创建宏定义
        let macro = DefineMacro(
            keyword: name.uppercased(),
            statement: try createWordCollection(body),
            argCount: argCount
        )

        // 检查名称冲突
        if let existing = macros[name.uppercased()] {
            throw PreprocessError.duplicateMacro(
                name: name,
                existing: existing.keyword,
                source: source,
                line: line
            )
        }

        macros[name.uppercased()] = macro
    }

    /// 处理 #FUNCTION 指令
    private func processFunction(_ scanner: StringScanner, source: String, line: Int) throws {
        // 这里只记录函数声明，实际解析在ScriptParser中完成
        // 为了Phase 5的完整性，我们先预留接口

        // 读取函数名
        guard let name = scanner.readIdentifier() else {
            throw PreprocessError.invalidFunction(
                message: "FUNCTION需要函数名称",
                source: source,
                line: line
            )
        }

        // 记录函数定义（简化版本）
        let funcDef = FunctionDefinition(
            name: name.uppercased(),
            parameters: [],
            directives: [],
            body: [],
            position: ScriptPosition(filename: source, lineNumber: line)
        )

        functionDefinitions[name.uppercased()] = funcDef
    }

    /// 处理 #DIM/#DIMS 指令
    private func processDim(_ scanner: StringScanner, source: String, line: Int, isString: Bool) throws {
        // 读取变量名
        guard let name = scanner.readIdentifier() else {
            throw PreprocessError.invalidDim(
                message: "DIM需要变量名称",
                source: source,
                line: line
            )
        }

        scanner.skipWhitespace()

        // 检查是否有数组大小
        var arraySize: Int64? = nil
        if scanner.current == "," {
            scanner.skip(1)
            scanner.skipWhitespace()

            // 读取数组大小
            if let sizeStr = scanner.readNumber() {
                arraySize = sizeStr
            }
        }

        // 创建全局变量定义
        let globalVar = GlobalVariableDef(
            name: name.uppercased(),
            type: isString ? .string : .integer,
            isArray: arraySize != nil,
            size: arraySize,
            source: source,
            line: line
        )

        // 检查名称冲突
        if let existing = globalVariables[name.uppercased()] {
            throw PreprocessError.duplicateVariable(
                name: name,
                existing: existing.name,
                source: source,
                line: line
            )
        }

        globalVariables[name.uppercased()] = globalVar
    }

    /// 处理 #GLOBAL 指令
    private func processGlobal(_ scanner: StringScanner, source: String, line: Int) throws {
        // #GLOBAL用于声明全局变量，类似于#DIM但作用域更广
        // 这里简化处理，与#DIM类似

        scanner.skipWhitespace()

        guard let name = scanner.readIdentifier() else {
            throw PreprocessError.invalidGlobal(
                message: "GLOBAL需要变量名称",
                source: source,
                line: line
            )
        }

        scanner.skipWhitespace()

        // 检查是否有数组大小
        var arraySize: Int64? = nil
        if scanner.current == "," {
            scanner.skip(1)
            scanner.skipWhitespace()

            if let sizeStr = scanner.readNumber() {
                arraySize = sizeStr
            }
        }

        let globalVar = GlobalVariableDef(
            name: name.uppercased(),
            type: .integer,
            isArray: arraySize != nil,
            size: arraySize,
            source: source,
            line: line
        )

        if let existing = globalVariables[name.uppercased()] {
            throw PreprocessError.duplicateVariable(
                name: name,
                existing: existing.name,
                source: source,
                line: line
            )
        }

        globalVariables[name.uppercased()] = globalVar
    }

    /// 解析宏参数列表
    private func parseMacroArguments(_ scanner: StringScanner) throws -> Int {
        var count = 0

        while !scanner.isAtEnd {
            scanner.skipWhitespace()

            if scanner.current == ")" {
                scanner.skip(1)
                break
            }

            if scanner.current == "," {
                scanner.skip(1)
                continue
            }

            // 读取参数名
            if scanner.readIdentifier() != nil {
                count += 1
            } else {
                throw PreprocessError.invalidMacroArgument(
                    message: "无效的宏参数"
                )
            }
        }

        return count
    }

    /// 创建词法单元集合
    private func createWordCollection(_ content: String) throws -> WordCollection {
        let wc = WordCollection()
        let scanner = StringScanner(content)

        while !scanner.isAtEnd {
            scanner.skipWhitespace()

            if scanner.isAtEnd {
                break
            }

            // 读取一个词法单元
            if let num = scanner.readNumber() {
                wc.add(LiteralIntegerWord(num))
            } else if let str = scanner.readQuotedString() {
                wc.add(LiteralStringWord(str))
            } else if let id = scanner.readIdentifier() {
                wc.add(IdentifierWord(id))
            } else if let op = scanner.readOperator() {
                wc.add(OperatorWord(op))
            } else if let sym = scanner.current {
                wc.add(SymbolWord(sym))
                scanner.skip(1)
            }
        }

        return wc
    }

    /// 读取文件内容
    private func readFile(_ path: String) throws -> String {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            throw PreprocessError.fileNotFound(path: path)
        }

        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)

        // 尝试不同编码
        if let content = String(data: data, encoding: .utf8) {
            return content
        }
        if let content = String(data: data, encoding: .shiftJIS) {
            return content
        }
        if let content = String(data: data, encoding: .windowsCP1252) {
            return content
        }

        throw PreprocessError.encodingError(path: path)
    }
}

// MARK: - 辅助类和结构

/// 字符串扫描器
private class StringScanner {
    private let text: String
    private var position: String.Index

    init(_ text: String) {
        self.text = text
        self.position = text.startIndex
    }

    var current: Character? {
        return position < text.endIndex ? text[position] : nil
    }

    var isAtEnd: Bool {
        return position >= text.endIndex
    }

    func skip(_ count: Int) {
        for _ in 0..<count {
            if position < text.endIndex {
                position = text.index(after: position)
            }
        }
    }

    func skipWhitespace() {
        while let char = current, char.isWhitespace {
            position = text.index(after: position)
        }
    }

    func readIdentifier() -> String? {
        var result = ""
        var pos = position

        while pos < text.endIndex {
            let char = text[pos]
            if char.isLetter || char.isNumber || char == "_" {
                result.append(char)
                pos = text.index(after: pos)
            } else {
                break
            }
        }

        if !result.isEmpty {
            position = pos
            return result
        }
        return nil
    }

    func readNumber() -> Int64? {
        var result = ""
        var pos = position

        while pos < text.endIndex {
            let char = text[pos]
            if char.isNumber {
                result.append(char)
                pos = text.index(after: pos)
            } else {
                break
            }
        }

        if !result.isEmpty {
            position = pos
            return Int64(result)
        }
        return nil
    }

    func readQuotedString() -> String? {
        guard let start = current, start == "\"" else {
            return nil
        }

        skip(1) // 跳过开头的引号

        var result = ""
        var escaped = false

        while !isAtEnd {
            guard let char = current else { break }

            if escaped {
                result.append(char)
                escaped = false
            } else if char == "\\" {
                escaped = true
            } else if char == "\"" {
                skip(1)
                return result
            } else {
                result.append(char)
            }

            skip(1)
        }

        return nil // 未找到闭合引号
    }

    func readOperator() -> OperatorCode? {
        guard let first = current else { return nil }

        // 检查双字符运算符
        if position < text.index(before: text.endIndex) {
            let nextIndex = text.index(after: position)
            if nextIndex < text.endIndex {
                let next = text[nextIndex]
                let twoChar = String([first, next])

                switch twoChar {
                case "**": skip(2); return .power
                case "==": skip(2); return .equal
                case "!=": skip(2); return .notEqual
                case "<=": skip(2); return .lessEqual
                case ">=": skip(2); return .greaterEqual
                case "&&": skip(2); return .and
                case "||": skip(2); return .or
                case "+=": skip(2); return .addAssign
                case "-=": skip(2); return .subtractAssign
                case "*=": skip(2); return .multiplyAssign
                case "/=": skip(2); return .divideAssign
                case "<<": skip(2); return .shiftLeft
                case ">>": skip(2); return .shiftRight
                default: break
                }
            }
        }

        // 单字符运算符
        switch first {
        case "+": skip(1); return .add
        case "-": skip(1); return .subtract
        case "*": skip(1); return .multiply
        case "/": skip(1); return .divide
        case "%": skip(1); return .modulo
        case "=": skip(1); return .assign
        case "!": skip(1); return .not
        case "<": skip(1); return .less
        case ">": skip(1); return .greater
        case "&": skip(1); return .bitAnd
        case "|": skip(1); return .bitOr
        case "^": skip(1); return .bitXor
        case "~": skip(1); return .bitNot
        default: return nil
        }
    }

    func remainder() -> String {
        return String(text[position...])
    }
}

/// 预处理阶段的全局变量定义（简化版）
public struct GlobalVariableDef {
    public let name: String
    public let type: PreprocessorVariableType
    public let isArray: Bool
    public let size: Int64?
    public let source: String
    public let line: Int
}

/// 预处理阶段使用的变量类型（简化版）
public enum PreprocessorVariableType {
    case integer
    case string
}

/// 预处理错误
public enum PreprocessError: Error, LocalizedError {
    case fileNotFound(path: String)
    case encodingError(path: String)
    case invalidDirective(message: String, source: String, line: Int)
    case unknownDirective(directive: String, source: String, line: Int)
    case invalidInclude(message: String, source: String, line: Int)
    case invalidDefine(message: String, source: String, line: Int)
    case invalidFunction(message: String, source: String, line: Int)
    case invalidDim(message: String, source: String, line: Int)
    case invalidGlobal(message: String, source: String, line: Int)
    case circularDependency(path: String, stack: [String], source: String, line: Int)
    case duplicateMacro(name: String, existing: String, source: String, line: Int)
    case duplicateVariable(name: String, existing: String, source: String, line: Int)
    case invalidMacroArgument(message: String)
    case multipleErrors(errors: [PreprocessError])

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "文件不存在: \(path)"
        case .encodingError(let path):
            return "编码错误: \(path)"
        case .invalidDirective(let message, let source, let line):
            return "\(source):\(line) - \(message)"
        case .unknownDirective(let directive, let source, let line):
            return "\(source):\(line) - 未知指令: \(directive)"
        case .invalidInclude(let message, let source, let line):
            return "\(source):\(line) - INCLUDE错误: \(message)"
        case .invalidDefine(let message, let source, let line):
            return "\(source):\(line) - DEFINE错误: \(message)"
        case .invalidFunction(let message, let source, let line):
            return "\(source):\(line) - FUNCTION错误: \(message)"
        case .invalidDim(let message, let source, let line):
            return "\(source):\(line) - DIM错误: \(message)"
        case .invalidGlobal(let message, let source, let line):
            return "\(source):\(line) - GLOBAL错误: \(message)"
        case .circularDependency(let path, let stack, let source, let line):
            return "\(source):\(line) - 循环依赖检测到: \(path), 调用栈: \(stack.joined(separator: " -> "))"
        case .duplicateMacro(let name, let existing, let source, let line):
            return "\(source):\(line) - 宏 \(name) 与已存在的 \(existing) 冲突"
        case .duplicateVariable(let name, let existing, let source, let line):
            return "\(source):\(line) - 变量 \(name) 与已存在的 \(existing) 冲突"
        case .invalidMacroArgument(let message):
            return "宏参数错误: \(message)"
        case .multipleErrors(let errors):
            return "预处理发现 \(errors.count) 个错误:\n" + errors.map { $0.errorDescription ?? "未知错误" }.joined(separator: "\n")
        }
    }
}

/// 字符串扫描器扩展
extension StringScanner {
    func peek(_ count: Int = 1) -> String? {
        var result = ""
        var pos = position

        for _ in 0..<count {
            guard pos < text.endIndex else { break }
            result.append(text[pos])
            pos = text.index(after: pos)
        }

        return result.isEmpty ? nil : result
    }
}
