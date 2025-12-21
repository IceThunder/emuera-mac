import Foundation
import EmueraCore

print("=== Debug ESCAPE ===")

let parser = ScriptParser()
let executor = StatementExecutor()

// Test what the lexer produces for the string literal
print("\nTest: What does the lexer produce for the string?")
let script1 = "PRINT ESCAPE(\"Test\\\\nLine\")"
print("Script: \(script1)")

let lexer = LexicalAnalyzer()
let tokens = lexer.tokenize(script1)
print("Tokens: \(tokens)")

// Now test ESCAPE
print("\nTest: ESCAPE function")
let stmts = try parser.parse(script1)
print("Statements: \(stmts)")
let output = executor.execute(stmts)
print("Output: \(output)")
print("Expected: [\"Test\\\\nLine\"]")

// Test with actual newline
print("\nTest: ESCAPE with actual newline")
let script2 = "PRINT ESCAPE(\"Test\\nLine\")"
print("Script: \(script2)")
let stmts2 = try parser.parse(script2)
print("Statements: \(stmts2)")
let output2 = executor.execute(stmts2)
print("Output: \(output2)")
