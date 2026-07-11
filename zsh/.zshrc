# ─── Oh My Zsh ──────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ─── History ────────────────────────────────────────────────
HISTSIZE=1000000
SAVEHIST=1000000

setopt SHARE_HISTORY
setopt HIST_VERIFY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt INTERACTIVE_COMMENTS

# ─── Environment ────────────────────────────────────────────
export TERM="xterm-256color"

# EDITOR / VISUAL: zed when available, else nvim/vim
if command -v zed >/dev/null 2>&1; then
  export EDITOR="zed --wait"
  export VISUAL="zed --wait"
elif command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
  export VISUAL="nvim"
else
  export EDITOR="vim"
  export VISUAL="vim"
fi

# PATH: pixi
export PATH="$HOME/.pixi/bin:$PATH"

# PATH: local nvim
_local_nvim_bin="$HOME/.local/opt/nvim-linux-x86_64/bin"
[[ -d "$_local_nvim_bin" ]] && export PATH="$_local_nvim_bin:$PATH"
unset _local_nvim_bin

# local env loader
[[ -e "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# ─── Aliases ────────────────────────────────────────────────
register_alias_if_exists() {
  if command -v "$1" >/dev/null 2>&1; then
    alias "$2"="$1"
  fi
}

register_alias_if_exists nvim vim
register_alias_if_exists nvim vi
register_alias_if_exists eza ls
register_alias_if_exists htop top

# ─── Tool Integrations ─────────────────────────────────────

# uv
command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion zsh)"

# mise
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

# rustup
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
