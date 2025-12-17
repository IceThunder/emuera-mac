//
//  ErrorTests.swift
//  EmueraCoreTests
//
//  Error handling tests
//  Created on 2025-12-18
//

import XCTest
@testable import EmueraCore

final class ErrorTests: XCTestCase {

    // Test error description
    func testErrorDescriptions() throws {
        let pos = ScriptPosition(filename: "test.erb", lineNumber: 10)

        let parseError = EmueraError.scriptParseError(message: "Syntax error", position: pos)
        XCTAssertEqual(parseError.localizedDescription, "Parse Error at test.erb:10: Syntax error")

        let runtimeError = EmueraError.runtimeError(message: "Variable not found", position: nil)
        XCTAssertEqual(runtimeError.localizedDescription, "Runtime Error: Variable not found")

        let fileError = EmueraError.fileNotFoundError(path: "/missing/file.txt")
        XCTAssertEqual(fileError.localizedDescription, "File not found: /missing/file.txt")
    }

    // Test script position
    func testScriptPosition() throws {
        let pos = ScriptPosition(filename: "test.erb", lineNumber: 10)
        XCTAssertEqual(pos.description, "test.erb:10")

        let pos2 = ScriptPosition(filename: "test.erb", lineNumber: 10)
        XCTAssertEqual(pos, pos2)
    }

    static var allTests = [
        ("testErrorDescriptions", testErrorDescriptions),
        ("testScriptPosition", testScriptPosition),
    ]
}