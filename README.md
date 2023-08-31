# Oleg Orlov's dotfiles

This is a repo for my OS X dotfiles. Bootstrap is based on the awesome [dotbot](https://github.com/anishathalye/dotbot).

## Installation

```bash
git clone https://github.com/graf009/dotfiles dotfiles
cd dotfiles
./install
sudo bash -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
```

## Post Install

```bash
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent
```

Change permissions:

```bash
chmod 744 ~/.ssh
chmod 700 ~/.gnupg/
chmod 644 ~/.ssh/* ~/.gnupg/*
chmod 700 ~/.gnupg/private-keys-v1.d
chmod 600 ~/.ssh/id_orlov ~/.gnupg/private-keys-v1.d/*
```

Install VS Code extensions.:

```bash
EXTENSIONS=(
  alefragnani.project-manager
  bungcip.better-toml
  christian-kohler.npm-intellisense
  christian-kohler.path-intellisense
  csstools.postcss
  dbaeumer.vscode-eslint
  EditorConfig.EditorConfig
  esbenp.prettier-vscode
  formulahendry.auto-rename-tag
  kshetline.ligatures-limited
  mariusschulz.yarn-lock-syntax
  mikestead.dotenv
  mrorz.language-gettext
  ms-azuretools.vscode-docker
  MS-CEINTL.vscode-language-pack-ru
  ms-vscode.live-server
  PKief.material-icon-theme
  rafaelmardojai.vscode-gnome-theme
  ryanluker.vscode-coverage-gutters
  sianglim.slim
  streetsidesoftware.code-spell-checker
  streetsidesoftware.code-spell-checker-russian
  stylelint.vscode-stylelint
  svelte.svelte-vscode
  VisualStudioExptTeam.vscodeintellicode
  webben.browserslist
  yzhang.markdown-all-in-one
)
for EXTENSION in ${EXTENSIONS[@]}; do
  code --install-extension $EXTENSION
done
```