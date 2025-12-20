import Foundation
import EmueraCore

@main
struct DebugForLoop {
    static func main() {
        print("=== Debug FOR loop parsing ===\n")

        // Simplest possible FOR loop
        let script = "FOR I, 1, 3\nENDFOR"

        print("Script: '\(script)'")
        print()

        do {
            let parser = ScriptParser()
            print("Parsing...")
            let statements = try parser.parse(script)
            print("Parsed \(statements.count) statements")
            for stmt in statements {
                print("  \(stmt)")
            }

        } catch {
            print("ERROR: \(error)")
        }
    }
}