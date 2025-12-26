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
    case PRINTCR        // 输出右对齐
    case PRINTFORM      // 格式化输出
    case PRINTFORML     // 格式化输出并换行
    case PRINTFORMW     // 格式化输出并等待
    case PRINTV         // 输出变量内容
    case PRINTVL        // 变量内容换行
    case PRINTVW        // 变量内容等待
    case PRINTS         // 输出字符串变量
    case PRINTSL        // 字符串变量换行
    case PRINTSW        // 字符串变量等待
    case PRINTFORMS     // 格式化字符串输出
    case PRINTFORMSL    // 格式化字符串输出换行
    case PRINTFORMSW    // 格式化字符串输出等待
    case PRINTFORMC     // 格式化居中输出
    case PRINTFORMLC    // 格式化左对齐输出
    case PRINTFORMCR    // 格式化右对齐输出

    // MARK: - D系列输出命令 (不解析{}和%)
    case PRINTD         // 输出不换行 (不解析)
    case PRINTDL        // 输出并换行 (不解析)
    case PRINTDW        // 输出并等待输入 (不解析)
    case PRINTVD        // 输出变量内容 (不解析)
    case PRINTVDL       // 变量内容换行 (不解析)
    case PRINTVDW       // 变量内容等待 (不解析)
    case PRINTSD        // 输出字符串变量 (不解析)
    case PRINTSDL       // 字符串变量换行 (不解析)
    case PRINTSDW       // 字符串变量等待 (不解析)
    case PRINTFORMD     // 格式化输出 (不解析)
    case PRINTFORMDL    // 格式化输出换行 (不解析)
    case PRINTFORMDW    // 格式化输出等待 (不解析)
    case PRINTFORMSD    // D格式化字符串输出
    case PRINTFORMSDL   // D格式化字符串输出换行
    case PRINTFORMSDW   // D格式化字符串输出等待
    case PRINTCD        // D居中输出
    case PRINTLCD       // D左对齐输出
    case PRINTFORMCD    // D格式化居中输出
    case PRINTFORMLCD   // D格式化左对齐输出

    case INPUT          // 整数输入
    case INPUTS         // 字符串输入
    case TINPUT         // 带超时输入
    case TINPUTS        // 带超时字符串输入
    case WAIT           // 等待输入
    case WAITANYKEY     // 等待任意键
    case ONEINPUT       // 单键输入
    case ONEINPUTS      // 单键字符串输入
    case TONEINPUT      // 带超时单键输入
    case TONEINPUTS     // 带超时单键字符串输入
    case AWAIT          // 等待（输入不可用）

    case CLEARLINE      // 清除行
    case REUSELASTLINE  // 重用最后一行

    // MARK: - 条件输出命令
    case SIF            // 单行条件输出

    // MARK: - 流程控制命令
    case CALL           // 函数调用
    case JUMP           // 函数跳转
    case GOTO           // 标签跳转
    case CALLFORM       // 格式化函数调用
    case JUMPFORM       // 格式化跳转
    case GOTOFORM       // 格式化标签跳转
    case CALLEVENT      // 事件调用
    case RETURN         // 返回
    case RETURNFORM     // 格式化返回
    case RETURNF        // 函数返回
    case RESTART        // 重启函数
    case DOTRAIN        // 训练开始
    case DO             // DO循环开始
    case LOOP           // DO循环结束
    case WHILE          // WHILE循环开始
    case WEND           // WHILE循环结束
    case FOR            // FOR循环开始
    case NEXT           // FOR循环结束
    case REPEAT         // REPEAT循环开始
    case REND           // REPEAT循环结束
    case CONTINUE       // 继续循环
    case BREAK          // 跳出循环
    case TRYCALL        // 尝试调用
    case TRYJUMP        // 尝试跳转
    case TRYGOTO        // 尝试GOTO
    case TRYCALLFORM    // 尝试格式化调用
    case TRYJUMPFORM    // 尝试格式化跳转
    case TRYGOTOFORM    // 尝试格式化GOTO
    case CATCH          // 捕获异常
    case ENDCATCH       // 结束捕获
    case TRYCCALL       // 带捕获调用
    case TRYCJUMP       // 带捕获跳转
    case TRYCGOTO       // 带捕获GOTO
    case TRYCCALLFORM   // 带捕获格式化调用
    case TRYCJUMPFORM   // 带捕获格式化跳转
    case TRYCGOTOFORM   // 带捕获格式化GOTO
    case TRYCALLLIST    // 尝试调用列表
    case TRYJUMPLIST    // 尝试跳转列表
    case TRYGOTOLIST    // 尝试GOTO列表
    // SELECTCASE, CASE, CASEELSE, ENDSELECT - handled as keywords, not commands
    case IF            // 条件开始
    case ELSEIF        // 否则如果
    case ELSE          // 否则
    case ENDIF         // 结束条件

    // MARK: - 变量操作
    case SET            // 变量赋值
    case VARSET         // 批量初始化
    case VARSIZE        // 数组大小
    case SWAP           // 变量交换
    case REF            // 引用
    case REFBYNAME      // 按名称引用

    // MARK: - 数据操作
    case ADDCHARA       // 添加角色
    case ADDDEFCHARA    // 添加默认角色
    case ADDSPCHARA     // 添加特殊角色
    case ADDVOIDCHARA   // 添加空角色
    case ADDCOPYCHARA   // 添加复制角色
    case DELCHARA       // 删除角色
    case DELALLCHARA    // 删除所有角色
    case SWAPCHARA      // 交换角色
    case COPYCHARA      // 复制角色
    case SORTCHARA      // 角色排序
    case PICKUPCHARA    // 挑选角色
    case FINDCHARA      // 查找角色
    case CHARAOPERATE   // 角色操作
    case CHARAMODIFY    // 批量修改
    case CHARAFILTER    // 角色过滤

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
    case STRLENFORM     // 格式化字符串长度
    case STRLENU        // Unicode字符串长度
    case STRLENFORMU    // 格式化Unicode长度
    case SPLIT          // 字符串分割
    case ENCODETOUNI    // 编码转换

    // MARK: - 文件操作
    case SAVEGAME       // 保存游戏
    case LOADGAME       // 加载游戏
    case SAVEVAR        // 保存变量
    case LOADVAR        // 加载变量
    case SAVECHARA      // 保存角色
    case LOADCHARA      // 加载角色
    case SAVEDATA       // 保存数据
    case LOADDATA       // 加载数据
    case DELDATA        // 删除数据
    case SAVEGLOBAL     // 保存全局
    case LOADGLOBAL     // 加载全局
    case SAVENOS        // 保存编号

    // MARK: - 系统命令
    case QUIT           // 退出游戏
    case BEGIN          // 开始系统函数
    case RESETDATA      // 重置数据
    case RESETGLOBAL    // 重置全局
    case RESET_STAIN    // 重置污渍

    case REDRAW         // 重绘控制
    case SKIPDISP       // 跳过显示
    case NOSKIP         // 禁止跳过
    case ENDNOSKIP      // 结束禁止跳过
    case OUTPUTLOG      // 输出日志
    case FORCEWAIT      // 强制等待
    case TWAIT          // 定时等待

    // MARK: - 绘图命令 (Priority 2)
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
    case FONTSTYLE      // 字体样式
    case SETFONT        // 设置字体

    // MARK: - 高级图形绘制 (Priority 4)
    case DRAWSPRITE     // 绘制精灵/图片
    case DRAWRECT       // 绘制矩形
    case FILLRECT       // 填充矩形
    case DRAWCIRCLE     // 绘制圆形
    case FILLCIRCLE     // 填充圆形
    case DRAWLINEEX     // 高级线条绘制
    case DRAWGRADIENT   // 渐变填充
    case SETBRUSH       // 设置画笔
    case CLEARSCREEN    // 清屏
    case SETBACKGROUNDCOLOR // 设置背景颜色

    // MARK: - 特殊命令
    case PERSIST        // 持久化开关
    case RESET          // 重置变量
    case RANDOMIZE      // 随机种子
    case DUMPRAND       // 转储随机状态
    case INITRAND       // 初始化随机
    case PUTFORM        // 保存格式化信息

    // MARK: - 调试命令
    case DEBUGPRINT     // 调试输出
    case DEBUGPRINTL    // 调试输出换行
    case DEBUGPRINTFORM // 调试格式化输出
    case DEBUGPRINTFORML // 调试格式化换行
    case DEBUGCLEAR     // 调试清空
    case ASSERT         // 断言
    case THROW          // 抛出异常
    case CVARSET        // 变量批量设置

    // MARK: - 其他
    case TIMES          // 小数计算
    case POWER          // 幂运算
    case GETTIME        // 获取时间
    case GETTIMES       // 获取时间戳
    case GETMILLISECOND // 获取毫秒
    case GETSECOND      // 获取秒

    // MARK: - 数据打印
    case PRINT_ABL      // 打印能力
    case PRINT_TALENT   // 打印素质
    case PRINT_MARK     // 打印刻印
    case PRINT_EXP      // 打印经验
    case PRINT_PALAM    // 打印参数
    case PRINT_ITEM     // 打印物品
    case PRINT_SHOPITEM // 打印商店物品

    // MARK: - 未分类
    case UPCHECK        // 参数检查
    case CUPCHECK       // 字符参数检查

    // MARK: - 事件相关
    case CALLTRAIN      // 调用训练
    case STOPCALLTRAIN  // 停止训练

    // MARK: - 函数定义
    case FUNC           // 函数开始
    case ENDFUNC        // 函数结束
    case CALLF          // 函数调用
    case CALLFORMF      // 格式化函数调用

    // MARK: - 数据块
    case PRINTDATA      // 数据块开始
    case PRINTDATAL     // 数据块开始（换行）
    case PRINTDATAW     // 数据块开始（等待）
    case PRINTDATAK     // 数据块开始（K模式）
    case PRINTDATAKL    // 数据块开始（K模式换行）
    case PRINTDATAKW    // 数据块开始（K模式等待）
    case PRINTDATAD     // 数据块开始（D模式）
    case PRINTDATADL    // 数据块开始（D模式换行）
    case PRINTDATADW    // 数据块开始（D模式等待）
    case DATALIST       // 数据列表
    case ENDLIST        // 结束列表
    case ENDDATA        // 结束数据
    case DATA           // 数据
    case DATAFORM       // 格式化数据
    case STRDATA        // 字符串数据

    // MARK: - HTML和工具提示
    case HTML_PRINT          // HTML打印
    case HTML_TAGSPLIT       // HTML标签分割
    case HTML_GETPRINTEDSTR  // 获取打印字符串
    case HTML_POPPRINTINGSTR // 弹出打印字符串
    case HTML_TOPLAINTEXT    // HTML转纯文本
    case HTML_ESCAPE         // HTML转义
    case TOOLTIP_SETCOLOR    // 工具提示颜色
    case TOOLTIP_SETDELAY    // 工具提示延迟
    case TOOLTIP_SETDURATION // 工具提示持续时间

    // MARK: - 鼠标和输入
    case INPUTMOUSEKEY  // 鼠标按键输入
    case FORCEKANA      // 强制假名

    // MARK: - 颜色扩展
    case SETCOLORBYNAME // 按名称设置颜色
    case SETBGCOLORBYNAME // 按名称设置背景颜色

    // MARK: - 对齐
    case ALIGNMENT      // 对齐方式

    // MARK: - 文本框
    case CLEARTEXTBOX   // 清空文本框

    // MARK: - 随机
    case RANDOM         // 随机数（函数形式）

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

    // MARK: - Phase 6: 角色显示命令
    case SHOWCHARACARD  // 显示角色卡片
    case SHOWCHARALIST  // 显示角色列表
    case SHOWBATTLESTATUS // 显示战斗状态
    case SHOWPROGRESSBARS // 显示进度条
    case SHOWCHARATAGS  // 显示角色标签

    // MARK: - Phase 6: 批量操作命令
    case BATCHMODIFY    // 批量修改
    case CHARACOUNT     // 角色数量
    case CHARAEXISTS    // 检查角色存在

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
    case PRINTSINGLEK   // K单行输出
    case PRINTSINGLEVK  // K单行变量输出
    case PRINTSINGLESK  // K单行字符串输出
    case PRINTSINGLEFORMK  // K单行格式化输出
    case PRINTSINGLEFORMSK // K单行格式化字符串输出
    case PRINTSINGLED   // D单行输出
    case PRINTSINGLEVD  // D单行变量输出
    case PRINTSINGLESD  // D单行字符串输出
    case PRINTSINGLEFORMD  // D单行格式化输出
    case PRINTSINGLEFORMSD // D单行格式化字符串输出

    // MARK: - 打印扩展命令
    case PRINT_IMG      // 打印图片
    case PRINT_RECT     // 打印矩形
    case PRINT_SPACE    // 打印空格
    case PRINTCPERLINE  // 每行字符数
    case PRINTCLENGTH   // 打印长度

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
        // 基础打印
        case .PRINT, .PRINTL, .PRINTW, .PRINTC, .PRINTLC, .PRINTCR,
             .PRINTFORM, .PRINTFORML, .PRINTFORMW,
             .PRINTV, .PRINTVL, .PRINTVW,
             .PRINTS, .PRINTSL, .PRINTSW,
             .PRINTFORMS, .PRINTFORMSL, .PRINTFORMSW,
             .PRINTFORMC, .PRINTFORMLC, .PRINTFORMCR,
             .PRINTPLAIN, .PRINTPLAINFORM,
             .PRINTSINGLE, .PRINTSINGLEV, .PRINTSINGLES,
             .PRINTSINGLEFORM, .PRINTSINGLEFORMS,
             .PRINTBUTTON, .PRINTBUTTONC, .PRINTBUTTONLC,
             .PRINT_IMG, .PRINT_RECT, .PRINT_SPACE,
             .PRINTCPERLINE, .PRINTCLENGTH,
             // K模式
             .PRINTK, .PRINTKL, .PRINTKW,
             .PRINTVK, .PRINTVKL, .PRINTVKW,
             .PRINTSK, .PRINTSKL, .PRINTSKW,
             .PRINTFORMK, .PRINTFORMKL, .PRINTFORMKW,
             .PRINTFORMSK, .PRINTFORMSKL, .PRINTFORMSKW,
             .PRINTCK, .PRINTLCK, .PRINTFORMCK, .PRINTFORMLCK,
             .PRINTSINGLEK, .PRINTSINGLEVK, .PRINTSINGLESK,
             .PRINTSINGLEFORMK, .PRINTSINGLEFORMSK,
             // D模式
             .PRINTD, .PRINTDL, .PRINTDW,
             .PRINTVD, .PRINTVDL, .PRINTVDW,
             .PRINTSD, .PRINTSDL, .PRINTSDW,
             .PRINTFORMD, .PRINTFORMDL, .PRINTFORMDW,
             .PRINTFORMSD, .PRINTFORMSDL, .PRINTFORMSDW,
             .PRINTCD, .PRINTLCD, .PRINTFORMCD, .PRINTFORMLCD,
             .PRINTSINGLED, .PRINTSINGLEVD, .PRINTSINGLESD,
             .PRINTSINGLEFORMD, .PRINTSINGLEFORMSD,
             // 数据块
             .PRINTDATA, .PRINTDATAL, .PRINTDATAW,
             .PRINTDATAK, .PRINTDATAKL, .PRINTDATAKW,
             .PRINTDATAD, .PRINTDATADL, .PRINTDATADW,
             .DATA, .DATAFORM, .STRDATA,
             // 数据打印
             .PRINT_ABL, .PRINT_TALENT, .PRINT_MARK, .PRINT_EXP, .PRINT_PALAM, .PRINT_ITEM, .PRINT_SHOPITEM,
             // 绘图
             .DRAWLINE, .CUSTOMDRAWLINE, .DRAWLINEFORM, .BAR, .BARL,
             .DRAWSPRITE, .DRAWRECT, .FILLRECT, .DRAWCIRCLE, .FILLCIRCLE, .DRAWLINEEX, .DRAWGRADIENT,
             // HTML
             .HTML_PRINT:
            return true
        default:
            return false
        }
    }

    /// 判断是否是输入类命令
    public var isInput: Bool {
        switch self {
        case .INPUT, .INPUTS, .TINPUT, .TINPUTS, .ONEINPUT, .ONEINPUTS, .WAIT, .WAITANYKEY, .TWAIT, .FORCEWAIT:
            return true
        default:
            return false
        }
    }

    /// 判断是否是流程控制命令
    public var isFlowControl: Bool {
        switch self {
        case .CALL, .JUMP, .GOTO, .CALLFORM, .JUMPFORM, .GOTOFORM, .CALLEVENT,
             .RETURN, .RETURNFORM, .RETURNF, .RESTART, .DOTRAIN,
             .DO, .LOOP, .WHILE, .WEND, .FOR, .NEXT, .REPEAT, .REND, .CONTINUE, .BREAK,
             .TRYCALL, .TRYJUMP, .TRYGOTO, .TRYCALLFORM, .TRYJUMPFORM, .TRYGOTOFORM,
             .CATCH, .ENDCATCH, .TRYCCALL, .TRYCJUMP, .TRYCGOTO, .TRYCCALLFORM, .TRYCJUMPFORM, .TRYCGOTOFORM,
             .TRYCALLLIST, .TRYJUMPLIST, .TRYGOTOLIST,
             .IF, .ELSEIF, .ELSE, .ENDIF:
            return true
        default:
            return false
        }
    }

    /// 判断是否是调试命令
    public var isDebug: Bool {
        switch self {
        case .DEBUGPRINT, .DEBUGPRINTL, .DEBUGPRINTFORM, .DEBUGPRINTFORML, .DEBUGCLEAR, .ASSERT, .THROW, .CVARSET:
            return true
        default:
            return false
        }
    }
}
