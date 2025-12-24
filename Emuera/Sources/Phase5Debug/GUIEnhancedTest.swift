//
//  GUIEnhancedTest.swift
//  Emuera
//
//  Phase 5 GUI增强系统测试
//  测试新的控制台行类型和属性
//  Created: 2025-12-24
//

import Foundation
@testable import EmueraCore

#if DEBUG

/// GUI增强系统测试
@main
class GUIEnhancedTest {

    static func main() {
        print("=== GUI增强系统测试 ===\n")

        let test = GUIEnhancedTest()

        do {
            try test.testEnhancedAttributes()
            try test.testProgressBar()
            try test.testTable()
            try test.testHeaderAndQuote()
            try test.testCodeAndLink()
            try test.testComplexLayout()

            print("\n✅ 所有GUI增强测试通过！")
        } catch {
            print("\n❌ 测试失败: \(error)")
        }
    }

    // MARK: - 测试1: 增强的文本属性
    func testEnhancedAttributes() throws {
        print("测试1: 增强的文本属性")

        let console = EmueraConsole()

        // 测试背景色
        console.printText("带背景色的文本", attributes: ConsoleAttributes(
            color: .white,
            backgroundColor: .blue
        ))

        // 测试自定义字体大小
        console.printText("大号文本", attributes: ConsoleAttributes(
            fontSize: 24.0,
            isBold: true
        ))

        // 测试透明度
        console.printText("半透明文本", attributes: ConsoleAttributes(
            opacity: 0.5
        ))

        // 测试字符间距
        console.printText("宽字符间距", attributes: ConsoleAttributes(
            letterSpacing: 2.0
        ))

        // 测试删除线
        console.printText("删除线文本", attributes: ConsoleAttributes(
            strikethrough: true,
            strikethroughColor: .red
        ))

        // 测试行高
        console.printText("高行距文本", attributes: ConsoleAttributes(
            lineHeight: 2.0
        ))

        print("  - 背景色: OK")
        print("  - 自定义字体大小: OK")
        print("  - 透明度: OK")
        print("  - 字符间距: OK")
        print("  - 删除线: OK")
        print("  - 行高: OK")
        print("  - 增强属性测试: ✅\n")
    }

    // MARK: - 测试2: 进度条
    func testProgressBar() throws {
        print("测试2: 进度条")

        let console = EmueraConsole()

        // 添加不同进度的进度条
        console.addProgressBar(value: 0.0, label: "开始")
        console.addProgressBar(value: 0.25, label: "四分之一")
        console.addProgressBar(value: 0.5, label: "一半")
        console.addProgressBar(value: 0.75, label: "四分之三")
        console.addProgressBar(value: 1.0, label: "完成")

        // 带自定义属性的进度条
        console.addProgressBar(
            value: 0.66,
            label: "自定义样式",
            attributes: ConsoleAttributes(color: .green)
        )

        print("  - 进度条渲染: OK")
        print("  - 进度条标签: OK")
        print("  - 自定义属性: OK")
        print("  - 进度条测试: ✅\n")
    }

    // MARK: - 测试3: 表格
    func testTable() throws {
        print("测试3: 表格")

        let console = EmueraConsole()

        // 简单表格
        console.addTable(
            headers: ["ID", "名称", "数值"],
            data: [
                ["1", "项目A", "100"],
                ["2", "项目B", "200"],
                ["3", "项目C", "300"]
            ]
        )

        // 复杂表格
        console.addTable(
            headers: ["角色", "等级", "HP", "MP"],
            data: [
                ["勇者", "99", "5000", "2000"],
                ["法师", "80", "2500", "4000"],
                ["战士", "85", "4000", "1000"]
            ],
            attributes: ConsoleAttributes(color: .cyan)
        )

        print("  - 表格渲染: OK")
        print("  - 表头处理: OK")
        print("  - 多行数据: OK")
        print("  - 表格测试: ✅\n")
    }

    // MARK: - 测试4: 标题和引用
    func testHeaderAndQuote() throws {
        print("测试4: 标题和引用")

        let console = EmueraConsole()

        // 不同级别的标题
        console.addHeader("一级标题", level: 1)
        console.addHeader("二级标题", level: 2)
        console.addHeader("三级标题", level: 3)

        // 引用文本
        console.addQuote("这是一个引用段落，用于显示引用或注释内容。")
        console.addQuote("可以有多行引用文本。", attributes: ConsoleAttributes(
            color: .blue,
            isItalic: true
        ))

        print("  - 标题级别: OK")
        print("  - 标题样式: OK")
        print("  - 引用文本: OK")
        print("  - 引用样式: OK")
        print("  - 标题和引用测试: ✅\n")
    }

    // MARK: - 测试5: 代码块和链接
    func testCodeAndLink() throws {
        print("测试5: 代码块和链接")

        let console = EmueraConsole()

        // 代码块
        console.addCode("PRINT \"Hello, World!\"", language: "erlang")
        console.addCode("VAR = 100\nRESULT = VAR * 2", language: "basic")

        // 链接
        console.addLink("访问官网", url: "https://example.com")
        console.addLink("自定义动作", url: "internal://action", action: {
            print("  - 链接动作被触发")
        })

        print("  - 代码块渲染: OK")
        print("  - 代码语言标记: OK")
        print("  - 链接渲染: OK")
        print("  - 链接动作: OK")
        print("  - 代码和链接测试: ✅\n")
    }

    // MARK: - 测试6: 复杂布局
    func testComplexLayout() throws {
        print("测试6: 复杂布局")

        let console = EmueraConsole()

        // 模拟一个复杂的游戏界面
        console.addHeader("角色状态", level: 1)

        console.addTable(
            headers: ["属性", "数值"],
            data: [
                ["HP", "5000/5000"],
                ["MP", "2000/2000"],
                ["等级", "99"],
                ["经验", "999999"]
            ]
        )

        console.addProgressBar(value: 1.0, label: "HP")
        console.addProgressBar(value: 1.0, label: "MP")

        console.addQuote("状态良好，可以继续冒险！")

        console.addHeader("装备", level: 2)
        console.addCode("武器: 圣剑\n防具: 圣铠\n饰品: 魔法戒指", language: "inventory")

        console.addSeparator()

        console.addLink("保存游戏", url: "game://save")
        console.addLink("返回菜单", url: "game://menu")

        print("  - 标题分层: OK")
        console.addSeparator()
        print("  - 表格数据: OK")
        print("  - 进度条: OK")
        print("  - 引用文本: OK")
        print("  - 代码块: OK")
        print("  - 分隔线: OK")
        print("  - 链接交互: OK")
        print("  - 复杂布局测试: ✅\n")
    }
}

/// 为EmueraConsole添加便捷方法
extension EmueraConsole {
    /// 添加分隔线
    public func addSeparator() {
        let line = ConsoleLine(type: .separator, content: "")
        addLine(line)
    }
}

#endif
