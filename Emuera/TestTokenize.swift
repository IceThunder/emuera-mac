import EmueraCore

let analyzer = LexicalAnalyzer()
let tokens = analyzer.tokenize("SKIP:")
for t in tokens {
    print("Token: \(t.description)")
}
