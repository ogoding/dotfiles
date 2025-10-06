alias jjui = lazyjj

alias jdiff = jj diff
alias jd = jdiff
alias jsh = jj show
alias jst = jj status
alias js = jst
alias jjl = jj log
alias jl = jl
alias jc = jj commit
alias jn = jj new

alias jgf = jj git fetch
alias jf = jgf

def jjp [] {
  jj tug;
  jj git push;
}

def jjnew [new_bookmark: string, base_bookmark?: string] {
  let bookmarks = jj bookmark list --all --template "concat(self.name(), '\n')"
    | split row "\n"
    | where {|line| $line in ['main', 'develop', 'trunk', 'master']};
  let bookmark = $base_bookmark | default ($bookmarks | first);

  jj new $bookmark;
  jj bookmark create $new_bookmark -r @-;
}
alias jnew = jjnew

# https://danverbraganza.com/writings/most-frequent-jj-commands
# https://jj-vcs.github.io/jj/latest/github/#using-a-named-bookmark
