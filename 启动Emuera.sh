#!/bin/bash

# Emuera macOS 启动脚本
# 使用方法: ./启动Emuera.sh [命令] [参数]

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMUERA_DIR="$SCRIPT_DIR/Emuera"
EMUERA_BIN="$EMUERA_DIR/.build/release/emuera"
EMUERA_GUI_BIN="$EMUERA_DIR/.build/release/EmueraGUI"

# 检查可执行文件是否存在
if [ ! -f "$EMUERA_BIN" ]; then
    echo "❌ 错误: 未找到可执行文件 $EMUERA_BIN"
    echo "请先运行: cd Emuera && swift build -c release"
    exit 1
fi

# 检查GUI可执行文件是否存在
if [ ! -f "$EMUERA_GUI_BIN" ]; then
    echo "⚠️  警告: 未找到GUI可执行文件 $EMUERA_GUI_BIN"
    echo "GUI可能需要在Emuera目录中运行"
fi

# 显示帮助信息
show_help() {
    echo "========================================="
    echo "  Emuera macOS 启动脚本"
    echo "========================================="
    echo ""
    echo "用法: ./启动Emuera.sh [命令] [参数]"
    echo ""
    echo "可用命令:"
    echo "  (无参数)          - 启动交互式控制台"
    echo "  test              - 运行基础测试"
    echo "  demo              - 运行演示脚本"
    echo "  integrationtest   - 运行完整集成测试"
    echo "  uitest            - 运行UI集成测试"
    echo "  exprtest          - 表达式解析器测试"
    echo "  scripttest        - 语法解析器测试"
    echo "  processtest       - Process系统测试"
    echo "  run <file>        - 运行指定脚本文件"
    echo "  gui               - 启动GUI应用"
    echo "  help              - 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  ./启动Emuera.sh"
    echo "  ./启动Emuera.sh demo"
    echo "  ./启动Emuera.sh run /path/to/script.erb"
    echo "  ./启动Emuera.sh gui"
    echo ""
    echo "文件位置:"
    echo "  可执行文件: $EMUERA_BIN"
    echo "  GUI文件: $EMUERA_GUI_BIN"
    echo "  示例脚本: $SCRIPT_DIR/Examples/"
    echo ""
}

# 如果没有参数，启动交互式控制台
if [ $# -eq 0 ]; then
    echo "🚀 启动 Emuera 交互式控制台..."
    echo ""
    cd "$EMUERA_DIR"
    "$EMUERA_BIN"
    exit 0
fi

# 处理命令
COMMAND="$1"
shift

case "$COMMAND" in
    "help")
        show_help
        ;;
    "gui")
        echo "🚀 启动 Emuera GUI 应用..."
        if [ -f "$EMUERA_GUI_BIN" ]; then
            open "$EMUERA_GUI_BIN"
        else
            echo "⚠️  GUI应用需要在Emuera目录中运行:"
            echo "   cd $EMUERA_DIR"
            echo "   swift run EmueraGUI"
        fi
        ;;
    "run")
        if [ $# -eq 0 ]; then
            echo "❌ 错误: 请指定要运行的脚本文件"
            echo "用法: ./启动Emuera.sh run /path/to/script.erb"
            exit 1
        fi
        SCRIPT_FILE="$1"
        if [ ! -f "$SCRIPT_FILE" ]; then
            echo "❌ 错误: 找不到文件 $SCRIPT_FILE"
            exit 1
        fi
        echo "📄 运行脚本: $SCRIPT_FILE"
        cd "$EMUERA_DIR"
        # 使用交互模式运行脚本
        echo "run $SCRIPT_FILE" | "$EMUERA_BIN"
        ;;
    *)
        # 其他命令直接传递给emuera
        cd "$EMUERA_DIR"
        "$EMUERA_BIN" "$COMMAND" "$@"
        ;;
esac
