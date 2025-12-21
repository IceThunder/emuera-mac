import Foundation
import EmueraCore

print("=== Debug BARSTRING ===")

// Test current implementation
let result = try! BuiltInFunctions.execute(name: "BARSTRING", arguments: [.integer(5), .integer(10), .integer(5)])
print("BARSTRING(5, 10, 5) = \(result)")

if case .string(let str) = result {
    print("String: '\(str)'")
    print("Expected: '[*****]'")
}

// Let's trace through the logic
print("\nLogic trace:")
let val: Int64 = 5
let max: Int64 = 10
let len: Int64 = 5

let ratio = max > 0 ? Double(val) / Double(max) : 0
print("ratio = \(val)/\(max) = \(ratio)")

let filled = Int(ratio * Double(len))
print("filled = Int(\(ratio) * \(len)) = \(filled)")

let bar = String(repeating: "*", count: filled) + String(repeating: ".", count: Int(len) - filled)
print("bar = '\(bar)'")
print("result = '[\(bar)]'")
