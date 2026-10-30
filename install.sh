#!/bin/sh
# cxtify installer for macOS and Linux.
#   curl -fsSL https://cxtify.com/install.sh | sh
# Env: CXTIFY_VERSION (default latest), CXTIFY_INSTALL_DIR (default /usr/local/bin if writable, else ~/.local/bin)
set -eu

REPO="cxtify/cxtify"
VERSION="${CXTIFY_VERSION:-latest}"

os=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$os" in
  linux|darwin) ;;
  *) echo "cxtify: unsupported OS '$os' (use install.ps1 on Windows)" >&2; exit 1 ;;
esac
arch=$(uname -m)
case "$arch" in
  x86_64|amd64) arch=amd64 ;;
  arm64|aarch64) arch=arm64 ;;
  *) echo "cxtify: unsupported architecture '$arch'" >&2; exit 1 ;;
esac

if [ "$VERSION" = "latest" ]; then
  url="https://github.com/$REPO/releases/latest/download/cxtify_${os}_${arch}.tar.gz"
else
  url="https://github.com/$REPO/releases/download/${VERSION}/cxtify_${os}_${arch}.tar.gz"
fi

dir="${CXTIFY_INSTALL_DIR:-}"
if [ -z "$dir" ]; then
  if [ -d /usr/local/bin ] && [ -w /usr/local/bin ]; then dir=/usr/local/bin; else dir="$HOME/.local/bin"; fi
fi
mkdir -p "$dir"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $url"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$url" -o "$tmp/cxtify.tar.gz"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$tmp/cxtify.tar.gz" "$url"
else
  echo "cxtify: need curl or wget" >&2; exit 1
fi
tar -xzf "$tmp/cxtify.tar.gz" -C "$tmp"
install -m 0755 "$tmp/cxtify" "$dir/cxtify"
ln -sf "$dir/cxtify" "$dir/ctxify"
echo "Installed $("$dir/cxtify" version) to $dir/cxtify (alias: ctxify)"

"$dir/cxtify" skill install || echo "cxtify: could not install the Claude Code skill; run 'cxtify skill install' later" >&2

case ":$PATH:" in
  *":$dir:"*) ;;
  *) echo ""; echo "Add $dir to your PATH, e.g.:"; echo "  export PATH=\"$dir:\$PATH\"" ;;
esac

echo ""
echo "Next: cxtify login"
echo "      cd <project> && cxtify link <topic>"
