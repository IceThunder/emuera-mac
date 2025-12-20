import Foundation
import EmueraCore

@main
struct MiniTest {
    static func main() {
        print("Mini test: PRINTL Start complex test")

        let script = "PRINTL Start complex test"

        do {
            let parser = ScriptParser()
            print("Parsing...")
            let statements = try parser.parse(script)
            print("Parsed \(statements.count) statements")

            for stmt in statements {
                print("Statement: \(stmt)")
                if let cmd = stmt as? CommandStatement {
                    print("  Command: \(cmd.command)")
                    print("  Arguments: \(cmd.arguments)")
                }
            }

            let executor = StatementExecutor()
            let output = executor.execute(statements)
            print("Output: \(output)")

        } catch {
            print("ERROR: \(error)")
        }
    }
}
