//
//  DebugParserTest.swift
//  Phase2Test
//
//  Debug parser issues
//

import Foundation
import EmueraCore

@main
struct DebugParserTest {
    static func main() {
        print("=== Debug Parser Test ===\n")

        // Test 1: Simple assignment
        print("Test 1: A = 0")
        testParse("A = 0", showTokens: true)

        // Test 2: DO with assignment
        print("\nTest 2: DO with assignment")
        let script2 = """
DO
    A = A + 1
LOOP WHILE A < 5
"""
        testParse(script2, showTokens: true)

        // Test 3: DO without assignment
        print("\nTest 3: DO without assignment")
        let script3 = """
DO
    PRINTL "Hello"
LOOP WHILE A < 5
"""
        testParse(script3, showTokens: true)

        // Test 4: SET command
        print("\nTest 4: SET A = 10")
        testParse("SET A = 10", showTokens: true)

        // Test 5: TINPUT with 3 args
        print("\nTest 5: TINPUT 1000, 0, \"超时\"")
        testParse("TINPUT 1000, 0, \"超时\"", showTokens: false)

        // Test 6: SETCOLOR with 3 args
        print("\nTest 6: SETCOLOR 255, 255, 255")
        testParse("SETCOLOR 255, 255, 255", showTokens: false)
    }

    static func testParse(_ script: String, showTokens: Bool = false) {
        if showTokens {
            print("  Tokens:")
            let lexer = LexicalAnalyzer()
            let tokens = lexer.tokenize(script)
            for (i, token) in tokens.enumerated() {
                print("    \(i): \(token)")
            }
            print("")
        }

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            print("✓ Parsed successfully: \(statements.count) statements")
            for (i, stmt) in statements.enumerated() {
                print("  \(i+1). \(type(of: stmt))")
            }
        } catch {
            print("✗ Parse error: \(error)")
        }
    }
}
