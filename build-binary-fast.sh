#!/bin/bash
# build-binary-fast.sh - 快速打包 Qwen Code 二进制文件（多平台并行）

set -e

echo "🚀 快速打包 Qwen Code 二进制文件..."

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
npm run build

echo "📦 并行打包二进制文件..."

# 定义要打包的平台
platforms=(
    "node18-macos-arm64:M1/M2芯片"
    "node18-macos-x64:Intel芯片"
    #"node20-macos-arm64:M4芯片"  # 如果需要 node20 版本取消注释
)

# 并行打包函数
build_platform() {
    local target=$1
    local name=$2
    local output_file="../../dist-bin/qwen-$(echo $target | cut -d'-' -f3)"
    
    echo "  [$name] 开始打包..."
    pkg . --targets $target --output $output_file 2>/dev/null || {
        echo "  [$name] 警告：部分文件未预编译，但不影响使用"
        pkg . --targets $target --output $output_file
    }
    echo "  [$name] ✓ 完成 ($(du -h $output_file | cut -f1))"
}

# 并行执行打包
pids=()
for platform in "${platforms[@]}"; do
    target=$(echo $platform | cut -d':' -f1)
    name=$(echo $platform | cut -d':' -f2)
    build_platform "$target" "$name" &
    pids+=($!)
done

# 等待所有打包完成
echo "⏳ 等待所有平台打包完成..."
for pid in ${pids[*]}; do
    wait $pid
done

echo ""
echo "✅ 打包完成！文件位于 dist-bin/ 目录："
ls -lh ../../dist-bin/

echo ""
echo "💡 使用说明："
echo "  M1/M2 Mac:  ./dist-bin/qwen-arm64"
echo "  Intel Mac:  ./dist-bin/qwen-x64"
echo ""
echo "📌 文件大小对比："
du -h ../../dist-bin/qwen-* | sort -hr