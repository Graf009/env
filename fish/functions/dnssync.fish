# Split-DNS route manager for macOS.
#
# Applies a declarative list of <domain> -> <nameserver(s)> routes to
# /etc/resolver/<domain> files (resolver(5) format). Fail-closed and
# marker-scoped: it only ever touches files it created (first line
# '# managed-by: dnssync'); anything else in /etc/resolver (VPN clients,
# Tailscale, dnsmasq) is left untouched.
#
# Config (declarative, one route per line):
#   <domain> <nameserver> [nameserver...] [port=NN] [search_order=NN]
# '#' comments and blank lines are ignored. The real config lives OUTSIDE
# this public repo at ~/.config/local/dns-routes.conf (never committed);
# see dns-routes.conf.example for the format.
#
# Usage:
#   dnssync              apply adds/updates, report stale (no deletions)
#   dnssync --prune      also delete stale managed routes (asks / needs --yes)
#   dnssync --dry-run    show what would change, touch nothing, no sudo
#   dnssync --status     show scutil --dns resolvers + managed files
#   dnssync -h           this help
#
# Test seams (env): DNSSYNC_RESOLVER_DIR, DNSSYNC_CONFIG, DNSSYNC_SUDO
# (set-but-empty = run without sudo), DNSSYNC_SKIP_FLUSH.
#
# Exit: 0 ok · 1 runtime failure · 2 usage/validation error.

function __dnssync_is_ipv4 --argument-names ip
    string match -rq '^[0-9]+(\.[0-9]+){3}$' -- $ip; or return 1
    for o in (string split . -- $ip)
        if test $o -lt 0 -o $o -gt 255
            return 1
        end
    end
    return 0
end

function __dnssync_is_ipv6 --argument-names ip
    string match -q '*:*' -- $ip; and string match -rq '^[0-9A-Fa-f:]+$' -- $ip
end

function __dnssync_is_domain --argument-names d
    string match -rq '^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)*$' -- $d
end

# Run argv with root. Test seam DNSSYNC_SUDO: set-but-empty runs with no sudo
# (tests write as $USER); set-non-empty overrides the elevation command;
# unset uses `sudo`. stdin passes through so `... | __dnssync_priv tee f` works.
function __dnssync_priv
    if set -q DNSSYNC_SUDO
        if test -n "$DNSSYNC_SUDO"
            command $DNSSYNC_SUDO $argv
        else
            command $argv
        end
    else
        command sudo $argv
    end
end

function __dnssync_usage
    printf '%s\n' \
        'dnssync — apply declarative split-DNS routes to /etc/resolver (macOS)' \
        '' \
        'Usage:' \
        '  dnssync              apply adds/updates, report stale (no deletions)' \
        '  dnssync --prune      also delete stale managed routes (asks / needs --yes)' \
        '  dnssync --dry-run    show what would change, touch nothing, no sudo' \
        '  dnssync --status     show scutil --dns resolvers + managed files' \
        '  dnssync -h           this help' \
        '' \
        'Config: ~/.config/local/dns-routes.conf  (see dns-routes.conf.example)' \
        'Exit:   0 ok · 1 runtime failure · 2 usage/validation error'
end

function __dnssync_status --argument-names resolver_dir
    echo "== managed routes ($resolver_dir) =="
    if test -d $resolver_dir
        for f in (find $resolver_dir -maxdepth 1 -type f 2>/dev/null)
            test (head -n1 $f 2>/dev/null) = '# managed-by: dnssync'; or continue
            set -l ns (grep '^nameserver ' $f | string replace 'nameserver ' '' | string join ', ')
            echo "  "(path basename $f)": $ns"
        end
    end
    echo
    echo "== scutil --dns resolvers =="
    scutil --dns
end

function dnssync --description 'Apply declarative split-DNS routes to /etc/resolver (managed, fail-closed)'
    # ---- flags ----
    set -l mode apply
    set -l dry 0
    set -l prune 0
    set -l assume_yes 0
    for a in $argv
        switch $a
            case -h --help
                __dnssync_usage
                return 0
            case -n --dry-run
                set dry 1
            case --prune
                set prune 1
            case -y --yes
                set assume_yes 1
            case --status
                set mode status
            case '*'
                echo "dnssync: unknown option: $a" >&2
                return 2
        end
    end

    # ---- config & test seams ----
    set -l resolver_dir /etc/resolver
    set -q DNSSYNC_RESOLVER_DIR[1]; and set resolver_dir $DNSSYNC_RESOLVER_DIR
    set -l config $HOME/.config/local/dns-routes.conf
    set -q DNSSYNC_CONFIG[1]; and set config $DNSSYNC_CONFIG

    if test "$mode" = status
        __dnssync_status $resolver_dir
        return 0
    end

    # ---- fail-closed: config must exist and be readable ----
    if not test -r "$config"
        echo "dnssync: config not found or unreadable: $config" >&2
        echo "  (refusing to reconcile — nothing deleted)" >&2
        return 2
    end

    # ---- parse + validate (fail-closed: any bad line aborts, no partial apply) ----
    set -l domains
    set -l contents # parallel to $domains: rendered file body (one element each)
    set -l lineno 0
    while read -l line
        set lineno (math $lineno + 1)
        # strip inline/full-line comments, then trim
        set -l trimmed (string trim -- (string replace -r '\s+#.*$' '' -- $line))
        set trimmed (string replace -r '^#.*$' '' -- $trimmed)
        test -z "$trimmed"; and continue
        set -l fields (string split -n ' ' -- (string replace -ra '\s+' ' ' -- $trimmed))
        set -l domain $fields[1]
        set -l rest $fields[2..-1]
        if not __dnssync_is_domain $domain
            echo "dnssync: invalid domain on line $lineno: '$domain'" >&2
            return 2
        end
        if contains -- $domain $domains
            echo "dnssync: duplicate domain on line $lineno: '$domain'" >&2
            return 2
        end
        set -l nameservers
        set -l port
        set -l search_order
        for tok in $rest
            if string match -q '*=*' -- $tok
                set -l k (string split -m1 = -- $tok)[1]
                set -l v (string split -m1 = -- $tok)[2]
                switch $k
                    case port
                        if not string match -rq '^[0-9]+$' -- $v; or test $v -lt 1 -o $v -gt 65535
                            echo "dnssync: invalid port on line $lineno: '$v'" >&2
                            return 2
                        end
                        set port $v
                    case search_order
                        if not string match -rq '^[0-9]+$' -- $v
                            echo "dnssync: invalid search_order on line $lineno: '$v'" >&2
                            return 2
                        end
                        set search_order $v
                    case '*'
                        echo "dnssync: unknown key on line $lineno: '$k'" >&2
                        return 2
                end
            else
                if not __dnssync_is_ipv4 $tok; and not __dnssync_is_ipv6 $tok
                    echo "dnssync: invalid nameserver on line $lineno: '$tok'" >&2
                    return 2
                end
                set -a nameservers $tok
            end
        end
        if test (count $nameservers) -eq 0
            echo "dnssync: no nameserver on line $lineno for '$domain'" >&2
            return 2
        end
        set -l body '# managed-by: dnssync'
        for ns in $nameservers
            set body $body "nameserver $ns"
        end
        test -n "$port"; and set body $body "port $port"
        test -n "$search_order"; and set body $body "search_order $search_order"
        set -a domains $domain
        set -a contents (string join \n $body | string collect)
    end <"$config"

    if test (count $domains) -eq 0
        echo "dnssync: config parsed to zero routes: $config" >&2
        echo "  (refusing to reconcile — nothing deleted)" >&2
        return 2
    end

    # ---- ensure resolver dir (skip in dry-run) ----
    if test $dry -eq 0; and not test -d $resolver_dir
        if not __dnssync_priv mkdir -p $resolver_dir
            echo "dnssync: cannot create $resolver_dir" >&2
            return 1
        end
    end

    # ---- apply adds/updates ----
    set -l added 0
    set -l updated 0
    set -l unchanged 0
    set -l skipped 0
    for i in (seq (count $domains))
        set -l domain $domains[$i]
        set -l target $resolver_dir/$domain
        set -l desired $contents[$i]

        # symlink guard: never write through a symlink as root
        if test -L $target
            echo "⚠  $domain: target is a symlink — skipping" >&2
            set skipped (math $skipped + 1)
            continue
        end

        set -l existed 0
        test -e $target; and set existed 1
        if test $existed -eq 1
            # reads are unprivileged (resolver files are world-readable); an
            # unreadable file reads empty and is treated as foreign → skipped.
            if test (head -n1 $target 2>/dev/null) != '# managed-by: dnssync'
                echo "⚠  $domain: managed by another tool — not overwriting" >&2
                set skipped (math $skipped + 1)
                continue
            end
            if test (cat $target 2>/dev/null | string collect) = "$desired"
                set unchanged (math $unchanged + 1)
                continue
            end
        end

        if test $dry -eq 1
            test $existed -eq 1; and echo "would update $target"; or echo "would add $target"
            continue
        end

        if not printf '%s\n' $desired | __dnssync_priv tee $target >/dev/null
            echo "dnssync: failed writing $target" >&2
            return 1
        end
        test $existed -eq 1; and set updated (math $updated + 1); or set added (math $added + 1)
    end

    # ---- stale detection (managed files whose domain left the config) ----
    set -l stale
    if test -d $resolver_dir
        for f in (find $resolver_dir -maxdepth 1 -type f 2>/dev/null)
            test (head -n1 $f 2>/dev/null) = '# managed-by: dnssync'; or continue
            if not contains -- (path basename $f) $domains
                set -a stale $f
            end
        end
    end

    if test (count $stale) -gt 0
        echo "stale managed routes ("(count $stale)"):"
        for f in $stale
            echo "  "(path basename $f)
        end
        if test $prune -eq 0
            echo "  (run with --prune to delete)"
        else if test $dry -eq 1
            echo "  (dry-run) would delete the above"
        else
            if not isatty stdout; and test $assume_yes -eq 0
                echo "dnssync: refusing to prune non-interactively without --yes" >&2
                return 2
            end
            if test $assume_yes -eq 0
                read -l -P "Delete these "(count $stale)" route(s)? [y/N] " ans
                if not string match -qi 'y*' -- $ans
                    echo "aborted (nothing deleted)"
                    return 0
                end
            end
            for f in $stale
                # re-verify right before rm: regular file, not a symlink, still marked
                test -f $f; and not test -L $f; or continue
                test (head -n1 $f 2>/dev/null) = '# managed-by: dnssync'; or continue
                __dnssync_priv rm -f $f
            end
        end
    end

    # ---- flush DNS cache so changes take effect (skippable in tests) ----
    if test $dry -eq 0; and not set -q DNSSYNC_SKIP_FLUSH
        __dnssync_priv dscacheutil -flushcache
        __dnssync_priv killall -HUP mDNSResponder 2>/dev/null
    end

    echo "dnssync: added $added, updated $updated, unchanged $unchanged, skipped $skipped, stale "(count $stale)
    return 0
end
