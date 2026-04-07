#!/usr/bin/env bash
set -euo pipefail

NORG_REVISION="6348056b999f06c2c7f43bb0a5aa7cfde5302712"
NORG_URL="https://github.com/nvim-neorg/tree-sitter-norg/archive/${NORG_REVISION}.tar.gz"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

need_cmd curl
need_cmd tar
need_cmd luarocks
need_cmd lua
need_cmd gcc
need_cmd g++
need_cmd nvim

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

echo "Installing local LuaRocks build dependency..."
luarocks install --local luarocks-build-treesitter-parser-cpp >/dev/null

echo "Downloading tree-sitter-norg ${NORG_REVISION}..."
curl -fsSL "$NORG_URL" -o "$tmpdir/tree-sitter-norg.tar.gz"
mkdir -p "$tmpdir/src"
tar -xzf "$tmpdir/tree-sitter-norg.tar.gz" -C "$tmpdir/src"

src_dir="$(find "$tmpdir/src" -maxdepth 1 -mindepth 1 -type d | head -n 1)"
if [ -z "$src_dir" ]; then
  echo "failed to unpack tree-sitter-norg source" >&2
  exit 1
fi

cat >"$src_dir/tree-sitter-norg-scm-1.rockspec" <<'EOF'
package = "tree-sitter-norg"
version = "scm-1"
rockspec_format = "3.0"

source = {
  url = "git://github.com/nvim-neorg/tree-sitter-norg",
}

description = {
  summary = "tree-sitter parser for norg",
  homepage = "https://github.com/nvim-neorg/tree-sitter-norg",
  license = "MIT",
}

dependencies = {
  "lua >= 5.1",
}

build_dependencies = {
  "luarocks-build-treesitter-parser-cpp ~> 2",
}

build = {
  type = "treesitter-parser-cpp",
  lang = "norg",
  sources = { "src/parser.c", "src/scanner.cc" },
}
EOF

echo "Building norg parser..."
(
  cd "$src_dir"
  CXX=g++ luarocks make --local tree-sitter-norg-scm-1.rockspec >/dev/null
)

parser_dir="$(nvim --headless "+lua io.write(vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'parser'))" +qa)"
mkdir -p "$parser_dir"
cp "$HOME/.luarocks/lib/lua/5.1/parser/norg.so" "$parser_dir/norg.so"

echo "Ensuring norg_meta parser is installed..."
nvim --headless "+TSInstall norg_meta" +qa >/dev/null

echo "Installed:"
echo "  $parser_dir/norg.so"
echo "  $parser_dir/norg_meta.so"
