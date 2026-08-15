# --- tmux session chooser on interactive login (skipped inside tmux / NO_TMUX=1) ---
if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -z "$NO_TMUX" ] && [[ -o interactive ]]; then
  if command -v fzf >/dev/null 2>&1; then
    _tchoice=$( { print -l '＋ new session'; tmux list-sessions -F '#{session_name}' 2>/dev/null; print -l '✗ no tmux (plain shell)'; } | fzf --reverse --height=40% --prompt='tmux ➜ ' --header='Enter = new session · pick one to attach · Esc = new' )
    case "$_tchoice" in
      '✗ no tmux (plain shell)') ;;
      '＋ new session'|'') exec tmux new-session ;;
      *) exec tmux attach-session -t "$_tchoice" ;;
    esac
    unset _tchoice
  else
    exec tmux new-session
  fi
fi



# Powerlevel10k instant prompt. Keep near the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim="nvim"
alias vi="nvim"
#
# Pyenv Configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


export PATH="/home/nolfonzo/.local/bin:$PATH"

# SSH with FZF
function s() {
  host=$(grep "^Host " ~/.ssh/config | awk '{print $2}' | fzf)
  
  if [ -n "$host" ]; then
    echo "Connecting to $host..."
    ssh "$host"
  fi
}
# Type 'v' to fuzzy find a file and open in nvim
function v() {
  file=$(fzf)
  if [ -n "$file" ]; then
    nvim "$file"
  fi
}
eval "$(zoxide init zsh)"

# Custom Prompt: Hostname + RobbyRussell Arrow logic
# disabled-for-p10k PROMPT='%{$fg[yellow]%}%n@%m %{$reset_color%}%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

# --- HISTORY SETTINGS ---
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS  # Don't record dupes
setopt HIST_REDUCE_BLANKS    # Remove superflous blanks
setopt SHARE_HISTORY         # Share history between tabs

# --- UP ARROW HISTORY SEARCH ---
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export PATH=$PATH:/snap/bin
export PATH=/opt/zig:$PATH
export PATH=/opt/zig:$PATH
export PATH="$HOME/.local/bin:$PATH"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# Powerlevel10k config (copied from Mac)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ls inverted-color fix: no green/blue background for world-writable dirs (WSL /mnt)
[ -z "$LS_COLORS" ] && eval "$(dircolors -b)"
export LS_COLORS="${LS_COLORS}:ow=01;34:tw=01;34:st=01;34"
