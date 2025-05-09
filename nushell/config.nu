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

# NOTE: Look at using `detect columns` - https://www.nushell.sh/commands/docs/detect_columns.html
use std/util "path add"
path add "/opt/homebrew/bin"
path add "~/.cargo/bin"
# Append zig/zls/fnm to PATH
# Append ~/Library/Application Support/JetBrains/Toolbox/scripts to path?
# fnm env - https://github.com/Schniz/fnm/issues/463#issuecomment-2760762541
#         - https://okmanideep.me/nushell-after-8-months/
# sdkman


if (not (plugin list | any {|p| $p.name == "polars" })) {
  print "Enabling the polars plugin installed by homebrew"
  plugin add /opt/homebrew/bin/nu_plugin_polars
  # TODO: Disable the plugin_gc for polars?
}

# Theme set to Catppuccin Mocha to match Ghostty/etc
source themes/catppuccin_mocha.nu

# This can be used for MacOS to avoid overriding the MacOS `open` command
# E.g. for opening a directory in Finder
# alias nu-open = open
# alias open = ^open


# TODO: Setup some nushell completions/hooks/scripts
# Install carapace-bin to do the work? - https://carapace-sh.github.io/carapace-bin/setup.html#nushell

# TODO: Aliases for things like build/test/watch/etc
# TODO: Autoload these aliases

# Enable pushing/popping directories from a stack - ala pushd/popd
# This is useful for setting up multiple directories to bounce between - e.g. terraform and code source
use std/dirs
# https://www.nushell.sh/book/aliases.html#replacing-existing-commands-using-aliases

# TODO: Try to use background jobs for some things like builds?

# TODO: Play around with https://www.nushell.sh/commands/docs/histogram.html#histogram-for-chart

# TODO: Create a setup/help module for installing all the required tools, creating gitconfig file, etc
