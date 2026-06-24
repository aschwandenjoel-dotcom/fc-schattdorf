#!/usr/bin/env bash
# Bequemer Wrapper für WP-CLI-Befehle.
# Beispiele:
#   ./scripts/wp.sh plugin list
#   ./scripts/wp.sh post list --post_type=page
#   ./scripts/wp.sh user list
set -euo pipefail
cd "$(dirname "$0")/.."
exec docker compose run --rm wpcli wp "$@"
