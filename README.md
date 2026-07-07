# Oleg Orlov's dotfiles

Mac dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot).
Packages via Brewfile, runtimes via mise, fish as the only shell.

## Bootstrap

On a **fresh Mac**, run `./bootstrap` — it handles the steps that need an
interactive sudo password (installing Homebrew), then runs `./install`:

```bash
git clone git@github.com:Graf009/env.git env
cd env
./bootstrap
```

`./bootstrap` will:
1. Cache sudo, then install Homebrew (if missing) — needs an interactive terminal
2. Hand off to `./install`

`./install` (also runnable on its own to re-sync an already-set-up machine) will:
1. Symlink configs via dotbot
2. `brew bundle install` — install all packages from `Brewfile`
3. Apply macOS defaults (`macos-defaults.sh`)
4. Install runtimes via `mise install` (node LTS, Go latest, Java LTS)

## Post-install

### Set fish as default shell

```bash
sudo bash -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
```

### SSH commit signing

Add your SSH public key to GitHub as a **signing key** (Settings → SSH keys → type: Signing):

```bash
cat ~/.ssh/id_graf009.pub   # personal / public projects
```

### SSH key permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_graf009 ~/.ssh/id_ecom-bnpl
chmod 644 ~/.ssh/*.pub
```

### Secrets management

Secrets (tokens, API keys, SSH private keys) are stored in **Bitwarden** and
pulled into the local machine on demand — nothing sensitive lives in this repo.

**First-time setup:**

```bash
bw login                   # authenticate once
```

**Load env vars** from a Bitwarden Secure Note named `fish.env`:

```fish
bw-env                     # pulls KEY=value pairs → ~/.fish.env, then exports
```

**Load SSH keys** into `ssh-agent` from Bitwarden **SSH-key items** named after
each key file (e.g. an SSH-key item called `id_graf009`):

```fish
bw-ssh                     # writes ~/.ssh/<key> (+ .pub) from the item, then ssh-add
```

**Vault conventions:**

| Bitwarden item name | Type | Content |
|---|---|---|
| `fish.env` | Secure Note | `KEY=value` lines (one per line) |
| `id_graf009` | SSH key | private + public key |
| `id_ecom` | SSH key | private + public key |

### Claude Code

Settings are symlinked from `claude/settings.json` → `~/.claude/settings.json` automatically by `./install`.

`settings.json` already declares the `omc` marketplace and enables the plugins
below, so they load on first launch. To add/manage them manually, use `/plugin`
in Claude Code (see `claude/plugins.md` for the full list):

```
/plugin marketplace add Yeachan-Heo/oh-my-claudecode   # registers the "omc" marketplace
/plugin install oh-my-claudecode@omc
/plugin install claude-code-setup@claude-plugins-official
/plugin install claude-md-management@claude-plugins-official
```

Then initialise oh-my-claudecode:

```
setup omc
```

### Manual software

Some apps aren't in Homebrew or the App Store, so `brew bundle` can't install
them — they need a manual `.dmg` download. The current list (with download links
and steps) lives in [`docs/manual-software.md`](docs/manual-software.md). After
`./install`, walk that list and install what you need.

### Yandex Cloud completion

After `yc init`, save the completion file outside the repo:

```bash
yc completion fish > ~/.config/local/yandex.fish
```

### Split DNS (per-domain resolvers)

`dnssync` routes specific domains to specific nameservers via macOS
`/etc/resolver/<domain>` files — useful for VPN / corporate internal DNS
without changing the system-wide resolver.

The route list is **declarative** and lives **outside this public repo** at
`~/.config/local/dns-routes.conf` (internal domains and resolver IPs are
sensitive infra, so only the [`dns-routes.conf.example`](dns-routes.conf.example)
template is committed):

```bash
cp dns-routes.conf.example ~/.config/local/dns-routes.conf
$EDITOR ~/.config/local/dns-routes.conf   # one route per line: <domain> <nameserver...>
```

Apply and inspect:

```fish
dnssync              # apply adds/updates, report stale routes (no deletions)
dnssync --dry-run    # preview changes, touch nothing, no sudo
dnssync --prune      # also delete routes you removed from the config
dnssync --status     # show scutil --dns resolvers + dnssync-managed files
```

`dnssync` is **fail-closed and marker-scoped**: it only ever touches files it
created (first line `# managed-by: dnssync`), never a resolver owned by a VPN
client / Tailscale / dnsmasq, and it refuses to delete anything when the config
is missing or empty. Writing to `/etc/resolver` needs sudo (it will prompt).
If a VPN client already manages a domain, leave that domain out of the config.

### Proxy toggle

`proxy` turns proxy usage on/off for the **current shell session** from the
endpoint in `$PROXY_URI` (e.g. `http://127.0.0.1:12334`, provided by your
private config — `~/.config/local` or the `bw-env` note):

```fish
proxy on       # export {http,https,all}_proxy (+ UPPERCASE) = $PROXY_URI, plus no_proxy for loopback
proxy off      # erase them all
proxy status   # on / off-but-ready / PROXY_URI-unset (bare `proxy` = status)
```

Notes:
- **Session-only.** It mutates this shell's env (inherited by newly spawned
  children); **already-running processes won't pick up the change**.
- **SOCKS caveat.** curl, git and pip honor a `socks5://` value in these
  variables; `wget` and native `npm`/`node` do **not** understand SOCKS and
  won't be proxied. `all_proxy`/`ALL_PROXY` is the reliable pair for SOCKS.
- `no_proxy`/`NO_PROXY` is set to `localhost,127.0.0.1,::1` so loopback (and
  the path to a local SOCKS listener) is never proxied.

### VS Code extensions

Extensions are declared in the `Brewfile` as `vscode "..."` entries and installed
by `brew bundle` (needs the `code` command on `PATH`). To sync the committed list
with what's currently installed:

```bash
brew bundle dump --vscode --force --describe   # snapshot installed → Brewfile-style
```

Then hand-merge the `vscode` lines into the `Brewfile`, preserving its grouping.

### Keeping the Brewfile in sync

`$HOMEBREW_BUNDLE_FILE` points at this repo's `Brewfile` (set in `fish/conf.d/env.fish`),
so `brew bundle` commands work from any directory. To see how the machine has drifted:

```fish
brewcheck        # read-only: lists declared-but-missing AND installed-but-undeclared
```

Reconcile by **hand-editing** the `Brewfile` (keep the sections/comments) — add the
ad-hoc installs you want to keep, remove or install the rest. For a full snapshot to
compare against:

```bash
brew bundle dump --force --describe --file=/tmp/Brewfile.new   # never dump over the curated file
```

Never run `brew bundle cleanup --force` (uninstalls) without reviewing `brewcheck` first.

## Structure

| Path | Purpose |
|---|---|
| `Brewfile` | All packages, casks, and App Store apps |
| `docs/software.md` | Reference for every tool in the `Brewfile`, by category |
| `docs/manual-software.md` | Apps that need manual install (no cask / not on App Store) |
| `fish/config.fish` | Shell init (mise, starship, atuin, zoxide, fzf) |
| `fish/conf.d/` | Env vars and abbreviations (auto-sourced) |
| `fish/graf009/` | Custom fish functions |
| `mise/config.toml` | Runtime versions (node, go, java) |
| `gitconfig` | Git config with SSH signing and identity switching |
| `git/allowed_signers` | SSH signing key registry |
| `sshconfig` | SSH client config |
| `starship.toml` | Prompt config |
| `macos-defaults.sh` | Idempotent macOS defaults |
| `claude/settings.json` | Claude Code settings (theme, plugins, effortLevel) |
| `claude/plugins.md` | Plugins to install on a new machine |
| `bin/` | Personal scripts on `PATH`. The whole folder is symlinked to `~/bin`, so **any executable dropped here becomes a command** — no `install.conf.yaml` edit needed |
| `bin/vvv` | Read-only macOS diagnostics: device management (MDM), background services, privacy permissions, network connections. Run `vvv`, `vvv -v`, `vvv --full` |
| `fish/functions/bw-ssh.fish` | Load SSH keys from Bitwarden into ssh-agent |
| `fish/functions/bw-env.fish` | Load env vars from Bitwarden into `~/.fish.env` |
| `fish/functions/brewcheck.fish` | Report Brewfile drift (missing / ad-hoc installed) |
| `fish/functions/flushdns.fish` | Flush the macOS DNS cache (`dscacheutil` + `mDNSResponder`) |
| `fish/functions/dnssync.fish` | Apply declarative split-DNS routes to `/etc/resolver` (managed, fail-closed) |
| `fish/functions/proxy.fish` | Toggle proxy env vars for the current session from `$PROXY_URI` (`on`/`off`/`status`) |
| `dns-routes.conf.example` | Template for `dnssync`; real config lives at `~/.config/local/dns-routes.conf` (not committed) |
