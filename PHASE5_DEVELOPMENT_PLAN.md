# Phase 5 开发计划 - ERH头文件系统 + 图形UI增强 + 游戏系统

**目标**: 实现与原版 Emuera 100% 功能兼容，支持完整游戏运行
**时间**: 预计 45-60 天 (2025-12-25 至 2026-02-10)
**代码量**: 预计新增 ~15,000行 (当前: 30,800行 → 目标: 45,000+行)

---

## 📋 Phase 5 开发总览

### 核心模块划分

| 模块 | 优先级 | 预计工时 | 依赖关系 | 目标完成 |
|------|--------|----------|----------|----------|
| **1. ERH头文件系统** | P0 | 8天 | 文件服务 | 第1-2周 |
| **2. 图形UI增强** | P0 | 15天 | 基础UI | 第3-5周 |
| **3. 字符管理系统** | P1 | 10天 | 变量系统 | 第6-7周 |
| **4. SHOP商店系统** | P1 | 5天 | 字符管理 | 第8周 |
| **5. TRAIN调教系统** | P2 | 6天 | SHOP系统 | 第9周 |
| **6. 事件系统** | P2 | 4天 | TRAIN系统 | 第10周 |
| **7. 高级功能** | P3 | 10天 | 以上全部 | 第11-12周 |
| **8. 测试优化** | P0 | 2天 | 全部完成 | 第12周 |

**总计**: 60天 → 45-60天（根据进度调整）

---

## 🎯 详细开发任务

### 阶段 1: ERH头文件系统 (8天)

#### 1.1 HeaderFileLoader 增强 (2天)
**目标**: 完整的头文件加载和管理

**实现步骤**:
- [ ] 重构 `HeaderFileLoader.swift` 支持多文件
- [ ] 实现头文件依赖关系解析
- [ ] 添加循环依赖检测
- [ ] 实现预处理缓存机制
- [ ] 添加错误报告和定位

**功能特性**:
- [ ] 支持多文件包含（#INCLUDE）
- [ ] 头文件搜索路径管理
- [ ] 依赖关系图构建
- [ ] 缓存失效策略
- [ ] 详细的错误信息

**文件修改**:
- `EmueraCore/Parser/HeaderFileLoader.swift`
- `EmueraCore/Services/FileService.swift`

#### 1.2 #FUNCTION 指令 (2天)
**目标**: 外部函数定义支持

```erh
#FUNCTION GET_MAX_HP
#DIM CHARACTER_ID
RETURNF BASE:CHARACTER_ID:0

#FUNCTION GET_ABL_VALUE
#DIM CHARACTER_ID
#DIM ABL_INDEX
RETURNF ABL:CHARACTER_ID:ABL_INDEX
```

**实现步骤**:
- [ ] 在 `TokenType.swift` 添加 `.hashFunction` 类型
- [ ] 在 `ScriptParser.swift` 添加 `parseHashFunction()` 方法
- [ ] 在 `FunctionSystem.swift` 添加外部函数注册
- [ ] 在 `FunctionRegistry.swift` 添加外部函数解析
- [ ] 实现参数验证和类型检查

**功能特性**:
- [ ] 函数签名解析
- [ ] 参数类型验证
- [ ] 返回值类型推断
- [ ] 函数重载支持
- [ ] 命名空间管理

**文件修改**:
- `EmueraCore/Parser/TokenType.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Function/FunctionSystem.swift`
- `EmueraCore/Function/FunctionRegistry.swift`

#### 1.3 #DIM/#DEFINE 指令 (2天)
**目标**: 全局变量和宏定义

```erh
#DIM GLOBAL MY_VAR
#DIM DYNAMIC MY_ARRAY, 100
#DIM REF MY_REF

#DEFINE MAX_HP 1000
#DEFINE DAMAGE(x) (x * 2)
#DEFINE ADD_STATUS(var, value) var += value
```

**实现步骤**:
- [ ] 创建 `Preprocessor.swift` 预处理器
- [ ] 实现宏定义解析器
- [ ] 实现宏替换机制
- [ ] 实现宏参数处理
- [ ] 集成到解析流程

**功能特性**:
- [ ] 全局变量定义
- [ ] 动态数组大小
- [ ] 引用类型支持
- [ ] 简单宏替换
- [ ] 带参数宏
- [ ] 宏嵌套支持

**文件修改**:
- `EmueraCore/Parser/Preprocessor.swift` (新建)
- `EmueraCore/Parser/DefineMacro.swift` (增强)
- `EmueraCore/Parser/ScriptParser.swift`

#### 1.4 头文件依赖管理 (2天)
**目标**: 复杂的头文件系统

**实现步骤**:
- [ ] 依赖关系图构建
- [ ] 拓扑排序算法
- [ ] 循环依赖检测
- [ ] 增量预处理
- [ ] 错误定位和报告

**功能特性**:
- [ ] 自动包含管理
- [ ] 依赖缓存
- [ ] 版本检查
- [ ] 详细的错误信息
- [ ] 性能优化

**文件修改**:
- `EmueraCore/Parser/HeaderFileLoader.swift`
- `EmueraCore/Services/FileService.swift`

---

### 阶段 2: 图形UI增强 (15天)

#### 2.1 窗口管理系统 (4天)
**目标**: 多窗口支持

```swift
// 需要支持的命令
CREATE_WINDOW id, x, y, width, height
SET_WINDOW id
CLOSE_WINDOW id
MOVE_WINDOW id, x, y
RESIZE_WINDOW id, width, height
```

**实现步骤**:
- [ ] 创建 `WindowManager.swift` 窗口管理器
- [ ] 创建 `EmueraWindow.swift` 窗口类
- [ ] 在 `StatementAST.swift` 添加窗口相关语句
- [ ] 在 `ScriptParser.swift` 添加解析方法
- [ ] 在 `StatementExecutor.swift` 添加执行逻辑
- [ ] 在 `UI/` 目录添加SwiftUI实现

**数据结构**:
```swift
class WindowManager {
    var windows: [Int: EmueraWindow]
    var currentWindow: Int
    var nextWindowId: Int
}

class EmueraWindow {
    var id: Int
    var frame: CGRect
    var content: [String]
    var style: WindowStyle
    var isVisible: Bool
}

struct WindowStyle {
    var backgroundColor: Color?
    var textColor: Color?
    var font: Font?
    var borderColor: Color?
    var borderWidth: CGFloat
}
```

**文件修改**:
- `EmueraCore/UI/WindowManager.swift` (新建)
- `EmueraCore/UI/EmueraWindow.swift` (新建)
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/UI/MainWindow.swift` (增强)

#### 2.2 图形绘制命令 (4天)
**目标**: 基础图形支持

```swift
// 需要支持的命令
PRINT_IMG path, x, y, width, height
PRINT_RECT x, y, w, h, color, fill
PRINT_CIRCLE x, y, r, color, fill
PRINT_LINE x1, y1, x2, y2, color, width
PRINT_TEXT x, y, "text", color, font
PRINT_BAR current, max, x, y, width, height
```

**实现步骤**:
- [ ] 在 `StatementAST.swift` 添加图形语句
- [ ] 在 `ScriptParser.swift` 添加解析方法
- [ ] 在 `StatementExecutor.swift` 添加执行逻辑
- [ ] 创建 `GraphicsRenderer.swift` 图形渲染器
- [ ] 在 `UI/` 目录添加SwiftUI Canvas实现

**技术方案**:
- 使用 SwiftUI `Canvas` 进行自定义绘制
- 支持相对/绝对坐标
- 图像缓存机制
- 性能优化（批量绘制）

**文件修改**:
- `EmueraCore/UI/GraphicsRenderer.swift` (新建)
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/UI/ConsoleView.swift` (增强)

#### 2.3 颜色和字体控制 (3天)
**目标**: 丰富的文本样式

```swift
// 需要支持的命令
SETCOLOR r, g, b
SETBGCOLOR r, g, b
RESETCOLOR
FONTBOLD
FONTITALIC
FONTUNDERLINE
SETFONT "FontName"
SETFONTSTYLE style
SETFONTSIZE size
```

**实现步骤**:
- [ ] 创建 `TextStyleManager.swift` 样式管理器
- [ ] 在 `StatementAST.swift` 添加样式语句
- [ ] 在 `ScriptParser.swift` 添加解析方法
- [ ] 在 `StatementExecutor.swift` 添加执行逻辑
- [ ] 在 `UI/` 目录实现样式应用

**数据结构**:
```swift
class TextStyleManager {
    var currentStyle: TextStyle
    var styleStack: [TextStyle]
}

struct TextStyle {
    var foregroundColor: Color?
    var backgroundColor: Color?
    var font: Font?
    var isBold: Bool
    var isItalic: Bool
    var isUnderline: Bool
    var fontSize: CGFloat?
}
```

**文件修改**:
- `EmueraCore/UI/TextStyleManager.swift` (新建)
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/UI/ConsoleView.swift`

#### 2.4 菜单和选择系统 (4天)
**目标**: 交互式菜单

```swift
// 需要支持的语法
PRINTBUTTON "[1] 选项一", 1
PRINTBUTTON "[2] 选项二", 2
PRINTCHOICE "选项A" 1, "选项B" 2
INPUT
SELECTCASE RESULT
    CASE 1
        ...
    CASE 2
        ...
ENDSELECT
```

**实现步骤**:
- [ ] 增强 `PRINTBUTTON` 命令（位置、样式）
- [ ] 新增 `PRINTCHOICE` 命令
- [ ] 新增 `MENU` 命令框架
- [ ] 新增 `ASKCALL` 命令
- [ ] 实现按钮高亮和悬停效果
- [ ] 在UI中实现点击事件处理

**功能特性**:
- [ ] 按钮样式自定义
- [ ] 鼠标悬停效果
- [ ] 键盘导航支持
- [ ] 选择列表显示
- [ ] 条件显示/隐藏
- [ ] 快捷键支持

**文件修改**:
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/UI/ConsoleView.swift` (交互增强)
- `EmueraCore/UI/EmueraConsole.swift` (事件处理)

---

### 阶段 3: 字符管理系统 (10天)

#### 3.1 角色数据结构 (3天)
**目标**: 完整的角色管理系统

**实现步骤**:
- [ ] 重构 `CharacterData.swift` 结构
- [ ] 创建 `CharacterManager.swift` 管理器
- [ ] 在 `VariableData.swift` 添加角色数组
- [ ] 实现字符变量访问逻辑
- [ ] 添加角色特殊变量（CHARANUM, TARGET等）

**数据结构**:
```swift
struct CharacterData {
    var id: Int
    var name: String
    var callname: String

    // 基础属性 (1D数组)
    var base: [Int]      // BASE:ID:INDEX
    var abl: [Int]       // ABL:ID:INDEX
    var talent: [Int]    // TALENT:ID:INDEX
    var exp: [Int]       // EXP:ID:INDEX
    var mark: [Int]      // MARK:ID:INDEX
    var PALAM: [Int]     // PALAM:ID:INDEX

    // 二维属性
    var cflag: [[Int]]   // CFLAG:ID:INDEX
    var cstr: [String]   // CSTR:ID:INDEX

    // 关系数据
    var relation: [Int]  // RELATION:ID
    var source: [Int]    // SOURCE:ID:INDEX
}

class CharacterManager {
    var characters: [CharacterData]
    var masterIndex: Int
    var targetIndex: Int
    var assistantIndex: Int
}
```

**变量访问**:
```swift
// 需要支持的访问模式
BASE:0:0          // 角色0的基础属性0
ABL:1:5           // 角色1的素质5
TALENT:2:10       // 角色2的素质10
CFLAG:0:100       // 角色0的标志100
NAME:0            // 角色0的名字
CALLNAME:1        // 角色1的称呼
CHARANUM          // 角色数量
TARGET            // 当前目标索引
MASTER            // 主角索引
ASSI              // 助手索引
```

**文件修改**:
- `EmueraCore/Variable/CharacterData.swift` (重构)
- `EmueraCore/Variable/CharacterManager.swift` (新建)
- `EmueraCore/Variable/VariableData.swift` (增强)
- `EmueraCore/Variable/VariableCode.swift` (添加字符变量)
- `EmueraCore/Executor/ExpressionEvaluator.swift` (字符变量解析)

#### 3.2 角色操作命令 (4天)
**目标**: 角色管理命令

```swift
// 需要支持的命令
ADDCHARA id
DELCHARA id
SWAPCHARA id1, id2
SORTCHARA key, order
FINDCHARA condition
CHARA_STATE id
```

**实现步骤**:
- [ ] 在 `StatementAST.swift` 添加角色操作语句
- [ ] 在 `ScriptParser.swift` 添加解析方法
- [ ] 在 `StatementExecutor.swift` 添加执行逻辑
- [ ] 在 `CharacterManager.swift` 添加操作方法
- [ ] 实现角色查找和排序算法

**功能特性**:
- [ ] 添加/删除角色
- [ ] 角色交换
- [ ] 角色排序（按属性）
- [ ] 角色查找（按条件）
- [ ] 角色状态显示
- [ ] 批量操作支持

**文件修改**:
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/Variable/CharacterManager.swift`

#### 3.3 字符变量扩展 (3天)
**目标**: 字符变量系统完善

**实现步骤**:
- [ ] 实现字符1D数组访问（BASE, ABL, TALENT等）
- [ ] 实现字符2D数组访问（CFLAG, CSTR等）
- [ ] 实现角色字符串访问（NAME, CALLNAME等）
- [ ] 实现特殊变量（CHARANUM, TARGET等）
- [ ] 在表达式解析器中支持字符变量

**访问模式**:
```swift
// 1D字符数组
BASE:ID:INDEX
ABL:ID:INDEX
TALENT:ID:INDEX
EXP:ID:INDEX
MARK:ID:INDEX
PALAM:ID:INDEX
SOURCE:ID:INDEX

// 2D字符数组
CFLAG:ID:INDEX
CSTR:ID:INDEX

// 字符串变量
NAME:ID
CALLNAME:ID
CSTR:ID:INDEX

// 特殊变量
CHARANUM
MASTER
TARGET
ASSI
```

**文件修改**:
- `EmueraCore/Variable/VariableCode.swift` (添加字符变量代码)
- `EmueraCore/Variable/VariableToken.swift` (字符变量令牌)
- `EmueraCore/Parser/ExpressionParser.swift` (字符变量解析)
- `EmueraCore/Executor/ExpressionEvaluator.swift` (字符变量求值)

---

### 阶段 4: SHOP商店系统 (5天)

#### 4.1 SHOP命令框架 (2天)
**目标**: 商店系统基础

```swift
// 需要支持的语法
SHOP
    ITEM 0, "回复药", 100, "恢复50HP"
    ITEM 1, "魔法药", 500, "恢复200MP"
    ITEM 2, "大回复药", 1000, "恢复200HP"
    BUY 0, 10  // 购买10个
    BUY 1, 5   // 购买5个
```

**实现步骤**:
- [ ] 在 `StatementAST.swift` 添加 `ShopStatement` 和 `ItemDefinition`
- [ ] 在 `ScriptParser.swift` 添加 `parseShop()` 方法
- [ ] 在 `StatementExecutor.swift` 添加 `visitShopStatement()`
- [ ] 创建 `ShopManager.swift` 管理商品和购买逻辑
- [ ] 在UI中实现商店界面

**数据结构**:
```swift
struct ItemDefinition {
    var id: Int
    var name: String
    var price: Int
    var description: String
    var conditions: ExpressionNode?
}

class ShopManager {
    var items: [ItemDefinition]
    var currentSelection: Int
    var purchaseHistory: [Int: Int] // itemID -> quantity
}
```

**文件修改**:
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/Services/ShopManager.swift` (新建)
- `EmueraCore/UI/ShopView.swift` (新建)

#### 4.2 购买逻辑和金钱管理 (2天)
**目标**: 完整的购买流程

**实现步骤**:
- [ ] 实现金钱检查（MONEY变量）
- [ ] 实现库存管理（ITEM数组）
- [ ] 实现购买数量输入
- [ ] 实现条件显示（某些物品需要条件）
- [ ] 实现购买确认
- [ ] 实现金钱扣除和物品增加

**功能特性**:
- [ ] 金钱检查和扣除
- [ ] 库存数量管理
- [ ] 购买数量输入
- [ ] 条件物品显示
- [ ] 购买确认提示
- [ ] 批量购买支持
- [ ] 特殊物品（无限库存）

**文件修改**:
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/Services/ShopManager.swift`
- `EmueraCore/UI/ShopView.swift`

#### 4.3 商店条件和增强 (1天)
**目标**: 高级商店功能

**功能特性**:
- [ ] 条件显示（某些物品需要特定条件）
- [ ] 价格变动（基于变量）
- [ ] 特殊物品（一次性/无限）
- [ ] 商店事件
- [ ] 购买历史

**文件修改**:
- `EmueraCore/Services/ShopManager.swift`
- `EmueraCore/Parser/StatementAST.swift`

---

### 阶段 5: TRAIN调教系统 (6天)

#### 5.1 TRAIN命令框架 (2天)
**目标**: 调教系统基础

```swift
// 需要支持的语法
TRAIN
    COM 0, "爱抚"
    COM 1, "クンニ"
    COM 2, "指挿入れ"
    COM 3, "胸愛撫"
    ...
```

**实现步骤**:
- [ ] 在 `StatementAST.swift` 添加 `TrainStatement` 和 `CommandDefinition`
- [ ] 在 `ScriptParser.swift` 添加 `parseTrain()` 方法
- [ ] 在 `StatementExecutor.swift` 添加 `visitTrainStatement()`
- [ ] 创建 `TrainManager.swift` 管理命令和计算
- [ ] 在UI中实现TRAIN界面

**数据结构**:
```swift
struct CommandDefinition {
    var id: Int
    var name: String
    var description: String
    var cost: Int
    var conditions: ExpressionNode?
    var effects: [Effect]
}

struct Effect {
    var target: VariableValue
    var operation: String
    var value: ExpressionNode
}

class TrainManager {
    var commands: [CommandDefinition]
    var currentSelection: Int
    var turnCount: Int
}
```

**文件修改**:
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/Services/TrainManager.swift` (新建)
- `EmueraCore/UI/TrainView.swift` (新建)

#### 5.2 快感计算和状态变化 (2天)
**目标**: 调教参数计算

**实现步骤**:
- [ ] 实现快感值计算公式
- [ ] 实现PALAM（快感等级）更新
- [ ] 实现EXP（经验值）增加
- [ ] 实现ABL（素质）升级检查
- [ ] 实现SOURCE（来源）计算
- [ ] 实现状态反馈显示

**计算公式**:
```swift
// 快感计算
let basePleasure = COMMAND_PLEASURE * ABL感度 / 100
let finalPleasure = basePleasure * (1 + TALENT敏感度 * 0.5)

// PALAM升级检查
if PALAM >= 1000 then PALAMLV += 1

// ABL升级检查
if EXP >= ABLRequirement[ABL+1] then ABL += 1
```

**文件修改**:
- `EmueraCore/Services/TrainManager.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/UI/TrainView.swift`

#### 5.3 调教事件和结果 (2天)
**目标**: 调教流程完善

**实现步骤**:
- [ ] 实现调教前事件（EVENTTRAIN）
- [ ] 实现调教后事件（EVENTEND）
- [ ] 实现命令执行事件（EVENTCOM）
- [ ] 实现状态变化反馈
- [ ] 实现特殊状态（绝顶、射精等）
- [ ] 实现调教结果报告

**功能特性**:
- [ ] 事件触发系统
- [ ] 状态变化通知
- [ ] 特殊状态处理
- [ ] 调教日志
- [ ] 结果统计

**文件修改**:
- `EmueraCore/Services/TrainManager.swift`
- `EmueraCore/Executor/StatementExecutor.swift`
- `EmueraCore/UI/TrainView.swift`

---

### 阶段 6: 事件系统 (4天)

#### 6.1 EVENT函数调用 (2天)
**目标**: 事件驱动架构

```swift
// 需要支持的调用
CALL EVENTTRAIN
CALL EVENTEND
CALL EVENTCOM, 0
CALL EVENTDAY
```

**实现步骤**:
- [ ] 创建 `EventManager.swift` 事件管理器
- [ ] 实现事件注册和触发机制
- [ ] 在 `FunctionRegistry.swift` 添加事件函数
- [ ] 实现事件参数传递
- [ ] 实现事件链（事件触发事件）

**事件类型**:
- [ ] `EVENTTRAIN` - 调教前
- [ ] `EVENTEND` - 调教后
- [ ] `EVENTCOM` - 命令执行
- [ ] `EVENTDAY` - 日期变化
- [ ] `EVENTSHOP` - 商店进入
- [ ] `EVENTBUY` - 购买物品
- [ ] `EVENTSELL` - 出售物品

**文件修改**:
- `EmueraCore/Services/EventManager.swift` (新建)
- `EmueraCore/Function/FunctionRegistry.swift`
- `EmueraCore/Function/BuiltInFunctions.swift`

#### 6.2 事件触发条件 (2天)
**目标**: 条件事件系统

**实现步骤**:
- [ ] 实现事件条件检查
- [ ] 实现事件优先级
- [ ] 实现事件拦截
- [ ] 实现事件返回值处理
- [ ] 实现事件日志

**功能特性**:
- [ ] 条件触发
- [ ] 优先级管理
- [ ] 事件拦截
- [ ] 返回值处理
- [ ] 错误处理
- [ ] 性能优化

**文件修改**:
- `EmueraCore/Services/EventManager.swift`
- `EmueraCore/Function/FunctionRegistry.swift`

---

### 阶段 7: 高级功能 (10天)

#### 7.1 动画系统 (3天)
**目标**: 基础动画支持

```swift
// 需要支持的命令
ANIMEPLAY "animation_name"
ANIMESTOP
ANIMEWAIT
ANIMEPOS x, y
ANIMEFRAME frame
```

**实现步骤**:
- [ ] 创建 `AnimationManager.swift`
- [ ] 实现帧动画支持
- [ ] 实现位置动画
- [ ] 实现透明度动画
- [ ] 在UI中实现动画渲染

**文件修改**:
- `EmueraCore/UI/AnimationManager.swift` (新建)
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`

#### 7.2 声音系统 (3天)
**目标**: 音效和音乐

```swift
// 需要支持的命令
BGMPLAY "bgm.mp3"
SEPLAY "se.wav"
BGMSTOP
SESTOP
SETVOLUME volume
```

**实现步骤**:
- [ ] 创建 `AudioManager.swift`
- [ ] 实现BGM播放/停止
- [ ] 实现SE播放/停止
- [ ] 实现音量控制
- [ ] 实现音频格式支持

**技术方案**:
- 使用 AVFoundation 框架
- 支持 MP3, WAV, AAC
- 音频缓存
- 音量渐变

**文件修改**:
- `EmueraCore/Services/AudioManager.swift` (新建)
- `EmueraCore/Parser/StatementAST.swift`
- `EmueraCore/Parser/ScriptParser.swift`
- `EmueraCore/Executor/StatementExecutor.swift`

#### 7.3 调试和优化 (4天)
**目标**: 生产级质量

**实现步骤**:
- [ ] 性能分析工具
- [ ] 内存泄漏检测
- [ ] 错误报告系统
- [ ] 日志级别控制
- [ ] 调试命令增强
- [ ] 单元测试覆盖

**性能优化**:
- [ ] 表达式缓存
- [ ] 函数调用优化
- [ ] 内存池管理
- [ ] 并发处理

**文件修改**:
- `EmueraCore/Common/PerformanceMonitor.swift` (新建)
- `EmueraCore/Common/DebugTools.swift` (新建)
- `EmueraCore/Common/Logger.swift` (增强)
- `EmueraCore/Executor/StatementExecutor.swift` (优化)

---

### 阶段 8: 测试验证 (2天)

#### 8.1 综合测试套件
**目标**: 全面验证

**测试场景**:
- [ ] ERH头文件加载测试
- [ ] 多窗口UI测试
- [ ] 图形绘制测试
- [ ] 角色管理测试
- [ ] SHOP系统测试
- [ ] TRAIN系统测试
- [ ] 事件系统测试
- [ ] 性能测试

**测试文件**:
- `Sources/Phase5Debug/ERHTest.swift`
- `Sources/Phase5Debug/UITest.swift`
- `Sources/Phase5Debug/CharacterTest.swift`
- `Sources/Phase5Debug/ShopTest.swift`
- `Sources/Phase5Debug/TrainTest.swift`
- `Sources/Phase5Debug/EventTest.swift`

#### 8.2 性能优化和发布准备
**目标**: 生产就绪

**任务**:
- [ ] 性能基准测试
- [ ] 内存使用分析
- [ ] 代码覆盖率检查
- [ ] 文档完善
- [ ] 发布包准备

---

## 📊 Phase 5 预期成果

### 功能完成度
```
Phase 2: 核心引擎      100% ✅ (已完成)
Phase 3: 语法扩展      100% ✅ (已完成)
Phase 4: 数据持久化    100% ✅ (已完成)
Phase 5: 完整系统      100% ✅ (目标)

完整Emuera:           100% ✅ (最终目标)
```

### 代码指标
- **总代码量**: ~45,000+ 行
- **测试覆盖率**: >85%
- **功能完整性**: 与原版 100% 兼容
- **性能**: 流畅运行复杂游戏

### 可交付物
1. ✅ 完整的 Emuera 引擎（Swift Package）
2. ✅ macOS 应用程序（SwiftUI，完整UI）
3. ✅ 完整的测试套件（100+测试）
4. ✅ 详细的开发文档
5. ✅ 使用手册和示例游戏
6. ✅ ERH头文件示例
7. ✅ 完整的API文档

---

## 🚀 开发路线图

### 第 1-2 周 (12/25 - 1/7)
- ✅ ERH头文件系统
- ✅ #FUNCTION, #DIM, #DEFINE
- ✅ 头文件依赖管理

### 第 3-5 周 (1/8 - 1/28)
- ✅ 窗口管理系统
- ✅ 图形绘制命令
- ✅ 颜色字体控制
- ✅ 菜单系统

### 第 6-7 周 (1/29 - 2/11)
- ✅ 角色数据结构
- ✅ 角色操作命令
- ✅ 字符变量扩展

### 第 8 周 (2/12 - 2/18)
- ✅ SHOP商店系统
- ✅ 购买逻辑

### 第 9 周 (2/19 - 2/25)
- ✅ TRAIN调教系统
- ✅ 快感计算

### 第 10 周 (2/26 - 3/4)
- ✅ 事件系统
- ✅ EVENT函数

### 第 11-12 周 (3/5 - 3/18)
- ✅ 动画声音
- ✅ 调试优化
- ✅ 测试验证
- ✅ 文档完善

---

## 📚 依赖关系和前置条件

### 必须完成的前置任务
1. ✅ Phase 4 所有功能
2. ✅ 变量系统稳定
3. ✅ 表达式解析器稳定
4. ✅ 函数系统稳定

### 推荐的开发顺序
1. **ERH系统** → 为其他模块提供外部函数支持
2. **UI增强** → 为SHOP/TRAIN提供界面
3. **字符管理** → 为SHOP/TRAIN提供数据
4. **SHOP/TRAIN** → 完整游戏循环
5. **事件系统** → 游戏逻辑完整性
6. **高级功能** → 生产级质量

---

## 🎯 关键技术挑战

### 1. ERH头文件依赖解析
**挑战**: 复杂的依赖关系和循环依赖
**方案**: 拓扑排序 + 循环检测 + 增量处理

### 2. 多窗口UI架构
**挑战**: 窗口管理、焦点切换、事件路由
**方案**: MVC模式 + 事件委托 + 状态管理

### 3. 字符变量性能
**挑战**: 大量角色数据的高效访问
**方案**: 索引优化 + 缓存 + 懒加载

### 4. 调教计算复杂性
**挑战**: 多重公式和状态变化
**方案**: 公式引擎 + 状态机 + 事件触发

### 5. 事件系统性能
**挑战**: 大量事件的高效处理
**方案**: 事件队列 + 优先级 + 异步处理

---

## 📝 开发建议

### 代码风格
- 遵循 Swift API Design Guidelines
- 使用 Protocol 和 Extension
- 保持函数纯净（无副作用）
- 完善的错误处理

### 测试策略
- TDD（测试驱动开发）
- 单元测试 + 集成测试
- 性能基准测试
- 边界条件测试

### 文档要求
- 每个模块都有README
- API文档（SwiftDoc）
- 使用示例
- 变更日志

### 版本控制
- 功能分支开发
- 清晰的提交信息
- 定期rebase
- 代码审查

---

## 🏆 Phase 5 里程碑

### M1: ERH系统完成 (第2周)
- ✅ 头文件加载
- ✅ #FUNCTION/#DIM/#DEFINE
- ✅ 依赖管理

### M2: UI增强完成 (第5周)
- ✅ 多窗口系统
- ✅ 图形绘制
- ✅ 颜色字体
- ✅ 菜单系统

### M3: 字符系统完成 (第7周)
- ✅ 角色数据结构
- ✅ 角色操作
- ✅ 字符变量

### M4: 游戏系统完成 (第10周)
- ✅ SHOP商店
- ✅ TRAIN调教
- ✅ 事件系统

### M5: 生产就绪 (第12周)
- ✅ 动画声音
- ✅ 性能优化
- ✅ 完整测试
- ✅ 文档完善

---

## 📚 相关文档

- [STATUS.md](./STATUS.md) - 项目状态看板
- [README.md](./README.md) - 项目总览
- [PHASE3_DEVELOPMENT_PLAN.md](./PHASE3_DEVELOPMENT_PLAN.md) - Phase 3计划
- [PHASE4_DEVELOPMENT_PLAN.md](./PHASE4_DEVELOPMENT_PLAN.md) - Phase 4计划

---

**文档版本**: v1.0
**创建日期**: 2025-12-24
**最后更新**: 2025-12-24 03:00
**作者**: IceThunder + Claude Code AI
**状态**: 📋 规划完成
**上一阶段**: Phase 4 ✅ 完成
**下一阶段**: Phase 5 🚀 待开始
