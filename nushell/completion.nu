let carapace_completer = {|spans: list<string>|
    CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}

let external_completer = {|spans|
  # if the current command is an alias, get it's expansion
  let expanded_alias = scope aliases
    | where name == $spans.0
    | get --optional 0.expansion

  # overwrite
  let spans = (if $expanded_alias != null  {
    # put the first word of the expanded alias first in the span
    $spans
      | skip 1
      | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  })

  match $spans.0 {
    _ => $carapace_completer
  } | do $in $spans
}

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
$env.config.completions = {
  algorithm: fuzzy,
  external: {
    enable: true,
    completer: $external_completer
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
