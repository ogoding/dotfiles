let zoxide_completer = {|spans|
    $spans | skip 1
      | zoxide query -l ...$in
      | lines
      | each {|line| $line | str replace $env.HOME '~' }
      | where {|x| $x != $env.PWD}
}

let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

# TODO: Try setting carapace to unfiltered and using fuzzy search on the nushell side
# CARAPACE_UNFILTERED=1
let external_completer = {|spans|
  # if the current command is an alias, get it's expansion
  let expanded_alias = (scope aliases | where name == $spans.0 | get --optional 0 | get --optional expansion)

  # overwrite
  let spans = (if $expanded_alias != null  {
    # put the first word of the expanded alias first in the span
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  })

  match $spans.0 {
    # TODO: Determine why this doesn't seem to work
    # use zoxide completions for zoxide commands
    z | zi => $zoxide_completer
    __zoxide_z | __zoxide_zi => $zoxide_completer
    _ => $carapace_completer
  } | do $in $spans
}

mut current = (($env | default {} config).config | default {} completions)
$current.completions = ($current.completions
  | default {} external)
$current.completions.algorithm = 'fuzzy'

$current.completions.external = ($current.completions.external
  | default true enable
  | default { $external_completer } completer)

$env.config = $current

# TODO: Work out how to load this more automatically
const completionsDir = "completions"
source $"($completionsDir)/aws-completions.nu"
source $"($completionsDir)/docker-completions.nu"
source $"($completionsDir)/git-completions.nu"
source $"($completionsDir)/just-completions.nu"
source $"($completionsDir)/make-completions.nu"
source $"($completionsDir)/npm-completions.nu"
source $"($completionsDir)/pnpm-completions.nu"
source $"($completionsDir)/pre-commit-completions.nu"
source $"($completionsDir)/ripgrep-completions.nu"
source $"($completionsDir)/rustup-completions.nu"
source $"($completionsDir)/yarnv4-completions.nu"
source $"($completionsDir)/jj-completions.nu"
