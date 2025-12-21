import Foundation
import EmueraCore

print("=== 新增内置函数测试 ===")
print("测试所有Phase 2新增的内置函数\n")

let parser = ScriptParser()
let executor = StatementExecutor()

// 辅助函数：字符串重复
func repeatString(_ str: String, count: Int) -> String {
    return String(repeating: str, count: count)
}

// 测试数学函数
print("1. 数学函数测试")
print(repeatString("-", count: 50))

let mathTests: [(String, String, [String])] = [
    ("ASIN", "PRINT ASIN(1000)", ["90"]),  // sin(90) = 1, ASIN(1000) = 90
    ("ACOS", "PRINT ACOS(0)", ["90"]),     // cos(90) = 0, ACOS(0) = 90
    ("ATAN", "PRINT ATAN(1000)", ["45"]),  // tan(45) = 1, ATAN(1000) = 45
    ("CBRT", "PRINT CBRT(27)", ["3"]),     // 立方根
    ("SIGN", "PRINT SIGN(10), SIGN(-5), SIGN(0)", ["1 -1 0"]),  // PRINT joins with spaces
    ("POWER", "PRINT POWER(2, 3)", ["8"]),
    ("LIMIT", "PRINT LIMIT(5, 1, 3)", ["3"]),
    ("SUM", "PRINT SUM(1, 2, 3, 4)", ["10"]),
]

for (name, script, expected) in mathTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 测试字符串函数
print("\n2. 字符串函数测试")
print(repeatString("-", count: 50))

let stringTests: [(String, String, [String])] = [
    ("STRLENFORM", "PRINT STRLENFORM(\"Hello\")", ["5"]),
    ("SUBSTRINGU", "PRINT SUBSTRINGU(\"测试\", 0, 1)", ["测"]),
    ("STRFIND", "PRINT STRFIND(\"Hello World\", \"World\")", ["6"]),
    ("STRCOUNT", "PRINT STRCOUNT(\"ababab\", \"ab\")", ["3"]),
    ("ESCAPE", "PRINT ESCAPE(\"Test\\nLine\")", ["Test\\nLine"]),
    ("UPPER", "PRINT UPPER(\"hello\")", ["HELLO"]),
    ("LOWER", "PRINT LOWER(\"HELLO\")", ["hello"]),
    ("TRIM", "PRINT TRIM(\"  test  \")", ["test"]),
    ("UNICODE", "PRINT UNICODE(65)", ["A"]),
    ("ENCODETOUNI", "PRINT ENCODETOUNI(\"A\")", ["0041"]),
]

for (name, script, expected) in stringTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 测试数组函数
print("\n3. 数组函数测试")
print(repeatString("-", count: 50))

let arrayTests: [(String, String, [String])] = [
    // 使用REPEAT创建数组进行测试（数组字面量语法尚未实现）
    ("VARSIZE", "A = REPEAT(5, 3)\nPRINT VARSIZE(A)", ["3"]),
    ("FINDELEMENT", "A = REPEAT(20, 3)\nPRINT FINDELEMENT(A, 20)", ["0"]),
    ("FINDLAST", "A = REPEAT(10, 4)\nPRINT FINDLAST(A, 10)", ["3"]),
    ("REPEAT", "A = REPEAT(3, 5)\nPRINT VARSIZE(A)", ["5"]),
    ("ARRAYMULTISORT", "A = REPEAT(3, 3)\nB = ARRAYMULTISORT(A)\nPRINT B:0, B:1, B:2", ["3 3 3"]),  // REPEAT creates same values
    ("INRANGE", "PRINT INRANGE(5, 1, 10), INRANGE(15, 1, 10)", ["1 0"]),  // Space joined
    ("INRANGEARRAY", "A = REPEAT(3, 3)\nPRINT INRANGEARRAY(A, 1, 5)", ["1"]),
]

for (name, script, expected) in arrayTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 测试位运算函数
print("\n4. 位运算函数测试")
print(repeatString("-", count: 50))

let bitTests: [(String, String, [String])] = [
    ("GETBIT", "PRINT GETBIT(5, 0), GETBIT(5, 1)", ["1 0"]),
    ("SETBIT", "PRINT SETBIT(4, 0)", ["5"]),
    ("CLEARBIT", "PRINT CLEARBIT(5, 0)", ["4"]),
    ("INVERTBIT", "PRINT INVERTBIT(5, 1)", ["7"]),
    ("SUMARRAYS", "A = REPEAT(1, 2)\nB = REPEAT(3, 2)\nPRINT SUMARRAYS(A, B)", ["8"]),
    ("GETNUM", "PRINT GETNUM(255, 0, 4), GETNUM(255, 4, 4)", ["15 15"]),
    ("GETNUMB", "PRINT GETNUMB(0x123456, 0), GETNUMB(0x123456, 1)", ["86 52"]),
]

for (name, script, expected) in bitTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 测试系统函数
print("\n5. 系统函数测试")
print(repeatString("-", count: 50))

let systemTests: [(String, String, [String])] = [
    ("CHECKFONT", "PRINT CHECKFONT(\"Arial\")", ["1"]),
    ("CHECKDATA", "PRINT CHECKDATA(\"test.dat\")", ["1"]),
    ("ISSKIP", "PRINT ISSKIP()", ["0"]),
    ("GETCOLOR", "PRINT GETCOLOR()", ["0"]),
    ("BARSTRING", "PRINT BARSTRING(5, 10, 5)", ["[**...]"]),
    ("RESULT", "A = 42\nPRINT RESULT()", ["42"]),
    ("RESULTS", "A = \"Hello\"\nPRINT RESULTS()", ["Hello"]),
    ("__INT_MAX__", "PRINT __INT_MAX__", [String(Int64.max)]),
    ("__INT_MIN__", "PRINT __INT_MIN__", [String(Int64.min)]),
]

for (name, script, expected) in systemTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 测试特殊数学函数
print("\n6. 特殊数学函数测试")
print(repeatString("-", count: 50))

let specialTests: [(String, String, [String])] = [
    ("GETPALLV", "PRINT GETPALLV(100)", ["100"]),
    ("GETEXPLV", "PRINT GETEXPLV(50)", ["50"]),
    ("MATCH", "A = 10\nPRINT MATCH(A, 10), MATCH(A, 20)", ["1 0"]),
    ("GROUPMATCH", "A = 5\nPRINT GROUPMATCH(A, 1, 5, 10), GROUPMATCH(A, 1, 2, 3)", ["1 0"]),
    ("NOSAMES", "PRINT NOSAMES(1, 2, 3), NOSAMES(1, 2, 1)", ["1 0"]),
    ("ALLSAMES", "PRINT ALLSAMES(5, 5, 5), ALLSAMES(5, 5, 6)", ["1 0"]),
]

for (name, script, expected) in specialTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 测试日期时间函数
print("\n7. 日期时间函数测试")
print(repeatString("-", count: 50))

let timeTests: [(String, String, [String])] = [
    ("YEAR", "PRINT YEAR() > 2024", ["1"]),  // 当前年份大于2024
    ("MONTH", "PRINT MONTH() >= 1 && MONTH() <= 12", ["1"]),
    ("DAY", "PRINT DAY() >= 1 && DAY() <= 31", ["1"]),
    ("HOUR", "PRINT HOUR() >= 0 && HOUR() <= 23", ["1"]),
    ("MINUTE", "PRINT MINUTE() >= 0 && MINUTE() <= 59", ["1"]),
    ("SECOND", "PRINT SECOND() >= 0 && SECOND() <= 59", ["1"]),
    ("TIME", "PRINT TIME() >= 0", ["1"]),
    ("GETTIME", "PRINT GETTIME() > 0", ["1"]),
]

for (name, script, expected) in timeTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 测试类型转换函数
print("\n8. 类型转换函数测试")
print(repeatString("-", count: 50))

let conversionTests: [(String, String, [String])] = [
    ("TO_STRING", "PRINT TO_STRING(123)", ["123"]),
    ("TO_INTEGER", "PRINT TO_INTEGER(\"456\")", ["456"]),
    ("ISNUMERIC", "PRINT ISNUMERIC(123), ISNUMERIC(\"abc\")", ["1 0"]),
    ("ISNULL", "PRINT ISNULL(0), ISNULL(NULL)", ["0 1"]),  // ISNULL(0)=0, ISNULL(NULL)=1
    ("TYPEOF", "A = 10\nB = \"test\"\nPRINT TYPEOF(A), TYPEOF(B)", ["INTEGER STRING"]),
]

for (name, script, expected) in conversionTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

// 测试复杂组合
print("\n9. 复杂组合测试")
print(repeatString("-", count: 50))

let complexTests: [(String, String, [String])] = [
    ("嵌套函数", "PRINT LIMIT(SUM(1, 2, 3), 0, 5)", ["5"]),
    ("数组与数学", "A = REPEAT(5, 10)\nPRINT VARSIZE(A) * 2", ["20"]),
    ("字符串与查找", "S = \"Hello World\"\nPRINT STRLENS(S) - STRFIND(S, \"World\")", ["5"]),
    ("位运算组合", "PRINT GETNUM(SETBIT(0, 3), 3, 1)", ["1"]),
]

for (name, script, expected) in complexTests {
    print("测试 \(name): \(script)")
    do {
        let output = executor.execute(try parser.parse(script))
        let passed = output.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } == expected
        print(passed ? "✅ 通过" : "❌ 失败 - 期望: \(expected), 实际: \(output)")
    } catch {
        print("❌ 错误: \(error)")
    }
}

print("\n" + repeatString("=", count: 50))
print("所有新增函数测试完成！")
print(repeatString("=", count: 50))
