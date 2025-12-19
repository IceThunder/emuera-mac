#!/usr/bin/swift

import Foundation

// Add EmueraCore to path
let emueraPath = "/Users/ss/Documents/Project/iOS/emuera-mac/Emuera"
let packagePath = "\(emueraPath)/Package.swift"

// Check if we can compile and run a simple test
print("=== Expression Parser Verification ===\n")

// Test 1: Simple arithmetic
print("Test 1: 10 + 20 * 3")
print("Expected: 70 (20*3=60, 10+60=70)")

// Test 2: Variable reference
print("\nTest 2: A = 10, then A * 2")
print("Expected: 20")

// Test 3: Array access
print("\nTest 3: A:5")
print("Expected: 30 (from test setup)")

// Test 4: Function call
print("\nTest 4: RAND(100)")
print("Expected: 0-99 random number")

// Test 5: Complex expression
print("\nTest 5: (10 + 20) * 3")
print("Expected: 90")

print("\n=== To run full tests ===")
print("cd \(emueraPath)")
print("swift build")
print("echo 'exprtest' | swift run emuera")
