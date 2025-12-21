import Foundation
import EmueraCore

print("=== Debug Constants Execution ===")

// Test 1: Direct tokenization
print("\n1. Tokenization test:")
let lexer = LexicalAnalyzer()
let tokens = lexer.tokenize("PRINT __INT_MAX__")
for (i, token) in tokens.enumerated() {
    print("  [\(i)] \(token.type):\(token.value)")
}

// Test 2: Script parsing
print("\n2. Script parsing test:")
let parser = ScriptParser()
do {
    let statements = try parser.parse("PRINT __INT_MAX__")
    print("  Parsed \(statements.count) statement(s)")
    for (i, stmt) in statements.enumerated() {
        print("  [\(i)] \(stmt)")
    }
} catch {
    print("  Error: \(error)")
}

// Test 3: Execution
print("\n3. Execution test:")
let executor = StatementExecutor()
do {
    let context = ExecutionContext()
    let statements = try parser.parse("PRINT __INT_MAX__")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}

// Test 4: ExpressionParser directly
print("\n4. ExpressionParser test:")
let exprParser = ExpressionParser()
do {
    let exprTokens = lexer.tokenize("__INT_MAX__")
    print("  Tokens: \(exprTokens)")
    let expr = try exprParser.parse(exprTokens)
    print("  AST: \(expr)")

    // Evaluate
    let evaluator = ExpressionEvaluator(variableData: VariableData())
    let result = try evaluator.evaluate(expr)
    print("  Result: \(result)")
} catch {
    print("  Error: \(error)")
}
