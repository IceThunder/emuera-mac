//
//  BuiltInFunctions.swift
//  EmueraCore
//
//  内置函数库 - 支持数学、字符串、数组、系统函数
//  Created: 2025-12-19
//

import Foundation

/// 内置函数类型
public enum FunctionType: String, CaseIterable {
    // MARK: - 数学函数
    case ABS            // 绝对值
    case SQRT           // 平方根
    case SIN            // 正弦
    case COS            // 余弦
    case TAN            // 正切
    case ASIN           // 反正弦
    case ACOS           // 反余弦
    case ATAN           // 反正切
    case LOG            // 对数
    case LOG10          // 以10为底的对数
    case EXP            // 指数
    case POWER          // 幂运算
    case MIN            // 最小值
    case MAX            // 最大值
    case LIMIT          // 限制范围
    case SUM            // 求和

    // MARK: - 随机函数
    case RAND           // 随机数
    case RANDOM         // 随机数（别名）
    case RANDOMIZE      // 随机种子
    case DUMPRAND       // 转储随机状态
    case INITRAND       // 初始化随机

    // MARK: - 字符串函数
    case STRLENS        // 字符串长度（字符数）
    case STRLEN         // 字符串长度（字节数）
    case STRLENU        // 字符串长度（Unicode）
    case SUBSTRING      // 子字符串
    case REPLACE        // 替换
    case SPLIT          // 分割
    case FIND           // 查找
    case UPPER          // 转大写
    case LOWER          // 转小写
    case TRIM           // 去除空白
    case UNICODE        // Unicode转字符
    case ENCODETOUNI    // 编码到Unicode

    // MARK: - 数组函数
    case FINDELEMENT    // 查找元素
    case FINDLAST       // 查找最后一个
    case SORT           // 排序
    case REPEAT         // 重复
    case VARSIZE        // 数组大小
    case ARRAYSHIFT     // 数组移位
    case ARRAYREMOVE    // 数组删除
    case ARRAYSORT      // 数组排序
    case ARRAYCOPY      // 数组复制

    // MARK: - 位运算
    case GETBIT         // 获取位
    case SETBIT         // 设置位
    case CLEARBIT       // 清除位
    case INVERTBIT      // 反转位
    case SUMARRAYS      // 数组求和

    // MARK: - 系统函数
    case GAMEBASE       // 游戏基础信息
    case VERSION        // 版本
    case TIME           // 时间
    case GETTIME        // 获取时间
    case CHARANUM       // 角色数量
    case RESULT         // 结果变量
    case RESULTS        // 结果字符串变量

    // MARK: - 特殊变量
    case __INT_MAX__    // 最大整数
    case __INT_MIN__    // 最小整数
    case __INT64_MAX__  // 最大64位整数
    case __INT64_MIN__  // 最小64位整数

    // MARK: - 字符串格式化
    case FORM           // 格式化
    case TO_STRING      // 转字符串
    case TO_INTEGER     // 转整数

    // MARK: - 日期时间
    case YEAR           // 年
    case MONTH          // 月
    case DAY            // 日
    case HOUR           // 时
    case MINUTE         // 分
    case SECOND         // 秒

    // MARK: - 其他
    case ISNUMERIC      // 是否数字
    case ISNULL         // 是否空值
    case TYPEOF         // 类型

    /// 从字符串创建函数类型（不区分大小写）
    public static func fromString(_ str: String) -> FunctionType? {
        let upper = str.uppercased()
        return FunctionType(rawValue: upper)
    }
}

/// 内置函数执行器
public class BuiltInFunctions {

    /// 执行内置函数
    /// - Parameters:
    ///   - name: 函数名
    ///   - arguments: 参数列表
    ///   - context: 执行上下文（用于访问变量）
    /// - Returns: 函数返回值
    public static func execute(
        name: String,
        arguments: [VariableValue],
        context: ExecutionContext? = nil
    ) throws -> VariableValue {

        let upperName = name.uppercased()

        // MARK: - 数学函数
        switch upperName {
        case "ABS":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                return .integer(value >= 0 ? value : -value)
            }
            return .integer(0)

        case "SQRT":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                return .integer(Int64(sqrt(Double(value))))
            }
            return .integer(0)

        case "SIN":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                let result = sin(Double(value) * .pi / 180.0)  // 角度转弧度
                return .integer(Int64(result * 1000))  // 返回1000倍整数
            }
            return .integer(0)

        case "COS":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                let result = cos(Double(value) * .pi / 180.0)
                return .integer(Int64(result * 1000))
            }
            return .integer(0)

        case "TAN":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                let result = tan(Double(value) * .pi / 180.0)
                return .integer(Int64(result * 1000))
            }
            return .integer(0)

        case "LOG":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg, value > 0 {
                let result = log(Double(value))
                return .integer(Int64(result * 1000))
            }
            return .integer(0)

        case "LOG10":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg, value > 0 {
                let result = log10(Double(value))
                return .integer(Int64(result * 1000))
            }
            return .integer(0)

        case "EXP":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                let result = exp(Double(value))
                return .integer(Int64(result))
            }
            return .integer(0)

        case "POWER":
            guard arguments.count >= 2 else { return .integer(0) }
            if case .integer(let base) = arguments[0],
               case .integer(let exp) = arguments[1] {
                return .integer(Int64(pow(Double(base), Double(exp))))
            }
            return .integer(0)

        case "MIN":
            var minVal: Int64 = Int64.max
            for arg in arguments {
                if case .integer(let value) = arg {
                    minVal = min(minVal, value)
                }
            }
            return .integer(minVal == Int64.max ? 0 : minVal)

        case "MAX":
            var maxVal: Int64 = Int64.min
            for arg in arguments {
                if case .integer(let value) = arg {
                    maxVal = max(maxVal, value)
                }
            }
            return .integer(maxVal == Int64.min ? 0 : maxVal)

        case "LIMIT":
            guard arguments.count >= 3 else { return .integer(0) }
            if case .integer(let value) = arguments[0],
               case .integer(let min) = arguments[1],
               case .integer(let max) = arguments[2] {
                if value < min { return .integer(min) }
                if value > max { return .integer(max) }
                return .integer(value)
            }
            return .integer(0)

        case "SUM":
            var sum: Int64 = 0
            for arg in arguments {
                if case .integer(let value) = arg {
                    sum += value
                }
            }
            return .integer(sum)

        // MARK: - 随机函数
        case "RAND":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let max) = arg {
                if max <= 0 { return .integer(0) }
                return .integer(Int64.random(in: 0..<max))
            }
            return .integer(0)

        case "RANDOM":
            // RANDOM(n) 等同于 RAND(n)
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let max) = arg {
                if max <= 0 { return .integer(0) }
                return .integer(Int64.random(in: 0..<max))
            }
            return .integer(0)

        // MARK: - 字符串函数
        case "STRLENS", "STRLEN":
            guard let arg = arguments.first else { return .integer(0) }
            if case .string(let str) = arg {
                return .integer(Int64(str.count))
            }
            return .integer(0)

        case "STRLENU":
            guard let arg = arguments.first else { return .integer(0) }
            if case .string(let str) = arg {
                // Unicode字符数
                return .integer(Int64(str.unicodeScalars.count))
            }
            return .integer(0)

        case "SUBSTRING":
            guard arguments.count >= 2 else { return .string("") }
            if case .string(let str) = arguments[0],
               case .integer(let start) = arguments[1] {
                let startIndex = str.index(str.startIndex, offsetBy: Int(start))
                if arguments.count >= 3 {
                    if case .integer(let length) = arguments[2] {
                        let endIndex = str.index(startIndex, offsetBy: Int(length), limitedBy: str.endIndex) ?? str.endIndex
                        return .string(String(str[startIndex..<endIndex]))
                    }
                }
                if startIndex < str.endIndex {
                    return .string(String(str[startIndex...]))
                }
                return .string("")
            }
            return .string("")

        case "REPLACE":
            guard arguments.count >= 3 else { return .string("") }
            if case .string(let str) = arguments[0],
               case .string(let search) = arguments[1],
               case .string(let replace) = arguments[2] {
                return .string(str.replacingOccurrences(of: search, with: replace))
            }
            return .string("")

        case "SPLIT":
            guard arguments.count >= 2 else { return .array([]) }
            if case .string(let str) = arguments[0],
               case .string(let delimiter) = arguments[1] {
                let parts = str.components(separatedBy: delimiter)
                let values = parts.map { VariableValue.string($0) }
                return .array(values)
            }
            return .array([])

        case "FIND":
            guard arguments.count >= 2 else { return .integer(-1) }
            if case .string(let str) = arguments[0],
               case .string(let search) = arguments[1] {
                if let range = str.range(of: search) {
                    let offset = str.distance(from: str.startIndex, to: range.lowerBound)
                    return .integer(Int64(offset))
                }
                return .integer(-1)
            }
            return .integer(-1)

        case "UPPER":
            guard let arg = arguments.first else { return .string("") }
            if case .string(let str) = arg {
                return .string(str.uppercased())
            }
            return .string("")

        case "LOWER":
            guard let arg = arguments.first else { return .string("") }
            if case .string(let str) = arg {
                return .string(str.lowercased())
            }
            return .string("")

        case "TRIM":
            guard let arg = arguments.first else { return .string("") }
            if case .string(let str) = arg {
                return .string(str.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            return .string("")

        case "UNICODE":
            guard let arg = arguments.first else { return .string("") }
            if case .integer(let code) = arg {
                if let scalar = UnicodeScalar(Int(code)) {
                    return .string(String(Character(scalar)))
                }
            }
            return .string("")

        case "ENCODETOUNI":
            guard let arg = arguments.first else { return .string("") }
            if case .string(let str) = arg {
                // 简化实现：返回UTF-8编码的十六进制表示
                let hex = str.unicodeScalars.map { String(format: "%04X", $0.value) }.joined()
                return .string(hex)
            }
            return .string("")

        // MARK: - 数组函数
        case "FINDELEMENT":
            guard arguments.count >= 2 else { return .integer(-1) }
            if case .array(let arr) = arguments[0],
               case .integer(let value) = arguments[1] {
                for (index, item) in arr.enumerated() {
                    if case .integer(let itemValue) = item, itemValue == value {
                        return .integer(Int64(index))
                    }
                }
            }
            return .integer(-1)

        case "FINDLAST":
            guard arguments.count >= 2 else { return .integer(-1) }
            if case .array(let arr) = arguments[0],
               case .integer(let value) = arguments[1] {
                for (index, item) in arr.enumerated().reversed() {
                    if case .integer(let itemValue) = item, itemValue == value {
                        return .integer(Int64(index))
                    }
                }
            }
            return .integer(-1)

        case "VARSIZE":
            guard let arg = arguments.first else { return .integer(0) }
            if case .array(let arr) = arg {
                return .integer(Int64(arr.count))
            }
            return .integer(0)

        case "REPEAT":
            guard arguments.count >= 2 else { return .array([]) }
            if case .integer(let count) = arguments[0],
               case .integer(let value) = arguments[1] {
                let arr = Array(repeating: value, count: Int(count))
                return .array(arr.map { .integer($0) })
            }
            return .array([])

        // MARK: - 位运算
        case "GETBIT":
            guard arguments.count >= 2 else { return .integer(0) }
            if case .integer(let value) = arguments[0],
               case .integer(let bit) = arguments[1] {
                return .integer((value >> bit) & 1)
            }
            return .integer(0)

        case "SETBIT":
            guard arguments.count >= 2 else { return .integer(0) }
            if case .integer(let value) = arguments[0],
               case .integer(let bit) = arguments[1] {
                return .integer(value | (1 << bit))
            }
            return .integer(0)

        case "CLEARBIT":
            guard arguments.count >= 2 else { return .integer(0) }
            if case .integer(let value) = arguments[0],
               case .integer(let bit) = arguments[1] {
                return .integer(value & ~(1 << bit))
            }
            return .integer(0)

        case "INVERTBIT":
            guard arguments.count >= 2 else { return .integer(0) }
            if case .integer(let value) = arguments[0],
               case .integer(let bit) = arguments[1] {
                return .integer(value ^ (1 << bit))
            }
            return .integer(0)

        case "SUMARRAYS":
            var sum: Int64 = 0
            for arg in arguments {
                if case .array(let arr) = arg {
                    for item in arr {
                        if case .integer(let value) = item {
                            sum += value
                        }
                    }
                }
            }
            return .integer(sum)

        // MARK: - 系统函数
        case "CHARANUM":
            // 返回变量数量（简化实现）
            if let ctx = context {
                return .integer(Int64(ctx.variables.count))
            }
            return .integer(0)

        case "RESULT":
            if let ctx = context {
                return ctx.lastResult
            }
            return .integer(0)

        case "RESULTS":
            if let ctx = context {
                if case .string(let str) = ctx.lastResult {
                    return .string(str)
                }
            }
            return .string("")

        case "__INT_MAX__":
            return .integer(Int64.max)

        case "__INT_MIN__":
            return .integer(Int64.min)

        case "__INT64_MAX__":
            return .integer(Int64.max)

        case "__INT64_MIN__":
            return .integer(Int64.min)

        // MARK: - 时间函数
        case "TIME":
            let now = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)
            return .integer(Int64(hour * 100 + minute))

        case "GETTIME":
            return .integer(Int64(Date().timeIntervalSince1970))

        case "YEAR":
            let now = Date()
            let calendar = Calendar.current
            return .integer(Int64(calendar.component(.year, from: now)))

        case "MONTH":
            let now = Date()
            let calendar = Calendar.current
            return .integer(Int64(calendar.component(.month, from: now)))

        case "DAY":
            let now = Date()
            let calendar = Calendar.current
            return .integer(Int64(calendar.component(.day, from: now)))

        case "HOUR":
            let now = Date()
            let calendar = Calendar.current
            return .integer(Int64(calendar.component(.hour, from: now)))

        case "MINUTE":
            let now = Date()
            let calendar = Calendar.current
            return .integer(Int64(calendar.component(.minute, from: now)))

        case "SECOND":
            let now = Date()
            let calendar = Calendar.current
            return .integer(Int64(calendar.component(.second, from: now)))

        // MARK: - 类型转换
        case "TO_STRING":
            guard let arg = arguments.first else { return .string("") }
            return .string(arg.description)

        case "TO_INTEGER":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                return .integer(value)
            }
            if case .string(let str) = arg {
                return .integer(Int64(str) ?? 0)
            }
            return .integer(0)

        case "ISNUMERIC":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer = arg {
                return .integer(1)
            }
            if case .string(let str) = arg {
                return .integer(Int64(str) != nil ? 1 : 0)
            }
            return .integer(0)

        case "ISNULL":
            guard let arg = arguments.first else { return .integer(1) }
            if case .null = arg {
                return .integer(1)
            }
            return .integer(0)

        case "TYPEOF":
            guard let arg = arguments.first else { return .string("UNKNOWN") }
            switch arg {
            case .integer: return .string("INTEGER")
            case .string: return .string("STRING")
            case .array: return .string("ARRAY")
            case .character: return .string("CHARACTER")
            case .null: return .string("NULL")
            }

        // MARK: - 未实现的函数
        case "GAMEBASE", "VERSION", "FORM":
            // 这些函数需要更多信息或上下文
            return .string("")

        default:
            throw EmueraError.functionNotFound(name: name)
        }
    }

    /// 检查函数是否存在
    public static func exists(_ name: String) -> Bool {
        return FunctionType.fromString(name) != nil
    }

    /// 获取所有可用函数名
    public static var allFunctionNames: [String] {
        return FunctionType.allCases.map { $0.rawValue }
    }
}
