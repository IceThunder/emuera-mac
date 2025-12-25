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
    case CBRT           // 立方根
    case SIGN           // 符号函数
    case POWER          // 幂运算
    case MIN            // 最小值
    case MAX            // 最大值
    case LIMIT          // 限制范围
    case SUM            // 求和
    case PI             // 圆周率常量

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
    case STRLENFORM     // 字符串长度（格式化）
    case SUBSTRING      // 子字符串
    case SUBSTRINGU     // 子字符串（Unicode）
    case REPLACE        // 替换
    case SPLIT          // 分割
    case FIND           // 查找
    case STRFIND        // 查找（Unicode）
    case STRCOUNT       // 统计出现次数
    case UPPER          // 转大写
    case LOWER          // 转小写
    case TOUPPER        // 转大写（别名）
    case TOLOWER        // 转小写（别名）
    case TRIM           // 去除空白
    case UNICODE        // Unicode转字符
    case ENCODETOUNI    // 编码到Unicode
    case ESCAPE         // 转义字符

    // MARK: - 数组函数
    case FINDELEMENT    // 查找元素
    case FINDLAST       // 查找最后一个
    case SORT           // 排序
    case UNIQUE         // 去重
    case REVERSE        // 反转
    case REPEAT         // 重复
    case VARSIZE        // 数组大小
    case ARRAYSHIFT     // 数组移位
    case ARRAYREMOVE    // 数组删除
    case ARRAYSORT      // 数组排序
    case ARRAYCOPY      // 数组复制
    case ARRAYMULTISORT // 多数组排序
    case INRANGE        // 范围检查
    case INRANGEARRAY   // 数组范围检查

    // MARK: - 位运算
    case GETBIT         // 获取位
    case SETBIT         // 设置位
    case CLEARBIT       // 清除位
    case INVERTBIT      // 反转位
    case SUMARRAYS      // 数组求和
    case GETNUM         // 获取数值（位运算）
    case GETNUMB        // 获取数值（位运算，字节）

    // MARK: - 系统函数
    case GAMEBASE       // 游戏基础信息
    case VERSION        // 版本
    case TIME           // 时间
    case GETTIME        // 获取时间
    case CHARANUM       // 角色数量
    case RESULT         // 结果变量
    case RESULTS        // 结果字符串变量
    case CHECKFONT      // 检查字体
    case CHECKDATA      // 检查数据
    case ISSKIP         // 是否跳过
    case GETCOLOR       // 获取颜色
    case BARSTRING      // 条形字符串

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
    case GETDATE        // 获取日期字符串
    case GETDATETIME    // 获取日期时间字符串
    case TIMESTAMP      // 时间戳
    case DATE           // 日期字符串
    case DATEFORM       // 格式化日期
    case GETTIMES       // 获取时间戳（毫秒）

    // MARK: - 文件操作
    case FILEEXISTS     // 文件是否存在
    case FILEDELETE     // 删除文件
    case FILECOPY       // 复制文件
    case FILEREAD       // 读取文件
    case FILEWRITE      // 写入文件
    case DIRECTORYLIST  // 目录列表

    // MARK: - 系统信息
    case GETTYPE        // 获取类型
    case GETS           // 获取字符串
    case GETDATA        // 获取数据
    case GETERROR       // 获取错误信息

    // MARK: - 其他
    case ISNUMERIC      // 是否数字
    case ISNULL         // 是否空值
    case TYPEOF         // 类型
    case GETPALLV       // 获取PALAM数值
    case GETEXPLV       // 获取EXP数值
    case MATCH          // 匹配
    case GROUPMATCH     // 组匹配
    case NOSAMES        // 不相同
    case ALLSAMES       // 全相同

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

        case "ASIN":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                // ASIN参数需要在-1到1之间
                let doubleValue = Double(value) / 1000.0
                if doubleValue < -1.0 || doubleValue > 1.0 {
                    return .integer(0)
                }
                let result = asin(doubleValue)
                return .integer(Int64(result * 180.0 / .pi))  // 弧度转角度
            }
            return .integer(0)

        case "ACOS":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                // ACOS参数需要在-1到1之间
                let doubleValue = Double(value) / 1000.0
                if doubleValue < -1.0 || doubleValue > 1.0 {
                    return .integer(0)
                }
                let result = acos(doubleValue)
                return .integer(Int64(result * 180.0 / .pi))  // 弧度转角度
            }
            return .integer(0)

        case "ATAN":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                let doubleValue = Double(value) / 1000.0
                let result = atan(doubleValue)
                return .integer(Int64(result * 180.0 / .pi))  // 弧度转角度
            }
            return .integer(0)

        case "CBRT":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                return .integer(Int64(cbrt(Double(value))))
            }
            return .integer(0)

        case "SIGN":
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                if value > 0 { return .integer(1) }
                if value < 0 { return .integer(-1) }
                return .integer(0)
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

        case "PI":
            // PI常量，返回314159（表示3.14159，乘以100000）
            return .integer(314159)

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

        case "UPPER", "TOUPPER":
            guard let arg = arguments.first else { return .string("") }
            if case .string(let str) = arg {
                return .string(str.uppercased())
            }
            return .string("")

        case "LOWER", "TOLOWER":
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

        case "STRLENFORM":
            // STRLENFORM与STRLENS相同，都返回字符数
            guard let arg = arguments.first else { return .integer(0) }
            if case .string(let str) = arg {
                return .integer(Int64(str.count))
            }
            return .integer(0)

        case "SUBSTRINGU":
            // Unicode版本的SUBSTRING
            guard arguments.count >= 2 else { return .string("") }
            if case .string(let str) = arguments[0],
               case .integer(let start) = arguments[1] {
                let scalars = Array(str.unicodeScalars)
                let startIndex = max(0, Int(start))
                guard startIndex < scalars.count else { return .string("") }

                if arguments.count >= 3 {
                    if case .integer(let length) = arguments[2] {
                        let endIndex = min(startIndex + Int(length), scalars.count)
                        let result = scalars[startIndex..<endIndex]
                        return .string(String(String.UnicodeScalarView(result)))
                    }
                }
                let result = scalars[startIndex...]
                return .string(String(String.UnicodeScalarView(result)))
            }
            return .string("")

        case "STRFIND":
            // 查找子串位置（Unicode感知）
            guard arguments.count >= 2 else { return .integer(-1) }
            if case .string(let str) = arguments[0],
               case .string(let search) = arguments[1] {
                if let range = str.range(of: search) {
                    let offset = str.unicodeScalars.distance(from: str.unicodeScalars.startIndex, to: range.lowerBound)
                    return .integer(Int64(offset))
                }
                return .integer(-1)
            }
            return .integer(-1)

        case "STRCOUNT":
            // 统计子串出现次数
            guard arguments.count >= 2 else { return .integer(0) }
            if case .string(let str) = arguments[0],
               case .string(let search) = arguments[1] {
                if search.isEmpty { return .integer(0) }
                let count = str.components(separatedBy: search).count - 1
                return .integer(Int64(count))
            }
            return .integer(0)

        case "ESCAPE":
            // 转义特殊字符 - 将控制字符转换为转义序列
            // 注意：不转义反斜杠本身，只转义控制字符和引号
            guard let arg = arguments.first else { return .string("") }
            if case .string(let str) = arg {
                var result = ""
                for char in str {
                    switch char {
                    case "\"": result += "\\\""
                    case "\n": result += "\\n"
                    case "\r": result += "\\r"
                    case "\t": result += "\\t"
                    default: result.append(char)
                    }
                }
                return .string(result)
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
            if case .integer(let value) = arguments[0],
               case .integer(let count) = arguments[1] {
                let arr = Array(repeating: value, count: Int(count))
                return .array(arr.map { .integer($0) })
            }
            return .array([])

        case "ARRAYMULTISORT":
            // 多数组排序（简化实现：只排序第一个数组，其他数组跟随）
            guard arguments.count >= 1 else { return .null }
            if case .array(let arr) = arguments[0] {
                let sorted = arr.sorted { a, b in
                    switch (a, b) {
                    case (.integer(let ia), .integer(let ib)): return ia < ib
                    case (.string(let sa), .string(let sb)): return sa < sb
                    default: return false
                    }
                }
                return .array(sorted)
            }
            return .null

        case "UNIQUE":
            // 数组去重
            guard arguments.count >= 1 else { return .array([]) }
            if case .array(let arr) = arguments[0] {
                var seen: [VariableValue] = []
                var result: [VariableValue] = []
                for item in arr {
                    if !seen.contains(where: { $0 == item }) {
                        seen.append(item)
                        result.append(item)
                    }
                }
                return .array(result)
            }
            return .array([])

        case "SORT":
            // 数组排序
            guard arguments.count >= 1 else { return .array([]) }
            if case .array(let arr) = arguments[0] {
                let ascending = arguments.count < 2 || {
                    if case .integer(let order) = arguments[1] { return order >= 0 }
                    if case .string(let order) = arguments[1] { return order.uppercased() != "DESC" }
                    return true
                }()

                let sorted = arr.sorted { a, b in
                    let comparison: Bool
                    switch (a, b) {
                    case (.integer(let ia), .integer(let ib)):
                        comparison = ia < ib
                    case (.string(let sa), .string(let sb)):
                        comparison = sa < sb
                    default:
                        comparison = false
                    }
                    return ascending ? comparison : !comparison
                }
                return .array(sorted)
            }
            return .array([])

        case "REVERSE":
            // 数组反转
            guard arguments.count >= 1 else { return .array([]) }
            if case .array(let arr) = arguments[0] {
                return .array(Array(arr.reversed()))
            }
            return .array([])

        case "ARRAYSHIFT":
            // 数组元素移动
            guard arguments.count >= 2 else { return .array([]) }
            if case .array(let arr) = arguments[0], case .integer(let shift) = arguments[1] {
                let count = Int(shift)
                if count == 0 { return .array(arr) }

                var result = arr
                if count > 0 {
                    // 向右移动，末尾元素移到开头
                    for _ in 0..<count {
                        if let last = result.popLast() {
                            result.insert(last, at: 0)
                        }
                    }
                } else {
                    // 向左移动，开头元素移到末尾
                    for _ in 0..<(-count) {
                        if let first = result.first {
                            result.remove(at: 0)
                            result.append(first)
                        }
                    }
                }
                return .array(result)
            }
            return .array([])

        case "ARRAYREMOVE":
            // 移除数组元素
            guard arguments.count >= 2 else { return .array([]) }
            if case .array(let arr) = arguments[0], case .integer(let index) = arguments[1] {
                let idx = Int(index)
                if idx >= 0 && idx < arr.count {
                    var result = arr
                    result.remove(at: idx)
                    return .array(result)
                }
            }
            return .array([])

        case "ARRAYCOPY":
            // 复制数组
            guard arguments.count >= 1 else { return .array([]) }
            if case .array(let arr) = arguments[0] {
                return .array(arr)
            }
            return .array([])

        case "ARRAYSORT":
            // 数组排序（兼容ARRAYMULTISORT）
            guard arguments.count >= 1 else { return .array([]) }
            if case .array(let arr) = arguments[0] {
                let ascending = arguments.count < 2 || {
                    if case .integer(let order) = arguments[1] { return order >= 0 }
                    if case .string(let order) = arguments[1] { return order.uppercased() != "DESC" }
                    return true
                }()

                let sorted = arr.sorted { a, b in
                    let comparison: Bool
                    switch (a, b) {
                    case (.integer(let ia), .integer(let ib)):
                        comparison = ia < ib
                    case (.string(let sa), .string(let sb)):
                        comparison = sa < sb
                    default:
                        comparison = false
                    }
                    return ascending ? comparison : !comparison
                }
                return .array(sorted)
            }
            return .array([])

        case "INRANGE":
            // 检查值是否在范围内
            guard arguments.count >= 3 else { return .integer(0) }
            if case .integer(let value) = arguments[0],
               case .integer(let min) = arguments[1],
               case .integer(let max) = arguments[2] {
                return .integer(value >= min && value <= max ? 1 : 0)
            }
            return .integer(0)

        case "INRANGEARRAY":
            // 检查数组元素是否在范围内
            guard arguments.count >= 3 else { return .integer(0) }
            if case .array(let arr) = arguments[0],
               case .integer(let min) = arguments[1],
               case .integer(let max) = arguments[2] {
                for item in arr {
                    if case .integer(let value) = item {
                        if value < min || value > max {
                            return .integer(0)
                        }
                    }
                }
                return .integer(1)
            }
            return .integer(0)

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

        case "GETNUM":
            // GETNUM(value, bitPos, bitCount) - 从value中提取从bitPos开始的bitCount位
            guard arguments.count >= 3 else { return .integer(0) }
            if case .integer(let value) = arguments[0],
               case .integer(let bitPos) = arguments[1],
               case .integer(let bitCount) = arguments[2] {
                let mask = (Int64(1) << bitCount) - 1
                return .integer((value >> bitPos) & mask)
            }
            return .integer(0)

        case "GETNUMB":
            // GETNUMB(value, bytePos) - 获取value中指定字节位置的字节值
            guard arguments.count >= 2 else { return .integer(0) }
            if case .integer(let value) = arguments[0],
               case .integer(let bytePos) = arguments[1] {
                return .integer((value >> (bytePos * 8)) & 0xFF)
            }
            return .integer(0)

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

        case "GETDATE":
            // 返回格式: YYYYMMDD
            let now = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: now)
            let month = calendar.component(.month, from: now)
            let day = calendar.component(.day, from: now)
            return .string(String(format: "%04d%02d%02d", year, month, day))

        case "GETDATETIME":
            // 返回格式: YYYYMMDDHHMMSS
            let now = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: now)
            let month = calendar.component(.month, from: now)
            let day = calendar.component(.day, from: now)
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)
            let second = calendar.component(.second, from: now)
            return .string(String(format: "%04d%02d%02d%02d%02d%02d", year, month, day, hour, minute, second))

        case "TIMESTAMP":
            // 返回当前时间戳（秒）
            return .integer(Int64(Date().timeIntervalSince1970))

        case "DATE":
            // 返回格式: YYYY/MM/DD
            let now = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: now)
            let month = calendar.component(.month, from: now)
            let day = calendar.component(.day, from: now)
            return .string(String(format: "%04d/%02d/%02d", year, month, day))

        case "DATEFORM":
            // 格式化日期，支持自定义格式
            // 简化实现：返回YYYY/MM/DD HH:MM:SS
            let now = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: now)
            let month = calendar.component(.month, from: now)
            let day = calendar.component(.day, from: now)
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)
            let second = calendar.component(.second, from: now)
            return .string(String(format: "%04d/%02d/%02d %02d:%02d:%02d", year, month, day, hour, minute, second))

        case "GETTIMES":
            // 返回当前时间戳（毫秒）
            let time = Date().timeIntervalSince1970
            return .integer(Int64(time * 1000))

        // MARK: - 文件操作
        case "FILEEXISTS":
            // 检查文件是否存在
            guard let arg = arguments.first else { return .integer(0) }
            if case .string(let filename) = arg {
                let fileURL = getFileURL(filename)
                return .integer(FileManager.default.fileExists(atPath: fileURL.path) ? 1 : 0)
            }
            return .integer(0)

        case "FILEDELETE":
            // 删除文件
            guard let arg = arguments.first else { return .integer(0) }
            if case .string(let filename) = arg {
                let fileURL = getFileURL(filename)
                do {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                        return .integer(1)
                    }
                    return .integer(0)
                } catch {
                    return .integer(0)
                }
            }
            return .integer(0)

        case "FILECOPY":
            // 复制文件
            guard arguments.count >= 2 else { return .integer(0) }
            if case .string(let src) = arguments[0],
               case .string(let dst) = arguments[1] {
                let srcURL = getFileURL(src)
                let dstURL = getFileURL(dst)
                do {
                    if FileManager.default.fileExists(atPath: srcURL.path) {
                        try FileManager.default.copyItem(at: srcURL, to: dstURL)
                        return .integer(1)
                    }
                    return .integer(0)
                } catch {
                    return .integer(0)
                }
            }
            return .integer(0)

        case "FILEREAD":
            // 读取文件内容
            guard let arg = arguments.first else { return .string("") }
            if case .string(let filename) = arg {
                let fileURL = getFileURL(filename)
                do {
                    let content = try String(contentsOf: fileURL, encoding: .utf8)
                    return .string(content)
                } catch {
                    return .string("")
                }
            }
            return .string("")

        case "FILEWRITE":
            // 写入文件
            guard arguments.count >= 2 else { return .integer(0) }
            if case .string(let filename) = arguments[0],
               case .string(let content) = arguments[1] {
                let fileURL = getFileURL(filename)
                do {
                    try content.write(to: fileURL, atomically: true, encoding: .utf8)
                    return .integer(1)
                } catch {
                    return .integer(0)
                }
            }
            return .integer(0)

        case "DIRECTORYLIST":
            // 列出目录中的文件
            guard let arg = arguments.first else { return .array([]) }
            if case .string(let dirname) = arg {
                let dirURL = getDirectoryURL(dirname)
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)
                    let fileNames = contents.map { VariableValue.string($0.lastPathComponent) }
                    return .array(fileNames)
                } catch {
                    return .array([])
                }
            }
            return .array([])

        // MARK: - 系统信息
        case "GETTYPE":
            // 获取变量类型
            guard let arg = arguments.first else { return .string("UNKNOWN") }
            switch arg {
            case .integer: return .string("INTEGER")
            case .string: return .string("STRING")
            case .array: return .string("ARRAY")
            case .character: return .string("CHARACTER")
            case .null: return .string("NULL")
            }

        case "GETS":
            // 获取字符串表示
            guard let arg = arguments.first else { return .string("") }
            return .string(arg.description)

        case "GETDATA":
            // 获取数据（简化实现，返回参数值）
            guard let arg = arguments.first else { return .integer(0) }
            return arg

        case "GETERROR":
            // 获取错误信息（当前无错误）
            return .string("")

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
            // Also check for string "NULL" as a special case
            if case .string(let str) = arg, str.uppercased() == "NULL" {
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

        // MARK: - 新增系统函数（简化实现）
        case "CHECKFONT":
            // 检查字体是否存在 - 总是返回1（存在）
            return .integer(1)

        case "CHECKDATA":
            // 检查数据文件是否存在 - 总是返回1（存在）
            return .integer(1)

        case "ISSKIP":
            // 检查是否跳过 - 返回0（不跳过）
            return .integer(0)

        case "GETCOLOR":
            // 获取当前颜色 - 返回默认值
            return .integer(0)

        case "BARSTRING":
            // BARSTRING(value, max, length, char1, char2) - 自定义条形图
            if arguments.count >= 3,
               case .integer(let val) = arguments[0],
               case .integer(let max) = arguments[1],
               case .integer(let len) = arguments[2] {
                let ratio = max > 0 ? Double(val) / Double(max) : 0
                let filled = Int(ratio * Double(len))

                // Get fill and empty characters (default: * and .)
                var fillChar: Character = "*"
                var emptyChar: Character = "."

                if arguments.count >= 4, case .string(let str) = arguments[3], !str.isEmpty {
                    fillChar = str.first!
                }
                if arguments.count >= 5, case .string(let str) = arguments[4], !str.isEmpty {
                    emptyChar = str.first!
                }

                let bar = String(repeating: fillChar, count: filled) +
                         String(repeating: emptyChar, count: Int(len) - filled)
                return .string("[\(bar)]")
            }
            return .string("")

        // MARK: - 特殊数学函数
        case "GETPALLV":
            // GETPALLV(数值) - 获取PALAM相关数值（简化：返回输入值）
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                return .integer(value)
            }
            return .integer(0)

        case "GETEXPLV":
            // GETEXPLV(数值) - 获取EXP相关数值（简化：返回输入值）
            guard let arg = arguments.first else { return .integer(0) }
            if case .integer(let value) = arg {
                return .integer(value)
            }
            return .integer(0)

        case "MATCH":
            // MATCH(变量, 值) - 检查变量是否匹配值
            guard arguments.count >= 2 else { return .integer(0) }
            return .integer(arguments[0] == arguments[1] ? 1 : 0)

        case "GROUPMATCH":
            // GROUPMATCH(变量, 值1, 值2, ...) - 检查变量是否匹配任意值
            guard arguments.count >= 2 else { return .integer(0) }
            let target = arguments[0]
            for i in 1..<arguments.count {
                if target == arguments[i] {
                    return .integer(1)
                }
            }
            return .integer(0)

        case "NOSAMES":
            // NOSAMES(值1, 值2, ...) - 检查所有值是否都不相同
            guard arguments.count >= 2 else { return .integer(1) }
            for i in 0..<arguments.count - 1 {
                for j in i+1..<arguments.count {
                    if arguments[i] == arguments[j] {
                        return .integer(0)
                    }
                }
            }
            return .integer(1)

        case "ALLSAMES":
            // ALLSAMES(值1, 值2, ...) - 检查所有值是否都相同
            guard arguments.count >= 2 else { return .integer(1) }
            let first = arguments[0]
            for i in 1..<arguments.count {
                if arguments[i] != first {
                    return .integer(0)
                }
            }
            return .integer(1)

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

    /// 获取文件URL（保存在应用目录下的data文件夹）
    private static func getFileURL(_ filename: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths[0]
        let dataURL = documentsURL.appendingPathComponent("EmueraData")

        // 确保目录存在
        try? FileManager.default.createDirectory(at: dataURL, withIntermediateDirectories: true)

        // 自动添加扩展名如果未指定
        let finalFilename = filename.hasSuffix(".txt") ? filename : "\(filename).txt"
        return dataURL.appendingPathComponent(finalFilename)
    }

    /// 获取目录URL
    private static func getDirectoryURL(_ dirname: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths[0]
        let dataURL = documentsURL.appendingPathComponent("EmueraData")

        // 确保目录存在
        try? FileManager.default.createDirectory(at: dataURL, withIntermediateDirectories: true)

        return dataURL
    }
}
