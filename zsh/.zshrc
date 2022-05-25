if hash brew 2>/dev/null;then
  eval $(/opt/homebrew/bin/brew shellenv)
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
register_alias_if_exists bat cat
register_alias_if_exists exa ls
register_alias_if_exists dust du
register_alias_if_exists duf df
register_alias_if_exists ng grep
register_alias_if_exists procs ps
register_alias_if_exists htop top
register_alias_if_exists yay pacman


#### etc
export PATH="$HOME/.poetry/bin:$PATH"
export TERM="xterm-256color"

if [[ `uname` == *"Linux"* ]]; then
  export "DISPLAY=localhost:10.0"
fi

export CONDA_HOME="$HOME/miniforge3"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$($CONDA_HOME/bin/conda 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$CONDA_HOME/etc/profile.d/conda.sh" ]; then
        . "$CONDA_HOME/etc/profile.d/conda.sh"
    else
        export PATH="$CONDA_HOME/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

