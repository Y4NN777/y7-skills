#!/usr/bin/env bash
# Automated health check for this LazyVim config.
# Runs nvim headless, checks plugin load, Claude Code integrations, and keymaps.
# Usage: ./scripts/test-config.sh
set -uo pipefail

NVIM_BIN="${NVIM_BIN:-nvim}"
FAIL=0
PASS=0

pass() { echo "  OK   $1"; PASS=$((PASS+1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL+1)); }

run_lua() {
  timeout 60 "$NVIM_BIN" --headless -c "$1" -c "qa" 2>&1
}

echo "== Environment =="
NVIM_VER=$("$NVIM_BIN" --version 2>/dev/null | head -1)
echo "  $NVIM_VER"
if "$NVIM_BIN" --version 2>/dev/null | head -1 | grep -qE 'v0\.(1[1-9]|[2-9][0-9])'; then
  pass "neovim version >= 0.11"
else
  fail "neovim version check (got: $NVIM_VER)"
fi

command -v git >/dev/null 2>&1 && pass "git present" || fail "git missing"
command -v claude >/dev/null 2>&1 && pass "claude CLI on PATH" || fail "claude CLI missing from PATH"
command -v lazyclaude >/dev/null 2>&1 && pass "lazyclaude CLI on PATH" || fail "lazyclaude CLI missing from PATH"

echo
echo "== Lazy.nvim plugin load =="
OUT=$(run_lua "lua local ok,err = pcall(function() local ps = require('lazy').plugins(); print('COUNT:'..#ps) end); if not ok then print('ERR:'..tostring(err)) end")
if echo "$OUT" | grep -q '^COUNT:'; then
  N=$(echo "$OUT" | grep -o 'COUNT:[0-9]*' | cut -d: -f2)
  pass "lazy.nvim loaded $N plugins"
else
  fail "lazy.nvim failed to load plugins ($OUT)"
fi

echo
echo "== claudecode.nvim =="
OUT=$(run_lua "lua local ok,mod = pcall(require,'claudecode'); print('REQUIRE:'..tostring(ok))")
echo "$OUT" | grep -q 'REQUIRE:true' && pass "require('claudecode') succeeds" || fail "require('claudecode') failed"

OUT=$(run_lua "lua local maps=vim.api.nvim_get_keymap('n'); local found={}; for _,m in ipairs(maps) do if m.lhs:match('^ a[cbafrCad]') then found[#found+1]=m.lhs end end; print('KEYS:'..table.concat(found,','))")
for k in ac ab af ar aC aa ad; do
  if echo "$OUT" | grep -q "$k"; then
    pass "claudecode keymap <leader>$k registered"
  else
    fail "claudecode keymap <leader>$k missing"
  fi
done

echo
echo "== lazyclaude.nvim =="
OUT=$(run_lua "lua local ok,mod = pcall(require,'lazyclaude'); print('REQUIRE:'..tostring(ok)); if ok then print('AVAILABLE:'..tostring(mod.is_available())) end")
echo "$OUT" | grep -q 'REQUIRE:true' && pass "require('lazyclaude') succeeds" || fail "require('lazyclaude') failed"
echo "$OUT" | grep -q 'AVAILABLE:true' && pass "lazyclaude.is_available() == true (binary found)" || fail "lazyclaude.is_available() == false (binary missing from nvim's PATH)"

OUT=$(run_lua "lua print(table.concat(vim.fn.getcompletion('LazyClaude','cmdline'),','))")
for c in LazyClaude LazyClaudeToggle LazyClaudeCurrentProject LazyClaudeClose; do
  echo "$OUT" | grep -q "$c" && pass "command :$c registered" || fail "command :$c missing"
done

OUT=$(run_lua "lua local maps=vim.api.nvim_get_keymap('n'); for _,m in ipairs(maps) do if m.lhs==' lc' then print('MAP_OK') end end")
echo "$OUT" | grep -q 'MAP_OK' && pass "lazyclaude keymap <leader>lc registered" || fail "lazyclaude keymap <leader>lc missing"

echo
echo "== Keymap collision check (<leader>a* vs <leader>l*) =="
OUT=$(run_lua "lua local maps=vim.api.nvim_get_keymap('n'); local seen={}; local dup=false; for _,m in ipairs(maps) do if seen[m.lhs] then dup=true; print('DUP:'..m.lhs) end; seen[m.lhs]=true end; if not dup then print('NO_DUPLICATES') end")
echo "$OUT" | grep -q 'NO_DUPLICATES' && pass "no duplicate normal-mode keymaps" || fail "duplicate keymap(s) found: $(echo "$OUT" | grep DUP)"

echo
echo "== checkhealth lazy =="
OUT=$(run_lua "lua vim.cmd('silent! checkhealth lazy'); local l=vim.api.nvim_buf_get_lines(0,0,-1,false); print(table.concat(l,'\\n'))")
ERRORS=$(echo "$OUT" | grep 'ERROR' | grep -v 'luarocks')
if [ -z "$ERRORS" ]; then
  pass "checkhealth lazy: no blocking errors"
else
  fail "checkhealth lazy: $ERRORS"
fi
if echo "$OUT" | grep -q 'luarocks'; then
  echo "  NOTE luarocks not installed (optional lazy-rocks feature; no installed plugin declares a 'rocks' dependency, so this is harmless)"
fi

echo
echo "== Mason binaries (tree-sitter-cli, shfmt) =="
MASON_BIN="$HOME/.local/share/nvim/mason/bin"
[ -x "$MASON_BIN/tree-sitter" ] && pass "mason: tree-sitter-cli installed" || fail "mason: tree-sitter-cli missing (run :MasonInstall tree-sitter-cli and wait for it to finish, headless 'qa' can cut the install short)"
[ -x "$MASON_BIN/shfmt" ] && pass "mason: shfmt installed" || fail "mason: shfmt missing (same as above)"

echo
echo "== claudecode.nvim Ex-commands (force-loaded) =="
OUT=$(run_lua "lua require('lazy').load({plugins={'claudecode.nvim'}}); vim.schedule(function() print('CMDS:'..table.concat(vim.fn.getcompletion('ClaudeCode','cmdline'),',')) end)" )
for c in ClaudeCode ClaudeCodeStart ClaudeCodeStop ClaudeCodeFocus ClaudeCodeSend ClaudeCodeDiffAccept ClaudeCodeDiffDeny; do
  echo "$OUT" | grep -q "$c" && pass "command :$c registered (after force-load)" || fail "command :$c missing (after force-load)"
done

echo
echo "=========================================="
echo "Results: $PASS passed, $FAIL failed"
echo "=========================================="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
