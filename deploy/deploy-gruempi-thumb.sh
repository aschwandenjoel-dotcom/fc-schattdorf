#!/usr/bin/env bash
# ====================================================================
# Einmal-Deploy: Beitragsbild («Titelbild») des News-Beitrags
#   «33. Dorf- und 66. Grümpelturnier» auf das Original-Header-Bild
#   umstellen -> Hostpoint (Produktion). GEZIELT, nur dieser Beitrag.
#
# Ablauf:
#   1. Header-Bild per rsync nach wp-content/uploads/2026/07/ hochladen
#   2. Token-geschütztes PHP in den Webroot legen (MySQL ist auf Host-
#      point nur aus Web-Prozessen erreichbar), per HTTPS auslösen
#      -> legt den Anhang an und setzt ihn als Beitragsbild. Rührt die
#      übrige DB NICHT an. Skript löscht sich selbst.
#   3. Reste entfernen und nach 60 s verifizieren (Hostpoint-Seitencache).
#
# Idempotent: Ist das Bild schon Beitragsbild, meldet das PHP «SKIP».
# Aufruf:  ./deploy/deploy-gruempi-thumb.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
UPLOAD_SUB="wp-content/uploads/2026/07"
FILE="gruempelturnier-hero.jpg"
SLUG="33-dorf-und-66-gruempelturnier-des-fc-schattdorf"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Bild hochladen ───────────────────────────────────────────────
log "1/4  Header-Bild nach ${UPLOAD_SUB}/ hochladen (rsync)…"
rsync -avz --exclude '.DS_Store' \
  --rsync-path="mkdir -p ${WEBROOT}/${UPLOAD_SUB} && rsync" \
  "deploy/gruempi-thumb/${FILE}" "$HOST:$WEBROOT/$UPLOAD_SUB/${FILE}"

# ── 2. PHP mit Token deployen und auslösen ──────────────────────────
log "2/4  Skript hochladen und per HTTPS auslösen…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" deploy/fcs-set-gruempi-thumb.php.tpl > deploy/fcs-set-gruempi-thumb.php
scp -q deploy/fcs-set-gruempi-thumb.php "$HOST:$WEBROOT/fcs-set-gruempi-thumb.php"
rm -f deploy/fcs-set-gruempi-thumb.php

echo "    Antwort des Skripts:"
RESP="$(lcurl -sS --max-time 600 "$LIVE/fcs-set-gruempi-thumb.php?token=${TOKEN}")"
echo "$RESP" | sed 's/^/      /'

# ── 3. Aufräumen (falls Selbst-Löschung nicht griff) ────────────────
log "3/4  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/fcs-set-gruempi-thumb.php"

# ── 4. Verifikation ─────────────────────────────────────────────────
log "4/4  Verifikation (60 s warten wegen Hostpoint-Seitencache)…"
sleep 60

fail=0
check() { if [ "$2" -eq 0 ]; then echo "    OK   $1"; else echo "    FEHLER  $1"; fail=1; fi }

# Neues Bild ausgeliefert?
# Durchgehend if/else und enthaelt() statt «cmd; check … $?» — siehe
# scripts/lib-live.sh: unter set -e brach ein nicht findendes grep das
# Skript ab, und «… | grep -q» wertete wegen SIGPIPE + pipefail einen
# Treffer als Fehlschlag.
code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/$UPLOAD_SUB/$FILE")"
if [ "$code" = "200" ]
  then check "Header-Bild $FILE erreichbar (HTTP $code)" 0
  else check "Header-Bild $FILE erreichbar (HTTP $code)" 1; fi

# Beitragsbild in der News-Übersicht (Card-<img>) = neues Bild?
# page-news.php gibt get_the_post_thumbnail_url(..., 'full') als <img src> aus.
news="$(lcurl -s "$LIVE/news/")"
if enthaelt "$news" "$FILE"
  then check "News-Übersicht /news/ zeigt Card-Bild $FILE" 0
  else check "News-Übersicht /news/ zeigt Card-Bild $FILE" 1; fi

echo
if [ "$fail" -eq 0 ]; then
	echo "==> Fertig – alle Checks OK. Titelbild ist umgestellt."
else
	echo "==> Fertig, ABER einzelne Checks meldeten Fehler."
	echo "    Hinweis: Hostpoint-Seitencache/CDN kann nachhängen – nach 1–2 min erneut prüfen:"
	echo "    curl -s $LIVE/$SLUG/ | grep -i og:image"
fi
