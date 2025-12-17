# Emuera macOS移植开发计划

## 📋 任务概述

将Emuera游戏引擎从Windows/.NET Framework移植到macOS/Swift，开发一个能够运行现有ERB脚本的原生macOS应用。

## ✅ 已完成工作

### 项目初始化 (2025-12-18)
- ✅ 创建Swift Package Manager项目结构
- ✅ 配置macOS目标平台 (macOS 13.0+)
- ✅ 创建核心模块目录
- ✅ 初始化Git仓库
- ✅ 创建基础配置系统
- ✅ 实现变量系统基础框架
- ✅ 添加错误处理和日志系统

## 🚧 下一步开发计划

### Phase 1: 核心解析器 (预计1周)

#### 1.1 词法分析器 (Lexer)
**文件**: `Sources/EmueraCore/Parser/LexicalAnalyzer.swift`
```swift
// 功能:
// - 读取ERB/ERH脚本文件
// - 将文本分解为Token流
// - 处理Shift-JIS等多字节编码
// - 支持注释和预处理指令

// Emuera示例:
// PRINTLHello World  -> [PRINTL, "Hello World"]
// RESULT:0 = 100     -> [RESULT, :, 0, =, 100]
```

#### 1.2 语法分析器 (Parser)
**文件**: `Sources/EmueraCore/Parser/ScriptParser.swift`
```swift
// 功能:
// - 将Token流解析为抽象语法树(AST)
// - 处理语句结构
// - 验证语法正确性
// - 生成可执行指令
```

#### 1.3 表达式解析器
**文件**: `Sources/EmueraCore/Parser/ExpressionParser.swift`
```swift
// 功能:
// - 解析数学表达式
// - 处理逻辑运算
// - 变量引用解析
// - 函数调用
// - 支持运算符优先级

// 示例表达式:
// RESULT + 10 * 2
// A > B && C == D
// CHARA:0_NAME + "さん"
```

### Phase 2: 执行引擎 (预计1周)

#### 2.1 指令系统
**文件**: `Sources/EmueraCore/Executor/Command.swift`
```swift
// 所有Emuera命令的Swift实现
// 基础I/O命令:
// - PRINT, PRINTL, PRINTW
// - INPUT, INPUTS
// - WAIT, WAITANYKEY

// 流程控制:
// - GOTO, CALL
// - IF/ELSE/ENDIF
// - FOR/ENDFOR
// - RETURN

// 数据操作:
// - ASSIGN (=)
// - ARRAYDATA
// - ADDDEFCHARA, ADDCHARA
```

#### 2.2 内置函数
**文件**: `Sources/EmueraCore/Executor/BuiltInFunctions.swift`
```swift
// 数学函数: ABS, SIN, COS, TAN, SQRT
// 字符串函数: STRLENS, SUBSTRING, REPLACE
// 数组函数: FINDELEMENT, FINDLAST, SORT
// 系统函数: GAMEBASE, VERSION, TIME
```

#### 2.3 执行上下文
**文件**: `Sources/EmueraCore/Executor/Process.swift`
```swift
// 模拟原版Process类
// 管理脚本执行状态
// 处理函数调用栈
// 错误恢复机制
```

### Phase 3: macOS原生UI (预计2周)

#### 3.1 主窗口 (AppKit)
**文件**: `Sources/EmueraApp/Views/MainWindow.swift`
```swift
// 使用AppKit重建:
// NSWindow: 主窗口框架
// NSTextView: 文本显示区域
// NSButton: 按钮和交互元素
// NSMenu: 菜单栏和快捷键
```

#### 3.2 图形渲染
**文件**: `Sources/EmueraApp/Render/GraphicsRenderer.swift`
```swift
// 替换GDI绘制的Core Graphics实现
// 方法:
// - drawRect: 绘制矩形
// - drawText: 文本渲染
// - drawImage: 图片绘制
// - fillRect: 填充区域

// 对应原版GDI函数:
// BitBlt -> drawImage
// TextOut -> drawText
// Rectangle -> drawRect/fillRect
```

#### 3.3 输入处理
**文件**: `Sources/EmueraApp/Services/InputService.swift`
```swift
// 键盘输入捕获
// 鼠标点击处理
// 计时器事件
// 模拟Windows输入系统
```

### Phase 4: 文件系统适配 (预计3天)

#### 4.1 编码处理
**文件**: `Sources/EmueraCore/Common/EncodingManager.swift`
```swift
// 处理Shift-JIS等编码
// 模拟原版emulator的文本处理
// 兼容原有的多字节字符处理
```

#### 4.2 文件I/O
**文件**: `Sources/EmueraCore/Common/FileService.swift`
```swift
// CSV文件读取
// ERB脚本加载
// 保存/读取游戏数据
// 配置文件管理
```

### Phase 5: 测试和优化 (预计1周)

#### 5.1 单元测试
```swift
- 变量系统测试
- 表达式计算测试
- 字符串处理测试
- 数组操作测试
```

#### 5.2 集成测试
```swift
- 脚本解析测试
- 完整游戏流程测试
- 错误处理测试
```

#### 5.3 性能优化
```swift
- 内存使用优化
- 渲染性能优化
- 启动速度优化
```

## 📁 模块开发优先级

### 紧急 (Week 1-2)
1. **变量系统** - 所有功能的基石
2. **词法分析器** - 脚本加载的前提
3. **表达式解析** - 计算系统核心
4. **基础命令** - 可运行最小系统

### 重要 (Week 2-3)
5. **UI框架** - 用户交互基础
6. **图形渲染** - 视觉输出
7. **文件管理** - 数据持久化

### 完善 (Week 4+)
8. **高级命令** - 完整功能支持
9. **游戏系统** - 完整游戏运行
10. **兼容层** - 更高的原版兼容

## 🔧 关键技术挑战

### 1. Windows API替换
```
Windows API         -> macOS替代
-------------------------------------
GDI32              -> Core Graphics
WinMM定时器        -> DispatchSourceTimer
GetKeyState        -> NSEvent.key modifiers
MessageBox         -> NSAlert
System.Windows.*   -> Foundation/AppKit
```

### 2. 编码兼容性
- 原版使用Shift-JIS和System编码
- macOS默认UTF-8
- 需要双向转换兼容层

### 3. 时序和事件
- Windows Forms事件循环 -> AppKit事件循环
- WinMM高精度计时器 -> CADisplayLink/DispatchTimer
- DoEvents清理 -> RunLoop处理

### 4. 内存管理
- C# GC -> Swift ARC
- 注意循环引用问题
- 及时释放资源

## 🎯 里程碑目标

### MVP (最小可用产品)
- ✅ 支持变量读写
- ✅ 支持基础命令(PRINT, INPUT等)
- ✅ 支持表达式计算
- 🔄 基础macOS界面

### Beta版本
- 完整脚本解析
- 高级流程控制
- 图形显示支持
- CSV文件支持

### 正式版
- 完整的原版兼容性
- 性能优化
- 用户配置系统
- 错误诊断工具

## 📝 开发注意事项

### 代码规范
- 严格错误处理
- 充分的注释
- 兼容性说明
- 性能考虑

### 测试策略
- 每个模块完成后立即测试
- 使用原版Emuera游戏作为验证标准
- 关注性能敏感区域

### 文档维护
- 代码内SwiftDoc
- API变更记要
- 迁移指南

---

**预计总开发周期: 4-6周**
**代码量预估: 15,000-20,000行Swift**