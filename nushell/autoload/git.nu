# TODO: Move all this into a module and autoload it if `.git` exists?
# TODO: Setup some better git completions

alias gitui = lazygit
alias gui = lazygit

alias gadd = git add
alias gaddmod = gadd -u
alias gaddm = gaddmod

alias gc = git commit
alias gcm = gc -m
alias gca = gc --amend

alias gst = git status
alias gfa = git fetch --all --prune
alias ggp = git push origin
alias ggf = git push origin --force
alias gpu = ggp
alias gpl = git pull

alias glog = git dlog
alias gloggraph = git log --graph --oneline

# TODO: Convert these to multi-command aliases when it's supported
# https://github.com/nushell/nushell/issues/740#issuecomment-1950144291
def gac [] {
  gaddmod;
  gc
}

def gacm [message: string] {
  gaddmod;
  gcm $message
}

alias gdiff = git diff
alias gdiffstg = git diff --staged
alias gdif = gdiff
alias gdifs = gdiffstg
alias gdiffs = gdiffstg

# TODO: Convert this to a function and use fzf/skim when no arg is supplied (or default branch)
alias gsw = git switch # TODO: Also fetch/pull?
alias gswnew = git switch -c
alias gundo = git restore
alias gundos = git restore --staged

# TODO: Add stash aliases, e.g. specific file, diff with current, etc
# TODO: Add method of adding/stashing hunks/chunks

alias gmodule-update = git submodule update --remote --merge
alias gmup = gmodule-update

# TODO: Setup some aliases using fzf or skim
# https://www.grailbox.com/2023/04/nushell-fzf-functions-for-git-switch-and-git-branch-d/
# https://thevaluable.dev/fzf-git-integration/
# https://www.reddit.com/r/commandline/comments/ne90tm/branch_switching_with_fzf/
# https://medium.com/@mrWinston/smarter-git-checkout-using-fzf-to-supercharge-your-commandline-7507db600996
