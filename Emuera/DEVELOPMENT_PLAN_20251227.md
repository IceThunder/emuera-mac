# Emuera Swift移植 - 开发计划 (2025-12-27更新)

## 📊 当前状态摘要

```
项目进度: 66.2% (200/302个命令)
当前阶段: 阶段2 - 执行逻辑完善
剩余工作: ~102个命令
预计完成: 7-10天 (阶段2)
```

---

## 🎯 核心目标

### 立即目标 (Week 1)
**完成阶段2: 100%命令执行逻辑覆盖**

- 剩余命令: ~102个
- 每日目标: 10-15个命令
- 时间估算: 7-10天

---

## 📋 每日开发计划

### Day 1 (12/27) - 流程控制基础 ✅
**已完成**:
- ✅ SET命令修复
- ✅ FOR/NEXT支持
- ✅ REPEAT/REND支持
- ✅ QuickTest 20/20通过
- ✅ FixVerificationTest 11/11通过

### Day 2 (12/28) - 核心跳转命令
**目标**: 实现函数调用和跳转

```
1. CALL - 函数调用
2. JUMP - 跳转到标签
3. GOTO - 无条件跳转
4. CALLFORM - 动态函数调用
5. JUMPFORM - 动态跳转
6. GOTOFORM - 动态GOTO
```

**测试用例**:
```swift
// CALL测试
CALL @TEST
QUIT

@TEST
PRINTL "Called"
RETURN

// GOTO测试
GOTO @SKIP
PRINTL "Skipped"

@SKIP
PRINTL "Jumped"
QUIT
```

### Day 3 (12/29) - 返回和事件命令
**目标**: 完善流程控制

```
7. RETURN - 返回
8. RETURNFORM - 动态返回
9. RETURNF - 函数返回
10. RESTART - 重新开始
11. DOTRAIN - 训练模式
12. CALLEVENT - 事件调用
13. CALLTRAIN - 调用训练
14. STOPCALLTRAIN - 停止训练
```

### Day 4 (12/30) - 数据操作1
**目标**: 角色管理命令

```
15. ADDDEFCHARA - 添加默认角色
16. ADDSPCHARA - 添加特殊角色
17. ADDCOPYCHARA - 添加复制角色
18. DELALLCHARA - 删除所有角色
19. PICKUPCHARA - 提取角色
20. SAVECHARA - 保存角色
21. LOADCHARA - 加载角色
```

### Day 5 (12/31) - 数据操作2
**目标**: 数据持久化

```
22. SAVEGAME - 保存游戏
23. LOADGAME - 加载游戏
24. SAVEVAR - 保存变量
25. LOADVAR - 加载变量
26. SAVENOS - 保存编号
```

### Day 6 (1/1) - 系统命令1
**目标**: 系统状态管理

```
27. RESETDATA - 重置数据
28. RESETGLOBAL - 重置全局
29. RESET_STAIN - 重置状态
30. REDRAW - 重绘
31. SKIPDISP - 跳过显示
32. NOSKIP - 禁止跳过
33. ENDNOSKIP - 结束禁止跳过
34. OUTPUTLOG - 输出日志
```

### Day 7 (1/2) - 系统命令2
**目标**: 等待和特殊命令

```
35. FORCEWAIT - 强制等待
36. TWAIT - 时间等待
37. PERSIST - 持久化
38. RESET - 重置
39. RANDOMIZE - 随机种子
40. DUMPRAND - 导出随机
41. INITRAND - 初始化随机
42. PUTFORM - 输出格式
```

### Day 8 (1/3) - 高级打印1
**目标**: 按钮和格式化

```
43. PRINTBUTTONC - 按钮居中
44. PRINTBUTTONLC - 按钮左居中
45. PRINTCPERLINE - 每行字符数
46. PRINTCLENGTH - 字符长度
47. PRINTSINGLE - 单行输出
48. PRINTSINGLEV - 单行变量
49. PRINTSINGLES - 单行字符串
50. PRINTSINGLEFORM - 单行格式
51. PRINTSINGLEFORMS - 单行格式字符串
```

### Day 9 (1/4) - 高级打印2
**目标**: D/K模式单行打印

```
52. PRINTSINGLED - D模式单行
53. PRINTSINGLEVD - D模式单行变量
54. PRINTSINGLESD - D模式单行字符串
55. PRINTSINGLEFORMD - D模式单行格式
56. PRINTSINGLEFORMSD - D模式单行格式字符串
57. PRINTSINGLEK - K模式单行
58. PRINTSINGLEVK - K模式单行变量
59. PRINTSINGLESK - K模式单行字符串
60. PRINTSINGLEFORMK - K模式单行格式
61. PRINTSINGLEFORMSK - K模式单行格式字符串
```

### Day 10 (1/5) - 剩余命令
**目标**: 完成所有剩余命令

```
剩余类别:
- 高级图形命令 (10个)
- 鼠标/输入命令 (2个)
- 颜色扩展命令 (2个)
- 对齐/文本框命令 (2个)
- 数据块命令完善 (10个)
- 其他零散命令 (10个)
```

---

## 🛠️ 开发工具

### 快速验证
```bash
# 每日进度
swift run --package-path Emuera QuickStats

# 命令验证
swift run --package-path Emuera CommandVerification

# 修复验证
swift run --package-path Emuera FixVerificationTest
```

### 工作流程
```
1. 运行QuickStats查看当前进度
2. 选择今天要实现的命令类别
3. 在StatementExecutor.swift中添加visit方法
4. 编写测试用例
5. 运行QuickTest验证
6. 提交代码
```

---

## 📊 进度跟踪表

| 日期 | 计划完成 | 累计完成 | 完成度 | 状态 |
|------|----------|----------|--------|------|
| 12/27 | 200 | 200 | 66.2% | ✅ |
| 12/28 | 206 | 206 | 68.2% | 🟡 |
| 12/29 | 213 | 213 | 70.5% | ⬜ |
| 12/30 | 223 | 223 | 73.8% | ⬜ |
| 12/31 | 228 | 228 | 75.5% | ⬜ |
| 01/01 | 236 | 236 | 78.1% | ⬜ |
| 01/02 | 248 | 248 | 82.1% | ⬜ |
| 01/03 | 258 | 258 | 85.4% | ⬜ |
| 01/04 | 268 | 268 | 88.7% | ⬜ |
| 01/05 | 302 | 302 | 100% | ⬜ |

---

## 🎯 里程碑

### Week 1结束 (1/5)
- ✅ 阶段2完成 (100%命令执行逻辑)
- ✅ 所有302个命令可执行
- ✅ 测试通过率100%

### Week 2开始 (1/6)
- ⏳ 阶段3开始 (内置函数补全)
- ⏳ 目标: 40个内置函数

---

## 💡 关键提示

### 1. 模式遵循
所有新命令遵循现有模式：
```swift
public func visitYourCommand(_ statement: YourCommandStatement) throws {
    // 1. 参数验证
    // 2. 执行逻辑
    // 3. 结果处理
}
```

### 2. 错误处理
```swift
guard condition else {
    throw EmueraError.runtimeError(
        message: "错误信息",
        position: statement.position
    )
}
```

### 3. 测试驱动
每个命令必须有测试用例，覆盖：
- 正常情况
- 异常情况
- 边界情况

---

## 📝 每日检查清单

- [ ] 运行QuickStats查看进度
- [ ] 实现10-15个相关命令
- [ ] 编写测试用例
- [ ] 验证测试通过率
- [ ] 更新文档
- [ ] 提交代码

---

**计划生成**: 2025-12-27
**当前状态**: 阶段2进行中 (66.2%)
**下一步**: Day 2开发 (核心跳转命令)
**预计完成**: 2026-01-05
