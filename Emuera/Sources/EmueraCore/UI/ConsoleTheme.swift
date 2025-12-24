//
//  ConsoleTheme.swift
//  EmueraCore
//
//  控制台主题系统，支持自定义颜色方案和样式
//  相当于C# Emuera中的主题配置系统
//
//  Created: 2025-12-24
//

import Foundation
import SwiftUI

/// 主题颜色定义
public struct ThemeColors: Hashable {
    public var background: Color
    public var text: Color
    public var primary: Color
    public var secondary: Color
    public var accent: Color
    public var error: Color
    public var warning: Color
    public var success: Color
    public var border: Color
    public var selection: Color

    public init(
        background: Color = Color(NSColor.textBackgroundColor),
        text: Color = Color.primary,
        primary: Color = .blue,
        secondary: Color = .gray,
        accent: Color = .cyan,
        error: Color = .red,
        warning: Color = .yellow,
        success: Color = .green,
        border: Color = Color.gray.opacity(0.3),
        selection: Color = Color.blue.opacity(0.2)
    ) {
        self.background = background
        self.text = text
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.error = error
        self.warning = warning
        self.success = success
        self.border = border
        self.selection = selection
    }

    // MARK: - 预定义主题

    /// 经典主题 (类似原版Emuera)
    public static let classic = ThemeColors(
        background: Color(NSColor.controlBackgroundColor),
        text: .white,
        primary: .cyan,
        secondary: .gray,
        accent: .yellow,
        error: .red,
        warning: .orange,
        success: .green,
        border: Color.gray.opacity(0.5),
        selection: Color.cyan.opacity(0.3)
    )

    /// 暗色主题 (现代风格)
    public static let dark = ThemeColors(
        background: Color(NSColor.windowBackgroundColor),
        text: .white,
        primary: .blue,
        secondary: .gray,
        accent: .cyan,
        error: .red,
        warning: .yellow,
        success: .green,
        border: Color.gray.opacity(0.4),
        selection: Color.blue.opacity(0.3)
    )

    /// 浅色主题
    public static let light = ThemeColors(
        background: .white,
        text: .black,
        primary: .blue,
        secondary: .gray,
        accent: .purple,
        error: .red,
        warning: .orange,
        success: .green,
        border: Color.gray.opacity(0.2),
        selection: Color.blue.opacity(0.2)
    )

    /// 高对比度主题 (无障碍)
    public static let highContrast = ThemeColors(
        background: .black,
        text: .white,
        primary: .yellow,
        secondary: .white,
        accent: .cyan,
        error: .red,
        warning: .yellow,
        success: .green,
        border: .white,
        selection: Color.yellow.opacity(0.5)
    )

    /// 未来科技主题
    public static let cyberpunk = ThemeColors(
        background: Color(red: 0.05, green: 0.05, blue: 0.1),
        text: Color(red: 0.9, green: 0.95, blue: 1.0),
        primary: Color(red: 0.0, green: 0.8, blue: 1.0),
        secondary: Color(red: 0.6, green: 0.4, blue: 0.8),
        accent: Color(red: 1.0, green: 0.2, blue: 0.8),
        error: Color(red: 1.0, green: 0.1, blue: 0.1),
        warning: Color(red: 1.0, green: 0.6, blue: 0.0),
        success: Color(red: 0.0, green: 1.0, blue: 0.4),
        border: Color(red: 0.2, green: 0.3, blue: 0.4),
        selection: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.3)
    )
}

/// 主题字体定义
public struct ThemeFonts: Hashable {
    public var normal: Font
    public var small: Font
    public var large: Font
    public var title: Font
    public var monospace: Font
    public var code: Font

    public init(
        normal: Font = .system(size: 14),
        small: Font = .system(size: 12),
        large: Font = .system(size: 18),
        title: Font = .system(size: 20, weight: .bold),
        monospace: Font = .system(size: 13, design: .monospaced),
        code: Font = .system(size: 12, design: .monospaced)
    ) {
        self.normal = normal
        self.small = small
        self.large = large
        self.title = title
        self.monospace = monospace
        self.code = code
    }

    // MARK: - 预定义字体方案

    /// 默认字体方案
    public static let `default` = ThemeFonts()

    /// 大字体方案 (适合高DPI屏幕)
    public static let large = ThemeFonts(
        normal: .system(size: 16),
        small: .system(size: 14),
        large: .system(size: 20),
        title: .system(size: 24, weight: .bold),
        monospace: .system(size: 15, design: .monospaced),
        code: .system(size: 14, design: .monospaced)
    )

    /// 小字体方案 (紧凑显示)
    public static let compact = ThemeFonts(
        normal: .system(size: 12),
        small: .system(size: 10),
        large: .system(size: 14),
        title: .system(size: 16, weight: .bold),
        monospace: .system(size: 11, design: .monospaced),
        code: .system(size: 10, design: .monospaced)
    )
}

/// 主题间距定义
public struct ThemeSpacing: Hashable {
    public var tiny: CGFloat
    public var small: CGFloat
    public var medium: CGFloat
    public var large: CGFloat
    public var extraLarge: CGFloat

    public init(
        tiny: CGFloat = 2,
        small: CGFloat = 4,
        medium: CGFloat = 8,
        large: CGFloat = 16,
        extraLarge: CGFloat = 24
    ) {
        self.tiny = tiny
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
    }

    // MARK: - 预定义间距方案

    /// 默认间距
    public static let `default` = ThemeSpacing()

    /// 紧凑间距
    public static let compact = ThemeSpacing(
        tiny: 1,
        small: 2,
        medium: 4,
        large: 8,
        extraLarge: 12
    )

    /// 宽松间距
    public static let comfortable = ThemeSpacing(
        tiny: 3,
        small: 6,
        medium: 12,
        large: 20,
        extraLarge: 32
    )
}

/// 主题配置
public struct ConsoleTheme: Hashable {
    public var name: String
    public var colors: ThemeColors
    public var fonts: ThemeFonts
    public var spacing: ThemeSpacing

    public init(
        name: String,
        colors: ThemeColors = .classic,
        fonts: ThemeFonts = .default,
        spacing: ThemeSpacing = .default
    ) {
        self.name = name
        self.colors = colors
        self.fonts = fonts
        self.spacing = spacing
    }

    // MARK: - 预定义主题

    /// 经典主题
    public static let classic = ConsoleTheme(
        name: "Classic",
        colors: .classic,
        fonts: .default,
        spacing: .default
    )

    /// 暗色主题
    public static let dark = ConsoleTheme(
        name: "Dark",
        colors: .dark,
        fonts: .default,
        spacing: .default
    )

    /// 浅色主题
    public static let light = ConsoleTheme(
        name: "Light",
        colors: .light,
        fonts: .default,
        spacing: .default
    )

    /// 高对比度主题
    public static let highContrast = ConsoleTheme(
        name: "High Contrast",
        colors: .highContrast,
        fonts: .large,
        spacing: .comfortable
    )

    /// 未来科技主题
    public static let cyberpunk = ConsoleTheme(
        name: "Cyberpunk",
        colors: .cyberpunk,
        fonts: .default,
        spacing: .compact
    )

    /// 紧凑主题
    public static let compact = ConsoleTheme(
        name: "Compact",
        colors: .light,
        fonts: .compact,
        spacing: .compact
    )
}

/// 主题管理器
public final class ThemeManager: ObservableObject {
    @Published public var currentTheme: ConsoleTheme

    public init(theme: ConsoleTheme = .classic) {
        self.currentTheme = theme
    }

    /// 切换主题
    public func switchTheme(_ theme: ConsoleTheme) {
        self.currentTheme = theme
    }

    /// 通过名称切换主题
    public func switchThemeByName(_ name: String) -> Bool {
        let themes: [ConsoleTheme] = [
            .classic, .dark, .light, .highContrast, .cyberpunk, .compact
        ]

        if let theme = themes.first(where: { $0.name == name }) {
            switchTheme(theme)
            return true
        }
        return false
    }

    /// 获取所有可用主题
    public func getAllThemes() -> [ConsoleTheme] {
        return [
            .classic, .dark, .light, .highContrast, .cyberpunk, .compact
        ]
    }

    /// 获取当前主题的可用颜色
    public func getCurrentColors() -> ThemeColors {
        return currentTheme.colors
    }

    /// 获取当前主题的字体
    public func getCurrentFonts() -> ThemeFonts {
        return currentTheme.fonts
    }

    /// 获取当前主题的间距
    public func getCurrentSpacing() -> ThemeSpacing {
        return currentTheme.spacing
    }
}

/// 主题扩展 - 为ConsoleLine添加主题支持
extension ConsoleLine {
    /// 使用主题颜色创建文本行
    public static func themedText(
        _ content: String,
        theme: ConsoleTheme,
        style: TextStyle = .normal
    ) -> ConsoleLine {
        var attrs = ConsoleAttributes()

        switch style {
        case .normal:
            attrs.color = ConsoleColor.fromColor(theme.colors.text)
            attrs.font = .default
        case .primary:
            attrs.color = ConsoleColor.fromColor(theme.colors.primary)
            attrs.isBold = true
        case .secondary:
            attrs.color = ConsoleColor.fromColor(theme.colors.secondary)
        case .error:
            attrs.color = ConsoleColor.fromColor(theme.colors.error)
            attrs.isBold = true
        case .warning:
            attrs.color = ConsoleColor.fromColor(theme.colors.warning)
        case .success:
            attrs.color = ConsoleColor.fromColor(theme.colors.success)
        case .accent:
            attrs.color = ConsoleColor.fromColor(theme.colors.accent)
        }

        return ConsoleLine(type: .text, content: content, attributes: attrs)
    }
}

/// 文本样式枚举
public enum TextStyle {
    case normal
    case primary
    case secondary
    case error
    case warning
    case success
    case accent
}

/// ConsoleColor扩展 - 从SwiftUI Color转换
extension ConsoleColor {
    public static func fromColor(_ color: Color) -> ConsoleColor {
        // 简单的颜色映射，实际应用中可能需要更复杂的颜色解析
        // 注意：SwiftUI Color 的 case 需要通过其他方式判断，这里简化为返回默认值
        return .default
    }
}
