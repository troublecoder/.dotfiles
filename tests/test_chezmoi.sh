#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
render_cache_dir="$tmp_dir/render-cache"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

fail() {
  printf '실패: %s\n' "$*" >&2
  exit 1
}

assert_readme_contains() {
  expected=$1
  message=$2
  grep -F -- "$expected" "$repo_dir/README.md" >/dev/null || fail "$message"
}

[ -f "$repo_dir/README.md" ] || fail "README.md가 없습니다."
assert_readme_contains 'chezmoi --source "$HOME/.dotfiles" init' \
  "현재 저장소 등록 명령이 README에 없습니다."
assert_readme_contains 'git clone https://github.com/troublecoder/.dotfiles.git "$HOME/.dotfiles"' \
  "새 머신 복제 명령이 README에 없습니다."
assert_readme_contains 'brew install chezmoi' \
  "macOS chezmoi 수동 설치 명령이 README에 없습니다."
assert_readme_contains 'sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"' \
  "Linux chezmoi 수동 설치 명령이 README에 없습니다."
assert_readme_contains 'winget install twpayne.chezmoi' \
  "Windows chezmoi 수동 설치 명령이 README에 없습니다."
assert_readme_contains 'chezmoi doctor' \
  "chezmoi doctor 명령이 README에 없습니다."
assert_readme_contains 'chezmoi diff' \
  "적용 전 diff 명령이 README에 없습니다."
assert_readme_contains 'chezmoi apply --verbose' \
  "chezmoi 적용 명령이 README에 없습니다."
assert_readme_contains '${EDITOR:-vi} home/.chezmoitemplates/zed-settings.json.tmpl' \
  "소스 설정 편집 명령이 README에 없습니다."
assert_readme_contains 'chezmoi status --exclude=scripts' \
  "스크립트 제외 상태 확인 명령이 README에 없습니다."
assert_readme_contains 'git add <변경한-파일>' \
  "변경 파일 Git 추가 명령이 README에 없습니다."
assert_readme_contains 'git commit -m "chore: 설정 갱신"' \
  "설정 커밋 예시가 README에 없습니다."
assert_readme_contains 'git push' \
  "Git push 명령이 README에 없습니다."
assert_readme_contains 'chezmoi re-add "$HOME/.cc-switch/settings.json"' \
  "일반 대상 re-add 명령이 README에 없습니다."
assert_readme_contains 'home/.chezmoitemplates/zed-settings.json.tmpl' \
  "Zed 공통 설정 템플릿 경로가 README에 없습니다."
assert_readme_contains 'chezmoi update' \
  "자동 업데이트 명령이 README에 없습니다."
assert_readme_contains 'git pull --ff-only' \
  "수동 Git 업데이트 명령이 README에 없습니다."
assert_readme_contains 'chezmoi diff --exclude=scripts' \
  "스크립트 제외 diff 진단 명령이 README에 없습니다."
assert_readme_contains 'chezmoi managed' \
  "관리 대상 진단 명령이 README에 없습니다."
assert_readme_contains 'config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi"' \
  "POSIX chezmoi 기본 설정 디렉터리가 README에 없습니다."
assert_readme_contains 'timestamp=$(date +%Y%m%d%H%M%S)' \
  "POSIX chezmoi 설정 백업 타임스탬프가 README에 없습니다."
assert_readme_contains 'for name in chezmoi.toml chezmoi.json chezmoi.jsonc chezmoi.yaml; do' \
  "POSIX chezmoi 설정 4개 형식 순회가 README에 없습니다."
assert_readme_contains 'config_path="$config_dir/$name"' \
  "POSIX chezmoi 설정 파일 경로 조합이 README에 없습니다."
assert_readme_contains 'cp -p "$config_path" "$config_path.before-dotfiles.$timestamp"' \
  "POSIX chezmoi 설정 백업 명령이 README에 없습니다."
assert_readme_contains '$configRoot = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }' \
  "PowerShell chezmoi 기본 설정 루트 결정이 README에 없습니다."
assert_readme_contains '$configDir = Join-Path $configRoot "chezmoi"' \
  "PowerShell chezmoi 기본 설정 디렉터리가 README에 없습니다."
assert_readme_contains 'foreach ($name in @("chezmoi.toml", "chezmoi.json", "chezmoi.jsonc", "chezmoi.yaml")) {' \
  "PowerShell chezmoi 설정 4개 형식 순회가 README에 없습니다."
assert_readme_contains '$configPath = Join-Path $configDir $name' \
  "PowerShell chezmoi 설정 파일 경로 조합이 README에 없습니다."
assert_readme_contains 'Copy-Item -LiteralPath $configPath -Destination "$configPath.before-dotfiles.$timestamp"' \
  "PowerShell chezmoi 설정 백업 명령이 README에 없습니다."
assert_readme_contains '`--config`로 별도 설정 경로를 사용하는 경우에는 그 파일도 직접 백업' \
  "--config 별도 설정 파일 백업 안내가 README에 없습니다."
unsupported_config_subcommand=$(printf '%s%s' 'chezmoi config' '-path')
if grep -F "$unsupported_config_subcommand" \
  "$repo_dir/README.md" "$repo_dir/tests/test_chezmoi.sh" >/dev/null; then
  fail "chezmoi v2.71에 없는 설정 경로 하위 명령이 README 또는 테스트에 남아 있습니다."
fi
assert_readme_contains '기존 chezmoi 설정 파일 전체를 다시 생성할 수 있다' \
  "기존 chezmoi 설정 재생성 경고가 README에 없습니다."
assert_readme_contains '기존 설정에서 계속 필요한 항목은 `init` 뒤 새 설정에 수동으로 병합' \
  "기존 chezmoi 설정 항목의 수동 병합 안내가 README에 없습니다."
assert_readme_contains '이미 clone된 `~/.dotfiles` Git 저장소를 `--source`로 지정하므로 이 절차에서는 새 Git 저장소를 만들지 않는다' \
  "--source init의 Git 저장소 생성 범위 설명이 README에 없습니다."
assert_readme_contains '새 머신에서는 반드시 clone을 먼저 완료' \
  "새 머신의 clone 선행 안내가 README에 없습니다."
if grep -F '`chezmoi init`은 새 Git 저장소를 만드는 명령이 아니다.' \
  "$repo_dir/README.md" >/dev/null; then
  fail "chezmoi init에 대한 일반적인 Git 저장소 생성 단정이 README에 남아 있습니다."
fi
assert_readme_contains '소스 템플릿 창에 병합한 뒤 그 파일을 저장해야 한다' \
  "merge 도구의 소스 템플릿 저장 안내가 README에 없습니다."
assert_readme_contains '저장하지 않고 종료하면 변경이 반영되지 않는다' \
  "merge 도구의 미저장 경고가 README에 없습니다."
assert_readme_contains 'Claude와 Codex 두 관리 대상에 먼저 같은 내용으로 렌더링' \
  "Claude와 Codex 두 대상의 선렌더링 설명이 README에 없습니다."
assert_readme_contains '원본 내용을 바꾼 뒤에도 다시 적용할 수 있다' \
  "지침 원본 변경의 재적용 설명이 README에 없습니다."

readme_line_after() {
  start_line=$1
  expected=$2
  awk -v start="$start_line" -v expected="$expected" '
    NR > start && index($0, expected) {
      print NR
      exit
    }
  ' "$repo_dir/README.md"
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

render_script() {
  os=$1
  arch=$2
  file=$3
  chezmoi --source "$repo_dir" --cache "$render_cache_dir" \
    --override-data "{\"chezmoi\":{\"os\":\"$os\",\"arch\":\"$arch\"}}" \
    execute-template --file "$repo_dir/home/$file"
}

assert_script_empty() {
  os=$1
  arch=$2
  file=$3
  output_file="$tmp_dir/$os-$arch-$file"
  render_script "$os" "$arch" "$file" > "$output_file"
  [ ! -s "$output_file" ] || fail "${os}에서 $file 스크립트는 완전히 비어 있어야 합니다."
}

assert_script_shebang() {
  os=$1
  arch=$2
  file=$3
  output_file="$tmp_dir/$os-$arch-$file"
  render_script "$os" "$arch" "$file" > "$output_file"
  prefix=$(dd if="$output_file" bs=1 count=2 2>/dev/null)
  [ "$prefix" = '#!' ] || fail "$file 스크립트가 첫 바이트부터 shebang으로 시작하지 않습니다."
}

assert_script_syntax() {
  os=$1
  arch=$2
  file=$3
  output_file="$tmp_dir/$os-$arch-$file"
  render_script "$os" "$arch" "$file" > "$output_file"
  /bin/sh -n "$output_file" || fail "${os} ${arch}용 $file 셸 구문이 올바르지 않습니다."
}

assert_local_nvim_noop() {
  bootstrap_arch=$1
  nvim_directory=$2
  bootstrap_home="$tmp_dir/bootstrap-$bootstrap_arch-home"
  bootstrap_bin="$tmp_dir/bootstrap-$bootstrap_arch-bin"
  bootstrap_file="$tmp_dir/bootstrap-$bootstrap_arch.sh"
  bootstrap_output="$tmp_dir/bootstrap-$bootstrap_arch.out"

  mkdir -p \
    "$bootstrap_home/.oh-my-zsh/custom/themes/spaceship-prompt" \
    "$bootstrap_home/.tmux" \
    "$bootstrap_home/.config/nvim" \
    "$bootstrap_home/.local/opt/$nvim_directory/bin" \
    "$bootstrap_bin"
  printf '%s\n' '#!/bin/sh' 'exit 0' > "$bootstrap_home/.local/opt/$nvim_directory/bin/nvim"
  chmod +x "$bootstrap_home/.local/opt/$nvim_directory/bin/nvim"

  for network_command in git curl tar; do
    printf '%s\n' '#!/bin/sh' 'exit 97' > "$bootstrap_bin/$network_command"
    chmod +x "$bootstrap_bin/$network_command"
  done

  render_script linux "$bootstrap_arch" run_once_before_10-bootstrap.sh.tmpl > "$bootstrap_file"
  if PATH="$bootstrap_bin" command -v nvim >/dev/null 2>&1; then
    fail "제한 PATH에 nvim이 포함됐습니다."
  fi

  for attempt in 1 2; do
    if ! HOME="$bootstrap_home" PATH="$bootstrap_bin" /bin/sh "$bootstrap_file" >"$bootstrap_output" 2>&1; then
      fail "Linux $bootstrap_arch 로컬 Neovim 부트스트랩 재실행이 실패했습니다."
    fi
  done
}

assert_local_mise_install() {
  mise_home="$tmp_dir/mise-home"
  restricted_path="$tmp_dir/mise-restricted-path"
  mise_script="$tmp_dir/mise-install.sh"
  mise_args="$tmp_dir/mise-args"

  mkdir -p "$mise_home/.local/bin" "$restricted_path"
  printf '%s\n' \
    '#!/bin/sh' \
    'printf '\''%s\n'\'' "$*" > "$MISE_ARGS_FILE"' \
    > "$mise_home/.local/bin/mise"
  chmod +x "$mise_home/.local/bin/mise"
  render_script linux amd64 run_onchange_after_80-mise-install.sh.tmpl > "$mise_script"

  if HOME="$mise_home" PATH="$restricted_path" command -v mise >/dev/null 2>&1; then
    fail "제한 PATH에서 로컬 mise가 발견되면 안 됩니다."
  fi

  if ! HOME="$mise_home" PATH="$restricted_path" MISE_ARGS_FILE="$mise_args" \
    /bin/sh "$mise_script"; then
    fail "Linux mise 후처리가 ~/.local/bin/mise를 실행하지 못했습니다."
  fi

  grep -Fx 'install --yes' "$mise_args" >/dev/null ||
    fail "Linux 로컬 mise가 install --yes 인수를 받지 못했습니다."
}

render_template() {
  os=$1
  arch=$2
  file=$3
  chezmoi --source "$repo_dir" \
    --override-data "{\"chezmoi\":{\"os\":\"$os\",\"arch\":\"$arch\"}}" \
    execute-template --file "$repo_dir/home/$file"
}

assert_contains() {
  content=$1
  expected=$2
  message=$3
  printf '%s' "$content" | grep -F -- "$expected" >/dev/null || fail "$message"
}

assert_not_contains() {
  content=$1
  unexpected=$2
  message=$3
  if printf '%s' "$content" | grep -F -- "$unexpected" >/dev/null; then
    fail "$message"
  fi
}

assert_powershell_syntax() {
  os=$1
  arch=$2
  file=$3
  output_file="$tmp_dir/$os-$arch-$(basename "$file")"
  render_script "$os" "$arch" "$file" > "$output_file"
  if ! POWERSHELL_PARSE_FILE="$output_file" \
    pwsh -NoLogo -NoProfile -NonInteractive -Command '
    $tokens = $null
    $errors = $null
    [void] [System.Management.Automation.Language.Parser]::ParseFile(
      $env:POWERSHELL_PARSE_FILE,
      [ref] $tokens,
      [ref] $errors
    )
    if ($errors.Count -gt 0) {
      $errors | ForEach-Object { Write-Error $_.Message }
      exit 1
    }
  '; then
    fail "${os} ${arch}용 $file PowerShell 구문이 올바르지 않습니다."
  fi
}

windows=$(managed windows amd64)
darwin=$(managed darwin arm64)
linux=$(managed linux amd64)

for list in "$windows" "$darwin" "$linux"; do
  assert_has "$list" ".claude/CLAUDE.md"
  assert_has "$list" ".codex/AGENTS.md"
  assert_has "$list" ".config/mise/config.toml"
  assert_has "$list" ".cc-switch/settings.json"
  assert_has "$list" ".agents/skills/find-skills/SKILL.md"
done

assert_has "$windows" "AppData/Roaming/Zed/settings.json"
assert_has "$windows" "AppData/Roaming/Zed/keymap.json"
assert_lacks "$windows" ".config/zed/settings.json"
assert_lacks "$windows" ".config/zed/keymap.json"
for list in "$darwin" "$linux"; do
  assert_has "$list" ".config/zed/settings.json"
  assert_has "$list" ".config/zed/keymap.json"
  assert_lacks "$list" "AppData/Roaming/Zed/settings.json"
  assert_lacks "$list" "AppData/Roaming/Zed/keymap.json"
done

for target in windows:amd64 darwin:arm64 linux:amd64; do
  os=${target%:*}
  arch=${target#*:}
  claude_instructions="$tmp_dir/$os-$arch-CLAUDE.md"
  codex_instructions="$tmp_dir/$os-$arch-AGENTS.md"
  render_template "$os" "$arch" dot_claude/CLAUDE.md.tmpl > "$claude_instructions"
  render_template "$os" "$arch" dot_codex/AGENTS.md.tmpl > "$codex_instructions"
  cmp -s "$repo_dir/CLAUDE.md" "$claude_instructions" ||
    fail "$os Claude 지침이 루트 CLAUDE.md와 바이트 단위로 다릅니다."
  cmp -s "$repo_dir/CLAUDE.md" "$codex_instructions" ||
    fail "$os Codex 지침이 루트 CLAUDE.md와 바이트 단위로 다릅니다."
  cmp -s "$claude_instructions" "$codex_instructions" ||
    fail "$os Claude와 Codex 지침 렌더링이 서로 다릅니다."
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
for list in "$darwin" "$linux"; do
  if printf '%s\n' "$list" | grep -E '^AppData(/|$)' >/dev/null; then
    fail "비 Windows 플랫폼에서 AppData 디렉터리를 관리하면 안 됩니다."
  fi
done

for target in darwin:arm64 linux:amd64; do
  os=${target%:*}
  arch=${target#*:}
  ghostty_config=$(render_template "$os" "$arch" dot_config/ghostty/config.ghostty.tmpl)
  primary_font_line=$(printf '%s\n' "$ghostty_config" | grep -nF 'font-family = CaskaydiaCove Nerd Font' | cut -d: -f1)
  fallback_font_line=$(printf '%s\n' "$ghostty_config" | grep -nF 'font-family = D2CodingLigature Nerd Font' | cut -d: -f1)
  [ -n "$primary_font_line" ] && [ -n "$fallback_font_line" ] ||
    fail "$os Ghostty 설정에 기본 글꼴과 fallback 글꼴이 모두 있어야 합니다."
  [ "$fallback_font_line" -eq $((primary_font_line + 1)) ] ||
    fail "$os Ghostty fallback 글꼴이 기본 글꼴 바로 다음에 있어야 합니다."
done

darwin_keymap_expected="$tmp_dir/darwin-keymap.json"
cat > "$darwin_keymap_expected" <<'EOF'
[
  {
    "bindings": {
      "alt-p": "text_finder::Toggle"
    }
  }
]
EOF
darwin_keymap_actual="$tmp_dir/darwin-keymap-actual.json"
render_template darwin arm64 dot_config/zed/keymap.json.tmpl > "$darwin_keymap_actual"
cmp -s "$darwin_keymap_expected" "$darwin_keymap_actual" ||
  fail "macOS Zed 키맵이 alt-p 바인딩 한 항목과 정확히 일치하지 않습니다."

ctrl_keymap_expected="$tmp_dir/ctrl-keymap.json"
cat > "$ctrl_keymap_expected" <<'EOF'
// Zed keymap
//
// For information on binding keys, see the Zed
// documentation: https://zed.dev/docs/key-bindings
//
// To see the default key bindings run `zed: open default keymap`
// from the command palette.
[
  {
    "context": "Editor && !menu",
    "bindings": {
      "ctrl-a": "editor::SelectAll",
      "ctrl-x": "editor::Cut",
      "ctrl-c": "editor::Copy",
      "ctrl-v": "editor::Paste",
      "ctrl-s": "workspace::Save",
    },
  },
  {
    "context": "Pane",
    "unbind": {
      "ctrl-w": [
        "pane::CloseActiveItem",
        {
          "close_pinned": false
        }
      ]
    }
  },
  {
    "bindings": {
      "alt-p": "text_finder::Toggle"
    }
  }
]
EOF

for target in windows:amd64 linux:amd64; do
  os=${target%:*}
  arch=${target#*:}
  ctrl_keymap_actual="$tmp_dir/$os-keymap-actual.json"
  render_template "$os" "$arch" dot_config/zed/keymap.json.tmpl > "$ctrl_keymap_actual"
  cmp -s "$ctrl_keymap_expected" "$ctrl_keymap_actual" ||
    fail "$os Zed 키맵이 현재 전체 ctrl 바인딩과 alt-p를 보존하지 않습니다."
done

for target in windows:amd64 darwin:arm64 linux:amd64; do
  os=${target%:*}
  arch=${target#*:}
  zed_settings=$(render_template "$os" "$arch" dot_config/zed/settings.json.tmpl)
  assert_not_contains "$zed_settings" "biome" \
    "$os Zed 설정에 Biome 연동이 남아 있습니다."
  assert_not_contains "$zed_settings" "prettier" \
    "$os Zed 설정에 명시적인 Prettier formatter가 남아 있습니다."
  assert_contains "$zed_settings" '"resize_all_panels_in_dock": ["right"]' \
    "$os Zed 설정이 오른쪽 dock 패널 폭을 함께 조절하지 않습니다."
done

windows_zed_settings=$(render_template windows amd64 AppData/Roaming/Zed/settings.json.tmpl)
assert_not_contains "$windows_zed_settings" '\Zed\extensions' \
  "Windows Zed 설정의 Kotlin LSP 경로에 JSON에서 이스케이프되지 않은 역슬래시가 있습니다."

brewfile_expected="$tmp_dir/Brewfile"
cat > "$brewfile_expected" <<'EOF'
tap "steipete/tap"
brew "eza"
brew "gh"
brew "htop"
brew "mise"
brew "neovim"
brew "podman"
brew "podman-compose"
brew "tmux"
cask "1password"
cask "1password-cli"
cask "cc-switch"
cask "codex-app"
cask "steipete/tap/codexbar", trusted: true
cask "discord"
cask "ghostty"
cask "google-chrome"
cask "google-drive"
cask "logi-options+"
cask "lunar"
cask "podman-desktop"
cask "ridibooks"
EOF
[ -f "$repo_dir/Brewfile" ] || fail "저장소 루트에 Brewfile이 없습니다."
cmp -s "$brewfile_expected" "$repo_dir/Brewfile" ||
  fail "Brewfile의 tap, formula, cask 스냅샷이 요구사항과 다릅니다."
if grep -F 'brew "stow"' "$repo_dir/Brewfile" >/dev/null; then
  fail "Brewfile에 전환 후 불필요한 stow가 남아 있습니다."
fi
if grep -F 'brew "chezmoi"' "$repo_dir/Brewfile" >/dev/null; then
  fail "Brewfile에 수동 설치 대상인 chezmoi가 포함됐습니다."
fi

mise_config_expected="$tmp_dir/mise-config.toml"
cat > "$mise_config_expected" <<'EOF'
[tools]
node = "lts"
npm = "latest"
pnpm = "latest"
ripgrep = "latest"
rust = "latest"
rust-analyzer = "latest"
uv = "latest"
EOF
[ -f "$repo_dir/home/dot_config/mise/config.toml" ] ||
  fail "mise 도구 설정 파일이 없습니다."
cmp -s "$mise_config_expected" "$repo_dir/home/dot_config/mise/config.toml" ||
  fail "mise 도구 설정이 현재 도구 집합과 다릅니다."

brew_checksum=$(chezmoi --source "$repo_dir" execute-template \
  '{{ include (joinPath .chezmoi.workingTree "Brewfile") | sha256sum }}')
mise_checksum=$(chezmoi --source "$repo_dir" execute-template \
  '{{ include (joinPath .chezmoi.sourceDir "dot_config/mise/config.toml") | sha256sum }}')

assert_script_shebang darwin arm64 run_onchange_before_05-brew-bundle.sh.tmpl
assert_script_syntax darwin arm64 run_onchange_before_05-brew-bundle.sh.tmpl
assert_script_empty windows amd64 run_onchange_before_05-brew-bundle.sh.tmpl
assert_script_empty linux amd64 run_onchange_before_05-brew-bundle.sh.tmpl
darwin_brew=$(render_script darwin arm64 run_onchange_before_05-brew-bundle.sh.tmpl)
assert_contains "$darwin_brew" "command -v brew" \
  "macOS Brew Bundle 스크립트에 Homebrew 존재 검사가 없습니다."
assert_contains "$darwin_brew" "수동으로 설치" \
  "Homebrew가 없을 때 수동 설치를 안내하는 한국어 오류가 없습니다."
assert_contains "$darwin_brew" "brew bundle" \
  "macOS Brew Bundle 스크립트에 brew bundle 실행이 없습니다."
assert_contains "$darwin_brew" "$repo_dir/Brewfile" \
  "macOS Brew Bundle 스크립트가 저장소 루트 Brewfile을 사용하지 않습니다."
assert_contains "$darwin_brew" "$brew_checksum" \
  "macOS Brew Bundle 스크립트에 Brewfile 체크섬이 없습니다."
if ! printf '%s' "$darwin_brew" | grep -F -- "--no-upgrade" >/dev/null &&
  ! printf '%s' "$darwin_brew" | grep -F "HOMEBREW_BUNDLE_NO_UPGRADE=1" >/dev/null; then
  fail "macOS Brew Bundle 스크립트가 패키지 업그레이드를 막지 않습니다."
fi

assert_script_shebang linux amd64 run_onchange_before_06-mise.sh.tmpl
assert_script_syntax linux amd64 run_onchange_before_06-mise.sh.tmpl
assert_script_empty darwin arm64 run_onchange_before_06-mise.sh.tmpl
assert_script_empty windows amd64 run_onchange_before_06-mise.sh.tmpl
linux_mise=$(render_script linux amd64 run_onchange_before_06-mise.sh.tmpl)
assert_contains "$linux_mise" "https://mise.run" \
  "Linux mise 설치 스크립트가 공식 설치 주소를 사용하지 않습니다."

assert_script_empty darwin arm64 run_onchange_before_06-mise.ps1.tmpl
assert_script_empty linux amd64 run_onchange_before_06-mise.ps1.tmpl
windows_mise=$(render_script windows amd64 run_onchange_before_06-mise.ps1.tmpl)
assert_contains "$windows_mise" "winget" \
  "Windows mise 설치 스크립트에 winget 실행이 없습니다."
assert_contains "$windows_mise" "jdx.mise" \
  "Windows mise 설치 스크립트에 jdx.mise 패키지 ID가 없습니다."
assert_contains "$windows_mise" '$ErrorActionPreference = '\''Stop'\''' \
  "Windows mise 설치 스크립트가 오류를 terminating error로 처리하지 않습니다."

assert_script_shebang darwin arm64 run_onchange_after_80-mise-install.sh.tmpl
assert_script_syntax darwin arm64 run_onchange_after_80-mise-install.sh.tmpl
assert_script_shebang linux amd64 run_onchange_after_80-mise-install.sh.tmpl
assert_script_syntax linux amd64 run_onchange_after_80-mise-install.sh.tmpl
assert_script_empty windows amd64 run_onchange_after_80-mise-install.sh.tmpl
for target in darwin:arm64 linux:amd64; do
  os=${target%:*}
  arch=${target#*:}
  unix_mise_install=$(render_script "$os" "$arch" run_onchange_after_80-mise-install.sh.tmpl)
  assert_contains "$unix_mise_install" "install --yes" \
    "$os mise 후처리 스크립트에 install --yes가 없습니다."
  assert_contains "$unix_mise_install" "$mise_checksum" \
    "$os mise 후처리 스크립트에 설정 체크섬이 없습니다."
done
assert_local_mise_install

assert_script_empty darwin arm64 run_onchange_after_80-mise-install.ps1.tmpl
assert_script_empty linux amd64 run_onchange_after_80-mise-install.ps1.tmpl
windows_mise_install=$(render_script windows amd64 run_onchange_after_80-mise-install.ps1.tmpl)
assert_contains "$windows_mise_install" "mise install --yes" \
  "Windows mise 후처리 스크립트에 mise install --yes가 없습니다."
assert_contains "$windows_mise_install" "$mise_checksum" \
  "Windows mise 후처리 스크립트에 설정 체크섬이 없습니다."
assert_contains "$windows_mise_install" "LOCALAPPDATA" \
  "Windows mise 후처리 스크립트가 LOCALAPPDATA를 사용하지 않습니다."
assert_contains "$windows_mise_install" 'Microsoft\WinGet\Links' \
  "Windows mise 후처리 스크립트가 WinGet Links 경로를 사용하지 않습니다."
assert_contains "$windows_mise_install" '$ErrorActionPreference = '\''Stop'\''' \
  "Windows mise 후처리 스크립트가 오류를 terminating error로 처리하지 않습니다."

if command -v pwsh >/dev/null 2>&1; then
  assert_powershell_syntax windows amd64 run_onchange_before_06-mise.ps1.tmpl
  assert_powershell_syntax windows amd64 run_onchange_after_80-mise-install.ps1.tmpl
fi

assert_script_empty windows amd64 run_once_before_10-bootstrap.sh.tmpl
assert_script_shebang darwin arm64 run_once_before_10-bootstrap.sh.tmpl
assert_script_syntax darwin arm64 run_once_before_10-bootstrap.sh.tmpl
assert_script_syntax linux amd64 run_once_before_10-bootstrap.sh.tmpl
assert_script_syntax linux arm64 run_once_before_10-bootstrap.sh.tmpl

darwin_bootstrap=$(render_script darwin arm64 run_once_before_10-bootstrap.sh.tmpl)
printf '%s' "$darwin_bootstrap" | grep -F "LazyVim/starter" >/dev/null ||
  fail "macOS 부트스트랩에 LazyVim 설치가 없습니다."
if printf '%s' "$darwin_bootstrap" | grep -F "nvim-linux-" >/dev/null; then
  fail "macOS에서 Linux Neovim을 설치하면 안 됩니다."
fi

linux_amd64_bootstrap=$(render_script linux amd64 run_once_before_10-bootstrap.sh.tmpl)
printf '%s' "$linux_amd64_bootstrap" | grep -F "nvim-linux-x86_64" >/dev/null ||
  fail "Linux amd64 Neovim 자산이 없습니다."

linux_arm64_bootstrap=$(render_script linux arm64 run_once_before_10-bootstrap.sh.tmpl)
printf '%s' "$linux_arm64_bootstrap" | grep -F "nvim-linux-arm64" >/dev/null ||
  fail "Linux arm64 Neovim 자산이 없습니다."

assert_local_nvim_noop amd64 nvim-linux-x86_64
assert_local_nvim_noop arm64 nvim-linux-arm64

darwin_zshrc=$(render_template darwin arm64 dot_zshrc.tmpl)
if printf '%s' "$darwin_zshrc" | grep -F "nvim-linux-" >/dev/null; then
  fail "macOS zshrc에 Linux Neovim PATH가 있으면 안 됩니다."
fi
if grep -F "nvim-linux-" "$repo_dir/home/dot_zprofile" >/dev/null; then
  fail "macOS에 배포되는 zprofile에서 Linux Neovim을 설치하면 안 됩니다."
fi

linux_amd64_zshrc=$(render_template linux amd64 dot_zshrc.tmpl)
printf '%s' "$linux_amd64_zshrc" | grep -F "nvim-linux-x86_64/bin" >/dev/null ||
  fail "Linux amd64 zshrc에 Neovim PATH가 없습니다."

linux_arm64_zshrc=$(render_template linux arm64 dot_zshrc.tmpl)
printf '%s' "$linux_arm64_zshrc" | grep -F "nvim-linux-arm64/bin" >/dev/null ||
  fail "Linux arm64 zshrc에 Neovim PATH가 없습니다."

assert_script_shebang darwin arm64 run_before_89-guard-agent-instructions.sh.tmpl
assert_script_syntax darwin arm64 run_before_89-guard-agent-instructions.sh.tmpl
assert_script_empty windows amd64 run_before_89-guard-agent-instructions.sh.tmpl
assert_script_empty darwin arm64 run_before_89-guard-agent-instructions.ps1.tmpl
unix_guard=$(render_script darwin arm64 run_before_89-guard-agent-instructions.sh.tmpl)
assert_contains "$unix_guard" 'cmp -s "$target_file" "$cache_file"' \
  "Unix 지침 보호 스크립트가 마지막 배포 사본과 비교하지 않습니다."
assert_contains "$unix_guard" 'cmp -s "$target_file" "$intended_file"' \
  "Unix 지침 보호 스크립트가 현재 원본 의도와 비교하지 않습니다."
assert_contains "$unix_guard" "$render_cache_dir/agent-instructions.last" \
  "Unix 지침 보호 스크립트가 chezmoi cache 상태를 사용하지 않습니다."

windows_guard=$(render_script windows amd64 run_before_89-guard-agent-instructions.ps1.tmpl)
assert_contains "$windows_guard" '$ErrorActionPreference = '\''Stop'\''' \
  "Windows 지침 보호 스크립트가 오류를 terminating error로 처리하지 않습니다."
assert_contains "$windows_guard" 'Get-FileHash' \
  "Windows 지침 보호 스크립트가 파일 해시를 비교하지 않습니다."
assert_contains "$windows_guard" "$render_cache_dir/agent-instructions.last" \
  "Windows 지침 보호 스크립트가 chezmoi cache 상태를 사용하지 않습니다."

if command -v pwsh >/dev/null 2>&1; then
  assert_powershell_syntax windows amd64 run_before_89-guard-agent-instructions.ps1.tmpl
  windows_guard_file="$tmp_dir/windows-guard.ps1"
  render_script windows amd64 run_before_89-guard-agent-instructions.ps1.tmpl > "$windows_guard_file"
  windows_guard_home="$tmp_dir/windows-guard-home"
  mkdir -p "$windows_guard_home"

  HOME="$windows_guard_home" pwsh -NoLogo -NoProfile -NonInteractive -File "$windows_guard_file"

  mkdir -p "$windows_guard_home/.codex"
  cp "$repo_dir/CLAUDE.md" "$windows_guard_home/.codex/AGENTS.md"
  HOME="$windows_guard_home" pwsh -NoLogo -NoProfile -NonInteractive -File "$windows_guard_file"

  mkdir -p "$render_cache_dir"
  printf '마지막 배포 지침\n' > "$render_cache_dir/agent-instructions.last"
  printf '마지막 배포 지침\n' > "$windows_guard_home/.codex/AGENTS.md"
  HOME="$windows_guard_home" pwsh -NoLogo -NoProfile -NonInteractive -File "$windows_guard_file"

  printf '사용자 지침\n' > "$windows_guard_home/.codex/AGENTS.md"
  if HOME="$windows_guard_home" pwsh -NoLogo -NoProfile -NonInteractive \
    -File "$windows_guard_file" >"$tmp_dir/windows-guard-conflict.out" 2>&1; then
    fail "Windows 지침 보호 스크립트가 다른 기존 내용을 허용했습니다."
  fi
  grep -Fx '사용자 지침' "$windows_guard_home/.codex/AGENTS.md" >/dev/null ||
    fail "Windows 지침 보호 실패 시 기존 내용이 보존되지 않았습니다."
fi

unix_link_file="$tmp_dir/unix-link.sh"
render_script darwin arm64 run_after_90-link-agent-instructions.sh.tmpl > "$unix_link_file"
unix_link_home="$tmp_dir/unix-link-home"
mkdir -p "$unix_link_home/.claude" "$unix_link_home/.codex"
cp "$repo_dir/CLAUDE.md" "$unix_link_home/.claude/CLAUDE.md"

HOME="$unix_link_home" /bin/sh "$unix_link_file"
test "$unix_link_home/.claude/CLAUDE.md" -ef "$unix_link_home/.codex/AGENTS.md" ||
  fail "Unix 하드링크 생성 결과가 원본과 같은 inode가 아닙니다."
rm "$render_cache_dir/agent-instructions.last"
HOME="$unix_link_home" /bin/sh "$unix_link_file"
cmp -s "$unix_link_home/.claude/CLAUDE.md" "$render_cache_dir/agent-instructions.last" ||
  fail "Unix의 올바른 기존 하드링크 경로에서 cache가 갱신되지 않았습니다."

rm "$unix_link_home/.codex/AGENTS.md"
printf '다른 지침\n' > "$unix_link_home/.codex/AGENTS.md"
if HOME="$unix_link_home" /bin/sh "$unix_link_file" >"$tmp_dir/unix-conflict.out" 2>&1; then
  fail "Unix 하드링크 스크립트가 서로 다른 기존 파일을 거부하지 않았습니다."
fi
grep -F '오류: 기존 ~/.codex/AGENTS.md의 내용이 원본 지침과 다릅니다.' "$tmp_dir/unix-conflict.out" >/dev/null ||
  fail "Unix 하드링크 충돌 시 한국어 오류가 없습니다."
grep -Fx '다른 지침' "$unix_link_home/.codex/AGENTS.md" >/dev/null ||
  fail "Unix 하드링크 충돌 시 기존 파일 내용이 보존되지 않았습니다."

cp "$unix_link_home/.claude/CLAUDE.md" "$unix_link_home/.codex/AGENTS.md"
ln "$unix_link_home/.codex/AGENTS.md" "$unix_link_home/.codex/AGENTS.md.guard"
failure_bin="$tmp_dir/failure-bin"
mkdir -p "$failure_bin"
printf '%s\n' '#!/bin/sh' 'exit 1' > "$failure_bin/ln"
chmod +x "$failure_bin/ln"
if HOME="$unix_link_home" PATH="$failure_bin:/usr/bin:/bin" /bin/sh "$unix_link_file" >"$tmp_dir/unix-ln-failure.out" 2>&1; then
  fail "Unix 하드링크 스크립트가 ln 실패를 성공으로 처리했습니다."
fi
test "$unix_link_home/.codex/AGENTS.md" -ef "$unix_link_home/.codex/AGENTS.md.guard" ||
  fail "Unix ln 실패 시 기존 target inode가 보존되지 않았습니다."

guard_regression_source="$tmp_dir/guard-regression-source"
guard_regression_home="$tmp_dir/guard-regression-home"
guard_regression_cache="$tmp_dir/guard-regression-cache"
mkdir -p \
  "$guard_regression_source/home/dot_claude" \
  "$guard_regression_source/home/dot_codex" \
  "$guard_regression_home/.codex"
printf 'home\n' > "$guard_regression_source/.chezmoiroot"
printf '배포 지침\n' > "$guard_regression_source/CLAUDE.md"
cp "$repo_dir/home/dot_claude/CLAUDE.md.tmpl" \
  "$guard_regression_source/home/dot_claude/CLAUDE.md.tmpl"
cp "$repo_dir/home/dot_codex/AGENTS.md.tmpl" \
  "$guard_regression_source/home/dot_codex/AGENTS.md.tmpl"
cp "$repo_dir/home/run_after_90-link-agent-instructions.sh.tmpl" \
  "$guard_regression_source/home/run_after_90-link-agent-instructions.sh.tmpl"
cp "$repo_dir/home/run_before_89-guard-agent-instructions.sh.tmpl" \
  "$guard_regression_source/home/run_before_89-guard-agent-instructions.sh.tmpl"

printf '보존할 사용자 지침\n' > "$guard_regression_home/.codex/AGENTS.md"
if HOME="$guard_regression_home" chezmoi \
  --source "$guard_regression_source" \
  --destination "$guard_regression_home" \
  --cache "$guard_regression_cache" \
  --override-data '{"chezmoi":{"os":"darwin","arch":"arm64"}}' \
  --force apply >"$tmp_dir/guard-regression.out" 2>&1; then
  fail "최초 full apply가 다른 기존 Codex 지침을 거부하지 않았습니다."
fi
grep -Fx '보존할 사용자 지침' "$guard_regression_home/.codex/AGENTS.md" >/dev/null ||
  fail "최초 full apply 실패 시 기존 Codex 지침이 보존되지 않았습니다."
grep -F '오류:' "$tmp_dir/guard-regression.out" >/dev/null ||
  fail "최초 full apply 충돌에 한국어 오류가 없습니다."
[ ! -e "$guard_regression_home/.claude/CLAUDE.md" ] ||
  fail "지침 보호 실패 전에 managed Claude 파일이 작성됐습니다."

guard_success_home="$tmp_dir/guard-success-home"
guard_success_cache="$tmp_dir/guard-success-cache"
mkdir -p "$guard_success_home"
HOME="$guard_success_home" chezmoi \
  --source "$guard_regression_source" \
  --destination "$guard_success_home" \
  --cache "$guard_success_cache" \
  --override-data '{"chezmoi":{"os":"darwin","arch":"arm64"}}' \
  --force apply
test "$guard_success_home/.claude/CLAUDE.md" -ef "$guard_success_home/.codex/AGENTS.md" ||
  fail "첫 full apply 후 Claude와 Codex 지침이 같은 inode가 아닙니다."
cmp -s "$guard_success_home/.claude/CLAUDE.md" "$guard_success_cache/agent-instructions.last" ||
  fail "첫 full apply 후 마지막 배포 cache가 생성되지 않았습니다."
if test "$guard_success_home/.claude/CLAUDE.md" -ef "$guard_success_cache/agent-instructions.last"; then
  fail "마지막 배포 cache가 내용 사본이 아니라 managed 파일의 하드링크입니다."
fi

printf '갱신된 배포 지침\n' > "$guard_regression_source/CLAUDE.md"
HOME="$guard_success_home" chezmoi \
  --source "$guard_regression_source" \
  --destination "$guard_success_home" \
  --cache "$guard_success_cache" \
  --override-data '{"chezmoi":{"os":"darwin","arch":"arm64"}}' \
  --force apply
grep -Fx '갱신된 배포 지침' "$guard_success_home/.claude/CLAUDE.md" >/dev/null ||
  fail "두 번째 full apply 후 Claude 지침이 새 값이 아닙니다."
grep -Fx '갱신된 배포 지침' "$guard_success_home/.codex/AGENTS.md" >/dev/null ||
  fail "두 번째 full apply 후 Codex 지침이 새 값이 아닙니다."
test "$guard_success_home/.claude/CLAUDE.md" -ef "$guard_success_home/.codex/AGENTS.md" ||
  fail "두 번째 full apply 후 Claude와 Codex 지침이 같은 inode가 아닙니다."
cmp -s "$guard_success_home/.claude/CLAUDE.md" "$guard_success_cache/agent-instructions.last" ||
  fail "두 번째 full apply 후 마지막 배포 cache가 갱신되지 않았습니다."

printf '사용자가 수정한 지침\n' > "$guard_success_home/.codex/AGENTS.md"
printf '다음 배포 지침\n' > "$guard_regression_source/CLAUDE.md"
if HOME="$guard_success_home" chezmoi \
  --source "$guard_regression_source" \
  --destination "$guard_success_home" \
  --cache "$guard_success_cache" \
  --override-data '{"chezmoi":{"os":"darwin","arch":"arm64"}}' \
  --force apply >"$tmp_dir/guard-user-change.out" 2>&1; then
  fail "사용자 지침 변경 뒤 full apply가 기존 내용을 덮어썼습니다."
fi
grep -Fx '사용자가 수정한 지침' "$guard_success_home/.claude/CLAUDE.md" >/dev/null ||
  fail "full apply 거부 뒤 Claude 사용자 변경이 보존되지 않았습니다."
grep -Fx '사용자가 수정한 지침' "$guard_success_home/.codex/AGENTS.md" >/dev/null ||
  fail "full apply 거부 뒤 Codex 사용자 변경이 보존되지 않았습니다."
grep -Fx '갱신된 배포 지침' "$guard_success_cache/agent-instructions.last" >/dev/null ||
  fail "full apply 거부 뒤 마지막 성공 cache가 보존되지 않았습니다."

unix_link=$(render_script darwin arm64 run_after_90-link-agent-instructions.sh.tmpl)
printf '%s' "$unix_link" | grep -F 'ln "$source_file" "$temporary_file"' >/dev/null ||
  fail "Unix 임시 하드링크 생성 명령이 없습니다."
printf '%s' "$unix_link" | grep -F 'mv -f "$temporary_file" "$target_file"' >/dev/null ||
  fail "Unix 원자적 하드링크 교체 명령이 없습니다."
assert_contains "$unix_link" 'umask 077' \
  "Unix cache 상태 파일에 제한 권한이 적용되지 않습니다."
assert_contains "$unix_link" 'agent-instructions.last' \
  "Unix 하드링크 성공 후 cache 상태를 기록하지 않습니다."
assert_script_shebang darwin arm64 run_after_90-link-agent-instructions.sh.tmpl
assert_script_syntax darwin arm64 run_after_90-link-agent-instructions.sh.tmpl

assert_script_empty windows amd64 run_after_90-link-agent-instructions.sh.tmpl

windows_link=$(render_script windows amd64 run_after_90-link-agent-instructions.ps1.tmpl)
printf '%s' "$windows_link" | grep -F "New-Item -ItemType HardLink" >/dev/null ||
  fail "Windows 하드링크 생성 명령이 없습니다."
printf '%s' "$windows_link" | grep -F '$ErrorActionPreference = '\''Stop'\''' >/dev/null ||
  fail "Windows 하드링크 스크립트가 오류를 terminating error로 처리하지 않습니다."
printf '%s' "$windows_link" | grep -F 'New-Item -ItemType HardLink -Path $temporaryFile -Target $sourceFile' >/dev/null ||
  fail "Windows 임시 하드링크 생성 명령이 없습니다."
printf '%s' "$windows_link" | grep -F 'New-Item -ItemType HardLink -Path $backupFile -Target $targetFile' >/dev/null ||
  fail "Windows 기존 target 백업 하드링크 생성 명령이 없습니다."
printf '%s' "$windows_link" | grep -F 'Remove-Item -LiteralPath $targetFile -ErrorAction Stop' >/dev/null ||
  fail "Windows 기존 target 제거 명령이 없습니다."
printf '%s' "$windows_link" | grep -F '[System.IO.File]::Move($temporaryFile, $targetFile)' >/dev/null ||
  fail "Windows 임시 하드링크 이동 명령이 없습니다."
printf '%s' "$windows_link" | grep -F '[System.IO.File]::Move($backupFile, $targetFile)' >/dev/null ||
  fail "Windows 실패 시 기존 target 복구 명령이 없습니다."
if printf '%s' "$windows_link" | grep -F '[System.IO.File]::Replace($temporaryFile, $targetFile' >/dev/null; then
  fail "Windows 하드링크 재적용에 File.Replace를 사용하면 안 됩니다."
fi
printf '%s' "$windows_link" | grep -F 'finally {' >/dev/null ||
  fail "Windows 임시 파일 정리용 finally 블록이 없습니다."
assert_contains "$windows_link" 'agent-instructions.last' \
  "Windows 하드링크 성공 후 cache 상태를 기록하지 않습니다."
assert_contains "$windows_link" '[System.IO.File]::Copy($sourceFile, $cacheTemporaryFile)' \
  "Windows cache 상태가 source 내용 사본으로 생성되지 않습니다."

temporary_link_line=$(printf '%s\n' "$windows_link" | grep -nF 'New-Item -ItemType HardLink -Path $temporaryFile -Target $sourceFile' | cut -d: -f1)
backup_link_line=$(printf '%s\n' "$windows_link" | grep -nF 'New-Item -ItemType HardLink -Path $backupFile -Target $targetFile' | cut -d: -f1)
target_remove_line=$(printf '%s\n' "$windows_link" | grep -nF 'Remove-Item -LiteralPath $targetFile -ErrorAction Stop' | cut -d: -f1)
temporary_move_line=$(printf '%s\n' "$windows_link" | grep -nF '[System.IO.File]::Move($temporaryFile, $targetFile)' | cut -d: -f1)
backup_restore_line=$(printf '%s\n' "$windows_link" | grep -nF '[System.IO.File]::Move($backupFile, $targetFile)' | cut -d: -f1)
[ "$temporary_link_line" -lt "$backup_link_line" ] &&
  [ "$backup_link_line" -lt "$target_remove_line" ] &&
  [ "$target_remove_line" -lt "$temporary_move_line" ] &&
  [ "$temporary_move_line" -lt "$backup_restore_line" ] ||
  fail "Windows 임시 링크, 백업, target 제거, 이동, 복구 순서가 올바르지 않습니다."

if command -v pwsh >/dev/null 2>&1; then
  assert_powershell_syntax windows amd64 run_after_90-link-agent-instructions.ps1.tmpl
  windows_link_file="$tmp_dir/windows-link.ps1"
  render_script windows amd64 run_after_90-link-agent-instructions.ps1.tmpl > "$windows_link_file"
  windows_link_home="$tmp_dir/windows-link-home"
  mkdir -p "$windows_link_home/.claude" "$windows_link_home/.codex"
  cp "$repo_dir/CLAUDE.md" "$windows_link_home/.claude/CLAUDE.md"
  cp "$repo_dir/CLAUDE.md" "$windows_link_home/.codex/AGENTS.md"
  HOME="$windows_link_home" pwsh -NoLogo -NoProfile -NonInteractive -File "$windows_link_file"
  test "$windows_link_home/.claude/CLAUDE.md" -ef "$windows_link_home/.codex/AGENTS.md" ||
    fail "PowerShell 하드링크 교체 결과가 원본과 같은 inode가 아닙니다."
  HOME="$windows_link_home" pwsh -NoLogo -NoProfile -NonInteractive -File "$windows_link_file"
  test "$windows_link_home/.claude/CLAUDE.md" -ef "$windows_link_home/.codex/AGENTS.md" ||
    fail "PowerShell 하드링크 두 번째 적용 결과가 원본과 같은 inode가 아닙니다."
  cmp -s "$windows_link_home/.claude/CLAUDE.md" "$render_cache_dir/agent-instructions.last" ||
    fail "PowerShell 하드링크 성공 후 cache 상태가 갱신되지 않았습니다."

  rm "$windows_link_home/.codex/AGENTS.md"
  printf '다른 지침\n' > "$windows_link_home/.codex/AGENTS.md"
  if HOME="$windows_link_home" pwsh -NoLogo -NoProfile -NonInteractive -File "$windows_link_file" >"$tmp_dir/windows-conflict.out" 2>&1; then
    fail "PowerShell 하드링크 스크립트가 서로 다른 기존 파일을 거부하지 않았습니다."
  fi
  grep -Fx '다른 지침' "$windows_link_home/.codex/AGENTS.md" >/dev/null ||
    fail "PowerShell 하드링크 충돌 시 기존 파일 내용이 보존되지 않았습니다."
fi

assert_script_empty darwin arm64 run_after_90-link-agent-instructions.ps1.tmpl

printf '플랫폼별 관리 대상 검증을 통과했습니다.\n'
