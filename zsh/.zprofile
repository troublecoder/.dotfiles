# oh-my-zsh
if [[ ! -e "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH="$HOME/.oh-my-zsh"

# spaceship prompt
if [[ "$ZSH" == "$HOME/.oh-my-zsh" && -d "$ZSH" ]]; then
  ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

  if [[ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]]; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
  fi

  if [[ ! -e "$ZSH_CUSTOM/themes/spaceship.zsh-theme" ]]; then
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
  fi
fi

# neovim
_local_nvim_dir="$HOME/.local/opt/nvim-linux-x86_64"
_local_nvim_bin="$_local_nvim_dir/bin/nvim"
_install_local_nvim=0

if [[ ! -x "$_local_nvim_bin" ]]; then
  if ! command -v nvim >/dev/null 2>&1; then
    _install_local_nvim=1
  else
    _nvim_version_line="$(nvim --version 2>/dev/null | head -n 1)"

    if [[ "$_nvim_version_line" =~ 'v([0-9]+)\.([0-9]+)\.([0-9]+)' ]]; then
      _nvim_major="${match[1]}"
      _nvim_minor="${match[2]}"
      _nvim_patch="${match[3]}"

      if (( _nvim_major == 0 && (_nvim_minor < 8 || (_nvim_minor == 8 && _nvim_patch <= 0)) )); then
        _install_local_nvim=1
      fi
    else
      _install_local_nvim=1
    fi
  fi
fi

if (( _install_local_nvim )); then
  mkdir -p "$HOME/.local/opt"
  curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | tar -xzf - -C "$HOME/.local/opt"
fi

unset _install_local_nvim _local_nvim_bin _local_nvim_dir _nvim_major _nvim_minor _nvim_patch _nvim_version_line

# tmux
if [[ ! -e "$HOME/.tmux" ]]; then
  git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  ln -s -f .tmux/.tmux.conf "$HOME/.tmux.conf"
  cp .tmux/.tmux.conf.local $HOME
fi

# lazyvim
if [[ ! -e "$HOME/.config/nvim" ]]; then
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
fi
