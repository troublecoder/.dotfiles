# Chezmoi 다중 플랫폼 전환 구현 계획

> **에이전트 작업자용:** REQUIRED SUB-SKILL: 이 계획을 작업 단위로 구현할 때 `superpowers:subagent-driven-development`를 사용한다. 모든 단계는 체크박스(`- [ ]`)로 추적한다.

**목표:** 기존 GNU Stow 구조를 제거하고 `~/.dotfiles`를 단일 chezmoi 소스로 사용하여 Windows, macOS, Linux에 맞는 설정을 배포한다.

**구조:** 저장소 루트의 `.chezmoiroot`가 `home/`을 소스 상태로 지정하고, `.chezmoiignore`와 Go 템플릿이 운영체제 차이를 처리한다. 외부 도구는 Unix 전용 `run_once_before_` 스크립트가 최초 한 번 설치하며, Claude 지침을 적용한 뒤 운영체제별 `run_after_` 스크립트가 Codex 지침 경로를 하드링크로 만든다.

**기술 스택:** chezmoi v2.71 이상, POSIX sh, PowerShell, Zsh, Git, jq, Ghostty 내장 설정 검증기

## 전역 제약

- 모든 새 문서, 안내 문구, 테스트 메시지와 코드 주석은 한국어로 작성한다.
- chezmoi 소스 디렉터리는 모든 플랫폼에서 `~/.dotfiles`이다.
- 기존 Git 저장소를 재사용하며 새 Git 저장소를 만들지 않는다.
- `CLAUDE.md`만 지침 원본으로 두고 `~/.claude/CLAUDE.md`를 배포한 뒤 `~/.codex/AGENTS.md`를 하드링크로 만든다.
- `~/.agents`에서는 `skills/`만 관리하고 `AGENTS.md`와 `.skill-lock.json`은 관리하지 않는다.
- `~/.cc-switch`에서는 `settings.json`만 관리하고 DB, OAuth, 로그, 백업과 skills는 관리하지 않는다.
- Windows는 Zed, 공통 에이전트 설정, CC Switch, Windows Terminal Stable만 적용한다.
- macOS는 Unix 공통 설정과 부트스트랩을 적용하되 Neovim 바이너리는 설치하지 않는다.
- Linux는 Unix 공통 설정과 아키텍처별 Neovim 바이너리를 설치한다.
- Ghostty 선택 색은 배경 `#cba6f7`, 글자 `#1e1e2e`이며 `copy-on-select = clipboard`를 유지한다.
- 삭제 예정인 루트 `settings.json`과 `config.toml`의 인증 정보는 새 소스에 복사하지 않는다.
- 기존 사용자 변경을 되돌리거나 관련 없는 파일을 수정하지 않는다.

---

### 작업 1: chezmoi 소스 구조와 플랫폼별 대상

**파일:**
- 생성: `.chezmoiroot`
- 생성: `home/.chezmoi.toml.tmpl`
- 생성: `home/.chezmoiignore`
- 생성: `home/dot_zprofile`
- 생성: `home/dot_zshrc.tmpl`
- 생성: `home/dot_tmux.conf.local`
- 생성: `home/symlink_dot_tmux.conf`
- 생성: `home/dot_oh-my-zsh/custom/themes/symlink_spaceship.zsh-theme`
- 생성: `home/dot_agents/skills/find-skills/SKILL.md`
- 생성: `home/dot_cc-switch/private_settings.json`
- 생성: `home/dot_claude/CLAUDE.md.tmpl`
- 생성: `home/dot_config/spaceship.zsh`
- 생성: `home/dot_config/ghostty/config.ghostty.tmpl`
- 생성: `home/dot_config/ghostty/themes/catppuccin-mocha.conf`
- 생성: `home/dot_config/zed/keymap.json`
- 생성: `home/dot_config/zed/settings.json.tmpl`
- 생성: `home/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`
- 생성: `tests/test_chezmoi.sh`
- 삭제: `config.toml`, `settings.json`, `tmux/`, `zed/`, `zsh/`, `windows_terminal.json`

**인터페이스:**
- 입력: 현재 Stow 파일, `~/.agents/skills/find-skills/SKILL.md`, `~/.cc-switch/settings.json`, 저장소 루트 `CLAUDE.md`
- 출력: `chezmoi --source <저장소> managed`가 운영체제별 정확한 대상 목록을 계산하는 소스 상태

- [ ] **1단계: 플랫폼 대상 검증을 먼저 작성한다**

`tests/test_chezmoi.sh`에 다음 동작을 구현한다.

```sh
#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

fail() {
  printf '실패: %s\n' "$*" >&2
  exit 1
}

managed() {
  os=$1
  arch=$2
  destination="$tmp_dir/$os-$arch"
  mkdir -p "$destination"
  chezmoi --source "$repo_dir" --destination "$destination" \
    --override-data "{\"chezmoi\":{\"os\":\"$os\",\"arch\":\"$arch\"}}" \
    managed
}

assert_has() {
  list=$1
  path=$2
  printf '%s\n' "$list" | grep -Fx "$path" >/dev/null ||
    fail "관리 대상에 $path 경로가 없습니다."
}

assert_lacks() {
  list=$1
  path=$2
  if printf '%s\n' "$list" | grep -Fx "$path" >/dev/null; then
    fail "관리하면 안 되는 $path 경로가 포함됐습니다."
  fi
}

windows=$(managed windows amd64)
darwin=$(managed darwin arm64)
linux=$(managed linux amd64)

for list in "$windows" "$darwin" "$linux"; do
  assert_has "$list" ".claude/CLAUDE.md"
  assert_has "$list" ".config/zed/settings.json"
  assert_has "$list" ".cc-switch/settings.json"
  assert_has "$list" ".agents/skills/find-skills/SKILL.md"
done

assert_has "$windows" "AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
assert_lacks "$windows" ".zshrc"
assert_lacks "$windows" ".config/ghostty/config.ghostty"
assert_has "$darwin" ".zshrc"
assert_has "$darwin" ".config/ghostty/config.ghostty"
assert_lacks "$darwin" "AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
assert_has "$linux" ".zshrc"
assert_has "$linux" ".config/ghostty/config.ghostty"
assert_lacks "$linux" "AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

printf '플랫폼별 관리 대상 검증을 통과했습니다.\n'
```

- [ ] **2단계: 테스트가 예상한 이유로 실패하는지 확인한다**

실행:

```sh
sh tests/test_chezmoi.sh
```

예상 결과: `.chezmoiroot`와 `home/` 소스 상태가 아직 없어 관리 대상 검증이 실패한다.

- [ ] **3단계: 최소 chezmoi 소스 구조를 구현한다**

다음 특수 파일을 정확히 생성한다.

`.chezmoiroot`:

```text
home
```

`home/.chezmoi.toml.tmpl`:

```toml
sourceDir = {{ joinPath .chezmoi.homeDir ".dotfiles" | quote }}
```

`home/.chezmoiignore`:

```text
{{ if eq .chezmoi.os "windows" }}
.zprofile
.zshrc
.tmux.conf
.tmux.conf.local
.oh-my-zsh
.config/spaceship.zsh
.config/ghostty
{{ else }}
AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
{{ end }}
```

기존 설정 파일은 내용 변경을 최소화하여 대응하는 `home/` 경로로 옮긴다. Zed는 사용자 이동본인 `zsh/.config/zed/`를 사용한다. Ghostty 설정에는 아래 값을 유지한다.

```text
selection-background = #cba6f7
selection-foreground = #1e1e2e
copy-on-select = clipboard
clipboard-write = allow
```

`dot_zshrc.tmpl`의 로컬 Neovim `PATH`는 Linux에서만 렌더링한다.
`dot_config/ghostty/config.ghostty.tmpl`의 `macos-*`, Display P3,
macOS 아이콘과 자동 업데이트 설정은 macOS에서만 렌더링한다.
`dot_config/zed/settings.json.tmpl`의 하드코딩된 Kotlin 언어 서버 경로는
Windows에서만 렌더링하고 `.chezmoi.homeDir`을 기준으로 생성한다.

`home/dot_claude/CLAUDE.md.tmpl`은 단일 원본을 그대로 포함한다.

```gotemplate
{{- include (joinPath .chezmoi.workingTree "CLAUDE.md") -}}
```

`home/symlink_dot_tmux.conf`:

```text
.tmux/.tmux.conf
```

`home/dot_oh-my-zsh/custom/themes/symlink_spaceship.zsh-theme`:

```text
spaceship-prompt/spaceship.zsh-theme
```

- [ ] **4단계: 플랫폼별 렌더링과 설정 문법을 검증한다**

실행:

```sh
sh tests/test_chezmoi.sh
jq empty home/dot_cc-switch/private_settings.json
jq empty home/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
git diff --check
```

예상 결과: 모든 명령이 종료 코드 0으로 끝난다.

- [ ] **5단계: 작업을 커밋한다**

```sh
git add .chezmoiroot home tests/test_chezmoi.sh
git add -u config.toml settings.json tmux zed zsh windows_terminal.json
git commit -m "refactor: Stow 설정을 chezmoi 소스로 전환"
```

### 작업 2: Unix 부트스트랩과 다중 플랫폼 하드링크

**파일:**
- 생성: `home/run_once_before_10-bootstrap.sh.tmpl`
- 생성: `home/run_after_90-link-agent-instructions.sh.tmpl`
- 생성: `home/run_after_90-link-agent-instructions.ps1.tmpl`
- 수정: `tests/test_chezmoi.sh`

**인터페이스:**
- 입력: 작업 1이 배포하는 `~/.claude/CLAUDE.md`
- 출력: macOS/Linux의 외부 셸 도구와 모든 플랫폼의 `~/.codex/AGENTS.md` 하드링크

- [ ] **1단계: 부트스트랩 및 하드링크 실패 검증을 추가한다**

`tests/test_chezmoi.sh`에 다음 검사를 추가한다.

```sh
render_script() {
  os=$1
  arch=$2
  file=$3
  chezmoi --source "$repo_dir" \
    --override-data "{\"chezmoi\":{\"os\":\"$os\",\"arch\":\"$arch\"}}" \
    execute-template --file "$repo_dir/home/$file"
}

windows_bootstrap=$(render_script windows amd64 run_once_before_10-bootstrap.sh.tmpl)
[ -z "$windows_bootstrap" ] || fail "Windows 부트스트랩은 비어 있어야 합니다."

darwin_bootstrap=$(render_script darwin arm64 run_once_before_10-bootstrap.sh.tmpl)
printf '%s' "$darwin_bootstrap" | grep -F "LazyVim/starter" >/dev/null ||
  fail "macOS 부트스트랩에 LazyVim 설치가 없습니다."
if printf '%s' "$darwin_bootstrap" | grep -F "nvim-linux-" >/dev/null; then
  fail "macOS에서 Linux Neovim을 설치하면 안 됩니다."
fi

linux_bootstrap=$(render_script linux amd64 run_once_before_10-bootstrap.sh.tmpl)
printf '%s' "$linux_bootstrap" | grep -F "nvim-linux-x86_64" >/dev/null ||
  fail "Linux amd64 Neovim 자산이 없습니다."

unix_link=$(render_script darwin arm64 run_after_90-link-agent-instructions.sh.tmpl)
printf '%s' "$unix_link" | grep -F 'ln "$source_file" "$target_file"' >/dev/null ||
  fail "Unix 하드링크 생성 명령이 없습니다."

windows_link=$(render_script windows amd64 run_after_90-link-agent-instructions.ps1.tmpl)
printf '%s' "$windows_link" | grep -F "New-Item -ItemType HardLink" >/dev/null ||
  fail "Windows 하드링크 생성 명령이 없습니다."
```

- [ ] **2단계: 새 검증이 파일 부재로 실패하는지 확인한다**

```sh
sh tests/test_chezmoi.sh
```

예상 결과: 세 스크립트 파일이 없어 실패한다.

- [ ] **3단계: 멱등 부트스트랩을 구현한다**

스크립트는 Windows에서 빈 문자열을 렌더링한다. macOS와 Linux에서는 `git`, `curl`, `tar`를 검사하고 다음 저장소를 대상이 없을 때만 `--depth=1`로 복제한다.

```text
https://github.com/ohmyzsh/ohmyzsh.git
https://github.com/spaceship-prompt/spaceship-prompt.git
https://github.com/gpakosz/.tmux.git
https://github.com/LazyVim/starter.git
```

Linux Neovim 자산은 chezmoi 아키텍처에 따라 정확히 다음을 사용한다.

```text
amd64 -> nvim-linux-x86_64.tar.gz
arm64 -> nvim-linux-arm64.tar.gz
```

시스템 Neovim이 없거나 `0.8.1`보다 오래됐을 때만 임시 디렉터리에 다운로드한 뒤 `~/.local/opt/<자산 디렉터리>`로 이동한다. 실패 시 기존 설치 디렉터리를 먼저 삭제하지 않는다.

- [ ] **4단계: Unix 및 Windows 하드링크 스크립트를 구현한다**

Unix 스크립트는 `test source -ef target`으로 기존 링크를 확인하고, 다른 파일이면서 내용이 다르면 한국어 오류로 중단한다. 내용이 같으면 기존 대상을 지우고 `ln`으로 다시 만든다.

Windows PowerShell 스크립트는 원본과 대상 내용을 `Get-FileHash`로 비교한다. 대상이 있으면 같은 내용일 때만 제거하고 다음 명령으로 하드링크를 만든다.

```powershell
New-Item -ItemType HardLink -Path $targetFile -Target $sourceFile | Out-Null
```

두 스크립트는 각자 대상 운영체제가 아니면 빈 문자열로 렌더링한다.

- [ ] **5단계: 스크립트 렌더링과 실제 Unix 하드링크를 검증한다**

```sh
sh tests/test_chezmoi.sh
tmp_home=$(mktemp -d)
mkdir -p "$tmp_home/.claude" "$tmp_home/.codex"
cp CLAUDE.md "$tmp_home/.claude/CLAUDE.md"
HOME="$tmp_home" sh -c "$(chezmoi --source "$PWD" --override-data '{\"chezmoi\":{\"os\":\"darwin\",\"arch\":\"arm64\"}}' execute-template --file home/run_after_90-link-agent-instructions.sh.tmpl)"
test "$tmp_home/.claude/CLAUDE.md" -ef "$tmp_home/.codex/AGENTS.md"
rm -rf "$tmp_home"
```

예상 결과: 모든 명령이 종료 코드 0으로 끝나고 두 대상이 같은 inode를 사용한다.

- [ ] **6단계: 작업을 커밋한다**

```sh
git add home/run_* tests/test_chezmoi.sh
git commit -m "feat: 운영체제별 부트스트랩과 지침 하드링크 추가"
```

### 작업 3: 한국어 README, 통합 검증, 현재 홈 적용

**파일:**
- 생성: `README.md`
- 수정: `tests/test_chezmoi.sh`
- 수정: `~/.config/chezmoi/chezmoi.toml` (chezmoi init 결과, 저장소 밖)
- 제거: 기존 Stow가 만든 홈 심볼릭 링크

**인터페이스:**
- 입력: 작업 1과 2의 완성된 chezmoi 소스 상태
- 출력: 문서화된 설치·적용 흐름과 chezmoi가 실제 관리하는 현재 홈

- [ ] **1단계: README 요구사항 검증을 추가한다**

`tests/test_chezmoi.sh`에 다음 검사를 추가한다.

```sh
[ -f "$repo_dir/README.md" ] || fail "README.md가 없습니다."
grep -F 'chezmoi --source "$HOME/.dotfiles" init' "$repo_dir/README.md" >/dev/null ||
  fail "현재 저장소 등록 명령이 README에 없습니다."
grep -F 'git clone https://github.com/troublecoder/.dotfiles.git "$HOME/.dotfiles"' "$repo_dir/README.md" >/dev/null ||
  fail "새 머신 복제 명령이 README에 없습니다."
grep -F 'chezmoi diff' "$repo_dir/README.md" >/dev/null ||
  fail "적용 전 diff 명령이 README에 없습니다."
grep -F 'chezmoi update' "$repo_dir/README.md" >/dev/null ||
  fail "업데이트 명령이 README에 없습니다."
```

- [ ] **2단계: README 부재로 검증이 실패하는지 확인한다**

```sh
sh tests/test_chezmoi.sh
```

예상 결과: `README.md`가 없어 실패한다.

- [ ] **3단계: 한국어 README를 작성한다**

README에는 다음 순서와 명령을 그대로 포함한다.

```sh
# 현재 ~/.dotfiles 등록
chezmoi --source "$HOME/.dotfiles" init
chezmoi doctor
chezmoi diff
chezmoi apply --verbose

# 새 머신에서 기존 저장소 사용
git clone https://github.com/troublecoder/.dotfiles.git "$HOME/.dotfiles"
chezmoi --source "$HOME/.dotfiles" init
chezmoi diff
chezmoi apply --verbose

# 원격 변경 가져오기 및 적용
chezmoi update
```

Windows, macOS, Linux의 설치 방법, 플랫폼별 관리 대상, 부트스트랩 차이, 하드링크 동작, 관리 제외 파일과 인증 정보 금지 경고를 한국어로 설명한다.

- [ ] **4단계: 저장소 전체 검증을 실행한다**

```sh
sh tests/test_chezmoi.sh
zsh -n <(chezmoi --source "$PWD" --override-data '{\"chezmoi\":{\"os\":\"darwin\",\"arch\":\"arm64\"}}' cat ~/.zshrc)
git diff --check
```

Ghostty가 설치된 macOS에서는 다음도 실행한다.

```sh
tmp_home=$(mktemp -d)
chezmoi --source "$PWD" --destination "$tmp_home" --exclude scripts apply
/Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config --config-file="$tmp_home/.config/ghostty/config.ghostty"
rm -rf "$tmp_home"
```

예상 결과: 모든 검증이 종료 코드 0으로 끝난다.

- [ ] **5단계: 문서와 최종 테스트를 커밋한다**

```sh
git add README.md tests/test_chezmoi.sh
git commit -m "docs: chezmoi 설치와 적용 방법 추가"
```

- [ ] **6단계: 현재 `~/.dotfiles`를 chezmoi 소스로 등록한다**

```sh
chezmoi --source "$HOME/.dotfiles" init
chezmoi doctor
chezmoi diff
```

예상 결과: 생성된 chezmoi 설정의 `sourceDir`이 `~/.dotfiles`이고 diff에는 관리 대상 Stow 심볼릭 링크 교체만 나타난다.

- [ ] **7단계: 기존 Stow 심볼릭 링크를 제거하고 chezmoi를 적용한다**

먼저 현재 링크가 `~/.dotfiles` 아래를 가리키는지 확인한 다음 해당 링크만 제거한다. `~/.tmux.conf`처럼 외부 도구가 관리하는 링크는 chezmoi가 같은 목적의 링크로 즉시 다시 만든다.

```sh
chezmoi apply --verbose
```

적용 후 다음을 확인한다.

```sh
chezmoi status
chezmoi diff
test ! -L "$HOME/.zshrc"
test ! -L "$HOME/.zprofile"
test ! -L "$HOME/.tmux.conf.local"
test "$HOME/.claude/CLAUDE.md" -ef "$HOME/.codex/AGENTS.md"
grep -F 'selection-background = #cba6f7' "$HOME/.config/ghostty/config.ghostty"
grep -F 'copy-on-select = clipboard' "$HOME/.config/ghostty/config.ghostty"
```

예상 결과: `chezmoi status`와 `chezmoi diff`가 비어 있고, 기존 Stow 링크가 남아 있지 않으며 Claude/Codex 지침이 같은 inode를 사용한다.
