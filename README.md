# Oleg Orlov's dotfiles

This is a repo for my OS X dotfiles. Bootstrap is based on the awesome [dotbot](https://github.com/anishathalye/dotbot).

## Installation

```sh
git clone https://github.com/graf009/dotfiles dotfiles
cd dotfiles
./install
sudo bash -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
```

## Post Install

```sh
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent
```