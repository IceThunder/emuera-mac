# Emuera macOS - Windows版兼容性实现

## 🎯 问题背景

用户反馈：Windows版Emuera支持将编译后的exe文件直接放到游戏脚本的根目录即可启动游戏，但macOS版没有这个功能。

## ✅ 已实现的功能

### 1. 自动路径检测 (Sys.swift)

```swift
// 自动获取可执行文件路径
Sys.exeDir    // 可执行文件所在目录
Sys.csvDir    // csv/ 子目录
Sys.erbDir    // erb/ 子目录
Sys.saveDir   // save/ 子目录
```

**实现方式**：
- 使用 `Bundle.main.executablePath` 获取可执行文件路径
- 自动计算标准子目录路径
- 支持在任何目录运行

### 2. GAMEBASE.CSV支持 (GameBase.swift)

```swift
// 自动加载游戏信息
SCRIPT_TITLE, 游戏标题
SCRIPT_AUTHOR, 作者名
SCRIPT_VERSION, 1.0.0
SCRIPT_WINDOW_TITLE, 窗口标题
BEGIN, TITLE
```

**功能**：
- 自动扫描 csv/GAMEBASE.CSV
- 支持Shift-JIS和UTF-8编码
- 显示游戏标题、作者、版本信息

### 3. 配置文件支持 (Config.swift)

```swift
// emuera.config 配置项
DISPLAY_REPORT, true          // 显示加载报告
SEARCH_SUBDIRECTORY, false    // 是否搜索子目录
SORT_WITH_FILENAME, true      // 按文件名排序
USE_SAVE_FOLDER, true         // 使用存档目录
```

**配置优先级**：
1. csv/_default.config (最低)
2. emuera.config (用户配置)
3. csv/_fixed.config (最高)

### 4. ERB脚本自动扫描 (ErbLoader.swift)

```swift
// 自动扫描erb/目录下的所有ERB文件
guard let erbFiles = getFiles(in: Sys.erbDir, pattern: "*.ERB")
```

**功能**：
- 自动扫描指定目录
- 支持UTF-8和Shift-JIS编码
- 统计有效代码行数
- 生成加载报告

### 5. 游戏启动器 (Launcher.swift)

```swift
// 启动模式
enum LaunchMode {
    case interactive          // 交互式控制台
    case auto                 // 自动模式（检测游戏结构）
    case runScript(String)    // 运行指定脚本
    case analysis([String])   // 分析模式
    case gui                  // GUI模式
}
```

**自动模式流程**：
1. 检查目录结构（csv/, erb/）
2. 加载配置文件
3. 读取GAMEBASE.CSV
4. 扫描并加载ERB脚本
5. 创建存档目录
6. 启动游戏引擎

### 6. 命令行接口更新 (main.swift)

```bash
# 新增命令
emuera auto               # 自动模式（Windows版兼容）
emuera run <file>         # 运行指定脚本
emuera demo               # 演示模式
emuera help               # 显示帮助
```

## 📁 目录结构要求

```
游戏根目录/
├── emuera (可执行文件)
├── csv/
│   ├── GAMEBASE.CSV (可选 - 游戏信息)
│   ├── _default.config (可选 - 默认配置)
│   ├── emuera.config (可选 - 用户配置)
│   └── _fixed.config (可选 - 固定配置)
├── erb/
│   └── *.erb (脚本文件)
└── save/ (自动创建 - 存档目录)
```

## 🚀 使用方法

### 方式1：自动模式（推荐）

```bash
# 1. 将emuera可执行文件放入游戏目录
cd /path/to/game
./emuera auto
```

### 方式2：指定脚本运行

```bash
./emuera run erb/myscript.erb
```

### 方式3：交互式控制台

```bash
./emuera
emuera> demo
emuera> exit
```

## 🔧 配置示例

### emuera.config
```csv
; 显示详细的加载报告
DISPLAY_REPORT, true

; 不搜索子目录（默认行为）
SEARCH_SUBDIRECTORY, false

; 按文件名排序
SORT_WITH_FILENAME, true

; 使用独立存档目录
USE_SAVE_FOLDER, true

; 脚本编码（可选）
SCRIPT_ENCODE, UTF-8
; 或
SCRIPT_ENCODE, SHIFTJIS
```

### GAMEBASE.CSV
```csv
; 游戏基础信息
SCRIPT_TITLE, 我的游戏
SCRIPT_AUTHOR, 作者名
SCRIPT_VERSION, 1.0.0
SCRIPT_WINDOW_TITLE, 我的游戏 - Emuera
BEGIN, TITLE
```

## 📊 测试结果

### 自动模式测试
```bash
$ cd test_game && ./emuera auto

🚀 Emuera 启动器 v1.0
模式: 自动游戏检测
📁 检查目录结构... ✅
⚙️  加载配置... ✅
📊 加载游戏信息...
  标题: 测试游戏
  作者: 测试作者
  版本: 1.0.0
📄 加载脚本... ✅
  发现 1 个ERB文件
📊 总计: 5 行代码
🎮 启动游戏引擎... ✅
```

### 配置文件测试
- ✅ 自动创建必需目录
- ✅ 支持多种编码格式
- ✅ 配置优先级正确
- ✅ 显示报告功能正常

## 🎯 与Windows版的对比

| 功能 | Windows版 | macOS版（实现） |
|------|-----------|-----------------|
| 自动检测游戏根目录 | ✅ | ✅ |
| 扫描csv/和erb/目录 | ✅ | ✅ |
| GAMEBASE.CSV支持 | ✅ | ✅ |
| emuera.config支持 | ✅ | ✅ |
| 自动创建目录 | ✅ | ✅ |
| 编码支持(SJIS/UTF8) | ✅ | ✅ |
| 配置优先级 | ✅ | ✅ |
| 显示加载报告 | ✅ | ✅ |

## 🔍 关键代码位置

- **Sys.swift**: `Emuera/Sources/EmueraCore/Services/Sys.swift`
- **GameBase.swift**: `Emuera/Sources/EmueraCore/Services/GameBase.swift`
- **Config.swift**: `Emuera/Sources/EmueraCore/Services/Config.swift`
- **ErbLoader.swift**: `Emuera/Sources/EmueraCore/Services/ErbLoader.swift`
- **Launcher.swift**: `Emuera/Sources/EmueraCore/Services/Launcher.swift`
- **main.swift**: `Emuera/Sources/EmueraApp/main.swift`

## 📝 使用示例

### 示例1：创建新游戏
```bash
mkdir mygame
cd mygame
mkdir csv erb

# 创建配置
echo "DISPLAY_REPORT, true" > emuera.config

# 创建游戏信息
cat > csv/GAMEBASE.CSV << EOF
SCRIPT_TITLE, 我的游戏
SCRIPT_AUTHOR, 作者
SCRIPT_VERSION, 1.0.0
EOF

# 创建脚本
cat > erb/main.erb << EOF
PRINTL 欢迎来到我的游戏！
WAIT
QUIT
EOF

# 复制并运行
cp /path/to/emuera ./
./emuera auto
```

### 示例2：运行现有游戏
```bash
# 直接运行，自动检测结构
cd /path/to/game
./emuera auto
```

## 🎉 总结

macOS版现在完全支持Windows版的自动游戏加载机制：

1. ✅ **自动路径检测** - 无需手动指定目录
2. ✅ **配置文件支持** - 完整的配置系统
3. ✅ **GAMEBASE.CSV** - 游戏信息自动加载
4. ✅ **ERB自动扫描** - 无需逐个指定文件
5. ✅ **目录自动创建** - 缺失目录自动补全
6. ✅ **编码自动处理** - UTF-8和Shift-JIS支持

**使用方式**：将编译后的emuera可执行文件放入游戏根目录，运行 `./emuera auto` 即可启动游戏，完全等同于Windows版的行为！