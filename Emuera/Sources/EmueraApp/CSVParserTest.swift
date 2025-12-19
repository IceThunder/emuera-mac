//
//  CSVParserTest.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/20.
//

import Foundation
import EmueraCore

/// CSVParser测试类
public final class CSVParserTest {

    private let parser: CSVParser

    public init() {
        self.parser = CSVParser()
    }

    /// 运行所有CSV测试
    public func runAllTests() {
        print("\n=== CSVParser 测试套件 ===")
        print()

        testBasicCSV()
        testQuotedFields()
        testEmptyValues()
        testNumericConversion()
        testColumnMapping()
        testSaveAndLoad()
        testEncodingSupport()

        print("\n=== 所有CSV测试完成 ===")
    }

    /// 测试基础CSV解析
    private func testBasicCSV() {
        print("--- Test 1: 基础CSV解析 ---")

        let csvContent = "Name,Age,Score\nAlice,25,95\nBob,30,88\nCharlie,22,92"

        do {
            // 默认不跳过标题，第一行作为数据
            let data = try parser.parseCSV(content: csvContent)
            print("✓ 解析成功")
            print("  - 行数: \(data.rowCount)")
            print("  - 列数: \(data.columnCount)")
            print("  - 列名: \(data.columnNames ?? [])")

            // 验证数据（默认不跳过标题，所以所有4行都是数据）
            assert(data.rowCount == 4, "应该有4行数据")
            assert(data.columnCount == 3, "应该有3列")
            assert(data.columnNames == nil, "没有列名")

            // 验证第一行数据
            let firstRow = data.rows[0]
            assert(firstRow.getField(0) == "Name", "第一行第一列应该是Name")
            assert(firstRow.getField(1) == "Age", "第一行第二列应该是Age")
            assert(firstRow.getField(2) == "Score", "第一行第三列应该是Score")

            print("✓ Test 1 PASSED")
        } catch {
            print("✗ Test 1 FAILED: \(error)")
        }
    }

    /// 测试带引号的字段
    private func testQuotedFields() {
        print("\n--- Test 2: 带引号的字段 ---")

        // Test case: header row + data row with quoted fields
        let simpleContent = "Header1,Header2\n\"X,Y\",\"Z\""

        do {
            var options = CSVParser.LoadOptions()
            options.skipHeader = true
            let simpleData = try parser.parseCSV(content: simpleContent, options: options)
            print("  Parsed rows: \(simpleData.rows.map { $0.fields })")
            print("  Column names: \(simpleData.columnNames ?? [])")

            if simpleData.rows.count > 0 {
                let r0c0 = simpleData.rows[0].getField(0)
                let r0c1 = simpleData.rows[0].getField(1)
                print("  Row 0: [\"\(r0c0)\", \"\(r0c1)\"]")

                if r0c0 == "X,Y" && r0c1 == "Z" {
                    print("✓ Quoted fields test PASSED")
                } else {
                    print("✗ Quoted fields test FAILED - expected [\"X,Y\", \"Z\"], got [\"\(r0c0)\", \"\(r0c1)\"]")
                    return
                }
            } else {
                print("✗ No rows parsed")
                return
            }

            print("✓ Test 2 PASSED")
        } catch {
            print("✗ Test 2 FAILED: \(error)")
        }
    }

    /// 测试空值处理
    private func testEmptyValues() {
        print("\n--- Test 3: 空值处理 ---")

        let csvContent = "A,B,C\n1,2,3\n4,,6\n7,8,"

        do {
            // 测试 emptyToNil = false
            var options = CSVParser.LoadOptions()
            options.emptyToNil = false
            let data1 = try parser.parseCSV(content: csvContent, options: options)

            // Row 0: "A,B,C"
            // Row 1: "1,2,3"
            // Row 2: "4,,6"  -> getField(1) should be ""
            // Row 3: "7,8,"  -> getField(2) should be ""
            assert(data1.rows[2].getField(1) == "", "中间空字段应该是空字符串")
            assert(data1.rows[3].getField(2) == "", "末尾空字段应该是空字符串")

            // 测试 emptyToNil = true
            options.emptyToNil = true
            let data2 = try parser.parseCSV(content: csvContent, options: options)

            assert(data2.rows[2].fields[1] == nil, "中间空字段应该是nil")
            assert(data2.rows[3].fields[2] == nil, "末尾空字段应该是nil")

            print("✓ Test 3 PASSED")
        } catch {
            print("✗ Test 3 FAILED: \(error)")
        }
    }

    /// 测试数值转换
    private func testNumericConversion() {
        print("\n--- Test 4: 数值转换 ---")

        let csvContent = "ID,Value\n1,100\n2,200\n3,300"

        do {
            var options = CSVParser.LoadOptions()
            options.skipHeader = true

            // 测试字符串数组
            let strArray = try parser.loadCSVToStringArray(from: createTempFile(content: csvContent), options: options)
            assert(strArray.count == 3, "应该有3行数据")
            assert(strArray[0][0] == "1", "第一行第一列应该是1")
            assert(strArray[0][1] == "100", "第一行第二列应该是100")

            // 测试整数数组
            let intArray = try parser.loadCSVToIntArray(from: createTempFile(content: csvContent), options: options)
            assert(intArray[0][0] == 1, "应该正确转换为整数")
            assert(intArray[0][1] == 100, "应该正确转换为整数")

            print("✓ Test 4 PASSED")
        } catch {
            print("✗ Test 4 FAILED: \(error)")
        }
    }

    /// 测试列映射
    private func testColumnMapping() {
        print("\n--- Test 5: 列映射 ---")

        let csvContent = "ID,Name,Age,Score\n1,Alice,25,95\n2,Bob,30,88\n3,Charlie,22,92"

        do {
            let tempFile = createTempFile(content: csvContent)

            // 测试加载指定列（跳过标题）
            var options = CSVParser.LoadOptions()
            options.skipHeader = true
            let ages = try parser.loadCSVColumn(from: tempFile, columnIndex: 2, options: options)
            assert(ages.count == 3, "应该有3个年龄值")
            assert(ages[0] == "25", "第一个年龄应该是25")

            // 测试列名映射
            let mappings = ["Name": "names", "Score": "scores"]
            let mapped = try parser.loadCSVWithMapping(from: tempFile, mappings: mappings, options: options)

            assert(mapped["names"]?.count == 3, "应该映射3个名字")
            assert(mapped["names"]?[0] == "Alice", "第一个名字应该是Alice")
            assert(mapped["scores"]?[1] == "88", "第二个分数应该是88")

            print("✓ Test 5 PASSED")
        } catch {
            print("✗ Test 5 FAILED: \(error)")
        }
    }

    /// 测试保存和加载
    private func testSaveAndLoad() {
        print("\n--- Test 6: 保存和加载 ---")

        let testData: [[String]] = [
            ["Name", "Age", "Score"],
            ["Alice", "25", "95"],
            ["Bob", "30", "88"]
        ]

        do {
            let tempFile = createTempFilePath()

            // 保存
            try parser.saveCSV(testData, to: tempFile)

            // 加载（不跳过标题）
            let loaded = try parser.loadCSV(from: tempFile)

            assert(loaded.rowCount == 3, "应该有3行数据（包括标题）")
            assert(loaded.columnNames == nil, "没有列名（不跳过标题）")

            // 验证数据
            assert(loaded.rows[0].getField(0) == "Name", "第一行应该是标题")
            assert(loaded.rows[1].getField(0) == "Alice", "第二行应该是数据")
            assert(loaded.rows[2].getField(1) == "30", "第三行数据应该正确")

            // 测试跳过标题
            var options = CSVParser.LoadOptions()
            options.skipHeader = true
            let loadedSkip = try parser.loadCSV(from: tempFile, options: options)
            assert(loadedSkip.rowCount == 2, "跳过标题后应该有2行数据")
            assert(loadedSkip.columnNames == ["Name", "Age", "Score"], "列名应该匹配")

            // 清理
            try? FileManager.default.removeItem(atPath: tempFile)

            print("✓ Test 6 PASSED")
        } catch {
            print("✗ Test 6 FAILED: \(error)")
        }
    }

    /// 测试编码支持
    private func testEncodingSupport() {
        print("\n--- Test 7: 编码支持 ---")

        let csvContent = "ID,Name\n1,测试\n2,数据"

        do {
            // UTF-8
            var options = CSVParser.LoadOptions()
            options.skipHeader = true
            let tempFileUTF8 = createTempFile(content: csvContent, encoding: .utf8)
            let dataUTF8 = try parser.loadCSV(from: tempFileUTF8, options: options)
            assert(dataUTF8.rows[0].getField(1) == "测试", "UTF-8编码应该正确")

            // Shift-JIS (如果系统支持)
            if let sjisData = csvContent.data(using: .shiftJIS) {
                let tempFileSJIS = createTempFilePath()
                try sjisData.write(to: URL(fileURLWithPath: tempFileSJIS))

                options.encoding = .shiftJIS
                let dataSJIS = try parser.loadCSV(from: tempFileSJIS, options: options)
                assert(dataSJIS.rows[0].getField(1) == "测试", "Shift-JIS编码应该正确")

                try? FileManager.default.removeItem(atPath: tempFileSJIS)
            }

            try? FileManager.default.removeItem(atPath: tempFileUTF8)

            print("✓ Test 7 PASSED")
        } catch {
            print("✗ Test 7 FAILED: \(error)")
        }
    }

    // MARK: - 辅助方法

    private func createTempFile(content: String, encoding: String.Encoding = .utf8) -> String {
        let tempFile = createTempFilePath()
        do {
            try content.write(toFile: tempFile, atomically: true, encoding: encoding)
        } catch {
            print("Failed to create temp file: \(error)")
        }
        return tempFile
    }

    private func createTempFilePath() -> String {
        let tempDir = NSTemporaryDirectory()
        return (tempDir as NSString).appendingPathComponent("test_\(UUID().uuidString).csv")
    }
}
