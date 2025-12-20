import Foundation
import EmueraCore

@main
struct DebugAllTokens {
    static func main() {
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

        let lexer = LexicalAnalyzer()
        let tokens = lexer.tokenize(script)

        print("=== All Tokens ===")
        for (i, token) in tokens.enumerated() {
            print("[\(i)] \(token)")
        }
    }
}