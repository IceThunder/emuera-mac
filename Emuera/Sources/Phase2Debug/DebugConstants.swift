import Foundation
import EmueraCore

print("=== Debug Constants ===")

let lexer = LexicalAnalyzer()

let tests = [
    "__INT_MAX__",
    "__INT_MIN__",
    "PRINT __INT_MAX__",
    "PRINT __INT_MIN__"
]

for script in tests {
    print("\nScript: '\(script)'")
    let tokens = lexer.tokenize(script)
    for (i, token) in tokens.enumerated() {
        print("  [\(i)] \(token.type):\(token.value)")
    }
}
