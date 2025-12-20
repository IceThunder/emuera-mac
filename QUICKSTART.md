# 🚀 Emuera macOS 快速开始指南

## 5分钟上手教程

---

## 第一步：验证环境

打开终端，运行：

```bash
swift --version
```

你应该看到类似：
```
Swift version 5.9 or higher
Target: arm64-apple-darwin23.3.0
```

如果提示命令未找到，请安装Xcode Command Line Tools：
```bash
xcode-select --install
```

---

## 第二步：编译项目

```bash
cd /Users/ss/Documents/Project/iOS/emuera-mac/Emuera
swift build
```

首次编译需要几分钟，后续会很快。

---

## 第三步：运行测试（验证安装）

```bash
swift run emuera integrationtest
```

你应该看到：
```
🧪 完整集成测试 - Process + StatementExecutor + UI
======================================================================

测试1: 基础变量赋值和输出
--------------------------------------------------
✅ 通过

测试2: 条件语句和流程控制
--------------------------------------------------
✅ 通过

... (更多测试)
```

如果看到 ✅ 通过，说明安装成功！

---

## 第四步：尝试交互式控制台

```bash
swift run emuera
```

你会看到：
```
┌────────────────────────────────────────┐
│  Emuera for macOS - MVP Version        │
│  (c) 2025, based on Emuera Original    │
└────────────────────────────────────────┘

输入 'help' 查看命令帮助
输入 'test' 运行内置测试

emuera>
```

现在可以输入命令：

### 尝试基础命令

```emuera
emuera> A = 100
emuera> PRINT A
100
emuera> B = A + 50
emuera> PRINT B
150
```

### 尝试条件语句

```emuera
emuera> IF A > 50
emuera>   PRINTL A大于50
emuera> ENDIF
A大于50
```

### 运行内置演示

```emuera
emuera> demo
```

### 运行完整测试

```emuera
emuera> integrationtest
```

---

## 第五步：创建你的第一个脚本

### 1. 创建脚本文件

```bash
# 在任意位置创建文件
nano ~/Desktop/my_first_script.erb
```

### 2. 写入以下内容：

```erb
PRINTL === 我的第一个Emuera脚本 ===
PRINTL

PRINTL 请输入一个数字:
WAIT

A = 100
B = 200
C = A + B

PRINTL
PRINTL 计算结果:
PRINT A + B =
PRINT C
PRINTL

IF C > 250
  PRINTL 结果大于250！
ELSE
  PRINTL 结果小于等于250
ENDIF

PRINTL
PRINTL 脚本执行完成！
QUIT
```

### 3. 运行脚本

**方法A：命令行直接运行**
```bash
swift run emuera run ~/Desktop/my_first_script.erb
```

**方法B：交互模式运行**
```bash
swift run emuera
emuera> run ~/Desktop/my_first_script.erb
```

---

## 第六步：使用GUI应用

### 启动GUI

```bash
swift run EmueraGUI
```

你会看到一个macOS原生应用窗口，包含：
- **工具栏**：运行、打开、清空、调试、设置
- **侧边栏**：文件列表和快速操作
- **主控制台**：显示输出
- **状态栏**：当前状态和行数

### 在GUI中运行脚本

1. 点击"打开文件"按钮 (文件夹图标)
2. 选择你的 `.erb` 文件
3. 点击"运行"按钮 (绿色播放图标)
4. 查看控制台输出

---

## 📚 常用命令速查

### 交互式控制台命令

| 命令 | 说明 |
|------|------|
| `help` | 显示帮助信息 |
| `test` | 运行基础测试脚本 |
| `demo` | 运行演示脚本 |
| `exprtest` | 表达式解析器测试 |
| `scripttest` | 语法解析器测试 |
| `processtest` | Process系统测试 |
| `integrationtest` | 完整集成测试 |
| `run <path>` | 运行指定脚本文件 |
| `tokens <script>` | 显示Token分析 |
| `reset` | 重置变量状态 |
| `persist on/off` | 开启/关闭持久化 |
| `exit/quit` | 退出程序 |

### 脚本语法速查

| 语法 | 示例 | 说明 |
|------|------|------|
| PRINT | `PRINT Hello` | 输出文本（不换行） |
| PRINTL | `PRINTL Hello` | 输出文本并换行 |
| 变量赋值 | `A = 100` | 赋值 |
| 表达式 | `B = A + 50` | 计算 |
| IF | `IF A > 5 ... ENDIF` | 条件语句 |
| WHILE | `WHILE A < 10 ... ENDWHILE` | 循环 |
| FOR | `FOR I, 1, 5 ... ENDFOR` | 计数循环 |
| CALL | `CALL MYFUNC` | 调用函数 |
| GOTO | `GOTO LABEL` | 跳转 |
| 标签 | `LABEL:` | 定义标签 |
| RETURN | `RETURN` | 从函数返回 |
| WAIT | `WAIT` | 等待输入 |
| QUIT | `QUIT` | 退出 |

---

## 🎯 进阶使用

### 1. 处理中文字符

Emuera macOS完全支持Unicode和中文：

```erb
PRINTL 你好，世界！
PRINTL 当前数值:
A = 100
PRINT A
PRINTL
PRINTL 中文变量名也可以:
中文变量 = 200
PRINT 中文变量
```

### 2. 复杂脚本示例

```erb
PRINTL === 计算器程序 ===
PRINTL

COUNT = 0
WHILE COUNT < 3
  PRINTL 第
  PRINT COUNT + 1
  PRINTL 次计算:

  A = 10
  B = 20
  C = A + B

  PRINT A + B =
  PRINT C
  PRINTL

  COUNT = COUNT + 1
ENDWHILE

PRINTL 计算完成！
QUIT
```

### 3. 函数和GOTO结合

```erb
PRINTL === 复杂流程演示 ===

GOTO START

@SUB1
  PRINTL 子程序1执行
  RETURN

@SUB2
  PRINTL 子程序2执行
  RETURN

@START
  PRINTL 主程序开始
  CALL SUB1
  GOTO NEXT

  PRINTL 这行不会执行

@NEXT
  CALL SUB2
  PRINTL 主程序结束
  QUIT
```

---

## 🐛 调试技巧

### 1. 查看Token分析

```emuera
emuera> tokens "A = 100 + 200"
```

### 2. 开启持久化模式

```emuera
emuera> persist on
emuera> A = 100
emuera> PRINT A  # 输出: 100
emuera> exit
emuera> persist on
emuera> PRINT A  # 仍然输出: 100
```

### 3. 重置状态

```emuera
emuera> reset    # 清除所有变量
```

### 4. GUI调试面板

在GUI应用中：
1. 点击"调试"按钮 (虫子图标)
2. 查看控制台状态、Process状态
3. 使用"打印状态"按钮查看实时信息

---

## 📁 文件管理建议

### 推荐目录结构

```
~/Emuera/
├── Games/              # 你的游戏脚本
│   ├── MyGame/
│   │   ├── main.erb
│   │   ├── functions.erb
│   │   └── data/
├── Saves/              # 存档文件
├── Examples/           # 示例脚本
└── Config/             # 配置文件
```

### 创建目录

```bash
mkdir -p ~/Emuera/Games/MyGame
mkdir -p ~/Emuera/Saves
mkdir -p ~/Emuera/Examples
```

---

## 🎓 学习路径

### 阶段1：基础语法（30分钟）
1. 运行 `demo` 查看示例
2. 尝试变量赋值和计算
3. 学习 IF 条件语句
4. 学习 WHILE 循环

### 阶段2：函数和流程（1小时）
1. 学习 CALL 和 RETURN
2. 学习 GOTO 和标签
3. 尝试 FOR 循环
4. 组合使用多个函数

### 阶段3：复杂脚本（2小时）
1. 创建计算器程序
2. 创建简单菜单系统
3. 学习 SELECTCASE
4. 处理用户输入

### 阶段4：GUI应用（30分钟）
1. 启动 EmueraGUI
2. 打开和运行脚本
3. 使用调试面板
4. 体验完整功能

---

## 💡 实用技巧

### 技巧1：快速测试

创建 `test.erb`：
```erb
PRINTL 测试开始
A = 100
PRINT A
QUIT
```

运行：
```bash
swift run emuera run test.erb
```

### 技巧2：交互式开发

```bash
swift run emuera
emuera> A = 100
emuera> B = 200
emuera> PRINT A + B
300
emuera> # 发现错误？直接重新输入
emuera> B = 300
emuera> PRINT A + B
400
```

### 技巧3：使用GUI调试

1. 在GUI中运行脚本
2. 点击"调试"按钮
3. 查看Process状态和调用栈
4. 使用"强制清空"重置控制台

---

## 🎉 恭喜！

你已经学会了Emuera macOS的基本使用！

### 下一步建议：

1. **阅读完整文档**：
   - `README.md` - 项目详情
   - `STATUS.md` - 功能状态
   - `运行说明.md` - 详细说明

2. **尝试更多示例**：
   - 运行 `swift run emuera scripttest` 查看语法测试
   - 运行 `swift run emuera processtest` 查看Process测试

3. **创建你的项目**：
   - 在 `~/Emuera/Games/` 创建你的游戏
   - 逐步添加功能
   - 使用GUI进行可视化开发

4. **探索源代码**：
   - `Sources/EmueraCore/` - 核心引擎
   - `Sources/EmueraCore/UI/` - UI系统
   - `Sources/EmueraApp/` - 测试代码

---

**有任何问题？** 运行 `help` 命令或查看 `运行说明.md`

**祝你开发愉快！** 🚀✨

---
*快速开始指南 v1.0 - 2025-12-20*
