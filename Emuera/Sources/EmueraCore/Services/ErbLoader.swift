//
//  ErbLoader.swift
//  EmueraCore
//
//  ERB脚本加载器 - 相当于Windows版的ErbLoader.cs
//  负责扫描和加载所有ERB文件
//
//  Created: 2025-12-20
//

import Foundation

/// ERB文件加载器
public final class ErbLoader {

    private let fileManager: FileManager

    public init() {
        self.fileManager = FileManager.default
    }

    /// 加载指定目录下的所有ERB文件
    /// - Parameters:
    ///   - erbDir: ERB目录路径
    ///   - displayReport: 是否显示加载报告
    ///   - labelDictionary: 标签字典（用于存储函数和标签）
    /// - Returns: 是否加载成功
    public func loadErbFiles(
        _ erbDir: String,
        displayReport: Bool = false,
        labelDictionary: LabelDictionary
    ) -> Bool {
        // 1. 获取所有ERB文件
        guard let erbFiles = getFiles(in: erbDir, pattern: "*.ERB") else {
            print("⚠️ 无法扫描ERB目录: \(erbDir)")
            return false
        }

        if erbFiles.isEmpty {
            print("⚠️ 在 \(erbDir) 中未找到ERB文件")
            return false
        }

        // 2. 加载报告
        if displayReport {
            print("📊 发现 \(erbFiles.count) 个ERB文件:")
            for file in erbFiles {
                print("  - \(file.key)")
            }
        }

        // 3. 逐个文件加载（简化版本：仅扫描文件）
        var totalLines = 0
        var success = true

        for (relativePath, fullPath) in erbFiles {
            if let lineCount = scanErbFile(fullPath, filename: relativePath) {
                totalLines += lineCount
                if displayReport {
                    print("  ✅ \(relativePath) - \(lineCount) 行")
                }
            } else {
                print("  ❌ \(relativePath) - 读取失败")
                success = false
            }
        }

        if success && displayReport {
            print("📊 总计: \(totalLines) 行代码")
        }

        return success
    }

    /// 加载指定的ERB文件列表（分析模式）
    /// - Parameters:
    ///   - files: 文件路径列表
    ///   - labelDictionary: 标签字典
    /// - Returns: 是否加载成功
    public func loadErbs(_ files: [String], labelDictionary: LabelDictionary) -> Bool {
        var success = true
        var totalLines = 0

        for file in files {
            let filename = URL(fileURLWithPath: file).lastPathComponent
            if let lineCount = scanErbFile(file, filename: filename) {
                totalLines += lineCount
                print("✅ \(filename) - \(lineCount) 行")
            } else {
                print("❌ \(filename) - 读取失败")
                success = false
            }
        }

        if success {
            print("📊 总计: \(totalLines) 行代码")
        }

        return success
    }

    /// 扫描ERB文件（统计行数）
    private func scanErbFile(_ filepath: String, filename: String) -> Int? {
        do {
            // 尝试UTF-8
            var content = try? String(contentsOfFile: filepath, encoding: .utf8)

            // 尝试Shift-JIS
            if content == nil {
                content = try? String(contentsOfFile: filepath, encoding: .shiftJIS)
            }

            guard let fileContent = content else {
                return nil
            }

            // 统计有效行数（排除注释和空行）
            let lines = fileContent.components(separatedBy: .newlines)
            var validLines = 0

            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty && !trimmed.hasPrefix(";") && !trimmed.hasPrefix("//") {
                    validLines += 1
                }
            }

            return validLines

        } catch {
            return nil
        }
    }

    /// 获取目录下的所有匹配文件
    /// - Parameters:
    ///   - dir: 目录路径
    ///   - pattern: 文件模式（如 "*.ERB"）
    /// - Returns: [相对路径: 完整路径] 的字典
    private func getFiles(in dir: String, pattern: String) -> [String: String]? {
        guard fileManager.fileExists(atPath: dir) else {
            return nil
        }

        var result: [String: String] = [:]

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: dir)

            for item in contents {
                // 检查是否匹配模式
                if matchesPattern(item, pattern: pattern) {
                    let fullPath = dir + "/" + item
                    result[item] = fullPath
                }
            }

            // 如果需要，可以递归搜索子目录
            // 这里暂时只搜索顶层目录，与Windows版默认行为一致

        } catch {
            print("❌ 无法读取目录 \(dir): \(error)")
            return nil
        }

        return result
    }

    /// 检查文件名是否匹配模式
    private func matchesPattern(_ filename: String, pattern: String) -> Bool {
        if pattern == "*.ERB" {
            return filename.uppercased().hasSuffix(".ERB")
        }
        // 可以扩展其他模式
        return filename == pattern
    }
}

