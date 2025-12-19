# 🔧 EmueraCore 模块编译错误修复说明

## 问题概述

Xcode 编译时报错：`Underlying Objective-C module 'EmueraCore' not found`

## 根本原因分析

在 `EmueraCore.swift` 文件中存在**致命的自引用导入错误**：

```swift
// ❌ 错误的写法 - 导入模块自身
@_exported import struct EmueraCore.ScriptPosition
@_exported import enum EmueraCore.EmueraError
// ... 其他类似导入
```

这会导致 Swift 编译器产生循环依赖：
1. `EmueraCore` 模块尝试引用自身
2. 无法生成 `EmueraCore-Swift.h` 头文件
3. 导致所有依赖该模块的代码无法编译

## 修复内容

### 1. 修复 EmueraCore.swift (Sources/EmueraCore/EmueraCore.swift)

**修复前**:
```swift
@_exported import Foundation

// 导入自身模块的类型 - ❌ 错误
@_exported import struct EmueraCore.ScriptPosition
@_exported import enum EmueraCore.EmueraError
@_exported import class EmueraCore.Logger
// ... 更多自引用
```

**修复后**:
```swift
/// Core Engine for Emuera Script Runtime
///
/// This module provides the fundamental script parsing and execution
/// capabilities for Emuera game engine, compatible with original Emuera
/// ERB/ERH script format.

@_exported import Foundation

// MARK: - Version Information

public let EmueraCoreVersion = "1.0.0"
public let EmueraVersion = "1.820" // Compatible with Emuera 1.820

// MARK: - Quick Access

/// Global logger instance for convenience
public func logDebug(_ message: String) {
    Logger.debug(message)
}

public func logInfo(_ message: String) {
    Logger.info(message)
}

public func logError(_ message: String) {
    Logger.error(message)
}
```

**说明**: 只保留版本信息和便利函数，删除所有自引用导入。Swift 会自动处理同一模块内的类型引用。

### 2. 修复访问控制 (Sources/EmueraCore/Common/EmueraError.swift)

**问题**: `ScriptPosition` 和 `EmueraError` 缺少 `public` 修饰符

**修复后**:
```swift
public enum EmueraError: Error, LocalizedError {
    // ... case 定义
    public var errorDescription: String? { /* ... */ }
}

public struct ScriptPosition: Codable, Equatable {
    public let filename: String
    public let lineNumber: Int

    public init(filename: String, lineNumber: Int) {
        self.filename = filename
        self.lineNumber = lineNumber
    }

    public var description: String {
        return "\(filename):\(lineNumber)"
    }
}
```

### 3. 修复递归类型依赖 (Sources/EmueraCore/Variable/VariableType.swift)

**问题**: `VariableValue` 和 `CharacterData` 形成循环依赖：
- `VariableValue.array([VariableValue])` - 数组包含自己
- `VariableValue.character(CharacterData)` - 包含 CharacterData
- `CharacterData.variables: [String: VariableValue]` - 包含 VariableValue

**修复方案**:
```swift
// VariableValue 必须声明为 Equatable
public enum VariableValue: Codable, Equatable {
    // ...

    // 手动实现 Equatable 以避免自动合成时的循环问题
    public static func == (lhs: VariableValue, rhs: VariableValue) -> Bool {
        switch (lhs, rhs) {
        case (.integer(let l), .integer(let r)): return l == r
        case (.string(let l), .string(let r)): return l == r
        case (.array(let l), .array(let r)):
            // 手动递归比较数组
            guard l.count == r.count else { return false }
            for i in 0..<l.count {
                if l[i] != r[i] { return false }
            }
            return true
        case (.character(let l), .character(let r)): return l.id == r.id  // 简化比较
        case (.null, .null): return true
        default: return false
        }
    }
}

// CharacterData 也实现 Equatable，但为避免循环只比较 id
public struct CharacterData: Codable {
    // ...

    public static func == (lhs: CharacterData, rhs: CharacterData) -> Bool {
        return lhs.id == rhs.id  // 简化比较，避免循环
    }
}
```

## 验证修复

运行以下命令验证修复成功：

```bash
cd /Users/ss/Documents/Project/iOS/emuera-mac/Emuera
swift build
```

输出应该是：
```
Build complete!
```

## 在 Xcode 中使用

由于新版 SwiftPM 移除了 `swift package generate-xcodeproj`，推荐使用以下方式：

### 方法 1: Xcode 直接打开 (推荐)
```bash
# 在 Emuera 目录下
open Package.swift
```

Xcode 会自动解析 Swift Package 并创建项目。

### 方法 2: 使用 Swift Playground
```bash
# 在 Emuera 目录下
swift playground
```

### 方法 3: 手动创建 Xcode 项目
1. 在 Xcode 中选择 `File` → `New` → `Project`
2. 选择 `macOS` → `Command Line Tool`
3. 在 `Build Settings` 中添加对 Swift Package 的依赖

## 修复总结

| 文件 | 问题 | 修复 |
|------|------|------|
| `EmueraCore.swift` | 自引用导入 | 删除所有 `@_exported import EmueraCore.*` |
| `EmueraError.swift` | 缺少 public | 添加 `public` 修饰符 |
| `VariableType.swift` | 循环依赖 | 手动实现 Equatable |
| `TokenType.swift` | 依赖 ScriptPosition | ScriptPosition 已设为 public |

## 下一步

现在项目应该可以正常在 Xcode 中编译。如果仍然遇到问题：

1. **清理 Xcode 缓存**: Product → Clean Build Folder (Shift+Cmd+K)
2. **重启 Xcode**
3. **重新打开 Package.swift**

如果需要重构代码，建议先备份当前修复状态。