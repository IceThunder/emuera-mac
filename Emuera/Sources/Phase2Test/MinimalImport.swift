//
//  MinimalImport.swift
//  Phase2Test
//
//  Minimal test to find the exact hanging point
//

import Foundation

// Write to file to avoid buffering issues
let logFile = "/tmp/phase2_debug.log"
func log(_ msg: String) {
    if let data = (msg + "\n").data(using: .utf8) {
        if let handle = try? FileHandle(forWritingAtPath: logFile) {
            handle.seekToEndOfFile()
            handle.write(data)
            handle.closeFile()
        }
    }
}

@main
struct Main {
    static func main() {
        log("1. Starting main()")

        // Test 1: Just import Foundation
        log("2. Foundation imported")

        // Test 2: Import EmueraCore (at top level)
        log("3. About to import EmueraCore")
        // Import is already done at top level
        log("4. EmueraCore imported")

        // If we get here, the import worked
        log("5. SUCCESS - Import completed")
    }
}

// Import at top level
import EmueraCore
