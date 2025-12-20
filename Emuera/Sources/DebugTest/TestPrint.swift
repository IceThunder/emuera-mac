import Foundation
import EmueraCore

@main
struct TestPrint {
    static func main() {
        print("=== Testing PRINT argument parsing ===\n")

        // Test 1: Simple text
        test("PRINTL Start complex test", """
        PRINTL Start complex test
        """)

        // Test 2: Variable
        test("PRINTL with variable", """
        A = 10
        PRINTL A
        """)

        // Test 3: Expression
        test("PRINTL with expression", """
        A = 10
        B = 20
        PRINTL A + B
        """)

        // Test 3b: Just expression
        test("PRINTL just expression", """
        A = 10
        B = 20
        PRINTL (A + B)
        """)

        // Test 4: Quoted string
        test("PRINTL with quoted string", """
        PRINTL "Hello World"
        """)

        // Test 5: Real test file pattern
        test("Real pattern", """
        A = 10
        B = 20
        C = A + B
        PRINT A equals
        PRINTL A
        PRINT C equals A plus B equals
        PRINTL C
        """)
    }

    static func test(_ name: String, _ script: String) {
        print("--- \(name) ---")
        print("Script: \(script)")

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            print("Parsed \(statements.count) statements")

            for (i, stmt) in statements.enumerated() {
                print("  [\(i)] \(type(of: stmt)): \(stmt)")
                if let cmd = stmt as? CommandStatement {
                    print("      Command: \(cmd.command), Args: \(cmd.arguments)")
                }
                if let expr = stmt as? ExpressionStatement {
                    print("      Expr: \(expr.expression)")
                }
            }

            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("Output: \(output)")
            print("Output count: \(output.count)")

        } catch {
            print("ERROR: \(error)")
        }
        print()
    }
}
