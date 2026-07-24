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

# Sicherheitsnetz: erst sichern, dann löschen. Uploads und DB liegen NUR im
# Docker-Volume — ohne Backup wären sie unwiederbringlich weg.
if docker compose ps --status running --format '{{.Service}}' | grep -q '^db$'; then
  echo "==> Automatisches Backup vor dem Reset…"
  ./scripts/backup.sh || { echo "FEHLER: Backup fehlgeschlagen — Reset abgebrochen." >&2; exit 1; }
else
  echo "WARNUNG: Container laufen nicht — es kann kein Backup erstellt werden."
  read -r -p "Trotzdem OHNE Backup löschen? [j/N] " b
  case "$b" in
    j|J|y|Y) ;;
    *) echo "Abgebrochen."; exit 0 ;;
  esac
fi

docker compose down -v
echo "Erledigt. Neu aufsetzen mit: ./scripts/setup.sh"
