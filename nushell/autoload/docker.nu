$env.config.abbreviations = $env.config.abbreviations | default {} | merge {
  dps: 'docker ps --all'
  dup: 'docker-compose up --detach'
  ddown: 'docker-compose down'
  dlog: 'docker-compose logs --follow'
  dprune: 'docker system prune --force --all'
  dvprune: 'docker volume prune --force --all'
  dstop: 'docker stop ...(docker ps --all --quiet | split row "\n")'
}
