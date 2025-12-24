//
//  EmueraConsole.swift
//  EmueraCore
//
//  UI系统的主协调器，负责管理显示缓冲区、处理输出、与Process系统对接
//  相当于C# Emuera中的EmueraConsole类
//
//  Created: 2025-12-20
//

import Foundation
import Combine

/// 显示行类型
public enum ConsoleLineType {
    case text           // 普通文本
    case print          // PRINT/PRINTL输出
    case error          // 错误信息
    case button         // 可点击按钮
    case image          // 图像
    case separator      // 分隔线
    case progressBar    // 进度条
    case table          // 表格数据
    case header         // 标题文本
    case quote          // 引用文本
    case code           // 代码块
    case link           // 可点击链接
}

/// 显示行数据结构
public struct ConsoleLine: Identifiable, Hashable {
    public let id = UUID()
    public let type: ConsoleLineType
    public let content: String
    public let attributes: ConsoleAttributes
    public let timestamp: Date

    // 用于按钮和链接
    public var buttonValue: Int?
    public var buttonAction: (() -> Void)?
    public var linkURL: String?

    // 用于图像
    public var imageReference: String?
    public var imageSize: CGSize?

    // 用于进度条
    public var progressValue: Double?  // 0.0 - 1.0
    public var progressLabel: String?

    // 用于表格
    public var tableData: [[String]]?  // 二维数组表示表格
    public var tableHeaders: [String]?

    // 用于代码块
    public var codeLanguage: String?

    // 用于多行内容
    public var multiLineContent: [String]?

    public init(
        type: ConsoleLineType,
        content: String,
        attributes: ConsoleAttributes = ConsoleAttributes(),
        buttonValue: Int? = nil,
        buttonAction: (() -> Void)? = nil,
        linkURL: String? = nil,
        imageReference: String? = nil,
        imageSize: CGSize? = nil,
        progressValue: Double? = nil,
        progressLabel: String? = nil,
        tableData: [[String]]? = nil,
        tableHeaders: [String]? = nil,
        codeLanguage: String? = nil,
        multiLineContent: [String]? = nil
    ) {
        self.type = type
        self.content = content
        self.attributes = attributes
        self.timestamp = Date()
        self.buttonValue = buttonValue
        self.buttonAction = buttonAction
        self.linkURL = linkURL
        self.imageReference = imageReference
        self.imageSize = imageSize
        self.progressValue = progressValue
        self.progressLabel = progressLabel
        self.tableData = tableData
        self.tableHeaders = tableHeaders
        self.codeLanguage = codeLanguage
        self.multiLineContent = multiLineContent
    }

    public static func == (lhs: ConsoleLine, rhs: ConsoleLine) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// 文本属性和样式
public struct ConsoleAttributes: Hashable {
    public var color: ConsoleColor
    public var backgroundColor: ConsoleColor?
    public var font: ConsoleFont
    public var fontSize: CGFloat?  // 自定义字体大小
    public var alignment: TextAlignment
    public var isBold: Bool
    public var isItalic: Bool
    public var isUnderlined: Bool
    public var lineHeight: CGFloat?  // 行高
    public var letterSpacing: CGFloat?  // 字符间距
    public var opacity: Double  // 透明度 (0.0 - 1.0)
    public var strikethrough: Bool  // 删除线
    public var strikethroughColor: ConsoleColor?

    public init(
        color: ConsoleColor = .default,
        backgroundColor: ConsoleColor? = nil,
        font: ConsoleFont = .default,
        fontSize: CGFloat? = nil,
        alignment: TextAlignment = .left,
        isBold: Bool = false,
        isItalic: Bool = false,
        isUnderlined: Bool = false,
        lineHeight: CGFloat? = nil,
        letterSpacing: CGFloat? = nil,
        opacity: Double = 1.0,
        strikethrough: Bool = false,
        strikethroughColor: ConsoleColor? = nil
    ) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.font = font
        self.fontSize = fontSize
        self.alignment = alignment
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.opacity = opacity
        self.strikethrough = strikethrough
        self.strikethroughColor = strikethroughColor
    }
}

/// 颜色系统
public enum ConsoleColor: Hashable {
    case `default`
    case black
    case white
    case red
    case green
    case blue
    case yellow
    case cyan
    case magenta
    case gray
    case custom(r: UInt8, g: UInt8, b: UInt8)

    public var toHex: String {
        switch self {
        case .default: return "#FFFFFF"
        case .black: return "#000000"
        case .white: return "#FFFFFF"
        case .red: return "#FF0000"
        case .green: return "#00FF00"
        case .blue: return "#0000FF"
        case .yellow: return "#FFFF00"
        case .cyan: return "#00FFFF"
        case .magenta: return "#FF00FF"
        case .gray: return "#808080"
        case .custom(let r, let g, let b):
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }
}

/// 字体系统
public enum ConsoleFont: Hashable {
    case `default`
    case small
    case large
    case monospace

    public var size: CGFloat {
        switch self {
        case .default: return 14.0
        case .small: return 12.0
        case .large: return 18.0
        case .monospace: return 13.0
        }
    }
}

/// 文本对齐
public enum TextAlignment: Hashable {
    case left
    case center
    case right
}

/// 输入请求类型
public enum InputType: Hashable {
    case enterKey       // WAIT
    case anyKey         // WAIT with any key
    case intValue       // INPUT
    case strValue       // INPUTS
    case void           // 无输入
    case primitiveMouseKey // 鼠标/键盘事件
}

/// 输入请求结构
public struct InputRequest: Hashable {
    public let type: InputType
    public let oneInput: Bool
    public let timeLimit: TimeInterval?
    public let defaultValue: String?
    public let prompt: String?

    public init(
        type: InputType,
        oneInput: Bool = false,
        timeLimit: TimeInterval? = nil,
        defaultValue: String? = nil,
        prompt: String? = nil
    ) {
        self.type = type
        self.oneInput = oneInput
        self.timeLimit = timeLimit
        self.defaultValue = defaultValue
        self.prompt = prompt
    }
}

/// 输入结果
public enum InputResult: Hashable {
    case success(String)
    case timeout
    case cancelled
    case error(String)
}

/// 控制台状态
public enum ConsoleState: Hashable {
    case ready          // 就绪，等待命令
    case running        // 脚本执行中
    case waitingInput   // 等待用户输入
    case sleeping       // WAIT/SLEEP中
    case paused         // 暂停
    case error          // 错误状态
    case quit           // 已退出
}

/// EmueraConsole主协调器
public final class EmueraConsole: ObservableObject {

    // MARK: - Published Properties

    /// 显示缓冲区
    @Published public private(set) var lines: [ConsoleLine] = []

    /// 当前状态
    @Published public private(set) var state: ConsoleState = .ready

    /// 当前输入请求（如果有）
    @Published public private(set) var currentInputRequest: InputRequest?

    /// 滚动到最新
    @Published public var scrollToBottom: Bool = false

    /// 当前主题
    @Published public var currentTheme: ConsoleTheme

    /// 总行数
    public var lineCount: Int { lines.count }

    // MARK: - Private Properties

    /// 输出队列（用于批处理输出）
    private var outputQueue: [ConsoleLine] = []

    /// 输入Continuation（用于async/await）
    private var inputContinuation: CheckedContinuation<InputResult, Never>?

    /// 与Process的连接
    private var process: Process?

    /// 配置
    private var config: ConsoleConfig

    // MARK: - Initialization

    public init(config: ConsoleConfig = ConsoleConfig(), theme: ConsoleTheme = .classic) {
        self.config = config
        self.currentTheme = theme
        setupInitialState()
    }

    private func setupInitialState() {
        // 添加欢迎信息
        let welcomeLine = ConsoleLine.themedText(
            "Emuera for macOS - Ready",
            theme: currentTheme,
            style: .primary
        )
        addLine(welcomeLine)
    }

    // MARK: - Output Methods

    /// 添加单行
    public func addLine(_ line: ConsoleLine) {
        lines.append(line)
        scrollToBottom = true

        // 限制缓冲区大小
        if lines.count > config.maxBufferSize {
            lines.removeFirst(lines.count - config.maxBufferSize)
        }
    }

    /// 批量添加行
    public func addLines(_ newLines: [ConsoleLine]) {
        lines.append(contentsOf: newLines)
        scrollToBottom = true

        if lines.count > config.maxBufferSize {
            lines.removeFirst(lines.count - config.maxBufferSize)
        }
    }

    /// 打印文本（类似PRINT）
    public func printText(_ text: String, newLine: Bool = true, attributes: ConsoleAttributes? = nil) {
        let attrs = attributes ?? ConsoleAttributes()
        let content = newLine ? text : text

        let line = ConsoleLine(
            type: .print,
            content: content,
            attributes: attrs
        )

        addLine(line)
    }

    /// 打印错误
    public func printError(_ message: String, position: ScriptPosition? = nil) {
        var content = "❌ \(message)"
        if let pos = position {
            content += " (Line: \(String(describing: pos.line)), Col: \(String(describing: pos.column)))"
        }

        let line = ConsoleLine(
            type: .error,
            content: content,
            attributes: ConsoleAttributes(color: .red, isBold: true)
        )

        addLine(line)
        state = .error
    }

    /// 打印调试信息
    public func printDebug(_ message: String) {
        #if DEBUG
        let line = ConsoleLine(
            type: .text,
            content: "🔧 \(message)",
            attributes: ConsoleAttributes(color: .gray)
        )
        addLine(line)
        #endif
    }

    /// 清空控制台
    public func clear() {
        lines.removeAll()
        outputQueue.removeAll()
    }

    // MARK: - Input Methods

    /// 等待用户输入（异步）
    public func waitForInput(request: InputRequest) async -> InputResult {
        // 更新状态和当前请求
        self.state = .waitingInput
        self.currentInputRequest = request

        // 使用Continuation挂起等待输入
        return await withCheckedContinuation { continuation in
            self.inputContinuation = continuation

            // 如果有超时设置
            if let timeLimit = request.timeLimit {
                Task {
                    try? await Task.sleep(nanoseconds: UInt64(timeLimit * 1_000_000_000))
                    // 检查是否还是同一个请求
                    if self.inputContinuation != nil {
                        self.handleInputResult(.timeout)
                    }
                }
            }
        }
    }

    /// 提交用户输入
    public func submitInput(_ input: String) {
        guard inputContinuation != nil else {
            // 如果没有continuation，可能是等待模式
            if state == .waitingInput {
                process?.handleUserInput(input)
            }
            return
        }

        // 验证输入
        if let request = currentInputRequest {
            switch request.type {
            case .intValue:
                if Int(input) == nil && request.defaultValue == nil {
                    printError("请输入有效的数字")
                    return
                }
            case .strValue:
                break // 任何字符串都有效
            case .enterKey, .anyKey:
                // 这些应该只接受特定按键
                break
            default:
                break
            }
        }

        handleInputResult(.success(input))
    }

    /// 取消当前输入
    public func cancelInput() {
        handleInputResult(.cancelled)
    }

    private func handleInputResult(_ result: InputResult) {
        guard let continuation = inputContinuation else { return }

        // 清理状态
        self.inputContinuation = nil
        self.currentInputRequest = nil
        self.state = .ready

        // 恢复执行
        continuation.resume(returning: result)
    }

    // MARK: - Button/Interactive Elements

    /// 添加可点击按钮
    public func addButton(
        _ text: String,
        value: Int,
        attributes: ConsoleAttributes? = nil,
        action: (() -> Void)? = nil
    ) {
        let attrs = attributes ?? ConsoleAttributes(color: .cyan, isUnderlined: true)

        let line = ConsoleLine(
            type: .button,
            content: text,
            attributes: attrs,
            buttonValue: value,
            buttonAction: action
        )

        addLine(line)
    }

    /// 处理按钮点击
    public func handleButtonTap(_ line: ConsoleLine) {
        guard line.type == .button else { return }

        if let action = line.buttonAction {
            action()
        } else if let value = line.buttonValue {
            // 发送按钮值作为输入
            submitInput(String(value))
        }
    }

    // MARK: - Enhanced Image/Graphic Support

    /// 添加图像
    public func addImage(
        _ imageName: String,
        size: CGSize? = nil,
        caption: String? = nil
    ) {
        let content = caption ?? "[图像: \(imageName)]"
        let line = ConsoleLine(
            type: .image,
            content: content,
            imageReference: imageName,
            imageSize: size
        )
        addLine(line)
    }

    /// 添加进度条
    public func addProgressBar(
        value: Double,
        label: String? = nil,
        attributes: ConsoleAttributes? = nil
    ) {
        let content = label ?? "进度: \(Int(value * 100))%"
        let line = ConsoleLine(
            type: .progressBar,
            content: content,
            attributes: attributes ?? ConsoleAttributes(),
            progressValue: value,
            progressLabel: label
        )
        addLine(line)
    }

    /// 添加表格
    public func addTable(
        headers: [String],
        data: [[String]],
        attributes: ConsoleAttributes? = nil
    ) {
        let line = ConsoleLine(
            type: .table,
            content: headers.joined(separator: " | "),
            attributes: attributes ?? ConsoleAttributes(),
            tableData: data,
            tableHeaders: headers
        )
        addLine(line)
    }

    /// 添加标题
    public func addHeader(
        _ text: String,
        level: Int = 1,
        attributes: ConsoleAttributes? = nil
    ) {
        var attrs = attributes ?? ConsoleAttributes()
        attrs.isBold = true
        attrs.fontSize = attrs.fontSize ?? (18.0 - Double(level) * 2.0)

        let line = ConsoleLine(
            type: .header,
            content: text,
            attributes: attrs
        )
        addLine(line)
    }

    /// 添加引用文本
    public func addQuote(
        _ text: String,
        attributes: ConsoleAttributes? = nil
    ) {
        let attrs = attributes ?? ConsoleAttributes(
            color: .gray,
            isItalic: true
        )

        let line = ConsoleLine(
            type: .quote,
            content: text,
            attributes: attrs
        )
        addLine(line)
    }

    /// 添加代码块
    public func addCode(
        _ code: String,
        language: String? = nil,
        attributes: ConsoleAttributes? = nil
    ) {
        let attrs = attributes ?? ConsoleAttributes(
            backgroundColor: .gray,
            font: .monospace
        )

        let line = ConsoleLine(
            type: .code,
            content: code,
            attributes: attrs,
            codeLanguage: language
        )
        addLine(line)
    }

    /// 添加链接
    public func addLink(
        _ text: String,
        url: String,
        attributes: ConsoleAttributes? = nil,
        action: (() -> Void)? = nil
    ) {
        var attrs = attributes ?? ConsoleAttributes()
        attrs.color = .cyan
        attrs.isUnderlined = true

        let line = ConsoleLine(
            type: .link,
            content: text,
            attributes: attrs,
            buttonAction: action,
            linkURL: url
        )
        addLine(line)
    }

    // MARK: - Image/Graphic Support (Legacy)

    /// 添加图像占位符 (兼容旧代码)
    public func addImageReference(_ imageName: String) {
        addImage(imageName)
    }

    // MARK: - Process Integration

    /// 连接到Process
    public func connect(to process: Process) {
        self.process = process
        printDebug("已连接到Process系统")
    }

    /// 执行脚本
    public func executeScript(_ script: String) async {
        guard state == .ready else {
            printError("控制台忙碌中，当前状态: \(state)")
            return
        }

        state = .running
        printDebug("开始执行脚本...")

        do {
            // 这里需要调用Process来执行脚本
            // 暂时打印提示
            printText("脚本执行功能需要与Process系统集成", attributes: ConsoleAttributes(color: .yellow))
        }

        state = .ready
    }

    // MARK: - Configuration

    /// 更新配置
    public func updateConfig(_ newConfig: ConsoleConfig) {
        self.config = newConfig
    }

    /// 更新状态（供Process使用）
    public func updateState(_ newState: ConsoleState) {
        self.state = newState
    }

    // MARK: - Theme Management

    /// 切换主题
    public func switchTheme(_ theme: ConsoleTheme) {
        self.currentTheme = theme
        printDebug("已切换到主题: \(theme.name)")
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

        printError("未找到主题: \(name)")
        return false
    }

    /// 获取所有可用主题名称
    public func getAvailableThemeNames() -> [String] {
        return [ConsoleTheme.classic, .dark, .light, .highContrast, .cyberpunk, .compact].map { $0.name }
    }

    /// 使用主题样式打印文本
    public func printThemedText(_ text: String, style: TextStyle = .normal) {
        let line = ConsoleLine.themedText(text, theme: currentTheme, style: style)
        addLine(line)
    }

    /// 添加分隔线
    public func addSeparator() {
        let line = ConsoleLine(type: .separator, content: "")
        addLine(line)
    }
}

/// 控制台配置
public struct ConsoleConfig: Hashable {
    public var maxBufferSize: Int
    public var autoScroll: Bool
    public var showTimestamp: Bool
    public var defaultColor: ConsoleColor
    public var errorColor: ConsoleColor
    public var buttonColor: ConsoleColor

    public init(
        maxBufferSize: Int = 1000,
        autoScroll: Bool = true,
        showTimestamp: Bool = false,
        defaultColor: ConsoleColor = .white,
        errorColor: ConsoleColor = .red,
        buttonColor: ConsoleColor = .cyan
    ) {
        self.maxBufferSize = maxBufferSize
        self.autoScroll = autoScroll
        self.showTimestamp = showTimestamp
        self.defaultColor = defaultColor
        self.errorColor = errorColor
        self.buttonColor = buttonColor
    }
}
