#!/usr/bin/env bash
# ====================================================================
# Einmal-Deploy: News-Beitrag «33. Dorf- und 66. Grümpelturnier»
#   -> Hostpoint (Produktion). GEZIELT, nur dieser eine Beitrag.
#
# Ablauf:
#   1. 25 Fotos per rsync nach wp-content/uploads/2026/07/ hochladen
#   2. Token-geschütztes Import-PHP in den Webroot legen (MySQL ist auf
#      Hostpoint nur aus Web-Prozessen erreichbar), per HTTPS auslösen
#      -> legt Beitrag + Anhänge über die WP-API an (neue, kollisions-
#      freie IDs), rührt die übrige DB NICHT an. Skript löscht sich selbst.
#   3. Reste entfernen und nach 60 s verifizieren (Hostpoint-Seitencache).
#
# Idempotent: Existiert der Beitrag (Slug) schon, meldet der Import «SKIP».
# Aufruf:  ./deploy/deploy-gruempi.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
UPLOAD_SUB="wp-content/uploads/2026/07"
SLUG="33-dorf-und-66-gruempelturnier-des-fc-schattdorf"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Bilder hochladen ─────────────────────────────────────────────
log "1/4  25 Fotos nach ${UPLOAD_SUB}/ hochladen (rsync)…"
rsync -avz --exclude '.DS_Store' \
  --rsync-path="mkdir -p ${WEBROOT}/${UPLOAD_SUB} && rsync" \
  deploy/gruempi-images/ "$HOST:$WEBROOT/$UPLOAD_SUB/" | tail -6

# ── 2. Import-PHP mit Token deployen und auslösen ───────────────────
log "2/4  Import-Skript hochladen und per HTTPS auslösen…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" deploy/fcs-import-gruempi.php.tpl > deploy/fcs-import-gruempi.php
scp -q deploy/fcs-import-gruempi.php "$HOST:$WEBROOT/fcs-import-gruempi.php"
rm -f deploy/fcs-import-gruempi.php

echo "    Antwort des Import-Skripts:"
RESP="$(lcurl -sS --max-time 600 "$LIVE/fcs-import-gruempi.php?token=${TOKEN}")"
echo "$RESP" | sed 's/^/      /'

# ── 3. Aufräumen (falls Selbst-Löschung nicht griff) ────────────────
log "3/4  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/fcs-import-gruempi.php"

# ── 4. Verifikation ─────────────────────────────────────────────────
log "4/4  Verifikation (60 s warten wegen Hostpoint-Seitencache)…"
sleep 60

fail=0
check() { if [ "$2" -eq 0 ]; then echo "    OK   $1"; else echo "    FEHLER  $1"; fail=1; fi }

# Einzelbeitrag erreichbar + Titel vorhanden?
# Durchgehend if/else und enthaelt() statt «cmd; check … $?»: unter set -e
# haette ein nicht findendes grep das Skript abgebrochen statt FEHLER zu
# melden, und «… | grep -q» haette wegen SIGPIPE + pipefail einen Treffer
# als Fehlschlag gewertet.
html="$(lcurl -s "$LIVE/$SLUG/")"
if enthaelt "$html" "Grümpelturnier des FC Schattdorf"
  then check "Einzelbeitrag /$SLUG/ zeigt den Titel" 0
  else check "Einzelbeitrag /$SLUG/ zeigt den Titel" 1; fi

# Beitragsbild (Leadbild) ausgeliefert?
code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/$UPLOAD_SUB/thumbnail.jpg")"
if [ "$code" = "200" ]
  then check "Leadbild thumbnail.jpg erreichbar (HTTP $code)" 0
  else check "Leadbild thumbnail.jpg erreichbar (HTTP $code)" 1; fi

# In der News-Übersicht gelistet?
news="$(lcurl -s "$LIVE/news/")"
if enthaelt "$news" "Dorf- und 66. Grümpelturnier"
  then check "In der News-Übersicht /news/ gelistet" 0
  else check "In der News-Übersicht /news/ gelistet" 1; fi

echo
if [ "$fail" -eq 0 ]; then
	echo "==> Fertig – alle Checks OK. Beitrag ist live."
else
	echo "==> Fertig, ABER einzelne Checks meldeten Fehler."
	echo "    Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
	echo "    curl -s $LIVE/$SLUG/ | grep Grümpelturnier"
fi
