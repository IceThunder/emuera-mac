//
//  Launcher.swift
//  EmueraCore
//
//  游戏启动器 - 相当于Windows版的Program.cs启动逻辑
//  负责自动检测游戏结构、加载配置和启动游戏
//
//  Created: 2025-12-20
//

import Foundation

/// 游戏启动器
public final class Launcher {

    // MARK: - 启动模式

    /// 启动模式
    public enum LaunchMode {
        case interactive          // 交互式控制台
        case auto                 // 自动模式（检测游戏结构）
        case runScript(String)    // 运行指定脚本
        case analysis([String])   // 分析模式（指定文件列表）
        case gui                  // GUI模式
    }

    // MARK: - 启动状态

    /// 启动状态
    public enum LaunchState {
        case ready
        case checkingDirectories
        case loadingConfig
        case loadingGameBase
        case loadingScripts
        case running
        case error(String)
        case success
    }

    // MARK: - 属性

    private let fileManager: FileManager
    private var currentState: LaunchState = .ready

    public init() {
        self.fileManager = FileManager.default
    }

    // MARK: - 主要启动方法

    /// 启动游戏
    /// - Parameter mode: 启动模式
    /// - Returns: 是否启动成功
    public func launch(mode: LaunchMode) -> Bool {
        print("🚀 Emuera 启动器 v1.0")
        print("=" * 50)

        switch mode {
        case .interactive:
            return launchInteractive()

        case .auto:
            return launchAuto()

        case .runScript(let scriptPath):
            return launchScript(scriptPath)

        case .analysis(let files):
            return launchAnalysis(files)

        case .gui:
            return launchGUI()
        }
    }

    // MARK: - 交互式模式

    /// 启动交互式控制台
    private func launchInteractive() -> Bool {
        print("模式: 交互式控制台")
        print("提示: 输入脚本路径或使用内置命令")
        print("")

        // 检查目录结构
        if !checkDirectories() {
            print("⚠️  目录结构不完整，但可以继续运行")
        }

        // 加载配置
        _ = Config.shared.loadConfig()

        // 创建控制台并运行（使用现有的ScriptEngine）
        print("ℹ️  交互式模式使用原有的ConsoleApp实现")
        print("    请直接运行 emuera 命令进入交互模式")
        return true
    }

    // MARK: - 自动模式

    /// 自动模式 - 检测游戏结构并启动
    /// 这是Windows版的核心功能：exe放在游戏根目录即可运行
    private func launchAuto() -> Bool {
        print("模式: 自动游戏检测")
        print("")

        // 1. 检查目录结构
        updateState(.checkingDirectories)
        if !checkDirectories() {
            // 如果目录不存在，尝试创建
            if !createDirectories() {
                updateState(.error("无法创建必需目录结构"))
                return false
            }
        }

        // 2. 加载配置
        updateState(.loadingConfig)
        _ = Config.shared.loadConfig()
        // 配置加载失败也继续，使用默认配置

        // 3. 加载GAMEBASE.CSV
        updateState(.loadingGameBase)
        let gameBase = loadGameBase()
        if gameBase.isValid {
            print("📊 游戏信息:")
            print("  标题: \(gameBase.scriptTitle)")
            print("  作者: \(gameBase.scriptAuthorName)")
            print("  版本: \(gameBase.scriptVersionText)")
            if let windowTitle = gameBase.scriptWindowTitle {
                print("  窗口标题: \(windowTitle)")
            }
            print("")
        } else {
            print("ℹ️  未找到GAMEBASE.CSV，使用默认设置")
        }

        // 4. 加载ERB脚本
        updateState(.loadingScripts)
        let erbLoader = ErbLoader()
        let labelDictionary = LabelDictionary()

        guard let erbFiles = Config.shared.getFiles(in: Sys.erbDir, pattern: "*.ERB") else {
            updateState(.error("无法扫描ERB目录: \(Sys.erbDir)"))
            return false
        }

        if erbFiles.isEmpty {
            updateState(.error("未找到ERB文件，请确保erb/目录中有脚本文件"))
            return false
        }

        print("📄 发现 \(erbFiles.count) 个ERB文件")

        // 收集ERB文件完整路径
        var erbFilePaths: [String] = []
        for (_, fullPath) in erbFiles {
            erbFilePaths.append(fullPath)
        }

        // 使用ErbLoader扫描文件（显示报告）
        if !erbLoader.loadErbFiles(Sys.erbDir, displayReport: Config.shared.displayReport, labelDictionary: labelDictionary) {
            updateState(.error("ERB脚本扫描失败"))
            return false
        }

        // 5. 创建存档目录
        Config.shared.createSaveDirectory()

        // 6. 启动游戏引擎
        updateState(.running)
        print("✅ 游戏加载完成，启动引擎...")
        print("")

        // 创建并运行游戏引擎（传递ERB文件列表）
        let engine = EmueraEngine(
            gameBase: gameBase,
            labelDictionary: labelDictionary,
            erbFiles: erbFilePaths
        )
        return engine.run()
    }

    // MARK: - 脚本运行模式

    /// 运行指定脚本文件
    private func launchScript(_ scriptPath: String) -> Bool {
        print("模式: 运行脚本")
        print("脚本: \(scriptPath)")
        print("")

        // 检查文件是否存在
        guard fileManager.fileExists(atPath: scriptPath) else {
            print("❌ 找不到脚本文件: \(scriptPath)")
            return false
        }

        // 检查目录结构（可选）
        _ = checkDirectories()

        // 加载配置
        _ = Config.shared.loadConfig()

        // 加载GAMEBASE.CSV
        let gameBase = loadGameBase()

        // 加载指定脚本
        let erbLoader = ErbLoader()
        let labelDictionary = LabelDictionary()

        if !erbLoader.loadErbs([scriptPath], labelDictionary: labelDictionary) {
            print("❌ 脚本加载失败")
            return false
        }

        // 创建并运行引擎
        let engine = EmueraEngine(
            gameBase: gameBase,
            labelDictionary: labelDictionary,
            erbFiles: [scriptPath]
        )
        return engine.run()
    }

    // MARK: - 分析模式

    /// 分析模式 - 检查脚本语法
    private func launchAnalysis(_ files: [String]) -> Bool {
        print("模式: 脚本分析")
        print("")

        // 检查目录结构
        _ = checkDirectories()

        // 加载配置
        _ = Config.shared.loadConfig()

        // 加载脚本
        let erbLoader = ErbLoader()
        let labelDictionary = LabelDictionary()

        if !erbLoader.loadErbs(files, labelDictionary: labelDictionary) {
            print("❌ 分析失败")
            return false
        }

        print("✅ 分析完成，未发现严重错误")
        return true
    }

    // MARK: - GUI模式

    /// 启动GUI应用
    private func launchGUI() -> Bool {
        print("模式: GUI应用")
        print("")

        // 检查是否在macOS上运行
        #if os(macOS)
        print("⚠️  GUI模式需要在AppKit环境下运行")
        print("请使用: swift run EmueraGUI")
        return false
        #else
        print("❌ GUI模式仅支持macOS")
        return false
        #endif
    }

    // MARK: - 目录检查和创建

    /// 检查必需目录是否存在
    /// - Returns: 是否所有目录都存在
    private func checkDirectories() -> Bool {
        let (exists, missing) = Sys.checkRequiredDirectories()

        if !exists {
            print("❌ 缺少必需目录:")
            for dir in missing {
                print("  - \(dir)")
            }
            print("")
            print("提示: 运行程序会自动创建这些目录，或手动创建:")
            print("  mkdir -p \(Sys.csvDir)")
            print("  mkdir -p \(Sys.erbDir)")
            print("")
            return false
        }

        print("✅ 目录结构完整")
        return true
    }

    /// 创建必需目录
    private func createDirectories() -> Bool {
        do {
            try Sys.createRequiredDirectories()
            print("✅ 已创建必需目录结构")
            return true
        } catch {
            print("❌ 无法创建目录: \(error)")
            return false
        }
    }

    // MARK: - GAMEBASE.CSV加载

    /// 加载GAMEBASE.CSV
    private func loadGameBase() -> GameBaseData {
        let loader = GameBaseLoader()

        if let gameBase = loader.loadGameBase() {
            return gameBase
        }

        return GameBaseData() // 返回默认数据
    }

    // MARK: - 状态管理

    /// 更新启动状态
    private func updateState(_ state: LaunchState) {
        currentState = state

        switch state {
        case .ready:
            break
        case .checkingDirectories:
            print("📁 检查目录结构...")
        case .loadingConfig:
            print("⚙️  加载配置...")
        case .loadingGameBase:
            print("📊 加载游戏信息...")
        case .loadingScripts:
            print("📄 加载脚本...")
        case .running:
            print("🎮 启动游戏引擎...")
        case .error(let message):
            print("❌ 错误: \(message)")
        case .success:
            print("✅ 启动成功")
        }
    }
}

// MARK: - EmueraEngine (完整执行引擎)

/// Emuera游戏引擎 - 集成完整的执行系统
public final class EmueraEngine {

    private let gameBase: GameBaseData
    private let labelDictionary: LabelDictionary
    private let erbFiles: [String]  // 需要执行的ERB文件列表

    public init(gameBase: GameBaseData, labelDictionary: LabelDictionary, erbFiles: [String] = []) {
        self.gameBase = gameBase
        self.labelDictionary = labelDictionary
        self.erbFiles = erbFiles
    }

    /// 运行游戏
    public func run() -> Bool {
        print("🎮 游戏引擎启动")
        print("  游戏标题: \(gameBase.scriptTitle.isEmpty ? "未命名" : gameBase.scriptTitle)")

        // 显示游戏信息
        if !gameBase.scriptTitle.isEmpty {
            print("")
            print("=" * 50)
            print("  \(gameBase.scriptTitle)")
            if !gameBase.scriptAuthorName.isEmpty {
                print("  作者: \(gameBase.scriptAuthorName)")
            }
            if !gameBase.scriptVersionText.isEmpty {
                print("  版本: \(gameBase.scriptVersionText)")
            }
            print("=" * 50)
            print("")
        }

        // 如果没有ERB文件，提示用户
        if erbFiles.isEmpty {
            print("⚠️  没有可执行的ERB脚本")
            print("    请确保erb/目录中有脚本文件")
            return false
        }

        // 执行脚本
        return executeScripts()
    }

    /// 执行所有ERB脚本
    private func executeScripts() -> Bool {
        print("🔄 开始执行脚本...")
        print("")

        // 1. 解析所有ERB文件，构建完整的语句列表
        var allStatements: [StatementNode] = []

        for file in erbFiles {
            do {
                // 读取文件内容
                let content = try readErbFile(file)

                // 解析为语句
                let parser = ScriptParser()
                let statements = try parser.parse(content)

                allStatements.append(contentsOf: statements)

                print("✅ 已解析: \(URL(fileURLWithPath: file).lastPathComponent) (\(statements.count) 条语句)")
            } catch {
                print("❌ 解析失败 \(URL(fileURLWithPath: file).lastPathComponent): \(error)")
                return false
            }
        }

        print("")
        print("📊 总计: \(allStatements.count) 条语句")
        print("")

        // 2. 使用StatementExecutor执行语句
        let executor = StatementExecutor()
        let outputs = executor.execute(allStatements)

        // 3. 显示输出
        if !outputs.isEmpty {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("🎮 游戏输出:")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            for output in outputs {
                print(output, terminator: "")
            }
            print("")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }

        print("")
        print("✅ 脚本执行完成")
        return true
    }

    /// 读取ERB文件内容（支持多种编码）
    private func readErbFile(_ path: String) throws -> String {
        // 尝试UTF-8
        if let content = try? String(contentsOfFile: path, encoding: .utf8) {
            return content
        }

        // 尝试Shift-JIS
        if let content = try? String(contentsOfFile: path, encoding: .shiftJIS) {
            return content
        }

        throw EmueraError.fileNotFoundError(path: path)
    }
}