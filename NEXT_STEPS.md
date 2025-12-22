# 下一步开发计划 - Phase 3

## 📊 当前状态总结

### ✅ 已完成 (2025-12-23)
- **TRY/CATCH异常处理系统** - 12/12测试通过
- **原版兼容性** - 核心功能100%一致
- **项目进度** - 78% (Phase 2完成 + Phase 3 25%)

### 📋 功能对比结果
```
核心功能: ✅ 100% (4/4) - 完全一致
扩展功能: ❌ 0% (0/4) - 待实现
整体完成度: 50% (4/8) - 核心完整
```

---

## 🎯 下一步优先级 (P0 - P2)

### P0: 立即开始 (本周内)

#### 1. SELECTCASE 语法解析 (2天)
**目标**: 实现多分支选择结构

```erlang
SELECTCASE A
    CASE 1
        PRINT "One"
    CASE 2 TO 5
        PRINT "Two to Five"
    CASEELSE
        PRINT "Other"
ENDSELECT
```

**任务清单**:
- [ ] 添加TokenType: `.selectcase`, `.case`, `.caseelse`, `.endselect`
- [ ] 实现parseSelectCase()方法
- [ ] 添加SelectCaseStatement AST节点
- [ ] 实现visitSelectCaseStatement()执行逻辑
- [ ] 添加测试用例

**文件修改**:
- `Sources/EmueraCore/Parser/TokenType.swift`
- `Sources/EmueraCore/Parser/ScriptParser.swift`
- `Sources/EmueraCore/Parser/StatementAST.swift`
- `Sources/EmueraCore/Executor/StatementExecutor.swift`

#### 2. SAVE/LOAD 基础架构 (3天)
**目标**: 数据持久化基础

**任务清单**:
- [ ] 设计序列化格式（JSON）
- [ ] 实现VariableData序列化
- [ ] 添加SAVEVAR/LOADVAR命令
- [ ] 支持选择性保存

---

### P1: 本周后续 (12/24-12/29)

#### 3. PRINTDATA/DATALIST (1天)
```erlang
PRINTDATA
    DATALIST
        PRINT "文本1"
    ENDLIST
    DATALIST
        PRINT "文本2"
    ENDLIST
ENDDATA
```

#### 4. 其他命令扩展 (2天)
- [ ] `REUSELASTLINE` - 重用最后一行
- [ ] `TIMES` - 小数计算
- [ ] `PRINTBUTTON` 增强
- [ ] `HTML_PRINT` - HTML输出
- [ ] `SETCOLOR`/`RESETCOLOR` - 颜色控制
- [ ] `FONTBOLD`/`FONTITALIC` - 字体样式

---

### P2: 下周计划 (12/30-1/5)

#### 5. 游戏存档系统 (4天)
- [ ] `SAVEGAME slot` - 保存到槽位
- [ ] `LOADGAME slot` - 从槽位加载
- [ ] 存档列表显示
- [ ] 存档版本管理

#### 6. 数据持久化增强 (3天)
- [ ] `SAVETEXT`/`LOADTEXT` - 文本保存
- [ ] `SAVECHARA`/`LOADCHARA` - 角色数据
- [ ] 自动保存机制

---

## 📅 时间线规划

### 本周 (12/23-12/29)
- **Day 1-2**: SELECTCASE实现
- **Day 3**: PRINTDATA实现
- **Day 4-5**: 其他命令扩展
- **Day 6-7**: SAVE/LOAD基础架构

### 下周 (12/30-1/5)
- **Day 8-10**: 游戏存档系统
- **Day 11-12**: 数据持久化增强
- **Day 13-14**: 测试和优化

---

## 🎯 里程碑目标

### M1: 语法扩展完成 (12/29)
- ✅ TRY/CATCH (已完成)
- ⏳ SELECTCASE
- ⏳ PRINTDATA
- ⏳ 其他命令扩展

### M2: 数据持久化完成 (1/5)
- ⏳ SAVE/LOAD系统
- ⏳ 变量序列化
- ⏳ 存档管理

### M3: ERH头文件系统 (1/12)
- ⏳ #FUNCTION指令
- ⏳ #DIM/#DEFINE
- ⏳ 头文件依赖管理

---

## 📋 每日开发计划

### 今天 (12/23) - 已完成 ✅
- ✅ TRY/CATCH功能对比
- ✅ 更新项目文档
- ✅ 制定下一步计划

### 明天 (12/24) - Day 1
- [ ] 开始SELECTCASE实现
- [ ] 添加TokenType
- [ ] 实现parseSelectCase()

### 后天 (12/25) - Day 2
- [ ] 完成SELECTCASE AST
- [ ] 实现执行逻辑
- [ ] 添加测试用例

---

## 📝 需要的决策

### 技术选择
1. **序列化格式**: JSON vs 自定义二进制
   - 推荐: JSON（易调试、易维护）

2. **文件路径管理**:
   - macOS标准: `~/Library/Application Support/Emuera/`
   - 需要实现跨平台路径处理

3. **错误信息存储**:
   - 是否需要实现错误信息变量？
   - 优先级: P1（中等）

---

## 🎯 成功标准

### 代码质量
- ✅ 所有测试通过
- ✅ 代码覆盖率 >80%
- ✅ 与原版Emuera兼容性 >95%

### 功能完整性
- ✅ 核心语法扩展完成
- ✅ 数据持久化可用
- ✅ 错误处理完善

### 文档
- ✅ API文档完整
- ✅ 使用示例丰富
- ✅ 迁移指南清晰

---

## 🚀 开始行动

```bash
# 1. 查看当前状态
cd /Users/tlkid/Documents/projects/scripts/emuera-mac
cat STATUS.md

# 2. 开始SELECTCASE开发
# 编辑: Sources/EmueraCore/Parser/TokenType.swift
# 编辑: Sources/EmueraCore/Parser/ScriptParser.swift
# 编辑: Sources/EmueraCore/Parser/StatementAST.swift
# 编辑: Sources/EmueraCore/Executor/StatementExecutor.swift

# 3. 运行测试验证
swift run SelectCaseTest

# 4. 更新文档
# 编辑: PHASE3_DEVELOPMENT_PLAN.md
# 编辑: STATUS.md
```

---

**下一步**: 立即开始SELECTCASE语法解析的实现！

**联系**: 如有问题或需要调整计划，请随时告知。
