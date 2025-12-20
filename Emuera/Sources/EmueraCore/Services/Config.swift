//
//  Config.swift
//  EmueraCore
//
//  配置管理器 - 相当于Windows版的Config.cs和ConfigData.cs
//  负责加载和管理emuera.config配置文件
//
//  Created: 2025-12-20
//

import Foundation

/// 配置管理器
public final class Config {

    // MARK: - 静态属性

    /// 单例实例
    public static let shared = Config()

    /// 配置数据
    public private(set) var data: ConfigData = ConfigData()

    /// 文件编码（用于读取脚本）
    public var scriptEncoding: String.Encoding = .shiftJIS

    /// 保存文件编码
    public var saveEncoding: String.Encoding = .shiftJIS

    /// 是否显示加载报告
    public var displayReport: Bool = false

    /// 是否使用子目录搜索
    public var searchSubdirectory: Bool = false

    /// 是否按文件名排序
    public var sortWithFilename: Bool = true

    /// 是否使用独立存档目录
    public var useSaveFolder: Bool = true

    // MARK: - 配置文件路径

    /// 默认配置文件路径
    public var defaultConfigPath: String {
        return Sys.csvDir + "_default.config"
    }

    /// 主配置文件路径
    public var configPath: String {
        return Sys.exeDir + "emuera.config"
    }

    /// 固定配置文件路径
    public var fixedConfigPath: String {
        return Sys.csvDir + "_fixed.config"
    }

    /// 存档目录路径
    public var saveDir: String {
        return Sys.saveDir
    }

    // MARK: - 配置加载

    /// 加载配置文件
    /// - Returns: 是否加载成功
    public func loadConfig() -> Bool {
        var success = true

        // 1. 加载默认配置（最低优先级）
        if !loadConfigFile(defaultConfigPath, isFixed: false) {
            print("⚠️ 未找到默认配置文件: \(defaultConfigPath)")
        }

        // 2. 加载主配置文件（中等优先级）
        if !loadConfigFile(configPath, isFixed: false) {
            print("ℹ️ 未找到主配置文件: \(configPath)")
        }

        // 3. 加载固定配置（最高优先级）
        if !loadConfigFile(fixedConfigPath, isFixed: true) {
            print("ℹ️ 未找到固定配置文件: \(fixedConfigPath)")
        }

        return success
    }

    /// 加载单个配置文件
    /// - Parameters:
    ///   - path: 配置文件路径
    ///   - isFixed: 是否为固定配置（覆盖其他配置）
    /// - Returns: 是否加载成功
    private func loadConfigFile(_ path: String, isFixed: Bool) -> Bool {
        guard fileManager.fileExists(atPath: path) else {
            return false
        }

        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)

            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

                // 跳过空行和注释
                if trimmed.isEmpty || trimmed.hasPrefix(";") || trimmed.hasPrefix("//") {
                    continue
                }

                // 解析配置项
                parseConfigLine(trimmed, isFixed: isFixed)
            }

            print("✅ \(isFixed ? "固定" : "用户")配置已加载: \(path)")
            return true

        } catch {
            // 尝试Shift-JIS编码
            if let content = try? String(contentsOfFile: path, encoding: .shiftJIS) {
                let lines = content.components(separatedBy: .newlines)
                for line in lines {
                    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty || trimmed.hasPrefix(";") || trimmed.hasPrefix("//") {
                        continue
                    }
                    parseConfigLine(trimmed, isFixed: isFixed)
                }
                print("✅ \(isFixed ? "固定" : "用户")配置已加载（Shift-JIS）: \(path)")
                return true
            }

            print("❌ 无法加载配置文件 \(path): \(error)")
            return false
        }
    }

    /// 解析单行配置
    /// - Parameters:
    ///   - line: 配置行
    ///   - isFixed: 是否为固定配置
    private func parseConfigLine(_ line: String, isFixed: Bool) {
        let components = line.components(separatedBy: ",")
        if components.count < 2 {
            return
        }

        let key = components[0].trimmingCharacters(in: .whitespaces).uppercased()
        let value = components[1...].joined(separator: ",").trimmingCharacters(in: .whitespaces)

        // 如果是固定配置，或者当前值未设置，才更新
        if isFixed || !data.isSet(key) {
            data.set(key, value: value)
        }
    }

    // MARK: - 文件扫描

    /// 获取目录下的所有匹配文件
    /// - Parameters:
    ///   - rootDir: 根目录
    ///   - pattern: 文件模式（如 "*.ERB"）
    /// - Returns: [相对路径: 完整路径] 的数组
    public func getFiles(in rootDir: String, pattern: String) -> [(key: String, value: String)]? {
        guard fileManager.fileExists(atPath: rootDir) else {
            return nil
        }

        var result: [(key: String, value: String)] = []

        // 递归搜索子目录
        if searchSubdirectory {
            if let files = getFilesRecursive(rootDir, rootDir: rootDir, pattern: pattern) {
                result.append(contentsOf: files)
            }
        } else {
            // 只搜索顶层目录
            if let files = getFilesInDirectory(rootDir, rootDir: rootDir, pattern: pattern) {
                result.append(contentsOf: files)
            }
        }

        // 排序
        if sortWithFilename {
            result.sort { $0.key < $1.key }
        }

        return result
    }

    /// 递归获取文件
    private func getFilesRecursive(_ dir: String, rootDir: String, pattern: String) -> [(key: String, value: String)]? {
        var result: [(key: String, value: String)] = []

        // 获取当前目录文件
        if let files = getFilesInDirectory(dir, rootDir: rootDir, pattern: pattern) {
            result.append(contentsOf: files)
        }

        // 递归子目录
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: dir)
            for item in contents {
                let fullPath = dir + "/" + item
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                    if let subFiles = getFilesRecursive(fullPath, rootDir: rootDir, pattern: pattern) {
                        result.append(contentsOf: subFiles)
                    }
                }
            }
        } catch {
            return nil
        }

        return result.isEmpty ? nil : result
    }

    /// 获取单个目录的文件
    private func getFilesInDirectory(_ dir: String, rootDir: String, pattern: String) -> [(key: String, value: String)]? {
        var result: [(key: String, value: String)] = []

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: dir)
            for item in contents {
                if matchesPattern(item, pattern: pattern) {
                    let fullPath = dir + "/" + item
                    let relativePath = getRelativePath(fullPath, rootDir: rootDir)
                    result.append((key: relativePath, value: fullPath))
                }
            }
        } catch {
            return nil
        }

        return result.isEmpty ? nil : result
    }

    /// 检查文件名是否匹配模式
    private func matchesPattern(_ filename: String, pattern: String) -> Bool {
        if pattern.uppercased() == "*.ERB" {
            return filename.uppercased().hasSuffix(".ERB")
        }
        if pattern.uppercased() == "*.ERH" {
            return filename.uppercased().hasSuffix(".ERH")
        }
        // 可以扩展其他模式
        return filename == pattern
    }

    /// 获取相对路径
    private func getRelativePath(_ fullPath: String, rootDir: String) -> String {
        if fullPath.hasPrefix(rootDir) {
            return String(fullPath.dropFirst(rootDir.count))
        }
        return fullPath
    }

    // MARK: - 存档目录管理

    /// 创建存档目录
    public func createSaveDirectory() {
        guard useSaveFolder else { return }

        let saveDirPath = saveDir
        if !fileManager.fileExists(atPath: saveDirPath) {
            do {
                try fileManager.createDirectory(atPath: saveDirPath, withIntermediateDirectories: true)
                print("✅ 创建存档目录: \(saveDirPath)")
            } catch {
                print("❌ 无法创建存档目录: \(error)")
            }
        }
    }

    // MARK: - 私有属性

    private let fileManager: FileManager = .default
}

// MARK: - ConfigData

/// 配置数据
public struct ConfigData {

    private var settings: [String: String] = [:]

    /// 检查配置项是否已设置
    public func isSet(_ key: String) -> Bool {
        return settings[key] != nil
    }

    /// 设置配置项
    public mutating func set(_ key: String, value: String) {
        settings[key] = value
        applySetting(key, value: value)
    }

    /// 获取配置项
    public func get(_ key: String) -> String? {
        return settings[key]
    }

    /// 获取字符串配置
    public func getString(_ key: String, default: String = "") -> String {
        return settings[key] ?? `default`
    }

    /// 获取整数配置
    public func getInt(_ key: String, default: Int = 0) -> Int {
        guard let value = settings[key], let int = Int(value) else {
            return `default`
        }
        return int
    }

    /// 获取布尔配置
    public func getBool(_ key: String, default: Bool = false) -> Bool {
        guard let value = settings[key] else {
            return `default`
        }
        let lower = value.lowercased()
        return lower == "true" || lower == "1" || lower == "yes"
    }

    /// 应用配置项到Config
    private mutating func applySetting(_ key: String, value: String) {
        switch key.uppercased() {
        case "SCRIPT_ENCODE", "ENCODE":
            // 设置脚本编码
            if value.uppercased().contains("UTF") {
                Config.shared.scriptEncoding = .utf8
            } else if value.uppercased().contains("SHIFTJIS") || value.uppercased().contains("SJIS") {
                Config.shared.scriptEncoding = .shiftJIS
            }

        case "SAVE_ENCODE":
            // 设置保存编码
            if value.uppercased().contains("UTF") {
                Config.shared.saveEncoding = .utf8
            } else if value.uppercased().contains("SHIFTJIS") || value.uppercased().contains("SJIS") {
                Config.shared.saveEncoding = .shiftJIS
            }

        case "DISPLAY_REPORT":
            Config.shared.displayReport = getBool(key, default: false)

        case "SEARCH_SUBDIRECTORY":
            Config.shared.searchSubdirectory = getBool(key, default: false)

        case "SORT_WITH_FILENAME":
            Config.shared.sortWithFilename = getBool(key, default: true)

        case "USE_SAVE_FOLDER":
            Config.shared.useSaveFolder = getBool(key, default: true)

        default:
            // 其他配置项可以在这里处理
            break
        }
    }
}