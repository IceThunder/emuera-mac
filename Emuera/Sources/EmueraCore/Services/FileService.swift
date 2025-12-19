//
//  FileService.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/20.
//

import Foundation
import CryptoKit

/// 文件服务 - 提供统一的文件I/O操作
/// 支持多种编码、文件操作和目录管理
public final class FileService {

    // MARK: - 初始化

    public init() {}

    // MARK: - 配置选项

    public struct FileOptions {
        /// 文件编码，默认UTF-8
        public var encoding: String.Encoding = .utf8

        /// 是否创建不存在的目录
        public var createDirectories: Bool = true

        /// 是否覆盖已存在的文件
        public var overwrite: Bool = true

        /// 是否备份原文件（覆盖前）
        public var backupOriginal: Bool = false

        /// 文件权限（Unix模式）
        public var filePermissions: Int = 0o644

        /// 目录权限（Unix模式）
        public var directoryPermissions: Int = 0o755

        public init() {}
    }

    // MARK: - 错误类型

    public enum FileError: Error, LocalizedError {
        case fileNotFound(path: String)
        case permissionDenied(path: String)
        case diskFull(path: String)
        case encodingError(path: String, encoding: String.Encoding)
        case ioError(path: String, message: String)
        case notADirectory(path: String)
        case isADirectory(path: String)
        case alreadyExists(path: String)
        case invalidPath(path: String)

        public var errorDescription: String? {
            switch self {
            case .fileNotFound(let path):
                return "文件不存在: \(path)"
            case .permissionDenied(let path):
                return "权限不足: \(path)"
            case .diskFull(let path):
                return "磁盘空间不足: \(path)"
            case .encodingError(let path, let encoding):
                return "编码错误 \(encoding): \(path)"
            case .ioError(let path, let message):
                return "I/O错误 \(path): \(message)"
            case .notADirectory(let path):
                return "不是目录: \(path)"
            case .isADirectory(let path):
                return "是目录而非文件: \(path)"
            case .alreadyExists(let path):
                return "已存在: \(path)"
            case .invalidPath(let path):
                return "无效路径: \(path)"
            }
        }
    }

    // MARK: - 文件读取

    /// 读取文本文件
    public func readText(
        from path: String,
        options: FileOptions = FileOptions()
    ) throws -> String {
        let url = URL(fileURLWithPath: path)

        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: path) else {
            throw FileError.fileNotFound(path: path)
        }

        // 检查是否是目录
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue {
            throw FileError.isADirectory(path: path)
        }

        // 读取文件
        do {
            let data = try Data(contentsOf: url)
            guard let content = String(data: data, encoding: options.encoding) else {
                // 尝试其他编码
                if let fallback = String(data: data, encoding: .shiftJIS) {
                    return fallback
                }
                if let fallback = String(data: data, encoding: .windowsCP1252) {
                    return fallback
                }
                throw FileError.encodingError(path: path, encoding: options.encoding)
            }
            return content
        } catch let error as FileError {
            throw error
        } catch {
            throw FileError.ioError(path: path, message: error.localizedDescription)
        }
    }

    /// 读取二进制数据
    public func readBinary(from path: String) throws -> Data {
        let url = URL(fileURLWithPath: path)

        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: path) else {
            throw FileError.fileNotFound(path: path)
        }

        // 检查是否是目录
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue {
            throw FileError.isADirectory(path: path)
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            throw FileError.ioError(path: path, message: error.localizedDescription)
        }
    }

    /// 读取CSV文件（使用CSVParser）
    public func readCSV(
        from path: String,
        options: CSVParser.LoadOptions = CSVParser.LoadOptions()
    ) throws -> CSVParser.CSVData {
        let parser = CSVParser()
        return try parser.loadCSV(from: path, options: options)
    }

    /// 读取JSON文件
    public func readJSON<T: Decodable>(
        from path: String,
        type: T.Type,
        options: FileOptions = FileOptions()
    ) throws -> T {
        let content = try readText(from: path, options: options)
        guard let data = content.data(using: options.encoding) else {
            throw FileError.encodingError(path: path, encoding: options.encoding)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }

    // MARK: - 文件写入

    /// 写入文本文件
    public func writeText(
        _ content: String,
        to path: String,
        options: FileOptions = FileOptions()
    ) throws {
        let url = URL(fileURLWithPath: path)

        // 创建目录（如果需要）
        if options.createDirectories {
            let directory = url.deletingLastPathComponent()
            try createDirectory(at: directory.path, options: options)
        }

        // 检查文件是否存在
        if FileManager.default.fileExists(atPath: path) {
            if !options.overwrite {
                throw FileError.alreadyExists(path: path)
            }

            if options.backupOriginal {
                let backupPath = path + ".bak"
                try? FileManager.default.removeItem(atPath: backupPath)
                try FileManager.default.moveItem(atPath: path, toPath: backupPath)
            }
        }

        // 写入文件
        do {
            try content.write(toFile: path, atomically: true, encoding: options.encoding)

            // 设置文件权限
            try setPermissions(path: path, permissions: options.filePermissions)
        } catch let error as EncodingError {
            throw FileError.encodingError(path: path, encoding: options.encoding)
        } catch {
            throw FileError.ioError(path: path, message: error.localizedDescription)
        }
    }

    /// 写入二进制数据
    public func writeBinary(
        _ data: Data,
        to path: String,
        options: FileOptions = FileOptions()
    ) throws {
        let url = URL(fileURLWithPath: path)

        // 创建目录（如果需要）
        if options.createDirectories {
            let directory = url.deletingLastPathComponent()
            try createDirectory(at: directory.path, options: options)
        }

        // 检查文件是否存在
        if FileManager.default.fileExists(atPath: path) {
            if !options.overwrite {
                throw FileError.alreadyExists(path: path)
            }

            if options.backupOriginal {
                let backupPath = path + ".bak"
                try? FileManager.default.removeItem(atPath: backupPath)
                try FileManager.default.moveItem(atPath: path, toPath: backupPath)
            }
        }

        // 写入文件
        do {
            try data.write(to: url, options: .atomic)

            // 设置文件权限
            try setPermissions(path: path, permissions: options.filePermissions)
        } catch {
            throw FileError.ioError(path: path, message: error.localizedDescription)
        }
    }

    /// 写入JSON文件
    public func writeJSON<T: Encodable>(
        _ object: T,
        to path: String,
        options: FileOptions = FileOptions(),
        prettyPrint: Bool = true
    ) throws {
        let encoder = JSONEncoder()
        if prettyPrint {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }

        let data = try encoder.encode(object)
        guard let content = String(data: data, encoding: options.encoding) else {
            throw FileError.encodingError(path: path, encoding: options.encoding)
        }

        try writeText(content, to: path, options: options)
    }

    /// 追加文本到文件
    public func appendText(
        _ content: String,
        to path: String,
        options: FileOptions = FileOptions()
    ) throws {
        // 如果文件不存在，创建它
        if !FileManager.default.fileExists(atPath: path) {
            try writeText(content, to: path, options: options)
            return
        }

        // 读取现有内容
        let existing = try readText(from: path, options: options)

        // 追加新内容
        let newContent = existing + content

        // 写回文件
        try writeText(newContent, to: path, options: options)
    }

    // MARK: - 目录操作

    /// 创建目录
    public func createDirectory(
        at path: String,
        options: FileOptions = FileOptions()
    ) throws {
        let url = URL(fileURLWithPath: path)

        // 检查是否已存在
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                return  // 已存在且是目录
            } else {
                throw FileError.notADirectory(path: path)
            }
        }

        // 创建目录
        do {
            try FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )

            // 设置权限
            try setPermissions(path: path, permissions: options.directoryPermissions)
        } catch {
            throw FileError.ioError(path: path, message: error.localizedDescription)
        }
    }

    /// 读取目录内容
    public func listDirectory(
        at path: String,
        includeHidden: Bool = false
    ) throws -> [String] {
        // 检查是否是目录
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) || !isDir.boolValue {
            throw FileError.notADirectory(path: path)
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)

            if includeHidden {
                return contents
            } else {
                return contents.filter { !$0.hasPrefix(".") }
            }
        } catch {
            throw FileError.ioError(path: path, message: error.localizedDescription)
        }
    }

    /// 递归列出目录内容
    public func listDirectoryRecursive(
        at path: String,
        includeHidden: Bool = false,
        includeDirectories: Bool = true
    ) throws -> [String] {
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) || !isDir.boolValue {
            throw FileError.notADirectory(path: path)
        }

        let enumerator = FileManager.default.enumerator(atPath: path)
        var results: [String] = []

        while let item = enumerator?.nextObject() as? String {
            if !includeHidden && item.hasPrefix(".") {
                continue
            }

            let fullPath = (path as NSString).appendingPathComponent(item)

            if !includeDirectories {
                var itemIsDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &itemIsDir), itemIsDir.boolValue {
                    continue
                }
            }

            results.append(fullPath)
        }

        return results
    }

    // MARK: - 文件信息

    /// 检查文件是否存在
    public func exists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    /// 检查是否是文件
    public func isFile(at path: String) -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            return !isDir.boolValue
        }
        return false
    }

    /// 检查是否是目录
    public func isDirectory(at path: String) -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            return isDir.boolValue
        }
        return false
    }

    /// 获取文件大小
    public func fileSize(at path: String) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        return attributes[.size] as? Int64 ?? 0
    }

    /// 获取文件修改时间
    public func modificationDate(at path: String) throws -> Date {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        return attributes[.modificationDate] as? Date ?? Date()
    }

    /// 获取文件属性
    public func getAttributes(at path: String) throws -> [FileAttributeKey: Any] {
        return try FileManager.default.attributesOfItem(atPath: path)
    }

    // MARK: - 文件操作

    /// 复制文件
    public func copy(
        from source: String,
        to destination: String,
        options: FileOptions = FileOptions()
    ) throws {
        // 检查源文件
        guard FileManager.default.fileExists(atPath: source) else {
            throw FileError.fileNotFound(path: source)
        }

        // 创建目标目录
        if options.createDirectories {
            let destURL = URL(fileURLWithPath: destination)
            try createDirectory(at: destURL.deletingLastPathComponent().path, options: options)
        }

        // 检查目标是否已存在
        if FileManager.default.fileExists(atPath: destination) {
            if !options.overwrite {
                throw FileError.alreadyExists(path: destination)
            }
            if options.backupOriginal {
                let backupPath = destination + ".bak"
                try? FileManager.default.removeItem(atPath: backupPath)
                try FileManager.default.moveItem(atPath: destination, toPath: backupPath)
            }
        }

        do {
            try FileManager.default.copyItem(atPath: source, toPath: destination)
        } catch {
            throw FileError.ioError(path: destination, message: error.localizedDescription)
        }
    }

    /// 移动/重命名文件
    public func move(
        from source: String,
        to destination: String,
        options: FileOptions = FileOptions()
    ) throws {
        // 检查源文件
        guard FileManager.default.fileExists(atPath: source) else {
            throw FileError.fileNotFound(path: source)
        }

        // 创建目标目录
        if options.createDirectories {
            let destURL = URL(fileURLWithPath: destination)
            try createDirectory(at: destURL.deletingLastPathComponent().path, options: options)
        }

        // 检查目标是否已存在
        if FileManager.default.fileExists(atPath: destination) {
            if !options.overwrite {
                throw FileError.alreadyExists(path: destination)
            }
        }

        do {
            try FileManager.default.moveItem(atPath: source, toPath: destination)
        } catch {
            throw FileError.ioError(path: destination, message: error.localizedDescription)
        }
    }

    /// 删除文件
    public func delete(at path: String) throws {
        guard FileManager.default.fileExists(atPath: path) else {
            return  // 文件不存在，无需删除
        }

        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            throw FileError.ioError(path: path, message: error.localizedDescription)
        }
    }

    /// 删除目录（递归）
    public func deleteDirectory(at path: String) throws {
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: path, isDirectory: &isDir) || !isDir.boolValue {
            throw FileError.notADirectory(path: path)
        }

        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            throw FileError.ioError(path: path, message: error.localizedDescription)
        }
    }

    // MARK: - 权限管理

    /// 设置文件/目录权限
    public func setPermissions(
        path: String,
        permissions: Int
    ) throws {
        do {
            try FileManager.default.setAttributes(
                [.posixPermissions: permissions],
                ofItemAtPath: path
            )
        } catch {
            throw FileError.permissionDenied(path: path)
        }
    }

    /// 获取文件/目录权限
    public func getPermissions(path: String) throws -> Int {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        return attributes[.posixPermissions] as? Int ?? 0
    }

    /// 检查读权限
    public func isReadable(at path: String) -> Bool {
        return FileManager.default.isReadableFile(atPath: path)
    }

    /// 检查写权限
    public func isWritable(at path: String) -> Bool {
        return FileManager.default.isWritableFile(atPath: path)
    }

    /// 检查执行权限
    public func isExecutable(at path: String) -> Bool {
        return FileManager.default.isExecutableFile(atPath: path)
    }

    // MARK: - 临时文件

    /// 创建临时文件
    public func createTempFile(
        prefix: String = "emuera_",
        suffix: String = ".tmp",
        options: FileOptions = FileOptions()
    ) throws -> String {
        let tempDir = NSTemporaryDirectory()
        let filename = "\(prefix)\(UUID().uuidString)\(suffix)"
        let path = (tempDir as NSString).appendingPathComponent(filename)

        // 创建空文件
        try writeText("", to: path, options: options)

        return path
    }

    /// 创建临时目录
    public func createTempDirectory(
        prefix: String = "emuera_"
    ) throws -> String {
        let tempDir = NSTemporaryDirectory()
        let dirname = "\(prefix)\(UUID().uuidString)"
        let path = (tempDir as NSString).appendingPathComponent(dirname)

        try createDirectory(at: path)

        return path
    }

    // MARK: - 路径操作

    /// 标准化路径
    public func normalizePath(_ path: String) -> String {
        return (path as NSString).standardizingPath
    }

    /// 获取绝对路径
    public func absolutePath(_ path: String) -> String {
        if path.hasPrefix("/") {
            return normalizePath(path)
        }
        let currentDir = FileManager.default.currentDirectoryPath
        return normalizePath((currentDir as NSString).appendingPathComponent(path))
    }

    /// 获取父目录
    public func parentDirectory(of path: String) -> String? {
        let url = URL(fileURLWithPath: path)
        return url.deletingLastPathComponent().path
    }

    /// 获取文件名
    public func fileName(of path: String) -> String {
        return (path as NSString).lastPathComponent
    }

    /// 获取文件扩展名
    public func fileExtension(of path: String) -> String {
        return (path as NSString).pathExtension
    }

    /// 无扩展名的文件名
    public func fileNameWithoutExtension(of path: String) -> String {
        let name = fileName(of: path)
        let ext = fileExtension(of: path)
        if ext.isEmpty {
            return name
        }
        return String(name.dropLast(ext.count + 1))
    }

    /// 组合路径
    public func joinPath(_ components: String...) -> String {
        return (components as NSArray).componentsJoined(by: "/")
    }

    // MARK: - 批量操作

    /// 批量读取多个文件
    public func readMultipleText(
        paths: [String],
        options: FileOptions = FileOptions()
    ) throws -> [String: String] {
        var results: [String: String] = [:]

        for path in paths {
            results[path] = try readText(from: path, options: options)
        }

        return results
    }

    /// 批量写入文件
    public func writeMultipleText(
        _ contents: [String: String],
        options: FileOptions = FileOptions()
    ) throws {
        for (path, content) in contents {
            try writeText(content, to: path, options: options)
        }
    }

    /// 查找文件（支持通配符）
    public func findFiles(
        in directory: String,
        pattern: String? = nil,
        recursive: Bool = false
    ) throws -> [String] {
        let files = recursive
            ? try listDirectoryRecursive(at: directory, includeHidden: true, includeDirectories: false)
            : try listDirectory(at: directory, includeHidden: true)

        guard let pattern = pattern else {
            return files
        }

        // 简单的通配符匹配（* 和 ?）
        let regexPattern = pattern
            .replacingOccurrences(of: ".", with: "\\.")
            .replacingOccurrences(of: "*", with: ".*")
            .replacingOccurrences(of: "?", with: ".")

        guard let regex = try? NSRegularExpression(pattern: "^" + regexPattern + "$") else {
            return files
        }

        return files.filter { path in
            let filename = fileName(of: path)
            let range = NSRange(location: 0, length: filename.utf16.count)
            return regex.firstMatch(in: filename, options: [], range: range) != nil
        }
    }

    // MARK: - 实用工具

    /// 检查磁盘空间
    public func getAvailableSpace(at path: String) throws -> Int64 {
        let url = URL(fileURLWithPath: path)
        let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForOpportunisticUsageKey])
        return values.volumeAvailableCapacityForOpportunisticUsage ?? 0
    }

    /// 比较两个文件
    public func compareFiles(_ path1: String, _ path2: String) throws -> Bool {
        let data1 = try readBinary(from: path1)
        let data2 = try readBinary(from: path2)
        return data1 == data2
    }

    /// 计算文件哈希（MD5）
    public func md5(of path: String) throws -> String {
        let data = try readBinary(from: path)
        return data.md5
    }

    /// 计算文件哈希（SHA256）
    public func sha256(of path: String) throws -> String {
        let data = try readBinary(from: path)
        return data.sha256
    }
}

// MARK: - Data 扩展（用于哈希计算）

extension Data {
    var md5: String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    var sha256: String {
        let digest = SHA256.hash(data: self)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
