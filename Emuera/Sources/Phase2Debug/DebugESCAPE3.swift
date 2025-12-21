import Foundation
import EmueraCore

print("=== Debug ESCAPE 3 - Full Flow ===")

// Test 1: What the user writes in ERB
print("\n--- Test 1: User's ERB script ---")
let erbScript = "PRINT ESCAPE(\"Test\\\\nLine\")"
print("ERB Script: \(erbScript)")
print("This is what the user types in their .erb file")

// Test 2: How Swift interprets it
print("\n--- Test 2: Swift string literal ---")
let swiftString = "Test\\\\nLine"  // Swift: \\ = one backslash
print("Swift string: \(swiftString)")
print("Characters: \(swiftString.map { String($0) })")
print("Swift sees: Test, backslash, n, Line")

// Test 3: What the lexer produces
print("\n--- Test 3: Lexer output ---")
let lexer = LexicalAnalyzer()
let tokens = lexer.tokenize(erbScript)
print("Tokens: \(tokens)")
if tokens.count >= 4, case .string(let value) = tokens[3].type {
    print("String token value: \(value)")
    print("String characters: \(value.map { String($0) })")
}

// Test 4: What ESCAPE function receives and returns
print("\n--- Test 4: ESCAPE function ---")
if tokens.count >= 4, case .string(let value) = tokens[3].type {
    let result = try! BuiltInFunctions.execute(name: "ESCAPE", arguments: [.string(value)])
    if case .string(let resultStr) = result {
        print("Input to ESCAPE: \(value)")
        print("Input chars: \(value.map { String($0) })")
        print("ESCAPE output: \(resultStr)")
        print("Output chars: \(resultStr.map { String($0) })")
    }
}

// Test 5: Full parse and execute
print("\n--- Test 5: Full pipeline ---")
let parser = ScriptParser()
let executor = StatementExecutor()
let stmts = try! parser.parse(erbScript)
let output = executor.execute(stmts)
print("Full pipeline output: \(output)")

// Test 6: What the test expects
print("\n--- Test 6: Test expectation ---")
print("Test expects: [\"Test\\\\nLine\"]")
print("This means: Test, backslash, backslash, n, Line")
print("In the array: the string contains 2 backslashes")

// Test 7: Manual trace
print("\n--- Test 7: Manual trace ---")
let input = "Test\\\\nLine"  // This is what the lexer gives us
print("1. Input to ESCAPE: '\(input)'")
print("2. Input characters: \(input.map { String($0) })")

var result = ""
for char in input {
    switch char {
    case "\"": result += "\\\""
    case "\n": result += "\\n"
    case "\r": result += "\\r"
    case "\t": result += "\\t"
    default: result.append(char)
    }
}
print("3. ESCAPE processes each character:")
print("   - 'T', 'e', 's', 't' -> append")
print("   - '\\\\' -> append (default case)")
print("   - 'n' -> append (default case)")
print("   - 'L', 'i', 'n', 'e' -> append")
print("4. ESCAPE result: '\(result)'")
print("5. Result characters: \(result.map { String($0) })")

// Test 8: What if the input had an actual newline?
print("\n--- Test 8: With actual newline ---")
let inputWithNewline = "Test\nLine"  // Actual newline character
print("Input: '\(inputWithNewline)'")
print("Input chars: \(inputWithNewline.map { String($0) })")

var result2 = ""
for char in inputWithNewline {
    switch char {
    case "\"": result2 += "\\\""
    case "\n": result2 += "\\n"
    case "\r": result2 += "\\r"
    case "\t": result2 += "\\t"
    default: result2.append(char)
    }
}
print("ESCAPE result: '\(result2)'")
print("Result chars: \(result2.map { String($0) })")
print("This is what the second test expects!")

// Test 9: What the reference Emuera does
print("\n--- Test 9: Reference Emuera behavior ---")
print("According to Emuera C# source:")
print("ESCAPE converts control chars to escape sequences")
print("- Input: 'Test\\nLine' (with actual newline)")
print("- Output: 'Test\\\\nLine' (with backslash-n sequence)")
print("")
print("But our test file says:")
print("Test 1: ESCAPE(\"Test\\\\nLine\") -> expect [\"Test\\\\nLine\"]")
print("Test 2: ESCAPE(\"Test\\nLine\") -> expect [\"Test\\\\nLine\"]")
print("")
print("Wait, both tests expect the SAME output!")
print("This means:")
print("- Test 1 input has 2 backslashes, output should have 2 backslashes")
print("- Test 2 input has 1 newline, output should have 2 backslashes")
print("")
print("So ESCAPE should:")
print("- NOT change backslashes")
print("- Convert newline to \\n")
print("- Convert quote to \\\"")
print("- Convert carriage return to \\r")
print("- Convert tab to \\t")
