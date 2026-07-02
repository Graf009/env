function brewcheck --description 'Show drift between the Brewfile and installed packages (read-only)'
    # Uses $HOMEBREW_BUNDLE_FILE (set in conf.d/env.fish); otherwise derive the
    # repo root from the ~/bin symlink (-> repo/bin).
    set -l bf $HOMEBREW_BUNDLE_FILE
    if test -z "$bf"; and test -L ~/bin
        set bf (path dirname (path resolve ~/bin))/Brewfile
    end
    if not test -r "$bf"
        echo "brewcheck: Brewfile not found (set HOMEBREW_BUNDLE_FILE or symlink ~/bin)"
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
