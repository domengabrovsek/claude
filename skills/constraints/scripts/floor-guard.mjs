#!/usr/bin/env node
/*
 * floor-guard: diff-scoped enforcement of the CONSTRAINTS.md floor.
 * Usage: node floor-guard.mjs [--base <ref>]   (default base: origin/main)
 * Exit codes: 0 clean, 1 floor violation, 2 the guard could not run.
 * Reports the rule and the location, never a matched secret value.
 */
import { execFileSync } from 'node:child_process';

const base = (() => {
  const i = process.argv.indexOf('--base');
  return i > -1 ? process.argv[i + 1] : 'origin/main';
})();

const git = (args) => {
  try { return execFileSync('git', args, { encoding: 'utf8' }); }
  catch { return null; }
};

/* Bail to exit 2 rather than pretending a shallow or rootless clone is clean. */
const mergeBase = git(['merge-base', base, 'HEAD'])?.trim();
if (!mergeBase) { console.error('floor-guard: no merge base against ' + base); process.exit(2); }

/* Unified diff plus untracked files; git diff alone cannot see new files. */
const tracked = git(['diff', '--unified=0', mergeBase, '--']) ?? '';
const untracked = (git(['ls-files', '--others', '--exclude-standard']) ?? '')
  .split('\n').filter(Boolean)
  .map((f) => git(['diff', '--no-index', '--unified=0', '/dev/null', f]) ?? '')
  .join('\n');
const diff = tracked + '\n' + untracked;

const added = [], removed = [];
let file = '';
for (const line of diff.split('\n')) {
  if (line.startsWith('+++ ')) file = line.slice(6);
  else if (line.startsWith('+') && !line.startsWith('+++')) added.push({ file, text: line.slice(1) });
  else if (line.startsWith('-') && !line.startsWith('---')) removed.push({ file, text: line.slice(1) });
}

const findings = [];
const flag = (rule, f, text) => findings.push({ rule, file: f, text: text.trim().slice(0, 120) });

/* The three regexes are the only stack-specific part; extend per ecosystem. */
const SUPPRESSIONS = /@ts-ignore|@ts-nocheck|eslint-disable|biome-ignore|# *noqa|# *type: *ignore|istanbul ignore|nosemgrep|gitleaks:allow|Stryker disable/;
const STUBS = /throw new (Error|NotImplemented).*[Nn]ot implemented|catch\s*\(\w*\)\s*\{\s*\}|catch\s*\{\s*\}|\bTO+DO\b|\bpass\s*# *stub/;
const SKIPS = /\.(skip|todo)\b|\bxit\(|\bxdescribe\(|@pytest\.mark\.skip|t\.Skip\(/;

for (const { file, text } of added) {
  if (SUPPRESSIONS.test(text)) flag('silenced-checker', file, text);
  if (STUBS.test(text)) flag('unfinished-work', file, text);
  if (SKIPS.test(text)) flag('test-made-easier', file, text);
  if (/CONSTRAINTS\.md$/.test(file) && /^\| *(W|E)\d+ *\|/.test(text)) flag('new-exception', file, text);
}

/* Assertion removed from a test file that still exists. */
for (const { file, text } of removed) {
  if (/\.(test|spec)\.|_test\.|test_/.test(file) && /\b(expect|assert|should)\b/.test(text)) {
    flag('assertion-removed', file, text);
  }
}

/* Weakened threshold: a number in CONSTRAINTS.md that went down. */
const nums = (s) => (s.match(/\d+(\.\d+)?/g) || []).map(Number);
const removedConstraints = removed.filter((l) => /CONSTRAINTS\.md$/.test(l.file));
const addedConstraints = added.filter((l) => /CONSTRAINTS\.md$/.test(l.file));
for (const r of removedConstraints) {
  const a = addedConstraints.find((x) => x.text.split(/[|:]/)[0] === r.text.split(/[|:]/)[0]);
  if (a && nums(a.text).some((n, i) => nums(r.text)[i] !== undefined && n < nums(r.text)[i])) {
    flag('threshold-lowered', r.file, r.text + '  ->  ' + a.text);
  }
}

if (findings.length === 0) { console.log('floor-guard: clean'); process.exit(0); }
console.error('floor-guard: ' + findings.length + ' floor violation(s):');
for (const f of findings) console.error(`  [${f.rule}] ${f.file}: ${f.text}`);
console.error('\nEach is a move that lowers the bar. Fix the code, or route it through a tracked exception.');
process.exit(1);
