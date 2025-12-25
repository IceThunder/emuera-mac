import Foundation
import EmueraCore

print("=== BAR命令参数解析测试 ===\n")

let parser = ScriptParser()

// 测试BAR命令
let testCases = [
    "BAR 50 100 20",
    "BAR 50, 100, 20",
    "DRAWSPRITE character.png, 10, 20",
    "DRAWSPRITE character.png 10 20"
]

for (i, script) in testCases.enumerated() {
    print("测试 \(i+1): \(script)")
    do {
        let statements = try parser.parse(script)
        print("  语句数: \(statements.count)")
        for (j, stmt) in statements.enumerated() {
            if let cmdStmt = stmt as? CommandStatement {
                print("    [\(j)]: CommandStatement - \(cmdStmt.command)")
                print("        参数: \(cmdStmt.arguments.count)个")
                for (k, arg) in cmdStmt.arguments.enumerated() {
                    print("          [\(k)]: \(arg)")
                }
            } else {
                print("    [\(j)]: \(type(of: stmt))")
            }
        }
    } catch {
        print("  ✗ 错误: \(error)")
    }
    print()
}

print("=== 测试完成 ===")
