# Chezmoi Migration Design

## Goal

Replace the current GNU Stow layout with a chezmoi source state that applies the
existing configuration to Windows, macOS, and Linux without running Unix shell
setup on Windows.

The migration preserves the current configuration content unless a platform
conditional is required for correctness. It also moves installation side
effects out of `.zprofile` and into one idempotent chezmoi bootstrap script.

## Scope

The managed configuration is:

- Shared personal instructions for Claude Code and Codex on all platforms.
- Shared agent skills under `~/.agents/skills/` on all platforms.
- Zed settings and keymap on Windows, macOS, and Linux.
- Zsh, Spaceship, Oh My Tmux, and LazyVim setup on macOS and Linux.
- Ghostty configuration and theme on macOS and Linux.
- A local Neovim installation on Linux only.
- Windows Terminal Stable settings on Windows only.

Installing applications such as Zed, Ghostty, Windows Terminal, and chezmoi is
outside this migration. Windows Terminal is assumed to be the Stable MSIX
package installed with `winget`.

## Repository Layout

The repository root remains suitable for documentation and development files.
`.chezmoiroot` points chezmoi at the `home/` subdirectory:

```text
.chezmoiroot
README.md
docs/
tests/
home/
  .chezmoiignore
  dot_zprofile
  dot_zshrc.tmpl
  dot_tmux.conf.local
  symlink_dot_tmux.conf
  dot_agents/
    skills/
      find-skills/SKILL.md
  dot_claude/CLAUDE.md.tmpl
  dot_codex/AGENTS.md.tmpl
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
```

The existing uncommitted move of Zed files into `zsh/.config/zed/` is treated
as the latest user-owned version and becomes the input for `home/dot_config/zed/`.
Unrelated user changes are not reverted or reformatted.

## Platform Mapping

| Target | Windows | macOS | Linux |
| --- | --- | --- | --- |
| `~/.agents/skills/` | yes | yes | yes |
| `~/.claude/CLAUDE.md` | yes | yes | yes |
| `~/.codex/AGENTS.md` | yes | yes | yes |
| `~/.config/zed/settings.json` | yes | yes | yes |
| `~/.config/zed/keymap.json` | yes | yes | yes |
| `~/.zshrc` and `~/.zprofile` | no | yes | yes |
| `~/.config/spaceship.zsh` | no | yes | yes |
| `~/.tmux.conf.local` and `~/.tmux.conf` | no | yes | yes |
| `~/.config/ghostty/` | no | yes | yes |
| Windows Terminal Stable `settings.json` | yes | no | no |
| Local Neovim binary | no | no | yes |

Zed deliberately keeps its XDG location on all three platforms. Ghostty also
uses its supported XDG location on macOS and Linux. Windows Terminal is written
to `AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`
under the Windows home directory; the repository's old
`windows_terminal.json` name is not retained as a target name.

`.chezmoiignore` excludes all Unix-only targets on Windows and excludes the
Windows Terminal target on macOS and Linux.

## Templates

The repository-root `CLAUDE.md` is the single source for personal agent
instructions. `dot_claude/CLAUDE.md.tmpl` and `dot_codex/AGENTS.md.tmpl`
include that file through `.chezmoi.workingTree`. Chezmoi therefore writes
identical regular files to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`
without requiring symlink support on Windows.

The current `~/.agents/skills/find-skills/SKILL.md` is managed as a regular
cross-platform file. The `~/.agents/skills/` directory is not exact, so skills
installed by another tool are not removed. `~/.agents/.skill-lock.json` remains
unmanaged.

`dot_zshrc.tmpl` preserves the current shell configuration. Its local Neovim
`PATH` entry is emitted only on Linux and uses the archive directory selected
for the current architecture.

`dot_config/ghostty/config.ghostty.tmpl` preserves shared options and emits
macOS-only options, including `macos-*` keys, only on macOS. Linux receives the
portable subset and the same Catppuccin theme file.

`dot_config/zed/settings.json.tmpl` preserves the existing JSONC settings. The
hard-coded Windows Kotlin language-server path is emitted only on Windows and
is rooted at chezmoi's Windows home directory instead of a literal username.

The managed `.zprofile` contains no network installation logic. It remains a
managed file so the old Stow symlink is replaced cleanly during migration.

## Bootstrap

`run_once_before_10-bootstrap.sh.tmpl` renders to an empty string on Windows, so
chezmoi does not execute it there. On macOS and Linux it is idempotent and:

1. Installs Oh My Zsh only when `~/.oh-my-zsh` is absent.
2. Clones Spaceship only when its theme directory is absent.
3. Clones Oh My Tmux only when `~/.tmux` is absent.
4. Clones the LazyVim starter only when `~/.config/nvim` is absent.
5. On Linux only, installs the current Neovim release when neither a suitable
   local binary nor a sufficiently recent system `nvim` is available.

Chezmoi manages the Spaceship and tmux compatibility symlinks after the
bootstrap has created their parent directories. The script checks required
commands before network work and exits with a clear error if a prerequisite is
missing. Existing clones and local changes are never updated or overwritten.

Because `run_once_` state is based on rendered script content, a changed script
may run again, but all operations remain guarded by existence and version
checks.

## Migration And Daily Use

The README documents both workflows:

- Existing checkout: run chezmoi with this repository as its source and inspect
  `chezmoi diff` before the first apply.
- New machine: initialize chezmoi from the Git repository and apply it.

The first apply replaces managed Stow symlinks with regular files or the
explicit chezmoi-managed symlinks. It does not remove unrelated files from the
home directory. Stow is no longer required after the migration.

## Error Handling

- Unsupported operating systems receive only targets that are explicitly
  shared; Unix bootstrap code is not executed on Windows.
- Unsupported Linux CPU architectures fail before downloading Neovim and name
  the unsupported architecture.
- Failed downloads or clones stop the bootstrap and leave existing
  configuration untouched.
- Chezmoi template errors stop before apply rather than producing partial
  platform-specific files.

## Verification

A shell test script drives the installed chezmoi binary against temporary
destinations. It overrides `.chezmoi.os` and `.chezmoi.arch` to exercise
Windows, macOS, Linux amd64, and Linux arm64 without modifying the real home
directory.

The checks verify:

- Each platform manages exactly the intended target paths.
- Rendered Claude Code and Codex instruction files are byte-for-byte identical
  to the repository-root `CLAUDE.md`.
- The managed agent skill is present on every platform, while
  `~/.agents/AGENTS.md` and `.skill-lock.json` remain unmanaged.
- Windows Terminal is named `settings.json` at the Stable MSIX path.
- Unix shell, tmux, and Ghostty files are absent from the Windows target state.
- The bootstrap renders empty on Windows, excludes Neovim on macOS, and includes
  the matching Neovim archive on Linux.
- Rendered Zsh files and Unix bootstrap scripts pass shell syntax checks.
- Windows Terminal settings remain valid JSON.
- `chezmoi apply --dry-run --verbose` succeeds for every simulated platform
  with scripts excluded from execution.

Before completion, the real macOS target is checked with `chezmoi diff`; an
actual apply is performed only after that diff contains the intended Stow
migration changes.

## References

- <https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/>
- <https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/>
- <https://learn.microsoft.com/en-us/windows/terminal/faq>
- <https://ghostty.org/docs/config>
- <https://zed.dev/faq>
- <https://code.claude.com/docs/en/memory>
- <https://openai.com/index/unrolling-the-codex-agent-loop/>
