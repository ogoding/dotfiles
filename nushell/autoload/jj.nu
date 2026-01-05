# TODO: Consider moving all this into a module

alias jjui = lazyjj

alias jdiff = jj diff
alias jd = jdiff
alias jsh = jj show
alias jst = jj status
alias js = jst
alias jjla = jj log
alias jla = jjla
alias jjl = jj log --limit 20 --ignore-working-copy
alias jl = jjl
alias jls = jj log --limit 20 --ignore-working-copy -r "ancestors(reachable(@, mutable()), 2)"
alias jc = jj commit

alias jjf = jj git fetch
alias jf = jjf

def jmv [bookmark: string, revset: string = "@-"] {
  jj bookmark move --to $revset --from $bookmark
}

def jj_rebase_to_latest [] {
  jj git fetch;
  jj rebase -A "trunk()"
}

def jjp [] {
  jj tug;
  jj git push;
}
alias jp = jjp

def jjnew [new_bookmark?: string] {
  jj new "trunk()";
  if ($new_bookmark != null) {
    jj bookmark create $new_bookmark -r @;
  }
}
alias jnew = jjnew
alias jn = jjnew

# TODO: Create aliases for listing conflicted bookmarks
# https://danverbraganza.com/writings/most-frequent-jj-commands
# https://jj-vcs.github.io/jj/latest/github/#using-a-named-bookmark


## Workspace aliases

# TODO: Bookmark picker alias/function for pushing?
alias jjws = jj_workspace_path

def jj_workspace_path [name: string] {
  # TODO: fuzzy search through workspace list to find the correct name
  # auto accept if only one is available
  # TODO: Open interactive menu if nothing is provided or --interactive is passed in
  jj workspace root --ignore-working-copy --name $name
}

# TODO: Instead of having to create a closure, make it a string and call `nu -c $command`?
# see https://github.com/nushell/nushell/discussions/7794
def jj_spawn_workspace [name: string, command?: closure] {
  let WORKSPACE_DIR = $"($env.HOME)/jj-workspaces"
  if not ($WORKSPACE_DIR | path exists) {
    mkdir $WORKSPACE_DIR
  }
  
  let directory = jj workspace root --ignore-working-copy --name $name | complete
  if $directory.exit_code == 0 {
    print $"($name) already exists! Skipping creation..."
  } else {
    # FIXME: use the repo name in the path (or the directory name)
    jj workspace add --name $name --revision "trunk()" $"($WORKSPACE_DIR)/($name)"
  }

  cd (jj_workspace_path $name)

  if $command != null {
    # TODO: Spawn a new nushell instance, then run the command?
    # Maybe this will persist working dir of the other workspace
    do $command
  }
}

# TODO: Add a --interactive flag to fuzzy search through the workspace list
def jj_drop_workspace [name: string] {
  # TODO: Prevent dropping the current workspace?
  if $name == "default" {
    print "ERR: Cannot drop the 'default' workspace"
    return
  }

  let directory = jj workspace root --ignore-working-copy --name $name 

  if $env.LAST_EXIT_CODE != 0 {
    let WORKSPACE_DIR = $"($env.HOME)/jj-workspaces"
    print $"The workspace ($name) does not exist. If this is not expected, or something failed previously,"
    print $"check the $($WORKSPACE_DIR) directory for the files."
    return
  } else {
    jj workspace forget $name --ignore-working-copy

    # TODO: Check if we are currently in the directory, if so, switch to the `default` workspace
    # _then_ delete $directory

    # TODO: Check if directory exists?
    rm -r $directory
  }
}

# FIXME: Add a jj_switch_workspace with a name and/or fuzzy search menu
