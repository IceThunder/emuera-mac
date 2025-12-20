import Foundation
import EmueraCore

/// 调试词法分析器
@main
struct DebugLexical {
    static func main() {
        print("=== Debug Lexical Analysis ===\n")

        let scripts = [
            "PRINTL Loop test:",
            "PRINTL C greater than 15 is true!",
            "PRINTL Start complex test",
        ]

        let lexer = LexicalAnalyzer()

        for script in scripts {
            print("Script: '\(script)'")
            let tokens = lexer.tokenize(script)
            for (i, token) in tokens.enumerated() {
                print("  [\(i)] \(token)")
            }
            print()
        }
    }
}
