#!/bin/bash
# qwen-code-e-install.sh - 安装 Qwen Code Enhanced 版本

set -e

REPO_URL="https://github.com/yveschina/qwen-code.git"
BRANCH="main"

echo "📥 安装 Qwen Code Enhanced..."

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

# 创建固定目录（不在临时目录中）
INSTALL_DIR="$HOME/.qwen-code-e-src"
echo "📂 源码将安装到: $INSTALL_DIR"

# 如果目录已存在，先删除
if [ -d "$INSTALL_DIR" ]; then
    echo "🗑️  删除旧版本..."
    rm -rf "$INSTALL_DIR"
fi

# 克隆仓库
echo "🔄 克隆仓库..."
git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 应用补丁
echo "🔧 应用自定义补丁..."
node qwen-code-e-patch.cjs

# 构建所有包
echo "🏗️  构建项目..."
npm install
npm run build
npm run bundle

# 安装所有包到全局（使用 file: 引用，保持链接有效）
echo "📦 安装到全局..."
npm install -g ./packages/core
npm install -g ./packages/web-templates
npm link --prefix packages/cli

# 验证
echo ""
echo "✅ 安装完成！"
echo "版本信息:"
qwen --version

echo ""
echo "💡 源码位置: $INSTALL_DIR"
echo "💡 如需卸载:"
echo "   npm uninstall -g @qwen-code/qwen-code @qwen-code/qwen-code-core @qwen-code/web-templates"
echo "   rm -rf $INSTALL_DIR"