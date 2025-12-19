//
//  DefineMacro.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/19.
//

/// 定义宏，用于ERH头文件中的#define指令
public final class DefineMacro {
    /// 宏的关键字（名称）
    public let keyword: String

    /// 宏对应的词法单元集合
    public let statement: WordCollection

    /// 参数个数
    public let argCount: Int

    /// 是否有参数
    public let hasArguments: Bool

    /// 是否为空宏
    public let isNull: Bool

    /// 单词标识符（当语句只有一个单词时）
    public private(set) var idWord: IdentifierWord?

    public init(keyword: String, statement: WordCollection, argCount: Int) {
        self.keyword = keyword
        self.statement = statement
        self.argCount = argCount
        self.hasArguments = argCount != 0
        self.isNull = statement.collection.count == 0

        if statement.collection.count == 1, let first = statement.current as? IdentifierWord {
            self.idWord = first
        }

        // 重置指针
        statement.pointer = 0
    }
}
