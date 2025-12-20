//
//  MainWindow.swift
//  EmueraCore
//
//  主窗口控制器 - 管理应用窗口、菜单、工具栏
//  相当于C# Emuera中的MainWindow类
//
//  Created: 2025-12-20
//

import SwiftUI
import AppKit

/// 主窗口视图
public struct MainWindow: View {
    @StateObject private var console: EmueraConsole
    @StateObject private var processManager: ProcessManager
    @State private var showPreferences: Bool = false
    @State private var showDebugPanel: Bool = false
    @State private var selectedFile: String = ""

    public init() {
        let console = EmueraConsole()
        let processManager = ProcessManager(console: console)
        self._console = StateObject(wrappedValue: console)
        self._processManager = StateObject(wrappedValue: processManager)
    }

    public var body: some View {
        NavigationView {
            // 左侧边栏（可选的文件浏览器）
            SidebarView(
                processManager: processManager,
                selectedFile: $selectedFile
            )
            .frame(minWidth: 200, idealWidth: 250)

            // 主内容区
            VStack(spacing: 0) {
                // 工具栏
                ToolbarView(
                    onRun: runScript,
                    onOpen: openFile,
                    onClear: clearConsole,
                    onDebug: { showDebugPanel.toggle() },
                    onPreferences: { showPreferences.toggle() }
                )

                // 控制台显示
                ConsoleView(console: console)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 状态栏
                StatusBarView(
                    state: console.state,
                    lineCount: console.lineCount,
                    processStatus: processManager.status
                )
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .navigationTitle("Emuera for macOS")
    }

    // MARK: - Actions

    private func runScript() {
        Task {
            if selectedFile.isEmpty {
                // 运行测试脚本
                await processManager.runTestScript()
            } else {
                // 运行选中的文件
                await processManager.runFile(selectedFile)
            }
        }
    }

    private func openFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.init(filenameExtension: "erb")!]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        if openPanel.runModal() == .OK, let url = openPanel.url {
            selectedFile = url.path
            console.printDebug("已选择文件: \(url.lastPathComponent)")
        }
    }

    private func clearConsole() {
        console.clear()
        console.printDebug("控制台已清空")
    }
}

/// 侧边栏视图
struct SidebarView: View {
    @ObservedObject var processManager: ProcessManager
    @Binding var selectedFile: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("文件")
                .font(.headline)
                .padding(.horizontal)

            // 文件列表
            List(processManager.recentFiles, id: \.self, selection: $selectedFile) { file in
                Text(URL(fileURLWithPath: file).lastPathComponent)
                    .tag(file)
            }
            .listStyle(SidebarListStyle())

            // 快速操作
            VStack(alignment: .leading, spacing: 8) {
                Button("运行测试脚本") {
                    Task {
                        await processManager.runTestScript()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("打开示例") {
                    // 打开示例目录
                    if let examples = processManager.getExampleDirectory() {
                        NSWorkspace.shared.open(examples)
                    }
                }
            }
            .padding()
        }
    }
}

/// 工具栏视图
struct ToolbarView: View {
    let onRun: () -> Void
    let onOpen: () -> Void
    let onClear: () -> Void
    let onDebug: () -> Void
    let onPreferences: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onRun) {
                Image(systemName: "play.fill")
                    .foregroundColor(.green)
            }
            .help("运行")

            Button(action: onOpen) {
                Image(systemName: "folder.fill")
            }
            .help("打开文件")

            Divider()

            Button(action: onClear) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
            }
            .help("清空")

            Spacer()

            Button(action: onDebug) {
                Image(systemName: "ladybug.fill")
            }
            .help("调试")

            Button(action: onPreferences) {
                Image(systemName: "gear")
            }
            .help("设置")
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

/// 状态栏视图
struct StatusBarView: View {
    let state: ConsoleState
    let lineCount: Int
    let processStatus: String

    var body: some View {
        HStack(spacing: 16) {
            // 状态
            HStack(spacing: 4) {
                Circle()
                    .fill(stateColor)
                    .frame(width: 8, height: 8)
                Text(stateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider().frame(height: 12)

            // 行数
            Text("行数: \(lineCount)")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider().frame(height: 12)

            // Process状态
            Text(processStatus)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var stateColor: Color {
        switch state {
        case .ready: return .green
        case .running: return .blue
        case .waitingInput: return .orange
        case .sleeping: return .yellow
        case .paused: return .purple
        case .error: return .red
        case .quit: return .gray
        }
    }

    private var stateText: String {
        switch state {
        case .ready: return "就绪"
        case .running: return "运行中"
        case .waitingInput: return "等待输入"
        case .sleeping: return "睡眠"
        case .paused: return "暂停"
        case .error: return "错误"
        case .quit: return "已退出"
        }
    }
}

/// 偏好设置视图
struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView {
            // 显示设置
            VStack(alignment: .leading, spacing: 16) {
                Text("显示设置")
                    .font(.title2)
                    .bold()

                Toggle("自动滚动", isOn: .constant(true))
                Toggle("显示时间戳", isOn: .constant(false))

                Spacer()
            }
            .padding()
            .tabItem { Label("显示", systemImage: "display") }

            // 编码设置
            VStack(alignment: .leading, spacing: 16) {
                Text("编码设置")
                    .font(.title2)
                    .bold()

                Picker("文件编码", selection: .constant(0)) {
                    Text("UTF-8").tag(0)
                    Text("Shift-JIS").tag(1)
                }
                .pickerStyle(RadioGroupPickerStyle())

                Spacer()
            }
            .padding()
            .tabItem { Label("编码", systemImage: "text.badge.plus") }

            // 快捷键
            VStack(alignment: .leading, spacing: 16) {
                Text("快捷键")
                    .font(.title2)
                    .bold()

                Text("Cmd+R - 运行脚本")
                Text("Cmd+O - 打开文件")
                Text("Cmd+, - 设置")
                Text("Cmd+W - 关闭窗口")

                Spacer()
            }
            .padding()
            .tabItem { Label("快捷键", systemImage: "keyboard") }
        }
        .frame(minWidth: 500, minHeight: 300)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }
            }
        }
    }
}

/// 调试面板视图
struct DebugPanelView: View {
    @ObservedObject var console: EmueraConsole
    @ObservedObject var processManager: ProcessManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("调试面板")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("关闭") { dismiss() }
            }

            Divider()

            // 调试信息
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    // 控制台状态
                    GroupBox(label: Text("控制台状态")) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("状态: \(String(describing: console.state))")
                            Text("行数: \(console.lineCount)")
                            if let request = console.currentInputRequest {
                                Text("输入请求: \(String(describing: request.type))")
                            }
                        }
                        .font(.system(.body, design: .monospaced))
                        .padding(4)
                    }

                    // Process状态
                    GroupBox(label: Text("Process状态")) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("状态: \(processManager.status)")
                            Text("调用栈深度: \(processManager.callStackDepth)")
                        }
                        .font(.system(.body, design: .monospaced))
                        .padding(4)
                    }

                    // 操作按钮
                    GroupBox(label: Text("操作")) {
                        HStack(spacing: 8) {
                            Button("打印状态") {
                                console.printDebug("状态: \(console.state)")
                            }
                            Button("强制清空") {
                                console.clear()
                            }
                            Button("运行测试") {
                                Task {
                                    await processManager.runTestScript()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - ProcessManager (UI集成)

/// Process管理器（UI层）
public final class ProcessManager: ObservableObject {
    @Published public var status: String = "就绪"
    @Published public var callStackDepth: Int = 0
    @Published public var recentFiles: [String] = []

    private weak var console: EmueraConsole?
    private var process: Process?

    public init(console: EmueraConsole) {
        self.console = console
        // 创建Process需要的依赖
        let varData = VariableData()
        let tokenData = TokenData(varData: varData)
        let labelDictionary = LabelDictionary()
        self.process = Process(tokenData: tokenData, labelDictionary: labelDictionary)
        // 将console与process关联
        self.process?.setConsole(console)
        self.recentFiles = loadRecentFiles()
    }

    /// 运行测试脚本
    public func runTestScript() async {
        status = "运行测试脚本..."
        console?.printDebug("开始运行测试脚本")

        let testScript = """
        PRINTL 测试开始...
        A = 100
        PRINT A的值是
        PRINT A
        PRINTL
        B = A + 50
        PRINT B =
        PRINT B
        PRINTL
        PRINTL 测试完成！
        """

        do {
            try await process?.runScript(testScript)
            status = "测试完成"
            console?.printDebug("测试脚本执行完毕")
        } catch {
            status = "错误: \(error)"
            console?.printError("测试脚本执行失败: \(error)")
        }
    }

    /// 运行文件
    public func runFile(_ path: String) async {
        status = "运行: \(URL(fileURLWithPath: path).lastPathComponent)"
        console?.printDebug("开始运行文件: \(path)")

        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            try await process?.runScript(content)
            status = "执行完成"
            addToRecentFiles(path)
        } catch {
            status = "错误: \(error)"
            console?.printError("文件执行失败: \(error)")
        }
    }

    /// 获取示例目录
    public func getExampleDirectory() -> URL? {
        // 返回应用内的示例目录
        let fileManager = FileManager.default
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let examplesDir = appSupport.appendingPathComponent("Emuera/Examples")
            try? fileManager.createDirectory(at: examplesDir, withIntermediateDirectories: true)
            return examplesDir
        }
        return nil
    }

    private func loadRecentFiles() -> [String] {
        // 从UserDefaults加载最近文件
        return UserDefaults.standard.stringArray(forKey: "RecentFiles") ?? []
    }

    private func addToRecentFiles(_ path: String) {
        var files = recentFiles
        if let index = files.firstIndex(of: path) {
            files.remove(at: index)
        }
        files.insert(path, at: 0)
        if files.count > 10 {
            files.removeLast()
        }
        recentFiles = files
        UserDefaults.standard.set(files, forKey: "RecentFiles")
    }
}

// MARK: - Process Extension for UI

extension Process {
    /// 运行脚本（异步版本）- 简化实现
    public func runScript(_ script: String) async throws {
        // 使用Task在后台执行
        try await Task.detached(priority: .userInitiated) {
            // 这里需要调用实际的Process执行逻辑
            // 暂时模拟执行
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒延迟
        }.value
    }
}
