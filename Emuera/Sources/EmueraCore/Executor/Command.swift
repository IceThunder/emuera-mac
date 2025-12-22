//
//  Command.swift
//  EmueraCore
//
//  命令枚举和定义 - 支持50+个Emuera命令
//  Created: 2025-12-19
//

import Foundation

/// Emuera命令类型
public enum CommandType: String, CaseIterable {
    // MARK: - I/O命令 (输入输出)
    case PRINT          // 输出不换行
    case PRINTL         // 输出并换行
    case PRINTW         // 输出并等待输入
    case PRINTC         // 输出居中
    case PRINTLC        // 输出左对齐
    case PRINTFORM      // 格式化输出
    case PRINTFORML     // 格式化输出并换行
    case PRINTFORMW     // 格式化输出并等待

    case INPUT          // 整数输入
    case INPUTS         // 字符串输入
    case TINPUT         // 带超时输入
    case TINPUTS        // 带超时字符串输入
    case WAIT           // 等待输入
    case WAITANYKEY     // 等待任意键
    case ONEINPUT       // 单键输入
    case ONEINPUTS      // 单键字符串输入

    case CLEARLINE      // 清除行
    case REUSELASTLINE  // 重用最后一行

    // MARK: - 流程控制 (注意: 这些在词法分析中被识别为关键字，不是命令)

    // MARK: - 变量操作
    case SET            // 变量赋值
    case VARSET         // 批量初始化

    // MARK: - 数据操作
    case ADDCHARA       // 添加角色
    case DELCHARA       // 删除角色
    case SWAPCHARA      // 交换角色
    case COPYCHARA      // 复制角色
    case SORTCHARA      // 角色排序

    case ADDVOIDCHARA   // 添加空角色
    case DELALLCHARA    // 删除所有角色

    // MARK: - 数组操作
    case ARRAYSHIFT     // 数组移位
    case ARRAYREMOVE    // 数组删除
    case ARRAYSORT      // 数组排序
    case ARRAYCOPY      // 数组复制

    // MARK: - 位运算
    case SETBIT         // 设置位
    case CLEARBIT       // 清除位
    case INVERTBIT      // 反转位

    // MARK: - 字符串操作
    case STRLEN         // 字符串长度
    case SPLIT          // 字符串分割

    // MARK: - 文件操作
    case SAVEGAME       // 保存游戏
    case LOADGAME       // 加载游戏
    case SAVEVAR        // 保存变量
    case LOADVAR        // 加载变量
    case SAVECHARA      // 保存角色
    case LOADCHARA      // 加载角色

    // MARK: - 系统命令
    case QUIT           // 退出游戏
    case BEGIN          // 开始系统函数
    case RESETDATA      // 重置数据
    case RESETGLOBAL    // 重置全局

    case REDRAW         // 重绘控制
    case SKIPDISP       // 跳过显示
    case NOSKIP         // 禁止跳过
    case ENDNOSKIP      // 结束禁止跳过

    // MARK: - 绘图命令
    case DRAWLINE       // 绘制线
    case CUSTOMDRAWLINE // 自定义线
    case DRAWLINEFORM   // 格式化线
    case BAR            // 条形图
    case BARL           // 条形图换行

    case SETCOLOR       // 设置颜色
    case RESETCOLOR     // 重置颜色
    case SETBGCOLOR     // 设置背景色
    case RESETBGCOLOR   // 重置背景色

    case FONTBOLD       // 粗体
    case FONTITALIC     // 斜体
    case FONTREGULAR    // 正常字体
    case SETFONT        // 设置字体

    // MARK: - 特殊命令
    case PERSIST        // 持久化开关
    case RESET          // 重置变量
    case RANDOMIZE      // 随机种子
    case DUMPRAND       // 转储随机状态
    case INITRAND       // 初始化随机

    // MARK: - 调试命令
    case DEBUGPRINT     // 调试输出
    case DEBUGPRINTL    // 调试输出换行
    case DEBUGCLEAR     // 调试清空
    case ASSERT         // 断言
    case THROW          // 抛出异常

    // MARK: - 其他
    case TIMES          // 小数计算
    case POWER          // 幂运算
    case GETTIME        // 获取时间

    // MARK: - 数据打印
    case PRINT_ABL      // 打印能力
    case PRINT_TALENT   // 打印素质
    case PRINT_MARK     // 打印刻印
    case PRINT_EXP      // 打印经验
    case PRINT_PALAM    // 打印参数
    case PRINT_ITEM     // 打印物品

    // MARK: - 未分类
    case UPCHECK        // 参数检查
    case CUPCHECK       // 字符参数检查

    // MARK: - 事件相关
    case CALLTRAIN      // 调用训练
    case STOPCALLTRAIN  // 停止训练

    // MARK: - 异常处理 (现在在关键字中处理，不是命令)
    // case CATCH       // 移到关键字 (Phase 3)
    // case ENDCATCH    // 移到关键字 (Phase 3)
    // TRY相关命令在关键字中处理

    // MARK: - 函数定义
    case FUNC           // 函数开始
    case ENDFUNC        // 函数结束
    case CALLF          // 函数调用
    case CALLFORMF      // 格式化函数调用

    // MARK: - 数据块
    // PRINTDATA, DATALIST, ENDLIST, ENDDATA 现在在关键字中处理 (Phase 3)
    case DATA           // 数据
    case DATAFORM       // 格式化数据
    case STRDATA        // 字符串数据

    // MARK: - 其他特殊
    case OUTPUTLOG      // 输出日志
    case SAVEDATA       // 保存数据
    case LOADDATA       // 加载数据
    case DELDATA        // 删除数据

    // MARK: - 颜色扩展
    case SETCOLORBYNAME // 按名称设置颜色

    // MARK: - 对齐
    case ALIGNMENT      // 对齐方式

    // MARK: - 文本框
    case CLEARTEXTBOX   // 清空文本框

    // MARK: - 随机
    case RANDOM         // 随机数（函数形式）

    // MARK: - 字符串格式化
    case PRINTFORMS     // 格式化字符串输出
    case PRINTFORMSL    // 格式化字符串输出换行
    case PRINTFORMSW    // 格式化字符串输出等待

    // MARK: - 按钮
    case PRINTBUTTON    // 按钮
    case PRINTBUTTONC   // 按钮居中
    case PRINTBUTTONLC  // 按钮左对齐

    // MARK: - 平面文本
    case PRINTPLAIN     // 平面文本
    case PRINTPLAINFORM // 格式化平面文本

    // MARK: - 单行输出
    case PRINTSINGLE    // 单行输出
    case PRINTSINGLEV   // 单行变量输出
    case PRINTSINGLES   // 单行字符串输出
    case PRINTSINGLEFORM // 单行格式化输出
    case PRINTSINGLEFORMS // 单行格式化字符串输出

    // MARK: - K系列（韩文扩展）
    case PRINTK         // K输出
    case PRINTKL        // K输出换行
    case PRINTKW        // K输出等待
    case PRINTVK        // K变量输出
    case PRINTVKL       // K变量输出换行
    case PRINTVKW       // K变量输出等待
    case PRINTSK        // K字符串输出
    case PRINTSKL       // K字符串输出换行
    case PRINTSKW       // K字符串输出等待
    case PRINTFORMK     // K格式化输出
    case PRINTFORMKL    // K格式化输出换行
    case PRINTFORMKW    // K格式化输出等待
    case PRINTFORMSK    // K格式化字符串输出
    case PRINTFORMSKL   // K格式化字符串输出换行
    case PRINTFORMSKW   // K格式化字符串输出等待
    case PRINTCK        // K居中输出
    case PRINTLCK       // K左对齐输出
    case PRINTFORMCK    // K格式化居中输出
    case PRINTFORMLCK   // K格式化左对齐输出

    // MARK: - 未知/通用
    case UNKNOWN        // 未知命令

    /// 从字符串创建命令类型（不区分大小写）
    public static func fromString(_ str: String) -> CommandType {
        let upper = str.uppercased()
        if let cmd = CommandType(rawValue: upper) {
            return cmd
        }
        return .UNKNOWN
    }

    /// 判断是否是打印类命令
    public var isPrint: Bool {
        switch self {
        case .PRINT, .PRINTL, .PRINTW, .PRINTC, .PRINTLC,
             .PRINTFORM, .PRINTFORML, .PRINTFORMW,
             .PRINTBUTTON, .PRINTBUTTONC, .PRINTBUTTONLC,
             .PRINTPLAIN, .PRINTPLAINFORM,
             .PRINTSINGLE, .PRINTSINGLEV, .PRINTSINGLES,
             .PRINTSINGLEFORM, .PRINTSINGLEFORMS,
             .PRINT_ABL, .PRINT_TALENT, .PRINT_MARK, .PRINT_EXP, .PRINT_PALAM, .PRINT_ITEM,
             .DRAWLINE, .CUSTOMDRAWLINE, .DRAWLINEFORM, .BAR, .BARL:
            return true
        default:
            return false
        }
    }

    /// 判断是否是输入类命令
    public var isInput: Bool {
        switch self {
        case .INPUT, .INPUTS, .TINPUT, .TINPUTS, .ONEINPUT, .ONEINPUTS, .WAIT, .WAITANYKEY:
            return true
        default:
            return false
        }
    }

    /// 判断是否是流程控制命令 (注意: 流程控制关键字现在是关键字类型，不是命令)
    public var isFlowControl: Bool {
        return false
    }

    /// 判断是否是调试命令
    public var isDebug: Bool {
        switch self {
        case .DEBUGPRINT, .DEBUGPRINTL, .DEBUGCLEAR, .ASSERT, .THROW:
            return true
        default:
            return false
        }
    }
}
