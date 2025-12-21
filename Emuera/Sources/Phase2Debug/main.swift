import Foundation
import EmueraCore

print("1. Starting program")
fflush(stdout)

print("2. Creating LexicalAnalyzer...")
fflush(stdout)

let lexer = LexicalAnalyzer()
print("3. LexicalAnalyzer created")
fflush(stdout)

print("4. Calling tokenize()...")
fflush(stdout)

let source = "@TEST_FUNC\nRETURNF 42"
let tokens = lexer.tokenize(source)

print("5. Tokenization complete! Tokens: \(tokens.count)")
for (i, token) in tokens.enumerated() {
    print("   \(i): \(token.type)")
}
fflush(stdout)

print("6. All done!")
