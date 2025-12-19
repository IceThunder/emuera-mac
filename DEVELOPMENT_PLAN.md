# Emuera macOS移植开发计划 (2025-12-19 更新)

## 📋 任务概述

将Emuera游戏引擎从Windows/.NET Framework移植到macOS/Swift，开发一个能够运行现有ERB脚本的原生macOS应用。

**当前状态**: 🟢 核心引擎完成 (35%)，准备进入语法解析阶段
**代码量**: 5,142行 (22个Swift文件)

---

## ✅ 已完成工作 (2025-12-18 ~ 12-19)

### Phase 0: 基础架构 (100%)
- ✅ 创建Swift Package Manager项目结构
- ✅ 配置macOS目标平台 (macOS 13.0+)
- ✅ 核心模块目录结构
- ✅ Git仓库初始化
- ✅ 配置系统 (Config.swift)
- ✅ 错误处理 (EmueraError.swift)
- ✅ 日志系统 (Logger.swift)

### Phase 1: 核心解析器 (80%)

#### ✅ 1.1 变量系统 (100%) ⭐ **重大突破**
**完成的文件**:
- `VariableCode.swift` - 完整位标志系统
- `VariableToken.swift` - 基础令牌实现
- `VariableToken+Advanced.swift` - 高级变量支持
- `VariableData.swift` - 完整存储结构
- `TokenData.swift` - 令牌管理系统
- `CharacterData.swift` - 角色数据系统

**支持的变量类型**:
- ✅ 单值变量: DAY, MONEY, RESULT, COUNT 等
- ✅ 1D数组: A-Z, FLAG, TFLAG, ITEM 等
- ✅ 2D数组: CDFLAG 等
- ✅ 字符1D数组: BASE, ABL, TALENT, EXP 等
- ✅ 字符2D数组: CDFLAG (字符版)
- ✅ 字符字符串: NAME, CALLNAME, CSTR 等
- ✅ 特殊变量: RAND, CHARANUM, __INT_MAX__, __INT_MIN__ 等

#### ✅ 1.2 词法分析器 (100%)
**文件**: `LexicalAnalyzer.swift`, `TokenType.swift`
- ✅ 识别变量名、数值、字符串
- ✅ 所有运算符 (算术、位运算、比较、逻辑)
- ✅ 命令识别 (PRINT, PRINTL, QUIT等)
- ✅ 括号处理
- ✅ 换行和空白处理

#### ✅ 1.3 表达式引擎 (100%)
**文件**: `ExpressionParser.swift`, `ExpressionEvaluator.swift`
- ✅ 算术运算: `+` `-` `*` `/` `%` `**`
- ✅ 优先级处理: `A + B * C`
- ✅ 括号支持: `(10 + 20) * 3`
- ✅ 变量引用: `X = Y`
- ✅ 混合运算: `A + B * C - (X + Y)`
- ✅ 数组语法: `A:5`, `BASE:0`, `CFLAG:0:5`
- ✅ 函数调用: `RAND(100)`

#### ⏳ 1.4 语法解析器 (0%)
**待实现**: `ScriptParser.swift`
- ❌ 支持 `IF/ELSE/ENDIF` 条件分支
- ❌ 支持 `WHILE/ENDWHILE` 循环
- ❌ 支持 `CALL` 函数调用
- ❌ 支持 `GOTO` 跳转
- ❌ 支持 `RETURN` 返回
- ❌ 支持 `SELECTCASE/ENDSELECT` 选择

#### ⏳ 1.5 逻辑行解析 (0%)
**待实现**: `LogicalLineParser.swift`
- ❌ 处理续行符号 `@`
- ❌ 逻辑行合并
- ❌ 注释处理

#### ⏳ 1.6 头文件加载 (0%)
**待实现**: `HeaderFileLoader.swift`
- ❌ 加载ERH文件
- ❌ 宏定义解析
- ❌ 常量定义

### Phase 2: 执行引擎 (60%)

#### ✅ 2.1 执行器核心 (80%)
**文件**: `SimpleExecutor.swift`, `ScriptEngine.swift`
- ✅ 分离持久环境和工作环境
- ✅ 变量跨脚本保持
- ✅ RESET命令清空变量
- ✅ PERSIST ON/OFF 状态切换
- ✅ 基础命令: PRINT, PRINTL, WAIT, QUIT

#### ⏳ 2.2 命令系统 (50%)
**部分实现**: 基础命令可用
- ✅ PRINT, PRINTL - 输出命令
- ✅ WAIT - 等待输入
- ✅ QUIT - 退出
- ✅ RESET - 重置变量
- ❌ INPUT, INPUTS - 输入命令
- ❌ GOTO, CALL - 流程控制
- ❌ IF/WHILE - 条件循环
- ❌ 50+ 其他命令

#### ⏳ 2.3 内置函数 (20%)
**部分实现**: 仅特殊变量
- ✅ RAND(100) - 随机数
- ✅ CHARANUM - 角色数量
- ✅ __INT_MAX__ - 常量
- ❌ 数学函数: ABS, SIN, COS, TAN, SQRT
- ❌ 字符串函数: STRLENS, SUBSTRING, REPLACE
- ❌ 数组函数: FINDELEMENT, SORT, REPEAT

#### ⏳ 2.4 进程管理 (0%)
**待实现**: `Process.swift`, `ProcessState.swift`
- ❌ 函数调用栈
- ❌ 局部变量作用域
- ❌ 递归支持
- ❌ 状态机实现
- ❌ 上下文切换

### Phase 3: macOS UI (0%)

**全部待实现**:
- ❌ MainWindow.swift - 主窗口
- ❌ ConsoleView.swift - 文本渲染
- ❌ GraphicsRenderer.swift - 图形绘制
- ❌ InputHandler.swift - 输入处理

### Phase 4: 文件系统 (0%)

**全部待实现**:
- ❌ EncodingManager.swift - Shift-JIS支持
- ❌ FileService.swift - CSV/ERB加载
- ❌ CSVParser.swift - CSV解析

### Phase 5: 测试和优化 (35%)

**部分实现**:
- ✅ 控制台测试命令 (test, exprtest, persisttest, debug)
- ✅ 持久化专项测试 (7个测试用例)
- ✅ 表达式解析器测试
- ❌ 单元测试框架
- ❌ 集成测试
- ❌ 性能测试

---

## 🚧 下一步开发计划 (2025-12-19 ~ 2026-01-15)

### 🔴 紧急任务: Phase 1 剩余 (Week 1)

#### 1.1 语法解析器 (最高优先级)
**文件**: `Sources/EmueraCore/Parser/ScriptParser.swift`

```swift
// 功能需求:
// - 将Token流解析为可执行指令序列
// - 处理控制流结构 (IF/WHILE/CALL等)
// - 构建抽象语法树(AST)
// - 语法验证

// 支持的语句类型:
// IF A > 10
//   PRINTL A大于10
// ELSE
//   PRINTL A小于等于10
// ENDIF

// WHILE COUNT < 100
//   COUNT = COUNT + 1
// ENDWHILE

// CALL EVENT_USER1

// GOTO LABEL1
// LABEL1:
//   PRINTL 跳转成功
```

**开发步骤**:
1. 定义语句节点类型 (Statement AST)
2. 实现语句解析器框架
3. 实现IF/ELSE/ENDIF解析
4. 实现WHILE/ENDWHILE解析
5. 实现CALL/RETURN解析
6. 实现GOTO/LABEL解析
7. 实现SELECTCASE/ENDSELECT解析

#### 1.2 逻辑行解析器
**文件**: `Sources/EmueraCore/Parser/LogicalLineParser.swift`

```swift
// 处理多行连接:
// PRINTL Hello \
//      World
// -> 合并为单行: PRINTL Hello World

// 处理注释:
// A = 10  # 这是注释
// -> 移除注释，保留A = 10
```

#### 1.3 头文件加载器
**文件**: `Sources/EmueraCore/Parser/HeaderFileLoader.swift`

```swift
// 加载ERH文件:
// #define MAX_FLAG 100
// #CONSTANT PI 3.14159

// 在脚本中使用:
// IF FLAG:MAX_FLAG > PI
```

#### 1.4 命令系统扩展
**文件**: `Sources/EmueraCore/Executor/Command.swift`

```swift
// 实现20+个常用命令:
// I/O命令: INPUT, INPUTS, WAIT, WAITANYKEY
// 流程控制: GOTO, CALL, RETURN, BREAK, CONTINUE
// 数据操作: ADDCHARA, DELCHARA, SWAP
// 文件操作: SAVE, LOAD
// 图形操作: DRAWLINE, PRINT_IMAGE
```

#### 1.5 内置函数库
**文件**: `Sources/EmueraCore/Executor/BuiltInFunctions.swift`

```swift
// 实现10+个常用函数:
// 数学: ABS, SIN, COS, TAN, SQRT, LOG, EXP
// 字符串: STRLENS, SUBSTRING, REPLACE, SPLIT
// 数组: FINDELEMENT, FINDLAST, SORT, REPEAT
// 系统: GAMEBASE, VERSION, TIME, GETTIME
// 位运算: GETBIT, SETBIT, CLEARBIT, SUMARRAYS
```

### 🟡 重要任务: Phase 2 剩余 (Week 2)

#### 2.1 进程管理
**文件**: `Sources/EmueraCore/Executor/Process.swift`

```swift
// 实现函数调用栈:
// - 支持嵌套调用
// - 局部变量作用域
// - RETURN返回值
// - 递归支持
// - 错误恢复
```

#### 2.2 状态管理
**文件**: `Sources/EmueraCore/Executor/ProcessState.swift`

```swift
// 实现状态机:
// - 执行状态跟踪
// - 上下文切换
// - 调试信息
// - 断点支持
```

#### 2.3 高级错误处理
**文件**: `Sources/EmueraCore/Common/ErrorHandling.swift`

```swift
// 实现:
// - 错误定位 (行号/列号)
// - 错误恢复机制
// - 用户友好错误消息
// - 错误堆栈跟踪
```

### 🟢 完善任务: Phase 3-5 (Week 3-4)

#### 3.1 macOS UI框架
**文件**: `Sources/EmueraApp/Views/`

- MainWindow.swift - 主窗口 (AppKit)
- ConsoleView.swift - 文本渲染
- MenuBar.swift - 菜单栏
- Toolbar.swift - 工具栏

#### 3.2 图形渲染
**文件**: `Sources/EmueraApp/Render/GraphicsRenderer.swift`

```swift
// Core Graphics实现:
// - drawRect: 绘制矩形
// - drawText: 文本渲染
// - drawImage: 图片绘制
// - fillRect: 填充区域
// - 对应GDI函数映射
```

#### 3.3 文件系统
**文件**: `Sources/EmueraCore/File/`

- EncodingManager.swift - Shift-JIS/UTF-8转换
- FileService.swift - CSV/ERB加载
- CSVParser.swift - CSV解析
- SaveManager.swift - 存档管理

#### 3.4 完整测试套件
**文件**: `Tests/EmueraCoreTests/`

- VariableSystemTests.swift
- ExpressionParserTests.swift
- ScriptParserTests.swift
- ExecutorTests.swift
- IntegrationTests.swift

---

## 📊 进度追踪表

| 模块 | 计划 | 实际 | 状态 | 代码行数 |
|------|------|------|------|----------|
| **基础架构** | 100% | 100% | ✅ | ~350 |
| **变量系统** | 100% | 100% | ✅ | ~1,800 |
| **词法分析** | 100% | 100% | ✅ | ~400 |
| **表达式引擎** | 100% | 100% | ✅ | ~1,200 |
| **语法解析器** | 100% | 0% | ⏳ | 0 |
| **命令系统** | 100% | 50% | 🟡 | ~300 |
| **内置函数** | 100% | 20% | 🔴 | ~100 |
| **执行引擎** | 100% | 80% | 🟢 | ~600 |
| **进程管理** | 100% | 0% | ⏳ | 0 |
| **UI框架** | 100% | 0% | ⏳ | 0 |
| **图形渲染** | 100% | 0% | ⏳ | 0 |
| **文件系统** | 100% | 0% | ⏳ | 0 |
| **测试套件** | 100% | 35% | 🟡 | ~392 |
| **总计** | **100%** | **35%** | 🟢 | **5,142** |

---

## 🎯 里程碑计划

### MVP v0.4 (预计2025-12-26)
**目标**: 完整语法解析支持
- ✅ 变量系统 (已完成)
- ✅ 表达式引擎 (已完成)
- ✅ 语法解析器 (IF/WHILE/CALL)
- ✅ 扩展命令系统 (20+个)
- ✅ 常用内置函数 (10+个)

### Beta v0.5 (预计2026-01-05)
**目标**: 完整脚本运行能力
- ✅ MVP v0.4 所有功能
- ✅ 完整命令系统 (50+个)
- ✅ 完整函数库 (100+个)
- ✅ 进程管理
- ✅ 高级错误处理

### Beta v0.6 (预计2026-01-12)
**目标**: macOS原生UI
- ✅ Beta v0.5 所有功能
- ✅ AppKit主窗口
- ✅ 文本控制台
- ✅ 菜单和工具栏
- ✅ 基础图形渲染

### 正式版 v1.0 (预计2026-01-20)
**目标**: 完整可用版本
- ✅ Beta v0.6 所有功能
- ✅ CSV文件支持
- ✅ Shift-JIS编码
- ✅ 完整测试覆盖
- ✅ 性能优化
- ✅ 用户文档

---

## 🔧 关键技术决策

### 1. 变量系统架构
**决策**: 使用位标志 + 令牌模式
- **优势**: 高性能、类型安全、易于扩展
- **实现**: VariableCode (位标志) + VariableToken (访问器)
- **结果**: 支持所有Emuera变量类型

### 2. 表达式解析策略
**决策**: 递归下降 + 优先级爬升
- **优势**: 代码清晰、易于调试、符合直觉
- **实现**: ExpressionParser (AST构建) + ExpressionEvaluator (执行)
- **结果**: 正确处理运算符优先级和括号

### 3. 持久化设计
**决策**: 环境分离 (持久/工作)
- **优势**: 跨脚本状态保持、易于重置
- **实现**: ScriptEngine分离两个VariableData环境
- **结果**: PERSIST ON/OFF功能正常工作

### 4. 错误处理
**决策**: Swift原生Error + 自定义错误类型
- **优势**: 类型安全、错误链、易于扩展
- **实现**: EmueraError枚举 + CodeEE错误
- **结果**: 清晰的错误消息和堆栈

---

## 📝 开发建议

### 优先级排序
1. **ScriptParser.swift** - 这是下一个关键路径
2. **Command.swift** - 扩展命令支持
3. **BuiltInFunctions.swift** - 增强表达式能力
4. **单元测试框架** - 确保代码质量

### 开发工作流
```bash
# 1. 创建新分支
git checkout -b feature/script-parser

# 2. 实现核心功能
# 创建: Sources/EmueraCore/Parser/ScriptParser.swift

# 3. 添加测试
# 在 Tests/EmueraCoreTests/ 添加测试

# 4. 验证功能
swift test --filter EmueraCoreTests

# 5. 提交代码
git add . && git commit -m "feat: 实现ScriptParser"
```

### 代码风格指南
```swift
// ✅ 推荐
public enum EmueraError: Error {
    case scriptParseError(message: String, position: ScriptPosition?)
}

// ❌ 不推荐
var err: String = "error"
```

### 测试策略
- 每个模块完成后立即测试
- 使用原版Emuera游戏作为验证标准
- 关注性能敏感区域
- 保持测试覆盖率 > 80%

---

## 🎯 风险和缓解

### 风险1: 语法解析复杂度高
**缓解**:
- 分阶段实现 (先IF，再WHILE，再CALL)
- 参考原版C#代码
- 使用测试驱动开发

### 风险2: 性能问题
**缓解**:
- 使用Swift优化技巧
- 避免不必要的内存分配
- 性能测试贯穿始终

### 风险3: 原版兼容性
**缓解**:
- 保持与原版行为一致
- 使用原版游戏测试
- 文档记录差异

---

## 📚 相关资源

- **原版Emuera**: [Emuera原版代码](https://ux.getuploader.com/ninnohito/)
- **项目状态**: [STATUS.md](./STATUS.md)
- **完整报告**: [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)
- **快速开始**: [QUICKSTART.md](./QUICKSTART.md)

---

## 🏁 总结

**当前状态**: 🟢 核心引擎完成，准备进入语法解析阶段
**当前进度**: **35%** (5,142行代码)
**下一步**: 实现ScriptParser.swift，支持IF/WHILE/CALL等语法结构
**预计完成**: 2026年1月 (Beta版本)

**宣言**:
> "变量系统是引擎的血液，表达式是大脑，而现在我们有了完整的大脑和血液。
> 下一步是给它一个能思考的语法解析器，让它真正理解ERB脚本的语言。"

---

*最后更新: 2025-12-19*
*工具: Claude Code*
*项目: emuera-mac*
