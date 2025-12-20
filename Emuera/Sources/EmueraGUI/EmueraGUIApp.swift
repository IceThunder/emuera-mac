//
//  EmueraGUIApp.swift
//  EmueraApp
//
//  GUI应用入口点
//  使用: swift run EmueraApp --gui 或直接运行这个文件
//
//  Created: 2025-12-20
//

import SwiftUI
import EmueraCore

@main
struct EmueraGUIApp: App {
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("打开...") {
                    // 通过MainWindow处理
                }
                .keyboardShortcut("o", modifiers: .command)

                Button("运行测试") {
                    // 通过MainWindow处理
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            CommandGroup(replacing: .help) {
                Link("项目文档", destination: URL(string: "https://github.com/IceThunder/emuera-mac")!)
                Button("关于 Emuera") {
                    // 显示关于对话框
                }
            }
        }
    }
}
