import Foundation
import EmueraCore

print("=== Debug Array Assignment ===")

let parser = ScriptParser()
let executor = StatementExecutor()

// Test 1: Array assignment
print("\nTest 1: A = 1, 2, 3")
let script1 = "A = 1, 2, 3"
let stmts1 = try! parser.parse(script1)
print("Parsed: \(stmts1)")
let output1 = executor.execute(stmts1)
print("Output: \(output1)")

// Test 2: Print array
print("\nTest 2: PRINT A")
let script2 = "PRINT A"
let stmts2 = try! parser.parse(script2)
print("Parsed: \(stmts2)")
let output2 = executor.execute(stmts2)
print("Output: \(output2)")

// Test 3: VARSIZE
print("\nTest 3: PRINT VARSIZE(A)")
let script3 = "PRINT VARSIZE(A)"
let stmts3 = try! parser.parse(script3)
print("Parsed: \(stmts3)")
let output3 = executor.execute(stmts3)
print("Output: \(output3)")

// Test 4: Combined
print("\nTest 4: Combined")
let script4 = "A = 1, 2, 3\nPRINT VARSIZE(A)"
let stmts4 = try! parser.parse(script4)
print("Parsed: \(stmts4)")
let output4 = executor.execute(stmts4)
print("Output: \(output4)")

// Test 5: What does REPEAT produce?
print("\nTest 5: A = REPEAT(3, 5)")
let script5 = "A = REPEAT(3, 5)\nPRINT VARSIZE(A)"
let stmts5 = try! parser.parse(script5)
print("Parsed: \(stmts5)")
let output5 = executor.execute(stmts5)
print("Output: \(output5)")
