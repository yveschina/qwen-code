#!/usr/bin/env node
/**
 * patch-qwencode.cjs
 *
 * Qwen Code 自定义补丁脚本
 *
 * 功能：
 *   1. 隐藏 UI 输出中的 thinking 内容
 *   2. 修复 /quit 和 Ctrl+C 退出时的报错
 *
 * 用法：
 *   cd <qwen-code-source-dir>
 *   node patch-qwencode.cjs
 *
 * 补丁应用后需要重新构建：
 *   npm run build
 */

const fs = require('fs');
const path = require('path');

const baseDir = process.argv[2] || __dirname;
let patchCount = 0;
let failCount = 0;

function patchFile(relPath, patches) {
  const filePath = path.join(baseDir, relPath);

  if (!fs.existsSync(filePath)) {
    console.error(`  [FAIL] 文件不存在: ${relPath}`);
    failCount += patches.length;
    return;
  }

  let content = fs.readFileSync(filePath, 'utf-8');
  let modified = false;

  for (const { name, find, replace, check } of patches) {
    // If a check string is provided, use it to detect if patch is already applied
    const alreadyApplied = check ? content.includes(check) : content.includes(replace);

    if (alreadyApplied && !content.includes(find)) {
      console.log(`  [SKIP] ${name} (已应用)`);
      continue;
    }

    if (content.includes(find)) {
      content = content.replace(find, replace);
      console.log(`  [OK]   ${name}`);
      modified = true;
      patchCount++;
    } else {
      console.error(`  [FAIL] ${name} (未找到匹配模式，可能上游已变更)`);
      failCount++;
    }
  }

  if (modified) {
    fs.writeFileSync(filePath, content, 'utf-8');
  }
}

// ─────────────────────────────────────────────
console.log('╔══════════════════════════════════════╗');
console.log('║   Qwen Code 自定义补丁              ║');
console.log('╚══════════════════════════════════════╝\n');

// ─── Patch 1: 隐藏 thinking 内容 ─────────────
console.log('[1/2] 隐藏 thinking 内容 (HistoryItemDisplay.tsx)');

patchFile('packages/cli/src/ui/components/HistoryItemDisplay.tsx', [
  {
    name: '在 useMemo 后添加 thinking 类型的 early return',
    find: [
      '  const itemForDisplay = useMemo(() => escapeAnsiCtrlCodes(item), [item]);',
      '  const contentWidth = terminalWidth - 4;',
    ].join('\n'),
    replace: [
      '  const itemForDisplay = useMemo(() => escapeAnsiCtrlCodes(item), [item]);',
      '',
      '  // [patch] 隐藏 thinking 内容',
      "  if (item.type === 'gemini_thought' || item.type === 'gemini_thought_content') {",
      '    return null;',
      '  }',
      '',
      '  const contentWidth = terminalWidth - 4;',
    ].join('\n'),
    check: '隐藏 thinking 内容',
  },
]);

// ─── Patch 2: 修复退出报错 ───────────────────
console.log('\n[2/2] 修复退出报错 (AppContainer.tsx)');

patchFile('packages/cli/src/ui/AppContainer.tsx', [
  {
    name: '退出时清除 updateInfo 并添加 try/catch',
    find: [
      '      quit: (messages: HistoryItem[]) => {',
      '        setQuittingMessages(messages);',
      '        setTimeout(async () => {',
      '          await runExitCleanup();',
      '          process.exit(0);',
      '        }, 100);',
      '      },',
    ].join('\n'),
    replace: [
      '      quit: (messages: HistoryItem[]) => {',
      '        setQuittingMessages(messages);',
      '        setUpdateInfo(null);',
      '        setTimeout(async () => {',
      '          try {',
      '            await runExitCleanup();',
      '            await new Promise((resolve) => setTimeout(resolve, 50));',
      '          } catch (_e) {',
      '            // Ignore cleanup errors during exit',
      '          }',
      '          process.exit(0);',
      '        }, 100);',
      '      },',
    ].join('\n'),
    check: 'setUpdateInfo(null)',
  },
]);

// ─── 结果汇总 ────────────────────────────────
console.log('\n────────────────────────────────────────');
if (failCount === 0) {
  console.log(`✓ 全部完成！共应用 ${patchCount} 个补丁`);
  console.log('\n下一步：重新构建');
  console.log('  npm run build\n');
} else {
  console.log(`完成：${patchCount} 个成功, ${failCount} 个失败`);
  console.log('失败的补丁可能需要手动处理（上游代码已变更）\n');
  process.exit(1);
}
