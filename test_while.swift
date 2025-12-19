#!/usr/bin/env swift

import Foundation
import EmueraCore

let script = """
COUNT = 0
WHILE COUNT < 3
  PRINT COUNT
  COUNT = COUNT + 1
ENDWHILE
"""

print("Script to parse:")
print(script)
print("\n---\n")

do {
    let parser = ScriptParser()
    let statements = try parser.parse(script)

    print("Parsed \(statements.count) statements:")
    for (i, stmt) in statements.enumerated() {
        print("  \(i): \(type(of: stmt))")
    }

    print("\n---\n")

    let executor = StatementExecutor()
    let output = executor.execute(statements)

    print("Output: \(output)")
    print("Expected: [\"0\", \"1\", \"2\"]")
    print("Match: \(output == ["0", "1", "2"])")

} catch {
    print("Error: \(error)")
}
