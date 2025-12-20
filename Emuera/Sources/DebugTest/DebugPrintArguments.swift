import Foundation
import EmueraCore

@main
struct DebugPrintArguments {
    static func main() {
        print("=== Debug parsePrintArguments() ===\n")

        // Test the exact failing case
        let script = "PRINTL C greater than 15 is true!"

        print("Script: '\(script)'")
        print()

        // Step 1: Lexical analysis
        let lexer = LexicalAnalyzer()
        let tokens = lexer.tokenize(script)
        print("Step 1 - Tokens from LexicalAnalyzer:")
        for (i, token) in tokens.enumerated() {
            print("  [\(i)] \(token)")
        }
        print()

        // Step 2: Parse
        do {
            let parser = ScriptParser()
            print("Step 2 - Parsing with ScriptParser...")
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
        }
    }
}
