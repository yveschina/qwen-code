#!/bin/bash
# pack-for-distribution.sh - 打包为 npm 包格式（与官方一致）

set -e

echo "📦 打包 Qwen Code 为 npm 分发包..."

# 进入 CLI 目录
cd packages/cli

echo "🏗️  构建项目..."
npm run build

echo "📦 创建 npm 包..."
npm pack --quiet

# 获取生成的包文件名
PACKAGE_FILE=$(ls qwen-code-qwen-code-*.tgz | head -1)

echo ""
echo "✅ 打包完成！"
echo "文件: $PACKAGE_FILE ($(du -h $PACKAGE_FILE | cut -f1))"
echo ""
echo "📋 分发说明："
echo "1. 将此文件复制到目标 Mac"
echo "2. 运行: npm install -g ./$PACKAGE_FILE"
echo "3. 会自动覆盖官方版本"