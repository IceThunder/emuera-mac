import Foundation
import EmueraCore

/// Debug test for variable token system
public class DebugTest {
    public static func run() {
        print("=== Debug Variable Token System ===\n")

        // Create VariableData
        print("1. Creating VariableData...")
        let varData = VariableData()
        print("   dataIntegerArray.count = \(varData.dataIntegerArray.count)")
        print("   dataIntegerArray[30].count = \(varData.dataIntegerArray[30].count)")
        print()

        // Get TokenData
        print("2. Getting TokenData...")
        let tokenData = varData.getTokenData()
        print()

        // Check token for A
        print("3. Checking token for 'A'...")
        if let token = tokenData.getToken("A") {
            print("   Token found!")
            print("   - code: \(token.code)")
            print("   - baseValue: \(token.code.baseValue)")
            print("   - isForbid: \(token.isForbid)")
            print("   - dimension: \(token.dimension)")
            print("   - isInteger: \(token.code.isInteger)")
            print("   - isArray1D: \(token.code.isArray1D)")
        } else {
            print("   Token NOT found!")
        }
        print()

        // Try to set A:5 = 30
        print("4. Setting A:5 = 30...")
        do {
            try tokenData.setIntValue("A", value: 30, arguments: [5])
            print("   Set successful!")
        } catch {
            print("   Set failed: \(error)")
        }
        print()

        // Try to read A:5
        print("5. Reading A:5...")
        do {
            let value = try tokenData.getIntValue("A", arguments: [5])
            print("   A:5 = \(value)")
        } catch {
            print("   Read failed: \(error)")
        }
        print()

        // Check dataIntegerArray directly
        print("6. Checking dataIntegerArray[30][5] directly...")
        print("   dataIntegerArray[30][5] = \(varData.dataIntegerArray[30][5])")
        print()

        // Try to set A[0] = 10 (without arguments)
        print("7. Setting A = 10 (no arguments)...")
        do {
            try tokenData.setIntValue("A", value: 10)
            print("   Set successful!")
        } catch {
            print("   Set failed: \(error)")
        }
        print()

        // Read A[0]
        print("8. Reading A (no arguments)...")
        do {
            let value = try tokenData.getIntValue("A")
            print("   A = \(value)")
        } catch {
            print("   Read failed: \(error)")
        }
        print()

        // Read A[0] explicitly
        print("9. Reading A:0 explicitly...")
        do {
            let value = try tokenData.getIntValue("A", arguments: [0])
            print("   A:0 = \(value)")
        } catch {
            print("   Read failed: \(error)")
        }
        print()

        print("=== Debug Complete ===")
    }
}
