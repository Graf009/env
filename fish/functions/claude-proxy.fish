# Launch Claude.app through the proxy in $PROXY_URI.
#
# Reads the endpoint from $PROXY_URI (http:// or socks5://, provided by your
# private config) and starts a NEW Claude.app instance with Chromium's
# --proxy-server flag. Fail-closed: refuses to launch if PROXY_URI is unset.
#
#   claude-proxy [extra Claude/Chromium args...]
#
# Notes:
#   - Chromium only reads --proxy-server at startup, and a running Claude
#     instance is reused by macOS. If Claude is already open, quit it fully
#     first or the flag won't apply (the function warns when it detects one).
#   - A credentialed PROXY_URI (user:pass@) is visible in `ps aux` while
#     Claude runs — unavoidable, Chromium reads the flag, not http_proxy env.
#
# Test seam: CLAUDE_PROXY_OPEN overrides the launcher command (default `open`).

function claude-proxy --description 'Launch Claude.app through the proxy in $PROXY_URI (new GUI instance)'
    if not set -q PROXY_URI; or test -z "$PROXY_URI"
        echo "claude-proxy: PROXY_URI is not set — refusing to launch without a proxy" >&2
        return 1
    end

    if pgrep -xq Claude 2>/dev/null
        echo "claude-proxy: Claude is already running; quit it fully or the proxy flag won't apply" >&2
    end

    # Launcher is overridable for tests; guard non-empty so an empty value
    # doesn't expand to an empty command (the dnssync `$SUDO` empty-list trap).
    set -l OPEN open
    if set -q CLAUDE_PROXY_OPEN[1]; and test -n "$CLAUDE_PROXY_OPEN"
        set OPEN $CLAUDE_PROXY_OPEN
    end

    echo "✓ launching Claude via proxy → "(string replace -r '://[^@/]+@' '://***@' -- $PROXY_URI)
    $OPEN -na "/Applications/Claude.app" --args --proxy-server="$PROXY_URI" $argv
end
