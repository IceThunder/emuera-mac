import Foundation
import EmueraCore

let parser = ScriptParser()
let executor = StatementExecutor()

print("=== Testing Constants ===")

// Test 1: Direct parse
print("\n1. Parse test:")
do {
    let statements = try parser.parse("PRINT __INT_MAX__")
    print("  Parsed \(statements.count) statement(s)")
    for stmt in statements {
        if let cmd = stmt as? CommandStatement {
            print("  Command: \(cmd.command)")
            print("  Arguments count: \(cmd.arguments.count)")
            for (i, arg) in cmd.arguments.enumerated() {
                print("    Arg \(i): \(arg)")
            }
        }
    }
} catch {
    print("  Parse error: \(error)")
}

// Test 2: Execute
print("\n2. Execute test:")
do {
    let statements = try parser.parse("PRINT __INT_MAX__")
    let output = executor.execute(statements)
    print("  Output: \(output)")
} catch {
    print("  Execute error: \(error)")
}

// Test 3: What does parsePrintArguments return?
print("\n3. Manual trace:")
let lexer = LexicalAnalyzer()
let tokens = lexer.tokenize("PRINT __INT_MAX__")
print("  Tokens: \(tokens)")
