#!/usr/bin/env bash
# ====================================================================
# Deploy: Ehren-/Freimitglieder- und Sponsorenapéro neu am 10.04.2027
#
# Rückmeldung vom 24.09.2026: der Termin verschiebt sich vom 24. auf
# den 10. April 2027. Nur DB (Feld fcs_ev_datum des fcs_event-Eintrags),
# keine Dateien, kein Theme-Deploy. Ort und Zeit bleiben offen.
#
# Aufruf:  ./deploy/deploy-apero-datum.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
. scripts/lib-live.sh
PHPNAME="fcs-apero-datum.php"

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

log "4/4  Seite /events/ prüfen…"
ok=1
body="$(lcurl -sSL --max-time 60 "$LIVE/events/")"
for muster in "10\. April 2027|>0" "24\. April 2027|0" "Sponsorenap|>0"; do
  m="${muster%%|*}"; erw="${muster#*|}"
  n="$(grep -c "$m" <<< "$body" || true)"   # kein printf|grep -q (pipefail-Fehlalarm)
  if { [ "$erw" = ">0" ] && [ "$n" != "0" ]; } || { [ "$erw" = "0" ] && [ "$n" = "0" ]; }; then
    printf "    OK   %s (%s)\n" "$m" "$n"
  else
    printf "    FEHL %s (%s, erwartet %s)\n" "$m" "$n" "$erw"; ok=0
  fi
done

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – der Apéro steht neu am 10. April 2027.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
