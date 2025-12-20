import Foundation
import EmueraCore

@main
struct PrintTest {
    static func main() {
        print("=== Testing PRINTL with English text ===\n")

        let script = "PRINTL C greater than 15 is true!"

        print("Script: '\(script)'")
        print()

        do {
            let parser = ScriptParser()
            print("Parsing...")
            let statements = try parser.parse(script)
            print("Parsed \(statements.count) statements")
            for stmt in statements {
                print("  \(stmt)")
                if let cmd = stmt as? CommandStatement {
                    print("    Command: \(cmd.command)")
                    print("    Arguments: \(cmd.arguments)")
                }
            }

            let executor = StatementExecutor()
            print("\nExecuting...")
            let output = executor.execute(statements)
            print("Output: \(output)")

        } catch {
            print("ERROR: \(error)")
        }
    }
}