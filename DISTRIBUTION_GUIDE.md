# Qwen Code 自定义版本分发指南

## 🎯 目标

打包自定义版本，一键安装到其他 Mac，**完全替代官方版本**，无冲突。

## 📦 打包流程（在你的开发机上）

```bash
# 1. 应用自定义补丁
node patch-qwencode.cjs

# 2. 构建项目
npm run build

# 3. 打包为 npm 包
./pack-for-distribution.sh
```

这会生成类似 `qwen-code-qwen-code-0.13.0.tgz` 的文件。

## 🚀 一键安装到其他 Mac

### 方法一：使用安装脚本（推荐）

```bash
# 在目标 Mac 上执行：
curl -O https://你的服务器/install-on-target.sh
chmod +x install-on-target.sh
./install-on-target.sh qwen-code-qwen-code-0.13.0.tgz
```

### 方法二：手动安装

```bash
# 1. 传输包文件到目标 Mac
scp qwen-code-qwen-code-0.13.0.tgz user@target-mac:~/

# 2. 在目标 Mac 上执行：
npm uninstall -g @qwen-code/qwen-code  # 卸载官方版
npm install -g ./qwen-code-qwen-code-0.13.0.tgz  # 安装自定义版

# 3. 验证
qwen --version
```

## ✅ 特性保证

- ✅ **无缝替换**：命令行接口完全一致
- ✅ **无冲突**：包名相同，npm 会自动覆盖
- ✅ **保留配置**：用户原有配置文件不受影响
- ✅ **易于回滚**：卸载自定义版后可重新安装官方版

## 🔄 升级流程

当需要升级时：

```bash
# 1. 在开发机更新代码并重新打包
git pull upstream main
node patch-qwencode.cjs
./pack-for-distribution.sh

# 2. 在各目标 Mac 上重新安装
./install-on-target.sh 新版本.tgz
```

---

_文档精简版，专注核心分发流程_
