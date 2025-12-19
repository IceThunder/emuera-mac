//
//  HeaderFileLoaderTest.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/20.
//

import Foundation
import EmueraCore

/// Test class for HeaderFileLoader functionality
public final class HeaderFileLoaderTest {

    private var idDic: IdentifierDictionary
    private var tokenData: TokenData
    private var loader: HeaderFileLoader

    public init() {
        self.idDic = IdentifierDictionary()
        let varData = VariableData()
        self.tokenData = TokenData(varData: varData)
        self.loader = HeaderFileLoader(idDic: idDic, tokenData: tokenData)
    }

    /// Test #FUNCTION directive parsing
    public func testFunctionParsing() {
        print("\n=== Testing #FUNCTION Directive Parsing ===")

        // Test 1: Simple function
        testSimpleFunction()

        // Test 2: Function with keywords
        testFunctionWithKeywords()

        // Test 3: #FUNCTIONS with return type
        testFunctionsWithReturnType()

        // Test 4: Function with argument count
        testFunctionWithArgCount()

        // Test 5: Name conflict detection
        testNameConflicts()

        print("\n=== All #FUNCTION Tests Completed ===")
    }

    private func testSimpleFunction() {
        print("\n--- Test 1: Simple Function ---")

        // Create a test ERH file content
        let erhContent = """
#FUNCTION TESTFUNC
"""

        if let result = parseFunctionLine(erhContent) {
            print("✓ Parsed: \(result.name)")
            print("  - Global: \(result.isGlobal)")
            print("  - Private: \(result.isPrivate)")
            print("  - Reference: \(result.isReference)")
            print("  - Arg Count: \(result.argCount)")
            print("  - Return Type: \(result.returnType)")

            // Verify
            assert(result.name == "TESTFUNC", "Name should be TESTFUNC")
            assert(!result.isGlobal, "Should not be global")
            assert(result.argCount == 0, "Should have 0 arguments")
            print("✓ Test 1 PASSED")
        } else {
            print("✗ Test 1 FAILED")
        }
    }

    private func testFunctionWithKeywords() {
        print("\n--- Test 2: Function with Keywords ---")

        let erhContent = """
#FUNCTION GLOBAL PRIVATE TESTFUNC2
"""

        if let result = parseFunctionLine(erhContent) {
            print("✓ Parsed: \(result.name)")
            print("  - Global: \(result.isGlobal)")
            print("  - Private: \(result.isPrivate)")

            // Verify
            assert(result.name == "TESTFUNC2", "Name should be TESTFUNC2")
            assert(result.isGlobal, "Should be global")
            assert(result.isPrivate, "Should be private")
            print("✓ Test 2 PASSED")
        } else {
            print("✗ Test 2 FAILED")
        }
    }

    private func testFunctionsWithReturnType() {
        print("\n--- Test 3: #FUNCTIONS with Return Type ---")

        // Test INT return
        let erhContent1 = """
#FUNCTIONS INT CALCULATE
"""

        if let result = parseFunctionLine(erhContent1, isFunctions: true) {
            print("✓ Parsed #FUNCTIONS INT: \(result.name)")
            print("  - Return Type: \(result.returnType)")
            assert(result.returnType == .integer, "Should be integer")
            print("✓ Test 3a PASSED")
        } else {
            print("✗ Test 3a FAILED")
        }

        // Test STR return
        let erhContent2 = """
#FUNCTIONS STR GETNAME
"""

        if let result = parseFunctionLine(erhContent2, isFunctions: true) {
            print("✓ Parsed #FUNCTIONS STR: \(result.name)")
            print("  - Return Type: \(result.returnType)")
            assert(result.returnType == .string, "Should be string")
            print("✓ Test 3b PASSED")
        } else {
            print("✗ Test 3b FAILED")
        }
    }

    private func testFunctionWithArgCount() {
        print("\n--- Test 4: Function with Argument Count ---")

        let erhContent = """
#FUNCTION ADD 2
"""

        if let result = parseFunctionLine(erhContent) {
            print("✓ Parsed: \(result.name)")
            print("  - Arg Count: \(result.argCount)")
            assert(result.argCount == 2, "Should have 2 arguments")
            print("✓ Test 4 PASSED")
        } else {
            print("✗ Test 4 FAILED")
        }
    }

    private func testNameConflicts() {
        print("\n--- Test 5: Name Conflict Detection ---")

        // Reset for this test
        idDic.clear()

        // First, add a reserved word
        let reservedResult = parseFunctionLine("#FUNCTION IS")
        if reservedResult != nil {
            print("✗ Test 5 FAILED - Should have rejected reserved name")
            return
        }

        // Add a function with a different name
        let firstResult = parseFunctionLine("#FUNCTION TESTCONFLICT")
        if firstResult == nil {
            print("✗ Test 5 FAILED - First function should succeed")
            return
        }

        // Try to add it again
        let duplicateResult = parseFunctionLine("#FUNCTION TESTCONFLICT")
        if duplicateResult != nil {
            print("✗ Test 5 FAILED - Should have rejected duplicate")
            return
        }

        print("✓ Test 5 PASSED - Conflicts properly detected")
    }

    /// Helper to parse a single function line
    private func parseFunctionLine(_ line: String, isFunctions: Bool = false) -> FunctionIdentifier? {
        let stream = StringStream(line)

        // Skip #
        stream.shiftNext()

        // Skip FUNCTION or FUNCTIONS
        stream.skipWhitespace()
        _ = stream.readIdentifier()  // This consumes FUNCTION/FUNCTIONS

        do {
            let function = try FunctionIdentifier.create(from: stream, isFunctions: isFunctions, position: ScriptPosition(filename: "test.erh", lineNumber: 1, line: line))

            // Try to add to dictionary
            try idDic.addFunction(function)
            return function
        } catch {
            print("  Error: \(error)")
            return nil
        }
    }

    /// Test loading a complete ERH file
    public func testCompleteERHFile() {
        print("\n=== Testing Complete ERH File Loading ===")

        // Create a temporary ERH file
        let erhContent = """
; Test header file
#FUNCTION TESTFUNC
#FUNCTIONS INT CALCULATE 2
#FUNCTION GLOBAL PRIVATE REF GETDATA 3
#DIM TESTVAR
#DIMS TESTSTR
"""

        let tempDir = NSTemporaryDirectory()
        let tempFile = (tempDir as NSString).appendingPathComponent("test_header.erh")

        do {
            try erhContent.write(toFile: tempFile, atomically: true, encoding: .utf8)

            // Reset dictionaries
            idDic.clear()
            tokenData.resetAll()

            // Load the file
            let result = try loader.loadHeaderFiles(from: tempDir, displayReport: false)

            if result {
                print("✓ File loaded successfully")

                // Verify functions were registered
                if let func1 = idDic.getFunction("TESTFUNC") {
                    print("✓ TESTFUNC registered: \(func1.name)")
                } else {
                    print("✗ TESTFUNC not found")
                }

                if let func2 = idDic.getFunction("CALCULATE") {
                    print("✓ CALCULATE registered: \(func2.name), args: \(func2.argCount), return: \(func2.returnType)")
                } else {
                    print("✗ CALCULATE not found")
                }

                if let func3 = idDic.getFunction("GETDATA") {
                    print("✓ GETDATA registered: \(func3.name), global: \(func3.isGlobal), private: \(func3.isPrivate), ref: \(func3.isReference), args: \(func3.argCount)")
                } else {
                    print("✗ GETDATA not found")
                }

                // Verify variables were registered using getToken
                if let var1 = tokenData.getToken("TESTVAR") {
                    print("✓ TESTVAR registered: \(var1.varName)")
                } else {
                    print("✗ TESTVAR not found")
                }

                if let var2 = tokenData.getToken("TESTSTR") {
                    print("✓ TESTSTR registered: \(var2.varName)")
                } else {
                    print("✗ TESTSTR not found")
                }

                print("✓ Complete ERH File Test PASSED")
            } else {
                print("✗ File loading failed")
            }

            // Clean up
            try? FileManager.default.removeItem(atPath: tempFile)
        } catch {
            print("✗ Test failed with error: \(error)")
        }
    }
}
