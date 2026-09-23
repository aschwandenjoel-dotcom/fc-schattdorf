#!/usr/bin/env bash
# ====================================================================
# Deploy: P-Nummer bei René Gnos auf /verein/vorstand/ entfernen
#
# Nur DB, keine Dateien, kein Theme-Deploy. Der Kontaktblock steht im
# Seiteninhalt der Vorstandsseite (Gutenberg), nicht in einem
# Seitenfeld. Das PHP prüft den erwarteten Alt-Wert und bricht ab,
# wenn die Redaktion dort inzwischen etwas geändert hat.
#
# Aufruf:  ./deploy/deploy-vorstand-p-nummer.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
. scripts/lib-live.sh
PHPNAME="fcs-vorstand-p-nummer.php"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

log "1/4  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"' EXIT

lcurl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume Skript vom Server…"; exit 0
fi

log "2/4  DB-Änderung ausführen…"
lcurl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

log "Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
trap - EXIT
printf "    %s liefert HTTP %s (erwartet 404)\n" "${PHPNAME}" \
  "$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"

log "3/4  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

log "4/4  Seite prüfen…"
ok=1
body="$(lcurl -sSL --max-time 60 "$LIVE/verein/vorstand/")"
for muster in "P: 041 870 19 15|0" "M: 079 420 61 20|>0" "Ren.* Gnos|>0" "Sportchef|>0"; do
  m="${muster%%|*}"; erw="${muster#*|}"
  n="$(grep -c "$m" <<< "$body" || true)"
  if { [ "$erw" = ">0" ] && [ "$n" != "0" ]; } || { [ "$erw" = "0" ] && [ "$n" = "0" ]; }; then
    printf "    OK   %s (%s)\n" "$m" "$n"
  else
    printf "    FEHL %s (%s, erwartet %s)\n" "$m" "$n" "$erw"; ok=0
  fi
done

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – P-Nummer ist weg, Mobilnummer steht.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
