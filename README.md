# maku-clip

Claude Code용 스크린샷 분석 slash command.

캡처한 이미지를 `/clip`으로 목록 조회하고, 번호를 지정해 AI 분석을 요청할 수 있다.

## 설치

### 방법 1: 파일 복사

프로젝트 루트의 `.claude/` 디렉토리에 복사:

```bash
mkdir -p .claude/hooks .claude/commands

curl -fsSL https://raw.githubusercontent.com/gyuminlee-repo/maku-clip/master/.claude/hooks/clip.sh \
  -o .claude/hooks/clip.sh
curl -fsSL https://raw.githubusercontent.com/gyuminlee-repo/maku-clip/master/.claude/commands/clip.md \
  -o .claude/commands/clip.md

chmod +x .claude/hooks/clip.sh
```

### 방법 2: git clone 후 복사

```bash
git clone https://github.com/gyuminlee-repo/maku-clip.git /tmp/maku-clip
cp -r /tmp/maku-clip/.claude/hooks/clip.sh  your-project/.claude/hooks/
cp -r /tmp/maku-clip/.claude/commands/clip.md your-project/.claude/commands/
chmod +x your-project/.claude/hooks/clip.sh
rm -rf /tmp/maku-clip
```

## 사전 설정: 스크린샷 자동 저장

Windows에서 스크린샷이 파일로 자동 저장되도록 설정해야 한다.

1. **Snipping Tool** 앱을 열고 설정(⚙️)으로 이동
2. **"스크린샷 자동 저장"** 토글을 켠다
3. 저장 위치를 원하는 폴더로 변경한다 (예: `C:\_screenshots`)

> 이 폴더는 WSL/DevContainer에서 접근 가능해야 한다.
> WSL 기준 `/mnt/c/_screenshots`로 마운트된다.

## 첫 실행

```
/clip
```

스크린샷 폴더 경로를 물어본다. 한번만 설정하면 이후 자동으로 사용된다.

| 환경 | 경로 예시 |
|------|-----------|
| WSL | `/mnt/c/_screenshots` |
| DevContainer | 마운트된 스크린샷 폴더 경로 |
| 네이티브 Linux | `~/Pictures/Screenshots` |

## 사용법

### 기본

```
/clip              # 최근 10개 목록
/clip 1            # 1번 이미지 선택
/clip 1 3          # 1번, 3번 동시 선택
/clip 1-3          # 1~3번 동시 선택 (최대 5장)
/clip set-path     # 경로 재설정
/clip set-max 20   # 목록 표시 개수 변경 (기본 10)
```

### 이미지 + 자유 텍스트

번호 뒤에 자연어를 붙이면 해당 이미지를 맥락으로 Claude가 응답한다. 질문, 요청, 지시 등 어떤 텍스트든 가능.

```
/clip 1 이 에러 어떻게 고쳐?
/clip 2 이 UI 레이아웃 개선안 제안해줘
/clip 1-3 이 세 화면의 차이점 정리해줘
/clip 1 이 코드를 TypeScript로 변환해줘
/clip 이거 뭔 뜻이야
```

번호 없이 텍스트만 쓰면 가장 최근 이미지가 자동 선택된다.

## 환경변수

WSL/DevContainer 터미널 또는 `.bashrc`에서 설정한다.

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `CLIP_SCREENSHOTS_DIR` | 스크린샷 폴더 경로 오버라이드 | `clip-path` 설정값 |

```bash
export CLIP_SCREENSHOTS_DIR=/mnt/c/_screenshots
```

## 파일 구조

```
.claude/
├── hooks/clip.sh      # 스크린샷 스캔, 경로 관리
├── commands/clip.md   # /clip 커맨드 정의
└── state/clip-path    # 저장된 경로 (자동 생성, gitignore 권장)
```

`.claude/state/`는 사용자별 설정이 저장되므로 `.gitignore`에 추가하는 것을 권장한다.
