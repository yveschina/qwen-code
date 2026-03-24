# Qwen Code Enhanced 开发指南

## 📌 概述

本文档记录 Qwen Code Enhanced (qwen-code-e) 的自定义修改和开发流程。

## ✅ 当前自定义功能

### 1. 隐藏 thinking 内容

- **文件**: `packages/cli/src/ui/components/HistoryItemDisplay.tsx`
- **作用**: 不显示 `✦` 前缀的灰色 thinking 文本

### 2. 修复退出报错

- **文件**: `packages/cli/src/ui/AppContainer.tsx`
- **作用**: `/quit` 和 `Ctrl+C` 退出时添加错误处理

### 3. 补丁脚本

- **文件**: `qwen-code-e-patch.cjs`
- **作用**: 自动化应用上述补丁

## 🔧 日常开发流程

### 初始化

```bash
git clone git@github.com:yveschina/qwen-code.git
cd qwen-code
git remote add upstream https://github.com/QwenLM/qwen-code.git
npm install
```

### 开发循环

```bash
npm run dev     # 开发模式
npm start      # 测试运行
git add . && git commit -m "修改说明"
git push origin main
```

## ⬆️ 升级上游代码

```bash
git pull upstream main
node qwen-code-e-patch.cjs
npm run build
npm link --prefix packages/cli
qwen --version
```

## 📦 分发给用户

用户只需运行：

```bash
curl -fsSL https://raw.githubusercontent.com/yveschina/qwen-code/main/qwen-code-e-install.sh | bash
```

## 🚀 常用命令

```bash
npm run dev          # 开发模式
npm start           # 启动 CLI
npm run build       # 构建
npm run typecheck   # 类型检查
npm test            # 运行测试
npm run lint        # 代码检查
```

---

_专注核心开发，分发使用 qwen-code-e-install.sh_
