//
//  CSVParser.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/20.
//

import Foundation

/// CSV数据加载器 - 支持Emuera风格的CSV文件
/// 用于加载CSV数据到数组变量中，支持多种编码格式
public final class CSVParser {

    /// Initialize CSVParser
    public init() {}

    // MARK: - CSV加载选项

    public struct LoadOptions {
        /// 文件编码，默认UTF-8
        public var encoding: String.Encoding = .utf8

        /// 是否跳过第一行（标题行）
        public var skipHeader: Bool = false

        /// 字段分隔符，默认逗号
        public var separator: Character = ","

        /// 是否允许空行
        public var allowEmptyLines: Bool = true

        /// 是否修剪字段两端的空白
        public var trimFields: Bool = true

        /// 最大列数限制（0表示不限制）
        public var maxColumns: Int = 0

        /// 是否将空字符串转换为nil
        public var emptyToNil: Bool = false

        public init() {}
    }

    // MARK: - 错误类型

    public enum CSVError: Error, LocalizedError {
        case fileNotFound(path: String)
        case parseError(message: String, line: Int?)
        case encodingError(message: String)
        case invalidFormat(message: String)

        public var errorDescription: String? {
            switch self {
            case .fileNotFound(let path):
                return "CSV file not found: \(path)"
            case .parseError(let message, let line):
                if let line = line {
                    return "Parse error at line \(line): \(message)"
                }
                return "Parse error: \(message)"
            case .encodingError(let message):
                return "Encoding error: \(message)"
            case .invalidFormat(let message):
                return "Invalid CSV format: \(message)"
            }
        }
    }

    // MARK: - CSV数据结构

    /// CSV行数据
    public struct CSVRow {
        public let fields: [String?]
        public let lineNumber: Int

        public init(fields: [String?], lineNumber: Int) {
            self.fields = fields
            self.lineNumber = lineNumber
        }

        /// 获取指定索引的字段，支持默认值
        public func getField(_ index: Int, default: String = "") -> String {
            guard index < fields.count else { return `default` }
            return fields[index] ?? `default`
        }

        /// 获取字段数量
        public var fieldCount: Int {
            return fields.count
        }
    }

    /// CSV数据集
    public struct CSVData {
        public let rows: [CSVRow]
        public let columnNames: [String]?

        public init(rows: [CSVRow], columnNames: [String]? = nil) {
            self.rows = rows
            self.columnNames = columnNames
        }

        /// 获取行数
        public var rowCount: Int {
            return rows.count
        }

        /// 获取列数（基于第一行数据）
        public var columnCount: Int {
            return rows.first?.fieldCount ?? 0
        }

        /// 获取指定行和列的值
        public func getValue(row: Int, column: Int, default: String = "") -> String {
            guard row < rows.count else { return `default` }
            return rows[row].getField(column, default: `default`)
        }

        /// 按列名获取值（如果有列名）
        public func getValue(row: Int, columnName: String, default: String = "") -> String {
            guard let columnNames = columnNames,
                  let columnIndex = columnNames.firstIndex(of: columnName),
                  row < rows.count else { return `default` }
            return rows[row].getField(columnIndex, default: `default`)
        }
    }

    // MARK: - 加载CSV文件

    /// 从文件加载CSV数据
    public func loadCSV(
        from filepath: String,
        options: LoadOptions = LoadOptions()
    ) throws -> CSVData {
        // 读取文件内容
        guard let content = try? String(contentsOfFile: filepath, encoding: options.encoding) else {
            // 尝试Shift-JIS编码
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: filepath)),
                  let content = String(data: data, encoding: .shiftJIS) else {
                throw CSVError.fileNotFound(path: filepath)
            }
            return try parseCSV(content: content, options: options)
        }

        return try parseCSV(content: content, options: options)
    }

    /// 从字符串解析CSV
    public func parseCSV(
        content: String,
        options: LoadOptions = LoadOptions()
    ) throws -> CSVData {
        let lines = content.components(separatedBy: .newlines)
        var rows: [CSVRow] = []
        var columnNames: [String]? = nil

        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1

            // 跳过空行
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !options.allowEmptyLines {
                    throw CSVError.parseError(message: "Empty line not allowed", line: lineNumber)
                }
                continue
            }

            // 解析行
            let fields = try parseLine(line, options: options)

            // 检查列数限制
            if options.maxColumns > 0 && fields.count > options.maxColumns {
                throw CSVError.parseError(
                    message: "Too many columns (max: \(options.maxColumns))",
                    line: lineNumber
                )
            }

            // 第一行可能是列名
            if lineNumber == 1 && options.skipHeader {
                columnNames = fields.map { $0 ?? "" }
                continue
            }

            rows.append(CSVRow(fields: fields, lineNumber: lineNumber))
        }

        return CSVData(rows: rows, columnNames: columnNames)
    }

    /// 解析单行CSV
    private func parseLine(_ line: String, options: LoadOptions) throws -> [String?] {
        var fields: [String?] = []
        var currentField = ""
        var inQuotes = false
        var i = line.startIndex

        while i < line.endIndex {
            let char = line[i]

            if char == "\"" {
                // 处理引号
                if inQuotes {
                    // 检查下一个字符是否也是引号（转义）
                    let nextIndex = line.index(after: i)
                    if nextIndex < line.endIndex && line[nextIndex] == "\"" {
                        currentField += "\""
                        i = nextIndex
                    } else {
                        inQuotes = false
                    }
                } else {
                    inQuotes = true
                }
            } else if char == options.separator && !inQuotes {
                // 字段分隔符
                let field = options.trimFields ? currentField.trimmingCharacters(in: .whitespaces) : currentField
                fields.append(options.emptyToNil && field.isEmpty ? nil : field)
                currentField = ""
            } else {
                currentField.append(char)
            }

            i = line.index(after: i)
        }

        // 添加最后一个字段
        let field = options.trimFields ? currentField.trimmingCharacters(in: .whitespaces) : currentField
        fields.append(options.emptyToNil && field.isEmpty ? nil : field)

        return fields
    }

    // MARK: - 便捷方法

    /// 加载CSV到二维字符串数组
    public func loadCSVToStringArray(
        from filepath: String,
        options: LoadOptions = LoadOptions()
    ) throws -> [[String?]] {
        let csvData = try loadCSV(from: filepath, options: options)
        return csvData.rows.map { $0.fields }
    }

    /// 加载CSV到二维整数数组（自动转换）
    public func loadCSVToIntArray(
        from filepath: String,
        options: LoadOptions = LoadOptions()
    ) throws -> [[Int64]] {
        let csvData = try loadCSV(from: filepath, options: options)
        return csvData.rows.map { row in
            row.fields.map { field in
                if let str = field, let num = Int64(str) {
                    return num
                }
                return 0
            }
        }
    }

    /// 加载CSV到一维数组（指定列）
    public func loadCSVColumn(
        from filepath: String,
        columnIndex: Int,
        options: LoadOptions = LoadOptions()
    ) throws -> [String?] {
        let csvData = try loadCSV(from: filepath, options: options)
        return csvData.rows.map { $0.getField(columnIndex) }
    }

    /// 加载CSV并按列名映射
    public func loadCSVWithMapping(
        from filepath: String,
        mappings: [String: String], // CSV列名 -> 变量名映射
        options: LoadOptions = LoadOptions()
    ) throws -> [String: [String?]] {
        var loadOptions = options
        loadOptions.skipHeader = true
        let csvData = try loadCSV(from: filepath, options: loadOptions)

        guard let columnNames = csvData.columnNames else {
            throw CSVError.invalidFormat(message: "No column names found")
        }

        var result: [String: [String?]] = [:]

        for (csvName, varName) in mappings {
            guard let columnIndex = columnNames.firstIndex(of: csvName) else {
                continue
            }
            result[varName] = csvData.rows.map { $0.getField(columnIndex) }
        }

        return result
    }

    // MARK: - CSV生成（写入）

    /// 将二维数组保存为CSV文件
    public func saveCSV(
        _ data: [[String]],
        to filepath: String,
        options: LoadOptions = LoadOptions()
    ) throws {
        var content = ""

        for (rowIndex, row) in data.enumerated() {
            let line = row.map { field in
                // 如果字段包含分隔符、引号或换行，需要加引号
                if field.contains(options.separator) || field.contains("\"") || field.contains("\n") {
                    var escaped = field
                    escaped = escaped.replacingOccurrences(of: "\"", with: "\"\"")
                    return "\"\(escaped)\""
                }
                return field
            }.joined(separator: String(options.separator))

            content += line

            if rowIndex < data.count - 1 {
                content += "\n"
            }
        }

        try content.write(toFile: filepath, atomically: true, encoding: options.encoding)
    }

    /// 将CSVData保存为文件
    public func saveCSV(
        _ data: CSVData,
        to filepath: String,
        options: LoadOptions = LoadOptions()
    ) throws {
        var arrayData: [[String]] = []

        // 添加列名行（如果有）
        if let columnNames = data.columnNames {
            arrayData.append(columnNames)
        }

        // 添加数据行
        for row in data.rows {
            arrayData.append(row.fields.map { $0 ?? "" })
        }

        try saveCSV(arrayData, to: filepath, options: options)
    }
}
