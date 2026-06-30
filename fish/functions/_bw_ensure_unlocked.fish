function _bw_ensure_unlocked --description 'Ensure Bitwarden vault is unlocked; set BW_SESSION'
    set -l bw_status (bw status 2>/dev/null | jq -r '.status' 2>/dev/null)

    switch $bw_status
        case unauthenticated
            echo "Bitwarden: not logged in — run: bw login"
            return 1
        case locked
            set -l session (bw unlock --raw)
            if test $status -ne 0
                echo "Bitwarden: unlock failed"
                return 1
            end
            set -gx BW_SESSION $session
        case unlocked
            # already unlocked, nothing to do
        case '*'
            echo "Bitwarden: unexpected status '$bw_status' (is bw installed?)"
            return 1
    end
end
