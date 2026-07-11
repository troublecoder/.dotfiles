# dotfiles 관리

이 저장소는 `~/.dotfiles`를 chezmoi 소스로 사용해 Windows, macOS,
Linux에 필요한 설정만 배포한다. 적용 전 `chezmoi diff`로 변경을
검토하고, 적용 후 소스 변경을 Git으로 기록하는 흐름을 기본으로
한다.

## 설치 전 준비

Git은 먼저 설치해야 한다. Homebrew와 첫 적용을 시작할 chezmoi는
이 저장소가 자동으로 설치하지 않으므로 사용자가 수동으로 준비한다.
macOS에서는 Homebrew를 공식 설치 절차로 먼저 설치한 뒤 chezmoi를
설치한다.

### macOS

```sh
brew install chezmoi
```

### Linux

공식 바이너리 설치 스크립트로 `~/.local/bin`에 설치한다.

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
```

설치 후 `~/.local/bin`이 `PATH`에 포함됐는지 확인한다.

### Windows

PowerShell에서 winget으로 설치한다.

```powershell
winget install twpayne.chezmoi
```

Windows PowerShell에서도 아래 예시의 `$HOME`과 슬래시 표기를 그대로
사용할 수 있다.

## 첫 적용

이 저장소의 `home/.chezmoi.toml.tmpl` 때문에 첫 `chezmoi init`은
기존 chezmoi 설정 파일 전체를 다시 생성할 수 있다. 현재 설정이 있다면
`init` 전에 내용을 확인하고 백업한다.

POSIX 셸에서는 다음과 같이 백업한다.

```sh
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi"
timestamp=$(date +%Y%m%d%H%M%S)
for name in chezmoi.toml chezmoi.json chezmoi.jsonc chezmoi.yaml; do
  config_path="$config_dir/$name"
  if [ -f "$config_path" ]; then
    cp -p "$config_path" "$config_path.before-dotfiles.$timestamp"
  fi
done
```

PowerShell에서는 다음과 같이 백업한다.

```powershell
$configRoot = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }
$configDir = Join-Path $configRoot "chezmoi"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
foreach ($name in @("chezmoi.toml", "chezmoi.json", "chezmoi.jsonc", "chezmoi.yaml")) {
    $configPath = Join-Path $configDir $name
    if (Test-Path -LiteralPath $configPath) {
        Copy-Item -LiteralPath $configPath -Destination "$configPath.before-dotfiles.$timestamp"
    }
}
```

위 명령은 chezmoi의 기본 설정 디렉터리만 확인한다. `--config`로 별도 설정 경로를 사용하는 경우에는 그 파일도 직접 백업한다.

백업을 보관하고, 기존 설정에서 계속 필요한 항목은 `init` 뒤 새 설정에 수동으로 병합한다.
백업 파일 자체는 Git에 추가하지 않는다.

아래 명령은 이미 clone된 `~/.dotfiles` Git 저장소를 `--source`로 지정하므로 이 절차에서는 새 Git 저장소를 만들지 않는다.
`chezmoi init`의 모든 사용 방식을 일반화한 설명은 아니다.

### 현재 `~/.dotfiles` 등록

```sh
chezmoi --source "$HOME/.dotfiles" init
chezmoi doctor
chezmoi diff
chezmoi apply --verbose
```

`chezmoi diff`에서 예상한 관리 대상만 바뀌는지 확인한 후 적용한다.
기존 GNU Stow 심볼릭 링크는 chezmoi가 관리하는 일반 파일 또는
명시적인 심볼릭 링크로 바뀌며, 관련 없는 홈 파일은 삭제하지
않는다. 전환 후에는 Stow를 사용하지 않는다.

### 새 머신에서 기존 저장소 사용

새 머신에서는 반드시 clone을 먼저 완료한 뒤 `chezmoi init`을
실행한다.

```sh
git clone https://github.com/troublecoder/.dotfiles.git "$HOME/.dotfiles"
chezmoi --source "$HOME/.dotfiles" init
chezmoi diff
chezmoi apply --verbose
```

검토를 생략해야 하는 경우에만 다음 명령으로 등록과 적용을 한 번에
실행한다. 기본 절차는 위의 `diff`를 포함한 순서다.

```sh
chezmoi --source "$HOME/.dotfiles" init --apply --verbose
```

## 플랫폼별 관리 범위

| 대상 | Windows | macOS | Linux |
| --- | --- | --- | --- |
| `~/.agents/skills/` | 예 | 예 | 예 |
| `~/.cc-switch/settings.json` | 예 | 예 | 예 |
| `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` | 예 | 예 | 예 |
| `~/.config/zed/settings.json`, `keymap.json` | 예 | 예 | 예 |
| `~/.config/mise/config.toml`과 mise 도구 | 예 | 예 | 예 |
| Zsh, Spaceship, Oh My Tmux, LazyVim | 아니요 | 예 | 예 |
| `~/.config/ghostty/` | 아니요 | 예 | 예 |
| Windows Terminal Stable `settings.json` | 예 | 아니요 | 아니요 |
| 로컬 Neovim 바이너리 | 아니요 | 아니요 | 예 |
| Homebrew `Brewfile` 패키지 | 아니요 | 예 | 아니요 |

Windows Terminal은 winget Stable 패키지의
`%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`
경로를 사용한다. Windows에서는 Unix 셸, tmux, Ghostty, LazyVim 부트스트랩을
실행하지 않는다.

macOS와 Linux에서는 첫 적용 시 Oh My Zsh, Spaceship, Oh My Tmux,
LazyVim starter가 없을 때만 복제된다. Linux는 `amd64`와 `arm64`에서
사용 가능한 Neovim이 없을 때 아키텍처에 맞는 로컬 바이너리도
설치한다. 이미 있는 복제본과 로컬 변경은 갱신하거나 덮어쓰지
않는다.

## Homebrew와 mise 자동화

Homebrew 자체와 chezmoi는 수동 선행 설치 대상이다. macOS에서는
첫 적용 또는 루트 `Brewfile`의 체크섬 변경 후 `brew bundle --no-upgrade`가
실행되어 누락된 tap, formula, cask를 설치한다. `Brewfile`에는
자동화 대상인 mise를 포함하지만, 수동 설치 대상인 chezmoi와 전환
후 불필요한 stow는 포함하지 않는다. 목록에서 항목을 제거해도 이미
설치된 패키지를 자동 삭제하지 않는다.

mise 자체는 macOS에서 `Brewfile`, Linux에서 공식 `https://mise.run`
설치 스크립트, Windows에서 winget의 `jdx.mise` 패키지로 설치된다.
Windows에서 동일한 설치를 수동으로 재현할 때는 다음 패키지 ID를
사용한다.

```powershell
winget install --id jdx.mise --exact
```

세 플랫폼 모두 `~/.config/mise/config.toml`을 적용한다. 첫 적용이나
이 설정의 체크섬이 바뀌면 후처리 스크립트가 다음 명령을 실행한다.

```sh
mise install --yes
```

## Zed 플랫폼 차이

Zed 설정은 세 플랫폼에 공통으로 적용되지만 키맵은 다르다.
macOS 키맵에는 Option+P에 해당하는
`"alt-p": "text_finder::Toggle"` 바인딩 하나만 있다. Windows와 Linux는
공통 Ctrl 편집 바인딩과 Alt+P 검색 바인딩을 함께 사용한다.

웹 언어 설정에서 Biome 연동과 명시적인 Prettier formatter를 제거해
Zed의 기본 formatter 선택에 맡긴다. 오른쪽 dock의 패널은
`"resize_all_panels_in_dock": ["right"]` 설정으로 폭을 함께 조절한다.

## Claude와 Codex 지침

루트 `CLAUDE.md`가 단일 원본이다. chezmoi는 이 원본을 Claude와 Codex 두 관리 대상에 먼저 같은 내용으로 렌더링한다.
대상 경로는 `~/.claude/CLAUDE.md`와 `~/.codex/AGENTS.md`다. 그 뒤
매 적용 후 스크립트가 두 대상을 같은 파일 식별자를 사용하는
하드링크로 묶는다.

이 순서 때문에 루트 `CLAUDE.md` 원본 내용을 바꾼 뒤에도 다시 적용할 수 있다.
재적용하면 두 관리 대상이 새 내용으로 먼저 렌더링된 뒤
다시 하드링크로 묶인다. 두 경로는 하드링크를 지원하는 같은
파일시스템에 있어야 한다.

후처리 스크립트가 서로 다른 두 파일을 받으면 기존 대상을 삭제하지
않고 오류로 중단한다. 일반 `chezmoi status`에서는 하드링크를 확인하는
`run_after_` 스크립트가 `R` 상태로 보일 수 있다. 일반 파일 차이만
확인할 때는 `--exclude=scripts`를 사용한다.

## 관리 제외 범위와 비밀값

- `~/.agents`에서는 `skills/`만 관리한다. `~/.agents/AGENTS.md`와
  `~/.agents/.skill-lock.json`은 관리하지 않으며, 다른 도구가 설치한
  스킬도 삭제하지 않는다.
- `~/.cc-switch`에서는 `settings.json`만 관리한다. `cc-switch.db`,
  `codex_oauth_auth.json`, 로그, 백업, `skills/`는 각 기기에 남긴다.
- Windows의 Zed, Ghostty, Windows Terminal, CC Switch 애플리케이션 설치는
  관리하지 않고 설정 파일만 플랫폼 범위에 맞게 배포한다.
- `Brewfile`은 Homebrew tap, formula, cask만 관리한다. Mac App Store
  애플리케이션, 편집기 확장, 언어별 전역 패키지는 제외한다.

Git에 커밋하는 모든 소스에는 토큰, 비밀번호, OAuth 정보를 포함한
비밀값을 절대 넣지 않는다. 과거 루트 `settings.json`에 인증 토큰이
있었으므로 해당 토큰은 노출된 것으로 간주해 폐기하고 새 토큰을
재발급해야 한다. 실제 토큰 값은 README, Git diff, 커밋, 로그에
적지 않는다.

## 설정 변경 기본 작업

변경 경로와 관계없이 커밋 전 `chezmoi diff`와 `git diff`를 읽고
토큰, 비밀번호, OAuth 정보가 없는지 확인한다.

### 소스 설정을 직접 수정할 때

```sh
cd "$HOME/.dotfiles"
chezmoi edit "$HOME/.config/zed/settings.json"
chezmoi diff
chezmoi apply --verbose
chezmoi status --exclude=scripts
git diff
git status
git add <변경한-파일>
git commit -m "chore: 설정 갱신"
git push
```

`chezmoi edit`는 대상 경로에 대응하는 소스를 편집한다. 루트
`Brewfile`, 루트 `CLAUDE.md`, `home/` 아래의 템플릿을 편집기로
직접 수정해도 같은 `diff → apply → status → Git` 순서를 사용한다.

### 앱이 홈의 일반 대상을 수정했을 때

`.tmpl`로 관리하지 않는 일반 파일은 현재 대상을 소스로 다시
가져온다. 다음은 CC Switch 설정 예시다.

```sh
cd "$HOME/.dotfiles"
chezmoi diff "$HOME/.cc-switch/settings.json"
chezmoi re-add "$HOME/.cc-switch/settings.json"
chezmoi diff
chezmoi apply --verbose
chezmoi status --exclude=scripts
git diff
git status
git add home/dot_cc-switch/private_settings.json
git commit -m "chore: CC Switch 설정 갱신"
git push
```

### 앱이 홈의 템플릿 대상을 수정했을 때

`chezmoi re-add`는 템플릿을 덮어쓰지 않는다. Zed, Ghostty, Zsh처럼
`.tmpl`로 관리하는 대상에는 `chezmoi merge`를 사용할 수 있다.
`chezmoi merge`는 소스를 자동으로 갱신하지 않는다. 기본 병합 도구는 홈의
대상 파일, 실제 소스 템플릿, 렌더링된 대상 파일을 연다. 원하는
변경을 소스 템플릿 창에 병합한 뒤 그 파일을 저장해야 한다.
저장하지 않고 종료하면 변경이 반영되지 않는다.

```sh
cd "$HOME/.dotfiles"
chezmoi diff "$HOME/.config/zed/settings.json"
chezmoi merge "$HOME/.config/zed/settings.json"
git diff -- home/dot_config/zed/settings.json.tmpl
chezmoi diff "$HOME/.config/zed/settings.json"
chezmoi apply --verbose
chezmoi status --exclude=scripts
git diff
git status
git add home/dot_config/zed/settings.json.tmpl
git commit -m "chore: Zed 설정 갱신"
git push
```

병합 직후 `git diff -- home/dot_config/zed/settings.json.tmpl`에서 원하는
소스 변경을 확인한 때만 대상 `diff`와 `apply`로 계속한다. 소스
변경이 없다면 적용하지 말고 병합 도구를 다시 열어 소스 템플릿을
저장한다.

병합 대신 `~/.dotfiles/home/`의 대응 템플릿에 수동으로 반영해도
된다. Zed는 `home/dot_config/zed/settings.json.tmpl`, Ghostty는
`home/dot_config/ghostty/config.ghostty.tmpl`, Zsh는 `home/dot_zshrc.tmpl`이다.
수동 반영 후에도 위와 같이 `diff`, `apply`, `status`, Git 순서를 모두
실행한다.

### macOS 패키지를 바꿀 때

```sh
cd "$HOME/.dotfiles"
$EDITOR Brewfile
chezmoi diff
chezmoi apply --verbose
chezmoi status --exclude=scripts
git diff
git status
git add Brewfile
git commit -m "chore: Brewfile 갱신"
git push
```

`Brewfile` 변경은 스크립트 체크섬을 바꾸므로 다음 `apply`에서
`brew bundle --no-upgrade`를 다시 실행한다.

### mise 도구를 바꿀 때

```sh
cd "$HOME/.dotfiles"
chezmoi edit "$HOME/.config/mise/config.toml"
chezmoi diff
chezmoi apply --verbose
chezmoi status --exclude=scripts
git diff
git status
git add home/dot_config/mise/config.toml
git commit -m "chore: mise 도구 갱신"
git push
```

`home/dot_config/mise/config.toml`의 `[tools]`를 바꾸면 체크섬이
바뀌고 `mise install --yes`가 실행된다. Homebrew와 chezmoi 자체의
설치는 이 자동화 범위에 포함되지 않는다.

## 원격 변경 받기

소스 Git 변경을 가져와 바로 적용하는 자동 흐름은 다음과 같다.

```sh
chezmoi update
```

적용 전 변경을 직접 검토하려면 Git 갱신과 chezmoi 적용을 분리한다.

```sh
cd "$HOME/.dotfiles"
git pull --ff-only
chezmoi diff
chezmoi apply --verbose
chezmoi status --exclude=scripts
```

## 진단

```sh
chezmoi doctor
chezmoi status
chezmoi diff --exclude=scripts
chezmoi managed
```

- `chezmoi doctor`는 설정, 경로, 외부 명령 상태를 점검한다.
- `chezmoi status`는 소스와 대상의 변경 상태를 보여 준다.
- `chezmoi diff --exclude=scripts`는 반복 실행 스크립트를 빼고 파일 차이만
  보여 준다.
- `chezmoi managed`는 현재 플랫폼에서 chezmoi가 관리하는 경로를 나열한다.
