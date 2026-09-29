#!/usr/bin/env bash
# ====================================================================
# Deploy: Junioren-Organisation, Kommunikation & Social Media
#
# Rückmeldung vom 29.09.2026: Dominique Scheiber macht das Ämtli nicht
# mehr, ihre Funktion wird geteilt.
#
#   A) Dominique Scheiber -> Papierkorb (nur Junioren-Organisation;
#      auf der Frauen-Teamseite bleibt sie)
#   B) Joel Aschwanden neu, «Kommunikation», an ihrer Stelle
#   C) Marvin Burch neu, «Social Media», vor May Van der Ven
#
# Nur DB, keine Dateien (beide Porträts liegen schon in 2026/06),
# kein Theme-Deploy.
#
# Aufruf:  ./deploy/deploy-junioren-orga.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
. scripts/lib-live.sh
PHPNAME="fcs-junioren-orga.php"
SEITE="/junioren/junioren-organisation/"

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

log "4/4  Seiten prüfen…"
ok=1
pruefe() { # $1 Beschreibung  $2 Pfad  $3 Muster  $4 erwartet
  local body n
  body="$(lcurl -sSL --max-time 60 "$LIVE$2")"
  n="$(grep -c "$3" <<< "$body" || true)"   # kein printf|grep -q (pipefail-Fehlalarm)
  if { [ "$4" = ">0" ] && [ "$n" != "0" ]; } || { [ "$4" = "0" ] && [ "$n" = "0" ]; }; then
    printf "    OK   %s (%s: %s)\n" "$1" "$3" "$n"
  else
    printf "    FEHL %s (%s: %s, erwartet %s)\n" "$1" "$3" "$n" "$4"; ok=0
  fi
}

echo "  Junioren-Organisation"
pruefe "Dominique Scheiber weg"   "$SEITE" 'Dominique Scheiber'            "0"
pruefe "alte Doppelrolle weg"     "$SEITE" 'Kommunikation &amp; Social Media' "0"
pruefe "Joel Aschwanden steht"    "$SEITE" 'Joel Aschwanden'               ">0"
pruefe "Rolle Kommunikation"      "$SEITE" '>Kommunikation<'               ">0"
pruefe "Funktionsadresse"         "$SEITE" 'kommunikation@fcschattdorf\.ch' ">0"
pruefe "Marvin Burch steht"       "$SEITE" 'Marvin Burch'                  ">0"
pruefe "Aline Kempf noch da"      "$SEITE" 'Aline Kempf'                   ">0"
pruefe "Linus Epp noch da"        "$SEITE" 'Linus Epp'                     ">0"

echo "  Frauen-Teamseite (Scheiber muss dort bleiben)"
pruefe "Scheiber bei den Frauen"  "/aktive/frauen-uri-1/" 'Dominique Scheiber'                  ">0"
pruefe "ihre Rolle dort"          "/aktive/frauen-uri-1/" 'Verantwortliche Frauenfussball Uri'  ">0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – Kommunikation bei Joel Aschwanden, Social Media bei Marvin Burch.\033[0m\n"
  echo "  Dominique Scheiber liegt im Papierkorb und liesse sich im Admin wiederherstellen."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
