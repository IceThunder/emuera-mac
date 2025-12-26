//
//  DebugTokens.swift
//  Phase2Test
//
//  Debug tokenization
//

import Foundation
import EmueraCore

@main
struct DebugTokens {
    static func main() {
        print("=== Token Debug ===\n")

        let scripts = [
            "A = 0",
            "DO\n    A = A + 1\nLOOP WHILE A < 5",
            "SET A = 10",
            "TINPUT 1000, 0, \"超时\"",
            "SETCOLOR 255, 255, 255"
        ]

        for (i, script) in scripts.enumerated() {
            print("Test \(i+1): \(script.replacingOccurrences(of: "\n", with: "\\n"))")
            do {
                let tokens = try LexicalAnalyzer.analyze(script)
                for (j, token) in tokens.enumerated() {
                    print("  \(j+1). \(token)")
                }
            } catch {
                print("  Error: \(error)")
            }
            print()
        }
    }
}
