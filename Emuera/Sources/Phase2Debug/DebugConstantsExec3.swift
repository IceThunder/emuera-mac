import Foundation
import EmueraCore

print("=== Debug Constants Exec 3 - FunctionTest Comparison ===")

// Test exactly what FunctionTest does
let parser = ScriptParser()
let executor = StatementExecutor()

// Test 1: Direct execution like FunctionTest
print("\n1. FunctionTest style:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("PRINT __INT_MAX__")
    print("  Parsed statements: \(statements.count)")
    for stmt in statements {
        print("  Statement: \(stmt)")
    }
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
    print("  Expected: [\"9223372036854775807\"]")
} catch {
    print("  Error: \(error)")
}

// Test 2: Step by step tokenization
print("\n2. Tokenization:")
let lexer = LexicalAnalyzer()
let tokens = lexer.tokenize("PRINT __INT_MAX__")
for (i, token) in tokens.enumerated() {
    print("  [\(i)] \(token.type):\(token.value)")
}

// Test 3: What does parsePrintArguments return?
print("\n3. Manual parsePrintArguments trace:")
let tokens2 = lexer.tokenize("PRINT __INT_MAX__")
print("  Tokens: \(tokens2)")

// Test 4: Check if __INT_MAX__ is tokenized as .function
print("\n4. Check token type:")
let testTokens = lexer.tokenize("__INT_MAX__")
for token in testTokens {
    print("  Token: \(token.type)")
    if case .function(let name) = token.type {
        print("  Function name: \(name)")
    }
}

// Test 5: ExpressionParser directly
print("\n5. ExpressionParser test:")
let exprParser = ExpressionParser()
do {
    let exprTokens = lexer.tokenize("__INT_MAX__")
    print("  Input tokens: \(exprTokens)")
    let expr = try exprParser.parse(exprTokens)
    print("  AST: \(expr)")

    let evaluator = ExpressionEvaluator(variableData: VariableData())
    let result = try evaluator.evaluate(expr)
    print("  Evaluated: \(result)")
} catch {
    print("  Error: \(error)")
}

// Test 6: What if we call parsePrintArguments manually?
print("\n6. Simulate parsePrintArguments:")
let testTokens2 = lexer.tokenize("PRINT __INT_MAX__")
print("  All tokens: \(testTokens2)")
print("  After PRINT, remaining: \(Array(testTokens2.dropFirst()))")

// Check the actual flow
print("\n7. Check what happens in parsePrintArguments:")
// Skip PRINT token
var currentIndex = 1
let tokens3 = testTokens2

// Skip whitespace
while currentIndex < tokens3.count {
    if case .whitespace = tokens3[currentIndex].type {
        currentIndex += 1
    } else {
        break
    }
}

print("  After skipping whitespace, index: \(currentIndex)")
if currentIndex < tokens3.count {
    print("  Current token: \(tokens3[currentIndex].type)")

    // Check if it's a line break
    if case .lineBreak = tokens3[currentIndex].type {
        print("  -> Would return []")
    }
    // Check if it's a string
    else if case .string = tokens3[currentIndex].type {
        print("  -> Would handle as string")
    }
    // Check if it's an expression start
    else {
        let nextToken = tokens3[currentIndex]
        let isExprStart: Bool
        switch nextToken.type {
        case .integer, .string, .variable, .parenthesisOpen, .command, .keyword, .operatorSymbol, .comparator, .function:
            isExprStart = true
        default:
            isExprStart = false
        }
        print("  isExprStart: \(isExprStart)")

        if isExprStart {
            // This is where the actual logic happens
            print("  -> Would collect tokens and parse")

            // Simulate collectExpressionTokens
            var exprTokens: [TokenType.Token] = []
            var parenDepth = 0
            var idx = currentIndex

            while idx < tokens3.count {
                let token = tokens3[idx]
                switch token.type {
                case .lineBreak:
                    if parenDepth == 0 {
                        idx += 1
                        break
                    }
                    idx += 1
                    continue
                case .whitespace:
                    idx += 1
                    continue
                case .comment:
                    idx += 1
                    continue
                case .parenthesisOpen:
                    parenDepth += 1
                    exprTokens.append(token)
                    idx += 1
                case .parenthesisClose:
                    parenDepth -= 1
                    exprTokens.append(token)
                    idx += 1
                case .comma:
                    if parenDepth == 0 {
                        break
                    }
                    exprTokens.append(token)
                    idx += 1
                case .operatorSymbol, .comparator:
                    exprTokens.append(token)
                    idx += 1
                case .integer, .string, .variable:
                    exprTokens.append(token)
                    idx += 1
                case .colon:
                    exprTokens.append(token)
                    idx += 1
                case .function:
                    exprTokens.append(token)
                    idx += 1
                default:
                    break
                }

                if parenDepth == 0 && idx < tokens3.count {
                    let nextToken = tokens3[idx]
                    switch nextToken.type {
                    case .command, .keyword:
                        break
                    default:
                        continue
                    }
                }
            }

            print("  Collected exprTokens: \(exprTokens)")
            print("  Count: \(exprTokens.count)")

            if exprTokens.count == 1 {
                let token = exprTokens[0]
                print("  Single token case:")
                switch token.type {
                case .variable(let name):
                    print("    -> [.variable(\(name))]")
                case .integer(let value):
                    print("    -> [.integer(\(value))]")
                case .string(let value):
                    print("    -> [.string(\(value))]")
                case .function(let name):
                    print("    -> Would check for __INT_MAX__")
                    if name.uppercased() == "__INT_MAX__" {
                        print("    -> [.integer(9223372036854775807)]")
                    } else {
                        print("    -> [.variable(\(name))]")
                    }
                default:
                    print("    -> []")
                }
            }
        }
    }
}

print("\n=== Summary ===")
print("The fix is in place at lines 980-989 of ScriptParser.swift")
print("But FunctionTest still fails. Let's check if there's another issue...")

// Test 7: Check if the issue is in the actual FunctionTest file
print("\n8. Check FunctionTest's exact test:")
print("  FunctionTest has: PRINT __INT_MAX__")
print("  Expected output: [\"9223372036854775807\"]")
print("  Actual output: [\"\"]")

print("\n9. Let's trace the actual execution:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("PRINT __INT_MAX__")

    print("  Parsed \(statements.count) statement(s)")
    for (i, stmt) in statements.enumerated() {
        print("  [\(i)] \(type(of: stmt)): \(stmt)")

        if let cmd = stmt as? CommandStatement {
            print("    Command: \(cmd.command)")
            print("    Arguments: \(cmd.arguments)")
            for (j, arg) in cmd.arguments.enumerated() {
                print("      [\(j)] \(type(of: arg)): \(arg)")
            }
        }
    }

    try executor.execute(statements, context: context)
    print("  Final output: '\(context.output)'")
    print("  Output length: \(context.output.count)")

} catch {
    print("  Error: \(error)")
}

// Test 8: Check if the fix is actually being used
print("\n10. Verify the fix is in ScriptParser.swift:")
print("  Lines 980-989 should handle .function case")
print("  Let's check what parsePrintArguments actually returns...")

do {
    // Use reflection to check the actual method
    let testParser = ScriptParser()
    let lexer = LexicalAnalyzer()
    let tokens = lexer.tokenize("PRINT __INT_MAX__")

    print("  Tokens from lexer: \(tokens)")

    // Try to call parse directly
    let result = try testParser.parse("PRINT __INT_MAX__")
    print("  Parse result count: \(result.count)")

    if let first = result.first as? CommandStatement {
        print("  Command: \(first.command)")
        print("  Arguments count: \(first.arguments.count)")
        if first.arguments.count > 0 {
            print("  First argument: \(first.arguments[0])")
            print("  First argument type: \(type(of: first.arguments[0]))")
        } else {
            print("  NO ARGUMENTS - This is the bug!")
        }
    }
} catch {
    print("  Error: \(error)")
}
