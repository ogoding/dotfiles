module py {
  export def run [script: string = "main.py"] {
    if ($script| path exists) {
      uv run $script
    } else {
      print $"ERROR: ($script) does not exist!"
    }
  }

  # TODO: Run, or at least prompt an uv-update if it hasn't happened in a while
  # TODO: Run uv tool install if tool is missing - uvx run <tool> doesn't seem to do the same as as uv tool install
  # NOTE: Additionally, we might want to swap between uv and uvx depending on whether the tool is already part of the pyproject.toml file or venv
  export alias lint = uvx ruff check
  export alias format = uvx ruff check
  export alias type-check = uvx ty check

  # TODO: Create something to track the last update and auto update
  # Add a config/envvar to disable the autoupdate
  # TODO: Make uv-update automatically run uv-install if any packages are missing
  export alias uv-install = uv tool install ruff ty
  export alias uv-update = uv tool upgrade --all

  export alias venv = uv venv
}

alias pip3 = uv pip
alias pip = uv pip

# TODO: Auto enable this module if .py file in current dir
