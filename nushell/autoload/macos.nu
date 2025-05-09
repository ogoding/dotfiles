module macos {
  export alias spotlight-enable = sudo mdutil -i on
  export alias spotlight-disable = sudo mdutil -i off
  export alias ssh-load-keychain = ssh-add --apple-load-keychain
}

