eval $(/opt/homebrew/bin/brew shellenv)

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
register_alias_if_exists bat cat
register_alias_if_exists exa ls
register_alias_if_exists dust du
register_alias_if_exists duf df
register_alias_if_exists ng grep
register_alias_if_exists procs ps
register_alias_if_exists htop top
register_alias_if_exists yay pacman


#### etc
eval "$(pyenv init -)"
export PATH="$HOME/.poetry/bin:$PATH"