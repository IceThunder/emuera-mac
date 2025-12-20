import Foundation
import EmueraCore

@main
struct SimpleTest {
    static func main() {
        print("Starting...")

        let script = """
        A = 10
        PRINTL A
        """

        print("Script: \(script)")

        do {
            let parser = ScriptParser()
            print("Parsing...")
            let statements = try parser.parse(script)
            print("Parsed \(statements.count) statements")

            let executor = StatementExecutor()
            print("Executing...")
            let output = executor.execute(statements)
            print("Output: \(output)")

        } catch {
            print("ERROR: \(error)")
        }

        print("Done!")
    }
}
