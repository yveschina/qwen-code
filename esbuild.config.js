/**
 * @license
 * Copyright 2025 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */

import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import { writeFileSync, readFileSync, rmSync } from 'node:fs';

let esbuild;
try {
  esbuild = (await import('esbuild')).default;
} catch (_error) {
  console.warn('esbuild not available, skipping bundle step');
  process.exit(0);
}

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const require = createRequire(import.meta.url);
const pkg = require(path.resolve(__dirname, 'package.json'));

// Clean dist directory (cross-platform)
rmSync(path.resolve(__dirname, 'dist'), { recursive: true, force: true });

const external = [
  '@lydell/node-pty',
  'node-pty',
  '@lydell/node-pty-darwin-arm64',
  '@lydell/node-pty-darwin-x64',
  '@lydell/node-pty-linux-x64',
  '@lydell/node-pty-win32-arm64',
  '@lydell/node-pty-win32-x64',
  '@teddyzhu/clipboard',
  '@teddyzhu/clipboard-darwin-arm64',
  '@teddyzhu/clipboard-darwin-x64',
  '@teddyzhu/clipboard-linux-x64-gnu',
  '@teddyzhu/clipboard-linux-arm64-gnu',
  '@teddyzhu/clipboard-win32-x64-msvc',
  '@teddyzhu/clipboard-win32-arm64-msvc',
];

esbuild
  .build({
    entryPoints: ['packages/cli/index.ts'],
    bundle: true,
    outfile: 'dist/cli.js',
    platform: 'node',
    format: 'esm',
    target: 'node20',
    external,
    packages: 'bundle',
    inject: [path.resolve(__dirname, 'scripts/esbuild-shims.js')],
    banner: {
      js: `// Force strict mode and setup for ESM
"use strict";`,
    },
    alias: {
      'is-in-ci': path.resolve(
        __dirname,
        'packages/cli/src/patches/is-in-ci.ts',
      ),
    },
    define: {
      'process.env.CLI_VERSION': JSON.stringify(pkg.version),
      // Make global available for compatibility
      global: 'globalThis',
    },
    loader: { '.node': 'file' },
    metafile: true,
    write: true,
    keepNames: true,
  })
  .then(({ metafile }) => {
    if (process.env.DEV === 'true') {
      writeFileSync('./dist/esbuild.json', JSON.stringify(metafile, null, 2));
    }

    // [patch] Fix ESM/CJS interop for ansi-regex.
    // ansi-align/node_modules/strip-ansi@6 (CJS) depends on ansi-regex@^5 (CJS),
    // but npm hoists ansi-regex@6 (ESM-only). esbuild wraps the ESM default
    // export via __toCommonJS, producing an object {default: fn} instead of fn.
    // We patch __toCommonJS so that modules exporting *only* a default are
    // unwrapped automatically, matching the behaviour callers expect.
    const outfile = path.resolve(__dirname, 'dist/cli.js');
    let code = readFileSync(outfile, 'utf-8');

    const oldToCommonJS =
      'var __toCommonJS = (mod2) => __copyProps(__defProp({}, "__esModule", { value: true }), mod2);';
    const newToCommonJS = `var __toCommonJS = (mod2) => {
  var result = __copyProps(__defProp({}, "__esModule", { value: true }), mod2);
  // Unwrap ESM modules that only export a default value so that
  // CJS callers (e.g. strip-ansi requiring ansi-regex) get the
  // function directly instead of a {default: fn} wrapper.
  var keys = Object.keys(result);
  if (keys.length === 1 && keys[0] === "default") return result.default;
  return result;
};`;

    if (code.includes(oldToCommonJS)) {
      code = code.replace(oldToCommonJS, newToCommonJS);
      writeFileSync(outfile, code);
      console.log('[patch] Fixed __toCommonJS ESM default-export interop');
    } else {
      console.warn(
        '[patch] WARNING: __toCommonJS pattern not found – ESM interop fix skipped',
      );
    }
  })
  .catch((error) => {
    console.error('esbuild build failed:', error);
    process.exitCode = 1;
  });
