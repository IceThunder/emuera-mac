//
//  FileServiceTest.swift
//  Emuera
//
//  Created by IceThunder on 2025/12/20.
//

import Foundation
import EmueraCore

/// FileService测试类
public final class FileServiceTest {

    private let fileService: FileService
    private var testDir: String

    public init() {
        self.fileService = FileService()
        self.testDir = ""
    }

    /// 运行所有FileService测试
    public func runAllTests() {
        print("\n=== FileService 测试套件 ===")
        print()

        do {
            // 创建测试目录
            try setupTestEnvironment()

            testBasicFileOperations()
            testDirectoryOperations()
            testFileAttributes()
            testFileOperations()
            testPathOperations()
            testBatchOperations()
            testFindFiles()
            testEncodingSupport()
            testBackupAndPermissions()

            // 清理
            cleanupTestEnvironment()

            print("\n=== 所有FileService测试完成 ===")
        } catch {
            print("✗ 测试环境设置失败: \(error)")
        }
    }

    private func setupTestEnvironment() throws {
        testDir = try fileService.createTempDirectory(prefix: "emuera_test_")
        print("测试目录: \(testDir)")
    }

    private func cleanupTestEnvironment() {
        do {
            try fileService.deleteDirectory(at: testDir)
            print("✓ 测试目录已清理")
        } catch {
            print("⚠ 清理测试目录失败: \(error)")
        }
    }

    // MARK: - 基础文件操作

    private func testBasicFileOperations() {
        print("\n--- Test 1: 基础文件操作 ---")

        do {
            let testFile = (testDir as NSString).appendingPathComponent("test.txt")
            let content = "Hello, FileService!\n这是测试内容\nLine 3"

            // 写入
            try fileService.writeText(content, to: testFile)
            print("✓ 写入文件成功")

            // 读取
            let readContent = try fileService.readText(from: testFile)
            assert(readContent == content, "内容应该相同")
            print("✓ 读取文件成功")

            // 追加
            try fileService.appendText("\nAppended line", to: testFile)
            let appended = try fileService.readText(from: testFile)
            assert(appended.contains("Appended line"), "应该包含追加内容")
            print("✓ 追加内容成功")

            // 检查存在
            assert(fileService.exists(at: testFile), "文件应该存在")
            assert(fileService.isFile(at: testFile), "应该是文件")
            print("✓ 文件存在性检查成功")

            print("✓ Test 1 PASSED")
        } catch {
            print("✗ Test 1 FAILED: \(error)")
        }
    }

    // MARK: - 目录操作

    private func testDirectoryOperations() {
        print("\n--- Test 2: 目录操作 ---")

        do {
            let subDir = (testDir as NSString).appendingPathComponent("subdir")
            try fileService.createDirectory(at: subDir)
            assert(fileService.isDirectory(at: subDir), "应该是目录")
            print("✓ 创建目录成功")

            // 在子目录中创建文件
            let nestedFile = (subDir as NSString).appendingPathComponent("nested.txt")
            try fileService.writeText("Nested content", to: nestedFile)
            print("✓ 在子目录创建文件成功")

            // 列出目录
            let contents = try fileService.listDirectory(at: testDir)
            assert(contents.contains("subdir"), "应该包含子目录")
            print("✓ 列出目录成功")

            // 递归列出
            let allContents = try fileService.listDirectoryRecursive(at: testDir)
            assert(allContents.count >= 2, "应该包含多个项目")
            print("✓ 递归列出目录成功")

            print("✓ Test 2 PASSED")
        } catch {
            print("✗ Test 2 FAILED: \(error)")
        }
    }

    // MARK: - 文件属性

    private func testFileAttributes() {
        print("\n--- Test 3: 文件属性 ---")

        do {
            let testFile = (testDir as NSString).appendingPathComponent("attr_test.txt")
            let content = "Test content for attributes"
            try fileService.writeText(content, to: testFile)

            // 文件大小
            let size = try fileService.fileSize(at: testFile)
            assert(size > 0, "文件大小应该大于0")
            assert(size == Int64(content.utf8.count), "大小应该匹配")
            print("✓ 文件大小检查成功")

            // 修改时间
            let modDate = try fileService.modificationDate(at: testFile)
            assert(modDate.timeIntervalSinceNow < 60, "修改时间应该是最近")
            print("✓ 修改时间检查成功")

            // 权限
            let perms = try fileService.getPermissions(path: testFile)
            assert(perms > 0, "应该有权限")
            print("✓ 权限检查成功")

            // 可读/可写检查
            assert(fileService.isReadable(at: testFile), "应该可读")
            assert(fileService.isWritable(at: testFile), "应该可写")
            print("✓ 读写权限检查成功")

            print("✓ Test 3 PASSED")
        } catch {
            print("✗ Test 3 FAILED: \(error)")
        }
    }

    // MARK: - 文件操作

    private func testFileOperations() {
        print("\n--- Test 4: 文件操作 ---")

        do {
            let source = (testDir as NSString).appendingPathComponent("source.txt")
            let dest = (testDir as NSString).appendingPathComponent("dest.txt")
            let moved = (testDir as NSString).appendingPathComponent("moved.txt")

            // 创建源文件
            try fileService.writeText("Source content", to: source)

            // 复制
            try fileService.copy(from: source, to: dest)
            assert(fileService.exists(at: dest), "复制文件应该存在")
            print("✓ 复制文件成功")

            // 移动
            try fileService.move(from: dest, to: moved)
            assert(!fileService.exists(at: dest), "原文件应该不存在")
            assert(fileService.exists(at: moved), "移动后文件应该存在")
            print("✓ 移动文件成功")

            // 删除
            try fileService.delete(at: moved)
            assert(!fileService.exists(at: moved), "删除后文件应该不存在")
            print("✓ 删除文件成功")

            print("✓ Test 4 PASSED")
        } catch {
            print("✗ Test 4 FAILED: \(error)")
        }
    }

    // MARK: - 路径操作

    private func testPathOperations() {
        print("\n--- Test 5: 路径操作 ---")

        let path1 = "/Users/test/file.txt"
        let _ = "relative/path/file.txt"  // Unused, kept for clarity

        // 标准化
        let normalized = fileService.normalizePath(path1)
        assert(normalized == "/Users/test/file.txt", "应该正确标准化")
        print("✓ 路径标准化成功")

        // 父目录
        let parent = fileService.parentDirectory(of: path1)
        assert(parent == "/Users/test", "父目录应该正确")
        print("✓ 获取父目录成功")

        // 文件名
        let filename = fileService.fileName(of: path1)
        assert(filename == "file.txt", "文件名应该正确")
        print("✓ 获取文件名成功")

        // 扩展名
        let ext = fileService.fileExtension(of: path1)
        assert(ext == "txt", "扩展名应该正确")
        print("✓ 获取扩展名成功")

        // 无扩展名
        let nameWithoutExt = fileService.fileNameWithoutExtension(of: path1)
        assert(nameWithoutExt == "file", "应该无扩展名")
        print("✓ 获取无扩展名文件名成功")

        // 组合路径
        let joined = fileService.joinPath("a", "b", "c")
        assert(joined == "a/b/c", "路径组合应该正确")
        print("✓ 路径组合成功")

        print("✓ Test 5 PASSED")
    }

    // MARK: - 批量操作

    private func testBatchOperations() {
        print("\n--- Test 6: 批量操作 ---")

        do {
            let files = [
                (testDir as NSString).appendingPathComponent("batch1.txt"): "Content 1",
                (testDir as NSString).appendingPathComponent("batch2.txt"): "Content 2",
                (testDir as NSString).appendingPathComponent("batch3.txt"): "Content 3"
            ]

            // 批量写入
            try fileService.writeMultipleText(files)
            print("✓ 批量写入成功")

            // 批量读取
            let readFiles = Array(files.keys)
            let contents = try fileService.readMultipleText(paths: readFiles)
            assert(contents.count == 3, "应该读取3个文件")
            assert(contents[files.keys.first!] == files.values.first!, "内容应该匹配")
            print("✓ 批量读取成功")

            print("✓ Test 6 PASSED")
        } catch {
            print("✗ Test 6 FAILED: \(error)")
        }
    }

    // MARK: - 查找文件

    private func testFindFiles() {
        print("\n--- Test 7: 查找文件 ---")

        do {
            // 使用子目录避免与其他测试冲突
            let findTestDir = (testDir as NSString).appendingPathComponent("findtest")
            try fileService.createDirectory(at: findTestDir)

            // 创建测试文件
            try fileService.writeText("test", to: (findTestDir as NSString).appendingPathComponent("file1.txt"))
            try fileService.writeText("test", to: (findTestDir as NSString).appendingPathComponent("file2.txt"))
            try fileService.writeText("test", to: (findTestDir as NSString).appendingPathComponent("data.csv"))
            try fileService.createDirectory(at: (findTestDir as NSString).appendingPathComponent("sub"))

            // 查找所有txt文件
            let txtFiles = try fileService.findFiles(in: findTestDir, pattern: "*.txt")
            assert(txtFiles.count == 2, "应该找到2个txt文件，实际找到 \(txtFiles.count)")
            print("✓ 通配符查找成功")

            // 查找所有文件（不带模式）
            let allFiles = try fileService.findFiles(in: findTestDir)
            assert(allFiles.count >= 3, "应该找到多个文件")
            print("✓ 查找所有文件成功")

            print("✓ Test 7 PASSED")
        } catch {
            print("✗ Test 7 FAILED: \(error)")
        }
    }

    // MARK: - 编码支持

    private func testEncodingSupport() {
        print("\n--- Test 8: 编码支持 ---")

        do {
            let testFile = (testDir as NSString).appendingPathComponent("encoding.txt")
            let content = "测试内容 - 中文测试\nTest content"

            // UTF-8
            var options = FileService.FileOptions()
            options.encoding = .utf8
            try fileService.writeText(content, to: testFile, options: options)
            let readBack = try fileService.readText(from: testFile, options: options)
            assert(readBack == content, "UTF-8编码应该正确")
            print("✓ UTF-8编码支持成功")

            // Shift-JIS（如果支持）
            if content.data(using: .shiftJIS) != nil {
                let sjisFile = (testDir as NSString).appendingPathComponent("sjis.txt")
                options.encoding = .shiftJIS
                try fileService.writeText(content, to: sjisFile, options: options)
                let readSJIS = try fileService.readText(from: sjisFile, options: options)
                assert(readSJIS == content, "Shift-JIS编码应该正确")
                print("✓ Shift-JIS编码支持成功")
            }

            print("✓ Test 8 PASSED")
        } catch {
            print("✗ Test 8 FAILED: \(error)")
        }
    }

    // MARK: - 备份和权限

    private func testBackupAndPermissions() {
        print("\n--- Test 9: 备份和权限 ---")

        do {
            let testFile = (testDir as NSString).appendingPathComponent("backup.txt")
            let backupFile = testFile + ".bak"

            // 创建初始文件
            try fileService.writeText("Original content", to: testFile)

            // 写入时备份
            var options = FileService.FileOptions()
            options.backupOriginal = true
            options.overwrite = true
            try fileService.writeText("New content", to: testFile, options: options)

            // 检查备份
            assert(fileService.exists(at: backupFile), "备份文件应该存在")
            let backupContent = try fileService.readText(from: backupFile)
            assert(backupContent == "Original content", "备份内容应该正确")
            print("✓ 备份功能成功")

            // 自定义权限
            options.filePermissions = 0o600  // 只有所有者可读写
            try fileService.writeText("Secure content", to: testFile, options: options)
            let perms = try fileService.getPermissions(path: testFile)
            assert(perms == 0o600, "权限应该正确设置")
            print("✓ 权限设置成功")

            print("✓ Test 9 PASSED")
        } catch {
            print("✗ Test 9 FAILED: \(error)")
        }
    }
}
