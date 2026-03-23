#!/bin/sh

set -ex

# TODO: install homebrew, nushell and anything else necessary for bare minimum environment
# IMPORTANT: Set certain envvars like HOMEBREW_CASK_OPTS before installing homebrew or any other packages
 
# TODO: Create setup nushell module/function to set the rest of the environment up
# - git config
# - nushell symlink
#  ln -s ~/.config/nushell nushell
# - create carapace cache
# mkdir -p ~/.cache/carapace
# - Make certain bundles of tools - e.g. colima/docker/etc optional

# TODO: Implement some mechanism to create backups of existing files, then overwrite them (either with a symlink or this repo)
# Could just be a flag to overwrite, backup or skip anytime an existing value is found
