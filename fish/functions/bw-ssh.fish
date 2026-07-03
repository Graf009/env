function bw-ssh --description 'Install SSH keys from Bitwarden (native SSH-key items) into ~/.ssh and ssh-agent'
    _bw_ensure_unlocked; or return 1

    # Convention: store each key as a Bitwarden "SSH key" item (type 5) named
    # exactly after the key file, e.g. an SSH-key item called "id_graf009".
    set -l keys id_graf009 id_ecom

    # Ensure ~/.ssh exists with the right permissions.
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    for key in $keys
        # Fetch the item once as a single JSON blob (string collect keeps
        # newlines intact for jq instead of splitting into a list).
        set -l json (bw get item "$key" 2>/dev/null | string collect)
        if test -z "$json"
            echo "⚠  Bitwarden: item '$key' not found — skipping"
            continue
        end

        set -l priv (printf '%s' $json | jq -r '.sshKey.privateKey // empty')
        set -l pub (printf '%s' $json | jq -r '.sshKey.publicKey // empty')

        if test -z "$priv"
            echo "⚠  '$key' is not an SSH-key item (no private key) — skipping"
            continue
        end

        # Save the private key (persisted for use as IdentityFile).
        set -l dest ~/.ssh/$key
        printf '%s\n' $priv >$dest
        chmod 600 $dest

        # Save the public key from the item (needed for IdentitiesOnly matching).
        if test -n "$pub"
            printf '%s\n' $pub >$dest.pub
            chmod 644 $dest.pub
        end

        # Also load into the running ssh-agent for this session.
        ssh-add $dest 2>/dev/null
        and echo "✓  Installed $key → $dest (and added to ssh-agent)"
        or echo "✗  ssh-add failed for $key (key saved at $dest)"
    end
end
