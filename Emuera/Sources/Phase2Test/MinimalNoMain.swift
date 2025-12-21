//
//  MinimalNoMain.swift
//  Phase2Test
//
//  Minimal test without @main
//

import Foundation

// Use stderr to avoid buffering
fputs("=== MinimalNoMain: Start ===\n", stderr)
fflush(stderr)

fputs("Creating Date object...\n", stderr)
fflush(stderr)

let date = Date()
fputs("Date created: \(date)\n", stderr)
fflush(stderr)

fputs("=== MinimalNoMain: End ===\n", stderr)
fflush(stderr)
