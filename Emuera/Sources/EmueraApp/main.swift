//
//  main.swift
//  EmueraApp
//
//  命令行控制台应用 - 支持脚本文件加载和执行
//  Created: 2025-12-18
//

import Foundation
import EmueraCore

// MARK: - Console Application

struct ConsoleApp {
    private var engine = ScriptEngine()

    /// 主循环 - 交互式控制台
    mutating func run() {
        printHeader()

        while true {
            printPrompt()
            guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else {
                continue
            }

            if input.isEmpty { continue }

            // 打印用户的输入（在脚本模式下模拟终端回显）
            // 在真实终端中，这由终端完成，但为了跨模式一致，我们主动打印
            if !input.isEmpty {
                print(input)  // 打印输入内容并换行
            }

            // 处理命令
            if self.handleCommand(input) {
                break
            }
        }
    }

    /// 处理内置命令
    /// - Returns: 是否退出程序
    private mutating func handleCommand(_ input: String) -> Bool {
        let parts = input.split(separator: " ", maxSplits: 1).map(String.init)
        let command = parts[0].uppercased()

        switch command {
        case "HELP", "?":
            showHelp()
            return false

        case "EXIT", "QUIT", "Q":
            print("👋 再见！")
            return true

        case "RUN":
            if parts.count > 1 {
                let path = String(parts[1])
                runScriptFile(path)
            } else {
                print("❌ 请指定脚本文件路径")
                print("用法: run <path-to-script>")
            }
            return false

        case "TEST":
            runTestScript()
            return false

        case "PERSISTTEST":
            runPersistenceTest()
            return false

        case "EXPRTEST":
            ExpressionTest.runTests()
            return false

        case "DEBUG":
            DebugTest.run()
            return false

        case "WHILETEST":
            runWhileTest()
            return false

        case "GOTOTEST":
            runGotoTest()
            return false

        case "SCRIPTTEST":
            runScriptParserTest()
            return false

        case "ADVANCEDTEST":
            runAdvancedSyntaxTest()
            return false

        case "DEMO":
            runDemo()
            return false

        case "PROCESSTEST":
            runProcessTest()
            return false

        case "TOKENS":
            if parts.count > 1 {
                let script = String(parts[1])
                showTokens(script)
            } else {
                print("❌ 用法: tokens <script-string>")
            }
            return false

        case "RESET":
            engine.reset()
            print("✅ 已重置所有变量状态")
            return false

        case "PERSIST":
            if parts.count > 1 {
                let mode = parts[1].uppercased()
                engine.persistentState = (mode == "ON" || mode == "TRUE")
                print("✅ 持久状态: \(engine.persistentState ? "开启" : "关闭")")
            } else {
                print("当前持久状态: \(engine.persistentState ? "开启" : "关闭")")
                print("用法: persist on|off")
            }
            return false

        default:
            // 尝试作为脚本执行
            if input.contains("=") || input.contains("PRINT") || input.contains("+") {
                executeInline(input)
            } else {
                // 检查是否是合法的变量名（纯字母或$/%开头的标识符）
                let trimmed = input.trimmingCharacters(in: .whitespaces)
                if trimmed.range(of: "^[A-Za-z_$%][A-Za-z0-9_$%]*$", options: .regularExpression) != nil {
                    executeInline("PRINT " + trimmed)
                } else {
                    print("❌ 未知命令: \(input)")
                    print("输入 'help' 查看帮助")
                }
            }
            return false
        }
    }

    /// 运行脚本文件
    private func runScriptFile(_ path: String) {
        let url = URL(fileURLWithPath: path)

        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("❌ 无法读取文件: \(path)")
            return
        }

        print("📄 正在执行: \(path)")
        print("---")

        let outputs = engine.run(content)

        for output in outputs {
            print(output, terminator: "")
        }

        print("\n---")
        print("✅ 执行完成")
    }

    /// 执行内联脚本 - 防止空行输出的关键修复
    private mutating func executeInline(_ script: String) {
        let outputs = engine.run(script)

        // 核心修复：只有在有实际输出时才进行打印操作
        // 避免因空的outputs数组导致的换行或空白
        guard !outputs.isEmpty else {
            return  // 无输出时，不打印任何内容，避免产生空行
        }

        // 打印所有输出结果
        for output in outputs {
            print(output)
        }
    }

    /// 运行测试脚本
    func runTestScript() {
        let testScript = """
        PRINTL 测试开始...
        PRINTL A的值设置为100
        A = 100
        PRINT A
        PRINTL
        PRINTL B设置为200
        B = 200
        PRINT B
        PRINTL
        PRINTL 测试完成！
        QUIT
        """

        print("🧪 运行MVP测试用例")
        print("---")
        print(testScript)
        print("---")

        let outputs = engine.run(testScript)
        print("输出结果:")
        for output in outputs {
            print(output, terminator: "")
        }
        print()
    }

    /// 运行持久化专项测试
    private func runPersistenceTest() {
        print("🧪 持久化变量功能专项测试")
        print("=" * 50)
        print()

        var pass = 0
        var fail = 0

        func assertEqual(actual: [String], expected: [String], _ name: String) {
            if actual == expected {
                print("✅ \(name)")
                pass += 1
            } else {
                print("❌ \(name)")
                print("   期望: \(expected)")
                print("   实际: \(actual)")
                fail += 1
            }
        }

        // 准备新引擎
        engine.reset()
        engine.persistentState = true

        print("测试1: A = 100")
        let o1 = engine.run("A = 100")
        assertEqual(actual: o1, expected: [], "赋值A=100无输出")

        print("测试2: PRINT A")
        let o2 = engine.run("PRINT A")
        assertEqual(actual: o2, expected: ["100"], "输出A=100")

        print("测试3: B = A + 50")
        let o3 = engine.run("B = A + 50")
        assertEqual(actual: o3, expected: [], "赋值B=A+50无输出")

        print("测试4: PRINT B")
        let o4 = engine.run("PRINT B")
        assertEqual(actual: o4, expected: ["150"], "输出B=150")

        print("测试5: A + B")
        let o5 = engine.run("A + B")
        assertEqual(actual: o5, expected: ["250"], "表达式A+B=250")

        print("测试6: RESET")
        engine.reset()
        let o6 = engine.run("PRINT A")
        assertEqual(actual: o6, expected: ["0"], "重置后A=0")

        print("测试7: 多变量持久")
        let _ = engine.run("X = 30")
        let o7a = engine.run("PRINT X")
        assertEqual(actual: o7a, expected: ["30"], "X=30")

        let _ = engine.run("Y = X * 2")
        let o7b = engine.run("PRINT Y")
        assertEqual(actual: o7b, expected: ["60"], "Y=X*2=60")

        print("\n" + "=" * 50)
        print("测试总结：通过 \(pass)，失败 \(fail)")
        if fail == 0 {
            print("🎉 所有测试通过！")
        } else {
            print("⚠️  部分测试失败")
        }
        print("=" * 50)
    }

    /// 运行演示脚本
    private func runDemo() {
        let demoScript = """
        PRINTL 欢迎来到Emuera macOS!
        PRINTL 这是第一个可运行的MVP版本
        PRINTL
        PRINTL 输入测试命令: demo
        PRINTL 或者运行帮助: help
        PRINTL
        PRINTL 现在演示变量赋值:
        COUNT = 10
        PRINT 当前数值:
        PRINTL COUNT
        WAIT
        QUIT
        """

        print("🎨 运行演示脚本")
        let outputs = engine.run(demoScript)
        for output in outputs {
            print(output, terminator: "")
        }
        print()
    }

    /// 显示Token列表
    private func showTokens(_ script: String) {
        let tokens = engine.getTokens(script)
        print("🔍 Token分析结果:")
        for (idx, _) in tokens.enumerated() {
            print("  \\(idx): \\(tokens[idx].description)")
        }
    }

    /// 显示帮助
    private func showHelp() {
        print("""

        🚀 Emuera macOS - MVP版本

        可用命令:
        ──────────────────────────────
        run <path>      - 运行脚本文件
        test            - 运行MVP测试脚本
        exprtest        - 运行表达式解析器测试
        advancedtest    - 运行高级语法测试 (WHILE/CALL/GOTO等)
        processtest     - 运行Process系统测试 (函数调用栈)
        demo            - 运行演示脚本
        tokens <script> - 显示脚本token分析
        help            - 显示此帮助
        exit/quit       - 退出程序

        支持的脚本语法:
        ──────────────────────────────
        PRINT 文本      - 输出文本（不换行）
        PRINTL 文本     - 输出文本并换行
        WAIT            - 等待用户输入
        QUIT            - 退出程序

        变量语法:
        变量名 = 值      - 赋值
        变量名           - 读取值

        示例:
        ──────────────────────────────
        PRINTL Hello World!
        A = 100
        PRINT A的值是
        PRINT A
        QUIT

        """)
    }

    /// 显示提示符
    private func printPrompt() {
        print("emuera> ", terminator: "")
    }

    /// 显示应用头部
    private func printHeader() {
        print("┌────────────────────────────────────────┐")
        print("│  Emuera for macOS - MVP Version        │")
        print("│  (c) 2025, based on Emuera Original    │")
        print("└────────────────────────────────────────┘")
        print()
        print("输入 'help' 查看命令帮助")
        print("输入 'test' 运行内置测试")
        print("输入 'exprtest' 运行表达式解析器测试")
        print("输入 'persisttest' 运行持久化专项测试")
        print("输入 'scripttest' 运行语法解析器测试")
        print()
    }

    /// 运行高级语法测试 (WHILE/CALL/GOTO等)
    private func runAdvancedSyntaxTest() {
        print("🧪 高级语法测试 - WHILE/CALL/GOTO/FOR/SELECTCASE")
        print(String(repeating: "=", count: 60))
        print()

        var pass = 0
        var fail = 0

        func test(_ name: String, _ script: String, _ expectedOutput: [String]) {
            print("测试: \(name)")
            do {
                let parser = ScriptParser()
                let statements = try parser.parse(script)
                let executor = StatementExecutor()
                let output = executor.execute(statements)

                if output == expectedOutput {
                    print("✅ 通过")
                    pass += 1
                } else {
                    print("❌ 失败")
                    print("  期望: \(expectedOutput)")
                    print("  实际: \(output)")
                    fail += 1
                }
            } catch {
                print("❌ 错误: \(error)")
                fail += 1
            }
            print()
        }

        // 测试1: WHILE循环
        test("WHILE循环", """
        COUNT = 0
        WHILE COUNT < 3
          PRINT COUNT
          COUNT = COUNT + 1
        ENDWHILE
        """, ["0", "1", "2"])

        // 测试2: FOR循环
        test("FOR循环", """
        FOR I, 1, 5
          PRINT I
        ENDFOR
        """, ["1", "2", "3", "4", "5"])

        // 测试3: GOTO跳转
        test("GOTO跳转", """
        A = 10
        GOTO SKIP
        A = 20
        SKIP:
        PRINT A
        """, ["10"])

        // 测试4: CALL子程序
        test("CALL子程序", """
        A = 100
        CALL SUB
        PRINT A

        SUB:
          A = A + 50
          RETURN
        """, ["100", "150"])

        // 测试5: RETURN带值
        test("RETURN带值", """
        CALL CALC
        PRINT RESULT

        CALC:
          RESULT = 100 + 200
          RETURN RESULT
        """, ["300"])

        // 测试6: SELECTCASE
        test("SELECTCASE", """
        A = 2
        SELECTCASE A
          CASE 1
            PRINTL 一
          CASE 2
            PRINTL 二
          CASE 3
            PRINTL 三
          CASEELSE
            PRINTL 其他
        ENDSELECT
        """, ["二\n"])

        // 测试7: BREAK
        test("BREAK", """
        FOR I, 1, 10
          IF I == 5
            BREAK
          ENDIF
          PRINT I
        ENDFOR
        """, ["1", "2", "3", "4"])

        // 测试8: CONTINUE
        test("CONTINUE", """
        FOR I, 1, 5
          IF I == 3
            CONTINUE
          ENDIF
          PRINT I
        ENDFOR
        """, ["1", "2", "4", "5"])

        // 测试9: 复杂嵌套
        test("复杂嵌套", """
        A = 0
        WHILE A < 2
          A = A + 1
          FOR I, 1, 2
            PRINT A
            PRINT I
          ENDFOR
        ENDWHILE
        """, ["1", "1", "1", "2", "2", "1", "2", "2"])

        // 测试10: 标签和GOTO
        test("标签和GOTO", """
        GOTO START
        PRINTL 跳过
        START:
        PRINTL 开始
        GOTO END
        PRINTL 也跳过
        END:
        PRINTL 结束
        """, ["开始\n", "结束\n"])

        print(String(repeating: "=", count: 60))
        print("测试总结: 通过 (pass)/(pass + fail)")
        if fail == 0 {
            print("🎉 所有高级语法测试通过！")
        } else {
            print("⚠️  (fail) 个测试失败")
        }
        print(String(repeating: "=", count: 60))
    }

    /// 运行ScriptParser测试
    func runScriptParserTest() {
        print("🧪 ScriptParser + StatementExecutor 完整测试")
        print(String(repeating: "=", count: 60))
        print()

        var pass = 0
        var fail = 0

        func test(_ name: String, _ script: String, _ expectedOutput: [String]) {
            print("测试: \(name)")
            print("脚本: \(script)")
            do {
                let parser = ScriptParser()
                let statements = try parser.parse(script)
                let executor = StatementExecutor()
                let output = executor.execute(statements)

                if output == expectedOutput {
                    print("✅ 通过")
                    pass += 1
                } else {
                    print("❌ 失败")
                    print("  期望: \(expectedOutput)")
                    print("  实际: \(output)")
                    fail += 1
                }
            } catch {
                print("❌ 错误: \(error)")
                fail += 1
            }
            print()
        }

        // 测试1: 基础赋值和输出
        test("基础赋值和输出", "A = 100\nPRINT A", ["100"])

        // 测试2: 表达式计算
        test("表达式计算", "A = 10\nB = A + 50 * 2\nPRINT B", ["110"])

        // 测试3: IF语句 - 条件为真
        test("IF语句 - 条件为真", "A = 10\nIF A > 5\n  PRINTL A大于5\nENDIF", ["A大于5\n"])

        // 测试4: IF语句 - 条件为假
        test("IF语句 - 条件为假", "A = 3\nIF A > 5\n  PRINTL A大于5\nENDIF", [])

        // 测试5: IF-ELSE语句
        test("IF-ELSE语句", "A = 3\nIF A > 5\n  PRINTL A大于5\nELSE\n  PRINTL A小于等于5\nENDIF", ["A小于等于5\n"])

        // 测试6: WHILE循环
        test("WHILE循环", "COUNT = 0\nWHILE COUNT < 3\n  PRINT COUNT\n  COUNT = COUNT + 1\nENDWHILE", ["0", "1", "2"])

        // 测试7: FOR循环
        test("FOR循环", "FOR I, 1, 3\n  PRINT I\nENDFOR", ["1", "2", "3"])

        // 测试8: BREAK语句
        test("BREAK语句", "COUNT = 0\nWHILE COUNT < 10\n  IF COUNT == 3\n    BREAK\n  ENDIF\n  PRINT COUNT\n  COUNT = COUNT + 1\nENDWHILE", ["0", "1", "2"])

        // 测试9: GOTO语句
        test("GOTO语句", "GOTO SKIP\nPRINTL 不应该执行\n@SKIP\nPRINTL 跳转成功", ["跳转成功\n"])

        // 测试10: CALL语句
        test("CALL语句", "CALL SUB\nQUIT\n@SUB\nPRINTL 子程序被调用\nRETURN", ["子程序被调用\n"])

        // 测试11: SELECTCASE语句
        test("SELECTCASE语句", "A = 2\nSELECTCASE A\n  CASE 1\n    PRINTL 一\n  CASE 2\n    PRINTL 二\n  CASE 3\n    PRINTL 三\n  CASEELSE\n    PRINTL 其他\nENDSELECT", ["二\n"])

        // 测试12: SELECTCASE CASEELSE
        test("SELECTCASE CASEELSE", "A = 5\nSELECTCASE A\n  CASE 1\n    PRINTL 一\n  CASE 2\n    PRINTL 二\n  CASEELSE\n    PRINTL 其他\nENDSELECT", ["其他\n"])

        // 测试13: 复杂表达式
        test("复杂表达式", "A = 10\nB = 20\nC = (A + B) * 2 - 5\nPRINT C", ["45"])

        // 测试14: RESET命令
        test("RESET命令", "A = 100\nRESET\nPRINT A", ["0"])

        // 测试15: 多行PRINT
        test("多行PRINT", "PRINTL 第一行\nPRINTL 第二行\nPRINTL 第三行", ["第一行\n", "第二行\n", "第三行\n"])

        // 测试16: 比较运算符
        test("比较运算符", "A = 10\nIF A == 10\n  PRINTL 相等\nENDIF\nIF A != 5\n  PRINTL 不等\nENDIF", ["相等\n", "不等\n"])

        // 测试17: 逻辑运算符
        test("逻辑运算符", "A = 10\nIF A > 5 && A < 20\n  PRINTL 范围内\nENDIF", ["范围内\n"])

        // 测试18: 嵌套IF
        test("嵌套IF", "A = 10\nIF A > 5\n  IF A < 15\n    PRINTL 5到15之间\n  ENDIF\nENDIF", ["5到15之间\n"])

        print(String(repeating: "=", count: 60))
        print("测试总结: 通过 \(pass)/\(pass + fail)")
        if fail == 0 {
            print("🎉 所有测试通过！")
        } else {
            print("⚠️  \(fail) 个测试失败")
        }
        print(String(repeating: "=", count: 60))
    }

    /// 简单WHILE测试
    private func runWhileTest() {
        print("🧪 WHILE循环简单测试")
        let script = """
        COUNT = 0
        WHILE COUNT < 3
          PRINT COUNT
          COUNT = COUNT + 1
        ENDWHILE
        """

        print("脚本:")
        print(script)
        print("\n---\n")

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            print("解析到 \(statements.count) 条语句")

            let executor = StatementExecutor()
            let output = executor.execute(statements)

            print("输出: \(output)")
            print("期望: [\"0\", \"1\", \"2\"]")
            print("结果: \(output == ["0", "1", "2"] ? "✅ 通过" : "❌ 失败")")
        } catch {
            print("错误: \(error)")
        }
    }

    /// GOTO测试
    private func runGotoTest() {
        print("🧪 GOTO跳转测试")
        let script = """
        A = 10
        GOTO SKIP
        A = 20
        SKIP:
        PRINT A
        """

        print("脚本:")
        print(script)
        print("\n---\n")

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            print("解析到 \(statements.count) 条语句:")
            for (i, stmt) in statements.enumerated() {
                print("  \(i): \(type(of: stmt))")
                if let label = stmt as? LabelStatement {
                    print("      -> 标签: \(label.name)")
                }
                if let goto = stmt as? GotoStatement {
                    print("      -> GOTO: \(goto.label)")
                }
            }

            let executor = StatementExecutor()
            let output = executor.execute(statements)

            print("\n输出: \(output)")
            print("期望: [\"10\"]")
            print("结果: \(output == ["10"] ? "✅ 通过" : "❌ 失败")")
        } catch {
            print("错误: \(error)")
        }
    }

    /// Process系统测试
    func runProcessTest() {
        print("🧪 Process系统测试 - 函数调用栈")
        print(String(repeating: "=", count: 60))
        print()

        // 使用ProcessTest进行测试
        let results = processQuickTest()
        print(results)

        print(String(repeating: "=", count: 60))
        print()

        // 额外运行集成测试
        print("🧪 Process系统集成测试（StatementExecutor）")
        print(String(repeating: "=", count: 60))
        print()

        let tester = ProcessTest()
        let integrationResults = tester.runIntegrationTest()
        for line in integrationResults {
            print(line)
        }

        print(String(repeating: "=", count: 60))
    }
}

// MARK: - String 扩展
extension String {
    static func *(left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// MARK: - Entry Point

// Check for command-line arguments
let args = CommandLine.arguments

if args.count > 1 {
    // Run specific commands without interactive mode
    let command = args[1].lowercased()

    switch command {
    case "processtest":
        // Run Process tests and exit
        let app = ConsoleApp()
        app.runProcessTest()
        exit(0)

    case "test":
        // Run basic test and exit
        let app = ConsoleApp()
        app.runTestScript()
        exit(0)

    case "exprtest":
        // Run expression tests and exit
        ExpressionTest.runTests()
        exit(0)

    case "scripttest":
        // Run script parser tests and exit
        let app = ConsoleApp()
        app.runScriptParserTest()
        exit(0)

    default:
        print("未知命令: \(command)")
        print("可用命令: processtest, test, exprtest, scripttest")
        exit(1)
    }
}

// Interactive mode (default)
var app = ConsoleApp()
app.run()
