function brewcheck --description 'Show drift between the Brewfile and installed packages (read-only)'
    # Uses $HOMEBREW_BUNDLE_FILE (set in conf.d/env.fish); fall back to the repo copy.
    set -l bf $HOMEBREW_BUNDLE_FILE
    test -n "$bf"; or set bf ~/project/public/dotfiles/Brewfile
    if not test -r "$bf"
        echo "brewcheck: Brewfile not found at $bf"
        return 1
    end

    echo "Brewfile: $bf"
    echo
    echo "── declared but MISSING (in Brewfile, not installed) ──"
    brew bundle check --verbose --file=$bf

    echo
    echo "── installed but NOT in Brewfile (ad-hoc; nothing is removed) ──"
    # cleanup without --force is a dry run: it only prints what WOULD be removed
    brew bundle cleanup --file=$bf
end
