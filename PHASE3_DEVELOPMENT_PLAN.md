# Phase 3 开发计划 - Emuera macOS 完整功能实现

**目标**: 实现与原版 Emuera 100% 功能兼容，支持完整游戏运行
**时间**: 预计 60-90 天
**代码量**: 约 25,000 行（Phase 2: 19,000 行）

---

## 📋 Phase 3 开发总览

### 核心模块划分

| 模块 | 优先级 | 预计工时 | 依赖关系 |
|------|--------|----------|----------|
| **1. 语法扩展** | P0 | 7天 | 无 |
| **2. 保存/加载系统** | P0 | 10天 | 变量系统 |
| **3. ERH头文件系统** | P1 | 8天 | 文件服务 |
| **4. 图形UI系统** | P1 | 15天 | 基础UI |
| **5. 字符管理系统** | P2 | 10天 | 变量系统 |
| **6. 调教/商店系统** | P2 | 15天 | 以上全部 |
| **7. 动画/声音** | P3 | 10天 | UI系统 |

---

## 🎯 详细开发任务

### 阶段 1: 语法扩展 (7天)

#### 1.1 SELECTCASE 语句 (2天)
**目标**: 实现完整的多分支选择结构

```swift
// 需要支持的语法
SELECTCASE A
    CASE 1
        PRINT "One"
    CASE 2 TO 5
        PRINT "Two to Five"
    CASEELSE
        PRINT "Other"
ENDSELECT
```

**实现步骤**:
- [ ] 在 `TokenType.swift` 添加 `.selectcase`, `.case`, `.caseelse`, `.endselect`
- [ ] 在 `ScriptParser.swift` 添加 `parseSelectCase()` 方法
- [ ] 在 `StatementAST.swift` 添加 `SelectCaseNode`
- [ ] 在 `StatementExecutor.swift` 添加 `executeSelectCase()` 方法
- [ ] 添加测试用例

**文件修改**:
- `EmueraCore/Parser/TokenType.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Executor/StatementExecutor.swift`

#### 1.2 TRY/CATCH 异常处理 (2天)
**目标**: 实现错误捕获和处理机制

```swift
// 需要支持的语法
TRY
    CALL 可能失败的函数
CATCH
    PRINT "发生错误"
ENDTRY
```

**实现步骤**:
- [ ] 添加异常类型和错误处理机制
- [ ] 在 `ScriptParser.swift` 添加 `parseTryCatch()`
- [ ] 在 `StatementExecutor.swift` 添加异常捕获逻辑
- [ ] 实现错误信息传递

#### 1.3 PRINTDATA/DATALIST (1天)
**目标**: 随机选择输出内容

```swift
PRINTDATA
    DATALIST
        PRINT "文本1"
        PRINTL "换行"
    ENDLIST
    DATALIST
        PRINT "文本2"
    ENDLIST
ENDDATA
```

#### 1.4 其他命令扩展 (2天)
- [ ] `REUSELASTLINE` - 重用最后一行
- [ ] `TIMES` - 小数计算
- [ ] `PRINTBUTTON` 增强 - 按钮样式
- [ ] `HTML_PRINT` - HTML格式输出
- [ ] `SETCOLOR` / `RESETCOLOR` - 颜色控制
- [ ] `FONTBOLD` / `FONTITALIC` - 字体样式

---

### 阶段 2: 保存/加载系统 (10天)

#### 2.1 变量持久化 (3天)
**目标**: 将变量状态保存到文件

**实现步骤**:
- [ ] 设计序列化格式（JSON 或自定义二进制）
- [ ] 实现 `VariableData` 的序列化/反序列化
- [ ] 添加 `SAVEVAR` / `LOADVAR` 命令
- [ ] 支持选择性保存（指定变量名）

**文件结构**:
```swift
// 保存格式示例
{
    "variables": {
        "DAY": 5,
        "MONEY": 1000,
        "A": [1, 2, 3, 0, 0],
        "CFLAG:0:5": 999
    },
    "characters": [...],
    "timestamp": "2025-12-21T10:00:00"
}
```

#### 2.2 游戏存档系统 (4天)
**目标**: 完整的 SAVE/LOAD 游戏状态

- [ ] `SAVEGAME slot` - 保存到指定槽位
- [ ] `LOADGAME slot` - 从槽位加载
- [ ] `SAVEGLOBAL` - 全局变量保存
- [ ] `LOADGLOBAL` - 全局变量加载
- [ ] 存档列表显示
- [ ] 存档版本管理

**文件路径**:
```
~/Library/Application Support/Emuera/
├── Saves/
│   ├── slot_001.sav
│   ├── slot_002.sav
│   └── global.sav
└── Config/
    └── settings.json
```

#### 2.3 数据持久化增强 (3天)
- [ ] `SAVETEXT` / `LOADTEXT` - 文本保存
- [ ] `SAVECHARA` / `LOADCHARA` - 角色数据
- [ ] `SAVESYSTEM` / `LOADSYSTEM` - 系统设置
- [ ] 自动保存机制
- [ ] 存档兼容性检查

---

### 阶段 3: ERH头文件系统 (8天)

#### 3.1 #FUNCTION 指令 (2天)
**目标**: 支持外部函数定义

```erh
#FUNCTION GET_MAX_HP
#DIM CHARACTER_ID
RETURNF BASE:CHARACTER_ID:0
```

**实现步骤**:
- [ ] 创建 `HeaderFileLoader.swift`
- [ ] 解析 #FUNCTION 指令
- [ ] 将外部函数注册到函数系统
- [ ] 处理函数依赖关系

#### 3.2 #DIM 定义 (2天)
**目标**: 全局变量和数组定义

```erh
#DIM GLOBAL MY_VAR
#DIM DYNAMIC MY_ARRAY, 100
#DIM REF MY_REF
```

#### 3.3 #DEFINE 宏替换 (2天)
**目标**: 预处理器宏

```erh
#DEFINE MAX_HP 1000
#DEFINE DAMAGE(x) (x * 2)
```

**实现步骤**:
- [ ] 宏定义解析器
- [ ] 宏替换机制
- [ ] 宏参数处理
- [ ] 预处理阶段集成

#### 3.4 头文件依赖管理 (2天)
- [ ] 多文件包含处理
- [ ] 循环依赖检测
- [ ] 预处理缓存
- [ ] 错误报告

---

### 阶段 4: 图形UI系统 (15天)

#### 4.1 窗口管理系统 (4天)
**目标**: 多窗口支持

```swift
// 需要支持的命令
CREATE_WINDOW id, x, y, width, height
SET_WINDOW id
CLOSE_WINDOW id
```

**实现步骤**:
- [ ] 窗口管理器类
- [ ] 窗口创建/销毁
- [ ] 窗口切换
- [ ] 窗口属性设置

**UI架构**:
```swift
class WindowManager {
    var windows: [Int: EmueraWindow]
    var currentWindow: Int
}

class EmueraWindow {
    var id: Int
    var frame: CGRect
    var content: [String]
    var style: WindowStyle
}
```

#### 4.2 图形绘制命令 (4天)
**目标**: 基础图形支持

- [ ] `PRINT_IMG path` - 显示图像
- [ ] `PRINT_RECT x, y, w, h` - 绘制矩形
- [ ] `PRINT_CIRCLE x, y, r` - 绘制圆形
- [ ] `PRINT_LINE x1, y1, x2, y2` - 绘制线条
- [ ] `PRINT_TEXT x, y, "text"` - 指定位置文本

**技术方案**:
- 使用 SwiftUI 的 `Canvas` 或 `Image`
- 支持相对/绝对坐标
- 缓存图像资源

#### 4.3 颜色和字体控制 (3天)
**目标**: 丰富的文本样式

- [ ] `SETCOLOR r, g, b` - 设置前景色
- [ ] `SETBGCOLOR r, g, b` - 设置背景色
- [ ] `RESETCOLOR` - 重置颜色
- [ ] `FONTBOLD` / `FONTITALIC` / `FONTUNDERLINE`
- [ ] `SETFONT "FontName"` - 设置字体
- [ ] `SETFONTSTYLE style` - 设置字体样式

**实现**:
```swift
class TextStyle {
    var foregroundColor: Color?
    var backgroundColor: Color?
    var font: Font?
    var isBold: Bool
    var isItalic: Bool
    var isUnderline: Bool
}
```

#### 4.4 菜单和选择系统 (4天)
**目标**: 交互式菜单

```swift
// 需要支持的语法
PRINTBUTTON "[1] 选项一", 1
PRINTBUTTON "[2] 选项二", 2
INPUT
SELECTCASE RESULT
    CASE 1
        ...
    CASE 2
        ...
ENDSELECT
```

**增强功能**:
- [ ] `PRINTBUTTON` 增强 - 支持样式、位置
- [ ] `PRINTCHOICE` - 选择列表
- [ ] `MENU` 命令 - 菜单系统
- [ ] `ASKCALL` - 询问调用
- [ ] 按钮高亮和悬停效果

---

### 阶段 5: 字符管理系统 (10天)

#### 5.1 角色数据结构 (3天)
**目标**: 完整的角色管理系统

```swift
struct CharacterData {
    var id: Int
    var name: String
    var callname: String

    // 基础属性
    var base: [Int]      // BASE:ID:INDEX
    var abl: [Int]       // ABL:ID:INDEX
    var talent: [Int]    // TALENT:ID:INDEX
    var exp: [Int]       // EXP:ID:INDEX

    // 二维属性
    var cflag: [[Int]]   // CFLAG:ID:INDEX
    var cstr: [String]   // CSTR:ID:INDEX

    // 关系数据
    var relation: [Int]  // RELATION:ID
}
```

**实现步骤**:
- [ ] 角色数据结构设计
- [ ] 角色数组管理
- [ ] 字符变量访问（CHARANUM等）
- [ ] 角色排序和筛选

#### 5.2 角色操作命令 (4天)
- [ ] `ADDCHARA id` - 添加角色
- [ ] `DELCHARA id` - 删除角色
- [ ] `SWAPCHARA id1, id2` - 交换角色
- [ ] `SORTCHARA key, order` - 排序角色
- [ ] `FINDCHARA condition` - 查找角色
- [ ] `CHARA_STATE id` - 角色状态

#### 5.3 角色变量扩展 (3天)
- [ ] 字符1D数组：BASE, ABL, TALENT, EXP
- [ ] 字符2D数组：CFLAG, CSTR
- [ ] 字符关系数组：RELATION
- [ ] 角色字符串：NAME, CALLNAME
- [ ] 角色特殊变量：CHARANUM, TARGET, MASTER

---

### 阶段 6: 游戏系统实现 (15天)

#### 6.1 SHOP 系统 (5天)
**目标**: 商店购买系统

```swift
// 需要支持的语法
SHOP
    ITEM 0, "回复药", 100, "恢复50HP"
    ITEM 1, "魔法药", 500, "恢复200MP"
    BUY 0, 10  // 购买10个
```

**实现**:
- [ ] `SHOP` 命令解析
- [ ] `ITEM` 定义
- [ ] `BUY` 购买逻辑
- [ ] 金钱扣除
- [ ] 物品数量管理
- [ ] 商店条件显示

#### 6.2 TRAIN 系统 (6天)
**目标**: 调教命令系统

```swift
// 需要支持的语法
TRAIN
    COM 0, "爱抚"
    COM 1, "クンニ"
    COM 2, "指挿入れ"
    ...
```

**实现**:
- [ ] `TRAIN` 命令框架
- [ ] `COM` 命令定义
- [ ] 调教参数计算
- [ ] 快感值计算
- [ ] 状态变化
- [ ] 结果反馈

#### 6.3 事件系统 (4天)
**目标**: 游戏事件处理

- [ ] `EVENT` 函数调用
- [ ] `EVENTTRAIN` - 调教前事件
- [ ] `EVENTEND` - 调教后事件
- [ ] `EVENTDAY` - 日期变化事件
- [ ] `EVENTCOM` - 命令执行事件
- [ ] 事件触发条件

---

### 阶段 7: 高级功能 (10天)

#### 7.1 动画系统 (3天)
**目标**: 基础动画支持

- [ ] `ANIMEPLAY` - 播放动画
- [ ] `ANIMESTOP` - 停止动画
- [ ] `ANIMEWAIT` - 等待动画
- [ ] 帧动画支持
- [ ] 位置动画

#### 7.2 声音系统 (3天)
**目标**: 音效和音乐

- [ ] `BGMPLAY` - 背景音乐
- [ ] `SEPLAY` - 音效
- [ ] `BGMSTOP` - 停止音乐
- [ ] `SESTOP` - 停止音效
- [ ] 音量控制
- [ ] 音频格式支持（MP3, WAV）

#### 7.3 调试和优化 (4天)
**目标**: 生产级质量

- [ ] 性能分析工具
- [ ] 内存泄漏检测
- [ ] 错误报告系统
- [ ] 日志级别控制
- [ ] 调试命令增强
- [ ] 单元测试覆盖

---

## 📅 Phase 3 时间线

### 第 1-2 周: 语法扩展
- Day 1-2: SELECTCASE
- Day 3-4: TRY/CATCH
- Day 5: PRINTDATA
- Day 6-7: 其他命令

### 第 3-4 周: 保存/加载系统
- Day 8-10: 变量持久化
- Day 11-14: 游戏存档

### 第 5-6 周: ERH头文件
- Day 15-16: #FUNCTION
- Day 17-18: #DIM/#DEFINE
- Day 19-20: 依赖管理

### 第 7-9 周: 图形UI系统
- Day 21-24: 窗口管理
- Day 25-28: 图形绘制
- Day 29-31: 颜色字体

### 第 10-11 周: 字符管理
- Day 32-34: 角色数据
- Day 35-38: 角色操作

### 第 12-14 周: 游戏系统
- Day 39-43: SHOP系统
- Day 44-49: TRAIN系统
- Day 50-52: 事件系统

### 第 15-16 周: 高级功能
- Day 53-55: 动画
- Day 56-58: 声音
- Day 59-60: 调试优化

---

## 🎯 Phase 3 里程碑

### M1: 语法完整 (第2周)
- ✅ SELECTCASE 支持
- ✅ TRY/CATCH 异常处理
- ✅ PRINTDATA 数据块
- ✅ 所有基础命令扩展

### M2: 数据持久化 (第4周)
- ✅ SAVE/LOAD 系统
- ✅ 变量序列化
- ✅ 存档管理
- ✅ 自动保存

### M3: 外部资源 (第6周)
- ✅ ERH头文件支持
- ✅ #FUNCTION 外部函数
- ✅ #DIM/#DEFINE 宏
- ✅ CSV增强解析

### M4: 图形界面 (第9周)
- ✅ 多窗口系统
- ✅ 图形绘制
- ✅ 颜色字体控制
- ✅ 菜单系统

### M5: 角色系统 (第11周)
- ✅ 角色数据管理
- ✅ 字符变量
- ✅ 角色操作命令
- ✅ 关系系统

### M6: 游戏系统 (第14周)
- ✅ SHOP商店
- ✅ TRAIN调教
- ✅ 事件处理
- ✅ 完整游戏循环

### M7: 生产就绪 (第16周)
- ✅ 动画声音
- ✅ 性能优化
- ✅ 错误处理
- ✅ 文档完善

---

## 📊 预期成果

### 功能完成度
```
Phase 2: 75%  ✅ 已完成
Phase 3: 95%  🎯 目标
完整版: 100%  🏁 最终目标
```

### 代码指标
- **总代码量**: ~25,000 行
- **测试覆盖率**: >80%
- **功能完整性**: 与原版 Emuera 100% 兼容

### 可交付物
1. ✅ 完整的 Emuera 引擎（Swift Package）
2. ✅ macOS 应用程序（SwiftUI）
3. ✅ 完整的测试套件
4. ✅ 详细的开发文档
5. ✅ 使用手册和示例

---

## 🚀 下一步行动

### 立即开始 (P0)
1. **SELECTCASE 语法解析** - 2天
2. **SAVE/LOAD 基础架构** - 3天

### 本周目标
- 完成 SELECTCASE 实现和测试
- 开始保存系统设计
- 更新 README 反映 Phase 3 计划

---

**文档版本**: v1.0
**创建日期**: 2025-12-21
**作者**: IceThunder + Claude Code AI
**状态**: 规划中
