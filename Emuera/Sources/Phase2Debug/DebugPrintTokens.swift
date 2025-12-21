import Foundation
import EmueraCore

print("=== Debug: PRINT A:0 tokens ===")
let lexer = LexicalAnalyzer()
let tokens = lexer.tokenize("PRINT A:0")
for (i, token) in tokens.enumerated() {
    print("  Token \(i): \(token)")
}

print("\n=== Debug: Parsing ===")
let parser = ScriptParser()
do {
    let statements = try parser.parse("A = REPEAT(5, 3)\nPRINT A:0")
    print("Statements: \(statements)")
    
    for stmt in statements {
        if let printStmt = stmt as? CommandStatement {
            print("Command: \(printStmt.command)")
            print("Arguments count: \(printStmt.arguments.count)")
            for (i, arg) in printStmt.arguments.enumerated() {
                print("  Arg \(i): \(type(of: arg)) - \(arg)")
            }
        }
    }
} catch {
    print("Error: \(error)")
}
