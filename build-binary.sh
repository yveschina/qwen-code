#!/bin/bash
# build-binary.sh - 打包 Qwen Code 为独立二进制文件

set -e

echo "🚀 开始打包 Qwen Code 二进制文件..."

# 检查 pkg 是否安装
if ! command -v pkg &> /dev/null; then
    echo "❌ 未找到 pkg，请先安装：npm install -g pkg"
    exit 1
fi

# 进入 CLI 目录
cd "$(dirname "$0")/packages/cli"

echo "🏗️  构建项目..."
npm run build

echo "📦 打包二进制文件..."

# Intel Mac (x64)
echo "  - 打包 macOS Intel 版本..."
pkg . --targets node18-macos-x64 --output ../../dist-bin/qwen-macos-x64

# Apple Silicon Mac (arm64)
echo "  - 打包 macOS Apple Silicon 版本..."
pkg . --targets node18-macos-arm64 --output ../../dist-bin/qwen-macos-arm64

# Linux
echo "  - 打包 Linux 版本..."
pkg . --targets node18-linux-x64 --output ../../dist-bin/qwen-linux-x64

# Windows
echo "  - 打包 Windows 版本..."
pkg . --targets node18-win-x64 --output ../../dist-bin/qwen-win.exe

echo "✅ 打包完成！文件位于 dist-bin/ 目录："
ls -lh ../../dist-bin/

echo ""
echo "💡 使用说明："
echo "  macOS Intel:     ./dist-bin/qwen-macos-x64"
echo "  macOS Apple Silicon: ./dist-bin/qwen-macos-arm64"
echo "  Linux:           ./dist-bin/qwen-linux-x64"
echo "  Windows:         dist-bin\\qwen-win.exe"