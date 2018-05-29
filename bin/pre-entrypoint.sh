#!/bin/bash

# Helper function to parse the DATABASE_URL to individual env configuration from wordress docker
# Useful when you deploy and link a database using dokku
parse_database_url() {
  if [[ -n "${1}" ]]; then
    local url_without_sheme="${1#*://}"
    local username_password="${url_without_sheme%%@*}"
    local host_name="${url_without_sheme##*@}"

    export WORDPRESS_DB_USER="${username_password%%:*}"
    export WORDPRESS_DB_PASSWORD="${username_password##*:}"
    export WORDPRESS_DB_HOST="${host_name%/*}"
    export WORDPRESS_DB_NAME="${host_name##*/}"
  fi
}

parse_database_url "${DATABASE_URL:-}"