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