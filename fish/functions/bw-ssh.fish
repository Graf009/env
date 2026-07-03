function bw-ssh --description 'Install SSH private keys from Bitwarden into ~/.ssh and ssh-agent'
    _bw_ensure_unlocked; or return 1

    # Convention: store each private key as a Bitwarden secure note
    # named exactly "SSH key: <filename>", e.g. "SSH key: id_graf009"
    set -l keys id_graf009 id_ecom

    # Ensure ~/.ssh exists with the right permissions.
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    for key in $keys
        set -l content (bw get notes "SSH key: $key" 2>/dev/null)
        if test -z "$content"
            echo "⚠  Bitwarden: note 'SSH key: $key' not found — skipping"
            continue
        end

        # Save the private key to ~/.ssh (persisted for use as IdentityFile).
        set -l dest ~/.ssh/$key
        printf '%s\n' $content >$dest
        chmod 600 $dest

        # Derive the public key — needed so IdentitiesOnly can match the key.
        if ssh-keygen -y -f $dest >$dest.pub 2>/dev/null
            chmod 644 $dest.pub
        else
            rm -f $dest.pub
            echo "⚠  Could not derive $key.pub (passphrase-protected?)"
        end

        # Also load into the running ssh-agent for this session.
        ssh-add $dest 2>/dev/null
        and echo "✓  Installed $key → $dest (and added to ssh-agent)"
        or echo "✗  ssh-add failed for $key (key saved at $dest)"
    end
end
