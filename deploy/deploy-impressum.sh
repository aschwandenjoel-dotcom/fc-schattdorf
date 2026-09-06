#!/usr/bin/env bash
# ====================================================================
# Deploy: Impressum — Webdesign «Urinet Aschwanden», urinet.ch, September 2026
#
# Reine DB-Änderung über ein token-geschütztes PHP-Skript im Webroot
# (MySQL ist auf Hostpoint nur aus Web-Prozessen erreichbar). Erst
# Probelauf, dann Rückfrage, dann Schreiben; idempotent. Unabhängig vom
# Domainwechsel — von main aus fahren.
#
# Aufruf:  ./deploy/deploy-impressum.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-impressum-update.php"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

log "1/4  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"
# Bei Abbruch darf das Token-Skript nicht liegen bleiben.
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"' EXIT

lcurl -sS --max-time 60 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume das Skript vom Server…"
  exit 0
fi

log "2/4  DB-Änderung ausführen…"
lcurl -sS --max-time 60 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

log "3/4  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
trap - EXIT
echo "    ${PHPNAME} liefert HTTP $(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}") (erwartet 404)"

log "4/4  Warte 60 s (Hostpoint-Seitencache) und prüfe…"
sleep 60
body="$(lcurl -sS --max-time 60 "$LIVE/impressum/" || true)"
if enthaelt "$body" "Urinet Aschwanden" && enthaelt "$body" "urinet.ch" && enthaelt "$body" "September 2026"; then
  printf "\033[1;32mFertig – Impressum nennt «Urinet Aschwanden».\033[0m\n"
else
  printf "\033[1;31mFertig, ABER «Urinet Aschwanden» steht noch nicht auf /impressum/ — Cache? Nach 1–2 min erneut prüfen:\033[0m\n"
  echo "  curl -s $LIVE/impressum/ | grep -c 'Urinet Aschwanden'"
  exit 1
fi
