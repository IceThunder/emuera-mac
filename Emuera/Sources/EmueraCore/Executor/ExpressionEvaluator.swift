//
//  ExpressionEvaluator.swift
//  EmueraCore
//
//  表达式求值器 - 执行ExpressionNode并返回VariableValue
//  Created: 2025-12-18
//

import Foundation

/// 表达式求值器
public class ExpressionEvaluator {

    private let variableData: VariableData
    private let tokenData: TokenData

    public init(variableData: VariableData) {
        self.variableData = variableData
        self.tokenData = variableData.getTokenData()
    }

    /// 求值表达式AST，返回VariableValue
    public func evaluate(_ node: ExpressionNode) throws -> VariableValue {
        switch node {
        case .integer(let value):
            return .integer(value)

        case .string(let value):
            return .string(value)

        case .variable(let name):
            return try resolveVariable(name)

        case .arrayAccess(let base, let indices):
            return try evaluateArrayAccess(base: base, indices: indices)

        case .functionCall(let name, let arguments):
            return try evaluateFunctionCall(name: name, arguments: arguments)

        case .binary(let op, let left, let right):
            return try evaluateBinary(op: op, left: left, right: right)
        }
    }

    // MARK: - 变量解析

    /// 解析变量引用（使用TokenData系统）
    private func resolveVariable(_ name: String) throws -> VariableValue {
        // 处理数组语法: A:5, BASE:0, CHARA_0_NAME等
        // 格式: VARNAME:INDEX 或 VARNAME:INDEX:INDEX...
        if name.contains(":") {
            let parts = name.split(separator: ":")
            if parts.count == 2 {
                // 1D数组: A:5, BASE:0
                let varName = String(parts[0])
                if let index = Int64(parts[1]) {
                    do {
                        let value = try tokenData.getIntValue(varName, arguments: [index])
                        return .integer(value)
                    } catch {
                        // 尝试字符串数组
                        do {
                            let strValue = try tokenData.getStrValue(varName, arguments: [index])
                            return .string(strValue)
                        } catch {
                            // 变量不存在，返回0
                            return .integer(0)
                        }
                    }
                }
            } else if parts.count == 3 {
                // 2D数组: CDFLAG:0:5
                let varName = String(parts[0])
                if let i1 = Int64(parts[1]), let i2 = Int64(parts[2]) {
                    do {
                        let value = try tokenData.getIntValue(varName, arguments: [i1, i2])
                        return .integer(value)
                    } catch {
                        return .integer(0)
                    }
                }
            }
        }

        // 处理普通变量: DAY, MONEY, A, B等
        do {
            // 尝试整数变量
            let value = try tokenData.getIntValue(name, arguments: [])
            return .integer(value)
        } catch {
            do {
                // 尝试字符串变量
                let strValue = try tokenData.getStrValue(name, arguments: [])
                return .string(strValue)
            } catch {
                // 变量不存在，返回0（Emuera行为）
                return .integer(0)
            }
        }
    }

    // MARK: - 数组访问

    /// 求值数组访问: A[5], BASE[0], CDFLAG[0,5]
    private func evaluateArrayAccess(base: String, indices: [ExpressionNode]) throws -> VariableValue {
        // 求值所有索引
        let indexValues = try indices.map { try evaluate($0).toInt() }

        // 转换为Int64数组
        let intIndices = indexValues.map { Int64($0) }

        // 根据索引数量调用对应方法
        switch intIndices.count {
        case 1:
            // 1D数组
            do {
                let value = try tokenData.getIntValue(base, arguments: intIndices)
                return .integer(value)
            } catch {
                // 尝试字符串数组
                do {
                    let strValue = try tokenData.getStrValue(base, arguments: intIndices)
                    return .string(strValue)
                } catch {
                    return .integer(0)
                }
            }
        case 2:
            // 2D数组
            do {
                let value = try tokenData.getIntValue(base, arguments: intIndices)
                return .integer(value)
            } catch {
                return .integer(0)
            }
        case 3:
            // 3D数组
            do {
                let value = try tokenData.getIntValue(base, arguments: intIndices)
                return .integer(value)
            } catch {
                return .integer(0)
            }
        default:
            throw EvaluateError.invalidOperation("不支持的数组维度: \(intIndices.count)")
        }
    }

    // MARK: - 函数调用

    /// 求值函数调用: RAND(100), ABS(-5)
    private func evaluateFunctionCall(name: String, arguments: [ExpressionNode]) throws -> VariableValue {
        // 求值所有参数
        let argValues = try arguments.map { try evaluate($0) }

        // 处理内置函数
        switch name.uppercased() {
        case "RAND":
            // RAND(max) 或 RAND(min, max)
            if argValues.count == 1, case .integer(let max) = argValues[0] {
                return .integer(Int64.random(in: 0..<max))
            } else if argValues.count == 2,
                      case .integer(let min) = argValues[0],
                      case .integer(let max) = argValues[1] {
                return .integer(Int64.random(in: min..<max))
            }
            throw EvaluateError.invalidOperation("RAND需要1或2个整数参数")

        case "ABS":
            if argValues.count == 1, case .integer(let value) = argValues[0] {
                return .integer(value < 0 ? -value : value)
            }
            throw EvaluateError.invalidOperation("ABS需要1个整数参数")

        case "SQRT":
            if argValues.count == 1, case .integer(let value) = argValues[0] {
                return .integer(Int64(sqrt(Double(value))))
            }
            throw EvaluateError.invalidOperation("SQRT需要1个整数参数")

        case "MIN":
            if argValues.count >= 2 {
                let ints = argValues.compactMap { if case .integer(let v) = $0 { return v }; return nil }
                if ints.count == argValues.count {
                    return .integer(ints.min() ?? 0)
                }
            }
            throw EvaluateError.invalidOperation("MIN需要至少2个整数参数")

        case "MAX":
            if argValues.count >= 2 {
                let ints = argValues.compactMap { if case .integer(let v) = $0 { return v }; return nil }
                if ints.count == argValues.count {
                    return .integer(ints.max() ?? 0)
                }
            }
            throw EvaluateError.invalidOperation("MAX需要至少2个整数参数")

        default:
            // 尝试从TokenData查找伪变量或函数
            do {
                // 尝试作为整数函数调用
                let value = try tokenData.getIntValue(name, arguments: argValues.map { $0.toInt() })
                return .integer(value)
            } catch {
                // 尝试作为字符串函数调用
                do {
                    let strValue = try tokenData.getStrValue(name, arguments: argValues.map { $0.toInt() })
                    return .string(strValue)
                } catch {
                    throw EvaluateError.variableNotFound(name)
                }
            }
        }
    }

    // MARK: - 二元运算

    /// 求值二元运算
    private func evaluateBinary(op: TokenType.Operator, left: ExpressionNode, right: ExpressionNode) throws -> VariableValue {
        let leftVal = try evaluate(left)
        let rightVal = try evaluate(right)

        switch op {
        // 算术运算
        case .add:
            return try add(leftVal, rightVal)
        case .subtract:
            return try subtract(leftVal, rightVal)
        case .multiply:
            return try multiply(leftVal, rightVal)
        case .divide:
            return try divide(leftVal, rightVal)
        case .modulo:
            return try modulo(leftVal, rightVal)
        case .power:
            return try power(leftVal, rightVal)

        // 比较运算
        case .equal:
            return .integer(leftVal == rightVal ? 1 : 0)
        case .notEqual:
            return .integer(leftVal != rightVal ? 1 : 0)
        case .less:
            return .integer(try compare(leftVal, rightVal) < 0 ? 1 : 0)
        case .lessEqual:
            return .integer(try compare(leftVal, rightVal) <= 0 ? 1 : 0)
        case .greater:
            return .integer(try compare(leftVal, rightVal) > 0 ? 1 : 0)
        case .greaterEqual:
            return .integer(try compare(leftVal, rightVal) >= 0 ? 1 : 0)

        // 逻辑运算
        case .and:
            return .integer((leftVal.toInt() != 0 && rightVal.toInt() != 0) ? 1 : 0)
        case .or:
            return .integer((leftVal.toInt() != 0 || rightVal.toInt() != 0) ? 1 : 0)

        // 位运算
        case .bitAnd:
            return .integer(leftVal.toInt() & rightVal.toInt())
        case .bitOr:
            return .integer(leftVal.toInt() | rightVal.toInt())
        case .bitXor:
            return .integer(leftVal.toInt() ^ rightVal.toInt())
        case .shiftLeft:
            return .integer(leftVal.toInt() << rightVal.toInt())
        case .shiftRight:
            return .integer(leftVal.toInt() >> rightVal.toInt())

        // 一元运算符（暂不支持）
        case .not, .bitNot:
            throw EvaluateError.invalidOperation("一元运算符 \(op.rawValue) 暂不支持")

        // 赋值运算（不应该在这里使用）
        case .assign, .addAssign, .subtractAssign, .multiplyAssign, .divideAssign:
            throw EvaluateError.invalidOperation("赋值运算符不能在表达式求值中使用")
        }
    }

    // MARK: - 算术运算实现

    /// 加法
    private func add(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        switch (left, right) {
        case (.integer(let l), .integer(let r)):
            return .integer(l + r)
        case (.string(let l), .string(let r)):
            return .string(l + r)
        case (.integer(let l), .string(let r)):
            return .string("\(l)\(r)")
        case (.string(let l), .integer(let r)):
            return .string("\(l)\(r)")
        default:
            throw EvaluateError.typeMismatch("不支持的加法操作")
        }
    }

    /// 减法
    private func subtract(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EvaluateError.typeMismatch("减法需要整数类型")
        }
        return .integer(l - r)
    }

    /// 乘法
    private func multiply(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EvaluateError.typeMismatch("乘法需要整数类型")
        }
        return .integer(l * r)
    }

    /// 除法
    private func divide(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EvaluateError.typeMismatch("除法需要整数类型")
        }
        if r == 0 {
            throw EvaluateError.divisionByZero
        }
        return .integer(l / r)
    }

    /// 取模
    private func modulo(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EvaluateError.typeMismatch("取模需要整数类型")
        }
        if r == 0 {
            throw EvaluateError.divisionByZero
        }
        return .integer(l % r)
    }

    /// 幂运算
    private func power(_ left: VariableValue, _ right: VariableValue) throws -> VariableValue {
        guard case .integer(let l) = left, case .integer(let r) = right else {
            throw EvaluateError.typeMismatch("幂运算需要整数类型")
        }
        // 简单实现，不处理溢出
        return .integer(Int64(pow(Double(l), Double(r))))
    }

    // MARK: - 比较运算

    /// 比较两个值，返回 -1/0/1
    private func compare(_ left: VariableValue, _ right: VariableValue) throws -> Int {
        switch (left, right) {
        case (.integer(let l), .integer(let r)):
            if l < r { return -1 }
            if l > r { return 1 }
            return 0
        case (.string(let l), .string(let r)):
            return l.compare(r).rawValue
        default:
            throw EvaluateError.typeMismatch("不支持的比较操作")
        }
    }
}

// MARK: - 错误定义

public enum EvaluateError: Error, LocalizedError {
    case typeMismatch(String)
    case divisionByZero
    case variableNotFound(String)
    case invalidOperation(String)

    public var errorDescription: String? {
        switch self {
        case .typeMismatch(let msg): return "类型不匹配: \(msg)"
        case .divisionByZero: return "除零错误"
        case .variableNotFound(let name): return "变量未找到: \(name)"
        case .invalidOperation(let msg): return "无效操作: \(msg)"
        }
    }
}
