module py {
  export def run [script: string = "main.py"] {
    if ($script| path exists) {
      uv run $script
    } else {
      print $"ERROR: ($script) does not exist!"
    }
  }
  export alias lint = uvx ruff check
  export alias format = uvx ruff check
  export alias type-check = uvx ty check

  export alias update-tools = uvx tool upgrade --all

  export alias venv = uv venv
}

alias pip3 = uv pip
alias pip = uv pip

# TODO: Auto enable this module if .py file in current dir
