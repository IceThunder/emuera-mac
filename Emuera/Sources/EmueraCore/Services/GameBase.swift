//
//  GameBase.swift
//  EmueraCore
//
//  GAMEBASE.CSV加载器 - 相当于Windows版的GameBase.cs
//  负责读取游戏基础信息
//
//  Created: 2025-12-20
//

import Foundation

/// 游戏基础信息
public struct GameBaseData {
    public var scriptTitle: String = ""           // 游戏标题
    public var scriptAuthorName: String = ""      // 作者
    public var scriptVersionText: String = ""     // 版本
    public var scriptWindowTitle: String? = nil   // 窗口标题
    public var beginTitle: String = "TITLE"       // 开始标签

    public init() {}

    /// 是否有有效数据
    public var isValid: Bool {
        return !scriptTitle.isEmpty
    }
}

/// GAMEBASE.CSV加载器
public final class GameBaseLoader {

    private let fileManager: FileManager

    public init() {
        self.fileManager = FileManager.default
    }

    /// 从CSV目录加载GAMEBASE.CSV
    /// - Returns: 游戏基础数据，如果文件不存在则返回nil
    public func loadGameBase() -> GameBaseData? {
        let csvPath = Sys.csvDir + "GAMEBASE.CSV"

        guard fileManager.fileExists(atPath: csvPath) else {
            return nil
        }

        do {
            let content = try String(contentsOfFile: csvPath, encoding: .utf8)
            return parseGameBase(content)
        } catch {
            // 尝试Shift-JIS编码（Windows版常用）
            if let shiftJIS = try? String(contentsOfFile: csvPath, encoding: .shiftJIS) {
                return parseGameBase(shiftJIS)
            }
            print("⚠️ 无法读取GAMEBASE.CSV: \(error)")
            return nil
        }
    }

    /// 解析GAMEBASE.CSV内容
    private func parseGameBase(_ content: String) -> GameBaseData {
        var data = GameBaseData()

        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // 跳过空行和注释
            if trimmed.isEmpty || trimmed.hasPrefix(";") || trimmed.hasPrefix("//") {
                continue
            }

            // 解析CSV行
            let components = trimmed.components(separatedBy: ",")
            if components.count < 2 {
                continue
            }

            let key = components[0].trimmingCharacters(in: .whitespaces)
            let value = components[1...].joined(separator: ",").trimmingCharacters(in: .whitespaces)

            switch key.uppercased() {
            case "SCRIPT_TITLE":
                data.scriptTitle = value
            case "SCRIPT_AUTHOR", "AUTHOR":
                data.scriptAuthorName = value
            case "SCRIPT_VERSION", "VERSION":
                data.scriptVersionText = value
            case "SCRIPT_WINDOW_TITLE", "WINDOW_TITLE":
                data.scriptWindowTitle = value.isEmpty ? nil : value
            case "BEGIN":
                data.beginTitle = value.isEmpty ? "TITLE" : value
            default:
                break
            }
        }

        return data
    }

    /// 创建默认的GAMEBASE.CSV文件
    public func createDefaultGameBase() throws {
        let csvPath = Sys.csvDir + "GAMEBASE.CSV"

        let defaultContent = """
        ; GAMEBASE.CSV - 游戏基础信息
        ; 格式: KEY, VALUE

        SCRIPT_TITLE, 新游戏
        SCRIPT_AUTHOR, 作者名
        SCRIPT_VERSION, 1.0.0
        SCRIPT_WINDOW_TITLE, Emuera Game
        BEGIN, TITLE

        """

        try defaultContent.write(toFile: csvPath, atomically: true, encoding: .utf8)
    }

    /// 检查GAMEBASE.CSV是否存在
    public func gameBaseExists() -> Bool {
        return fileManager.fileExists(atPath: Sys.csvDir + "GAMEBASE.CSV")
    }
}
