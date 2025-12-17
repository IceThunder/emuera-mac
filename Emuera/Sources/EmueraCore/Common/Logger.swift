//
//  Logger.swift
//  EmueraCore
//
//  Console logging and error output system
//  Created on 2025-12-18
//

import Foundation

/// 日志级别
public enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARN"
        case .error: return "ERROR"
        }
    }
}

/// 日志输出协议
public protocol LogOutput {
    func write(_ level: LogLevel, _ message: String)
}

/// 控制台日志输出器
public class ConsoleLogOutput: LogOutput {
    public func write(_ level: LogLevel, _ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("[\(timestamp)] [\(level.description)] \(message)")
    }
}

/// 模拟Emuera控制台的输出
public class EmueraConsoleOutput: LogOutput {
    private var buffer: [String] = []

    public func write(_ level: LogLevel, _ message: String) {
        // 转换为Emuera风格的输出
        let prefix: String
        switch level {
        case .error:
            prefix = "★ "
        case .warning:
            prefix = "⚠️ "
        default:
            prefix = ""
        }

        let output = prefix + message
        buffer.append(output)

        // 立即输出到控制台
        print(output)
    }

    public func getBuffer() -> [String] {
        return buffer
    }

    public func clearBuffer() {
        buffer.removeAll()
    }
}

/// 日志管理器
public class Logger {
    private static var outputs: [LogOutput] = [ConsoleLogOutput()]
    private static var minLevel: LogLevel = .info

    public static func addOutput(_ output: LogOutput) {
        outputs.append(output)
    }

    public static func setMinLevel(_ level: LogLevel) {
        minLevel = level
    }

    public static func log(_ level: LogLevel, _ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        guard level >= minLevel else { return }

        // 添加位置信息（debug模式下）
        let fullMessage: String
        #if DEBUG
            let filename = URL(fileURLWithPath: file).lastPathComponent
            fullMessage = "\(filename):\(line) \(function) - \(message())"
        #else
            fullMessage = message()
        #endif

        for output in outputs {
            output.write(level, fullMessage)
        }
    }

    // 便捷方法
    public static func debug(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message(), file: file, function: function, line: line)
    }

    public static func info(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message(), file: file, function: function, line: line)
    }

    public static func warning(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message(), file: file, function: function, line: line)
    }

    public static func error(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message(), file: file, function: function, line: line)
    }

    public static func printSystemLine(_ message: String) {
        // 模拟Emuera的系统消息输出
        info("SYSTEM: \(message)")
    }

    public static func printError(_ message: String) {
        // 模拟Emuera的错误消息输出
        error("ERROR: \(message)")
    }
}