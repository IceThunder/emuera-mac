import EmueraCore

let path = "/Users/ss/Documents/Project/iOS/emuera-mac/test_game/erb/complex_test.erb"

do {
    let content = try String(contentsOfFile: path, encoding: .utf8)
    print("File content:")
    print("====")
    print(content)
    print("====")
    print("Lines:")
    let lines = content.components(separatedBy: "\n")
    for (i, line) in lines.enumerated() {
        print("\(i+1): '\(line)'")
    }

    print("\nParsing...")
    let parser = ScriptParser()
    let statements = try parser.parse(content)
    print("✅ Parsed \(statements.count) statements")

} catch {
    print("❌ Error: \(error)")
}
