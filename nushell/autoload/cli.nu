alias tree = erd
alias cat = bat --colour=always
alias btop = btm

alias l = ls
alias ll = ls -l
alias la = ls -la

alias brewup = brew update
alias bup = brew update and brew upgrade

alias cdconfig = cd ~/.config
alias hxconfig = hx ~/.config

# TODO: Try to replace watchexec with the inbuilt watch command
# The only problem with the inbuilt one is that helix writes bcp temporary files and
# so we need some kind of glob pattern
def wproc [...args: string] {
  watchexec --clear reset ...$args
}
def wbin [args: closure] {
  # TODO: Figure out how to make this work. Or whether there's any support for a no-glob arg
  # let g: glob = "**/*.{rs,ts,js,py,java,bck}"
  # let glob = $g | into string
  # watch . -v --glob=$glob {|| try { do $args } }
  watch . --glob=src/** {|| try { do $args } }
}

def resume [
  # TODO: Try to make this support more than a single string
  proc_name?: string,
  --interactive (-i) = false
] {
  if ($proc_name== null) {
    if (job list | is-not-empty) {
      job unfreeze
    } else {
      print "No frozen jobs found. Try `job list` for the full list."
    }
  } else {
    # With no args, just do "jobs unfreeze"
    # With args, pass to fzf/skim and fuzzy search for the process name
     
    let jobs = job list | filter {|j| $j.type == "frozen" }
      | filter {|j|
        ps
        | where pid in $j.pids
        # TODO: Add some fuzzy searching
        | where name starts-with $proc_name
        | is-not-empty
      };

    if ($jobs | is-not-empty) {
      $jobs | first | job unfreeze
    } else {
      print $"No jobs found for ($proc_name)"
    }
  }
}
alias fg = resume

# TODO: Support other args
def hxrg [...args: string] {
  # The reason we have to split the row is because nushell
  # doesn't have the same auto splitting string behaviour
  # of bash/zsh
  let files = rg --no-heading --line-number ...$args | split row "\n";
  let files_to_open = $files
    | each {|s| $s | parse '{file}:{line}:{rest}'}
    | flatten
    | each {|f| $f.file ++ ":" ++ $f.line};

  hx ...$files_to_open 
}

# TODO: Reimplement the following function
# function find-and-replace() {
#     OLD=$1
#     NEW=$2
#     rg $OLD -l | xargs -I {} sd $OLD $NEW {}
# }

# TODO: Reimplement any remaining aliases
# bitwise? tree=>erd? find=>fd?
