#!/usr/bin/env node
// prepare-package.js - Prepare CLI package for distribution by bundling dependencies

import { readFileSync, writeFileSync, cpSync, existsSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';

const cliDir = join(process.cwd(), 'packages', 'cli');
const coreDir = join(process.cwd(), 'packages', 'core');
const templatesDir = join(process.cwd(), 'packages', 'web-templates');

console.log('📂 Preparing CLI package for distribution...');

// 1. Copy dependencies
console.log('  Copying @qwen-code/qwen-code-core...');
const coreTarget = join(cliDir, 'node_modules', '@qwen-code', 'qwen-code-core');
mkdirSync(join(cliDir, 'node_modules', '@qwen-code'), { recursive: true });
cpSync(coreDir, coreTarget, { recursive: true });

console.log('  Copying @qwen-code/web-templates...');
const templatesTarget = join(cliDir, 'node_modules', '@qwen-code', 'web-templates');
cpSync(templatesDir, templatesTarget, { recursive: true });

// 2. Modify package.json to remove file: references
console.log('  Updating package.json...');
const pkgPath = join(cliDir, 'package.json');
const pkg = JSON.parse(readFileSync(pkgPath, 'utf-8'));

// Remove workspace file references
delete pkg.dependencies['@qwen-code/qwen-code-core'];
delete pkg.dependencies['@qwen-code/web-templates'];

writeFileSync(pkgPath, JSON.stringify(pkg, null, 2));

console.log('✅ Preparation complete!');