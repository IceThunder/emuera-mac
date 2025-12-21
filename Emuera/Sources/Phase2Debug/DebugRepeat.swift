import Foundation
import EmueraCore

print("=== Debug REPEAT Function ===")

let parser = ScriptParser()
let executor = StatementExecutor()

// Test 1: Direct REPEAT call
print("\n1. Direct REPEAT(5, 10):")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(5, 10)")
    print("  Parsed: \(statements.count) statement(s)")
    for stmt in statements {
        print("    \(type(of: stmt)): \(stmt)")
    }
    try executor.execute(statements, context: context)
    print("  After execution:")
    print("    A = \(context.variables["A"] ?? .null)")
} catch {
    print("  Error: \(error)")
}

// Test 2: What does REPEAT return directly?
print("\n2. Test REPEAT in ExpressionParser:")
let lexer = LexicalAnalyzer()
let exprParser = ExpressionParser()

do {
    let tokens = lexer.tokenize("REPEAT(5, 10)")
    print("  Tokens: \(tokens)")
    let expr = try exprParser.parse(tokens)
    print("  AST: \(expr)")

    let evaluator = ExpressionEvaluator(variableData: VariableData())
    let result = try evaluator.evaluate(expr)
    print("  Evaluated: \(result)")
} catch {
    print("  Error: \(error)")
}

// Test 3: Check what happens with PRINT REPEAT
print("\n3. PRINT REPEAT(5, 10):")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("PRINT REPEAT(5, 10)")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}

// Test 4: Check what happens with A = REPEAT then PRINT A
print("\n4. A = REPEAT(5, 10) then PRINT A:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(5, 10)\nPRINT A")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
    print("  Variable A: \(context.variables["A"] ?? .null)")
} catch {
    print("  Error: \(error)")
}

// Test 5: Check what happens with PRINT A:0
print("\n5. A = REPEAT(5, 10) then PRINT A:0:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(5, 10)\nPRINT A:0")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}

// Test 6: Check what VARSIZE returns for this
print("\n6. A = REPEAT(5, 10) then PRINT VARSIZE(A):")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(5, 10)\nPRINT VARSIZE(A)")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}

// Test 7: Check what FINDELEMENT returns
print("\n7. A = REPEAT(10, 5) then PRINT FINDELEMENT(A, 10):")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(10, 5)\nPRINT FINDELEMENT(A, 10)")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}

// Test 8: Check what FINDELEMENT returns for value not in array
print("\n8. A = REPEAT(10, 5) then PRINT FINDELEMENT(A, 20):")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(10, 5)\nPRINT FINDELEMENT(A, 20)")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}
