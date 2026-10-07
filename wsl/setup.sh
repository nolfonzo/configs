#!/usr/bin/env bash
# Bootstrap this shell environment on a fresh Ubuntu/Debian box (WSL or not).
#
#   git clone https://github.com/nolfonzo/configs.git
#   bash configs/wsl/setup.sh
#
# Idempotent: safe to re-run. Never overwrites an existing config without
# first moving it aside to <name>.bak-<date>.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d)"

say() { printf '\n\033[1;33m== %s\033[0m\n' "$*"; }

backup_then_copy() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
    mv "$dst" "${dst}.bak-${STAMP}"
    echo "   existing $(basename "$dst") saved as $(basename "$dst").bak-${STAMP}"
  fi
  cp "$src" "$dst"
  echo "   installed $(basename "$dst")"
}

say "packages"
# fzf/ripgrep/fd/zoxide are all in Ubuntu 24.04+; no need for Homebrew just
# for these. On older releases install them yourself or via brew.
sudo apt-get update -qq
sudo apt-get install -y -qq \
  zsh tmux git curl wget neovim \
  fzf ripgrep fd-find zoxide \
  bat eza btop lazygit git-delta \
  xauth                      # needed for `ssh -X` GUI forwarding
# Ubuntu ships bat and fd as batcat and fdfind; .zshrc and the fzf settings
# call them by their upstream names.
mkdir -p "$HOME/.local/bin"
command -v bat >/dev/null || ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
command -v fd  >/dev/null || ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
echo "   done"

say "oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "   already present"
else
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

say "theme + plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_if_missing() {
  local url="$1" dst="$2"
  if [ -d "$dst" ]; then echo "   $(basename "$dst"): present"
  else git clone -q --depth=1 "$url" "$dst" && echo "   $(basename "$dst"): cloned"; fi
}
clone_if_missing https://github.com/romkatv/powerlevel10k.git          "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

say "config files"
backup_then_copy "$REPO_DIR/.zshrc"     "$HOME/.zshrc"
backup_then_copy "$REPO_DIR/.p10k.zsh"  "$HOME/.p10k.zsh"
backup_then_copy "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"

say "default shell"
if [ "$(basename "${SHELL:-}")" = "zsh" ]; then
  echo "   already zsh"
else
  chsh -s "$(command -v zsh)" && echo "   set to zsh (takes effect next login)"
fi

say "done"
cat <<'DONE'
   Open a new shell, or: exec zsh

   Notes:
   - Nerd Font is a CLIENT-side setting. Install one in your terminal app
     (Windows Terminal / Ghostty / iTerm), not on this machine.
   - tmux prefix is Ctrl+a, not the default Ctrl+b.
   - LazyVim needs nvim 0.11+. Older Ubuntu's apt neovim is too old; use the
     official release tarball in /opt (minipc-wsl runs Homebrew's 0.12.4).
   - yazi is not in apt: use the release zip from github.com/sxyazi/yazi.
   - Per-machine aliases go in ~/.zshrc.local, which .zshrc sources last.
   - If tmux copy does not reach the system clipboard, the terminal must
     allow OSC 52 writes. Windows Terminal allows it by default
     (compatibility.allowOSC52).
DONE
