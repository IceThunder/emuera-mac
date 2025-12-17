# Emuera for macOS

🚀 Emuera游戏引擎的macOS原生移植版本

## 项目简介

Emuera是一个用于运行ERA系列游戏脚本的引擎。这个项目是将其从Windows/.NET Framework移植到macOS/Swift的努力。

> ⚠️ **开发状态**: 预Alpha阶段 - 正在构建核心架构

## 核心特性

### 现有功能
- Swift Package Manager 项目结构
- 兼容原版Emuera的变量系统
- 基础错误处理和日志系统
- JSON配置管理

### 计划功能
- [ ] 完整脚本解析器 (ERB/ERH)
- [ ] 表达式解析和计算引擎
- [ ] 命令执行系统
- [ ] macOS原生UI (AppKit)
- [ ] 图形渲染系统
- [ ] 文件I/O兼容性层

## 项目结构

```
Emuera/
├── Sources/
│   ├── EmueraCore/          # 核心引擎
│   │   ├── Common/          # 基础工具
│   │   ├── Variable/        # 变量系统
│   │   ├── Parser/          # 解析器
│   │   ├── Script/          # 脚本处理
│   │   └── Executor/        # 执行器
│   └── EmueraApp/           # macOS应用
│       ├── Views/           # UI组件
│       ├── Render/          # 图形渲染
│       └── Services/        # 系统服务
├── Tests/                   # 测试
└── Resources/               # 资源文件
```

## 开发环境要求

- macOS 13.0+
- Xcode 15.0+ 或 Swift 5.9+
- Swift Package Manager

## 快速开始

### 构建项目

```bash
cd Emuera
swift build
```

### 运行测试

```bash
swift test
```

### 运行应用

```bash
swift run emuera
```

## 与原版Emuera的兼容性

本项目目标是保持与原版Emuera的脚本兼容：

- ✅ ERB脚本语法兼容
- ✅ 变量系统兼容 (`RESULT`, `SELECTCOM`等)
- ✅ CSV文件格式兼容
- ⚠️ 部分Windows特有API需要重新实现
- ❌ GDI图形需要替换为Core Graphics

## 技术栈对比

| 功能 | Windows原版 | macOS移植 |
|------|-------------|-----------|
| 界面框架 | Windows Forms | AppKit |
| 图形引擎 | GDI32 | Core Graphics/Metal |
| 定时器 | WinMM | DispatchSource |
| 文件编码 | System Default | Foundation Encoding |
| 进程管理 | Windows API | POSIX |

## 模块开发状态

| 模块 | 状态 | 说明 |
|------|------|------|
| **Common** | ✅ | 基础工具类完成 |
| **Variable** | 🟡 | 基础数据结构完成 |
| **Parser** | 🔴 | 待开发 |
| **Executor** | 🔴 | 待开发 |
| **UI (AppKit)** | 🔴 | 待开发 |
| **Renderer** | 🔴 | 待开发 |

## 贡献指南

这个项目正在开发中，欢迎贡献代码和建议。

### 开发分支策略
- `main`: 稳定版本
- `dev`: 开发分支
- `feature/*`: 功能分支

### 提交规范
```
feat: 新功能
fix: 修复
refactor: 重构
docs: 文档
test: 测试
```

## 许可证

参考原版Emuera的许可证。

## 致谢

- 原版Emuera: https://github.com/Zerunokasiar/Emuera
- ERA系列游戏社区

---

**开发中...** 🚧