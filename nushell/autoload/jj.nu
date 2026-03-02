# TODO: Consider moving all this into a module

alias jjui = lazyjj

alias jdiff = jj diff
alias jd = jdiff
alias jsh = jj show
alias jst = jj status
alias js = jst
alias jjla = jj log
alias jla = jjla
alias jls = jj log --limit 20 --ignore-working-copy -r "ancestors(reachable(@, mutable()), 2)"
alias jjl = jj log --limit 20 --ignore-working-copy
alias jl = jjl
alias jjc = jj commit
alias jc = jjc

alias jjf = jj git fetch
alias jf = jjf

def jmv [bookmark: string, revset: string = "@-"] {
  jj bookmark move --to $revset --from $bookmark
}

def jj_rebase_to_latest [] {
  jj git fetch;
  # Alternatives such as "--insert-after" results in the commits being rebased
  # being inserted *between* the latest "trunk()" commit and any children
  jj rebase --onto "trunk()"
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


def jj_list_workspaces [] {
  jj workspace list --ignore-working-copy --template 'concat(name, "\n")' | split row "\n"
}

def --env jj_cd_workspace [name?: string@jj_list_workspaces] {
  if $name == null {
    jj_list_workspaces 
  } else {
    # TODO: Use `split row "\n" | input list` to avoid needing to type the whole thing. Can apply it to the $name==null branch too
    cd (jj workspace root --ignore-working-copy --name $name)
  }
}

alias jjcdhome = cd (jj workspace root --ignore-working-copy)
alias jjhome = jjcdhome
alias jjws = jj_cd_workspace
alias jws = jjws
alias ws = jjws

# TODO: Instead of having to create a closure, make it a string and call `nu -c $command`?
# see https://github.com/nushell/nushell/discussions/7794
def --env jj_spawn_workspace [name: string, command?: closure] {
  let WORKSPACE_DIR = $"($env.HOME)/jj-workspaces"
  if not ($WORKSPACE_DIR | path exists) {
    mkdir $WORKSPACE_DIR
  }
  
  let directory = (jj workspace root --ignore-working-copy --name $name | complete)
  if $directory.exit_code == 0 {
    print $"($name) already exists! Skipping creation..."
  } else {
    let repo_name = jj git remote list | lines | first | split row "\t" | last | path parse | get stem
    # FIXME: Add some sanitization to $name (e.g. replace `/` with `-`)
    jj workspace add --name $name --revision "trunk()" $"($WORKSPACE_DIR)/($repo_name)-($name)"
  }

  jj_cd_workspace $name
  # IDEA: Automatically create a new bookmark?

  # TODO: If no command is specified, spawn a new shell in directory?
  if $command != null {
    do $command
  }
}

def jj_drop_workspace [name: string@jj_list_workspaces] {
  if $name == "default" {
    print "ERR: Cannot drop the 'default' workspace"
    return
  }

  let directory = (jj workspace root --ignore-working-copy --name $name)

  # FIXME: Prevent dropping the current workspace

  if $env.LAST_EXIT_CODE != 0 {
    let WORKSPACE_DIR = $"($env.HOME)/jj-workspaces"
    print $"The workspace ($name) does not exist. If this is not expected, or something failed previously,"
    print $"check the ($WORKSPACE_DIR) directory for the files."
    return
  } else {
    print $"Forgetting ($name)..."
    jj workspace forget $name --ignore-working-copy

    print $"Deleting ($directory)..."
    # TODO: Check if directory exists?
    rm -r $directory

    print $"($name) has been removed."
  }
}

# FIXME: Add a jj_switch_workspace with a name and/or fuzzy search menu

# def jj-squash-range [oldest_commit: string, latest_commit: string, target_commit: string] {
#   jj squash --from $"($oldest_commit)..($latest_commit)" --into $target_commit
# }

# TODO: Create an alias for absorb (or some docs)
# With default args, absorb effectively redistributes/reallocates changes from the current commit
# to the most recent mutable ancestor/parent commit when the file was modified
# This might end up updating a number of commits
# https://www.pauladamsmith.com/blog/2025/08/jj-absorb.html
# alias jj-redistribute-changes = jj absorb --from @ --to "mutable()"
