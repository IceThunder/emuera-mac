import Foundation
import EmueraCore

@main
struct DebugCollect {
    static func main() {
        print("=== Debug parsePrintArguments() ===\n")
        fflush(stdout)

        // Test the exact failing case
        let script = "PRINTL C greater than 15 is true!"
        print("Script: '\(script)'")
        fflush(stdout)

        // Parse
        do {
            let parser = ScriptParser()
            print("Parsing with ScriptParser...")
            fflush(stdout)
            let statements = try parser.parse(script)
            print("Success! Parsed \(statements.count) statements:")
            for stmt in statements {
                print("  \(stmt)")
                if let cmd = stmt as? CommandStatement {
                    print("    Command: \(cmd.command)")
                    print("    Arguments: \(cmd.arguments)")
                }
            }
        } catch {
            print("❌ ERROR: \(error)")
            fflush(stdout)
        }
    }
}