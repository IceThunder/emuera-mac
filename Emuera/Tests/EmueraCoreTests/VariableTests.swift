//
//  VariableTests.swift
//  EmueraCoreTests
//
//  Basic variable system tests
//  Created on 2025-12-18
//

import XCTest
@testable import EmueraCore

final class VariableTests: XCTestCase {

    // Test basic integer variable
    func testIntegerVariable() throws {
        let varData = VariableData()
        varData.setVariable("RESULT", value: .integer(42))
        let result = varData.getVariable("RESULT")

        guard case .integer(let value) = result else {
            XCTFail("Expected integer type")
            return
        }
        XCTAssertEqual(value, 42)
    }

    // Test string variable
    func testStringVariable() throws {
        let varData = VariableData()
        varData.setVariable("TEST", value: .string("Hello"))
        let result = varData.getVariable("TEST")

        guard case .string(let value) = result else {
            XCTFail("Expected string type")
            return
        }
        XCTAssertEqual(value, "Hello")
    }

    // Test array operations
    func testArrayOperations() throws {
        let varData = VariableData()
        varData.setArrayElement("TEST_ARRAY", index: 0, value: 100)
        varData.setArrayElement("TEST_ARRAY", index: 5, value: 200)

        let val0 = varData.getArrayElement("TEST_ARRAY", index: 0)
        let val5 = varData.getArrayElement("TEST_ARRAY", index: 5)
        let valNil = varData.getArrayElement("TEST_ARRAY", index: 99)

        XCTAssertEqual(val0, 100)
        XCTAssertEqual(val5, 200)
        XCTAssertEqual(valNil, 0) // Out of bounds should return 0
    }

    // Test character data
    func testCharacterData() throws {
        let chara = CharacterData(id: 0, name: "TestChar")
        varData.addCharacter(chara)

        XCTAssertEqual(varData.getCharacterCount(), 1)
        XCTAssertNotNil(varData.getCharacter(at: 0))
        XCTAssertEqual(varData.getCharacter(at: 0)?.name, "TestChar")
    }

    // Test reset functionality
    func testReset() throws {
        let varData = VariableData()
        varData.setVariable("TEST", value: .integer(123))
        varData.reset()

        let result = varData.getVariable("TEST")
        XCTAssertTrue(result.isNull)
    }

    // Static test suite for Linux compatibility
    static var allTests = [
        ("testIntegerVariable", testIntegerVariable),
        ("testStringVariable", testStringVariable),
        ("testArrayOperations", testArrayOperations),
        ("testCharacterData", testCharacterData),
        ("testReset", testReset),
    ]
}