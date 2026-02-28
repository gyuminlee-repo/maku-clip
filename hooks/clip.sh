#!/bin/bash
# 플러그인 설치용 wrapper — 공통 로직은 lib/clip-core.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ "$PLUGIN_ROOT" == *".claude/plugins/cache"* ]] || [[ "$PLUGIN_ROOT" == *".claude/plugins"* ]]; then
    STATE_DIR="$HOME/.claude/state"
else
    STATE_DIR="$PLUGIN_ROOT/.claude/state"
fi
export STATE_DIR

# shellcheck source=../lib/clip-core.sh
source "$PLUGIN_ROOT/lib/clip-core.sh" "$@"
