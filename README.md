[한국어](README.md) | [English](README.en.md)

# maku-clip

Claude Code용 스크린샷 분석 slash command.

캡처한 이미지를 `/clip`으로 목록 조회하고, 번호를 지정해 AI 분석을 요청할 수 있다.

## 설치

### 방법 1: 플러그인 (권장)

```
/plugin marketplace add gyuminlee-repo/maku-clip
/plugin install maku-clip@maku-clip
```

글로벌 설치되어 모든 프로젝트에서 `/clip`을 사용할 수 있다.

### 방법 2: 파일 복사

프로젝트 루트의 `.claude/` 디렉토리에 복사:

```bash
mkdir -p .claude/hooks .claude/commands

curl -fsSL https://raw.githubusercontent.com/gyuminlee-repo/maku-clip/master/.claude/hooks/clip.sh \
  -o .claude/hooks/clip.sh
curl -fsSL https://raw.githubusercontent.com/gyuminlee-repo/maku-clip/master/.claude/commands/clip.md \
  -o .claude/commands/clip.md

chmod +x .claude/hooks/clip.sh
```

### 방법 3: git clone 후 복사

```bash
git clone https://github.com/gyuminlee-repo/maku-clip.git /tmp/maku-clip
cp -r /tmp/maku-clip/.claude/hooks/clip.sh  your-project/.claude/hooks/
cp -r /tmp/maku-clip/.claude/commands/clip.md your-project/.claude/commands/
chmod +x your-project/.claude/hooks/clip.sh
rm -rf /tmp/maku-clip
```

## 사전 설정: 스크린샷 자동 저장

Windows에서 스크린샷이 파일로 자동 저장되도록 설정해야 한다.

1. **캡처 도구**(Snipping Tool) 앱을 열고 설정(⚙️)으로 이동
2. **"스크린샷 자동 저장"** 토글을 켠다
3. 저장 위치를 원하는 폴더로 변경한다 (예: `C:\_screenshots`)

> **WSL**: Windows 드라이브가 `/mnt/c/`로 자동 마운트되므로 추가 설정이 필요 없다.
> 예: `C:\_screenshots` → `/mnt/c/_screenshots`
>
> **DevContainer**: 컨테이너 내부에서 호스트 폴더에 직접 접근할 수 없다.
> `devcontainer.json`에 마운트 설정을 추가해야 한다:
>
> ```jsonc
> // .devcontainer/devcontainer.json
> {
>   "mounts": [
>     "source=/mnt/c/_screenshots,target=/mnt/c/_screenshots,type=bind,consistency=cached"
>   ]
> }
> ```
>
> 설정 후 **Rebuild Container**를 실행해야 적용된다.

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

## 파일 구조

```
.claude-plugin/
├── plugin.json            # 플러그인 매니페스트
└── marketplace.json       # 마켓플레이스 등록 정보
lib/
└── clip-core.sh           # 공통 로직 (두 hooks에서 source)
skills/
└── clip/SKILL.md          # /clip skill 정의 (플러그인용)
hooks/
└── clip.sh                # wrapper: 플러그인용 STATE_DIR 결정 → clip-core.sh
.claude/
├── hooks/clip.sh          # standalone: 파일 복사 설치용 (전체 로직 포함)
├── commands/clip.md       # /clip 커맨드 정의 (파일 복사 설치용)
└── state/clip-path        # 저장된 경로 (자동 생성, gitignore 대상)
```

- 플러그인 설치 시 상태 파일은 `~/.claude/state/`에 저장된다 (글로벌).
- 파일 복사 설치 시 상태 파일은 프로젝트 `.claude/state/`에 저장된다 (로컬).
