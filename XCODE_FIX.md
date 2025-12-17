# 🔧 Xcode 配置修复说明

## 修复的错误
```
invalid custom path 'Tests/EmueraCoreTests' for target 'EmueraCoreTests'
```

## 解决方案

### 1. 根本原因
Package.swift 中测试目标使用了不存在的自定义路径配置。

### 2. 已修复的内容

**✅ Package.swift**
- 移除了测试目标的 `path` 参数
- 现在使用 SwiftPM 默认路径规则

**✅ 测试目录结构**
```
Emuera/
├── Tests/
│   ├── EmueraCoreTests/
│   │   ├── XCTestManifests.swift
│   │   ├── VariableTests.swift
│   │   └── ErrorTests.swift
│   └── EmueraAppTests/
│       └── EmueraAppTests.swift
```

### 3. 如果你仍然看到错误

#### 选项 A: 清理并重新构建
```bash
cd Emuera
rm -rf .build
swift build
```

#### 选项 B: 重新生成Xcode项目
```bash
cd Emuera
rm -rf Emuera.xcodeproj
swift package generate-xcodeproject
open Emuera.xcodeproj
```

#### 选项 C: 在Xcode中清理
1. `Product` → `Clean Build Folder` (Shift+Cmd+K)
2. 重新构建 (Cmd+B)

### 4. 验证修复

```bash
# 测试构建是否正常
cd Emuera
swift build
swift test
```

如果看到 ✅ 测试通过，说明修复成功！

---

**已推送修复到GitHub，下次克隆应该没有这个问题。**