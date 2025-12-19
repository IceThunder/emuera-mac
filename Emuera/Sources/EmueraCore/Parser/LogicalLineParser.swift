//
//  LogicalLineParser.swift
//  EmueraCore
//
//  逻辑行解析器 - 处理续行@、注释、多行逻辑合并
//  将物理行合并为逻辑行
//  Created: 2025-12-19
//

import Foundation

/// 逻辑行解析器
/// 功能:
/// 1. 处理续行符号 @ - 将多行合并为一个逻辑行
/// 2. 移除注释
/// 3. 处理行内空白
public class LogicalLineParser {
    public init() {}

    /// 解析源代码，返回逻辑行列表
    /// - Parameter source: 原始脚本源码
    /// - Returns: 逻辑行数组（每个元素是一行完整的逻辑行）
    public func parse(_ source: String) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        var inContinuation = false

        // 按行分割
        let rawLines = source.components(separatedBy: "\n")

        for (index, rawLine) in rawLines.enumerated() {
            let lineNum = index + 1
            let processed = processLine(rawLine, lineNum: lineNum)

            if processed.isEmpty {
                continue
            }

            // 检查是否以续行符号@结尾
            if processed.hasSuffix("@") {
                // 移除末尾的@，并累积
                let withoutAt = String(processed.dropLast()).trimmingCharacters(in: .whitespaces)
                if inContinuation {
                    currentLine += " " + withoutAt
                } else {
                    currentLine = withoutAt
                }
                inContinuation = true
            } else {
                // 不是续行，完成当前逻辑行
                if inContinuation {
                    currentLine += " " + processed
                    lines.append(currentLine)
                    currentLine = ""
                    inContinuation = false
                } else {
                    lines.append(processed)
                }
            }
        }

        // 处理文件末尾的续行
        if inContinuation && !currentLine.isEmpty {
            lines.append(currentLine)
        }

        return lines.filter { !$0.isEmpty }
    }

    /// 处理单行：移除注释、处理空白
    private func processLine(_ line: String, lineNum: Int) -> String {
        var result = ""
        var i = 0
        let chars = Array(line)
        var inString = false
        var stringChar: Character? = nil

        while i < chars.count {
            let c = chars[i]

            // 处理字符串内的字符（不解析注释）
            if inString {
                result.append(c)
                if c == stringChar! {
                    inString = false
                    stringChar = nil
                }
                i += 1
                continue
            }

            // 开始字符串
            if c == "\"" || c == "'" {
                result.append(c)
                stringChar = c
                inString = true
                i += 1
                continue
            }

            // 遇到注释符号（不在字符串内）
            if c == ";" {
                // 注释开始，剩余部分全部忽略
                break
            }

            // 遇到续行符号@（不在字符串内）
            if c == "@" {
                // 保留@，但移除前面的空白
                result = result.trimmingCharacters(in: .whitespaces)
                result.append("@")
                // @之后的内容（除了可能的注释）都保留
                i += 1
                while i < chars.count {
                    if chars[i] == ";" {
                        break
                    }
                    result.append(chars[i])
                    i += 1
                }
                break
            }

            result.append(c)
            i += 1
        }

        // 移除首尾空白
        result = result.trimmingCharacters(in: .whitespaces)

        return result
    }

    /// 预处理：合并续行并移除注释
    /// - Parameter source: 原始源码
    /// - Returns: 预处理后的源码（已合并续行、移除注释）
    public func preprocess(_ source: String) -> String {
        let lines = parse(source)
        return lines.joined(separator: "\n")
    }

    /// 解析并返回带行号的逻辑行
    /// - Parameter source: 原始源码
    /// - Returns: 逻辑行数组，每个包含行号和内容
    public func parseWithLineNumbers(_ source: String) -> [(lineNumber: Int, content: String)] {
        var result: [(Int, String)] = []
        var currentLine = ""
        var currentLineNum = 1
        var inContinuation = false
        var startLineNum = 1

        let rawLines = source.components(separatedBy: "\n")

        for (index, rawLine) in rawLines.enumerated() {
            let lineNum = index + 1
            let processed = processLine(rawLine, lineNum: lineNum)

            if processed.isEmpty {
                continue
            }

            if processed.hasSuffix("@") {
                let withoutAt = String(processed.dropLast()).trimmingCharacters(in: .whitespaces)
                if !inContinuation {
                    startLineNum = lineNum
                    currentLine = withoutAt
                } else {
                    currentLine += " " + withoutAt
                }
                inContinuation = true
            } else {
                if inContinuation {
                    currentLine += " " + processed
                    result.append((startLineNum, currentLine))
                    currentLine = ""
                    inContinuation = false
                } else {
                    result.append((lineNum, processed))
                }
            }
        }

        if inContinuation && !currentLine.isEmpty {
            result.append((startLineNum, currentLine))
        }

        return result.filter { !$0.1.isEmpty }
    }
}
