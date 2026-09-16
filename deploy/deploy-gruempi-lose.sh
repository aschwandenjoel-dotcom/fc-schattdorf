#!/usr/bin/env bash
# ====================================================================
# Deploy: Losnummern und Ziehungsprotokoll auf der Grümpelturnier-Seite
# (13.09.2026)
#
# Die alte Joomla-Seite verlinkte unter «Dorf- und Grümpelturnier» das
# PDF «Gezogene Losnummern Grümpelturnier 2026»; auf der neuen Seite
# fehlte es. Dazu kommt das vom Notar beglaubigte Ziehungsprotokoll.
# DB-Teil: deploy/fcs-gruempi-lose.php.tpl (Mediathek-Einträge und
# Seitenfeld «Weitere Downloads»).
#
# GEHÖRT ZUSAMMEN mit ./scripts/deploy-theme.sh — die Vorlage
# page-gruempelturnier.php zeigt das Feld erst nach dem Theme-Deploy.
# Reihenfolge: erst dieses Skript (Dateien + Feld), dann das Theme.
#
# Ablauf:
#   1. 2 PDFs übertragen, jedes auf HTTP 200 prüfen
#   2. Token-geschütztes PHP in den Webroot legen, Probelauf fahren
#   3. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   4. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Idempotent. Aufruf:  ./deploy/deploy-gruempi-lose.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
. scripts/lib-live.sh
PHPNAME="fcs-gruempi-lose.php"

DATEIEN=(
  "2026/06/Losnummern_Gruempi_2026.pdf"
  "2026/06/Ziehungsprotokoll_Gruempi_2026.pdf"
)

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

for b in "${DATEIEN[@]}"; do
  [ -f "wp-content/uploads/$b" ] || { echo "FEHLER: wp-content/uploads/$b fehlt lokal. Abbruch." >&2; exit 1; }
done

log "1/5  PDFs übertragen und prüfen…"
for b in "${DATEIEN[@]}"; do
  scp -q "wp-content/uploads/$b" "$HOST:$WEBROOT/wp-content/uploads/$b"
done
ok=1
for b in "${DATEIEN[@]}"; do
  c="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 30 "$LIVE/wp-content/uploads/$b")"
  if [ "$c" = "200" ]; then printf "    OK   %s\n" "$b"; else printf "    FEHL %s (HTTP %s)\n" "$b" "$c"; ok=0; fi
done
[ "$ok" = "1" ] || { echo "FEHLER: mindestens eine Datei ist live nicht erreichbar. Abbruch." >&2; exit 1; }

log "2/5  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"' EXIT

lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume Skript vom Server…"
  exit 0
fi

log "3/5  DB-Änderung ausführen…"
lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

log "Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
trap - EXIT
printf "    %s liefert HTTP %s (erwartet 404)\n" "${PHPNAME}" \
  "$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"

log "4/5  Warte 60 s (Hostpoint-Seitencache)…"
sleep 60

log "5/5  Seite prüfen (greift erst nach ./scripts/deploy-theme.sh — FEHL ist bis dahin normal)…"
ok=1
for m in 'Losnummern_Gruempi_2026\.pdf' 'Ziehungsprotokoll_Gruempi_2026\.pdf' 'Gezogene Losnummern 2026' 'beglaubigt'; do
  n="$(lcurl -sSL --max-time 60 "$LIVE/gruempelturnier/" | grep -c "$m" || true)"
  if [ "$n" != "0" ]; then printf "    OK   %s\n" "$m"; else printf "    FEHL %s\n" "$m"; ok=0; fi
done
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – Downloads stehen auf der Grümpelturnier-Seite.\033[0m\n"
else
  echo
  echo "  JETZT: ./scripts/deploy-theme.sh — erst damit zeigt die Vorlage die"
  echo "  Download-Karten. Danach dieses Skript nochmals laufen lassen: es"
  echo "  meldet überall SKIP und wiederholt nur die Prüfung."
fi
