# Oleg Orlov's dotfiles

Mac dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot).
Packages via Brewfile, runtimes via mise, fish as the only shell.

## Bootstrap

```bash
git clone https://github.com/graf009/dotfiles dotfiles
cd dotfiles
./install
```

`./install` will:
1. Install Homebrew (if missing)
2. `brew bundle install` — install all packages from `Brewfile`
3. Apply macOS defaults (`macos-defaults.sh`)
4. Symlink configs via dotbot
5. Install fish plugins via fisher
6. Install runtimes via `mise install` (node LTS, Go latest, Java LTS)

## Post-install

### Set fish as default shell

```bash
sudo bash -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
```

### SSH commit signing

Add your SSH public key to GitHub as a **signing key** (Settings → SSH keys → type: Signing):

```bash
cat ~/.ssh/id_orlov.pub   # personal / public projects
cat ~/.ssh/id_dc.pub      # work (oorlov@alfabank.ru)
```

### SSH key permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_orlov ~/.ssh/id_dc ~/.ssh/id_podeli-bnpl
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

**Load SSH keys** into `ssh-agent` from Secure Notes named `SSH key: id_orlov` etc.:

```fish
bw-ssh                     # decrypts each key, ssh-add, wipes temp file
```

**Vault conventions:**

| Bitwarden item name | Type | Content |
|---|---|---|
| `fish.env` | Secure Note | `KEY=value` lines (one per line) |
| `SSH key: id_orlov` | Secure Note | Private key file content |
| `SSH key: id_dc` | Secure Note | Private key file content |
| `SSH key: id_podeli-bnpl` | Secure Note | Private key file content |

A template for `~/.fish.env` is at `.fish.env.example` in this repo.

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

```bash
EXTENSIONS=(
  # AI
  anthropic.claude-code

  # Git
  eamodio.gitlens

  # Languages
  golang.go
  ms-python.python
  ms-python.debugpy
  ms-python.vscode-pylance
  ms-python.vscode-python-envs
  svelte.svelte-vscode

  # Infrastructure / DevOps
  redhat.ansible
  redhat.vscode-yaml
  hashicorp.hcl
  docker.docker
  ms-azuretools.vscode-docker
  ms-azuretools.vscode-containers

  # Formatters / Linters
  esbenp.prettier-vscode
  dbaeumer.vscode-eslint
  stylelint.vscode-stylelint
  davidanson.vscode-markdownlint

  # Data formats
  tamasfe.even-better-toml
  csstools.postcss
  jock.svg
  mechatroner.rainbow-csv
  inferrinizzard.prettier-sql-vscode
  xyz.plsql-language
  mariusschulz.yarn-lock-syntax
  webben.browserslist

  # Editor UX
  editorconfig.editorconfig
  mikestead.dotenv
  kshetline.ligatures-limited
  ms-vscode.live-server

  # Markdown
  yzhang.markdown-all-in-one

  # Spell check
  streetsidesoftware.code-spell-checker
  streetsidesoftware.code-spell-checker-russian

  # Theme / Icons
  rafaelmardojai.vscode-gnome-theme
  pkief.material-icon-theme

  # Localisation
  ms-ceintl.vscode-language-pack-ru
)
for EXTENSION in "${EXTENSIONS[@]}"; do
  [[ "$EXTENSION" =~ ^# ]] && continue
  code --install-extension "$EXTENSION"
done
```

## Structure

| Path | Purpose |
|---|---|
| `Brewfile` | All packages, casks, and App Store apps |
| `fish/config.fish` | Shell init (mise, starship, atuin, zoxide, fzf) |
| `fish/conf.d/` | Env vars and abbreviations (auto-sourced) |
| `fish/graf009/` | Custom fish functions |
| `fish/fish_plugins` | Fisher plugin manifest |
| `mise/config.toml` | Runtime versions (node, go, java) |
| `gitconfig` | Git config with SSH signing and identity switching |
| `git/allowed_signers` | SSH signing key registry |
| `sshconfig` | SSH client config |
| `starship.toml` | Prompt config |
| `macos-defaults.sh` | Idempotent macOS defaults |
| `claude/settings.json` | Claude Code settings (theme, plugins, effortLevel) |
| `claude/plugins.md` | Plugins to install on a new machine |
| `vvv` | Read-only macOS diagnostics: device management (MDM), background services, privacy permissions, network connections. Symlinked to `~/bin/vvv`. Run `vvv`, `vvv -v`, `vvv --full` |
| `fish/functions/bw-ssh.fish` | Load SSH keys from Bitwarden into ssh-agent |
| `fish/functions/bw-env.fish` | Load env vars from Bitwarden into `~/.fish.env` |
| `.fish.env.example` | Template for `~/.fish.env` (fill in and place at `~/`) |
