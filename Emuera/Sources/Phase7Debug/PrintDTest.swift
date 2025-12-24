//
//  PrintDTest.swift
//  EmueraCore
//
//  D系列输出命令测试 - Priority 1
//  Created: 2025-12-25
//

import Foundation
import EmueraCore

/// D系列输出命令测试
public class PrintDTest {

    public static func runAllTests() {
        print("=== D系列输出命令测试 ===")

        do {
            try testPrintD()
            try testPrintDL()
            try testPrintDW()
            try testPrintVD()
            try testPrintVL()
            try testPrintVW()
            try testPrintSD()
            try testPrintSL()
            try testPrintSW()
            try testPrintFormD()
            try testPrintFormDL()
            try testPrintFormDW()

            print("✅ 所有D系列命令测试通过！")
        } catch {
            print("❌ 测试失败: \(error)")
        }
    }

    /// 测试PRINTD - 输出不换行 (不解析{}和%)
    private static func testPrintD() throws {
        print("测试 PRINTD...")

        let script = """
        A = 100
        PRINTD "数值: "
        PRINTD A
        PRINTD " 完成"
        """

        let result = try runScript(script)

        // 检查是否包含关键内容（忽略欢迎信息和换行）
        let has数值 = result.contains("数值: ")
        let has100 = result.contains("100")
        let has完成 = result.contains("完成")

        print("  检查结果:")
        print("    - 包含'数值: ': \(has数值)")
        print("    - 包含'100': \(has100)")
        print("    - 包含'完成': \(has完成)")

        if has数值 && has100 && has完成 {
            print("  ✅ PRINTD 测试通过")
        } else {
            print("  ❌ PRINTD 测试失败")
            print("  完整输出: '\(result)'")
            fatalError("PRINTD输出不正确")
        }
    }

    /// 测试PRINTDL - 输出并换行 (不解析{}和%)
    private static func testPrintDL() throws {
        print("测试 PRINTDL...")

        let script = """
        B = "测试"
        PRINTDL B
        PRINTDL "结束"
        """

        let result = try runScript(script)
        let has测试 = result.contains("测试")
        let has结束 = result.contains("结束")

        if has测试 && has结束 {
            print("  ✅ PRINTDL 测试通过")
        } else {
            fatalError("PRINTDL测试失败: '\(result)'")
        }
    }

    /// 测试PRINTDW - 输出并等待输入 (不解析{}和%)
    private static func testPrintDW() throws {
        print("测试 PRINTDW...")

        let script = """
        C = 999
        PRINTDW C
        """

        let result = try runScript(script)
        if result.contains("999") {
            print("  ✅ PRINTDW 测试通过")
        } else {
            fatalError("PRINTDW测试失败: '\(result)'")
        }
    }

    /// 测试PRINTVD - 输出变量内容 (不解析{}和%)
    private static func testPrintVD() throws {
        print("测试 PRINTVD...")

        let script = """
        A:5 = 42
        PRINTVD A:5
        """

        let result = try runScript(script)
        if result.contains("42") {
            print("  ✅ PRINTVD 测试通过")
        } else {
            fatalError("PRINTVD测试失败: '\(result)'")
        }
    }

    /// 测试PRINTVL - 变量内容换行 (不解析{}和%)
    private static func testPrintVL() throws {
        print("测试 PRINTVL...")

        let script = """
        FLAG:10 = 123
        PRINTVL FLAG:10
        """

        let result = try runScript(script)
        if result.contains("123") {
            print("  ✅ PRINTVL 测试通过")
        } else {
            fatalError("PRINTVL测试失败: '\(result)'")
        }
    }

    /// 测试PRINTVW - 变量内容等待 (不解析{}和%)
    private static func testPrintVW() throws {
        print("测试 PRINTVW...")

        let script = """
        D = 777
        PRINTVW D
        """

        let result = try runScript(script)
        if result.contains("777") {
            print("  ✅ PRINTVW 测试通过")
        } else {
            fatalError("PRINTVW测试失败: '\(result)'")
        }
    }

    /// 测试PRINTSD - 输出字符串变量 (不解析{}和%)
    private static func testPrintSD() throws {
        print("测试 PRINTSD...")

        let script = """
        STRS = "Hello"
        PRINTSD STRS
        """

        let result = try runScript(script)
        if result.contains("Hello") {
            print("  ✅ PRINTSD 测试通过")
        } else {
            fatalError("PRINTSD测试失败: '\(result)'")
        }
    }

    /// 测试PRINTSL - 字符串变量换行 (不解析{}和%)
    private static func testPrintSL() throws {
        print("测试 PRINTSL...")

        let script = """
        STRS:0 = "World"
        PRINTSL STRS:0
        """

        let result = try runScript(script)
        if result.contains("World") {
            print("  ✅ PRINTSL 测试通过")
        } else {
            fatalError("PRINTSL测试失败: '\(result)'")
        }
    }

    /// 测试PRINTSW - 字符串变量等待 (不解析{}和%)
    private static func testPrintSW() throws {
        print("测试 PRINTSW...")

        let script = """
        E = "Wait"
        PRINTSW E
        """

        let result = try runScript(script)
        if result.contains("Wait") {
            print("  ✅ PRINTSW 测试通过")
        } else {
            fatalError("PRINTSW测试失败: '\(result)'")
        }
    }

    /// 测试PRINTFORMD - 格式化输出 (不解析{}和%)
    private static func testPrintFormD() throws {
        print("测试 PRINTFORMD...")

        let script = """
        VAR1 = 100
        VAR2 = 200
        PRINTFORMD "数值: %d + %d", VAR1, VAR2
        """

        let result = try runScript(script)
        if result.contains("数值: 100 + 200") {
            print("  ✅ PRINTFORMD 测试通过")
        } else {
            fatalError("PRINTFORMD测试失败: '\(result)'")
        }
    }

    /// 测试PRINTFORMDL - 格式化输出换行 (不解析{}和%)
    private static func testPrintFormDL() throws {
        print("测试 PRINTFORMDL...")

        let script = """
        VARX = 50
        PRINTFORMDL "结果: %d", VARX
        """

        let result = try runScript(script)
        if result.contains("结果: 50") {
            print("  ✅ PRINTFORMDL 测试通过")
        } else {
            fatalError("PRINTFORMDL测试失败: '\(result)'")
        }
    }

    /// 测试PRINTFORMDW - 格式化输出等待 (不解析{}和%)
    private static func testPrintFormDW() throws {
        print("测试 PRINTFORMDW...")

        let script = """
        VARY = 99
        PRINTFORMDW "完成: %d", VARY
        """

        let result = try runScript(script)
        if result.contains("完成: 99") {
            print("  ✅ PRINTFORMDW 测试通过")
        } else {
            fatalError("PRINTFORMDW测试失败: '\(result)'")
        }
    }

    /// 运行脚本并返回输出
    private static func runScript(_ script: String) throws -> String {
        let parser = ScriptParser()
        let statements = try parser.parse(script)

        let executor = StatementExecutor()
        let console = EmueraConsole()
        let varData = VariableData()

        let context = ExecutionContext()
        context.varData = varData
        context.console = console

        // 使用execute方法执行
        executor.execute(statements, context: context)

        // 返回控制台内容
        return console.lines.map { $0.content }.joined(separator: "\n")
    }
}

// 运行测试
PrintDTest.runAllTests()
