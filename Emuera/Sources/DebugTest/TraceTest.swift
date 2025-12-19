import Foundation
import EmueraCore

/// 追踪解析过程
@main
struct TraceTest {
    static func main() {
        print("🔍 追踪 ScriptParser 解析过程")
        print(String(repeating: "=", count: 60))

        // 手动追踪 A = 10\nB = A + 50 * 2
        let source = "A = 10\nB = A + 50 * 2"
        print("源代码: \(source.replacingOccurrences(of: "\n", with: "\\n"))")

        // 使用ScriptParser的内部方法来追踪
        let parser = ScriptParser()

        // 先获取tokens - 使用ScriptEngine来获取
        let engine = ScriptEngine()
        let tokens = engine.getTokens(source)
        print("\nTokens:")
        for (i, token) in tokens.enumerated() {
            print("  [\(i)]: \(token.description)")
        }

        // 现在解析
        print("\n开始解析...")
        do {
            let statements = try parser.parse(source)
            print("成功！得到 \(statements.count) 个语句")
            for (i, stmt) in statements.enumerated() {
                print("  [\(i)]: \(type(of: stmt))")
            }
        } catch {
            print("失败: \(error)")

            // 手动模拟解析过程来找出问题
            print("\n手动模拟解析过程:")
            manualParse(tokens)
        }

        print("\n" + String(repeating: "=", count: 60))
    }

    static func manualParse(_ tokens: [TokenType.Token]) {
        // 手动模拟ScriptParser的parse方法
        var currentIndex = 0
        var currentLine = 1

        print("\n模拟 parse() 循环:")

        while currentIndex < tokens.count {
            // skipWhitespaceAndNewlines
            print("  当前索引: \(currentIndex), token: \(tokens[currentIndex].description)")

            while currentIndex < tokens.count {
                let token = tokens[currentIndex]
                switch token.type {
                case .whitespace:
                    currentIndex += 1
                case .lineBreak:
                    currentLine += 1
                    currentIndex += 1
                case .comment:
                    currentIndex += 1
                default:
                    break
                }
                if currentIndex >= tokens.count {
                    break
                }
                let nextType = tokens[currentIndex].type
                if case .whitespace = nextType,
                   case .lineBreak = nextType,
                   case .comment = nextType {
                    continue
                } else {
                    break
                }
            }

            if currentIndex >= tokens.count {
                print("  索引超出范围，结束")
                break
            }

            print("  跳过空白后，索引: \(currentIndex), token: \(tokens[currentIndex].description)")

            // parseStatement
            let token = tokens[currentIndex]
            print("  解析语句，token类型: \(type(of: token.type))")

            if case .variable = token.type {
                print("  这是变量，调用 parseAssignmentOrExpression")

                // parseAssignmentOrExpression
                print("    检查赋值: currentIndex=\(currentIndex), 检查范围: \(currentIndex) + 2 < \(tokens.count)")

                if currentIndex + 2 < tokens.count,
                   case .variable(let varName) = tokens[currentIndex].type,
                   case .operatorSymbol(let op) = tokens[currentIndex + 1].type,
                   op == .assign {

                    print("    匹配赋值: \(varName) = ...")
                    currentIndex += 2
                    print("    跳过变量和=，现在 currentIndex = \(currentIndex)")

                    // parseExpression - 收集表达式tokens
                    print("    收集表达式tokens，从索引 \(currentIndex) 开始")
                    var exprTokens: [TokenType.Token] = []
                    var parenDepth = 0

                    while currentIndex < tokens.count {
                        let t = tokens[currentIndex]
                        print("      检查 token: \(t.description)")

                        switch t.type {
                        case .lineBreak, .whitespace:
                            currentIndex += 1
                            continue
                        case .comment:
                            currentIndex += 1
                            continue
                        case .parenthesisOpen:
                            parenDepth += 1
                            exprTokens.append(t)
                            currentIndex += 1
                        case .parenthesisClose:
                            parenDepth -= 1
                            exprTokens.append(t)
                            currentIndex += 1
                        case .comma:
                            if parenDepth == 0 {
                                break
                            }
                            exprTokens.append(t)
                            currentIndex += 1
                        case .operatorSymbol, .comparator:
                            exprTokens.append(t)
                            currentIndex += 1
                        case .integer, .string, .variable:
                            exprTokens.append(t)
                            currentIndex += 1
                        case .colon:
                            exprTokens.append(t)
                            currentIndex += 1
                        case .function:
                            exprTokens.append(t)
                            currentIndex += 1
                        default:
                            break
                        }

                        if parenDepth == 0 && currentIndex < tokens.count {
                            let nextToken = tokens[currentIndex]
                            if case .command = nextToken.type,
                               case .keyword = nextToken.type {
                                break
                            }
                        }
                    }

                    print("    收集到表达式tokens: \(exprTokens.map { $0.description })")
                    print("    收集后currentIndex: \(currentIndex)")

                    // 使用ExpressionParser解析
                    print("    使用ExpressionParser解析...")
                    let exprParser = ExpressionParser()
                    do {
                        let expr = try exprParser.parse(exprTokens)
                        print("    表达式解析成功: \(expr)")
                    } catch {
                        print("    表达式解析失败: \(error)")
                        return
                    }
                } else {
                    print("    不是赋值，作为表达式处理")
                    currentIndex += 1
                }
            } else {
                print("  不是变量，跳过")
                currentIndex += 1
            }

            print("  语句解析完成，currentIndex = \(currentIndex)")
        }
    }
}
