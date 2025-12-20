import Foundation
import EmueraCore

@main
struct ForLoopTest {
    static func main() {
        print("=== Testing FOR loop ===\n")

        let script = """
        FOR I, 1, 3
            PRINT I
            PRINTL equals
        ENDFOR
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
                print("  \(i): \(stmt)")
            }
            print()

            let executor = StatementExecutor()
            print("Executing...")
            let output = executor.execute(statements)

            print("\n" + String(repeating: "=", count: 50))
            print("OUTPUT:")
            print(String(repeating: "=", count: 50))
            for line in output {
                print(line, terminator: "")
            }
            print("\n" + String(repeating: "=", count: 50))
            print("\n✅ Test completed!")

        } catch {
            print("❌ ERROR: \(error)")
            exit(1)
        }
    }
}