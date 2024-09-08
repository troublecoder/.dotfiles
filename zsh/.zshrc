HOMEBREW_PATH=/opt/homebrew/bin/brew
if [[ -e $HOMEBREW_PATH ]]; then
  eval $($HOMEBREW_PATH shellenv)
fi

zstyle ':zim:zmodule' use 'degit'

ZIM_HOME=$HOME/.zim

register_alias_if_exists() {
  if hash $1 2>/dev/null; then
    alias $2=$1
  fi
}

#### install
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

if [[ ! -e ${HOME}/.tmux ]]; then
  git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux
  ln -s -f .tmux/.tmux.conf $HOME/.tmux.conf
fi

if [[ ! -e ${HOME}/.SpaceVim ]]; then
  curl -sLf https://spacevim.org/install.sh | bash
fi

if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

source ${ZIM_HOME}/init.zsh

#### alias
register_alias_if_exists nvim vim
register_alias_if_exists nvim vi
register_alias_if_exists eza ls
register_alias_if_exists htop top


#### etc
export PATH="$HOME/.poetry/bin:$PATH"
export TERM="xterm-256color"

if [[ `uname` == *"Linux"* ]]; then
  export "DISPLAY=localhost:10.0"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"