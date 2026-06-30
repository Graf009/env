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

# node runtime managed by mise — activated in Phase 3