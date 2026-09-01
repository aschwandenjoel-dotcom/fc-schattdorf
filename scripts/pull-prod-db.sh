#!/usr/bin/env bash
# ====================================================================
# Produktions-DB nach lokal holen (Hostpoint -> Docker)
# --------------------------------------------------------------------
# WICHTIG: Seit der Migration auf pflegbare Inhalte (Juli 2026) ist die
# LIVE-Datenbank die Quelle der Wahrheit (Redaktion pflegt im
# Live-Admin). Vor lokaler Arbeit an Inhalten oder Vorlagen IMMER
# zuerst dieses Skript ausführen, sonst arbeitet man auf veralteten
# Daten und Deploys überschreiben Redaktions-Änderungen!
#
# Ablauf:
#   1. Sicherung der lokalen DB (backups/db-vor-pull-<Datum>.sql.gz)
#   2. Export-Skript (deploy/fcs-db-export.php.tpl) mit Token in den
#      Live-Webroot legen und Dump per HTTPS abholen
#      (MySQL ist auf Hostpoint nur aus Web-Prozessen erreichbar)
#   3. Vollständigkeit prüfen (Endmarke), Import in die lokale DB
#   4. URLs auf localhost umschreiben (Host ohne Schema, wegen
#      JSON-escapter URLs z. B. in MailPoet-Vorlagen)
#
# Uploads/Medien werden NICHT synchronisiert — bei Bedarf:
#   rsync -avz aziwivac@sl1819.web.hostpoint.ch:www/fcschattdorf/wp-content/uploads/ \
#     ./wp-content/uploads/
#   docker-compose.yml bindet dieses Verzeichnis in wordpress und wpcli
#   ein, der rsync landet also direkt am richtigen Ort (seit 01.09.2026).
#
# Aufruf:  ./scripts/pull-prod-db.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env ]; then set -a; . ./.env; set +a; else echo "FEHLER: .env fehlt." >&2; exit 1; fi

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
STAMP="$(date +%Y%m%d-%H%M%S)"

# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh

wpc() { docker compose run --rm -T wpcli wp "$@"; }
log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

log "Container prüfen…"
# «docker compose up -d» ist idempotent: laufende Container bleiben, fehlende
# starten. Bewusst ohne vorheriges «ps --status running --format …» — diese
# Flags gibt es nicht in jeder Compose-Version, und schlug der Check fehl,
# brach das ganze Skript mit «unknown flag: --status» ab (30.08.2026).
if ! docker compose up -d db wordpress; then
  echo "FEHLER: Container liessen sich nicht starten." >&2
  echo "  Läuft die Docker-Maschine?   colima status   (sonst: colima start)" >&2
  echo "  Ist Compose vorhanden?       docker compose version" >&2
  exit 1
fi

# Auf die Datenbank warten statt blind zu schlafen: erst wenn MySQL antwortet,
# ist der folgende mysqldump verlässlich.
printf "    warte auf die Datenbank"
for _ in $(seq 1 60); do
  if docker compose exec -T db mysqladmin ping -u"${DB_USER}" -p"${DB_PASSWORD}" --silent >/dev/null 2>&1; then
    db_bereit=1; break
  fi
  printf "."; sleep 1
done
echo
if [ "${db_bereit:-0}" != "1" ]; then
  echo "FEHLER: Datenbank antwortet nach 60 s nicht — Abbruch, lokale DB unverändert." >&2
  exit 1
fi

log "1/4  Lokale DB sichern (backups/db-vor-pull-${STAMP}.sql.gz)…"
mkdir -p backups
docker compose exec -T db mysqldump -u"${DB_USER}" -p"${DB_PASSWORD}" \
  --single-transaction --no-tablespaces "${DB_NAME}" 2>/dev/null | gzip > "backups/db-vor-pull-${STAMP}.sql.gz"

log "2/4  Produktions-Dump abholen…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" deploy/fcs-db-export.php.tpl > deploy/fcs-db-export.php
scp -q deploy/fcs-db-export.php "$HOST:$WEBROOT/fcs-db-export.php"
rm deploy/fcs-db-export.php
# Ab jetzt liegt ein Token-Skript im Live-Webroot. Es wird beim Skriptende
# entfernt — auch bei Abbruch (set -e): am 05.09.2026 scheiterte der
# curl-Abruf (Zertifikat), und das Skript blieb auf dem Server liegen.
trap 'ssh "$HOST" "rm -f $WEBROOT/fcs-db-export.php"' EXIT
DUMP="backups/prod-db-${STAMP}.sql"
lcurl -sS --max-time 600 "$LIVE/fcs-db-export.php?token=${TOKEN}" -o "$DUMP"

log "3/4  Dump prüfen und importieren…"
ENDMARKE="$(tail -c 200 "$DUMP")"
if ! enthaelt "$ENDMARKE" "FCS-DUMP-COMPLETE"; then
  echo "FEHLER: Dump unvollständig (Endmarke fehlt) — lokale DB UNVERÄNDERT." >&2
  head -5 "$DUMP" >&2
  exit 1
fi
GROESSE=$(wc -c < "$DUMP" | tr -d ' ')
if [ "$GROESSE" -lt 500000 ]; then
  echo "FEHLER: Dump verdächtig klein (${GROESSE} Bytes) — lokale DB UNVERÄNDERT." >&2; exit 1
fi
# Exotische MariaDB-Collations für lokales MySQL neutralisieren
sed -e 's/utf8mb4_uca1400[a-z_]*/utf8mb4_unicode_ci/g' "$DUMP" | \
  docker compose exec -T db mysql -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" 2>/dev/null
gzip -f "$DUMP"

log "4/4  URLs auf lokal umschreiben…"
# Host ohne Schema ersetzen (erfasst auch JSON-escapte URLs), dann Schema angleichen
wpc search-replace 'fcschattdorf.dynalias.net' 'localhost:8080' --all-tables --report-changed-only | tail -2
wpc search-replace 'https://localhost:8080' 'http://localhost:8080' --all-tables --report-changed-only | tail -2
wpc search-replace 'https:\/\/localhost:8080' 'http:\/\/localhost:8080' --all-tables --report-changed-only | tail -2
wpc cache flush >/dev/null 2>&1 || true
wpc rewrite flush >/dev/null 2>&1 || true

echo ""
echo "==> Fertig. Lokale DB = Produktionsstand von ${STAMP}."
echo "    Rückgängig: gunzip -c backups/db-vor-pull-${STAMP}.sql.gz | docker compose exec -T db mysql -u${DB_USER} -p<pass> ${DB_NAME}"
curl -s -o /dev/null -w "    Lokale Seite: HTTP %{http_code} (http://localhost:8080)\n" http://localhost:8080/
