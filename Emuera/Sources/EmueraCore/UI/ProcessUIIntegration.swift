//
//  ProcessUIIntegration.swift
//  EmueraCore
//
//  Process系统与UI的集成层
//  负责将Process的输出重定向到EmueraConsole
//  处理WAIT/INPUT等交互命令
//
//  Created: 2025-12-20
//

import Foundation

// MARK: - Process UI Extension

extension Process {
    /// 关联的控制台（弱引用避免循环引用）
    private struct ConsoleWrapper {
        weak var console: EmueraConsole?
    }

    private static var consoleKey: UInt8 = 0

    /// 设置控制台输出目标
    public func setConsole(_ console: EmueraConsole) {
        objc_setAssociatedObject(self, &Self.consoleKey, ConsoleWrapper(console: console), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// 获取关联的控制台
    public func getConsole() -> EmueraConsole? {
        let wrapper = objc_getAssociatedObject(self, &Self.consoleKey) as? ConsoleWrapper
        return wrapper?.console
    }

    /// 重定向输出到控制台
    public func redirectOutputToConsole() {
        // 这里可以重定向print语句
        // 在Swift中，我们可以使用自定义的输出函数
    }

    /// 处理PRINT命令输出
    public func printToConsole(_ text: String, newLine: Bool = true) {
        guard let console = getConsole() else { return }

        // 在主线程更新UI
        DispatchQueue.main.async {
            console.printText(text, newLine: newLine)
        }
    }

    /// 处理PRINTL命令输出
    public func printLineToConsole(_ text: String) {
        printToConsole(text, newLine: true)
    }

    /// 处理错误输出
    public func printErrorToConsole(_ message: String, position: ScriptPosition? = nil) {
        guard let console = getConsole() else { return }

        DispatchQueue.main.async {
            console.printError(message, position: position)
        }
    }

    /// 处理调试输出
    public func printDebugToConsole(_ message: String) {
        guard let console = getConsole() else { return }

        DispatchQueue.main.async {
            console.printDebug(message)
        }
    }

    /// 处理WAIT命令
    public func waitForUserInput() async -> Bool {
        guard let console = getConsole() else { return false }

        let request = InputRequest(
            type: .enterKey,
            prompt: "按回车键继续..."
        )

        let result = await console.waitForInput(request: request)

        switch result {
        case .success:
            return true
        case .timeout, .cancelled, .error:
            return false
        }
    }

    /// 处理WAIT命令（任意键）
    public func waitForAnyKey() async -> Bool {
        guard let console = getConsole() else { return false }

        let request = InputRequest(
            type: .anyKey,
            prompt: "按任意键继续..."
        )

        let result = await console.waitForInput(request: request)

        switch result {
        case .success:
            return true
        case .timeout, .cancelled, .error:
            return false
        }
    }

    /// 处理INPUT命令（整数输入）
    public func inputInt(prompt: String? = nil, defaultValue: Int? = nil) async -> Int? {
        guard let console = getConsole() else { return nil }

        let defaultValueStr = defaultValue != nil ? String(defaultValue!) : nil
        let request = InputRequest(
            type: .intValue,
            oneInput: false,
            timeLimit: nil,
            defaultValue: defaultValueStr,
            prompt: prompt ?? "请输入数字:"
        )

        let result = await console.waitForInput(request: request)

        switch result {
        case .success(let value):
            return Int(value) ?? defaultValue
        case .timeout, .cancelled, .error:
            return defaultValue
        }
    }

    /// 处理INPUTS命令（字符串输入）
    public func inputString(prompt: String? = nil, defaultValue: String? = nil) async -> String? {
        guard let console = getConsole() else { return nil }

        let request = InputRequest(
            type: .strValue,
            oneInput: false,
            timeLimit: nil,
            defaultValue: defaultValue,
            prompt: prompt ?? "请输入文本:"
        )

        let result = await console.waitForInput(request: request)

        switch result {
        case .success(let value):
            return value
        case .timeout, .cancelled, .error:
            return defaultValue
        }
    }

    /// 处理按钮点击
    public func handleUserInput(_ input: String) {
        // 这里需要将输入传递给当前正在执行的脚本
        // 通过状态机或回调机制
        printDebugToConsole("用户输入: \(input)")
    }

    /// 添加按钮到控制台
    public func addButtonToConsole(_ text: String, value: Int, action: (() -> Void)? = nil) {
        guard let console = getConsole() else { return }

        DispatchQueue.main.async {
            console.addButton(text, value: value, action: action)
        }
    }

    /// 添加图像到控制台
    public func addImageToConsole(_ imageName: String) {
        guard let console = getConsole() else { return }

        DispatchQueue.main.async {
            console.addImageReference(imageName)
        }
    }

    /// 清空控制台
    public func clearConsole() {
        guard let console = getConsole() else { return }

        DispatchQueue.main.async {
            console.clear()
        }
    }

    /// 更新控制台状态
    public func updateConsoleState(_ state: ConsoleState) {
        guard let console = getConsole() else { return }

        DispatchQueue.main.async {
            // 通过方法更新状态，避免直接访问私有属性
            console.updateState(state)
        }
    }
}
