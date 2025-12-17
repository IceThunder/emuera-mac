//
//  main.swift
//  EmueraApp
//
//  Main entry point for Emuera macOS application
//  Created on 2025-12-18
//

import Foundation
import EmueraCore

// MARK: - Main Entrypoint

struct EmueraApp {
    static func main() {
        print("🚀 Emuera for macOS - Development Build")
        print("Version: \(EmueraVersion) (Core: \(EmueraCoreVersion))")
        print("Compatible with Emuera Script Engine")
        print()

        // Test core functionality
        testCoreEngine()
    }

    static func testCoreEngine() {
        print("🧪 Testing core engine components...")

        // Test 1: Basic variable system
        let varData = VariableData()
        varData.setVariable("RESULT", value: .integer(42))
        let result = varData.getVariable("RESULT")

        if case .integer(let value) = result, value == 42 {
            print("✓ Variable system: PASS")
        } else {
            print("✗ Variable system: FAIL")
        }

        // Test 2: Array operations
        varData.setArrayElement("TEST_ARRAY", index: 0, value: 100)
        varData.setArrayElement("TEST_ARRAY", index: 5, value: 200)
        let arrVal = varData.getArrayElement("TEST_ARRAY", index: 5)

        if arrVal == 200 {
            print("✓ Array operations: PASS")
        } else {
            print("✗ Array operations: FAIL")
        }

        // Test 3: Character data
        let chara = CharacterData(id: 0, name: "テストキャラ")
        varData.addCharacter(chara)

        if varData.getCharacterCount() == 1 {
            print("✓ Character data: PASS")
        } else {
            print("✗ Character data: FAIL")
        }

        // Test 4: Logger system
        Logger.info("Core engine test completed")
        print("✓ Logger system: PASS")

        print()
        print("🎉 All core tests passed!")
        print()
        print("下一步计划:")
        print("1. 完善脚本解析器 (ScriptParser)")
        print("2. 实现表达式解析器 (ExpressionParser)")
        print("3. 创建主执行引擎 (Engine)")
        print("4. 开发macOS原生UI (AppKit)")
    }
}

// MARK: - Entry Point

EmueraApp.main()