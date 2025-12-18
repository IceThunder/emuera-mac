//
//  SimpleExecutor.swift
//  EmueraCore
//
//  MVP版核心命令执行器
//  Created: 2025-12-18
//

import Foundation

/// 执行环境 - 存储变量和执行状态
public struct ExecutionEnvironment {
    public var variables: [String: VariableValue]
    public var output: [String]
    public var shouldQuit: Bool
    public var lastResult: VariableValue

    public init() {
        variables = [:]
        output = []
        shouldQuit = false
        lastResult = .null
    }
}

/// 简单命令执行器 - 支持MVP核心5命令 + 表达式解析
public class SimpleExecutor {

    // 持久的执行环境，用于跨脚本调用
    private var persistentEnv: ExecutionEnvironment?

    public init() {}

    /// 执行Token序列，返回输出结果
    /// - Parameter tokens: Token序列
    /// - Parameter usePersistentEnv: 是否使用持久环境（与上次执行共享变量）
    public func execute(tokens: [TokenType.Token], usePersistentEnv: Bool = false) -> [String] {
        // 从上次状态恢复或新建持久环境
        let savedEnv = usePersistentEnv ? (persistentEnv ?? ExecutionEnvironment()) : ExecutionEnvironment()

        // 创建工作环境（每次执行独立，不影响持久环境）
        var workEnv = ExecutionEnvironment()
        workEnv.variables = savedEnv.variables  // 复制变量
        workEnv.lastResult = savedEnv.lastResult

        var i = 0
        while i < tokens.count {
            let token = tokens[i]

            // 跳过换行符和空白
            let isSkip: Bool
            switch token.type {
            case .lineBreak, .whitespace:
                isSkip = true
            default:
                isSkip = false
            }
            if isSkip {
                i += 1
                continue
            }

            // 处理命令
            if case .command(let cmd) = token.type {
                let upperCmd = cmd.uppercased()

                switch upperCmd {
                case "PRINT":
                    let resultTuple = parseAndExecuteExpression(tokens: tokens, startIndex: i + 1, env: workEnv)
                    workEnv.output.append(resultTuple.value.description)
                    i = resultTuple.newIndex
                    continue

                case "PRINTL":
                    let resultTuple = parseAndExecuteExpression(tokens: tokens, startIndex: i + 1, env: workEnv)
                    workEnv.output.append(resultTuple.value.description + "\n")
                    i = resultTuple.newIndex
                    continue

                case "PRINTW":
                    let resultTuple = parseAndExecuteExpression(tokens: tokens, startIndex: i + 1, env: workEnv)
                    workEnv.output.append(resultTuple.value.description)
                    workEnv.output.append("按回车继续...")
                    i = resultTuple.newIndex
                    continue

                case "WAIT":
                    workEnv.output.append("按回车继续...")
                    i += 1
                    continue

                case "INPUT":
                    workEnv.output.append("[等待输入]")
                    i += 1
                    continue

                case "QUIT":
                    workEnv.output.append("程序已退出")
                    workEnv.shouldQuit = true
                    i += 1
                    continue

                default:
                    break
                }
            }

            // 处理变量赋值: A = 表达式
            if case .variable(let varName) = token.type {
                if i + 1 < tokens.count,
                   case .operatorSymbol(let op) = tokens[i + 1].type,
                   op == .assign {

                    let resultTuple = parseAndExecuteExpression(tokens: tokens, startIndex: i + 2, env: workEnv)
                    workEnv.variables[varName] = resultTuple.value
                    workEnv.lastResult = resultTuple.value
                    i = resultTuple.newIndex
                    continue
                }
            }

            // 处理不带命令的表达式 (裸表达式直接输出)
            let isExpressionStart: Bool
            switch token.type {
            case .integer, .string, .variable:
                isExpressionStart = true
            default:
                isExpressionStart = false
            }
            if isExpressionStart {
                let resultTuple = parseAndExecuteExpression(tokens: tokens, startIndex: i, env: workEnv)
                workEnv.output.append(resultTuple.value.description)
                i = resultTuple.newIndex
                continue
            }

            // 未知token，跳过
            i += 1
        }

        // 如果使用持久环境，保存工作环境的变量状态到持久环境
        if usePersistentEnv {
            var newPersistent = ExecutionEnvironment()
            newPersistent.variables = workEnv.variables
            newPersistent.output = []  // 输出不持久化
            newPersistent.lastResult = workEnv.lastResult
            persistentEnv = newPersistent
        }

        return workEnv.output
    }

    /// 解析并执行表达式
    private func parseAndExecuteExpression(tokens: [TokenType.Token], startIndex: Int, env: ExecutionEnvironment) -> (value: VariableValue, newIndex: Int) {
        // 找到表达式结束位置 (到lineBreak或命令开始)
        var endIndex = startIndex
        while endIndex < tokens.count {
            let token = tokens[endIndex]
            switch token.type {
            case .lineBreak, .command:
                break
            default:
                endIndex += 1
            }
        }

        if startIndex >= endIndex {
            return (.null, endIndex)
        }

        let exprTokens = Array(tokens[startIndex..<endIndex])

        // 单独的变量处理（优化）
        if exprTokens.count == 1, case .variable(let name) = exprTokens[0].type {
            if let val = env.variables[name] {
                return (val, endIndex)
            }
            return (.integer(0), endIndex)
        }

        // 使用表达式解析器
        do {
            let parser = ExpressionParser()
            let exprNode = try parser.parse(exprTokens)
            let evaluator = ExpressionEvaluator(variableData: createVariableData(env: env))
            let result = try evaluator.evaluate(exprNode)
            return (result, endIndex)
        } catch {
            // 降级：尝试逐个token处理
            if let first = exprTokens.first {
                switch first.type {
                case .integer(let value): return (.integer(value), endIndex)
                case .string(let value): return (.string(value), endIndex)
                case .variable(let name):
                    if let val = env.variables[name] { return (val, endIndex) }
                    return (.integer(0), endIndex)
                default: break
                }
            }
            return (.null, endIndex)
        }
    }

    /// 从ExecutionEnvironment创建VariableData
    private func createVariableData(env: ExecutionEnvironment) -> VariableData {
        let data = VariableData()
        // 复制当前环境中的变量
        for (name, value) in env.variables {
            data.setVariable(name, value: value)
        }
        return data
    }

    /// 为测试提供的便捷方法：执行单个脚本字符串
    public func executeScript(_ script: String) -> [String] {
        let lexer = LexicalAnalyzer()
        let tokens = lexer.tokenize(script)
        return execute(tokens: tokens)
    }

    /// 重置持久环境
    public func resetPersistentEnv() {
        persistentEnv = nil
    }
}
