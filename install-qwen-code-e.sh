#!/bin/bash
# install-custom-qwen.sh - 安装自定义版本的 Qwen Code

set -e

REPO_URL="https://github.com/yveschina/qwen-code.git"
BRANCH="main"

echo "📥 安装自定义 Qwen Code..."

# 检查依赖
for cmd in git node npm; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ 未找到 $cmd，请先安装"
        exit 1
    fi
done

NODE_VERSION=$(node -v | cut -d'.' -f1 | sed 's/v//')
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "❌ Node.js 版本过低，需要 >= 20"
    exit 1
fi

echo "✅ 依赖检查通过"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"

# 克隆仓库
echo "🔄 克隆仓库..."
git clone --depth 1 -b "$BRANCH" "$REPO_URL" qwen-code
cd qwen-code

# 应用补丁
echo "🔧 应用自定义补丁..."
node patch-qwencode.cjs

# 构建
echo "🏗️  构建项目..."
npm install
npm run build

# 链接安装
echo "🔗 安装到全局..."
npm link --prefix packages/cli

# 验证
echo ""
echo "✅ 安装完成！"
echo "版本信息:"
qwen --version

echo ""
echo "💡 源码位置: $TEMP_DIR/qwen-code"
echo "💡 如需卸载: npm uninstall -g @qwen-code/qwen-code"