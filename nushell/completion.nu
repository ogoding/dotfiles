# @interactive
# def carapace-fzf [place: record] {
#     carapace ($place.command | first) nushell ...$place.command
#     | from json
#     | ^fzf
#     | lines
# }

let carapace_completer = {|place|
  # backwards compatible workaround for positional completer input, see nushell #18791
  let spans = (if ($place | describe) =~ "record" { $place.command } else { $place })
  carapace $spans.0 nushell ...$spans | from json

  # Generated carapace completer - sticking with the simpler version for now
  # # if the current command is an alias, get it's expansion
  # let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)

  # # overwrite
  # let spans = (if $expanded_alias != null  {
  #   # put the first word of the expanded alias first in the span
  #   $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  # } else {
  #   $spans | skip 1 | prepend ($spans.0)
  # })

  # if ($spans | length) == 1 {
  #   null
  # } else {
  #   with-env {
  #     CARAPACE_SHELL: 'nushell'
  #     CARAPACE_SHELL_ALIASES: (scope aliases | get name | uniq | str join "\n")
  #     CARAPACE_SHELL_BUILTINS: (help commands | where category != "" | get name | each { split row " " | first } | uniq  | str join "\n")
  #     CARAPACE_SHELL_FUNCTIONS: (help commands | where category == "" | get name | each { split row " " | first } | uniq  | str join "\n")
  #     CARAPACE_SHELL_VARIABLES: (scope variables | get name | uniq | str join "\n")
  #   } {
  #     carapace $spans.0 nushell ...$spans | from json
  #   }
  # }
}

$env.CARAPACE_LENIENT = "1"
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
# $env.CARAPACE_BUILTINS = "experimental"
$env.config.completions = {
  algorithm: fuzzy,
  external: {
    enable: true,
    completer: $carapace_completer
  }
}

## binary specific completions courtesy of
## https://github.com/nushell/nu_scripts/tree/main/custom-completions
source $"completions/aws-completions.nu"
source $"completions/docker-completions.nu"
source $"completions/just-completions.nu"
source $"completions/make-completions.nu"
source $"completions/npm-completions.nu"
source $"completions/pnpm-completions.nu"
source $"completions/rustup-completions.nu"
source $"completions/yarnv4-completions.nu"
source $"completions/jj-completions.nu"
