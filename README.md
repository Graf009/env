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

### Private env vars

Create `~/.fish.env` with `KEY=value` pairs (one per line) for secrets that
should not live in source control.

### Yandex Cloud completion

After `yc init`, save the completion file outside the repo:

```bash
yc completion fish > ~/.config/local/yandex.fish
```

### VS Code extensions

```bash
EXTENSIONS=(
  alefragnani.project-manager
  christian-kohler.npm-intellisense
  christian-kohler.path-intellisense
  csstools.postcss
  dbaeumer.vscode-eslint
  EditorConfig.EditorConfig
  esbenp.prettier-vscode
  formulahendry.auto-rename-tag
  mikestead.dotenv
  ms-azuretools.vscode-docker
  MS-CEINTL.vscode-language-pack-ru
  PKief.material-icon-theme
  streetsidesoftware.code-spell-checker
  streetsidesoftware.code-spell-checker-russian
  stylelint.vscode-stylelint
  svelte.svelte-vscode
  VisualStudioExptTeam.vscodeintellicode
  yzhang.markdown-all-in-one
)
for EXTENSION in "${EXTENSIONS[@]}"; do
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
