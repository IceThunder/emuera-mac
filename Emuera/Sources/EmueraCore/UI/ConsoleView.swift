//
//  ConsoleView.swift
//  EmueraCore
//
//  SwiftUI视图 - 显示控制台内容
//  负责渲染ConsoleLine，处理用户交互
//
//  Created: 2025-12-20
//

import SwiftUI

/// 控制台显示视图
public struct ConsoleView: View {
    @ObservedObject var console: EmueraConsole
    @State private var inputText: String = ""

    public init(console: EmueraConsole) {
        self.console = console
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 显示区域
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(console.lines, id: \.id) { line in
                            ConsoleLineView(line: line) {
                                console.handleButtonTap(line)
                            }
                            .id(line.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: console.scrollToBottom) { _ in
                    if let lastLine = console.lines.last {
                        withAnimation {
                            proxy.scrollTo(lastLine.id, anchor: .bottom)
                        }
                    }
                }
            }

            // 输入区域
            if console.currentInputRequest != nil {
                InputAreaView(
                    inputText: $inputText,
                    request: console.currentInputRequest!,
                    onSubmit: { text in
                        console.submitInput(text)
                        inputText = ""
                    },
                    onCancel: {
                        console.cancelInput()
                        inputText = ""
                    }
                )
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }
}

/// 单行显示视图
struct ConsoleLineView: View {
    let line: ConsoleLine
    let onButtonTap: () -> Void

    var body: some View {
        switch line.type {
        case .text, .print:
            renderTextLine()

        case .error:
            renderErrorLine()

        case .button:
            renderButtonLine()

        case .image:
            renderImageLine()

        case .separator:
            renderSeparatorLine()

        case .progressBar:
            renderProgressBarLine()

        case .table:
            renderTableLine()

        case .header:
            renderHeaderLine()

        case .quote:
            renderQuoteLine()

        case .code:
            renderCodeLine()

        case .link:
            renderLinkLine()
        }
    }

    // MARK: - Render Methods

    private func renderTextLine() -> some View {
        let text = Text(line.content)
            .foregroundColor(colorFromConsole(line.attributes.color))
            .font(createFont())
            .fontWeight(line.attributes.isBold ? .bold : .regular)
            .italic(line.attributes.isItalic)
            .opacity(line.attributes.opacity)

        return applyModifiers(text: text)
            .frame(maxWidth: .infinity, alignment: alignmentFromConsole(line.attributes.alignment))
            .background(backgroundColor())
    }

    private func renderErrorLine() -> some View {
        Text(line.content)
            .foregroundColor(.red)
            .font(.system(.body, design: .monospaced))
            .fontWeight(.bold)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.1))
            .frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(4)
    }

    private func renderButtonLine() -> some View {
        Button(action: onButtonTap) {
            Text(line.content)
                .foregroundColor(colorFromConsole(line.attributes.color))
                .font(createFont())
                .fontWeight(line.attributes.isBold ? .bold : .regular)
                .italic(line.attributes.isItalic)
                .underline(line.attributes.isUnderlined, color: colorFromConsole(line.attributes.color))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func renderImageLine() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let ref = line.imageReference {
                // 实际图像渲染（需要图像系统）
                HStack {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: line.imageSize?.width ?? 60, height: line.imageSize?.height ?? 60)
                        .foregroundColor(.gray)

                    if line.content != "[图像: \(ref)]" {
                        Text(line.content)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(4)
            } else {
                Text(line.content)
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func renderSeparatorLine() -> some View {
        Divider()
            .padding(.vertical, 4)
    }

    private func renderProgressBarLine() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = line.progressLabel {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let value = line.progressValue {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                            .cornerRadius(8)

                        // 进度
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * CGFloat(value), height: 16)
                            .cornerRadius(8)
                    }
                }
                .frame(height: 16)

                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func renderTableLine() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // 表头
            if let headers = line.tableHeaders {
                HStack(spacing: 4) {
                    ForEach(headers, id: \.self) { header in
                        Text(header)
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(2)
                    }
                }
            }

            // 表格数据
            if let data = line.tableData {
                ForEach(data.indices, id: \.self) { rowIndex in
                    HStack(spacing: 4) {
                        ForEach(data[rowIndex], id: \.self) { cell in
                            Text(cell)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(4)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(2)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func renderHeaderLine() -> some View {
        Text(line.content)
            .font(createFont())
            .fontWeight(.bold)
            .foregroundColor(colorFromConsole(line.attributes.color))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: alignmentFromConsole(line.attributes.alignment))
            .background(backgroundColor())
    }

    private func renderQuoteLine() -> some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 3)

            Text(line.content)
                .font(createFont())
                .foregroundColor(colorFromConsole(line.attributes.color))
                .italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor())
    }

    private func renderCodeLine() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let lang = line.codeLanguage {
                Text(lang.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }

            Text(line.content)
                .font(createFont())
                .foregroundColor(colorFromConsole(line.attributes.color))
                .padding(8)
                .background(backgroundColor() ?? Color.gray.opacity(0.1))
                .cornerRadius(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    private func renderLinkLine() -> some View {
        Button(action: {
            if let action = line.buttonAction {
                action()
            } else if let url = line.linkURL {
                // 打开URL
                if let url = URL(string: url) {
                    NSWorkspace.shared.open(url)
                }
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "link")
                    .font(.caption)
                Text(line.content)
                    .font(createFont())
                    .foregroundColor(colorFromConsole(line.attributes.color))
                    .underline(line.attributes.isUnderlined)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.cyan.opacity(0.1))
        .cornerRadius(4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helper Methods

    private func createFont() -> Font {
        let baseSize = line.attributes.fontSize ?? line.attributes.font.size

        if line.attributes.font == .monospace {
            return .system(size: baseSize, design: .monospaced)
        }

        return .system(size: baseSize)
    }

    private func applyModifiers<T: View>(text: T) -> some View {
        var view = AnyView(text)

        // 下划线
        if line.attributes.isUnderlined {
            view = AnyView(view.underline(color: colorFromConsole(line.attributes.color)))
        }

        // 删除线
        if line.attributes.strikethrough {
            let strikeColor = line.attributes.strikethroughColor ?? line.attributes.color
            view = AnyView(view.strikethrough(color: colorFromConsole(strikeColor)))
        }

        // 字符间距
        if let spacing = line.attributes.letterSpacing {
            view = AnyView(view.kerning(spacing))
        }

        return view
    }

    private func backgroundColor() -> Color? {
        guard let bg = line.attributes.backgroundColor else { return nil }
        return colorFromConsole(bg).opacity(0.1)
    }

    private func colorFromConsole(_ consoleColor: ConsoleColor) -> Color {
        switch consoleColor {
        case .default: return Color.primary
        case .black: return .black
        case .white: return .white
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .yellow: return .yellow
        case .cyan: return .cyan
        case .magenta: return .purple
        case .gray: return .gray
        case .custom(let r, let g, let b):
            return Color(red: Double(r)/255.0, green: Double(g)/255.0, blue: Double(b)/255.0)
        }
    }

    private func fontFromConsole(_ consoleFont: ConsoleFont) -> Font {
        switch consoleFont {
        case .default: return .body
        case .small: return .caption
        case .large: return .title3
        case .monospace: return .system(.body, design: .monospaced)
        }
    }

    private func alignmentFromConsole(_ alignment: TextAlignment) -> Alignment {
        switch alignment {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        }
    }
}

/// 输入区域视图
struct InputAreaView: View {
    @Binding var inputText: String
    let request: InputRequest
    let onSubmit: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 提示信息
            if let prompt = request.prompt {
                Text(prompt)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(promptText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                TextField("输入...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !inputText.isEmpty {
                            onSubmit(inputText)
                        } else if let defaultValue = request.defaultValue {
                            onSubmit(defaultValue)
                        }
                    }

                Button("提交") {
                    if !inputText.isEmpty {
                        onSubmit(inputText)
                    } else if let defaultValue = request.defaultValue {
                        onSubmit(defaultValue)
                    }
                }
                .keyboardShortcut(.return, modifiers: [])

                if request.type != .enterKey && request.type != .anyKey {
                    Button("取消") {
                        onCancel()
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var promptText: String {
        switch request.type {
        case .enterKey: return "按回车键继续..."
        case .anyKey: return "按任意键继续..."
        case .intValue: return "请输入数字:"
        case .strValue: return "请输入文本:"
        case .void: return "等待..."
        case .primitiveMouseKey: return "等待输入..."
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        let console = EmueraConsole()

        // 添加测试数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            console.addLine(ConsoleLine(type: .text, content: "欢迎使用Emuera！"))
            console.addLine(ConsoleLine(type: .print, content: "这是PRINT输出"))
            console.addLine(ConsoleLine(type: .error, content: "❌ 错误示例"))
            console.addButton("点击这里", value: 1) {
                print("按钮被点击")
            }
            console.addLine(ConsoleLine(type: .separator, content: ""))
            console.addImageReference("test_image")
        }

        return ConsoleView(console: console)
            .frame(width: 600, height: 400)
    }
}
#endif
