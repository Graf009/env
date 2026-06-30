# disable fish greeting
set fish_greeting

set -x LC_ALL en_US.UTF-8
set -x VIRTUAL_ENV_DISABLE_PROMPT off
set PATH ~/bin /usr/local/bin/ /opt/homebrew/bin/ $PATH

# set private environment variables stored outside source control
test -r ~/.fish.env; and export (cat ~/.fish.env|xargs -L 1)


# load my fish functions
for f in (find ~/.config/fish/graf009/ -type f  -name '*.fish')
	source $f
end

# runtime manager (must be in config.fish — conf.d loads before this)
mise activate fish | source

# prompt
starship init fish | source

# shell history
atuin init fish | source

# smart cd
zoxide init fish | source

# fuzzy finder
fzf --fish | source