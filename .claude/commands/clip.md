---
description: "클립보드 이미지 분석. Win+Shift+S 캡처 이미지 목록 조회 및 분석."
---
입력: $ARGUMENTS

스크린샷 이미지를 목록 조회하고 분석한다.

## 첫 실행: 경로 설정 확인
1. `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/clip.sh" list`를 실행한다.
2. **exit code 2** (경로 미설정)인 경우:
   - 사용자에게 스크린샷 저장 폴더 경로를 질문한다:
     "스크린샷이 저장되는 폴더 경로를 알려주세요. (예: /mnt/c/_screenshots, /workspaces/screenshots)"
   - 경로를 받으면 `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/clip.sh" set-path <경로>`를 실행한다.
   - 성공 시 다시 list를 실행하여 진행한다.
3. 정상이면 아래 분기를 따른다.

## 입력이 비어있거나 "list"인 경우
1. `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/clip.sh" list`를 실행한다.
2. 출력된 목록을 사용자에게 보여준다.
3. 안내를 추가한다:
   - "번호를 입력하면 해당 이미지를 분석합니다. (예: /clip 1)"
   - "다중 선택: /clip 1 3 또는 /clip 1-3 (최대 5장)"

## 입력 파싱 규칙
입력에서 숫자/범위 부분과 텍스트 부분을 분리한다:
- 숫자/범위: `1`, `1 3`, `1-3`, `2 4-5` 등 (앞쪽에 위치)
- 텍스트: 숫자/범위 뒤에 오는 나머지 부분 (분석 요청)
- 예: `1-3 이 에러들 비교해줘` → 숫자부분=`1-3`, 텍스트=`이 에러들 비교해줘`

## 입력이 숫자/범위만 있는 경우 (예: "1", "1 3", "1-3", "2 4-5")
1. `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/clip.sh" <숫자/범위>`를 실행하여 이미지 경로를 얻는다.
2. 실패 시 에러 메시지를 전달하고 중단한다.
3. 성공 시 반환된 각 경로의 이미지를 Read 도구로 모두 읽고 한국어로 내용을 설명한다.
   - 여러 이미지인 경우 각각 번호를 붙여 설명한다.

## 입력이 숫자/범위 + 텍스트인 경우 (예: "1-3 이 에러들 비교해줘", "2 이거 뭐야")
1. 숫자/범위 부분으로 `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/clip.sh" <숫자/범위>`를 실행한다.
2. 실패 시 에러 메시지를 전달하고 중단한다.
3. 성공 시 반환된 각 경로의 이미지를 Read 도구로 모두 읽는다.
4. 텍스트 부분의 요청에 맞춰 이미지를 분석하고 한국어로 응답한다.

## 입력이 텍스트만 있는 경우 (예: "이 에러 뭐야")
1. `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/clip.sh" latest`를 실행하여 최신 이미지 경로를 얻는다.
2. 이미지를 Read 도구로 읽는다.
3. 입력 텍스트의 요청에 맞춰 분석하고 한국어로 응답한다.

## 경로 재설정
입력이 "set-path" 또는 "경로 변경"인 경우:
- 사용자에게 새 경로를 질문하고 `clip.sh set-path <경로>`를 실행한다.

## 목록 표시 개수 변경
입력이 "set-max"인 경우:
- `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/clip.sh" set-max <숫자>`를 실행한다.
- 예: `/clip set-max 20` → 이후 `/clip` 목록에 최근 20개가 표시된다.
