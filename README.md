# maku-clip

Claude Code용 스크린샷 분석 slash command.

캡처한 이미지를 `/clip`으로 목록 조회하고, 번호를 지정해 AI 분석을 요청할 수 있다.

## 설치

프로젝트 루트에서:

```bash
# hooks
mkdir -p .claude/hooks .claude/commands
curl -fsSL https://raw.githubusercontent.com/gyuminlee-repo/maku-clip/main/.claude/hooks/clip.sh -o .claude/hooks/clip.sh
curl -fsSL https://raw.githubusercontent.com/gyuminlee-repo/maku-clip/main/.claude/commands/clip.md -o .claude/commands/clip.md
chmod +x .claude/hooks/clip.sh
```

## 첫 실행

```
/clip
```

스크린샷 폴더 경로를 물어본다. 한번만 설정하면 이후 자동으로 사용된다.

| 환경 | 경로 예시 |
|------|-----------|
| WSL | `/mnt/c/_screenshots` |
| DevContainer | `/workspaces/screenshots` |
| 네이티브 Linux | `~/Pictures/Screenshots` |
| 커스텀 | 아무 경로나 지정 가능 |

## 사용법

```
/clip              # 최근 10개 목록
/clip 1            # 1번 이미지 분석
/clip 1 3          # 1번, 3번 동시 분석
/clip 1-3          # 1~3번 동시 분석
/clip 2 이거 뭐야   # 2번 이미지 + 텍스트 요청
/clip 1-3 비교해줘  # 1~3번 + 텍스트 요청
/clip 이 에러 뭐야  # 최신 1장 + 텍스트 요청
/clip set-path     # 경로 재설정
```

최대 5장까지 동시 선택 가능.

## 환경변수

`CLIP_SCREENSHOTS_DIR`로 경로를 임시 오버라이드할 수 있다:

```bash
export CLIP_SCREENSHOTS_DIR=/other/path
```

## 파일 구조

```
.claude/
├── hooks/clip.sh      # 스크린샷 스캔, 경로 관리
├── commands/clip.md   # /clip 커맨드 정의
└── state/clip-path    # 저장된 경로 (자동 생성, gitignore 권장)
```

## 이름

마메(マメ) + 쿠로(クロ) = MAKU
