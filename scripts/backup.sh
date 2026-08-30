#!/usr/bin/env bash
# ====================================================================
# Backup der lokalen WordPress-Umgebung
# --------------------------------------------------------------------
# Sichert alles, was NICHT im Git-Repo liegt:
#   • Datenbank  -> backups/db-<Datum>.sql.gz
#   • Uploads    -> backups/uploads-<Datum>.tgz  (Docker-Volume!)
# Zusätzlich wird fc-schattdorf-db.sql im Repo aktualisiert, damit der
# versionierte Transfer-Dump immer dem letzten Stand entspricht.
#
# Jedes Backup wird zusätzlich nach OneDrive gespiegelt (BACKUP_REMOTE_DIR,
# überschreibbar in .env). Lokal wie remote werden die letzten 7 behalten.
#
# Aufruf:  ./scripts/backup.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a; . ./.env; set +a
else
  echo "FEHLER: .env fehlt." >&2; exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p backups

# Zweitkopie ausserhalb des Rechners (OneDrive). In .env überschreibbar.
BACKUP_REMOTE_DIR="${BACKUP_REMOTE_DIR:-$HOME/OneDrive/Urinet/projekte/fc-schattdorf/backup}"

# Container müssen laufen. Direkt im Container nachfragen statt «ps
# --status running --format …» zu parsen: diese Flags gibt es nicht in
# jeder Compose-Version (am 30.08.2026 brach ein Skript deshalb mit
# «unknown flag: --status» ab), und die Pipe in grep -q ist mit pipefail
# ohnehin heikel.
if ! docker compose exec -T db true >/dev/null 2>&1; then
  echo "FEHLER: Container laufen nicht (docker compose up -d)." >&2; exit 1
fi

echo "==> Datenbank sichern…"
docker compose exec -T db mysqldump -u"${DB_USER}" -p"${DB_PASSWORD}" \
  --single-transaction --no-tablespaces "${DB_NAME}" > "backups/db-${STAMP}.sql"
gzip -f "backups/db-${STAMP}.sql"

echo "==> Transfer-Dump im Repo aktualisieren (fc-schattdorf-db.sql)…"
gunzip -c "backups/db-${STAMP}.sql.gz" > fc-schattdorf-db.sql

echo "==> Uploads sichern (aus dem Docker-Volume)…"
docker compose exec -T wordpress tar -C /var/www/html/wp-content -czf - uploads \
  > "backups/uploads-${STAMP}.tgz"

echo "==> Alte Backups aufräumen (behalte die letzten 7)…"
ls -t backups/db-*.sql.gz 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null || true
ls -t backups/uploads-*.tgz 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null || true

# ------------------------------------------------------------------
# Zweitkopie nach OneDrive (falls der OneDrive-Ordner existiert)
if [ -d "$(dirname "$(dirname "$BACKUP_REMOTE_DIR")")" ]; then
  echo "==> Kopiere nach $BACKUP_REMOTE_DIR …"
  mkdir -p "$BACKUP_REMOTE_DIR"
  cp "backups/db-${STAMP}.sql.gz" "backups/uploads-${STAMP}.tgz" "$BACKUP_REMOTE_DIR/"
  ls -t "$BACKUP_REMOTE_DIR"/db-*.sql.gz 2>/dev/null | tail -n +8 | while read -r f; do rm -f "$f"; done
  ls -t "$BACKUP_REMOTE_DIR"/uploads-*.tgz 2>/dev/null | tail -n +8 | while read -r f; do rm -f "$f"; done
else
  echo "WARNUNG: OneDrive-Ordner nicht gefunden ($BACKUP_REMOTE_DIR) — nur lokal gesichert." >&2
fi

echo "==> Fertig:"
ls -lh "backups/db-${STAMP}.sql.gz" "backups/uploads-${STAMP}.tgz" | awk '{print "   ", $9, "("$5")"}'
cat <<'EOF'

   Wiederherstellen:
     DB:      gunzip -c backups/db-<Datum>.sql.gz | docker compose exec -T db mysql -u<user> -p<pass> <dbname>
     Uploads: docker compose exec -T wordpress tar -C /var/www/html/wp-content -xzf - < backups/uploads-<Datum>.tgz
EOF
