[한국어](README.md) | [English](README.en.md)

# maku-clip

Screenshot analysis slash command for Claude Code.

Browse captured images with `/clip` and select by number to request AI analysis.

## Installation

### Method 1: Plugin (Recommended)

```
/plugin marketplace add gyuminlee-repo/maku-clip
/plugin install maku-clip@maku-clip
```

Installed globally, making `/clip` available across all projects.

### Method 2: File Copy

Copy into the `.claude/` directory at your project root:

```bash
mkdir -p .claude/hooks .claude/commands

curl -fsSL https://raw.githubusercontent.com/gyuminlee-repo/maku-clip/master/.claude/hooks/clip.sh \
  -o .claude/hooks/clip.sh
curl -fsSL https://raw.githubusercontent.com/gyuminlee-repo/maku-clip/master/.claude/commands/clip.md \
  -o .claude/commands/clip.md

chmod +x .claude/hooks/clip.sh
```

### Method 3: git clone

```bash
git clone https://github.com/gyuminlee-repo/maku-clip.git /tmp/maku-clip
cp -r /tmp/maku-clip/.claude/hooks/clip.sh  your-project/.claude/hooks/
cp -r /tmp/maku-clip/.claude/commands/clip.md your-project/.claude/commands/
chmod +x your-project/.claude/hooks/clip.sh
rm -rf /tmp/maku-clip
```

## Prerequisites: Auto-Save Screenshots

Configure Windows to automatically save screenshots as files.

1. Open the **Snipping Tool** app and go to Settings
2. Enable **"Automatically save screenshots"**
3. Change the save location to a folder of your choice (e.g., `C:\_screenshots`)

> **WSL**: Windows drives are automatically mounted at `/mnt/c/`, so no extra configuration is needed.
> e.g., `C:\_screenshots` → `/mnt/c/_screenshots`
>
> **DevContainer**: The container cannot directly access host folders.
> Add a mount configuration to `devcontainer.json`:
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
> **Rebuild Container** after making this change.

## First Run

```
/clip
```

The command will ask for the screenshot folder path. Only needs to be set once.

| Environment | Example Path |
|-------------|--------------|
| WSL | `/mnt/c/_screenshots` |
| DevContainer | Mounted screenshot folder path |
| Native Linux | `~/Pictures/Screenshots` |

## Usage

### Basic

```
/clip              # List recent 10 images
/clip 1            # Select image #1
/clip 1 3          # Select #1 and #3
/clip 1-3          # Select #1 through #3 (max 5)
/clip set-path     # Reconfigure path
/clip set-max 20   # Change list size (default 10)
```

### Image + Free Text

Append natural language after a number to have Claude analyze the image in context. Any text works — questions, requests, instructions.

```
/clip 1 How do I fix this error?
/clip 2 Suggest improvements for this UI layout
/clip 1-3 Compare these three screens
/clip 1 Convert this code to TypeScript
/clip What does this mean?
```

If no number is given, the most recent image is automatically selected.

## File Structure

```
.claude-plugin/
├── plugin.json            # Plugin manifest
└── marketplace.json       # Marketplace registration
lib/
└── clip-core.sh           # Shared logic (sourced by both hooks)
skills/
└── clip/SKILL.md          # /clip skill definition (plugin)
hooks/
└── clip.sh                # Wrapper: plugin STATE_DIR → clip-core.sh
.claude/
├── hooks/clip.sh          # Standalone: file copy install (full logic)
├── commands/clip.md       # /clip command definition (file copy install)
└── state/clip-path        # Saved path (auto-generated, gitignored)
```

- Plugin install stores state files in `~/.claude/state/` (global).
- File copy install stores state files in the project `.claude/state/` (local).
