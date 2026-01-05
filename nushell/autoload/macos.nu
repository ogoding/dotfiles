module macos {
  export alias spotlight-enable = sudo mdutil -i on
  export alias spotlight-disable = sudo mdutil -i off
  export alias ssh-load-keychain = ssh-add --apple-load-keychain
  export alias ssh-add-keychain = ssh-add --apple-use-keychain

  # Add something to setup rosetta
  # softwareupdate --install-rosetta

  # This can be used for MacOS to avoid overriding the MacOS `open` command
  # E.g. for opening a directory in Finder
  # alias nu-open = open
  # alias open = ^open
}
