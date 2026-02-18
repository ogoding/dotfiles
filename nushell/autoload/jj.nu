alias jjui = lazyjj

alias jdiff = jj diff
alias jd = jdiff
alias jsh = jj show
alias jst = jj status
alias js = jst
alias jjl = jj log
alias jl = jjl
alias jjc = jj commit
alias jc = jjc
alias jn = jj new

alias jjf = jj git fetch
alias jf = jjf

def jj_rebase_to_latest [] {
  jj git fetch;
  jj rebase --onto "trunk()"
}

def jjp [] {
  jj tug;
  jj git push;
}
alias jp = jjp

def jjnew [new_bookmark?: string] {
  jj new "trunk()";
  if ($new_bookmark) {
    jj bookmark create $new_bookmark -r @;
  }
}
alias jnew = jjnew
alias jn = jjnew

# https://danverbraganza.com/writings/most-frequent-jj-commands
# https://jj-vcs.github.io/jj/latest/github/#using-a-named-bookmark

# def jj-squash-range [oldest_commit: string, latest_commit: string, target_commit: string] {
#   jj squash --from $"($oldest_commit)..($latest_commit)" --into $target_commit
# }

# TODO: Create an alias for absorb (or some docs)
# With default args, absorb effectively redistributes/reallocates changes from the current commit
# to the most recent mutable ancestor/parent commit when the file was modified
# This might end up updating a number of commits
# https://www.pauladamsmith.com/blog/2025/08/jj-absorb.html
# alias jj-redistribute-changes = jj absorb --from @ --to "mutable()"
