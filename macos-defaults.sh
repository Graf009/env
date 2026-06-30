#!/bin/bash
# Idempotent macOS defaults — safe to run multiple times.
# Add new tweaks as one-liners below.

set -e

# Dock: disable bouncing icons
defaults write com.apple.dock no-bouncing -bool true

killall Dock 2>/dev/null || true

echo "macOS defaults applied."
