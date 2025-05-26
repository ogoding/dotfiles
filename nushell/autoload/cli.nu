alias tree = erd
alias cat = bat --color=always
alias btop = btm

alias l = ls
alias ll = ls -l
alias la = ls -la

alias brewup = brew update
alias bup = brew update and brew upgrade

alias cdconfig = cd ~/.config
alias hxconfig = hx ~/.config
alias hx-clear-log = rm ~/.cache/helix/helix.log

alias nu-watch = watch
def watch [
  args: closure
] {
  clear
  nu-watch . {|op, path|
    let bck_file = $path | str ends-with ".bck";

    const IGNORED_PATHS = ["target", "cache", "out", "build"];
    let ignored = $IGNORED_PATHS | any {|dir| $path | str contains $dir };

    if (($op == "Write") and not $bck_file and not $ignored) {
      clear
      try { do $args }
    }
  }
}

def resume [
  # TODO: Try to make this support more than a single string
  proc_name?: string,
  --interactive (-i) = false
] {
  if ($proc_name == null) {
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

def hxfd [...args: string] {
  let files = fd ...$args | split row "\n";
  hx ...$files
}

def find-and-replace [old: string, new: string] {
  rg $old -l
    | split row "\n"
    | each {|file| sd $old $new $file}
}
