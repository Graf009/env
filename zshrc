# History
HISTSIZE=1000
SAVEHIST=1000

# Colors
autoload -U colors && colors

# Key bindings
bindkey -e
bindkey ';5D' backward-word # ctrl+left
bindkey ';5C' forward-word  # ctrl+right

# Zsh plugins
if [ -f ~/.antigen.zsh ]; then
  ANTIGEN_MUTEX=false
  source ~/.antigen.zsh
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle zsh-users/zsh-history-substring-search
  antigen bundle zsh-users/zsh-completions
  antigen apply
fi

# Completion
zstyle :compinstall filename '/home/ai/.zshrc'
autoload -Uz compinit
compinit

# Prompt
eval "$(starship init zsh)"

# Fast way to projects
if [ -d ~/project ]; then
  cdpath=(. ~/project)
fi

# Dev tools
# if [ -d ~/.asdf/ ]; then
#   source $HOME/.asdf/asdf.sh
#   autoload -U +X bashcompinit && bashcompinit
#   source $HOME/.asdf/completions/asdf.bash
# fi

# Rip Grep
export RIPGREP_CONFIG_PATH=~/.ripgreprc

# Console editor
export EDITOR=micro

# VS Code
export ELECTRON_TRASH=gio
alias e='code .'

# Aliases
alias g='git'
alias ..='cd ..'
alias l='exa --all'
alias ll='exa --long --all --git'
alias cat='bat'

# Node.js
alias n='pnpm '
alias pui='pnpm update --interactive --latest -r --include-workspace-root'
alias pu='pnpm update -r --include-workspace-root'
alias ptr='pnpm test -r --include-workspace-root'
alias p='n clean-publish'
alias pui1='pnpm update --interactive --latest'
alias pu1='pnpm update'

# pnpm
export PNPM_HOME="~/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Python
export PATH=~/.local/bin/:$PATH