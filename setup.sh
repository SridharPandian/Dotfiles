#!/bin/bash

set -e

# Setup ohmyzsh
sh -c "$(curl -fsSL https://install.ohmyz.sh)"

# Copy the zsh config to the user home folder
cp zsh/.zshrc $HOME/.zshrc

set +e