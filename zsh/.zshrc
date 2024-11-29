# functions

register_alias_if_exists() {
  if hash $1 2>/dev/null; then
    alias $2=$1
  fi
}

# environment variables

## zsh
HISTSIZE=1000000
SAVEHIST=1000000
setopt SHARE_HISTORY
setopt HIST_VERIFY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt INTERACTIVE_COMMENTS

## HOME
ZIM_HOME=$HOME/.zim
LAZY_VIM_HOME=$HOME/.config/nvim
HOMEBREW_PATH=/opt/homebrew/bin/brew

if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ -e $HOMEBREW_PATH ]]; then
    eval $($HOMEBREW_PATH shellenv)
  fi

  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi


# install

## tmux
if [[ ! -e ${HOME}/.tmux ]]; then
  git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux
  ln -s -f .tmux/.tmux.conf $HOME/.tmux.conf
fi

## zim
zstyle ':zim:zmodule' use 'degit'
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

source ${ZIM_HOME}/init.zsh

## lazyvim
if [[ ! -e ${LAZY_VIM_HOME} ]]; then
  git clone https://github.com/LazyVim/starter ${LAZY_VIM_HOME}
fi

# alias
register_alias_if_exists nvim vim
register_alias_if_exists nvim vi
register_alias_if_exists eza ls
register_alias_if_exists htop top


# etc
export TERM="xterm-256color"

if [[ -e "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi

if [[ -e "$HOME/.local/bin/uv" ]]; then
  eval "$(uv generate-shell-completion zsh)"
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniforge3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "$HOME/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "$HOME/miniforge3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<


