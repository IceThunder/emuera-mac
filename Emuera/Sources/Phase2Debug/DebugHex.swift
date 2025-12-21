import Foundation
import EmueraCore

print("=== Debug Hex Literal Parsing ===")

let lexer = LexicalAnalyzer()

// Test hex literals
let tests = [
    "0x123456",
    "0x0",
    "0xFF",
    "0xABCDEF",
    "PRINT GETNUMB(0x123456, 0)",
    "A = 0x100"
]

for script in tests {
    print("\nScript: '\(script)'")
    let tokens = lexer.tokenize(script)
    for (i, token) in tokens.enumerated() {
        print("  [\(i)] \(token.type):\(token.value)@\(token.position)")
    }
}
