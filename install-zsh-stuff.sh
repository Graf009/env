#!/bin/bash

set -e

curl -L git.io/antigen > ~/.antigen.zsh
zsh
source ~/.antigen.zsh

micro -plugin install editorconfig

exit 0