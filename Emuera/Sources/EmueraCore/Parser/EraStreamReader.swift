//
//  EraStreamReader.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/19.
//

import Foundation

/// Reads ERB/ERH files with preprocessing
public final class EraStreamReader {
    private let enableRename: Bool
    private var lines: [String] = []
    private var currentIndex: Int = 0
    private var currentLineNo: Int = 0
    private var filename: String = ""

    public init(enableRename: Bool = true) {
        self.enableRename = enableRename
    }

    /// Open and read a file
    public func open(filepath: String, filename: String) -> Bool {
        self.filename = filename

        guard let content = try? String(contentsOfFile: filepath, encoding: .utf8) else {
            // Try Shift-JIS for legacy support
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: filepath)),
                  let content = String(data: data, encoding: .shiftJIS) else {
                return false
            }
            self.lines = content.components(separatedBy: .newlines)
            return true
        }

        self.lines = content.components(separatedBy: .newlines)
        return true
    }

    /// Read next enabled line (skips comments, handles preprocessing)
    public func readEnabledLine() -> StringStream? {
        while currentIndex < lines.count {
            let line = lines[currentIndex]
            currentLineNo += 1
            currentIndex += 1

            // Skip empty lines
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                continue
            }

            // Skip full-line comments
            if trimmed.hasPrefix(";") {
                continue
            }

            // Handle line continuation with @
            if trimmed.hasPrefix("@") {
                // For now, treat @ as part of the line
                // In full implementation, would merge with next line
            }

            // Return the line for processing
            return StringStream(line)
        }
        return nil
    }

    public func close() {
        lines.removeAll()
        currentIndex = 0
        currentLineNo = 0
    }

    public var lineNo: Int {
        return currentLineNo
    }

    public var Filename: String {
        return filename
    }
}

/// String stream for character-by-character processing
public final class StringStream {
    private let text: String
    private var index: String.Index
    private let originalString: String

    public init(_ text: String) {
        self.text = text
        self.originalString = text
        self.index = text.startIndex
    }

    public var current: Character? {
        guard index < text.endIndex else { return nil }
        return text[index]
    }

    public func shiftNext() {
        guard index < text.endIndex else { return }
        index = text.index(after: index)
    }

    public var eol: Bool {
        return index >= text.endIndex
    }

    public var rowString: String {
        return originalString
    }

    /// Read until end of line
    public func readUntilEnd() -> String {
        let substring = text[index...]
        return String(substring)
    }

    /// Skip whitespace
    public func skipWhitespace() {
        while !eol, let char = current, char.isWhitespace {
            shiftNext()
        }
    }

    /// Read a single identifier
    public func readIdentifier() -> String? {
        skipWhitespace()
        guard !eol, let first = current, first.isLetter || first == "_" else {
            return nil
        }

        var result = ""
        while !eol, let char = current, (char.isLetter || char.isNumber || char == "_") {
            result.append(char)
            shiftNext()
        }
        return result.isEmpty ? nil : result
    }

    /// Read until specified character
    public func readUntil(_ char: Character) -> String {
        var result = ""
        while !eol, let currentChar = current {
            if currentChar == char {
                break
            }
            result.append(currentChar)
            shiftNext()
        }
        return result
    }

    /// Read a quoted string
    public func readQuotedString() -> String? {
        guard !eol, let first = current, first == "\"" else { return nil }
        shiftNext() // Skip opening quote

        var result = ""
        while !eol, let char = current {
            if char == "\"" {
                shiftNext() // Skip closing quote
                return result
            }
            if char == "\\" {
                shiftNext()
                if !eol, let next = current {
                    result.append(next)
                    shiftNext()
                }
                continue
            }
            result.append(char)
            shiftNext()
        }
        return nil // Unclosed string
    }

    /// Read an integer
    public func readInteger() -> Int64? {
        skipWhitespace()
        guard !eol, let first = current, first.isNumber else { return nil }

        var result = ""
        while !eol, let char = current, char.isNumber {
            result.append(char)
            shiftNext()
        }
        return Int64(result)
    }

    /// Peek next character without consuming
    public func peek() -> Character? {
        guard index < text.endIndex else { return nil }
        let nextIndex = text.index(after: index)
        guard nextIndex < text.endIndex else { return nil }
        return text[nextIndex]
    }

    /// Current position as ScriptPosition
    public func currentPosition(filename: String, lineNo: Int) -> ScriptPosition {
        let col = text.distance(from: text.startIndex, to: index)
        return ScriptPosition(filename: filename, lineNumber: lineNo, line: originalString, column: col)
    }
}
