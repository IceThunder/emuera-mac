//
//  IntegrationTest.swift
//  EmueraCore
//
//  完整集成测试 - 验证 Process + StatementExecutor + UI 系统协同工作
//  Created: 2025-12-20
//

import Foundation

/// 完整集成测试器
public final class IntegrationTest {
    public init() {}

    /// 运行完整集成测试
    /// - Returns: 测试结果报告
    public func runCompleteIntegrationTest() -> [String] {
        var results: [String] = []

        results.append("🧪 完整集成测试 - Process + StatementExecutor + UI")
        results.append(String(repeating: "=", count: 70))
        results.append("")

        // 测试1: 基础变量赋值和输出
        results.append(contentsOf: testBasicVariableFlow())

        // 测试2: 条件语句和流程控制
        results.append(contentsOf: testConditionalFlow())

        // 测试3: 循环结构
        results.append(contentsOf: testLoopFlow())

        // 测试4: 复杂脚本
        results.append(contentsOf: testComplexScript())

        results.append("")
        results.append(String(repeating: "=", count: 70))
        results.append("✅ 所有集成测试完成")

        return results
    }

    /// 测试1: 基础变量赋值和输出
    private func testBasicVariableFlow() -> [String] {
        var results: [String] = []
        results.append("测试1: 基础变量赋值和输出")
        results.append("-" * 50)

        let script = """
        A = 100
        B = 200
        PRINT A
        PRINTL
        PRINT B
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            results.append("脚本: \(script)")
            results.append("输出: \(output)")
            results.append("期望: [\"100\", \"\\n\", \"200\"]")
            results.append(output == ["100", "\n", "200"] ? "✅ 通过" : "❌ 失败")
        } catch {
            results.append("❌ 错误: \(error)")
        }

        results.append("")
        return results
    }

    /// 测试2: 条件语句和流程控制
    private func testConditionalFlow() -> [String] {
        var results: [String] = []
        results.append("测试2: 条件语句和流程控制")
        results.append("-" * 50)

        let script = """
        A = 10
        IF A > 5
          PRINTL A大于5
        ELSE
          PRINTL A小于等于5
        ENDIF
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            results.append("脚本: \(script)")
            results.append("输出: \(output)")
            results.append("期望: [\"A大于5\\n\"]")
            results.append(output == ["A大于5\n"] ? "✅ 通过" : "❌ 失败")
        } catch {
            results.append("❌ 错误: \(error)")
        }

        results.append("")
        return results
    }

    /// 测试3: 循环结构
    private func testLoopFlow() -> [String] {
        var results: [String] = []
        results.append("测试3: 循环结构")
        results.append("-" * 50)

        let script = """
        COUNT = 0
        WHILE COUNT < 3
          PRINT COUNT
          COUNT = COUNT + 1
        ENDWHILE
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            results.append("脚本: \(script)")
            results.append("输出: \(output)")
            results.append("期望: [\"0\", \"1\", \"2\"]")
            results.append(output == ["0", "1", "2"] ? "✅ 通过" : "❌ 失败")
        } catch {
            results.append("❌ 错误: \(error)")
        }

        results.append("")
        return results
    }

    /// 测试4: 复杂脚本
    private func testComplexScript() -> [String] {
        var results: [String] = []
        results.append("测试4: 复杂脚本")
        results.append("-" * 50)

        let script = """
        PRINTL 开始测试...
        A = 10
        B = 20
        C = A + B
        PRINT A + B =
        PRINT C
        PRINTL
        IF C > 25
          PRINTL C大于25
        ELSE
          PRINTL C小于等于25
        ENDIF
        FOR I, 1, 3
          PRINT I
        ENDFOR
        PRINTL
        PRINTL 测试完成！
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            results.append("脚本: (多行)")
            results.append("输出: \(output)")
            let expected = ["开始测试...\n", "A + B = ", "30", "\n", "C小于等于25\n", "1", "2", "3", "\n", "测试完成！\n"]
            results.append("期望: \(expected)")
            results.append(output == expected ? "✅ 通过" : "❌ 失败")
        } catch {
            results.append("❌ 错误: \(error)")
        }

        results.append("")
        return results
    }
}

/// Process系统集成测试
public final class ProcessIntegrationTest {
    public init() {}

    /// 测试Process与StatementExecutor的集成
    /// 使用ScriptParser解析脚本，然后通过Process执行
    public func runProcessExecutorIntegration() -> [String] {
        var results: [String] = []

        results.append("🧪 Process + StatementExecutor 集成测试")
        results.append(String(repeating: "=", count: 70))
        results.append("")

        // 测试1: 简单函数执行
        results.append("测试1: 简单函数执行")
        results.append("-" * 50)
        results.append(contentsOf: testSimpleFunctionWithParser())
        results.append("")

        // 测试2: 函数调用和返回
        results.append("测试2: 函数调用和返回")
        results.append("-" * 50)
        results.append(contentsOf: testCallReturnWithParser())
        results.append("")

        // 测试3: GOTO跳转
        results.append("测试3: GOTO跳转")
        results.append("-" * 50)
        results.append(contentsOf: testGotoWithParser())
        results.append("")

        results.append(String(repeating: "=", count: 70))
        results.append("✅ Process集成测试完成")

        return results
    }

    /// 测试1: 使用ScriptParser解析并执行
    private func testSimpleFunctionWithParser() -> [String] {
        var results: [String] = []

        let script = """
        A = 100
        PRINT A
        """

        do {
            // 解析脚本
            let parser = ScriptParser()
            let statements = try parser.parse(script)

            // 创建Process并设置函数
            let varData = VariableData()
            let tokenData = TokenData(varData: varData)
            let labelDictionary = LabelDictionary()
            let process = EmueraCore.Process(tokenData: tokenData, labelDictionary: labelDictionary)

            // 创建主函数并添加语句
            let funcLine = FunctionLabelLine(labelName: "MAIN")
            funcLine.statements = statements
            labelDictionary.addNonEventLabel("MAIN", funcLine)

            // 执行
            try process.callFunction("MAIN", nil as LogicalLine?)
            let output = try process.runScriptProc()

            results.append("  脚本: \(script)")
            results.append("  输出: \(output)")
            results.append("  期望: [\"100\"]")
            results.append(output == ["100"] ? "  ✅ 通过" : "  ❌ 失败")
        } catch {
            results.append("  ❌ 错误: \(error)")
        }

        return results
    }

    /// 测试2: 函数调用和返回
    private func testCallReturnWithParser() -> [String] {
        var results: [String] = []

        let mainScript = """
        CALL SUB
        PRINT A
        """

        let subScript = """
        A = 150
        RETURN
        """

        do {
            // 解析主函数
            let parser = ScriptParser()
            let mainStatements = try parser.parse(mainScript)
            let subStatements = try parser.parse(subScript)

            // 创建Process
            let varData = VariableData()
            let tokenData = TokenData(varData: varData)
            let labelDictionary = LabelDictionary()
            let process = EmueraCore.Process(tokenData: tokenData, labelDictionary: labelDictionary)

            // 创建主函数
            let mainFunc = FunctionLabelLine(labelName: "MAIN")
            mainFunc.statements = mainStatements
            labelDictionary.addNonEventLabel("MAIN", mainFunc)

            // 创建子函数
            let subFunc = FunctionLabelLine(labelName: "SUB")
            subFunc.statements = subStatements
            labelDictionary.addNonEventLabel("SUB", subFunc)

            // 执行
            try process.callFunction("MAIN", nil as LogicalLine?)
            let output = try process.runScriptProc()

            results.append("  主函数: CALL SUB, PRINT A")
            results.append("  子函数: A = 150, RETURN")
            results.append("  输出: \(output)")
            results.append("  期望: [\"150\"]")
            results.append(output == ["150"] ? "  ✅ 通过" : "  ❌ 失败")
        } catch {
            results.append("  ❌ 错误: \(error)")
        }

        return results
    }

    /// 测试3: GOTO跳转
    private func testGotoWithParser() -> [String] {
        var results: [String] = []

        let script = """
        A = 10
        GOTO SKIP
        A = 20
        SKIP:
        PRINT A
        """

        do {
            // 解析脚本
            let parser = ScriptParser()
            let statements = try parser.parse(script)

            // 创建Process
            let varData = VariableData()
            let tokenData = TokenData(varData: varData)
            let labelDictionary = LabelDictionary()
            let process = EmueraCore.Process(tokenData: tokenData, labelDictionary: labelDictionary)

            // 创建函数
            let funcLine = FunctionLabelLine(labelName: "GOTOTEST")
            funcLine.statements = statements
            labelDictionary.addNonEventLabel("GOTOTEST", funcLine)

            // 执行
            try process.callFunction("GOTOTEST", nil as LogicalLine?)
            let output = try process.runScriptProc()

            results.append("  脚本: A=10, GOTO SKIP, A=20, SKIP:, PRINT A")
            results.append("  输出: \(output)")
            results.append("  期望: [\"10\"]")
            results.append(output == ["10"] ? "  ✅ 通过" : "  ❌ 失败")
        } catch {
            results.append("  ❌ 错误: \(error)")
        }

        return results
    }
}

// MARK: - String 扩展

extension String {
    static func *(left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
