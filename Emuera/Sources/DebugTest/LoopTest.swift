import Foundation
import EmueraCore

@main
struct LoopTest {
    static func main() {
        print("=== Testing Loop parsing ===\n")

        let script = """
        PRINTL Loop test:
        FOR I, 1, 5
            PRINT I
            PRINTL equals
        ENDFOR
        PRINTL
        PRINTL Test complete!
        QUIT
        """

        print("Script:")
        print(script)
        print("\n" + String(repeating: "=", count: 50) + "\n")

        do {
            let parser = ScriptParser()
            print("Parsing...")
            let statements = try parser.parse(script)
            print("Parsed \(statements.count) statements")
            for (i, stmt) in statements.enumerated() {
                print("  [\(i)] \(stmt)")
            }
            print("\n✅ Test completed successfully!")

        } catch {
            print("❌ ERROR: \(error)")
            exit(1)
        }
    }
}