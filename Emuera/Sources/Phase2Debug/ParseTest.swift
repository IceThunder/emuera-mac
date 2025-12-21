import Foundation
import EmueraCore

print("=== ScriptParser Full Test ===")
print("Testing function definition parsing...")

let parser = ScriptParser()

// Test 1: Simple function definition
let source1 = """
@TEST_FUNC
RETURNF 42
"""

print("\nTest 1: Simple function definition")
print("Input: \(source1)")
do {
    let statements = try parser.parse(source1)
    print("✓ Parsed \(statements.count) statements")
    for (i, stmt) in statements.enumerated() {
        print("  \(i): \(type(of: stmt))")
    }
} catch {
    print("✗ Error: \(error)")
}

// Test 2: Function with parameters
let source2 = """
@TEST_FUNC, ARG1, ARG2
RETURNF ARG1 + ARG2
"""

print("\nTest 2: Function with parameters")
print("Input: \(source2)")
do {
    let statements = try parser.parse(source2)
    print("✓ Parsed \(statements.count) statements")
    for (i, stmt) in statements.enumerated() {
        print("  \(i): \(type(of: stmt))")
    }
} catch {
    print("✗ Error: \(error)")
}

// Test 3: Function with directives
let source3 = """
@TEST_FUNC
#DIM LOCAL1
LOCAL1 = 10
RETURNF LOCAL1
"""

print("\nTest 3: Function with directives")
print("Input: \(source3)")
do {
    let statements = try parser.parse(source3)
    print("✓ Parsed \(statements.count) statements")
    for (i, stmt) in statements.enumerated() {
        print("  \(i): \(type(of: stmt))")
    }
} catch {
    print("✗ Error: \(error)")
}

// Test 4: Multiple functions
let source4 = """
@FUNC1
RETURNF 1

@FUNC2
RETURNF 2
"""

print("\nTest 4: Multiple functions")
print("Input: \(source4)")
do {
    let statements = try parser.parse(source4)
    print("✓ Parsed \(statements.count) statements")
    for (i, stmt) in statements.enumerated() {
        print("  \(i): \(type(of: stmt))")
    }
} catch {
    print("✗ Error: \(error)")
}

// Test 5: Complex function with PRINT
let source5 = """
@COMPLEX_TEST
PRINTL Start complex test
LOCAL = 5
IF LOCAL > 3
    PRINTL Condition met!
ENDIF
RETURNF LOCAL
"""

print("\nTest 5: Complex function")
print("Input: \(source5)")
do {
    let statements = try parser.parse(source5)
    print("✓ Parsed \(statements.count) statements")
    for (i, stmt) in statements.enumerated() {
        print("  \(i): \(type(of: stmt))")
    }
} catch {
    print("✗ Error: \(error)")
}

print("\n=== All tests completed ===")
