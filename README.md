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

Install plugins on first run (see `claude/plugins.md` for full list):

```
/install-plugin oh-my-claudecode   # from omc marketplace
/install-plugin claude-code-setup
/install-plugin claude-md-management
```

Then initialise oh-my-claudecode:

```
setup omc
```

### Yandex Cloud completion

After `yc init`, save the completion file outside the repo:

```bash
yc completion fish > ~/.config/local/yandex.fish
```

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
