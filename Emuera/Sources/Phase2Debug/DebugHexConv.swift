import Foundation

print("=== Hex Conversion Test ===")

let hexStr = "123456"
if let value = Int64(hexStr, radix: 16) {
    print("0x\(hexStr) = \(value)")
    print("Expected: 1,193,174")

    // Check bytes
    print("\nByte extraction:")
    print("Byte 0: \(value & 0xFF) (expected: 86)")
    print("Byte 1: \((value >> 8) & 0xFF) (expected: 52)")
    print("Byte 2: \((value >> 16) & 0xFF) (expected: 52)")
} else {
    print("Failed to parse")
}
