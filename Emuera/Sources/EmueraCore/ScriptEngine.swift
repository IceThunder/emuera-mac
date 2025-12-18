//
//  ScriptEngine.swift
//  EmueraCore
//
//  脚本引擎 - 连接词法分析和执行器
//  Created: 2025-12-18
//

import Foundation

/// MVP脚本引擎 - 调度器
public class ScriptEngine {
    private let lexer: LexicalAnalyzer
    private let executor: SimpleExecutor

    // 是否在脚本执行间保持变量状态
    public var persistentState: Bool = true

    public init() {
        lexer = LexicalAnalyzer()
        executor = SimpleExecutor()
    }

    /// 运行脚本并返回输出数组
    /// - Parameter script: ERB脚本字符串
    /// - Returns: 执行输出结果
    public func run(_ script: String) -> [String] {
        let tokens = lexer.tokenize(script)
        let outputs = executor.execute(tokens: tokens, usePersistentEnv: persistentState)
        return outputs
    }

    /// 运行脚本并返回单个字符串（方便日志显示）
    /// - Parameter script: ERB脚本字符串
    /// - Returns: 合并后的执行结果
    public func runAndCombine(_ script: String) -> String {
        let outputs = run(script)
        return outputs.joined()
    }

    /// 获取脚本的Token列表（用于调试）
    /// - Parameter script: ERB脚本字符串
    /// - Returns: Token数组
    public func getTokens(_ script: String) -> [TokenType.Token] {
        return lexer.tokenize(script)
    }

    /// 执行外部提供的Token序列（用于高级功能）
    /// - Parameter tokens: Token数组
    /// - Returns: 执行输出结果
    public func executeTokens(_ tokens: [TokenType.Token]) -> [String] {
        return executor.execute(tokens: tokens, usePersistentEnv: persistentState)
    }

    /// 重置所有持久化状态（变量、数组等）
    public func reset() {
        executor.resetPersistentEnv()
    }
}
