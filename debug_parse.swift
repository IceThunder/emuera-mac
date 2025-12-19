import Foundation

// Quick debug to see what tokens are generated
let source = """
A = 10
GOTO SKIP
A = 20
SKIP:
PRINT A
"""

// Simulate the tokenization
print("Source:")
print(source)
print("\n---\n")

// We need to check what tokens are generated
// Let me trace through manually

// Expected tokens for "SKIP:":
// .variable("SKIP"), .colon

// The issue might be in how parseStatement() routes to parseAssignmentOrExpression()
