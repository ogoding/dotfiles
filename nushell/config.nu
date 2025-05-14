const hx = "/opt/homebrew/bin/hx";
$env.VISUAL = $hx;
$env.EDITOR = $hx;

$env.config = $env.config | default {} | merge {
  # edit_mode: "vim",
  show_banner: false,
  use_kitty_protocol: true,
  bracketed_paste: true,
  # edit_mode: "vi",

  # TODO: Completions config
  history: {
    file_format: "sqlite",
    max_size: 5_000_000,
    sync_on_enter: true,
    isolation: true
  },
};

load-env {
  DOCKER_DEFAULT_PLATFORM:"linux/arm64",
  HOMEBREW_NO_ANALYTICS:"1",
  HOMEBREW_PREFIX:"/opt/homebrew",
  HOMEBREW_CELLAR:"/opt/homebrew/Cellar",
  HOMEBREW_REPOSITORY:"/opt/homebrew",
  INFOPATH: "/opt/homebrew/share/info:",

  GPG_TTY:(tty)
};

use std/util "path add"
path add "/opt/homebrew/bin"
path add "~/.cargo/bin"
path add "~/.local/bin"

if (not (plugin list | any {|p| $p.name == "polars" })) {
  print "Enabling the polars plugin installed by homebrew"
  plugin add /opt/homebrew/bin/nu_plugin_polars
  # TODO: Disable the plugin_gc for polars?
}

# Theme set to Catppuccin Mocha to match Ghostty/etc
source themes/catppuccin_mocha.nu

# TODO: Setup some nushell completions/hooks/scripts
# Install carapace-bin to do the work? - https://carapace-sh.github.io/carapace-bin/setup.html#nushell
