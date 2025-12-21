//
//  NoImportTest.swift
//  Phase2Test
//
//  测试不导入EmueraCore - 最小化测试
//

import Foundation

func debugPrint(_ message: String) {
    fputs(message + "\n", stderr)
    fflush(stderr)
}

@main
struct Main {
    static func main() {
        debugPrint("=== NoImportTest: 开始 ===")
        debugPrint("步骤1: 不导入EmueraCore，只使用Foundation")
        debugPrint("步骤2: 创建日期对象")
        let date = Date()
        debugPrint("步骤3: 日期创建完成: \(date)")
        debugPrint("步骤4: 测试完成 - SUCCESS")
        debugPrint("=== NoImportTest: 结束 ===")
    }
}
