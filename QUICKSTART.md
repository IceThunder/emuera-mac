# Emuera macOS - 快速开始指南

## 🏁 立即开始 (在你的Mac上)

### 1. 环境准备

首先确保你的Mac已安装Swift开发环境：

```bash
# 检查Swift版本
swift --version

# 如果没有安装，请访问 https://swift.org/download/
# 或通过Homebrew安装 (推荐)
brew install swift
```

### 2. 克隆项目

```bash
# 从GitHub克隆
git clone https://github.com/IceThunder/emuera-mac.git
cd emuera-mac/Emuera

# 或如果你想在本地继续开发
cd /d/Project_js/EmueraJs/Emuera
```

### 3. 构建项目

```bash
# 构建所有目标
swift build

# 或构建特定目标
swift build --product EmueraCore
swift build --product emuera

# 释放模式构建 (优化后的版本)
swift build -c release
```

### 4. 运行测试

```bash
# 运行所有测试
swift test

# 运行特定测试模块
swift test --filter EmueraCoreTests
```

### 5. 启动应用

```bash
# 运行主程序
swift run emuera

# 或直接运行二进制文件
swift run -c release emuera
```

## 📋 现有功能演示

### 变量系统测试

应用启动后会自动运行基础测试：

```swift
// 你可以看到以下输出:
// 🚀 Emuera for macOS - Development Build
// Version: 1.820 (Core: 1.0.0)
//
// 🧪 Testing core engine components...
// ✓ Variable system: PASS
// ✓ Array operations: PASS
// ✓ Character data: PASS
// ✓ Logger system: PASS
//
// 🎉 All core tests passed!
```

### 下一步操作

创建一个简单的测试脚本来验证功能：

```bash
# 创建测试目录结构
cd Resources
mkdir -p csv erb

# 创建基础CSV（测试用）
cat > csv/GAMEBASE.CSV << EOF
SCRIPT_TITLE,Test Game
VERSION,1.0
EOF

# 创建测试ERB脚本
cat > erb/TEST.ERB << EOF
@SYSTEM_START
PRINTL Welcome to Emuera for macOS!
INPUT
RESULT = RESULT * 2
PRINTL Your doubled result: {RESULT}
RETURN
EOF
```

## 🔧 在Xcode中开发

### 创建Xcode项目

```bash
# 生成Xcode项目
swift package generate-xcodeproject

# 直接打开
open Emuera.xcodeproj
```

### Xcode开发提示
1. 使用`Cmd+B`构建
2. 使用`Cmd+R`运行
3. 使用`Cmd+U`运行测试
4. 在Scheme中设置工作目录为项目文件夹

## 📁 项目结构详解

```
Emuera/
├── Package.swift              # SwiftPM配置文件
├── Sources/
│   ├── EmueraCore/           # 核心引擎库
│   │   ├── Common/          # 工具类
│   │   │   ├── Config.swift         # 配置管理
│   │   │   ├── EmueraError.swift   # 错误类型
│   │   │   └── Logger.swift        # 日志系统
│   │   ├── Variable/         # 变量系统
│   │   │   ├── VariableData.swift  # 数据存储
│   │   │   └── VariableType.swift  # 类型定义
│   │   ├── Parser/          # 解析器
│   │   │   ├── TokenType.swift     # Token定义
│   │   │   └── (开发中...)
│   │   ├── Script/          # 脚本处理
│   │   └── Executor/        # 执行引擎
│   └── EmueraApp/           # macOS应用
│       ├── main.swift       # 应用入口
│       ├── Views/           # UI组件 (待开发)
│       ├── Render/          # 图形渲染 (待开发)
│       └── Services/        # 系统服务 (待开发)
├── Tests/                   # 单元测试
├── Resources/               # 游戏资源
│   ├── csv/                # CSV数据
│   ├── erb/                # ERB脚本
│   └── resources/          # 图片等资源
└── README.md               # 项目说明
```

## 🚀 开发路线

### 立即可以做的贡献

1. **基础解析器实现**
   - 在`EmueraCore/Parser/`添加逻辑解析器
   - 测试ERB文件读取

2. **表达式计算**
   - 实现四则运算引擎
   - 添加比较运算符支持

3. **UI原型**
   - 使用Xcode Interface Builder
   - 创建基础窗口布局

### 示例：添加新命令

在`Sources/EmueraCore/Executor/`中：

```swift
// Command.swift
public enum EmueraCommand {
    case print(String)
    case input
    case goto(label: String)

    public func execute(in context: ProcessState) throws {
        switch self {
        case .print(let message):
            context.console.write(message)
        case .input:
            // 等待输入...
            break
        case .goto(let label):
            context.jump(to: label)
        }
    }
}
```

## 🐛 常见问题

### 问题：找不到Swift命令
**解决**: 安装Xcode Command Line Tools
```bash
xcode-select --install
```

### 问题：构建失败
**解决**: 清理构建缓存
```bash
rm -rf .build
swift build
```

### 问题：权限错误
**解决**: 确保有读写权限
```bash
chmod -R +w .
```

## 📞 获取帮助

- 查看`DEVELOPMENT_PLAN.md`了解详细开发计划
- 阅读原版Emuera源码理解行为
- 加入ERA系列游戏开发社区讨论

## ✅ 验证成功

如果看到以下输出，说明环境配置成功：

```
✅ Swift版本: Swift 5.9+
✅ 项目结构: 正确
✅ 核心模块: 可编译
✅ 测试运行: 通过
```

---

**准备好开始开发了！** 🎉

下一步建议：
1. 阅读`DEVELOPMENT_PLAN.md`了解详细功能清单
2. 在`EmueraCore/Parser/`添加词法分析器
3. 参与GitHub仓库贡献代码