# TODO: Consider moving all this into a module

alias jjui = lazyjj

alias jdiff = jj diff
alias jd = jdiff
alias jsh = jj show
alias jst = jj status
alias js = jst
alias jjla = jj log -r "latest(.., 20)"
alias jla = jjla
alias jls = jj log --limit 20 -r "ancestors(reachable(@, mutable()), 2)"
alias jjl = jj log --limit 20 
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

# TODO: Add another flag to spin out a new workspace?
def jjnew [new_bookmark?: string, --fetch(-f)] {
  if $fetch {
    print "Fetching changes to the git tree"
    jj git fetch;
  }

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
def jj_list_bookmarks [] {
  jj bookmark list -r "mine()" --ignore-working-copy 
    | lines
    | where $it !~ "@"
    | each {|s| $s | parse '{bookmark}:{rest}' }
    | get bookmark
    | flatten
}

# TODO: Make this a function and avoid `input list` if there's only one value
alias jj_switch_bookmarks = jj new (jj_list_bookmarks | input list --fuzzy "Pick a bookmark")

def jj_mega_merge_bookmarks [] {
  let bookmarks = jj_list_bookmarks | input list --fuzzy --multi "Pick bookmarks to merge";
  if ($bookmarks | is-not-empty) {
    let merge_string = $bookmarks | each {$"-b ($in)"} | str join " ";
    jj new -r @- ($merge_string)
  }
}

def jj_list_workspaces [] {
  jj workspace list --ignore-working-copy --template 'concat(name, "\n")' | split row "\n"
}

def --env jj_cd_workspace [name?: string@jj_list_workspaces] {
  if $name == null {
    # TODO: Avoid `input list` if there's only one value
    let workspace = jj_list_workspaces | split row "\n" | input list --fuzzy "Pick a workspace to go to:"
    if $workspace != null {
      print $"Jumping to ($workspace)"
      cd (jj workspace root --ignore-working-copy --name $workspace)
    }

    # IDEA: If workspace can't be found, create a new one?
  } else {
    try {
      # TODO: Suppress output from the following
      let directory = (jj workspace root --ignore-working-copy --name $name)
      cd $directory
    } catch {
      # JJ doesn't seem to always set a workspace path for the 'default' workspace, so instead we use zoxide
      # and hope that the default repo directory is in the zoxide history
      let repo_name = jj git remote list | lines | first | split row "\t" | last | path parse | get stem

      # TODO: If we're already in the directory that zoxide returns, do nothing
      if $name == "default" {
        z $repo_name
      } else {
        z jj-workspaces $repo_name $name
      }
    }
  }
}

# TODO: Create an alias/function to print the current workspace name
alias jjcdhome = cd (jj workspace root --ignore-working-copy)
alias jjhome = jjcdhome
alias jjws = jj_cd_workspace
alias jws = jjws
alias ws = jjws

# TODO: Instead of having to create a closure, make it a string and call `nu -c $command`?
# see https://github.com/nushell/nushell/discussions/7794
def --env jj_spawn_workspace [name: string, command?: closure, --create-bookmark(-b)=false] {
  let WORKSPACE_DIR = $"($env.HOME)/jj-workspaces"
  if not ($WORKSPACE_DIR | path exists) {
    mkdir $WORKSPACE_DIR
  }
  
  let directory = (jj workspace root --ignore-working-copy --name $name | complete)
  if $directory.exit_code == 0 {
    print $"($name) already exists! Skipping creation..."
  } else {
    let repo_name = jj git remote list | lines | first | split row "\t" | last | path parse | get stem
    let directory = $"($WORKSPACE_DIR)/($repo_name)"

    if not ($directory | path exists) {
      mkdir $directory
    }

    # FIXME: Add some sanitization to $name (e.g. replace `/` with `-`)
    jj workspace add --name $name --revision "trunk()" $"($directory)/($name)"
  }

  jj_cd_workspace $name

  if $create_bookmark {
    jj new -r "trunk()"
    jj bookmark create $name -r @
  }

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

# TODO: Create an alias `jj_close_workspace` that drops the current workspace after a warning
# The idea would be to chain it - e.g. jj_spawn_workspace feature1 -- claude "Please create the feature, and push the branch to a new branch" && jj_close_workspace

# def jj-squash-range [oldest_commit: string, latest_commit: string, target_commit: string] {
#   jj squash --from $"($oldest_commit)..($latest_commit)" --into $target_commit
# }

# TODO: Create an alias for absorb (or some docs)
# With default args, absorb effectively redistributes/reallocates changes from the current commit
# to the most recent mutable ancestor/parent commit when the file was modified
# This might end up updating a number of commits
# https://www.pauladamsmith.com/blog/2025/08/jj-absorb.html
# alias jj-redistribute-changes = jj absorb --from @ --to "mutable()"
