//
//  Phase2Test.swift
//  EmueraApp
//
//  Phase 2函数系统测试
//  Created: 2025-12-20
//

import Foundation
import EmueraCore

/// Phase 2函数系统测试
public struct Phase2Test {

    /// 运行所有Phase 2测试
    public static func runAllTests() {
        print("=== Phase 2 函数系统测试 ===\n")

        testFunctionDefinition()
        testFunctionCall()
        testLocalVariables()
        testBuiltInFunctions()
        testReturnStatement()

        print("\n=== Phase 2 测试完成 ===")
    }

    /// 测试函数定义解析
    private static func testFunctionDefinition() {
        print("1. 测试函数定义解析...")

        let script = """
        @TESTFUNC, arg1, arg2
        #DIM LOCAL
        LOCAL = arg1 + arg2
        RETURN LOCAL
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            print("   ✓ 解析成功，得到 \(statements.count) 个语句")

            for stmt in statements {
                if let funcStmt = stmt as? FunctionDefinitionStatement {
                    print("   ✓ 函数定义: \(funcStmt.definition.name)")
                    print("     参数: \(funcStmt.definition.parameters.map { $0.name })")
                    print("     体语句: \(funcStmt.definition.body.count)")
                }
            }
        } catch {
            print("   ✗ 解析失败: \(error)")
        }
    }

    /// 测试函数调用
    private static func testFunctionCall() {
        print("\n2. 测试函数调用...")

        let script = """
        @ADD, a, b
        RETURN a + b

        CALL @ADD, 5, 3
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            print("   ✓ 执行成功")
            print("   输出: \(output)")
        } catch {
            print("   ✗ 执行失败: \(error)")
        }
    }

    /// 测试局部变量
    private static func testLocalVariables() {
        print("\n3. 测试局部变量...")

        let script = """
        @TEST_LOCAL
        #DIM LOCAL
        #DIMS LOCALS
        LOCAL = 42
        LOCALS = "Hello"
        PRINTL LOCAL: {LOCAL}
        PRINTL LOCALS: %LOCALS%
        RETURN LOCAL
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            print("   ✓ 执行成功")
            print("   输出:")
            for line in output {
                print("     \(line)")
            }
        } catch {
            print("   ✗ 执行失败: \(error)")
        }
    }

    /// 测试内置函数
    private static func testBuiltInFunctions() {
        print("\n4. 测试内置函数...")

        let script = """
        PRINT RAND(100)
        PRINTL
        PRINT ABS(-5)
        PRINTL
        PRINT LIMIT(150, 0, 100)
        PRINTL
        PRINT MIN(5, 3, 8, 2)
        PRINTL
        PRINT MAX(5, 3, 8, 2)
        PRINTL
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            print("   ✓ 执行成功")
            print("   输出:")
            for line in output {
                print("     \(line)")
            }
        } catch {
            print("   ✗ 执行失败: \(error)")
        }
    }

    /// 测试RETURN语句
    private static func testReturnStatement() {
        print("\n5. 测试RETURN语句...")

        let script = """
        @FACTORIAL, n
        #DIM LOCAL
        IF n <= 1
            RETURN 1
        ENDIF
        LOCAL = @FACTORIAL, n - 1
        RETURN n * LOCAL

        PRINTL 5! =
        PRINT @FACTORIAL, 5
        PRINTL
        """

        do {
            let parser = ScriptParser()
            let statements = try parser.parse(script)
            let executor = StatementExecutor()
            let output = executor.execute(statements)

            print("   ✓ 执行成功")
            print("   输出:")
            for line in output {
                print("     \(line)")
            }
        } catch {
            print("   ✗ 执行失败: \(error)")
        }
    }
}

/// 运行Phase 2测试的入口点
@main
public struct Phase2TestRunner {
    public static func main() {
        Phase2Test.runAllTests()
    }
}
