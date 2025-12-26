# Emuera Swift移植 - 下一步开发计划

**制定日期**: 2025-12-26
**当前状态**: 阶段2进行中 (52%完成) - ✅ 解析器限制已修复
**目标**: 完成阶段2，达到100%命令执行逻辑覆盖

---

## 🎯 立即行动清单 (Week 1 - 优先级最高)

### ✅ Day 1-2: 修复解析器限制 (9个测试失败 - 已全部完成)

#### ✅ 任务1: 修复TINPUT系列参数支持
**影响命令**: TINPUT, TINPUTS, TONEINPUT, TONEINPUTS (4个)
**状态**: ✅ 已修复 - 现在支持1-4个参数
**修复位置**: `Emuera/Sources/EmueraCore/Parser/ScriptParser.swift:parseInputCommand()`
**修改**: 使用 `parseSpaceSeparatedArguments(minCount: 1, maxCount: 4)`
**C#原项目语法**:
```
TINPUT timeout, default, display_time, timeout_message
TINPUTS timeout, default_string, display_time, timeout_message
```

**修复位置**: `Emuera/Sources/EmueraCore/Parser/ScriptParser.swift`
**修改函数**: `parseInputCommand()`
**参考**: 查看原项目 `GameProc/Function/BuiltInFunctionCode.cs`

**实现步骤**:
```swift
// 当前
func parseInputCommand() throws -> Statement {
    let timeout = try parseSpaceSeparatedArguments(exactCount: 1)[0]
    return InputStatement(timeout: timeout)
}

// 需要改为
func parseInputCommand() throws -> Statement {
    let args = try parseSpaceSeparatedArguments(minCount: 1, maxCount: 4)
    return InputStatement(
        timeout: args[0],
        default: args.count > 1 ? args[1] : nil,
        displayTime: args.count > 2 ? args[2] : nil,
        timeoutMessage: args.count > 3 ? args[3] : nil
    )
}
```

#### 任务2: 修复SETCOLOR/SETBGCOLOR参数支持
**影响命令**: SETCOLOR, SETBGCOLOR (2个)
**当前问题**: 只支持1个参数，需要支持1或3个参数
**C#原项目语法**:
```
SETCOLOR 255, 255, 255  // RGB值
SETCOLOR 0xFFFFFF       // 单个颜色值
```

**修复位置**: `Emuera/Sources/EmueraCore/Parser/ScriptParser.swift`
**修改函数**: `parseColorCommand()`

**实现步骤**:
```swift
// 当前
func parseColorCommand(_ command: Command) throws -> Statement {
    let args = try parseSpaceSeparatedArguments(exactCount: 1)
    return ColorStatement(command: command, value: args[0])
}

// 需要改为
func parseColorCommand(_ command: Command) throws -> Statement {
    let args = try parseSpaceSeparatedArguments(minCount: 1, maxCount: 3)
    if args.count == 1 {
        // 单个颜色值
        return ColorStatement(command: command, value: args[0])
    } else {
        // RGB值: 需要合并为单个值
        return ColorStatement(command: command, rgb: (args[0], args[1], args[2]))
    }
}
```

#### 任务3: 修复DO-LOOP块内赋值解析
**影响命令**: DO...LOOP WHILE, DO...LOOP UNTIL (2个)
**当前问题**: 解析器在块内赋值时报错 "unexpectedToken(operator(=))"
**测试用例**:
```erb
DO
    A = A + 1
LOOP WHILE A < 5
```

**修复位置**: `Emuera/Sources/EmueraCore/Parser/ScriptParser.swift`
**修改函数**: `parseDoLoop()`

**可能原因**:
- 块内语句解析时，赋值表达式未被正确识别
- 需要检查 `parseStatement()` 是否支持赋值语句

**调试步骤**:
```swift
// 1. 在 parseDoLoop() 中添加调试输出
// 2. 检查 parseStatement() 是否能处理 A = A + 1
// 3. 查看 ExpressionParser 是否支持赋值操作符
```

#### 任务4: 文档说明SET命令替代方案
**影响命令**: SET (1个)
**解决方案**: 文档说明使用表达式语法

**更新文档**: `PARSER_LIMITATIONS.md`
```markdown
## SET Command

**C# Emuera Syntax:**
```
SET A = 10
```

**Swift Emuera Syntax:**
```
A = 10  // 使用表达式语法
```

**说明**: SET命令在Swift版本中通过ExpressionStatement实现，语法更简洁。
```

---

### Day 3-5: 完成剩余命令执行逻辑 (~186个)

#### 优先级1: 核心流程控制 (约30个)
**目标**: 实现脚本运行的基础流程控制

**命令列表**:
```
CALL, JUMP, GOTO, CALLFORM, JUMPFORM, GOTOFORM
CALLEVENT, CALLTRAIN, STOPCALLTRAIN
RETURN, RETURNFORM, RETURNF, RESTART, DOTRAIN
SELECTCASE, CASE, CASEELSE, ENDSELECT
```

**实现要点**:
1. **CALL/JUMP/GOTO**: 需要函数系统支持
   - 维护函数调用栈
   - 处理参数传递
   - 支持返回值

2. **SELECTCASE**: 需要完整的case匹配逻辑
   - 支持单个值匹配
   - 支持范围匹配 (CASE 1 TO 5)
   - 支持多个值匹配 (CASE 1, 2, 3)
   - 支持CASEELSE

3. **循环结构**: FOR, WHILE, DO, REPEAT
   - 维护循环状态
   - 支持CONTINUE/BREAK
   - 处理循环变量

**参考文件**:
- 原项目: `GameProc/Statement/Statement.cs`
- 现有实现: `StatementExecutor.swift` 中的IF语句

#### 优先级2: 数据操作 (约20个)
**目标**: 支持角色和数据管理

**命令列表**:
```
ADDDEFCHARA, ADDSPCHARA, ADDCOPYCHARA
DELALLCHARA, PICKUPCHARA
SAVECHARA, LOADCHARA, SAVEGAME, LOADGAME, SAVEVAR, LOADVAR
```

**实现要点**:
1. **角色管理**: 需要CharacterManager支持
2. **数据持久化**: 需要FileService支持
3. **序列化**: 需要实现SaveData结构

#### 优先级3: 数据块和高级打印 (约40个)
**目标**: 完善数据展示功能

**命令列表**:
```
PRINTDATA, PRINTDATAL, PRINTDATAW, PRINTDATAK, PRINTDATAKL, PRINTDATAKW
PRINTDATAD, PRINTDATADL, PRINTDATADW
DATALIST, ENDLIST, ENDDATA, DATA, DATAFORM, STRDATA
PRINTSINGLE, PRINTSINGLEV, PRINTSINGLES, PRINTSINGLEFORM, PRINTSINGLEFORMS
PRINTSINGLED, PRINTSINGLEVD, PRINTSINGLESD, PRINTSINGLEFORMD, PRINTSINGLEFORMSD
PRINTSINGLEK, PRINTSINGLEVK, PRINTSINGLESK, PRINTSINGLEFORMK, PRINTSINGLEFORMSK
```

**实现要点**:
1. **数据块**: 需要维护数据列表，随机选择
2. **单行打印**: 需要特殊的输出格式控制

#### 优先级4: 系统命令和工具 (约30个)
**目标**: 完善系统功能

**命令列表**:
```
RESETDATA, RESETGLOBAL, RESET_STAIN
REDRAW, SKIPDISP, NOSKIP, ENDNOSKIP, OUTPUTLOG
FORCEWAIT, TWAIT
CUSTOMDRAWLINE, DRAWLINEFORM
FONTSTYLE, ALIGNMENT, CLEARTEXTBOX
SETCOLORBYNAME, SETBGCOLORBYNAME
```

**实现要点**:
1. **系统状态**: 需要维护全局状态
2. **显示控制**: 需要UI系统支持
3. **颜色扩展**: 需要颜色名称映射

#### 优先级5: 字符串和数学 (约20个)
**目标**: 完善字符串处理和数学计算

**命令列表**:
```
STRLENFORM, STRLENFORMU, STRLENU, ENCODETOUNI
TIMES, POWER
```

**实现要点**:
1. **字符串**: 需要支持Unicode和编码转换
2. **数学**: 需要支持幂运算和乘法

#### 优先级6: HTML和工具提示 (约15个)
**目标**: 支持HTML输出和工具提示

**命令列表**:
```
HTML_PRINT, HTML_TAGSPLIT, HTML_GETPRINTEDSTR, HTML_POPPRINTINGSTR
HTML_TOPLAINTEXT, HTML_ESCAPE
TOOLTIP_SETCOLOR, TOOLTIP_SETDELAY, TOOLTIP_SETDURATION
INPUTMOUSEKEY, FORCEKANA
```

**实现要点**:
1. **HTML解析**: 需要HTML解析器
2. **工具提示**: 需要UI系统支持

#### 优先级7: Phase 6角色显示 (约10个)
**目标**: 完善角色UI显示

**命令列表**:
```
SHOWCHARACARD, SHOWCHARALIST, SHOWBATTLESTATUS, SHOWPROGRESSBARS, SHOWCHARATAGS
BATCHMODIFY, CHARACOUNT, CHARAEXISTS
```

**实现要点**:
1. **UI组件**: 需要CharacterUIManager支持
2. **批量操作**: 需要CharacterManager支持

---

## 📅 详细开发时间表

### Week 1 (12/26 - 12/29)

#### Day 1 (12/26) - 修复解析器
- **上午**: 分析TINPUT系列问题，阅读原项目代码
- **下午**: 实现TINPUT参数支持 (4个命令)
- **晚上**: 测试并提交

#### Day 2 (12/27) - 继续修复
- **上午**: 实现SETCOLOR/SETBGCOLOR参数支持 (2个命令)
- **下午**: 修复DO-LOOP赋值解析 (2个命令)
- **晚上**: 更新文档，运行完整测试

#### Day 3 (12/28) - 流程控制1
- **上午**: 实现CALL/JUMP/GOTO基础 (3个命令)
- **下午**: 实现CALLFORM/JUMPFORM/GOTOFORM (3个命令)
- **晚上**: 测试函数调用

#### Day 4 (12/29) - 流程控制2
- **上午**: 实现RETURN系列 (3个命令)
- **下午**: 实现SELECTCASE基础 (4个命令)
- **晚上**: 测试流程控制

### Week 2 (12/30 - 1/5)

#### Day 5-6 (12/30-31) - 循环结构
- **FOR/NEXT, WHILE/WEND, DO/LOOP, REPEAT/REND**
- **CONTINUE, BREAK**

#### Day 7-8 (1/1-2) - 数据操作
- **ADDCHARA系列, DEL系列, SWAP/COPY**
- **SAVE/LOAD系列**

#### Day 9-10 (1/3-4) - 数据块
- **PRINTDATA系列, DATALIST/ENDLIST**
- **单行打印系列**

#### Day 11-12 (1/5) - 系统命令
- **RESET系列, 显示控制, 等待命令**

### Week 3 (1/6 - 1/12)

#### Day 13-14 - 字符串和数学
- **STRLEN系列, ENCODETOUNI**
- **TIMES, POWER**

#### Day 15-16 - HTML和工具提示
- **HTML_PRINT系列, TOOLTIP系列**
- **INPUTMOUSEKEY, FORCEKANA**

#### Day 17-18 - Phase 6角色显示
- **SHOW系列, BATCHMODIFY**
- **CHARACOUNT, CHARAEXISTS**

#### Day 19 - 完整测试
- **运行CommandVerification**
- **修复发现的问题**
- **更新文档**

### Week 4 (1/13 - 1/19) - 阶段3开始

#### Day 20-23 - 内置函数补全
- **字符串函数: 15个**
- **数组函数: 15个**
- **图形函数: 10个**

---

## 🛠️ 开发工作流

### 每日开发流程

```bash
# 1. 早上: 选择任务
# 阅读 CURRENT_STATUS.md 确定今天目标
# 查看 PARSER_LIMITATIONS.md 了解已知问题

# 2. 实现命令
# 编辑: Emuera/Sources/EmueraCore/Executor/StatementExecutor.swift
# 添加: case语句和执行逻辑

# 3. 测试验证
cd /Users/ss/Documents/Project/iOS/emuera-mac/Emuera
swift run CommandVerification

# 4. 提交代码
git add .
git commit -m "feat: 实现XXX命令执行逻辑"
git push origin main
```

### 代码规范

```swift
// 1. 命令执行逻辑模板
case .COMMAND_NAME:
    // 参数验证
    guard let arg1 = statement.arguments[safe: 0] else {
        throw ExecutionError.missingArgument("参数1")
    }

    // 执行逻辑
    // ... 具体实现 ...

    // 返回结果
    return .null

// 2. 错误处理
enum ExecutionError: Error {
    case missingArgument(String)
    case invalidArgument(String)
    case notImplemented(String)
}

// 3. 文档注释
/// 执行 COMMAND_NAME 命令
/// - 参数: arg1, arg2, ...
/// - 返回: .null 或具体值
/// - 注意: 需要xxx支持
```

### 测试策略

```swift
// 1. 单元测试模板
func testCommandName() {
    let script = """
    COMMAND_NAME arg1, arg2
    QUIT
    """

    let parser = ScriptParser()
    let statements = try! parser.parse(script)
    let executor = StatementExecutor()
    let result = executor.execute(statements)

    XCTAssertEqual(result, .null)
}

// 2. 集成测试
func testCommandVerification() {
    // 运行 CommandVerification.swift
    // 确保通过率 >= 97%
}
```

---

## 📋 每日任务清单

### Day 1: TINPUT系列修复
- [ ] 阅读原项目TINPUT实现
- [ ] 修改parseInputCommand支持2-4参数
- [ ] 更新StatementExecutor中的TINPUT逻辑
- [ ] 编写测试用例
- [ ] 运行CommandVerification验证
- [ ] 提交代码

### Day 2: SETCOLOR和DO-LOOP修复
- [ ] 修改parseColorCommand支持RGB参数
- [ ] 修复DO-LOOP块内赋值解析
- [ ] 更新文档说明SET命令
- [ ] 编写测试用例
- [ ] 运行CommandVerification验证
- [ ] 提交代码

### Day 3-5: 流程控制实现
- [ ] 实现CALL/JUMP/GOTO系列
- [ ] 实现RETURN系列
- [ ] 实现SELECTCASE系列
- [ ] 实现循环结构
- [ ] 编写测试用例
- [ ] 运行CommandVerification验证
- [ ] 提交代码

---

## 📊 预期成果

### Week 1结束时
- ✅ 9个解析器限制全部修复
- ✅ 测试通过率从97.0%提升到100%
- ✅ 实现30-40个核心流程控制命令
- ✅ 完成度从52%提升到60%

### Week 2结束时
- ✅ 实现150+个命令执行逻辑
- ✅ 完成度达到80%
- ✅ 所有核心功能可用

### Week 3结束时
- ✅ 实现所有386个命令执行逻辑
- ✅ 完成度达到100%
- ✅ 测试通过率100%

---

## 🎯 成功标准

### 阶段2完成标准
1. **所有386个命令都有执行逻辑**
2. **CommandVerification测试通过率100%**
3. **无编译错误和警告**
4. **代码质量良好，有适当注释**
5. **文档更新完整**

### 质量标准
1. **与C# Emuera行为一致**
2. **错误处理完善**
3. **测试覆盖率 > 90%**
4. **代码风格统一**

---

## 💡 提示和技巧

### 1. 如何阅读原项目代码
```bash
# 查找命令实现
grep -r "TINPUT" /Users/ss/Documents/Project/Games/Emuera/GameProc/Function/

# 查看函数定义
cat /Users/ss/Documents/Project/Games/Emuera/GameProc/Function/BuiltInFunctionCode.cs | grep -A 20 "TINPUT"
```

### 2. 如何调试解析器
```swift
// 在 ScriptParser.swift 中添加
print("Parsing: \(token)")
```

### 3. 如何验证实现
```swift
// 创建简单测试
let script = "COMMAND_NAME arg1, arg2\nQUIT"
// 运行并检查输出
```

---

## 📞 总结

**当前**: 阶段2进行中 (52%完成)
**目标**: 1-2周内完成阶段2
**重点**: 修复9个解析器限制 + 完成剩余命令逻辑

**立即行动**:
1. Day 1: 修复TINPUT系列 (4个命令)
2. Day 2: 修复SETCOLOR和DO-LOOP (3个命令)
3. Day 3-5: 实现核心流程控制 (30+个命令)

**成功关键**:
- 每日完成任务并提交
- 保持测试通过率 >= 97%
- 及时更新文档
- 参考原项目确保行为一致

---

**计划制定**: 2025-12-26
**预计完成**: 2026-1-10
**状态**: 🟢 待执行
