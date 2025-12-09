alias jjui = lazyjj

alias jdiff = jj diff
alias jd = jdiff
alias jsh = jj show
alias jst = jj status
alias js = jst
alias jjl = jj log
alias jl = jjl
alias jc = jj commit
# alias jn = jj new

alias jjf = jj git fetch
alias jf = jjf

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
  if ($new_bookmark) {
    jj bookmark create $new_bookmark -r @;
  }
}
alias jnew = jjnew
alias jn = jjnew

# https://danverbraganza.com/writings/most-frequent-jj-commands
# https://jj-vcs.github.io/jj/latest/github/#using-a-named-bookmark
