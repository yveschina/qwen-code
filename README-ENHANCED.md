# Qwen Code Enhanced 🚀

这是 Qwen Code 的增强版本，包含了以下改进功能：

## 🌟 主要特性

### 1. 隐藏思考内容显示

- 移除了 UI 中的 thinking/thought 内容显示
- 让对话界面更加简洁清晰
- 专注于实际的问答内容

### 2. 修复退出报错

- 解决了 `/quit` 命令和 `Ctrl+C` 退出时的错误
- 添加了适当的错误处理和清理逻辑
- 确保程序能够干净地退出到终端

### 3. 改进稳定性

- 优化了模块加载和依赖解析
- 修复了 ESM/CommonJS 互操作性问题
- 提供了更可靠的安装和运行体验

## 📦 安装方式

### 方法一：一键安装脚本（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/yveschina/qwen-code/main/qwen-code-e-install.sh | bash
```

### 方法二：手动安装

```bash
# 克隆仓库
git clone https://github.com/yveschina/qwen-code.git
cd qwen-code

# 应用补丁
node qwen-code-e-patch.cjs

# 构建和安装
npm install
npm run build
npm install -g ./packages/cli
```

## 🧪 验证安装

安装完成后，可以运行以下命令验证：

```bash
# 检查版本
qwen --version

# 运行测试
node qwen-code-e-test.cjs
```

## 🛠️ 开发说明

### 补丁文件

- `qwen-code-e-patch.cjs` - 核心修改补丁脚本
- `qwen-code-e-install.sh` - 一键安装脚本
- `esbuild.config.js` - 包含 ESM 互操作性修复

### 修改的文件

1. `packages/cli/src/ui/components/HistoryItemDisplay.tsx` - 隐藏 thinking 内容
2. `packages/cli/src/ui/AppContainer.tsx` - 修复退出逻辑

## ⚠️ 注意事项

- 此版本基于官方 Qwen Code 仓库的特定提交
- 建议定期同步上游更新
- 如遇到问题，可以随时卸载并重新安装

## 📝 卸载方法

```bash
npm uninstall -g @qwen-code/qwen-code
rm -rf ~/.qwen-code-e-src
```

---

_Enhanced with ❤️ for better Qwen Code experience_
