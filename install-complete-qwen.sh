#!/bin/bash
# install-complete-qwen.sh - 在目标 Mac 上完整安装 Qwen Code（包含所有依赖）

set -e

echo "📥 完整安装 Qwen Code..."

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 未找到 Node.js，请先安装 Node.js >= 20"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'.' -f1 | sed 's/v//')
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "❌ Node.js 版本过低 ($node_version)，需要 >= 20"
    exit 1
fi

echo "✅ Node.js 版本: $(node -v)"

# 卸载现有版本
echo "🗑️  卸载现有版本..."
npm uninstall -g @qwen-code/qwen-code 2>/dev/null || true

# 安装主包
echo "📦 安装 Qwen Code..."
npm install -g @qwen-code/qwen-code

# 安装工作区依赖
echo "🔌 安装工作区依赖..."
npm install -g @qwen-code/qwen-code-core
npm install -g @qwen-code/web-templates

# 验证安装
echo ""
echo "✅ 安装完成！"
echo "版本信息:"
qwen --version

echo ""
echo "💡 如需卸载，运行: npm uninstall -g @qwen-code/qwen-code @qwen-code/qwen-code-core @qwen-code/web-templates"