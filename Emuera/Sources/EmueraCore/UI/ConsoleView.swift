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
            Text(line.content)
                .foregroundColor(colorFromConsole(line.attributes.color))
                .font(fontFromConsole(line.attributes.font))
                .fontWeight(line.attributes.isBold ? .bold : .regular)
                .italic(line.attributes.isItalic)
                .underline(line.attributes.isUnderlined, color: colorFromConsole(line.attributes.color))
                .frame(maxWidth: .infinity, alignment: alignmentFromConsole(line.attributes.alignment))

        case .error:
            Text(line.content)
                .foregroundColor(.red)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .padding(.vertical, 2)
                .background(Color.red.opacity(0.1))
                .frame(maxWidth: .infinity, alignment: .leading)

        case .button:
            Button(action: onButtonTap) {
                Text(line.content)
                    .foregroundColor(colorFromConsole(line.attributes.color))
                    .underline(line.attributes.isUnderlined)
                    .font(fontFromConsole(line.attributes.font))
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity, alignment: .leading)

        case .image:
            HStack {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                Text(line.content)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.05))

        case .separator:
            Divider()
                .padding(.vertical, 4)
        }
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
