import Foundation
import EmueraCore

print("=== Debug Print Arguments for Array Access ===")

let lexer = LexicalAnalyzer()
let parser = ScriptParser()

// Test: PRINT A:0
print("\nTest: PRINT A:0")
do {
    let tokens = lexer.tokenize("PRINT A:0")
    print("  Tokens: \(tokens)")

    let statements = try parser.parse("PRINT A:0")
    print("  Statements: \(statements)")

    for stmt in statements {
        if let printStmt = stmt as? PrintStatement {
            print("  Print arguments: \(printStmt.arguments)")
            for (i, arg) in printStmt.arguments.enumerated() {
                print("    [\(i)]: \(type(of: arg)) - \(arg)")
            }
        }
    }
} catch {
    print("  Error: \(error)")
}

// Test: A = REPEAT(5, 3) then PRINT A:0
print("\nTest: A = REPEAT(5, 3) then PRINT A:0")
do {
    let statements = try parser.parse("A = REPEAT(5, 3)\nPRINT A:0")
    print("  Statements: \(statements)")

    let executor = StatementExecutor()
    let context = ExecutionContext()
    try executor.execute(statements, context: context)

    print("  Variable A: \(context.variables["A"] ?? .null)")
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}
