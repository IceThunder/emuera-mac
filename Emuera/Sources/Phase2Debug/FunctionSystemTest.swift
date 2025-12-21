import Foundation
import EmueraCore

// Comprehensive Phase 2 Function System Test
// This tests all Phase 2 features: function definitions, local variables, scoping, and calls

print("=== Phase 2 Function System Test ===")
print()

// Test 1: Simple Function Definition
print("Test 1: Simple Function Definition")
print("-" * 40)
do {
    let parser = ScriptParser()
    let source = """
    @TEST_FUNC
    RETURNF 42
    """
    let statements = try parser.parse(source)
    print("✓ Parsed \(statements.count) statements")
    print("  Statements: \(statements)")

    // Verify it's a FunctionDefinitionStatement
    if let funcDef = statements.first as? FunctionDefinitionStatement {
        print("✓ Function name: \(funcDef.definition.name)")
        print("  Parameters: \(funcDef.definition.parameters)")
        print("  Body statements: \(funcDef.definition.body.count)")
    }
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 2: Function with Parameters
print("Test 2: Function with Parameters")
print("-" * 40)
do {
    let parser = ScriptParser()
    let source = """
    @ADD_TWO_NUMBERS, ARG:1, ARG:2
    LOCAL:1 = ARG:1 + ARG:2
    RETURNF LOCAL:1
    """
    let statements = try parser.parse(source)
    print("✓ Parsed \(statements.count) statements")

    if let funcDef = statements.first as? FunctionDefinitionStatement {
        print("✓ Function name: \(funcDef.definition.name)")
        print("  Parameters: \(funcDef.definition.parameters)")
        print("  Body statements: \(funcDef.definition.body.count)")
    }
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 3: Function with Local Variables
print("Test 3: Function with Local Variables")
print("-" * 40)
do {
    let parser = ScriptParser()
    let source = """
    @CALCULATE_SUM
    #DIM LOCAL, 3
    LOCAL:0 = 1
    LOCAL:1 = 2
    LOCAL:2 = LOCAL:0 + LOCAL:1
    RETURNF LOCAL:2
    """
    let statements = try parser.parse(source)
    print("✓ Parsed \(statements.count) statements")

    if let funcDef = statements.first as? FunctionDefinitionStatement {
        print("✓ Function name: \(funcDef.definition.name)")
        print("  Directives: \(funcDef.definition.directives)")
        print("  Body statements: \(funcDef.definition.body.count)")
    }
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 4: Function Call
print("Test 4: Function Call")
print("-" * 40)
do {
    let parser = ScriptParser()
    let source = """
    CALL TEST_FUNC
    PRINTL Result: %RESULT%
    """
    let statements = try parser.parse(source)
    print("✓ Parsed \(statements.count) statements")
    print("  Statements: \(statements)")
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 5: Scoped Variable Expression
print("Test 5: Scoped Variable Expression")
print("-" * 40)
do {
    let parser = ScriptParser()
    let source = """
    LOCAL:1 = 10
    ARG:2 = 20
    RESULT:0 = LOCAL:1 + ARG:2
    """
    let statements = try parser.parse(source)
    print("✓ Parsed \(statements.count) statements")

    for (i, stmt) in statements.enumerated() {
        print("  Statement \(i + 1): \(type(of: stmt))")
        if let exprStmt = stmt as? ExpressionStatement {
            print("    Expression: \(exprStmt.expression)")
        }
    }
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 6: Built-in Function Execution
print("Test 6: Built-in Function Execution")
print("-" * 40)
do {
    let parser = ScriptParser()
    let executor = StatementExecutor()

    // Test LIMIT function
    let source = """
    LOCAL:0 = LIMIT(100, 0, 50)
    PRINTL Limited value: %LOCAL:0%
    """
    let statements = try parser.parse(source)
    let output = executor.execute(statements)
    print("✓ Executed LIMIT function")
    print("  Output: \(output)")
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 7: String Functions
print("Test 7: String Functions")
print("-" * 40)
do {
    let parser = ScriptParser()
    let executor = StatementExecutor()

    let source = """
    LOCALS:0 = "Hello"
    LOCALS:1 = "World"
    RESULTS:0 = LOCALS:0 + " " + LOCALS:1
    PRINTL %RESULTS:0%
    """
    let statements = try parser.parse(source)
    let output = executor.execute(statements)
    print("✓ Executed string operations")
    print("  Output: \(output)")
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 8: Array Operations
print("Test 8: Array Operations")
print("-" * 40)
do {
    let parser = ScriptParser()
    let executor = StatementExecutor()

    let source = """
    #DIM LOCAL, 5
    LOCAL:0 = 1
    LOCAL:1 = 2
    LOCAL:2 = LOCAL:0 + LOCAL:1
    PRINTL Array sum: %LOCAL:2%
    """
    let statements = try parser.parse(source)
    let output = executor.execute(statements)
    print("✓ Executed array operations")
    print("  Output: \(output)")
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 9: Complex Expression
print("Test 9: Complex Expression")
print("-" * 40)
do {
    let parser = ScriptParser()
    let executor = StatementExecutor()

    let source = """
    LOCAL:0 = (10 + 5) * 2 - 3
    PRINTL Result: %LOCAL:0%
    """
    let statements = try parser.parse(source)
    let output = executor.execute(statements)
    print("✓ Executed complex expression")
    print("  Output: \(output)")
} catch {
    print("✗ Error: \(error)")
}
print()

// Test 10: Conditional Logic
print("Test 10: Conditional Logic")
print("-" * 40)
do {
    let parser = ScriptParser()
    let executor = StatementExecutor()

    let source = """
    LOCAL:0 = 10
    IF LOCAL:0 > 5
        PRINTL Greater than 5
    ELSE
        PRINTL Less than or equal to 5
    ENDIF
    """
    let statements = try parser.parse(source)
    let output = executor.execute(statements)
    print("✓ Executed conditional logic")
    print("  Output: \(output)")
} catch {
    print("✗ Error: \(error)")
}
print()

print("=== Phase 2 Function System Test Complete ===")

// Helper function for string repetition
func *(lhs: String, rhs: Int) -> String {
    return String(repeating: lhs, count: rhs)
}
