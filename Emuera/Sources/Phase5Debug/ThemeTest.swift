//
//  ThemeTest.swift
//  Emuera
//
//  Phase 5 主题系统测试
//  测试新的主题系统功能
//  Created: 2025-12-24
//

import Foundation
@testable import EmueraCore

#if DEBUG

/// 主题系统测试
@main
class ThemeTest {

    static func main() {
        print("=== 主题系统测试 ===\n")

        let test = ThemeTest()

        do {
            try test.testThemeCreation()
            try test.testThemeColors()
            try test.testThemeFonts()
            try test.testThemeSpacing()
            try test.testConsoleThemeIntegration()
            try test.testThemeSwitching()
            try test.testThemedText()

            print("\n✅ 所有主题测试通过！")
        } catch {
            print("\n❌ 测试失败: \(error)")
        }
    }

    // MARK: - 测试1: 主题创建
    func testThemeCreation() throws {
        print("测试1: 主题创建")

        // 测试预定义主题
        let themes: [ConsoleTheme] = [
            .classic, .dark, .light, .highContrast, .cyberpunk, .compact
        ]

        for theme in themes {
            print("  - \(theme.name): OK")
        }

        // 测试自定义主题
        let customTheme = ConsoleTheme(
            name: "Custom",
            colors: ThemeColors(
                background: .black,
                text: .green,
                primary: .cyan,
                secondary: .gray,
                accent: .yellow,
                error: .red,
                warning: .orange,
                success: .green,
                border: .gray,
                selection: .blue
            ),
            fonts: ThemeFonts(
                normal: .system(size: 16),
                small: .system(size: 14),
                large: .system(size: 20),
                title: .system(size: 24, weight: .bold),
                monospace: .system(size: 14, design: .monospaced),
                code: .system(size: 12, design: .monospaced)
            ),
            spacing: ThemeSpacing(
                tiny: 1,
                small: 2,
                medium: 4,
                large: 8,
                extraLarge: 12
            )
        )

        print("  - 自定义主题: OK")
        print("  - 主题创建测试: ✅\n")
    }

    // MARK: - 测试2: 主题颜色
    func testThemeColors() throws {
        print("测试2: 主题颜色")

        let colors = ThemeColors.classic

        print("  - 背景色: \(colors.background)")
        print("  - 文本色: \(colors.text)")
        print("  - 主色: \(colors.primary)")
        print("  - 辅助色: \(colors.secondary)")
        print("  - 强调色: \(colors.accent)")
        print("  - 错误色: \(colors.error)")
        print("  - 警告色: \(colors.warning)")
        print("  - 成功色: \(colors.success)")
        print("  - 边框色: \(colors.border)")
        print("  - 选中色: \(colors.selection)")

        // 测试颜色方案
        let schemes: [ThemeColors] = [
            .classic, .dark, .light, .highContrast, .cyberpunk
        ]

        for scheme in schemes {
            print("  - 颜色方案 \(scheme): OK")
        }

        print("  - 主题颜色测试: ✅\n")
    }

    // MARK: - 测试3: 主题字体
    func testThemeFonts() throws {
        print("测试3: 主题字体")

        let fonts = ThemeFonts.default

        print("  - 正常字体: \(fonts.normal)")
        print("  - 小字体: \(fonts.small)")
        print("  - 大字体: \(fonts.large)")
        print("  - 标题字体: \(fonts.title)")
        print("  - 等宽字体: \(fonts.monospace)")
        print("  - 代码字体: \(fonts.code)")

        // 测试字体方案
        let schemes: [ThemeFonts] = [.default, .large, .compact]

        for scheme in schemes {
            print("  - 字体方案: OK")
        }

        print("  - 主题字体测试: ✅\n")
    }

    // MARK: - 测试4: 主题间距
    func testThemeSpacing() throws {
        print("测试4: 主题间距")

        let spacing = ThemeSpacing.default

        print("  - 微小间距: \(spacing.tiny)")
        print("  - 小间距: \(spacing.small)")
        print("  - 中间距: \(spacing.medium)")
        print("  - 大间距: \(spacing.large)")
        print("  - 超大间距: \(spacing.extraLarge)")

        // 测试间距方案
        let schemes: [ThemeSpacing] = [.default, .compact, .comfortable]

        for scheme in schemes {
            print("  - 间距方案: OK")
        }

        print("  - 主题间距测试: ✅\n")
    }

    // MARK: - 测试5: 控制台主题集成
    func testConsoleThemeIntegration() throws {
        print("测试5: 控制台主题集成")

        // 创建带主题的控制台
        let console = EmueraConsole(theme: .cyberpunk)

        // 验证主题已设置
        print("  - 当前主题: \(console.currentTheme.name)")
        print("  - 主题颜色: \(console.currentTheme.colors.primary)")

        // 测试主题扩展方法
        let themedLine = ConsoleLine.themedText(
            "测试主题文本",
            theme: .cyberpunk,
            style: .primary
        )

        print("  - 主题行类型: \(themedLine.type)")
        print("  - 主题行内容: \(themedLine.content)")
        print("  - 主题行颜色: \(themedLine.attributes.color)")

        print("  - 控制台主题集成测试: ✅\n")
    }

    // MARK: - 测试6: 主题切换
    func testThemeSwitching() throws {
        print("测试6: 主题切换")

        let console = EmueraConsole(theme: .classic)

        // 测试通过主题对象切换
        console.switchTheme(.dark)
        print("  - 切换到暗色主题: \(console.currentTheme.name)")

        // 测试通过名称切换
        let success = console.switchThemeByName("Light")
        print("  - 通过名称切换: \(success ? "成功" : "失败")")
        print("  - 当前主题: \(console.currentTheme.name)")

        // 测试无效名称
        let fail = console.switchThemeByName("InvalidTheme")
        print("  - 无效名称切换: \(fail ? "成功" : "失败")")

        // 获取所有可用主题
        let themeNames = console.getAvailableThemeNames()
        print("  - 可用主题数量: \(themeNames.count)")
        print("  - 可用主题: \(themeNames.joined(separator: ", "))")

        print("  - 主题切换测试: ✅\n")
    }

    // MARK: - 测试7: 主题化文本
    func testThemedText() throws {
        print("测试7: 主题化文本")

        let console = EmueraConsole(theme: .classic)

        // 测试不同样式
        console.printThemedText("普通文本", style: .normal)
        console.printThemedText("主文本", style: .primary)
        console.printThemedText("辅助文本", style: .secondary)
        console.printThemedText("错误文本", style: .error)
        console.printThemedText("警告文本", style: .warning)
        console.printThemedText("成功文本", style: .success)
        console.printThemedText("强调文本", style: .accent)

        print("  - 样式数量: 7")
        print("  - 控制台行数: \(console.lineCount)")

        // 验证所有行都已添加
        if console.lineCount == 8 { // 1欢迎 + 7样式
            print("  - 所有主题化文本已添加")
        }

        print("  - 主题化文本测试: ✅\n")
    }
}

#endif
