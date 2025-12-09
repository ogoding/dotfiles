alias tree = erd
alias cat = bat --color=always
alias btop = btm

alias l = ls
alias ll = ls -l
alias la = ls -la

alias brewup = brew update
def bup [] {
  brew update;
  brew upgrade
}

alias cdconfig = cd ~/.config
alias hxconfig = hx ~/.config
alias hx-clear-log = rm ~/.cache/helix/helix.log

use std/dirs;
alias pushd = dirs add
alias popd = dirs drop
alias dn = dirs next
alias dp = dirs prev
alias dl = dirs
alias dgo = dirs goto

alias nu-watch = watch
def watch [
  args: closure
] {
  clear
  nu-watch . {|op, path|
    let bck_file = $path | str ends-with ".bck";

    const IGNORED_PATHS = ["target", "cache", "out", "build", ".git", ".jj"];
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
  # TODO: If proc_name is number-like, treat it as a job id
  if ($proc_name == null) {
    if (job list | is-not-empty) {
      job unfreeze
    } else {
      print "No frozen jobs found. Try `job list` for the full list."
    }
  } else {
    # With no args, just do "jobs unfreeze"
    # With args, pass to fzf/skim and fuzzy search for the process name

    let jobs = job list | where {|j| $j.type == "frozen" }
      | where {|j|
        ps
        | where pid in $j.pids
        # TODO: Add some fuzzy searching
        | where name starts-with $proc_name
        | is-not-empty
      };

    if ($jobs | is-not-empty) {
      $jobs | last | job unfreeze
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

def top-commands [] {
  history | each {|h| $h.command | split words | first 1 } | flatten | histogram | first 10
}

# TODO: Write something that changes the current dir to either $HOME or the closest .git (whichever is first)
# - make the function to determine the closest .git, .jj or $HOME into a standalone function so that we can use it with zi or fzf to quickly jump around a repo
#   - if we use zi for jumping out, we could just auto insert the project/home dir path into the query prompt
# def cdroot [] {

# }

def backup [
  path: string,
  --include-date(-d) = false
] {
  ## TODO: add a flag to include the date
  cp $path $"($path).bak"
}

def bench [script_file] {
  open $script_file | split row "\n" | hyperfine ...$in
}
