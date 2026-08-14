# TODO: Consider moving all this into a module or a series of modules
# Or using sub-commands more: https://www.nushell.sh/book/style_guide.html#sub-commands
# TODO: Replace `jj` calls to `^jj`

# Cheaky shortcut to skipping a bit of typing. Should be safe enough until some other vcs is needed
alias "jj clone" = jj git clone --colocate

def "jj log bookmarks-with-changes" [file: string] {
  jj log -r $"bookmarks\(\) & files\(\"($file)\"\)"
}

def "jj bookmarks with-changes" [file: string] {
  jj bookmark list -r $"bookmarks\(\) & files\(\"($file)\"\)"
}

def "jj bookmark-move" [bookmark: string, revset: string = "@-"] {
  jj bookmark move --to $revset --from $bookmark
}

def "jj rebase-to-latest" [] {
  jj git fetch;
  # Alternatives such as "--insert-after" results in the commits being rebased
  # being inserted *between* the latest "trunk()" commit and any children
  jj rebase --onto "trunk()"
}

def "jj push" [] {
  # TODO: Replace with `jj bookmark advance`
  jj tug;
  jj git push;
}

# TODO: Add another flag to spin out a new workspace?
def "jj bookmark-new" [new_bookmark?: string, --fetch(-f)] {
  if $fetch {
    print "Fetching changes to the git tree"
    jj git fetch;
  }

  jj new "trunk()";
  if ($new_bookmark != null) {
    jj bookmark create $new_bookmark -r @;
  }
}

# TODO: Create aliases for listing conflicted bookmarks
# https://danverbraganza.com/writings/most-frequent-jj-commands
# https://jj-vcs.github.io/jj/latest/github/#using-a-named-bookmark


def jj-bookmarks [] {
  jj bookmark list --ignore-working-copy --color never -T 'if(!remote, name ++ "\n")' | lines
}

def "jj bookmark-jump" [name?: string@jj-bookmarks] {
  mut bookmark: string = $name

  if $name == null {
    $bookmark = (jj-bookmarks | input list --fuzzy "Pick a bookmark")
  }

  if $bookmark != null {
    jj new $bookmark
  }
}
# alias "jj bookmark-jump" = jj new (jj-bookmarks | input list --fuzzy "Pick a bookmark")
alias "jj bookmark-goto" = jj bookmark swap

def "jj bookmark-megamerge" [] {
  let bookmarks = jj-bookmarks | input list --fuzzy --multi "Pick bookmarks to merge";
  if ($bookmarks | is-not-empty) {
    let merge_string = $bookmarks | each {$"-b ($in)"} | str join " ";
    jj new -r @- ($merge_string)
  }
}

## Workspace aliases
def jj-workspaces [] {
  jj workspace list --ignore-working-copy --template 'concat(name, "\n")' | split row "\n"
}

def --env "jj workspace-jump" [name?: string@jj-workspaces] {
  if $name == null {
    # TODO: Avoid `input list` if there's only one value
    let workspace = jj-workspaces | split row "\n" | input list --fuzzy "Pick a workspace to go to:"
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

# TODO: Instead of having to create a closure, make it a string and call `nu -c $command`?
# see https://github.com/nushell/nushell/discussions/7794
def --env "jj workspace-spawn" [
    name: string,
    command?: closure,
    revision?: string = "trunk()",
    --create-bookmark(-b)=false
  ] {
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

  jj workspace-jump $name

  if $create_bookmark {
    jj new -r "trunk()"
    jj bookmark create $name -r @
  }

  # TODO: If no command is specified, spawn a new shell in directory?
  if $command != null {
    do $command
  }
}

def "jj workspace-drop" [name: string@jj-workspaces] {
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

# TODO: Create an alias `jj_close_workspace`/`jj_cleanup_workspace` that drops the current workspace after a warning
# The idea would be to chain it - e.g. `jj_spawn_workspace feature1 -- claude "Please create the feature, and push the branch to a new branch" && jj_close_workspace` or `jj commit && jjpush && jj_close_workspace`
# IMPORTANT: This will need to log a warning if there are any pending changes (i.e. the current commit is not empty and/or has no description). Ideally, it should also check that all the latest changes have been pushed to remote
# This should also switch back to default (or the first other workspace)

# TODO: Create an alias/function to print the current workspace name
alias ws = jj workspace-jump
alias "ws jump" = jj workspace-jump
alias "ws spawn" = jj workspace-spawn
alias "ws drop" = jj workspace-drop
alias bm = jj bookmark-jump
alias "bm jump" = jj bookmark-jump
alias "bm new" = jj bookmark-new

# Squash a range of commits into some target (from oldest to newest)
def "jj squash-range" [oldest_commit: string, latest_commit: string, target_commit: string] {
  jj squash --from $"($oldest_commit)..($latest_commit)" --into $target_commit
}

# TODO: Create an alias for absorb (or some docs)
# With default args, absorb effectively redistributes/reallocates changes from the current commit
# to the most recent mutable ancestor/parent commit when the file was modified
# This might end up updating a number of commits
# https://www.pauladamsmith.com/blog/2025/08/jj-absorb.html
# alias jj-redistribute-changes = jj absorb --from @ --to "mutable()"

$env.config.abbreviations = $env.config.abbreviations | default {} | merge {
  jsh: 'jj show',
  jst: 'jj status',
  jjc: 'jj commit',
  jc: 'jj commit',
  jjf: 'jj git fetch',
  jf: 'jj git fetch',
  jjp: 'jj push',
  jp: 'jj push',

  jll: 'jj log -r "latest(.., 20)"',
  jls: 'jj log -r "ancestors(reachable(@, mutable()), 2)" --limit 20',
  jlsa: 'jj log -r "ancestors(reachable(@, mutable()), 2)"',
  jl: 'jj log --limit 20',
  jla: 'jj log',

  jjrbl: 'jj rebase-to-latest',
  jrbl: 'jj rebase-to-latest',
  jjws: 'jj workspace-jump',
  jjcdhome: 'cd (jj workspace root --ignore-working-copy)',
  jjhome: 'cd (jj workspace root --ignore-working-copy)',
};
