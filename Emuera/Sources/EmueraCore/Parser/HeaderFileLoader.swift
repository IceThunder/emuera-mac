//  HeaderFileLoader.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/19.
//

import Foundation

/// Loads and processes ERH header files with enhanced features
public final class HeaderFileLoader {
    private let idDic: IdentifierDictionary
    private let tokenData: TokenData
    private var dimLines: [DimLineData] = []
    private var noError: Bool = true

    // MARK: - Phase 5 增强功能

    /// 头文件依赖关系图
    private var dependencyGraph: [String: [String]] = [:]

    /// 已加载的头文件（用于去重和循环检测）
    private var loadedFiles: Set<String> = []

    /// 加载栈（用于循环依赖检测）
    private var loadingStack: [String] = []

    /// 缓存机制
    private var cacheEnabled: Bool = true
    private var cacheDirectory: String?

    /// 预处理器实例
    private var preprocessor: Preprocessor?

    public init(idDic: IdentifierDictionary, tokenData: TokenData) {
        self.idDic = idDic
        self.tokenData = tokenData
        self.preprocessor = Preprocessor()
    }

    // MARK: - 新增属性访问器

    /// 获取依赖关系图
    public func getDependencyGraph() -> [String: [String]] {
        return dependencyGraph
    }

    /// 获取已加载的文件列表
    public func getLoadedFiles() -> Set<String> {
        return loadedFiles
    }

    /// 启用/禁用缓存
    public func setCacheEnabled(_ enabled: Bool, directory: String? = nil) {
        cacheEnabled = enabled
        cacheDirectory = directory
    }

    /// 获取预处理器（用于访问宏定义等）
    public func getPreprocessor() -> Preprocessor? {
        return preprocessor
    }

    /// Load all ERH header files from specified directory
    /// Phase 5增强：支持依赖解析和循环检测
    public func loadHeaderFiles(from directory: String, displayReport: Bool = false) throws -> Bool {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: directory) else {
            return true  // No header files is OK
        }

        let erhFiles = files.filter { $0.uppercased().hasSuffix(".ERH") }

        // 清除之前的状态
        dimLines.removeAll()
        noError = true
        dependencyGraph.removeAll()
        loadedFiles.removeAll()
        loadingStack.removeAll()

        // 第一阶段：使用预处理器处理所有文件（包括#INCLUDE）
        for filename in erhFiles {
            let filepath = (directory as NSString).appendingPathComponent(filename)

            if displayReport {
                print("预处理中: \(filename)")
            }

            // 使用预处理器处理文件
            if let preprocessor = preprocessor {
                let preprocessed = try preprocessor.preprocess(filePath: filepath)

                // 保存预处理结果（可选，用于调试）
                if cacheEnabled {
                    try savePreprocessedCache(filename: filename, content: preprocessed)
                }
            }
        }

        // 第二阶段：解析预处理后的指令
        for filename in erhFiles {
            let filepath = (directory as NSString).appendingPathComponent(filename)

            if displayReport {
                print("解析中: \(filename)")
            }

            let result = try loadHeaderFile(filepath: filepath, filename: filename)
            if !result {
                return false
            }
        }

        // 第三阶段：处理#DIM声明
        if !dimLines.isEmpty {
            let dimResult = try analyzeSharpDimLines()
            noError = noError && dimResult
        }

        return noError
    }

    /// Load a single header file
    private func loadHeaderFile(filepath: String, filename: String) throws -> Bool {
        let reader = EraStreamReader(enableRename: true)

        guard reader.open(filepath: filepath, filename: filename) else {
            throw EmueraError.fileNotFoundError(path: filepath)
        }

        defer { reader.close() }

        while let stream = reader.readEnabledLine() {
            if !noError {
                return false
            }

            let position = ScriptPosition(filename: filename, lineNumber: reader.lineNo, line: stream.rowString)

            // Skip whitespace
            stream.skipWhitespace()

            // Must start with #
            guard let first = stream.current, first == "#" else {
                throw EmueraError.headerFileError(message: "Header file line must start with #", position: position)
            }
            stream.shiftNext()  // Skip #

            // Read directive identifier
            guard let sharpID = stream.readIdentifier()?.uppercased() else {
                throw EmueraError.headerFileError(message: "Cannot parse # directive", position: position)
            }

            stream.skipWhitespace()

            switch sharpID {
            case "DEFINE":
                try analyzeSharpDefine(stream: stream, position: position)

            case "FUNCTION", "FUNCTIONS":
                try analyzeSharpFunction(stream: stream, position: position, isFunctions: sharpID == "FUNCTIONS")

            case "DIM", "DIMS":
                let wc = try HeaderLexicalAnalyzer.analyse(stream: stream, endWith: .eol, flags: [.allowAssignment])
                dimLines.append(DimLineData(wc: wc, isString: sharpID == "DIMS", isPrivate: false, position: position))

            default:
                throw EmueraError.headerFileError(message: "Unknown directive #\(sharpID)", position: position)
            }
        }

        return true
    }

    /// Analyze #DEFINE directive
    private func analyzeSharpDefine(stream: StringStream, position: ScriptPosition) throws {
        guard let srcID = stream.readIdentifier() else {
            throw EmueraError.headerFileError(message: "Missing macro name", position: position)
        }

        // Check for name conflicts
        var errMes = ""
        var errLevel = -1
        idDic.checkUserMacroName(ref: &errMes, ref: &errLevel, name: srcID)

        if errLevel >= 0 {
            // Warning or error
            if errLevel >= 2 {
                noError = false
                return
            }
        }

        let hasArg = stream.current == "("
        let wc = try HeaderLexicalAnalyzer.analyse(stream: stream, endWith: .eol, flags: [.allowAssignment])

        if wc.eol {
            // Empty macro
            let nullmac = DefineMacro(keyword: srcID, statement: WordCollection(), argCount: 0)
            try idDic.addMacro(nullmac)
            return
        }

        var argID: [String] = []

        if hasArg {
            // Parse function-style macro arguments
            guard let next = stream.current, next == "(" else { return }
            stream.shiftNext()  // Skip (

            if stream.current == ")" {
                throw EmueraError.headerFileError(message: "Function macro cannot have 0 arguments", position: position)
            }

            while !wc.eol {
                guard let word = wc.current as? IdentifierWord else {
                    throw EmueraError.headerFileError(message: "Invalid argument format", position: position)
                }

                word.setAsMacro()
                let id = word.code

                if argID.contains(id) {
                    throw EmueraError.headerFileError(message: "Duplicate argument name: \(id)", position: position)
                }

                argID.append(id)
                wc.shiftNext()

                if wc.current is SymbolWord, (wc.current as! SymbolWord).symbol == "," {
                    wc.shiftNext()
                    continue
                }

                if wc.current is SymbolWord, (wc.current as! SymbolWord).symbol == ")" {
                    break
                }

                throw EmueraError.headerFileError(message: "Invalid argument format", position: position)
            }

            if wc.eol {
                throw EmueraError.headerFileError(message: "Missing closing )", position: position)
            }

            wc.shiftNext()  // Skip )
        }

        if wc.eol {
            throw EmueraError.headerFileError(message: "Missing macro body", position: position)
        }

        // Build destination word collection
        let destWc = WordCollection()
        while !wc.eol {
            destWc.add(wc.current)
            wc.shiftNext()
        }

        // Replace argument identifiers with MacroWord
        if hasArg {
            for i in 0..<destWc.collection.count {
                if let word = destWc.collection[i] as? IdentifierWord {
                    for (argIndex, arg) in argID.enumerated() {
                        if word.code == arg {
                            destWc.collection[i] = MacroWord(argIndex)
                            break
                        }
                    }
                }
            }
            destWc.pointer = 0
        }

        // Function-style macros are not supported in this version
        if hasArg {
            throw EmueraError.headerFileError(message: "Function-style macros not supported", position: position)
        }

        let mac = DefineMacro(keyword: srcID, statement: destWc, argCount: argID.count)
        try idDic.addMacro(mac)
    }

    /// Analyze #FUNCTION directive
    private func analyzeSharpFunction(stream: StringStream, position: ScriptPosition, isFunctions: Bool) throws {
        // Parse function declaration using FunctionIdentifier
        let function = try FunctionIdentifier.create(from: stream, isFunctions: isFunctions, position: position)

        // Check for name conflicts
        var errMes = ""
        var errLevel = -1
        idDic.checkUserMacroName(ref: &errMes, ref: &errLevel, name: function.name)

        if errLevel >= 0 {
            // Warning or error
            if errLevel >= 2 {
                noError = false
                return
            }
        }

        // Add function to identifier dictionary
        try idDic.addFunction(function)
    }

    /// Analyze all #DIM lines
    private func analyzeSharpDimLines() throws -> Bool {
        var noError = true
        var tryAgain = true
        var processedCount = 0

        while !dimLines.isEmpty {
            let count = dimLines.count
            processedCount = 0

            for _ in 0..<count {
                let dimLine = dimLines.removeFirst()

                do {
                    // Parse DIM line and create user-defined variable
                    let data = try UserDefinedVariableData.create(from: dimLine)

                    // Add to identifier dictionary
                    if let varName = data.name {
                        // Check for name conflicts first
                        var errMes = ""
                        var errLevel = -1
                        idDic.checkUserMacroName(ref: &errMes, ref: &errLevel, name: varName)

                        if errLevel >= 0 {
                            // Conflict detected
                            if errLevel >= 2 {
                                // Error level - don't process
                                print("Error: \(errMes)")
                                noError = false
                                continue
                            }
                        }

                        // Register in TokenData
                        try tokenData.registerUserDefinedVariable(data)

                        // Mark as processed
                        processedCount += 1
                        continue
                    }
                } catch let e as EmueraError {
                    if tryAgain {
                        dimLines.append(dimLine)
                    } else {
                        // Report error
                        print("Error: \(e.errorDescription ?? e.localizedDescription)")
                        noError = false
                    }
                } catch {
                    if tryAgain {
                        dimLines.append(dimLine)
                    } else {
                        noError = false
                    }
                }
            }

            if dimLines.count == count {
                // No progress made
                if processedCount == 0 {
                    tryAgain = false
                }
            }
        }

        return noError
    }

    // MARK: - Phase 5 新增辅助方法

    /// 保存预处理缓存
    private func savePreprocessedCache(filename: String, content: String) throws {
        guard let cacheDir = cacheDirectory else { return }

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: cacheDir) {
            try fileManager.createDirectory(atPath: cacheDir, withIntermediateDirectories: true)
        }

        let cacheFilename = filename + ".cache"
        let cachePath = (cacheDir as NSString).appendingPathComponent(cacheFilename)

        try content.write(toFile: cachePath, atomically: true, encoding: .utf8)
    }

    /// 检查并记录依赖关系
    private func recordDependency(parent: String, child: String) {
        if dependencyGraph[parent] == nil {
            dependencyGraph[parent] = []
        }
        if !dependencyGraph[parent]!.contains(child) {
            dependencyGraph[parent]!.append(child)
        }
    }

    /// 拓扑排序依赖关系
    public func getSortedDependencies() throws -> [String] {
        var graph: [String: [String]] = dependencyGraph
        var inDegree: [String: Int] = [:]

        // 初始化所有节点的入度
        for (parent, children) in graph {
            inDegree[parent] = inDegree[parent] ?? 0
            for child in children {
                inDegree[child] = (inDegree[child] ?? 0) + 1
            }
        }

        // 找到所有节点（包括没有依赖的）
        let allNodes = Set(graph.keys).union(graph.values.flatMap { $0 })
        for node in allNodes {
            if inDegree[node] == nil {
                inDegree[node] = 0
            }
        }

        // 拓扑排序
        var result: [String] = []
        var queue: [String] = allNodes.filter { inDegree[$0] == 0 }

        while !queue.isEmpty {
            let node = queue.removeFirst()
            result.append(node)

            if let children = graph[node] {
                for child in children {
                    inDegree[child, default: 0] -= 1
                    if inDegree[child] == 0 {
                        queue.append(child)
                    }
                }
            }
        }

        // 检查是否有循环依赖
        if result.count != allNodes.count {
            throw EmueraError.headerFileError(
                message: "检测到循环依赖，无法拓扑排序",
                position: nil
            )
        }

        return result
    }

    /// 清除缓存
    public func clearCache() {
        loadedFiles.removeAll()
        loadingStack.removeAll()
        dependencyGraph.removeAll()
        preprocessor?.clearCache()
    }
}

/// Simplified LexicalAnalyzer for header file parsing
private final class HeaderLexicalAnalyzer {
    enum LexEndWith {
        case eol
        case comma
    }

    struct LexAnalyzeFlag: OptionSet {
        let rawValue: Int
        static let allowAssignment = LexAnalyzeFlag(rawValue: 1 << 0)
    }

    /// Analyze a stream into WordCollection
    static func analyse(stream: StringStream, endWith: LexEndWith, flags: LexAnalyzeFlag) throws -> WordCollection {
        let wc = WordCollection()

        while !stream.eol {
            stream.skipWhitespace()

            guard let char = stream.current else { break }

            // Check end condition
            if endWith == .eol {
                // Continue to end of line
            } else if endWith == .comma && char == "," {
                break
            }

            // Skip comments
            if char == ";" {
                break
            }

            // Handle string literals
            if char == "\"" {
                if let str = stream.readQuotedString() {
                    wc.add(LiteralStringWord(str))
                    continue
                }
            }

            // Handle numbers
            if char.isNumber {
                if let num = stream.readInteger() {
                    wc.add(LiteralIntegerWord(num))
                    continue
                }
            }

            // Handle identifiers
            if char.isLetter || char == "_" {
                if let id = stream.readIdentifier() {
                    wc.add(IdentifierWord(id))
                    continue
                }
            }

            // Handle operators
            if let op = tryReadOperator(stream: stream) {
                wc.add(OperatorWord(op))
                continue
            }

            // Handle symbols
            if "+-*/%=&|<>!^~".contains(char) {
                wc.add(SymbolWord(char))
                stream.shiftNext()
                continue
            }

            // Handle parentheses and brackets
            if "(),:".contains(char) {
                wc.add(SymbolWord(char))
                stream.shiftNext()
                continue
            }

            // Unknown character
            stream.shiftNext()
        }

        return wc
    }

    /// Try to read multi-character operators
    private static func tryReadOperator(stream: StringStream) -> OperatorCode? {
        let start = stream.current ?? "\0"
        let next = stream.peek() ?? "\0"

        // Two-character operators
        if start == "*" && next == "*" { stream.shiftNext(); stream.shiftNext(); return .power }
        if start == "=" && next == "=" { stream.shiftNext(); stream.shiftNext(); return .equal }
        if start == "!" && next == "=" { stream.shiftNext(); stream.shiftNext(); return .notEqual }
        if start == "<" && next == "=" { stream.shiftNext(); stream.shiftNext(); return .lessEqual }
        if start == ">" && next == "=" { stream.shiftNext(); stream.shiftNext(); return .greaterEqual }
        if start == "&" && next == "&" { stream.shiftNext(); stream.shiftNext(); return .and }
        if start == "|" && next == "|" { stream.shiftNext(); stream.shiftNext(); return .or }
        if start == "+" && next == "=" { stream.shiftNext(); stream.shiftNext(); return .addAssign }
        if start == "-" && next == "=" { stream.shiftNext(); stream.shiftNext(); return .subtractAssign }
        if start == "*" && next == "=" { stream.shiftNext(); stream.shiftNext(); return .multiplyAssign }
        if start == "/" && next == "=" { stream.shiftNext(); stream.shiftNext(); return .divideAssign }
        if start == "<" && next == "<" { stream.shiftNext(); stream.shiftNext(); return .shiftLeft }
        if start == ">" && next == ">" { stream.shiftNext(); stream.shiftNext(); return .shiftRight }

        // Single-character operators
        if start == "+" { stream.shiftNext(); return .add }
        if start == "-" { stream.shiftNext(); return .subtract }
        if start == "*" { stream.shiftNext(); return .multiply }
        if start == "/" { stream.shiftNext(); return .divide }
        if start == "%" { stream.shiftNext(); return .modulo }
        if start == "=" { stream.shiftNext(); return .assign }
        if start == "!" { stream.shiftNext(); return .not }
        if start == "<" { stream.shiftNext(); return .less }
        if start == ">" { stream.shiftNext(); return .greater }
        if start == "&" { stream.shiftNext(); return .bitAnd }
        if start == "|" { stream.shiftNext(); return .bitOr }
        if start == "^" { stream.shiftNext(); return .bitXor }
        if start == "~" { stream.shiftNext(); return .bitNot }

        return nil
    }
}
