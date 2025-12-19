import Foundation
import EmueraCore

let parser = CSVParser()

// Test 1: Simple CSV
print("Test 1: Simple CSV")
let content1 = "Name,Age\nAlice,25"
do {
    let data = try parser.parseCSV(content: content1)
    print("  Rows: \(data.rowCount)")
    for (i, row) in data.rows.enumerated() {
        print("  Row \(i): \(row.fields)")
    }
} catch {
    print("  Error: \(error)")
}

// Test 2: Quoted fields
print("\nTest 2: Quoted fields")
let content2 = "Name,Description\n\"Smith, John\",\"A person with a comma\""
do {
    let data = try parser.parseCSV(content: content2)
    print("  Rows: \(data.rowCount)")
    for (i, row) in data.rows.enumerated() {
        print("  Row \(i): \(row.fields)")
    }
} catch {
    print("  Error: \(error)")
}
