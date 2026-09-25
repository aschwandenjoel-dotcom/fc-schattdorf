#!/usr/bin/env bash
# ====================================================================
# Deploy: fünf neue Betreuer-Porträts (25.09.2026)
#
#   A) Team Uri FF14 — Philipp Bissig, Luca Forte und Heinz Gisler
#      trugen bisher eine Silhouette und bekommen ihr Porträt.
#   B) Frauen Team Uri — Dominique Scheiber bekommt ihr neues Porträt
#      (statt Domi_Scheiber.jpg), Fabrice Arnold kommt als Trainer neu
#      auf die Teamseite.
#
# Bilder aus ~/Downloads/transfer-01a0d3c7/, auf 1600 px Höhe gebracht
# und als <Vorname>_<Nachname>_2627.jpg in 2026/06 abgelegt.
#
# Ablauf: Bilder übertragen und auf HTTP 200 prüfen, dann
# token-geschütztes PHP mit Probelauf, Rückfrage, scharf, 60 s warten,
# Seiten prüfen. Kein Theme-Deploy.
#
# Aufruf:  ./deploy/deploy-betreuer-2509.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
. scripts/lib-live.sh
PHPNAME="fcs-betreuer-2509.php"

BILDER=(
  "2026/06/Philipp_Bissig_2627.jpg"
  "2026/06/Luca_Forte_2627.jpg"
  "2026/06/Heinz_Gisler_2627.jpg"
  "2026/06/Dominique_Scheiber_2627.jpg"
  "2026/06/Fabrice_Arnold_2627.jpg"
)

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

for b in "${BILDER[@]}"; do
  [ -f "wp-content/uploads/$b" ] || { echo "FEHLER: wp-content/uploads/$b fehlt lokal. Abbruch." >&2; exit 1; }
done

log "1/5  Bilddateien übertragen und einzeln prüfen…"
for b in "${BILDER[@]}"; do
  scp -q "wp-content/uploads/$b" "$HOST:$WEBROOT/wp-content/uploads/$b"
done
ok=1
for b in "${BILDER[@]}"; do
  c="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 30 "$LIVE/wp-content/uploads/$b")"
  if [ "$c" = "200" ]; then printf "    OK   %s (HTTP %s)\n" "$b" "$c"; else printf "    FEHL %s (HTTP %s)\n" "$b" "$c"; ok=0; fi
done
[ "$ok" = "1" ] || { echo "FEHLER: mindestens eine Datei ist live nicht erreichbar. Abbruch vor der DB-Änderung." >&2; exit 1; }

log "2/5  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"' EXIT

lcurl -sS --max-time 180 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume Skript vom Server…"
  echo "Hinweis: die fünf Bilddateien liegen bereits live; ohne die DB-Änderung bindet sie niemand ein."
  exit 0
fi

log "3/5  DB-Änderung ausführen…"
lcurl -sS --max-time 180 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

log "Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
trap - EXIT
printf "    %s liefert HTTP %s (erwartet 404)\n" "${PHPNAME}" \
  "$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"

log "4/5  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

log "5/5  Seiten prüfen…"
ok=1
pruefe() { # $1 Beschreibung  $2 Pfad  $3 Suchmuster  $4 erwartet (>0|0)
  local body n
  body="$(lcurl -sSL --max-time 60 "$LIVE$2")"
  n="$(grep -c "$3" <<< "$body" || true)"   # kein printf|grep -q (pipefail-Fehlalarm)
  if { [ "$4" = ">0" ] && [ "$n" != "0" ]; } || { [ "$4" = "0" ] && [ "$n" = "0" ]; }; then
    printf "    OK   %s (%s: %s)\n" "$1" "$3" "$n"
  else
    printf "    FEHL %s (%s: %s, erwartet %s)\n" "$1" "$3" "$n" "$4"; ok=0
  fi
}

F="/junioren/teams/team-uri-ff14/"
pruefe "FF14: Bissig"            "$F" 'Philipp_Bissig_2627\.jpg'      ">0"
pruefe "FF14: Forte"             "$F" 'Luca_Forte_2627\.jpg'          ">0"
pruefe "FF14: Heinz Gisler"      "$F" 'Heinz_Gisler_2627\.jpg'        ">0"
pruefe "FF14: keine Silhouette"  "$F" 'Silhouette'                    "0"

W="/aktive/frauen-uri-1/"
pruefe "Frauen: Scheiber neu"    "$W" 'Dominique_Scheiber_2627\.jpg'  ">0"
pruefe "Frauen: altes Bild weg"  "$W" 'Domi_Scheiber\.jpg'            "0"
pruefe "Frauen: Arnold als Trainer" "$W" 'Fabrice_Arnold_2627\.jpg'   ">0"
pruefe "Frauen: Name Arnold"     "$W" 'Fabrice Arnold'                ">0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Zeigt der Browser noch alte Bilder: einmal hart neu laden (Cmd+Shift+R)."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
