#!/bin/bash
# Install Homebrew if it is missing.
#
# On a fresh Mac this needs an administrator password (Homebrew uses sudo to
# create its prefix), so run ./install from an interactive terminal. On a
# managed/corporate Mac without admin rights the install may be blocked — in
# that case install Homebrew by hand and re-run ./install.
set -euo pipefail

# Already on PATH?
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed: $(command -v brew)"
    exit 0
fi

# Installed but not yet on PATH (Apple Silicon first, then Intel)?
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew_bin" ]; then
        echo "Homebrew found at $brew_bin (not on PATH yet)"
        exit 0
    fi
done

if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl not found; cannot bootstrap Homebrew" >&2
    exit 1
fi

echo "Installing Homebrew (may prompt for your macOS password)…"
NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify it actually landed.
if [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; then
    echo "Homebrew installed."
    exit 0
fi

echo "error: Homebrew installation did not complete." >&2
echo "Install it manually, then re-run ./install:" >&2
echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' >&2
exit 1
