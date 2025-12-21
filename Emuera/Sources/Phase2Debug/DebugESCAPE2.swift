import Foundation
import EmueraCore

print("=== Debug ESCAPE 2 ===")

// Direct test of ESCAPE function
let testString = "Test\\nLine"  // This is Test, backslash, n, Line
print("Input string: \(testString)")
print("Input string characters: \(testString.map { String($0) })")

// Call ESCAPE directly
let result = try! BuiltInFunctions.execute(name: "ESCAPE", arguments: [.string(testString)])
print("ESCAPE result: \(result)")

if case .string(let str) = result {
    print("Result string: \(str)")
    print("Result characters: \(str.map { String($0) })")
}

// What the test expects
print("\nTest expects: Test\\nLine (2 backslashes)")
print("Test expects in array format: [\"Test\\\\nLine\"]")
