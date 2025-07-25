module py {
  export def pyrun [script: string = "main.py"] {
    if ($script| path exists) {
      uv run $script
    } else {
      print $"ERROR: ($script) does not exist!"
    }
  }

  # TODO: Run, or at least prompt an uv-update if it hasn't happened in a while
  # TODO: Run uv tool install if tool is missing - uvx run <tool> doesn't seem to do the same as as uv tool install
  # NOTE: Additionally, we might want to swap between uv and uvx depending on whether the tool is already part of the pyproject.toml file or venv
  export def lint [] {
    uv tool run ruff check
  }
  export def format [] {
    uv tool run ruff format
  }
  export def type-check [] {
    uv tool run ty check
  }
  export def check [] {
    if not (["ruff", "ty"] | all {|tool| (uv tool list) | str contains $tool }) {
      print "Installing ruff (formatter/linter) and ty (type checker)"
      uv-install-tools
    }

    lint
    format
    type-check
  }

  export def uv-install-tools [] {
    uv tool install ruff;
    uv tool install ty;
  }
  export alias uv-update = uv tool upgrade --all

  export alias venv = uv venv
}

alias pip3 = uv pip
alias pip = uv pip

# TODO: Auto enable this module if .py file in current dir


