#!/usr/bin/env bash
# ====================================================================
# Deploy: Liveticker-Seite /liveticker/ (08.09.2026)
#
# Zwei Teile, in dieser Reihenfolge:
#   1. Theme-Code über scripts/deploy-theme.sh — page-liveticker.php,
#      inc/fcs-fields-liveticker.php, Startseiten-Link auf /liveticker/.
#   2. DB-Änderung über ein token-geschütztes PHP-Skript im Webroot
#      (auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar): legt
#      die Seite «Liveticker» mit der Vorlage an (noindex, Ticker-Link
#      leer). Siehe Kopf von deploy/fcs-liveticker-seite.php.tpl.
#
# Danach pflegt die Redaktion vor jedem Spiel den Tickaroo-Link im
# Seitenfeld «Link zum aktuellen Ticker» der Seite Liveticker — ohne Deploy.
#
# Erst Probelauf, dann Rückfrage, dann Schreiben. Idempotent.
# Aufruf:  ./deploy/deploy-liveticker.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-liveticker-seite.php"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Theme ────────────────────────────────────────────────────────
log "1/4  Theme-Code deployen (scripts/deploy-theme.sh)…"
./scripts/deploy-theme.sh

# ── 2. Seite anlegen: Probelauf ─────────────────────────────────────
log "2/4  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"
# Bei Abbruch darf das Token-Skript nicht liegen bleiben.
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"' EXIT

lcurl -sS --max-time 60 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf plausibel? Seite jetzt anlegen? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume das Skript vom Server…"
  exit 0
fi

# ── 3. Schreiben und aufräumen ──────────────────────────────────────
log "3/4  Seite anlegen…"
lcurl -sS --max-time 60 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
trap - EXIT
echo "    ${PHPNAME} liefert HTTP $(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}") (erwartet 404)"

# ── 4. Prüfen ───────────────────────────────────────────────────────
log "4/4  Warte 60 s (Hostpoint-Seitencache) und prüfe…"
sleep 60
fail=0
code="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 30 "$LIVE/liveticker/")"
body="$(lcurl -sS --max-time 30 "$LIVE/liveticker/" || true)"
if [ "$code" = "200" ] && enthaelt "$body" "Zurzeit läuft kein Liveticker"; then
  echo "    OK     /liveticker/ zeigt die Hinweisseite (kein Ticker gesetzt)"
elif [ "$code" = "302" ]; then
  echo "    OK     /liveticker/ leitet auf den gesetzten Ticker weiter"
else
  echo "    FEHLER /liveticker/ -> HTTP $code"; fail=1
fi
start="$(lcurl -sS --max-time 30 "$LIVE/?cb=$(date +%s)" || true)"
if enthaelt "$start" "href=\"$LIVE/liveticker/\""; then
  echo "    OK     Startseite verlinkt «Liveticker» auf /liveticker/"
else
  echo "    FEHLER Startseite verlinkt noch nicht auf /liveticker/ (Cache? nach 1–2 min erneut prüfen)"; fail=1
fi

echo
if [ "$fail" = "0" ]; then
  printf "\033[1;32mFertig – Liveticker-Seite ist live.\033[0m\n"
  echo "  Redaktion: wp-admin -> Seiten -> Liveticker -> Box «Seiteninhalte» -> «Link zum aktuellen Ticker»"
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht — oben nachsehen.\033[0m\n"; exit 1
fi
