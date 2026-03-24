#!/bin/bash
# build-single-platform.sh - 为指定平台快速打包

set -e

PLATFORM=${1:-arm64}  # 默认 arm64 (M1/M2/M4)
NODE_VERSION=${2:-18} # 默认 node18

echo "🚀 为 $PLATFORM 平台打包 (Node.js $NODE_VERSION)..."

# 检查 pkg 是否安装
if ! command -v pkg &> /dev/null; then
    echo "❌ 未找到 pkg，请先安装：npm install -g pkg"
    exit 1
fi

# 创建输出目录
mkdir -p dist-bin

# 进入 CLI 目录
cd packages/cli

echo "🏗️  构建项目..."
npm run build --silent 2>/dev/null

echo "📦 打包中..."

# 映射平台到 pkg target
case $PLATFORM in
    "arm64"|"m1"|"m2"|"m4")
        TARGET="node${NODE_VERSION}-macos-arm64"
        OUTPUT_FILE="../../dist-bin/qwen-macos-arm64"
        ;;
    "x64"|"intel")
        TARGET="node${NODE_VERSION}-macos-x64"
        OUTPUT_FILE="../../dist-bin/qwen-macos-x64"
        ;;
    *)
        echo "❌ 不支持的平台: $PLATFORM"
        echo "支持的平台: arm64, x64"
        exit 1
        ;;
esac

# 执行打包（静默模式减少输出）
pkg . --targets $TARGET --output $OUTPUT_FILE 2>/dev/null || {
    # 如果失败再显示详细信息
    pkg . --targets $TARGET --output $OUTPUT_FILE
}

echo ""
echo "✅ 打包完成！"
echo "文件: $OUTPUT_FILE ($(du -h $OUTPUT_FILE | cut -f1))"
echo ""
echo "💡 使用方法："
echo "  ./$OUTPUT_FILE --version"
echo "  ./$OUTPUT_FILE --help"