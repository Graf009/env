function bw-env --description 'Load env vars from Bitwarden secure note into ~/.fish.env'
    _bw_ensure_unlocked; or return 1

    # Store all KEY=value pairs as the body of a secure note named "fish.env"
    set -l content (bw get notes "fish.env" 2>/dev/null)
    if test -z "$content"
        echo "Bitwarden: secure note 'fish.env' not found"
        echo "Create it with KEY=value lines (one per line)"
        return 1
    end

    printf '%s\n' $content >~/.fish.env
    chmod 600 ~/.fish.env
    export (cat ~/.fish.env | xargs -L 1)
    echo "✓  Loaded env vars from Bitwarden → ~/.fish.env"
end
