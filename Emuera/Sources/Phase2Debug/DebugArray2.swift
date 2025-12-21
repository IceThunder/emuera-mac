import Foundation
import EmueraCore

print("=== Debug Array Assignment Issue ===")

let parser = ScriptParser()
let executor = StatementExecutor()

// Test 1: What does "A = 1, 2, 3" parse to?
print("\n1. Parse 'A = 1, 2, 3':")
do {
    let statements = try parser.parse("A = 1, 2, 3")
    print("  Parsed \(statements.count) statement(s):")
    for (i, stmt) in statements.enumerated() {
        print("  [\(i)] \(type(of: stmt)): \(stmt)")
    }
} catch {
    print("  Error: \(error)")
}

// Test 2: Tokenization
print("\n2. Tokenize 'A = 1, 2, 3':")
let lexer = LexicalAnalyzer()
let tokens = lexer.tokenize("A = 1, 2, 3")
for (i, token) in tokens.enumerated() {
    print("  [\(i)] \(token.type):\(token.value)")
}

// Test 3: What does FunctionTest actually do?
print("\n3. FunctionTest's 'A = 1, 2, 3\\nPRINT VARSIZE(A)':")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = 1, 2, 3\nPRINT VARSIZE(A)")
    print("  Parsed \(statements.count) statement(s):")
    for (i, stmt) in statements.enumerated() {
        print("  [\(i)] \(type(of: stmt)): \(stmt)")
    }
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
    print("  Expected: [\"3\"]")
} catch {
    print("  Error: \(error)")
}

// Test 4: What about the actual array functions?
print("\n4. Test VARSIZE function directly:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(5, 10)\nPRINT VARSIZE(A)")
    print("  Parsed \(statements.count) statement(s):")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
    print("  Expected: [\"10\"]")
} catch {
    print("  Error: \(error)")
}

// Test 5: What does REPEAT actually create?
print("\n5. Test REPEAT function:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(5, 10)\nPRINT A:0, A:1, A:9")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}

// Test 6: Check what VARSIZE returns for REPEAT
print("\n6. Check VARSIZE implementation:")
print("  VARSIZE should return the size of an array")
print("  REPEAT(5, 10) should create array [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]")
print("  VARSIZE should return 10")

// Test 7: What about FINDELEMENT?
print("\n7. Test FINDELEMENT:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(10, 5)\nPRINT FINDELEMENT(A, 10)")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
    print("  Expected: [\"0\"] (first index)")
} catch {
    print("  Error: \(error)")
}

// Test 8: What does "A = 1, 2, 3" actually do in Emuera?
print("\n8. Understanding array assignment:")
print("  In Emuera, 'A = 1, 2, 3' should:")
print("  1. Create array A with 3 elements")
print("  2. Set A:0 = 1, A:1 = 2, A:2 = 3")
print("  3. But our parser treats it as 3 separate statements!")
print("  ")
print("  Current behavior:")
print("    A = 1  -> sets A to 1")
print("    , 2    -> syntax error or ignored")
print("    , 3    -> syntax error or ignored")
print("  ")
print("  This is a parser limitation that needs to be fixed")
