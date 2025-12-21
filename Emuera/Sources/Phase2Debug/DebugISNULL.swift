import Foundation
import EmueraCore

print("=== Debug ISNULL ===")

let parser = ScriptParser()
let executor = StatementExecutor()

// Test 1: ISNULL(0)
print("\nTest 1: ISNULL(0)")
let script1 = "PRINT ISNULL(0)"
let stmts1 = try parser.parse(script1)
let output1 = executor.execute(stmts1)
print("Output: \(output1)")
print("Expected: [\"0\"]")

// Test 2: ISNULL(NULL)
print("\nTest 2: ISNULL(NULL)")
let script2 = "PRINT ISNULL(NULL)"
let stmts2 = try parser.parse(script2)
print("Statements: \(stmts2)")
let output2 = executor.execute(stmts2)
print("Output: \(output2)")
print("Expected: [\"1\"]")

// Test 3: Combined
print("\nTest 3: PRINT ISNULL(0), ISNULL(NULL)")
let script3 = "PRINT ISNULL(0), ISNULL(NULL)"
let stmts3 = try parser.parse(script3)
let output3 = executor.execute(stmts3)
print("Output: \(output3)")
print("Expected: [\"0 1\"]")

// Debug: What does NULL evaluate to?
print("\n=== Debug: NULL variable ===")
let script4 = "A = NULL\nPRINT A"
let stmts4 = try parser.parse(script4)
let output4 = executor.execute(stmts4)
print("A = NULL, PRINT A => \(output4)")

// Debug: What about direct NULL?
print("\n=== Debug: Direct NULL ===")
let script5 = "PRINT NULL"
let stmts5 = try parser.parse(script5)
print("Statements: \(stmts5)")
let output5 = executor.execute(stmts5)
print("PRINT NULL => \(output5)")
