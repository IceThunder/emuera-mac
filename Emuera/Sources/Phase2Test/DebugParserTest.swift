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
        testParse("A = 0")

        // Test 2: DO with assignment
        print("\nTest 2: DO with assignment")
        testParse("""
        DO
            A = A + 1
        LOOP WHILE A < 5
        """)

        // Test 3: SET command
        print("\nTest 3: SET A = 10")
        testParse("SET A = 10")

        // Test 4: TINPUT with 3 args
        print("\nTest 4: TINPUT 1000, 0, \"超时\"")
        testParse("TINPUT 1000, 0, \"超时\"")

        // Test 5: SETCOLOR with 3 args
        print("\nTest 5: SETCOLOR 255, 255, 255")
        testParse("SETCOLOR 255, 255, 255")
    }

    static func testParse(_ script: String) {
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
