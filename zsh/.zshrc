export LANG="en_US.UTF-8"
export TERM="xterm-256color"
export VIMRUNTIME=/usr/share/nvim/runtime
export VCPKG_DEFAULT_TRIPLET="x64-linux"

if [[ ! -f ~/.zplug/init.zsh ]]; then
    git clone https://github.com/b4b4r07/zplug ~/.zplug
    source ~/.zplug/init.zsh
else
    source ~/.zplug/init.zsh
fi

zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/zsh_reload", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh

# theme
zplug "agkozak/agkozak-zsh-prompt"

# install & load
zplug check || zplug install
zplug load

# User configuration
case $HOST in
    (*) export EMACS="emacsclient -c -s instance1"
        export CUDA="/opt/cuda"
        ;;
esac

export VISUAL="$EMACS"
export EDITOR="$EMACS"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
alias vi="$EDITOR"
alias vim="$VISUAL"
alias emacs="$EMACS"

if [ -f "/usr/bin/yay"]; then
    alias pacman="yay"
fi
if [ -f "/usr/bin/exa"]; then
   alias ls='exa'
fi
if [ -f "/usr/bin/bat"]; then
    alias cat='bat'
fi

export PATH="$CUDA/bin:$HOME/vcpkg:$PATH"

export LD_LIBRARY_PATH="$CUDA/lib64:$LD_LIBRARY_PATH"
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/anaconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
