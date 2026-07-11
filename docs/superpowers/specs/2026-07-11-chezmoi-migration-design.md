# Chezmoi 전환 설계

## 목표

현재 GNU Stow 구조를 chezmoi 소스 상태로 전환한다. Windows, macOS,
Linux에서 각 운영체제에 맞는 설정만 적용하고 Windows에서는 Unix 셸
설치 작업을 실행하지 않는다.

기존 설정 내용은 플랫폼 분기가 필요한 부분을 제외하고 그대로 보존한다.
`.zprofile`에 있던 설치 부작용은 멱등성을 갖춘 chezmoi 부트스트랩
스크립트 하나로 옮긴다.

## 언어 원칙

이번 작업에서 새로 작성하거나 수정하는 README, 설계 문서, 안내 문구,
테스트 메시지와 코드 주석은 한국어로 작성한다. 파일명, 명령어, 설정 키,
제품명, URL처럼 도구가 요구하는 고유 표기는 원문을 유지한다. 기존 설정
내용은 동작 보존이 우선이므로 요청과 무관한 문자열은 번역하지 않는다.

## 관리 범위

관리 대상은 다음과 같다.

- 모든 플랫폼의 Claude Code 및 Codex 공통 개인 지침
- 모든 플랫폼의 `~/.agents/skills/` 공통 스킬
- 모든 플랫폼의 CC Switch 기기 설정
- 모든 플랫폼의 Zed 설정과 키맵
- macOS와 Linux의 Zsh, Spaceship, Oh My Tmux, LazyVim 구성
- macOS와 Linux의 Ghostty 설정과 테마
- Linux 전용 로컬 Neovim 설치
- Windows 전용 Windows Terminal Stable 설정

Zed, Ghostty, Windows Terminal, CC Switch, chezmoi 애플리케이션 자체의
설치는 범위에서 제외한다. Windows Terminal은 `winget`으로 설치한 Stable
MSIX 패키지를 기준으로 한다.

## 저장소 구조

저장소 루트는 문서와 개발 파일을 둘 수 있도록 유지한다. `.chezmoiroot`가
`home/` 하위 디렉터리를 chezmoi 소스 상태로 지정한다.

```text
.chezmoiroot
README.md
docs/
tests/
home/
  .chezmoiignore
  .chezmoi.toml.tmpl
  dot_zprofile
  dot_zshrc.tmpl
  dot_tmux.conf.local
  symlink_dot_tmux.conf
  dot_agents/
    skills/
      find-skills/SKILL.md
  dot_cc-switch/private_settings.json
  dot_claude/CLAUDE.md.tmpl
  dot_config/
    spaceship.zsh
    ghostty/
      config.ghostty.tmpl
      themes/catppuccin-mocha.conf
    zed/
      keymap.json
      settings.json.tmpl
  AppData/Local/Packages/
    Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
  run_once_before_10-bootstrap.sh.tmpl
  run_after_90-link-agent-instructions.ps1.tmpl
  run_after_90-link-agent-instructions.sh.tmpl
```

현재 커밋되지 않은 `zsh/.config/zed/` 이동 결과를 최신 사용자 변경으로
간주하고 `home/dot_config/zed/`의 입력으로 사용한다. 관련 없는 사용자
변경은 되돌리거나 다시 포맷하지 않는다.

`.chezmoi.toml.tmpl`은 `sourceDir`을 항상 `~/.dotfiles`로 설정한다. 현재
Git 저장소를 그대로 chezmoi 작업 트리로 사용하며, 별도의 Git 저장소나
기본 `~/.local/share/chezmoi` 소스 디렉터리를 만들지 않는다.

## 플랫폼별 대상

| 대상 | Windows | macOS | Linux |
| --- | --- | --- | --- |
| `~/.agents/skills/` | 예 | 예 | 예 |
| `~/.cc-switch/settings.json` | 예 | 예 | 예 |
| `~/.claude/CLAUDE.md` | 예 | 예 | 예 |
| `~/.codex/AGENTS.md` | 예 | 예 | 예 |
| `~/.config/zed/settings.json` | 예 | 예 | 예 |
| `~/.config/zed/keymap.json` | 예 | 예 | 예 |
| `~/.zshrc`, `~/.zprofile` | 아니요 | 예 | 예 |
| `~/.config/spaceship.zsh` | 아니요 | 예 | 예 |
| `~/.tmux.conf.local`, `~/.tmux.conf` | 아니요 | 예 | 예 |
| `~/.config/ghostty/` | 아니요 | 예 | 예 |
| Windows Terminal Stable `settings.json` | 예 | 아니요 | 아니요 |
| 로컬 Neovim 바이너리 | 아니요 | 아니요 | 예 |

Zed는 세 플랫폼 모두 XDG 경로를 사용한다. Ghostty도 macOS와 Linux에서
지원되는 XDG 경로를 사용한다. Windows Terminal 설정은 Windows 홈 아래의
`AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`
으로 배치한다. 기존 저장소의 `windows_terminal.json`이라는 이름은 대상
파일명으로 유지하지 않는다.

`.chezmoiignore`는 Windows에서 Unix 전용 대상을 제외하고, macOS와
Linux에서 Windows Terminal 대상을 제외한다.

## 공통 원본과 템플릿

저장소 루트의 `CLAUDE.md` 하나를 개인 에이전트 지침의 단일 원본으로
사용한다. `dot_claude/CLAUDE.md.tmpl`이 `.chezmoi.workingTree`를 통해 이
원본을 `~/.claude/CLAUDE.md`로 배포한다. 적용이 끝난 뒤 운영체제별
`run_after_` 스크립트가 `~/.codex/AGENTS.md`를 이 파일의 하드링크로
만든다. 따라서 두 경로는 같은 파일 데이터를 공유하며 소스 내용은 하나만
유지한다.

macOS와 Linux에서는 `ln`을 사용하고 Windows에서는 PowerShell의
`New-Item -ItemType HardLink`를 사용한다. 두 파일은 모두 같은 홈
파일시스템 안에 있으므로 표준 APFS, ext 계열, NTFS 환경에서 동작한다.
스크립트는 매 적용 뒤 현재 파일 식별자가 같은지 확인하고, 이미 올바른
하드링크라면 아무 작업도 하지 않는다. 링크가 아니면 기존
`~/.codex/AGENTS.md`를 원본과 내용이 같은지 확인한 뒤 교체한다. 내용이
다르면 사용자 변경을 보호하기 위해 파일을 삭제하지 않고 한국어 오류를
출력한 뒤 중단한다.

현재 `~/.agents/skills/find-skills/SKILL.md`는 모든 플랫폼의 일반 파일로
관리한다. `~/.agents/skills/`는 exact 디렉터리로 만들지 않으므로 다른
도구가 설치한 스킬을 삭제하지 않는다. `~/.agents/.skill-lock.json`은
관리하지 않는다. `~/.agents/AGENTS.md`는 만들지 않는다.

현재 `~/.cc-switch/settings.json`은 기기별 값을 걸러내지 않고 JSON
내용을 그대로 보존한다. 소스의 `private_` 속성으로 Unix 계열 대상
권한을 `0600`으로 유지한다. `~/.cc-switch` 아래의 다른 항목은 관리하지
않으며, 특히 `cc-switch.db`, `codex_oauth_auth.json`, 로그, 백업,
skills는 각 기기에 그대로 둔다.

`dot_zshrc.tmpl`은 현재 셸 설정을 보존한다. 로컬 Neovim `PATH`는
Linux에서만 출력하며 현재 아키텍처에 맞는 압축 해제 디렉터리를 사용한다.

`dot_config/ghostty/config.ghostty.tmpl`은 공통 옵션을 유지하고
`macos-*` 키를 포함한 macOS 전용 옵션은 macOS에서만 출력한다. Linux에는
이식 가능한 옵션과 같은 Catppuccin 테마 파일을 적용한다.

Ghostty의 선택 영역은 기존 `selection-background = 353749` 대신
`selection-background = cba6f7`과 `selection-foreground = 1e1e2e`를
사용해 배경과의 대비를 높인다. `copy-on-select = clipboard`와
`clipboard-write = allow`를 유지하여 마우스로 선택한 내용을 즉시 시스템
클립보드에 복사한다.

`dot_config/zed/settings.json.tmpl`은 기존 JSONC 설정을 보존한다.
하드코딩된 Windows Kotlin 언어 서버 경로는 Windows에서만 출력하고,
고정된 사용자명 대신 chezmoi가 제공하는 Windows 홈 경로를 기준으로
생성한다.

관리되는 `.zprofile`에는 네트워크 설치 로직을 넣지 않는다. 기존 Stow
심볼릭 링크를 전환 시 정상적으로 교체할 수 있도록 관리 파일로는 유지한다.

## 부트스트랩

`run_once_before_10-bootstrap.sh.tmpl`은 Windows에서 빈 문자열로
렌더링하여 chezmoi가 실행하지 않게 한다. macOS와 Linux에서는 다음 작업을
멱등하게 수행한다.

1. `~/.oh-my-zsh`가 없을 때만 Oh My Zsh를 설치한다.
2. Spaceship 테마 디렉터리가 없을 때만 Spaceship을 복제한다.
3. `~/.tmux`가 없을 때만 Oh My Tmux를 복제한다.
4. `~/.config/nvim`이 없을 때만 LazyVim starter를 복제한다.
5. Linux에서만 적절한 로컬 바이너리와 충분히 최신인 시스템 `nvim`이
   모두 없을 때 현재 Neovim 릴리스를 설치한다.

부트스트랩이 상위 디렉터리를 만든 뒤 chezmoi가 Spaceship과 tmux 호환
심볼릭 링크를 관리한다. 스크립트는 네트워크 작업 전에 필수 명령을
검사하고, 누락된 도구가 있으면 원인을 한국어로 출력한 뒤 종료한다. 이미
존재하는 복제본과 로컬 변경은 갱신하거나 덮어쓰지 않는다.

`run_once_` 상태는 렌더링된 스크립트 내용에 따라 기록되므로 스크립트가
바뀌면 다시 실행될 수 있다. 모든 작업은 존재 여부와 버전 검사로 보호한다.

## README 요구사항

저장소 루트의 `README.md`는 전부 한국어로 작성하며 다음 내용을 포함한다.

1. chezmoi를 사용하는 이유와 플랫폼별 관리 대상 요약
2. Windows, macOS, Linux에서 chezmoi를 설치하는 방법
3. 현재 `~/.dotfiles` Git 저장소를 chezmoi 소스로 등록하고 상태를 확인한
   뒤 적용하는 방법
4. 새 머신에서 기존 원격 저장소를 `~/.dotfiles`에 복제한 뒤 미리보기와
   적용을 분리해서 실행하는 방법
5. 검토를 생략하고 한 번에 초기화 및 적용하는 선택 명령
6. 원격 변경을 가져와 적용하는 방법
7. 운영체제별 부트스트랩 동작과 관리에서 제외되는 파일

현재 체크아웃에서는 실제 홈을 바꾸기 전에 다음 순서를 안내한다.

```sh
chezmoi --source "$HOME/.dotfiles" init
chezmoi doctor
chezmoi diff
chezmoi apply --verbose
```

새 머신에서는 기존 원격 저장소를 먼저 정해진 위치에 복제한다. 새 Git
저장소를 생성하지 않는다.

```sh
git clone https://github.com/troublecoder/.dotfiles.git "$HOME/.dotfiles"
chezmoi --source "$HOME/.dotfiles" init
chezmoi diff
chezmoi apply --verbose
```

검토를 생략하는 선택 명령은 별도로 표시한다.

```sh
chezmoi --source "$HOME/.dotfiles" init --apply --verbose
```

기본 소스 디렉터리로 초기화한 머신의 갱신 명령도 설명한다.

```sh
chezmoi update
```

Windows PowerShell에서도 `$HOME`과 슬래시 표기를 그대로 사용할 수 있는
명령만 제시한다. 모든 적용 절차에서 `diff` 확인을 기본값으로 두고,
`--force`는 문서에 권장하지 않는다.

README는 현재 Git 저장소가 chezmoi 소스라는 점과 `chezmoi init`이 새
저장소를 만드는 용도가 아니라 `~/.dotfiles`를 등록하고 설정 파일을
생성하는 용도로만 쓰인다는 점을 명시한다.

## 전환과 일상 사용

첫 적용은 관리 대상인 기존 Stow 심볼릭 링크를 일반 파일 또는 명시적인
chezmoi 관리 심볼릭 링크로 교체한다. 홈 디렉터리의 관련 없는 파일은
삭제하지 않는다. 전환 뒤에는 Stow가 필요하지 않다.

새 머신에서 기본 소스 디렉터리로 초기화한 뒤에는 `chezmoi cd`로 소스
저장소에 들어가 일반 Git 명령을 사용할 수 있다. 적용 전에는
`chezmoi status` 또는 `chezmoi diff`로 변경 내용을 확인한다.

## 오류 처리

- 지원하지 않는 운영체제에는 명시적으로 공유하는 대상만 계산하고,
  Windows에서는 Unix 부트스트랩을 실행하지 않는다.
- 지원하지 않는 Linux CPU 아키텍처에서는 Neovim을 다운로드하기 전에
  아키텍처 이름을 포함한 한국어 오류를 출력한다.
- 다운로드나 복제가 실패하면 부트스트랩을 중단하고 기존 설정은 건드리지
  않는다.
- chezmoi 템플릿 오류가 발생하면 적용 전에 중단하여 플랫폼별 파일이
  일부만 생성되는 것을 막는다.
- 하드링크를 지원하지 않거나 두 경로가 서로 다른 파일시스템에 있으면
  원본 파일은 유지하고 한국어 오류를 출력한 뒤 적용을 실패 처리한다.

## 검증

셸 테스트 스크립트가 설치된 chezmoi 바이너리와 임시 대상 디렉터리를
사용한다. `.chezmoi.os`와 `.chezmoi.arch`를 덮어써 Windows, macOS,
Linux amd64, Linux arm64를 실제 홈 수정 없이 검증한다.

검증 항목은 다음과 같다.

- 각 플랫폼이 의도한 대상 경로만 관리한다.
- 렌더링된 Claude Code 및 Codex 지침이 저장소 루트 `CLAUDE.md`와
  바이트 단위로 같고, 실제 적용 뒤 두 대상 경로의 파일 식별자가 같다.
- 모든 플랫폼에 관리 대상 에이전트 스킬이 존재한다.
- `~/.agents/AGENTS.md`와 `.skill-lock.json`은 관리하지 않는다.
- CC Switch 설정은 유효한 JSON이며 `~/.cc-switch` 아래에서 유일하게
  관리되는 파일이다.
- Windows Terminal 파일명이 Stable MSIX 경로의 `settings.json`이다.
- Windows 대상 상태에는 Unix 셸, tmux, Ghostty 파일이 없다.
- Ghostty 선택 영역 색상이 `cba6f7`/`1e1e2e`로 렌더링되고
  `copy-on-select = clipboard`가 유지된다.
- 부트스트랩은 Windows에서 빈 문자열이며, macOS에서 Neovim 설치를
  제외하고, Linux에서 아키텍처에 맞는 Neovim 압축 파일을 선택한다.
- 렌더링된 Zsh 파일과 Unix 부트스트랩이 셸 구문 검사를 통과한다.
- Windows Terminal 설정이 유효한 JSON이다.
- 스크립트 실행을 제외한
  `chezmoi apply --dry-run --verbose`가 모든 모의 플랫폼에서 성공한다.
- README에 적은 핵심 명령이 임시 홈 또는 dry-run 환경에서 성공한다.

완료 전에 실제 macOS 대상을 `chezmoi diff`로 확인한다. 실제 적용은
diff가 의도한 Stow 전환 변경만 포함하는 것을 확인한 뒤 수행한다.

## 참고 자료

- <https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/>
- <https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/>
- <https://www.chezmoi.io/user-guide/setup/>
- <https://www.chezmoi.io/user-guide/command-overview/>
- <https://www.chezmoi.io/reference/target-types/>
- <https://learn.microsoft.com/en-us/windows/terminal/faq>
- <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item>
- <https://ghostty.org/docs/config>
- <https://zed.dev/faq>
- <https://code.claude.com/docs/en/memory>
- <https://openai.com/index/unrolling-the-codex-agent-loop/>
- <https://ccswitch.co/docs/faq-config-files.html>
