# Navigation
abbr --add -- .. 'cd ..'
abbr --add cd z

# Git
abbr --add g git

# Editor
abbr --add e 'code .'

# Claude Code
abbr --add cc 'claude --dangerously-skip-permissions'

# Modern unix replacements
abbr --add l 'eza --all'
abbr --add ll 'eza --long --all --git'
abbr --add ls eza
abbr --add cat bat
abbr --add dig doggo

# Tool wrappers (interactive-only; keep real binaries available in scripts)
abbr --add mtr 'sudo mtr'
abbr --add first-time-ssh 'kitty +kitten ssh'

# pnpm
abbr --add n 'pnpm '
abbr --add pui 'pnpm update --interactive --latest -r --include-workspace-root'
abbr --add pu 'pnpm update -r --include-workspace-root'
abbr --add ptr 'pnpm test -r --include-workspace-root'
abbr --add p 'n clean-publish'
abbr --add pui1 'pnpm update --interactive --latest'
abbr --add pu1 'pnpm update'
