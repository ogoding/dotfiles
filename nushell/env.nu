const hx = "/opt/homebrew/bin/hx";
$env.VISUAL = $hx;
$env.EDITOR = $hx;

load-env {
  DOCKER_DEFAULT_PLATFORM:"linux/arm64",
  HOMEBREW_NO_ANALYTICS:"1",
  HOMEBREW_PREFIX:"/opt/homebrew",
  HOMEBREW_CELLAR:"/opt/homebrew/Cellar",
  HOMEBREW_REPOSITORY:"/opt/homebrew",
  INFOPATH: "/opt/homebrew/share/info:",

  GPG_TTY:(tty)

  # Disable claude code's autoupdater in favour of using homebrew instead
  DISABLE_AUTOUPDATER:1
};

use std/util "path add"
path add "/opt/homebrew/bin"
path add "~/.local/bin"
