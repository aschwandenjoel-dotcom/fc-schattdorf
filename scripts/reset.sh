#!/usr/bin/env bash
# Setzt die Umgebung KOMPLETT zurück (löscht Datenbank + WordPress-Dateien).
# Das Child-Theme im Repo bleibt erhalten.
set -euo pipefail
cd "$(dirname "$0")/.."

read -r -p "Wirklich ALLE lokalen WordPress-Daten löschen? [j/N] " a
case "$a" in
  j|J|y|Y) ;;
  *) echo "Abgebrochen."; exit 0 ;;
esac

docker compose down -v
echo "Erledigt. Neu aufsetzen mit: ./scripts/setup.sh"
