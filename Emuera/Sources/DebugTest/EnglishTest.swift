import Foundation
import EmueraCore

@main
struct EnglishTest {
    static func main() {
        print("=== Testing English text parsing ===\n")

        let script = """
        PRINTL Start complex test
        A = 10
        B = 20
        C = A + B
        PRINT A
        PRINTL equals
        PRINT B
        PRINTL equals
        PRINT C
        PRINTL equals A plus B equals
        PRINTL
        PRINTL Conditional test:
        IF C > 15
            PRINTL C greater than 15 is true!
        ELSE
            PRINTL C greater than 15 is false!
        ENDIF
        IF A == 10
            PRINTL A equals 10 is true!
        ENDIF
        PRINTL
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
            print("\n✅ Test completed successfully!")

        } catch {
            print("❌ ERROR: \(error)")
            exit(1)
        }
    }
}
