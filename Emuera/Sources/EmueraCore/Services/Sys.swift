//
//  Sys.swift
//  EmueraCore
//
//  系统服务 - 获取可执行文件路径和目录
//  相当于Windows版的Sys.cs
//
//  Created: 2025-12-20
//

import Foundation

/// 系统服务 - 提供可执行文件路径管理
/// 相当于Windows版的Sys类
public final class Sys {

    // MARK: - 静态属性

    /// 可执行文件完整路径
    public static let exePath: String = {
        // 在macOS应用中，使用Bundle更可靠
        if let path = Bundle.main.executablePath {
            return path
        }
        // 回退到ProcessInfo
        return CommandLine.arguments.first ?? ""
    }()

    /// 可执行文件所在目录（以/结尾）
    public static let exeDir: String = {
        // 在macOS应用中，使用Bundle更可靠
        if let path = Bundle.main.executablePath {
            let url = URL(fileURLWithPath: path)
            return url.deletingLastPathComponent().path + "/"
        }
        // 回退到ProcessInfo
        if let firstArg = CommandLine.arguments.first {
            let url = URL(fileURLWithPath: firstArg)
            return url.deletingLastPathComponent().path + "/"
        }
        return "./"
    }()

    /// 可执行文件名（不含扩展名）
    public static let exeName: String = {
        if let path = Bundle.main.executablePath {
            let url = URL(fileURLWithPath: path)
            return url.deletingPathExtension().lastPathComponent
        }
        if let firstArg = CommandLine.arguments.first {
            let url = URL(fileURLWithPath: firstArg)
            return url.deletingPathExtension().lastPathComponent
        }
        return "emuera"
    }()

    /// 可执行文件名（含扩展名）
    public static let exeFileName: String = {
        if let path = Bundle.main.executablePath {
            let url = URL(fileURLWithPath: path)
            return url.lastPathComponent
        }
        if let firstArg = CommandLine.arguments.first {
            let url = URL(fileURLWithPath: firstArg)
            return url.lastPathComponent
        }
        return "emuera"
    }()

    // MARK: - 子目录路径（基于Windows版结构）

    /// CSV文件目录
    public static var csvDir: String {
        return exeDir + "csv/"
    }

    /// ERB脚本目录
    public static var erbDir: String {
        return exeDir + "erb/"
    }

    /// 调试文件目录
    public static var debugDir: String {
        return exeDir + "debug/"
    }

    /// 数据文件目录
    public static var datDir: String {
        return exeDir + "dat/"
    }

    /// 资源文件目录
    public static var resourcesDir: String {
        return exeDir + "resources/"
    }

    /// 存档文件目录
    public static var saveDir: String {
        return exeDir + "save/"
    }

    // MARK: - 配置文件路径

    /// 主配置文件路径
    public static var configPath: String {
        return exeDir + "emuera.config"
    }

    /// 调试配置文件路径
    public static var debugConfigPath: String {
        return debugDir + "debug.config"
    }

    // MARK: - 目录检查方法

    /// 检查必需目录是否存在
    /// - Returns: (存在, 缺失的目录列表)
    public static func checkRequiredDirectories() -> (Bool, [String]) {
        var missing: [String] = []

        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: csvDir) {
            missing.append("csv/")
        }

        if !fileManager.fileExists(atPath: erbDir) {
            missing.append("erb/")
        }

        return (missing.isEmpty, missing)
    }

    /// 创建必需的目录结构
    public static func createRequiredDirectories() throws {
        let fileManager = FileManager.default

        let directories = [
            csvDir,
            erbDir,
            debugDir,
            datDir,
            resourcesDir,
            saveDir
        ]

        for dir in directories {
            if !fileManager.fileExists(atPath: dir) {
                try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true)
            }
        }
    }

    /// 检查是否为可执行文件所在目录的游戏包
    /// - Returns: 是否包含标准游戏结构
    public static func isGamePackage() -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: csvDir) &&
               fileManager.fileExists(atPath: erbDir)
    }

    // MARK: - 路径辅助方法

    /// 获取相对路径（相对于exe目录）
    /// - Parameter fullPath: 完整路径
    /// - Returns: 相对路径
    public static func getRelativePath(_ fullPath: String) -> String {
        if fullPath.hasPrefix(exeDir) {
            return String(fullPath.dropFirst(exeDir.count))
        }
        return fullPath
    }

    /// 获取文件名（不含路径）
    /// - Parameter path: 路径
    /// - Returns: 文件名
    public static func getFileName(_ path: String) -> String {
        return URL(fileURLWithPath: path).lastPathComponent
    }

    /// 获取文件名（不含扩展名）
    /// - Parameter path: 路径
    /// - Returns: 文件名（无扩展名）
    public static func getFileNameWithoutExtension(_ path: String) -> String {
        return URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    }

    // MARK: - 调试信息

    /// 打印系统信息（用于调试）
    public static func printSystemInfo() {
        print("=== Sys System Info ===")
        print("ExePath: \(exePath)")
        print("ExeDir: \(exeDir)")
        print("ExeName: \(exeName)")
        print("CSV Dir: \(csvDir)")
        print("ERB Dir: \(erbDir)")
        print("Config: \(configPath)")
        print("========================")
    }
}
