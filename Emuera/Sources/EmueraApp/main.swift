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
    private let engine = ScriptEngine()

    /// 主循环 - 交互式控制台
    func run() {
        printHeader()

        while true {
            printPrompt()
            guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else {
                continue
            }

            if input.isEmpty { continue }

            // 处理命令
            if handleCommand(input) {
                break
            }
        }
    }

    /// 处理内置命令
    /// - Returns: 是否退出程序
    private func handleCommand(_ input: String) -> Bool {
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

        case "DEMO":
            runDemo()
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

    /// 执行内联脚本
    private func executeInline(_ script: String) {
        let outputs = engine.run(script)

        for output in outputs {
            print(output, terminator: "")
        }
        print()
    }

    /// 运行测试脚本
    private func runTestScript() {
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
        for (idx, token) in tokens.enumerated() {
            print("  \(idx): \(token.description)")
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
        print()
    }
}

// MARK: - Entry Point

ConsoleApp().run()
