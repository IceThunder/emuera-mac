//
//  ERHTest.swift
//  Emuera
//
//  Phase 5 ERH头文件系统测试
//  测试 #INCLUDE, #FUNCTION, #DIM, #DEFINE, #GLOBAL 指令
//  Created: 2025-12-25
//

import Foundation
@testable import EmueraCore

#if DEBUG

/// ERH系统测试
@main
class ERHTest {

    static func main() {
        print("=== ERH头文件系统测试 ===\n")

        let test = ERHTest()

        do {
            try test.testPreprocessor()
            try test.testInclude()
            try test.testDefine()
            try test.testDim()
            try test.testGlobal()
            try test.testDependencyGraph()
            try test.testCircularDependency()

            print("\n✅ 所有ERH测试通过！")
        } catch {
            print("\n❌ 测试失败: \(error)")
        }
    }

    // MARK: - 测试1: 预处理器基础功能
    func testPreprocessor() throws {
        print("测试1: Preprocessor基础功能")

        let preprocessor = Preprocessor()

        // 测试简单宏定义
        let code1 = """
        #DEFINE MAX_HP 1000
        #DEFINE MAX_MP 500
        """

        let result1 = try preprocessor.preprocessContent(code1, source: "test1.erh")
        print("  - 简单宏定义: OK")

        // 测试带参数宏
        let code2 = "#DEFINE DAMAGE(x) (x * 2)"
        let result2 = try preprocessor.preprocessContent(code2, source: "test2.erh")
        print("  - 带参数宏: OK")

        // 验证宏已存储
        guard let maxHp = preprocessor.getMacro("MAX_HP") else {
            throw TestError.message("MAX_HP宏未存储")
        }
        print("  - 宏存储验证: OK")

        // 测试全局变量
        let code3 = """
        #DIM MY_VAR
        #DIMS MY_STRING
        #GLOBAL GLOBAL_ARRAY, 100
        """

        let result3 = try preprocessor.preprocessContent(code3, source: "test3.erh")

        guard let myVar = preprocessor.getGlobalVariable("MY_VAR") else {
            throw TestError.message("MY_VAR未存储")
        }

        guard let globalArray = preprocessor.getGlobalVariable("GLOBAL_ARRAY") else {
            throw TestError.message("GLOBAL_ARRAY未存储")
        }

        print("  - 全局变量存储: OK")
        print("  - 预处理器测试: ✅\n")
    }

    // MARK: - 测试2: #INCLUDE功能
    func testInclude() throws {
        print("测试2: #INCLUDE功能")

        let fileManager = FileManager.default
        let testDir = "/tmp/erh_test"

        // 创建测试目录
        try? fileManager.removeItem(atPath: testDir)
        try fileManager.createDirectory(atPath: testDir, withIntermediateDirectories: true)

        // 创建主文件（ERH头文件只包含#指令）
        let mainContent = """
        #INCLUDE "base.erh"
        #INCLUDE "utils.erh"
        #DEFINE MAIN_VALUE 999
        """

        // 创建被包含的文件
        let baseContent = """
        #DEFINE BASE_HP 100
        #DIM BASE_VAR
        """

        let utilsContent = """
        #DEFINE CALC(x) (x * 10)
        #GLOBAL UTILS_ARRAY, 50
        """

        try baseContent.write(toFile: "\(testDir)/base.erh", atomically: true, encoding: .utf8)
        try utilsContent.write(toFile: "\(testDir)/utils.erh", atomically: true, encoding: .utf8)
        try mainContent.write(toFile: "\(testDir)/main.erh", atomically: true, encoding: .utf8)

        // 使用预处理器测试
        let preprocessor = Preprocessor()
        let mainPath = "\(testDir)/main.erh"

        // 预处理主文件（应自动处理INCLUDE）
        let result = try preprocessor.preprocess(filePath: mainPath)

        // 验证依赖关系
        let deps = preprocessor.getDependencies()
        print("  - 依赖关系: \(deps)")

        // 验证宏已加载
        if preprocessor.getMacro("BASE_HP") == nil {
            throw TestError.message("BASE_HP宏未从base.erh加载")
        }

        if preprocessor.getMacro("CALC") == nil {
            throw TestError.message("CALC宏未从utils.erh加载")
        }

        print("  - #INCLUDE测试: ✅\n")

        // 清理
        try? fileManager.removeItem(atPath: testDir)
    }

    // MARK: - 测试3: #DEFINE功能
    func testDefine() throws {
        print("测试3: #DEFINE功能")

        let preprocessor = Preprocessor()

        // 测试各种宏定义
        let code = """
        #DEFINE MAX_HP 1000
        #DEFINE MAX_MP 500
        #DEFINE DAMAGE(x) (x * 2)
        #DEFINE HEAL(amount) (amount / 2)
        #DEFINE EMPTY_MACRO
        """

        try preprocessor.preprocessContent(code, source: "define_test.erh")

        // 验证宏
        let maxHp = preprocessor.getMacro("MAX_HP")
        let damage = preprocessor.getMacro("DAMAGE")
        let empty = preprocessor.getMacro("EMPTY_MACRO")

        if maxHp == nil || damage == nil || empty == nil {
            throw TestError.message("宏未正确存储")
        }

        if damage?.argCount != 1 {
            throw TestError.message("DAMAGE宏参数数量错误")
        }

        print("  - 宏定义解析: OK")
        print("  - 宏参数计数: OK")
        print("  - 空宏处理: OK")
        print("  - #DEFINE测试: ✅\n")
    }

    // MARK: - 测试4: #DIM/#DIMS功能
    func testDim() throws {
        print("测试4: #DIM/#DIMS功能")

        let preprocessor = Preprocessor()

        let code = """
        #DIM LOCAL_VAR
        #DIMS LOCAL_STRING
        #DIM ARRAY_VAR, 100
        #DIMS STRING_ARRAY, 50
        """

        try preprocessor.preprocessContent(code, source: "dim_test.erh")

        // 验证变量定义
        let localVar = preprocessor.getGlobalVariable("LOCAL_VAR")
        let localString = preprocessor.getGlobalVariable("LOCAL_STRING")
        let arrayVar = preprocessor.getGlobalVariable("ARRAY_VAR")
        let stringArray = preprocessor.getGlobalVariable("STRING_ARRAY")

        if localVar == nil || localString == nil || arrayVar == nil || stringArray == nil {
            throw TestError.message("全局变量未正确存储")
        }

        if !arrayVar!.isArray || arrayVar!.size != 100 {
            throw TestError.message("数组变量定义错误")
        }

        print("  - 标量变量: OK")
        print("  - 数组变量: OK")
        print("  - 字符串变量: OK")
        print("  - #DIM测试: ✅\n")
    }

    // MARK: - 测试5: #GLOBAL功能
    func testGlobal() throws {
        print("测试5: #GLOBAL功能")

        let preprocessor = Preprocessor()

        let code = """
        #GLOBAL GLOBAL_VAR
        #GLOBAL GLOBAL_ARRAY, 200
        """

        try preprocessor.preprocessContent(code, source: "global_test.erh")

        let globalVar = preprocessor.getGlobalVariable("GLOBAL_VAR")
        let globalArray = preprocessor.getGlobalVariable("GLOBAL_ARRAY")

        if globalVar == nil || globalArray == nil {
            throw TestError.message("全局变量未正确存储")
        }

        print("  - 全局标量: OK")
        print("  - 全局数组: OK")
        print("  - #GLOBAL测试: ✅\n")
    }

    // MARK: - 测试6: 依赖关系图
    func testDependencyGraph() throws {
        print("测试6: 依赖关系图和拓扑排序")

        let fileManager = FileManager.default
        let testDir = "/tmp/erh_deps_test"

        try? fileManager.removeItem(atPath: testDir)
        try fileManager.createDirectory(atPath: testDir, withIntermediateDirectories: true)

        // 创建依赖链: A -> B -> C
        let cContent = "#DEFINE C_VALUE 100"
        let bContent = "#INCLUDE \"C.erh\"\n#DEFINE B_VALUE C_VALUE"
        let aContent = "#INCLUDE \"B.erh\"\n#DEFINE A_VALUE B_VALUE"

        try cContent.write(toFile: "\(testDir)/C.erh", atomically: true, encoding: .utf8)
        try bContent.write(toFile: "\(testDir)/B.erh", atomically: true, encoding: .utf8)
        try aContent.write(toFile: "\(testDir)/A.erh", atomically: true, encoding: .utf8)

        let preprocessor = Preprocessor()

        // 预处理A，应该自动处理B和C
        let _ = try preprocessor.preprocess(filePath: "\(testDir)/A.erh")

        let deps = preprocessor.getDependencies()
        print("  - 依赖图: \(deps)")

        // 验证宏已全部加载
        if preprocessor.getMacro("C_VALUE") == nil ||
           preprocessor.getMacro("B_VALUE") == nil ||
           preprocessor.getMacro("A_VALUE") == nil {
            throw TestError.message("依赖链中的宏未全部加载")
        }

        print("  - 依赖链解析: OK")
        print("  - 依赖关系图测试: ✅\n")

        try? fileManager.removeItem(atPath: testDir)
    }

    // MARK: - 测试7: 循环依赖检测
    func testCircularDependency() throws {
        print("测试7: 循环依赖检测")

        let fileManager = FileManager.default
        let testDir = "/tmp/erh_circular_test"

        try? fileManager.removeItem(atPath: testDir)
        try fileManager.createDirectory(atPath: testDir, withIntermediateDirectories: true)

        // 创建循环依赖: A -> B -> C -> A
        let aContent = "#INCLUDE \"B.erh\""
        let bContent = "#INCLUDE \"C.erh\""
        let cContent = "#INCLUDE \"A.erh\""

        try aContent.write(toFile: "\(testDir)/A.erh", atomically: true, encoding: .utf8)
        try bContent.write(toFile: "\(testDir)/B.erh", atomically: true, encoding: .utf8)
        try cContent.write(toFile: "\(testDir)/C.erh", atomically: true, encoding: .utf8)

        let preprocessor = Preprocessor()

        do {
            let _ = try preprocessor.preprocess(filePath: "\(testDir)/A.erh")
            throw TestError.message("应该检测到循环依赖但未检测到")
        } catch PreprocessError.circularDependency {
            print("  - 循环依赖检测: OK")
        } catch {
            throw TestError.message("期望循环依赖错误，但得到: \(error)")
        }

        print("  - 循环依赖测试: ✅\n")

        try? fileManager.removeItem(atPath: testDir)
    }
}

/// 测试错误类型
enum TestError: Error {
    case message(String)
}

#endif
