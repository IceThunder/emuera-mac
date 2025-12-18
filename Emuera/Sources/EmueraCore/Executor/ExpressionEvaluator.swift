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

    public init(variableData: VariableData) {
        self.variableData = variableData
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

        case .binary(let op, let left, let right):
            return try evaluateBinary(op: op, left: left, right: right)
        }
    }

    // MARK: - 变量解析

    /// 解析变量引用
    private func resolveVariable(_ name: String) throws -> VariableValue {
        // 使用VariableData的API获取变量
        let value = variableData.getVariable(name)

        if value != .null {
            return value
        }

        // 如果不存在，尝试解析数组访问格式: A:0 或 ARRAY[0]
        if name.contains(":") || name.contains("[") {
            // 简单的数组访问支持
            if let colonIndex = name.firstIndex(of: ":") {
                let arrayName = String(name[..<colonIndex])
                let indexStr = String(name[name.index(after: colonIndex)...])
                if let index = Int(indexStr) {
                    let val = variableData.getArrayElement(arrayName, index: index)
                    return .integer(val)
                }
            }
        }

        // 变量不存在，返回0（Emuera行为）
        return .integer(0)
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
