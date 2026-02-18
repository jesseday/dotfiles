# Loads Jira CLI authentication from ~/me/env/jira-cli.sh
# Usage: jira-auth

function jira-auth() {
  local env_file="$HOME/me/env/jira-cli.sh"
  if [[ -f "$env_file" ]]; then
    source "$env_file"
    echo "Jira CLI auth loaded."
  else
    echo "Error: $env_file not found." >&2
    return 1
  fi
}
