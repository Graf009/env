function bw-ssh --description 'Load SSH private keys from Bitwarden into ssh-agent'
    _bw_ensure_unlocked; or return 1

    # Convention: store each private key as a Bitwarden secure note
    # named exactly "SSH key: <filename>", e.g. "SSH key: id_orlov"
    set -l keys id_orlov id_dc id_podeli-bnpl

    for key in $keys
        set -l content (bw get notes "SSH key: $key" 2>/dev/null)
        if test -z "$content"
            echo "⚠  Bitwarden: note 'SSH key: $key' not found — skipping"
            continue
        end

        set -l tmp (mktemp)
        chmod 600 $tmp
        printf '%s\n' $content >$tmp
        ssh-add $tmp 2>/dev/null
        and echo "✓  Added $key to ssh-agent"
        or echo "✗  ssh-add failed for $key"
        rm -f $tmp
    end
end
