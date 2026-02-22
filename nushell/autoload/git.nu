def gac [] {
  git add --update;
  git commit;
}

def gacm [message: string] {
  git add -u;
  git commit --message $message
}

# TODO: Add stash aliases, e.g. specific file, diff with current, etc
# TODO: Add method of adding/stashing hunks/chunks

$env.config.abbreviations = $env.config.abbreviations | default {} | merge {
  gitui: 'lazygit',
  gui: 'lazygit',

  gadd: 'git add',
  gaddm: 'gadd -u',
  gaddmod: 'gadd -u',

  gc: 'git commit',
  gcm: 'gc -m',
  gca: 'gc --amend',

  gst: 'git status',
  gfa: 'git fetch --all --prune',
  ggp: 'git push origin',
  ggf: 'git push origin --force',
  gpl: 'git pull',

  glog: 'git dlog',
  gloggraph: 'git log --graph --oneline',

  gdiff: 'git diff',
  gdiffstg: 'git diff --staged',
  gdif: 'git diff',
  gdifs: 'git diff --staged',
  gdiffs: 'git diff --staged',

  gsw: 'git switch',
  gswnew: 'git switch -c',
  gundo: 'git restore',
  gundos: 'git restore --staged',

  gmodul:u'pdate = git submodule update --remote --merge',
  gmup: 'git submodule update --remote --merge',
};

# TODO: Setup some aliases using fzf or skim
# https://www.grailbox.com/2023/04/nushell-fzf-functions-for-git-switch-and-git-branch-d/
# https://thevaluable.dev/fzf-git-integration/
# https://www.reddit.com/r/commandline/comments/ne90tm/branch_switching_with_fzf/
# https://medium.com/@mrWinston/smarter-git-checkout-using-fzf-to-supercharge-your-commandline-7507db600996
