#!/bin/bash
set -euo pipefail

MAX_SHOW=10
MAX_SELECT=5

# 프로젝트 루트를 스크립트 위치 기준으로 계산 (.claude/hooks/clip.sh → 2단계 상위)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/.claude/state/clip-path"

# --- 경로 설정 명령 (경로 로드보다 먼저 처리) ---
if [ "${1:-}" = "set-path" ]; then
    NEW_PATH="${2:-}"
    if [ -z "$NEW_PATH" ]; then
        echo "사용법: clip.sh set-path /your/screenshots/path" >&2
        exit 1
    fi
    if [ ! -d "$NEW_PATH" ]; then
        echo "폴더가 존재하지 않습니다: $NEW_PATH" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "$NEW_PATH" > "$CONFIG_FILE"
    echo "스크린샷 경로 설정 완료: $NEW_PATH"
    exit 0
fi

# --- 스크린샷 경로 로드 ---
if [ -n "${CLIP_SCREENSHOTS_DIR:-}" ]; then
    SCREENSHOTS_DIR="$CLIP_SCREENSHOTS_DIR"
elif [ -f "$CONFIG_FILE" ]; then
    SCREENSHOTS_DIR=$(cat "$CONFIG_FILE" | tr -d '\n\r')
else
    echo "스크린샷 경로가 설정되지 않았습니다." >&2
    echo "설정 방법: /clip 실행 시 안내를 따르세요." >&2
    exit 2
fi

if [ ! -d "$SCREENSHOTS_DIR" ]; then
    echo "설정된 경로가 존재하지 않습니다: $SCREENSHOTS_DIR" >&2
    echo "경로를 확인하거나 다시 설정하세요." >&2
    exit 2
fi

# --- 파일 스캔 ---
mapfile -t FILES < <(find "$SCREENSHOTS_DIR" -maxdepth 1 \( -name "Screenshot*.png" -o -name "스크린샷*.png" -o -name "*.png" \) -printf '%T@\t%p\n' 2>/dev/null | sort -rn | head -n "$MAX_SHOW" | cut -f2)

if [ ${#FILES[@]} -eq 0 ]; then
    echo "이미지가 없습니다: $SCREENSHOTS_DIR" >&2
    exit 1
fi

# --- 인자 파싱 ---
ARGS=("$@")
[ ${#ARGS[@]} -eq 0 ] && ARGS=("list")

# --- 번호 파싱: "1 3 5", "1-3", "2 4-5" 혼합 지원 ---
parse_selections() {
    local -a selections=()
    for arg in "$@"; do
        if [[ "$arg" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"
            if [ "$start" -gt "$end" ]; then
                echo "잘못된 범위: $arg" >&2
                return 1
            fi
            for ((i=start; i<=end; i++)); do
                selections+=("$i")
            done
        elif [[ "$arg" =~ ^[0-9]+$ ]]; then
            selections+=("$arg")
        else
            return 2  # 숫자가 아닌 인자
        fi
    done

    if [ ${#selections[@]} -gt "$MAX_SELECT" ]; then
        echo "최대 ${MAX_SELECT}장까지 선택 가능합니다. (요청: ${#selections[@]}장)" >&2
        return 1
    fi

    for num in "${selections[@]}"; do
        local idx=$((num - 1))
        if [ "$idx" -lt 0 ] || [ "$idx" -ge ${#FILES[@]} ]; then
            echo "잘못된 번호: $num (1~${#FILES[@]} 범위)" >&2
            return 1
        fi
        echo "${FILES[$idx]}"
    done
}

# --- 메인 분기 ---
case "${ARGS[0]}" in
    list)
        echo "📁 $SCREENSHOTS_DIR"
        echo ""
        for i in "${!FILES[@]}"; do
            NUM=$((i + 1))
            BASENAME=$(basename "${FILES[$i]}")
            SIZE=$(du -h "${FILES[$i]}" 2>/dev/null | cut -f1)
            MTIME=$(stat -c '%y' "${FILES[$i]}" 2>/dev/null | cut -d'.' -f1)
            echo "${NUM}) [${MTIME}] ${BASENAME} (${SIZE})"
        done
        ;;
    latest)
        echo "${FILES[0]}"
        ;;
    get-path)
        echo "$SCREENSHOTS_DIR"
        ;;
    *)
        if parse_selections "${ARGS[@]}"; then
            :
        else
            RET=$?
            if [ "$RET" -eq 2 ]; then
                echo "${FILES[0]}"
            else
                exit 1
            fi
        fi
        ;;
esac
