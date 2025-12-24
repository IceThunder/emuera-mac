# Emuera macOS移植开发计划 (2025-12-24 更新 - Priority 1优先级)

## 📋 任务概述

将Emuera游戏引擎从Windows/.NET Framework移植到macOS/Swift，开发一个能够运行现有ERB脚本的原生macOS应用。

**当前状态**: 🟢 **Phase 2-6完成，准备开始Priority 1开发**
**实际进度**: **60%** (核心引擎100% + Phase 3语法扩展100% + Phase 4数据持久化100% + Phase 5 GUI增强100% + Phase 6字符管理100%)
**代码量**: ~38,000行 (170+个Swift文件)
**测试状态**: ✅ **全部通过** (180+项测试)
**最新里程碑**: **2025-12-24** - Phase 6完成，原版对比分析完成

---

## 🎯 原版Emuera对比分析 (2025-12-24)

### 原始项目统计
- **原版文件数**: 109个C#文件
- **原版命令总数**: 266+个FunctionCode
- **原版内置函数**: 100+个
- **原版完整度**: 100% (完整功能)

### 当前移植进度

| 功能类别 | 原版数量 | 已移植 | 完成度 | 状态 |
|----------|----------|--------|--------|------|
| **核心命令** | 50+ | 50+ | 100% | ✅ |
| **流程控制** | 15+ | 15+ | 100% | ✅ |
| **数据操作** | 20+ | 17+ | 85% | 🟡 |
| **I/O命令** | 40+ | 30+ | 75% | 🟡 |
| **图形命令** | 15+ | 5+ | 33% | 🔴 |
| **文件操作** | 15+ | 10+ | 67% | 🟡 |
| **系统命令** | 20+ | 15+ | 75% | 🟡 |
| **调试命令** | 10+ | 8+ | 80% | 🟡 |
| **内置函数** | 100+ | 50+ | 50% | 🔴 |
| **ERH系统** | 完整 | 部分 | 60% | 🟡 |
| **字符管理** | 完整 | 完整 | 100% | ✅ |
| **GUI系统** | 完整 | 部分 | 50% | 🟡 |
| **SHOP系统** | 完整 | 0% | 0% | 🔴 |
| **TRAIN系统** | 完整 | 0% | 0% | 🔴 |
| **事件系统** | 完整 | 0% | 0% | 🔴 |

**总体进度**: **60%** ✅

---

## ✅ 已完成工作 (2025-12-18 ~ 12-24)

### Phase 2: 核心引擎 ✅ 100%
- ✅ 词法分析器 (LexicalAnalyzer)
- ✅ 表达式解析器 (ExpressionParser)
- ✅ 语法解析器 (ScriptParser)
- ✅ 语句执行器 (StatementExecutor)
- ✅ 内置函数库 (50+函数)
- ✅ 函数系统 (@function, RETURNF)
- ✅ Process系统 (调用栈管理)
- ✅ 文件服务 (ERB/CSV加载)
- ✅ UI系统 (SwiftUI控制台)

### Phase 3: 语法扩展 ✅ 100%
- ✅ SELECTCASE - 多分支选择
- ✅ TRY/CATCH - 异常处理
- ✅ PRINTDATA - 随机数据输出
- ✅ DO-LOOP - 条件循环
- ✅ REPEAT - 计数循环

### Phase 4: 数据持久化 ✅ 100%
- ✅ RESETDATA - 重置变量
- ✅ RESETGLOBAL - 重置全局数组
- ✅ PERSIST - 持久化控制
- ✅ SAVEDATA/LOADDATA - 变量保存
- ✅ SAVECHARA/LOADCHARA - 角色保存
- ✅ SAVEGAME/LOADGAME - 游戏存档
- ✅ SAVELIST/SAVEEXISTS - 存档管理
- ✅ AUTOSAVE/SAVEINFO - 高级功能

### Phase 5: GUI增强系统 ✅ 100%
- ✅ 增强属性 (背景色、字体、透明度等)
- ✅ 新行类型 (进度条、表格、标题等)
- ✅ 主题系统 (6种主题 + 自定义)
- ✅ 渲染架构 (现代化SwiftUI)

### Phase 6: 字符管理系统 ✅ 100%
- ✅ 17个新命令 (ADDCHARA到CHARAEXISTS)
- ✅ 完整AST节点
- ✅ 角色UI可视化
- ✅ 9组存储系统

---

## 🎯 Priority 1-3 开发计划 (2025-12-25 ~ 2026-01-15)

### 🔴 Priority 1 (紧急 - 2025-12-25 ~ 2026-01-05)

#### 1. D系列输出命令 (2天)
**目标**: 实现带变量格式化的输出命令

| 命令 | 说明 | 状态 |
|------|------|------|
| **PRINTD** | 输出不换行 (不解析{}和%) | ⏳ |
| **PRINTDL** | 输出并换行 | ⏳ |
| **PRINTDW** | 输出并等待输入 | ⏳ |
| **PRINTVD** | 输出变量内容 | ⏳ |
| **PRINTVL** | 变量内容换行 | ⏳ |
| **PRINTVW** | 变量内容等待 | ⏳ |
| **PRINTSD** | 输出字符串变量 | ⏳ |
| **PRINTSL** | 字符串变量换行 | ⏳ |
| **PRINTSW** | 字符串变量等待 | ⏳ |
| **PRINTFORMD** | 格式化输出 | ⏳ |
| **PRINTFORMDL** | 格式化输出换行 | ⏳ |
| **PRINTFORMDW** | 格式化输出等待 | ⏳ |

**实现步骤**:
1. 在Command.swift中添加D系列命令枚举
2. 在ScriptParser.swift中添加parsePrintDCommand方法
3. 在StatementAST.swift中添加PrintDStatement节点
4. 在StatementExecutor.swift中添加executePrintD方法
5. 编写测试用例验证功能

#### 2. SIF命令 (1天)
**目标**: 实现一行条件语句

| 命令 | 说明 | 状态 |
|------|------|------|
| **SIF** | 一行IF (条件满足时执行下一行) | ⏳ |

**实现步骤**:
1. 添加SIF命令到Command.swift
2. 在ScriptParser中添加parseSIFStatement方法
3. 设计SIFStatement AST节点
4. 在执行器中实现特殊逻辑 (下一行执行控制)
5. 编写测试用例

#### 3. TRYC系列异常处理 (3天)
**目标**: 完整的TRYC异常处理系统

| 命令 | 说明 | 状态 |
|------|------|------|
| **TRYCCALL** | 带CATCH的函数调用 | ⏳ |
| **TRYCGOTO** | 带CATCH的跳转 | ⏳ |
| **TRYCJUMP** | 带CATCH的JUMP | ⏳ |
| **TRYCCALLFORM** | 格式化函数调用 | ⏳ |
| **TRYCGOTOFORM** | 格式化跳转 | ⏳ |
| **TRYCJUMPFORM** | 格式化JUMP | ⏳ |
| **TRYCALLLIST** | 函数调用列表 | ⏳ |
| **TRYJUMPLIST** | JUMP列表 | ⏳ |
| **TRYGOTOLIST** | GOTO列表 | ⏳ |

**实现步骤**:
1. 扩展TryCatchStatement支持CATCH标签
2. 添加TRYC系列命令到Command.swift
3. 在ScriptParser中添加解析方法
4. 在StatementExecutor中实现CATCH逻辑
5. 编写完整的异常处理测试

#### 4. 字符串高级函数 (3天)
**目标**: 增强字符串处理能力

| 函数 | 说明 | 状态 |
|------|------|------|
| **STRLENS** | 字符串长度 (字符数) | ⏳ |
| **SUBSTRING** | 子字符串 | ⏳ |
| **STRFIND** | 字符串查找 | ⏳ |
| **STRCOUNT** | 字符串计数 | ⏳ |
| **REPLACE** | 字符串替换 | ⏳ |
| **ESCAPE** | 转义处理 | ⏳ |
| **TOUPPER** | 转大写 | ⏳ |
| **TOLOWER** | 转小写 | ⏳ |
| **TRIM** | 去除空白 | ⏳ |
| **BARSTRING** | 进度条字符串 | ⏳ |
| **SPLIT** | 字符串分割 | ⏳ |

**实现步骤**:
1. 在BuiltInFunctions.swift中添加新函数
2. 在FunctionRegistry中注册
3. 在ExpressionEvaluator中支持调用
4. 编写函数测试用例

#### 5. 数组高级函数 (2天)
**目标**: 增强数组处理能力

| 函数 | 说明 | 状态 |
|------|------|------|
| **FINDELEMENT** | 查找元素 | ⏳ |
| **FINDLAST** | 反向查找 | ⏳ |
| **UNIQUE** | 去重 | ⏳ |
| **SORT** | 排序 | ⏳ |
| **REVERSE** | 反转 | ⏳ |
| **VARSIZE** | 数组大小 | ⏳ |
| **SUMARRAY** | 数组求和 | ⏳ |

**实现步骤**:
1. 在BuiltInFunctions.swift中添加数组函数
2. 处理数组参数和返回值
3. 在FunctionRegistry中注册
4. 编写数组函数测试

**Priority 1 总计**: **11天**

---

### 🟡 Priority 2 (重要 - 2026-01-06 ~ 2026-01-10)

#### 1. 图形绘制命令 (3天)
- DRAWLINE, CUSTOMDRAWLINE, DRAWLINEFORM
- BAR, BARL
- SETCOLOR, RESETCOLOR, SETBGCOLOR, RESETBGCOLOR

#### 2. 输入命令扩展 (2天)
- TINPUT, TINPUTS (带超时)
- ONEINPUT, ONEINPUTS (单键)
- TONEINPUT, TONEINPUTS
- AWAIT (输入不可用)

#### 3. 位运算命令 (1天)
- SETBIT, CLEARBIT, INVERTBIT

#### 4. 数组操作命令 (1天)
- ARRAYSHIFT, ARRAYREMOVE, ARRAYSORT, ARRAYCOPY

**Priority 2 总计**: **7天**

---

### 🟢 Priority 3 (完善 - 2026-01-11 ~ 2026-01-15)

#### 1. ERH完整系统 (3天)
- #FUNCTION, #DIM, #DEFINE, #GLOBAL, #INCLUDE
- 宏展开和预处理
- 头文件依赖管理

#### 2. SHOP系统 (2天)
- SHOP, SHOP_DATA
- BUY, SELL
- 金钱管理

#### 3. TRAIN系统 (3天)
- TRAIN, EXTRAIN
- SOURCE, PALAM
- 状态变化计算

#### 4. 事件系统 (2天)
- EVENT, EVENTUSER
- EVENTTRAIN, EVENTEND
- 触发条件处理

#### 5. 高级功能 (3天)
- 动画、声音
- 调试优化
- 性能提升

**Priority 3 总计**: **13天**

---

## 📊 详细开发指南

### 开发工作流
```bash
# 1. 分析原版代码
grep -r "PRINTD\|SIF\|TRYC" /path/to/original/Emuera --include="*.cs"

# 2. 设计Swift方案
# - 定义CommandType枚举
# - 设计AST节点结构
# - 规划解析器逻辑

# 3. 实现核心功能
# - 添加命令到Command.swift
# - 实现解析方法
# - 创建AST节点
# - 实现执行逻辑

# 4. 编写测试
# - 创建测试文件
# - 验证功能正确性
# - 确保与原版兼容

# 5. 提交代码
git add .
git commit -m "feat: 实现PRINTD系列命令"
git push
```

### 代码规范
```swift
// ✅ 推荐
public class PrintDStatement: StatementNode {
    public let format: ExpressionNode
    public let arguments: [ExpressionNode]

    public init(format: ExpressionNode, arguments: [ExpressionNode], position: ScriptPosition? = nil) {
        self.format = format
        self.arguments = arguments
        super.init(position: position)
    }
}

// ❌ 不推荐
var fmt: ExpressionNode
var args: [ExpressionNode]
```

### 测试策略
1. **单元测试**: 每个命令独立测试
2. **集成测试**: 组合使用测试
3. **兼容性测试**: 与原版行为对比
4. **性能测试**: 大量数据处理

---

## 🎯 里程碑计划

### MVP v1.0 (预计2026-01-05)
**目标**: Priority 1功能完成
- ✅ D系列输出命令
- ✅ SIF命令
- ✅ TRYC系列异常处理
- ✅ 字符串高级函数
- ✅ 数组高级函数

### Beta v1.1 (预计2026-01-10)
**目标**: Priority 2功能完成
- ✅ Priority 1所有功能
- ✅ 图形绘制命令
- ✅ 输入命令扩展
- ✅ 位运算命令
- ✅ 数组操作命令

### 正式版 v1.2 (预计2026-01-15)
**目标**: 完整功能移植
- ✅ Beta v1.1所有功能
- ✅ Priority 3所有功能
- ✅ 完整测试覆盖
- ✅ 性能优化
- ✅ 用户文档

---

## 📋 任务清单 (按优先级)

### 立即开始 (Priority 1) - 预计11天
- [ ] **D系列输出命令** (9个): PRINTD, PRINTDL, PRINTDW, PRINTVD, PRINTVL, PRINTVW, PRINTSD, PRINTSL, PRINTSW
- [ ] **SIF命令** (1个): 一行条件语句
- [ ] **TRYC系列异常处理** (10+个): TRYCCALL, TRYCGOTO, TRYCJUMP, TRYCCALLFORM, TRYCGOTOFORM, TRYCJUMPFORM, TRYCALLLIST, TRYJUMPLIST, TRYGOTOLIST
- [ ] **字符串高级函数** (11个): STRLENS, SUBSTRING, STRFIND, STRCOUNT, REPLACE, ESCAPE, TOUPPER, TOLOWER, TRIM, BARSTRING, SPLIT
- [ ] **数组高级函数** (7个): FINDELEMENT, FINDLAST, UNIQUE, SORT, REVERSE, VARSIZE, SUMARRAY

### 下一步 (Priority 2) - 预计7天
- [ ] **图形绘制命令** (15+个): DRAWLINE, CUSTOMDRAWLINE, DRAWLINEFORM, BAR, BARL, SETCOLOR, RESETCOLOR, SETBGCOLOR, RESETBGCOLOR
- [ ] **输入命令扩展** (10+个): TINPUT, TINPUTS, ONEINPUT, ONEINPUTS, TONEINPUT, TONEINPUTS, AWAIT
- [ ] **位运算命令** (3个): SETBIT, CLEARBIT, INVERTBIT
- [ ] **数组操作命令** (4个): ARRAYSHIFT, ARRAYREMOVE, ARRAYSORT, ARRAYCOPY

### 完善阶段 (Priority 3) - 预计13天
- [ ] **ERH完整系统** (3天): #FUNCTION, #DIM, #DEFINE, #GLOBAL, #INCLUDE (完整实现)
- [ ] **SHOP系统** (2天): SHOP, SHOP_DATA, BUY, SELL, 金钱管理
- [ ] **TRAIN系统** (3天): TRAIN, EXTRAIN, SOURCE, PALAM, 状态变化
- [ ] **事件系统** (2天): EVENT, EVENTUSER, EVENTTRAIN, EVENTEND
- [ ] **高级功能** (3天): 动画、声音、视频、网络、调试优化

---

## 🔧 关键技术决策

### 1. D系列命令设计
**决策**: 使用与PRINT系列相同的架构，但不解析{}和%
- **优势**: 保持一致性，易于维护
- **实现**: 在解析时标记为"D系列"，执行时跳过格式化
- **结果**: 与原版行为完全一致

### 2. SIF特殊逻辑
**决策**: SIF影响下一行的执行
- **优势**: 准确模拟原版行为
- **实现**: 在执行器中设置SIF状态标志
- **结果**: 正确处理一行条件语句

### 3. TRYC异常处理
**决策**: 扩展现有TRY/CATCH系统
- **优势**: 复用现有基础设施
- **实现**: 添加CATCH标签支持，增强错误捕获
- **结果**: 完整的异常处理链

---

## 📈 预期成果

### 代码指标
- **新增代码**: ~8,000行
- **新增文件**: ~30个
- **新增测试**: ~80项
- **总代码**: ~46,000行

### 功能指标
- **原版命令**: 266+ → 200+ (75%)
- **原版函数**: 100+ → 75+ (75%)
- **整体进度**: 60% → 85%

### 时间投入
- **Priority 1**: 11天 (D系列/SIF/TRYC/字符串/数组函数)
- **Priority 2**: 7天 (图形/输入/位运算/数组操作)
- **Priority 3**: 13天 (ERH/SHOP/TRAIN/事件/高级功能)
- **总计**: 31天 (约1个月) - 2026-01-15完成

---

## 🎯 总结

**当前状态**: 🟢 **Phase 2-6完成，准备开始Priority 1开发**
**下一步**: 实现D系列输出命令、SIF、TRYC系列、字符串高级函数
**预计完成**: 2026-01-15 (完整功能移植)
**剩余工作**: **40%** (Priority 1-3功能) - **21天开发时间**

**宣言**:
> "Phase 2-6已经构建了完整的引擎骨架和核心功能。
> 现在我们需要填充血肉——Priority 1功能将使引擎真正实用。
> 通过系统化的开发流程，我们将逐步实现与原版100%兼容。"

**开发流程**:
1. ✅ 分析原版C#代码逻辑
2. ✅ 设计Swift实现方案
3. ✅ 实现AST节点和解析器
4. ✅ 实现执行器逻辑
5. ✅ 编写测试用例
6. ✅ 提交git并更新文档

---

*本文件与 STATUS.md 和 README.md 保持同步*
*最后更新: 2025-12-24 23:30*
*开发阶段: Phase 7 - Priority 1 开发准备*
