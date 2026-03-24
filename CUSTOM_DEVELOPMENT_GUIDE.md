# Qwen Code 自定义开发与部署指南

## 📌 概述

本文档记录了对 Qwen Code 的自定义修改、升级流程和跨设备部署方法。

## ✅ 当前已做的自定义修改

### 1. 隐藏 thinking 内容

- **文件**: `packages/cli/src/ui/components/HistoryItemDisplay.tsx`
- **作用**: 不再显示带有 `✦` 前缀的灰色 thinking 文本

### 2. 修复退出报错

- **文件**: `packages/cli/src/ui/AppContainer.tsx`
- **作用**:
  - `/quit` 和 `Ctrl+C` 退出时不再报错
  - 清除 updateInfo 防止更新通知干扰退出
  - 添加 try/catch 包裹 cleanup 逻辑
  - 增加延时确保渲染完成后再退出

### 3. 补丁脚本

- **文件**: `patch-qwencode.cjs`
- **作用**: 自动化应用上述补丁，幂等设计（重复运行安全）

## 🔧 日常开发工作流

### 初始化设置（首次）

```bash
# 克隆你的 fork
git clone git@github.com:yveschina/qwen-code.git
cd qwen-code

# 添加上游仓库
git remote add upstream https://github.com/QwenLM/qwen-code.git

# 安装依赖
npm install
```

### 日常开发循环

```bash
# 1. 启动开发模式（热重载）
npm run dev

# 2. 修改代码后测试
npm start  # 或直接运行 qwen（如果已链接）

# 3. 提交修改
git add .
git commit -m "描述你的修改"
git push origin main
```

## ⬆️ 升级上游代码流程

当 QwenLM/qwen-code 有新版本发布时：

```bash
# 1. 拉取上游最新代码
git pull upstream main

# 2. 应用自定义补丁
node patch-qwencode.cjs

# 3. 构建项目
npm run build

# 4. 安装到全局
npm link --prefix packages/cli

# 5. 验证安装
qwen --version

# 6. 推送更新到你的 fork（可选）
git add -A
git commit -m "chore: upgrade to latest upstream + apply patches"
git push origin main
```

## 📦 打包分发包（用于其他 Mac 设备）

### 方法一：打包为 tar.gz（推荐）

```bash
# 1. 构建项目
npm run build

# 2. 创建分发目录
mkdir -p dist-package
cd dist-package

# 3. 复制必要文件
cp -r ../packages/cli ./qwen-code-cli
cp ../patch-qwencode.cjs .
cp ../package.json ./qwen-code-cli/

# 4. 打包
tar -czf qwen-code-custom.tar.gz qwen-code-cli patch-qwencode.cjs

# 5. 包大小检查
ls -lh qwen-code-custom.tar.gz
```

### 方法二：使用 npm pack（官方推荐）

```bash
# 1. 进入 CLI 目录
cd packages/cli

# 2. 打包
npm pack

# 3. 会在当前目录生成类似 qwen-code-qwen-code-0.13.0.tgz 的文件
ls *.tgz
```

## 💻 在其他 Mac 设备上安装

### 安装前置条件

```bash
# 确保 Node.js >= 20
node --version

# 安装 npm（通常随 Node.js 一起安装）
npm --version
```

### 安装步骤

#### 方式一：使用 tar.gz 包

```bash
# 1. 解压包
tar -xzf qwen-code-custom.tar.gz
cd qwen-code-cli

# 2. 应用补丁
node ../patch-qwencode.cjs

# 3. 安装依赖
npm install

# 4. 链接到全局
npm link

# 5. 验证
qwen --version
```

#### 方式二：使用 npm tgz 包

```bash
# 直接全局安装
npm install -g ./qwen-code-qwen-code-0.13.0.tgz

# 验证
qwen --version
```

## 🛠️ 开发更多自定义功能

### 新增补丁的流程

1. **修改源码**

   ```bash
   # 直接编辑你需要的文件
   vim packages/cli/src/xxx.ts
   ```

2. **提取 diff 生成补丁**

   ```bash
   # 查看当前修改
   git diff

   # 生成 patch 文件（可选）
   git diff > my-new-feature.patch
   ```

3. **更新 patch-qwencode.cjs**

   在脚本中添加新的 patch 规则：

   ```javascript
   patchFile('relative/path/to/file.ts', [
     {
       name: '简短描述',
       find: '要替换的原文本',
       replace: '替换后的文本',
       check: '检查是否已应用的标识文本', // 可选
     },
   ]);
   ```

4. **测试补丁**

   ```bash
   # 恢复原始文件
   git checkout -- .

   # 应用补丁
   node patch-qwencode.cjs

   # 构建验证
   npm run build
   npm run typecheck  # 如果有类型检查脚本
   ```

### 补丁脚本编写要点

- **幂等性**: 使用 `check` 字段避免重复应用
- **精确匹配**: `find` 文本要足够独特，避免误匹配
- **保持可读**: 补丁逻辑要清晰，注释说明用途
- **类型安全**: 修改后运行 TypeScript 检查

## 📁 项目目录结构说明

```
qwen-code/
├── packages/
│   ├── cli/              # 主 CLI 程序（我们主要修改这里）
│   ├── core/             # 核心库
│   └── ...
├── patch-qwencode.cjs    # 自定义补丁脚本 ✅
├── docs/                 # 文档
└── ...
```

## 🚀 常用命令速查

```bash
# 开发
npm run dev          # 开发模式（热重载）
npm start           # 启动 CLI
npm run build       # 构建所有包
npm run typecheck   # 类型检查

# 测试
npm test            # 运行单元测试
npm run test:e2e    # 运行集成测试

# 代码质量
npm run lint        # 代码检查
npm run format      # 代码格式化

# 发布相关
npm link            # 链接到全局（开发时）
npm pack            # 打包当前包
npm publish         # 发布到 npm（需权限）
```

## ⚠️ 注意事项

1. **定期同步上游**: 建议每周检查一次 QwenLM/qwen-code 的更新
2. **备份重要修改**: 自定义补丁都要记录在 patch-qwencode.cjs 中
3. **测试兼容性**: 每次升级后都要充分测试核心功能
4. **版本控制**: 补丁脚本中最好注明适用的上游版本范围

## 📞 故障排除

### 构建失败

```bash
# 清理缓存重新构建
npm run clean
rm -rf node_modules
npm install
npm run build
```

### 全局命令不可用

```bash
# 检查 npm 全局路径
npm list -g --depth=0

# 重新链接
npm unlink -g @qwen-code/qwen-code
npm link --prefix packages/cli
```

### 补丁应用失败

```bash
# 手动检查文件是否存在
ls packages/cli/src/ui/AppContainer.tsx

# 查看具体错误
node patch-qwencode.cjs
```

---

📝 _文档最后更新: 2026-03-24_
