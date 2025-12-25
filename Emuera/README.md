# Emuera for macOS (Swift)

一个使用Swift开发的Emuera游戏引擎移植版本，运行在macOS平台。

## 项目概述

Emuera是基于ERB脚本的视觉小说游戏引擎。本项目是将Emuera移植到macOS平台的尝试，使用纯Swift实现核心引擎。

## 项目进度

### ✅ 已完成

#### Priority 1 - 核心函数系统 (100%)
- **231+ 个内置函数**
- **40+ 个基础命令**
- **完整的变量系统**
- **表达式解析和计算**
- **测试覆盖率: 优秀**

#### Priority 2 - 命令扩展 (100%)
- **图形绘制命令**: DRAWLINE, BAR, SETCOLOR等
- **输入命令扩展**: TINPUT, ONEINPUT, AWAIT等
- **位运算命令**: SETBIT, CLEARBIT, INVERTBIT
- **数组操作命令**: ARRAYSHIFT, ARRAYREMOVE, ARRAYSORT, ARRAYCOPY
- **测试覆盖率: 100% (19/19通过)**

#### Priority 3 - 功能完善 (100%)
- **时间日期函数**: GETDATE, GETDATETIME, TIMESTAMP, DATE, DATEFORM, GETTIMES
- **文件操作**: FILEEXISTS, FILEDELETE, FILECOPY, FILEREAD, FILEWRITE, DIRECTORYLIST
- **系统信息**: GETTYPE, GETS, GETDATA, GETERROR
- **数学常量**: PI
- **测试覆盖率: 100% (17/17通过)**

### 🚧 进行中

#### Priority 4 - 高级功能 (进行中)
- **高级图形绘制**: ✅ 10/10 命令完成
  - DRAWSPRITE, DRAWRECT, FILLRECT, DRAWCIRCLE, FILLCIRCLE
  - DRAWLINEEX, DRAWGRADIENT, SETBRUSH, CLEARSCREEN, SETBACKGROUNDCOLOR
  - 测试覆盖率: 100% (11/11通过)
  - **注意**: 这些是新增功能，原项目没有
- **原项目功能补齐**: 待开始
  - PRINT_IMG, PRINT_RECT, PRINT_SPACE
  - K/D模式打印命令
  - 字体样式命令
  - 调试命令
  - HTML命令
- **音频系统**: 待开始 (新增功能)
- **鼠标输入**: 待开始 (需要调整以匹配原项目)

#### Priority 5 - 头文件系统 (待开始)
- ERH头文件系统
- 宏定义
- 全局变量声明
- 函数指令

#### Priority 6 - 角色管理 (待开始)
- 角色管理系统
- 角色添加/删除
- 角色排序/查找
- 角色数据操作

### 整体进度

- **项目完成度**: **60%** (对比原项目功能)
- **核心功能**: **完整**
- **测试覆盖**: **优秀**
- **代码质量**: **良好**

### 最新更新 (2025-12-26)

#### Priority 4 高级图形渲染 ✅
- 新增10个图形绘制命令 (扩展功能)
- 修复参数解析器对逗号分隔的支持
- 所有11个测试用例通过
- 支持空格和逗号两种参数分隔方式

#### 重要发现 📊
通过对比原项目（C#版Emuera）:
- ✅ 我们的扩展: 音频、高级图形 (17个命令)
- ⚠️ 需要补齐: 原项目有但我们缺失 (~166个命令)
- 📋 修正计划: 优先补齐原项目功能，保留扩展特性

## 项目结构

```
Emuera/
├── Sources/
│   ├── EmueraCore/           # 核心引擎
│   │   ├── Function/         # 内置函数库
│   │   ├── Parser/           # 脚本解析器
│   │   ├── Executor/         # 执行引擎
│   │   └── Variable/         # 变量系统
│   ├── EmueraApp/            # macOS应用
│   ├── EmueraGUI/            # GUI界面
│   └── Phase7Debug/          # 测试程序
├── Tests/                    # 单元测试
└── Documentation/            # 文档
```

## 核心特性

### 1. 完整的函数系统
- 231+ 个内置函数
- 数学、字符串、数组、位运算、时间日期、文件操作
- 类型安全的VariableValue系统

### 2. 强大的解析能力
- ERB脚本词法分析
- 表达式解析（支持优先级、括号）
- 复杂语句解析（IF, SELECTCASE, TRY/CATCH, FOR, DO等）

### 3. 丰富的命令支持
- 图形绘制（DRAWLINE, BAR, SETCOLOR等）
- 输入处理（INPUT, TINPUT, ONEINPUT等）
- 流程控制（GOTO, RETURN, CONTINUE, BREAK等）
- 数据持久化（SAVE, LOAD, SAVECHARA等）

### 4. 完善的测试体系
- 10+ 个测试套件
- 100+ 个测试用例
- 持续集成支持

## 快速开始

### 编译项目

```bash
swift build
```

### 运行测试

```bash
# Priority 1 函数测试
swift run FunctionTest

# Priority 2 命令测试
swift run Priority2Test

# Priority 3 函数测试
swift run Priority3Test

# Priority 4 图形测试
swift run GraphicsTest

# 其他测试
swift run SelectCaseTest
swift run TryCatchTest
swift run PrintDTest
```

### 运行主程序

```bash
swift run emuera
```

## 开发文档

详细的功能实现总结请参考以下文档：

- [Priority 1 实现总结](PRIORITY1_IMPLEMENTATION_SUMMARY.md) - 核心函数系统
- [Priority 2 实现总结](PRIORITY2_IMPLEMENTATION_SUMMARY.md) - 命令扩展
- [Priority 3 实现总结](PRIORITY3_IMPLEMENTATION_SUMMARY.md) - 功能完善
- [Priority 4 开发计划](PHASE4_DEVELOPMENT_PLAN.md) - 高级功能开发
- [TRY/CATCH 实现总结](TRYC_IMPLEMENTATION_SUMMARY.md) - 异常处理系统
- [GUI 增强总结](Sources/Phase5Debug/GUI_ENHANCEMENT_SUMMARY.md) - GUI功能

## 技术栈

- **语言**: Swift 5.9
- **平台**: macOS 13+
- **框架**: Foundation, AppKit
- **构建工具**: Swift Package Manager

## 设计原则

- **KISS**: 保持简单，避免过度设计
- **渐进式开发**: 逐步实现，持续测试
- **类型安全**: 使用Swift的强类型系统
- **测试驱动**: 先测试，后实现

## 贡献指南

1. 遵循KISS原则，实现简单可维护的代码
2. 所有新功能必须有对应的测试
3. 保持代码风格一致
4. 更新相关文档

## 许可证

MIT License

## 作者

基于Emuera项目的Swift移植版本

---

**当前状态**:
- ✅ Priority 4 高级图形渲染完成 (10个扩展命令)
- 📋 修正计划: 优先补齐原项目功能 (~166个命令待实现)
- 🎯 下一步: 添加PRINT_IMG/RECT/SPACE, K/D模式打印, 字体命令

**文档更新**:
- `FUNCTION_COMPARISON.md` - 原项目对比分析
- `PRIORITY4_CORRECTED_PLAN.md` - 修正后的开发计划
- `NEXT_DEVELOPMENT_PLAN.md` - 详细实施计划