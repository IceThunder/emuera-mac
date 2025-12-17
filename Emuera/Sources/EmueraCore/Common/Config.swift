//
//  Config.swift
//  EmueraCore
//
//  Configuration management compatible with emuera.config
//  Created on 2025-12-18
//

import Foundation

/// Emuera配置系统
public struct Config: Codable {
    // 文件编码
    public var encoding: String = "Shift_JIS"

    // 字体设置
    public var fontName: String = "MS Gothic"
    public var fontSize: Int = 14

    // 颜色设置
    public var foregroundColor: String = "#FFFFFF"
    public var backgroundColor: String = "#000000"
    public var linkColor: String = "#0000FF"

    // 显示设置
    public var fps: Int = 60
    public var drawLineString: String = "ー"
    public var loadLabel: String = "データ読み込み中..."

    // 功能开关
    public var useKeyMacro: Bool = true
    public var useReplaceFile: Bool = true
    public var useRenameFile: Bool = true
    public var allowMultipleInstances: Bool = false
    public var displayReport: Bool = true

    // 循环检测
    public var infiniteLoopAlertTime: UInt = 5000 // ms

    // 单例实例
    public static var instance = Config()

    private init() {}

    /// 从JSON配置文件加载
    public static func load(from path: String) throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        instance = try decoder.decode(Config.self, from: data)
    }

    /// 保存到JSON配置文件
    public func save(to path: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: URL(fileURLWithPath: path))
    }

    /// 默认配置（用于首次运行）
    public static func defaultConfig() -> Config {
        return Config()
    }
}

/// 路径配置（兼容原版目录结构）
public struct PathConfig {
    public static var exeDir: String = "./"
    public static var csvDir: String = "./csv/"
    public static var erbDir: String = "./erb/"
    public static var debugDir: String = "./debug/"
    public static var datDir: String = "./dat/"
    public static var contentDir: String = "./resources/"

    /// 创建必需的目录结构
    public static func createRequiredDirectories() throws {
        let fileManager = FileManager.default
        let directories = [csvDir, erbDir, debugDir, datDir, contentDir]

        for dir in directories {
            if !fileManager.fileExists(atPath: dir) {
                try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true)
            }
        }
    }
}