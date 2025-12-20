# 📁 Emuera macOS 示例脚本

这些示例脚本展示了Emuera macOS的所有核心功能。

## 📚 示例列表

### 1. 计算器示例.erb
**难度**: ⭐ 入门
**功能**: 变量、表达式、条件语句、用户输入

```bash
# 运行方式
swift run emuera run "Examples/计算器示例.erb"
```

**学习要点**:
- 变量赋值和计算
- 用户输入 (WAIT)
- IF/ELSEIF/ELSE 条件判断
- 基本算术运算

---

### 2. 循环测试.erb
**难度**: ⭐⭐ 初级
**功能**: WHILE循环、FOR循环、嵌套循环

```bash
swift run emuera run "Examples/循环测试.erb"
```

**学习要点**:
- WHILE 循环
- FOR 计数循环
- 嵌套循环
- 打印格式控制

---

### 3. 函数和GOTO示例.erb
**难度**: ⭐⭐⭐ 中级
**功能**: 函数调用、GOTO跳转、标签

```bash
swift run emuera run "Examples/函数和GOTO示例.erb"
```

**学习要点**:
- CALL 调用函数
- RETURN 从函数返回
- GOTO 无条件跳转
- 标签定义和使用
- 函数调用栈

---

### 4. SELECTCASE示例.erb
**难度**: ⭐⭐ 中级
**功能**: 多分支选择、用户输入验证

```bash
swift run emuera run "Examples/SELECTCASE示例.erb"
```

**学习要点**:
- SELECTCASE 多分支
- CASE 匹配
- CASEELSE 默认情况
- 用户输入处理

---

## 🚀 快速运行所有示例

### 方法1：逐个运行

```bash
cd /Users/ss/Documents/Project/iOS/emuera-mac/Emuera

# 计算器
swift run emuera run ../Examples/计算器示例.erb

# 循环测试
swift run emuera run ../Examples/循环测试.erb

# 函数和GOTO
swift run emuera run ../Examples/函数和GOTO示例.erb

# SELECTCASE
swift run emuera run ../Examples/SELECTCASE示例.erb
```

### 方法2：交互模式

```bash
swift run emuera
emuera> run ../Examples/计算器示例.erb
emuera> run ../Examples/循环测试.erb
# ... 以此类推
```

### 方法3：使用GUI

1. 启动 `swift run EmueraGUI`
2. 点击"打开示例"按钮
3. 选择示例文件夹
4. 选择并运行示例

---

## 📖 每个示例的学习建议

### 计算器示例
**建议练习**:
1. 添加乘法和除法
2. 添加取余运算 (%)
3. 增加循环让用户可以连续计算
4. 添加负数支持

### 循环测试
**建议练习**:
1. 创建九九乘法表
2. 打印菱形图案
3. 计算1到100的和
4. 斐波那契数列

### 函数和GOTO
**建议练习**:
1. 创建多个子程序
2. 添加错误处理
3. 实现简单的菜单系统
4. 创建递归函数

### SELECTCASE
**建议练习**:
1. 创建简单RPG战斗系统
2. 实现菜单选择
3. 添加更多选项
4. 嵌套SELECTCASE

---

## 🎯 组合示例

### 完整游戏示例

创建 `完整游戏.erb`:

```erb
PRINTL === 简单RPG游戏 ===
PRINTL

@MAIN
  PRINTL 1. 查看状态
  PRINTL 2. 战斗
  PRINTL 3. 退出
  PRINTL 请选择:
  WAIT

  SELECTCASE RESULT
    CASE 1
      CALL STATUS
    CASE 2
      CALL BATTLE
    CASE 3
      GOTO END
    CASEELSE
      PRINTL 无效选择！
  ENDSELECT

  GOTO MAIN

@STATUS
  PRINTL === 状态 ===
  PRINTL HP: 100
  PRINTL MP: 50
  PRINTL
  RETURN

@BATTLE
  PRINTL === 战斗开始 ===
  PRINTL 你遇到了怪物！
  PRINTL 1. 攻击
  PRINTL 2. 防御
  PRINTL 3. 逃跑
  WAIT

  SELECTCASE RESULT
    CASE 1
      PRINTL 你攻击了怪物！
      PRINTL 造成 25 点伤害
    CASE 2
      PRINTL 你采取防御姿态
    CASE 3
      PRINTL 你成功逃跑！
    CASEELSE
      PRINTL 无效选择！
  ENDSELECT
  PRINTL
  RETURN

@END
  PRINTL 游戏结束！
  QUIT
```

运行:
```bash
swift run emuera run 完整游戏.erb
```

---

## 🔍 调试技巧

### 查看Token分析

```emuera
emuera> tokens "A = 100 + 200 * 3"
```

### 逐步执行

```emuera
emuera> run ../Examples/计算器示例.erb
# 观察输出，检查错误
```

### 变量检查

```emuera
emuera> A = 100
emuera> PRINT A
emuera> persist on
emuera> exit
emuera> persist on
emuera> PRINT A  # 应该还是100
```

---

## 📝 创建自己的示例

### 模板

```erb
PRINTL === 我的脚本 ===
PRINTL

# 在这里写你的代码

QUIT
```

### 建议的开发流程

1. **从简单开始**: 先运行计算器示例
2. **逐步增加**: 添加新功能
3. **测试每个部分**: 确保理解每个命令
4. **组合使用**: 尝试组合不同功能
5. **创建自己的**: 写完整脚本

---

## 🎓 学习路径

### 第1天：基础
- 运行计算器示例
- 理解变量和表达式
- 尝试修改示例

### 第2天：流程控制
- 运行循环测试
- 理解WHILE和FOR
- 创建自己的循环

### 第3天：函数和跳转
- 运行函数和GOTO示例
- 理解调用栈
- 创建多函数脚本

### 第4天：高级语法
- 运行SELECTCASE示例
- 理解多分支
- 创建菜单系统

### 第5天：完整项目
- 组合所有知识
- 创建自己的游戏
- 使用GUI开发

---

## 💡 提示

### 文件路径问题

如果在Emuera目录运行：
```bash
swift run emuera run ../Examples/计算器示例.erb
```

如果在emuera-mac目录运行：
```bash
cd Emuera
swift run emuera run ../Examples/计算器示例.erb
```

### 中文支持

所有示例都支持中文：
- ✅ 中文输出
- ✅ 中文变量名
- ✅ 中文注释

### 错误处理

如果运行出错：
1. 检查语法是否正确
2. 查看错误信息
3. 对照示例代码
4. 使用 `help` 命令

---

## 🎉 开始学习

选择一个示例，开始你的Emuera之旅吧！

```bash
# 最简单的开始
swift run emuera run ../Examples/计算器示例.erb
```

祝你学习愉快！🚀✨

---
*示例文档 v1.0 - 2025-12-20*
