import Foundation
import EmueraCore

/// 调试词法分析器
@main
struct DebugLexical {
    static func main() {
        print("=== Debug Lexical Analyzer ===")

        let testInputs = [
            "PRINTL 一",
            "PRINTL 二",
            "一",
            "二",
            "其他",
            "PRINTL 一\nPRINTL 二"
        ]

        for input in testInputs {
            print("\n输入: \(input)")
            let engine = ScriptEngine()
            let tokens = engine.getTokens(input)
            print("Tokens:")
            for token in tokens {
                print("  \(token)")
            }
        }

        // 检查字符属性
        print("\n=== 字符属性检查 ===")
        let chars = ["一", "二", "三", "其他"]
        for char in chars {
            print("字符: \(char)")
            // 检查第一个字符
            if let first = char.unicodeScalars.first {
                print("  isASCII: \(first.isASCII)")
                print("  value: U+\(String(format: "%04X", first.value))")
            }
            // 检查String的isLetter
            print("  String.isLetter: \(char.rangeOfCharacter(from: .letters) != nil)")
            // 检查Character的isLetter
            if let firstChar = char.first {
                print("  Character.isLetter: \(firstChar.isLetter)")
            }
        }

        // 手动模拟词法分析器
        print("\n=== 手动模拟 ===")
        let testStr = "一"
        if let first = testStr.first {
            print("第一个字符: \(first)")
            print("  isLetter: \(first.isLetter)")
            print("  isNumber: \(first.isNumber)")
            print("  == '$': \(first == "$")")
            print("  == '%': \(first == "%")")
            print("  == '@': \(first == "@")")
            print("  进入identifier分支: \(first.isLetter || first == "$" || first == "%" || first == "@")")
            print("  isASCII: \(first.isASCII)")
        }
    }
}
