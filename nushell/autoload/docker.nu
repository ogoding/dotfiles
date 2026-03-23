alias dps = docker ps --all
alias dup = docker-compose up --detach
alias ddown = docker-compose down
alias dlog = docker-compose logs --follow
alias dprune = docker system prune --force --all
alias stop = docker stop ...(docker ps --all --quiet | split row "\n")
