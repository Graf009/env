# Toggle proxy environment variables for the CURRENT fish session.
#
# Reads the endpoint from $PROXY_URI (e.g. "socks5://127.0.0.1:12334"), which
# is provided by your private config (~/.config/local or the bw-env note).
# This function only consumes it.
#
#   proxy on       export {http,https,all}_proxy (+ UPPERCASE) = $PROXY_URI
#                  and no_proxy/NO_PROXY for loopback
#   proxy off      erase all of the above
#   proxy status   show current state (on / off-but-ready / PROXY_URI unset)
#   proxy          same as `proxy status`
#
# Session-only: `set -gx` mutates this shell's global env, inherited by newly
# spawned children. Already-running processes do NOT pick up the change.
#
# SOCKS caveat: curl, git and pip honor a socks5:// value in these vars;
# wget and native npm/node do NOT understand SOCKS and won't be proxied.
# all_proxy/ALL_PROXY is the load-bearing pair for SOCKS.

function __proxy_redact --argument-names url
    # Hide user:pass@ userinfo so a credentialed URL isn't printed to scrollback.
    string replace -r '://[^@/]+@' '://***@' -- $url
end

function proxy --description 'Toggle proxy env vars for the current session (from $PROXY_URI)'
    if test (count $argv) -gt 1
        echo "proxy: too many arguments (use: on | off | status)" >&2
        return 2
    end
    set -l cmd status
    test (count $argv) -eq 1; and set cmd $argv[1]

    set -l vars http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
    set -l noproxy localhost,127.0.0.1,::1

    switch $cmd
        case on
            if not set -q PROXY_URI; or test -z "$PROXY_URI"
                echo "proxy: PROXY_URI is not set — cannot enable" >&2
                return 1
            end
            for v in $vars
                set -gx $v $PROXY_URI
            end
            set -gx no_proxy $noproxy
            set -gx NO_PROXY $noproxy
            echo "✓ proxy on → "(__proxy_redact $PROXY_URI)
            return 0
        case off
            # Erase unconditionally (set -e returns 4 for already-unset names —
            # do NOT chain the echo with `and`, and force a clean exit code).
            set -e $vars no_proxy NO_PROXY
            echo "✓ proxy off"
            return 0
        case status ''
            if set -q http_proxy
                echo "proxy: on → "(__proxy_redact $http_proxy)
            else if set -q PROXY_URI; and test -n "$PROXY_URI"
                echo "proxy: off (ready — run 'proxy on')"
            else
                echo "proxy: off (PROXY_URI not set)"
            end
            return 0
        case '*'
            echo "proxy: unknown command: $cmd (use: on | off | status)" >&2
            return 2
    end
end
