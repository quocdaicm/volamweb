#!/bin/bash
# Gom file game vào ios/Game và chuyển sang chế độ OFFLINE (tắt đăng nhập/chat Supabase)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DST="$ROOT/ios/Game"
rm -rf "$DST"; mkdir -p "$DST"

# Chép các file/thư mục ở gốc repo (bỏ phần chỉ dành cho server, test, CI)
SKIP=" .git .github ios __MACOSX server.js start.sh start.command NET_SETUP.sql .gitignore .DS_Store Thumbs.db robots.txt.html "
for item in "$ROOT"/* "$ROOT"/.[!.]*; do
  [ -e "$item" ] || continue
  name="$(basename "$item")"
  case "$SKIP" in *" $name "*) continue ;; esac
  case "$name" in test_*.js) continue ;; esac
  cp -R "$item" "$DST/"
done

# Tắt đăng nhập + chat online
CFG="$DST/js/chatcfg.js"
sed -i.bak 's/window\.AUTH_ENABLED[[:space:]]*=[[:space:]]*true/window.AUTH_ENABLED = false/' "$CFG"
rm -f "$CFG.bak"
grep -q 'window.AUTH_ENABLED = false' "$CFG" || { echo "Không tắt được AUTH_ENABLED"; exit 1; }

# Kiểm tra mọi <script src> trong index.html đều có file
missing=0
for f in $(grep -oE '<script src="[^"]+"' "$DST/index.html" | sed 's/<script src="//;s/"$//'); do
  [ -f "$DST/$f" ] || { echo "THIẾU: $f"; missing=1; }
done
[ $missing -eq 0 ] || exit 1
echo "OK: $(find "$DST" -type f | wc -l) file, $(du -sh "$DST" | cut -f1)"
