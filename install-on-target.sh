#!/bin/bash
# install-on-target.sh - 在目标 Mac 上一键安装（覆盖官方版本）

set -e

echo "📥 安装自定义 Qwen Code..."

# 检查是否提供了包文件
if [ $# -eq 0 ]; then
    echo "❌ 请提供 .tgz 包文件路径"
    echo "用法: ./install-on-target.sh qwen-code-qwen-code-0.13.0.tgz"
    exit 1
fi

PACKAGE_FILE="$1"

# 检查文件是否存在
if [ ! -f "$PACKAGE_FILE" ]; then
    echo "❌ 文件不存在: $PACKAGE_FILE"
    exit 1
fi

echo "📦 安装包: $PACKAGE_FILE"

# 卸载官方版本（如果存在）
echo "🗑️  卸载官方版本..."
npm uninstall -g @qwen-code/qwen-code 2>/dev/null || true

# 安装自定义版本
echo "🔧 安装自定义版本..."
npm install -g "$PACKAGE_FILE"

# 验证安装
echo ""
echo "✅ 安装完成！"
echo "版本信息:"
qwen --version

echo ""
echo "💡 如需卸载，运行: npm uninstall -g @qwen-code/qwen-code"