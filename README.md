# Emuera for macOS 🔥

**将Windows的Emuera游戏引擎完整移植到macOS的原生Swift实现**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://developer.apple.com/macos)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)
[![Project](https://img.shields.io/badge/状态-开发中-yellow.svg)](PROJECT_SUMMARY.md)

---

## 🎯 项目概述

本项目基于Windows平台的[Emuera](https://ux.getuploader.com/ninnohito/)引擎，将其完整移植到macOS原生平台，使用Swift语言重写，目标是提供与原版完全兼容的ERB脚本运行环境。

### 核心目标
- ✅ **完整脚本兼容**: 支持所有原版ERB/ERH脚本语法
- ✅ **原生macOS体验**: 高速、流畅、美观的原生界面
- ✅ **高性能渲染**: 替换GDI为Core Graphics加速
- ✅ **开发者友好**: 完善的文档和调试工具

---

## 📊 项目状态 (2025-12-18)

| 阶段 | 完成度 | 状态 |
|------|--------|-------|
| **需求分析** | ✅ 100% | 完成 |
| **架构设计** | ✅ 100% | 完成 |
| **项目骨架** | ✅ 100% | 完成 |
| **核心实现** | 🟡 5% | 进行中 |
| **UI开发** | 🔴 0% | 待开始 |
| **测试验证** | 🔴 0% | 待开始 |

**已提交**: 初始项目结构和基础类库 (commit `cc8ded3`)

---

## 🏗️ 技术架构

### 核心分层设计
```
┌─────────────────────────────────────────┐
│  macOS App (AppKit) - 用户界面层        │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│  │ 主窗口  │ │ 对话框  │ │ 菜单    │  │
│  └─────────┘ └─────────┘ └─────────┘  │
├─────────────────────────────────────────┤
│  核心引擎 (Swift Package)               │
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│  │ 解析器  │ │ 变量    │ │ 执行器  │  │
│  └─────────┘ └─────────┘ └─────────┘  │
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│  │ 文件    │ │ 日志    │ │ 错误    │  │
│  └─────────┘ └─────────┘ └─────────┘  │
└─────────────────────────────────────────┘
```

### 主要技术替换对照

| Windows组件 | macOS替代 | 当前状态 |
|-------------|-----------|----------|
| `System.Windows.Forms` | `AppKit` | 待实现 |
| `GDI32.dll` | `Core Graphics` | 待实现 |
| `WinmmTimer` | `DispatchSourceTimer` | 待实现 |
| `GetKeyState` | `NSEvent` | 待实现 |

---

## 📁 已创建项目结构

### 代码目录 (`/Emuera/`)
```
Emuera/
├── Package.swift                 # SwiftPM构建配置
├── Sources/
│   ├── EmueraCore/              # 核心引擎库
│   │   ├── Common/             # 基础工具
│   │   │   ├── Config.swift     ✅ 配置管理
│   │   │   ├── Logger.swift     ✅ 日志系统
│   │   │   └── EmueraError.swift✅ 错误类型
│   │   ├── Variable/            # 变量系统
│   │   │   ├── VariableData.swift✅ 数据存储
│   │   │   └── VariableType.swift✅ 类型定义
│   │   ├── Parser/              # 解析器框架
│   │   │   └── TokenType.swift  ✅ Token定义
│   │   ├── EmueraCore.swift     ✅ 模块入口
│   │   └── Executor/            # 待实现
│   └── EmueraApp/               # macOS应用
│       └── main.swift           ✅ 测试入口
├── Tests/                        # 测试目录
└── Resources/                    # 资源目录
```

### 文档目录 (`/`)
```
EmueraJs/
├── PROJECT_SUMMARY.md  ✅ 完整项目报告 (建议先读这个)
├── DEVELOPMENT_PLAN.md ✅ 详细开发计划
├── QUICKSTART.md     ✅ 快速开始指南
├── STATUS.md         ✅ 实时状态看板
├── README.md         ✅ 本文件
└── .git/             ✅ Git仓库已初始化
```

---

## 🚀 立即开始

### 1. 环境要求
- **macOS**: 13.0+ (Sonoma)
- **Swift**: 5.9+
- **Xcode**: 15.0+ (推荐)

### 2. 克隆和启动
```bash
# 克隆仓库
git clone git@github.com:IceThunder/emuera-mac.git
cd emuera-mac/Emuera

# 构建项目
swift build

# 运行测试 (验证环境)
swift test

# 启动应用 (当前为测试模式)
swift run emuera
```

### 3. 预期输出
```
🚀 Emuera for macOS - Development Build
Version: 1.820 (Core: 1.0.0)
🧪 Testing core engine components...
✓ Variable system: PASS
✓ Array operations: PASS
✓ Character data: PASS
✓ Logger system: PASS
🎉 All core tests passed!
```

---

## 📋 下一步开发任务

### 🔴 紧急 (本周)
1. **LexicalAnalyzer.swift** - 词法分析器解析ERB脚本
2. **ExpressionParser.swift** - 表达式和公式计算
3. **ScriptParser.swift** - 完整语法解析

### 🟡 重要 (下周)
4. **Command.swift** - 实现PRINT/INPUT等基础命令
5. **Process.swift** - 执行流管理
6. **MainWindow.swift** - macOS主窗口UI

### 🟢 完善 (后续)
7. 命令实现完备化 (50+命令)
8. 图形渲染支持
9. CSV文件处理
10. 完整游戏测试

---

## 🔧 快速开发指引

### 在Xcode中打开
```bash
# 生成Xcode项目
swift package generate-xcodeproject
open Emuera.xcodeproj
```

### 开发工作流
1. **认领任务**: 从 `STATUS.md` 选择模块
2. **创建分支**: `git checkout -b feature/新模块`
3. **编写代码**: 添加Swift文件
4. **添加测试**: 在 `Tests/` 目录
5. **提交**: `git commit -m "feat: 添加新模块"`

### 代码风格
```swift
// ✅ 推荐写法
public enum EmueraError: Error {
    case invalidSyntax(message: String)
}

// ❌ 不推荐
var err: String = "error"
```

---

## 🤝 贡献指南

### 如何贡献
1. 阅读 `PROJECT_SUMMARY.md` 了解完整背景
2. 查看 `DEVELOPMENT_PLAN.md` 了解详细计划
3. 在 `STATUS.md` 中认领任务
4. 提交Pull Request

### 开发讨论
- **提交Issue**: 报告Bug或建议新功能
- **Pull Request**: 代码审查后合并
- **讨论区**: GitHub Discussions

---

## 🎯 项目指标

| 指标 | 数值 |
|------|------|
| 总代码行数 | ~2,300 (截至目前) |
| 文件数量 | 15 |
| 预计总行数 | 15,000-20,000 |
| 预计完成时间 | 4-6周 |
| 核心复杂度 | 高 |

---

## 📚 资源链接

- **原版Emuera**: [Emuera原版代码](https://ux.getuploader.com/ninnohito/)
- **完整项目报告**: [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)
- **详细开发计划**: [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md)
- **快速开始**: [QUICKSTART.md](./QUICKSTART.md)
- **当前状态**: [STATUS.md](./STATUS.md)

---

## 🏁 项目宣言

> "我们不只是移植代码，我们是在为macOS平台重新构建一个现代化的、高性能的、完整的Emuera引擎。
> 每一行Swift代码都是对原版项目的致敬，同时也是对未来可能性的探索。"

**项目启动**: 2025年12月18日
**预计首个Beta**: 2026年1月
**开发者**: IceThunder + AI辅助
**许可证**: 与原版Emuera保持一致

---

*本README与 PROJECT_SUMMARY.md 保持同步更新，后者包含更详细的信息*