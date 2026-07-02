# Console editor
set -gx EDITOR micro

# Homebrew: point `brew bundle` (and brewcheck) at this repo's Brewfile from
# any directory. Derive the repo root from the ~/bin symlink (-> repo/bin) so
# it works regardless of where the repo is cloned.
if test -L ~/bin
    set -l _repo (path dirname (path resolve ~/bin))
    test -r $_repo/Brewfile; and set -gx HOMEBREW_BUNDLE_FILE $_repo/Brewfile
end

# Ripgrep config (XDG path — matched by install.conf.yaml link ~/.config/ripgreprc)
set -gx RIPGREP_CONFIG_PATH ~/.config/ripgreprc

# pnpm
set -gx PNPM_HOME ~/.local/share/pnpm
fish_add_path $PNPM_HOME

# Go (mise owns the runtime; keep GOPATH for go install'd tools)
set -gx GOPATH $HOME/go
fish_add_path $GOPATH/bin
if set -q GOROOT
    fish_add_path $GOROOT/bin
end

# VS Code trash handler
set -gx ELECTRON_TRASH gio

# Local binaries
fish_add_path ~/.local/bin

# V8 compile cache (speeds up Node.js startup)
set -gx NODE_COMPILE_CACHE ~/.cache/node

# bat theme (works in any terminal)
set -gx BAT_THEME ansi

# XDG-compliant Claude config path
if test -d ~/.local/share/claude
    set -gx CLAUDE_CONFIG_DIR ~/.local/share/claude
end

# Private local overrides — gitignored, never committed
if test -r ~/.config/local/yandex.fish
    source ~/.config/local/yandex.fish
end
