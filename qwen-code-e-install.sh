#!/bin/bash
# qwen-code-e-install.sh - 安装 Qwen Code Enhanced 版本
#
# 功能:
#   1. 隐藏 UI 中的 thinking 思考内容
#   2. 修复 /quit 和 Ctrl+C 退出时的报错
#   3. 修复 ansi-regex ESM/CJS 互操作性问题

set -e

REPO_URL="https://github.com/yveschina/qwen-code.git"
BRANCH="main"

echo "================================================"
echo "  Qwen Code Enhanced - 安装脚本"
echo "================================================"
echo ""

# 检查依赖
for cmd in git node npm; do
    if ! command -v $cmd &> /dev/null; then
        echo "[ERROR] 未找到 $cmd，请先安装"
        exit 1
    fi
done

NODE_VERSION=$(node -v | cut -d'.' -f1 | sed 's/v//')
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "[ERROR] Node.js 版本过低 (当前: $(node -v))，需要 >= 20"
    exit 1
fi

echo "[OK] 依赖检查通过 (Node $(node -v), npm $(npm -v))"

# 创建固定目录（不在临时目录中）
INSTALL_DIR="$HOME/.qwen-code-e-src"
echo "[INFO] 源码目录: $INSTALL_DIR"

# 如果目录已存在，先删除
if [ -d "$INSTALL_DIR" ]; then
    echo "[INFO] 删除旧版本..."
    rm -rf "$INSTALL_DIR"
fi

# 克隆仓库
echo ""
echo "[1/5] 克隆仓库..."
git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 应用源码级补丁（隐藏 thinking、修复退出）
echo ""
echo "[2/5] 应用自定义补丁..."
node qwen-code-e-patch.cjs

# 安装依赖并构建
echo ""
echo "[3/5] 安装依赖并构建..."
npm install
npm run build

# 打包成单文件 bundle（包含 ESM 互操作修复）
echo ""
echo "[4/5] 打包分发包..."
npm run bundle
node scripts/prepare-package.js

# 全局安装打包后的 bundle
echo ""
echo "[5/5] 安装到全局..."
npm install -g ./dist/

# 验证
echo ""
echo "================================================"
echo "  安装完成!"
echo "================================================"
echo ""
echo "版本: $(qwen --version)"
echo "命令: qwen"
echo ""
echo "源码位置: $INSTALL_DIR"
echo ""
echo "卸载方法:"
echo "  npm uninstall -g @qwen-code/qwen-code"
echo "  rm -rf $INSTALL_DIR"