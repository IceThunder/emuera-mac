import Foundation
import EmueraCore

print("=== Debug ARRAYMULTISORT ===")

let parser = ScriptParser()
let executor = StatementExecutor()

// Test 1: Create array with REPEAT
print("\n1. Create array A = REPEAT(3, 3):")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(3, 3)")
    try executor.execute(statements, context: context)
    print("  A = \(context.variables["A"] ?? .null)")
} catch {
    print("  Error: \(error)")
}

// Test 2: Call ARRAYMULTISORT
print("\n2. B = ARRAYMULTISORT(A):")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(3, 3)\nB = ARRAYMULTISORT(A)")
    try executor.execute(statements, context: context)
    print("  A = \(context.variables["A"] ?? .null)")
    print("  B = \(context.variables["B"] ?? .null)")
} catch {
    print("  Error: \(error)")
}

// Test 3: Print B:0, B:1, B:2
print("\n3. PRINT B:0, B:1, B:2:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(3, 3)\nB = ARRAYMULTISORT(A)\nPRINT B:0, B:1, B:2")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
    print("  B = \(context.variables["B"] ?? .null)")
} catch {
    print("  Error: \(error)")
}

// Test 4: What does ARRAYMULTISORT actually return?
print("\n4. Direct ARRAYMULTISORT call:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("PRINT ARRAYMULTISORT(REPEAT(3, 3))")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
} catch {
    print("  Error: \(error)")
}

// Test 5: Check what happens with array access in PRINT
print("\n5. Array access in PRINT:")
do {
    let context = ExecutionContext()
    let statements = try parser.parse("A = REPEAT(5, 3)\nPRINT A:0")
    try executor.execute(statements, context: context)
    print("  Output: \(context.output)")
    print("  A = \(context.variables["A"] ?? .null)")
} catch {
    print("  Error: \(error)")
}
