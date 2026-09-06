#!/usr/bin/env bash
# ====================================================================
# Deploy: Vorstandsseite zeigt Vorschaubilder statt Originale
#
# Reine DB-Änderung — kein Theme-Code, keine neuen Dateien. Im Inhalt
# der Seite /verein/vorstand/ stehen bei sieben Personen die von
# WordPress erzeugten Vorschauen («-300x200» bzw. «-200x300»), obwohl
# die Originale mit 2500x1667 bzw. 1280x1920 in derselben Mediathek
# liegen. Die Karten sind 375 px breit, auf Retina also 750 px — die
# Bilder werden bis zu 4,7-fach hochskaliert.
#
# Ablauf:
#   1. Token-geschütztes PHP in den Webroot legen (auf Hostpoint ist
#      MySQL nur aus Web-Prozessen erreichbar), Probelauf fahren
#   2. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   3. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Der Bildausschnitt ändert sich nicht: die Vorlage schneidet über CSS
# auf 4:5 zu (object-fit: cover), und die Vorschauen hatten dasselbe
# Seitenverhältnis wie die Originale.
#
# Unabhängig von den anderen offenen Deploys — fasst weder deren
# Felder noch Dateien an und kann jederzeit laufen.
#
# Vorher einmal ./scripts/pull-prod-db.sh laufen lassen — der Dump in
# backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Idempotent: ein zweiter Lauf meldet «SKIP».
#
# Aufruf:  ./deploy/deploy-vorstand-bilder.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-vorstand-bilder.php"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. DB-Skript hochladen und PROBELAUF ────────────────────────────
log "1/5  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"

lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume das Skript vom Server…"
  ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
  exit 0
fi

# ── 2. DB-Änderung scharf auslösen ──────────────────────────────────
log "2/5  DB-Änderung ausführen…"
lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

# ── 3. Reste entfernen (falls Selbst-Löschung nicht griff) ──────────
log "3/5  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"
echo "    ${PHPNAME} liefert HTTP $code (erwartet 404)"

# ── 4. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "4/5  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 5. Verifikation ─────────────────────────────────────────────────
log "5/5  Seite prüfen…"
ok=1
pruefe() { # $1 Beschreibung  $2 Pfad  $3 Suchmuster  $4 erwartet (>0|0)
  local body n
  body="$(lcurl -sSL --max-time 60 "$LIVE$2")"
  n="$(printf '%s' "$body" | grep -c "$3" || true)"
  if { [ "$4" = ">0" ] && [ "$n" != "0" ]; } || { [ "$4" = "0" ] && [ "$n" = "0" ]; }; then
    printf "    OK   %s (%s: %s)\n" "$1" "$3" "$n"
  else
    printf "    FEHL %s (%s: %s, erwartet %s)\n" "$1" "$3" "$n" "$4"; ok=0
  fi
}

V="/verein/vorstand/"
pruefe "keine 300x200-Vorschau mehr"   "$V" '\-300x200\.jpg'        "0"
pruefe "keine 200x300-Vorschau mehr"   "$V" '\-200x300\.jpg'        "0"
pruefe "Original Ralph Bomatter"       "$V" 'Ralph_Bomatter\.jpg'   ">0"
pruefe "Original Iwan Herger"          "$V" 'Iwan_Herger\.jpg'      ">0"
pruefe "Original Claudia Gisler"       "$V" 'Claudia_Gisler\.jpg'   ">0"
pruefe "Original Reto Planzer"         "$V" 'Reto_Planzer\.jpg'     ">0"
pruefe "Original Patrick Schorno"      "$V" 'Paddi_Schorno\.jpg'    ">0"
pruefe "Original Orlando Gisler"       "$V" 'Orlando_Gisler\.jpg'   ">0"
pruefe "Original René Gnos"            "$V" 'Rene_Gnos\.jpg'        ">0"
pruefe "Silhouette Robin Lindauer"     "$V" 'Silhouette_Male_v2'    ">0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Die sieben Porträts kommen jetzt in voller Auflösung."
  echo "  Ohne Foto bleibt nur Robin Lindauer (Silhouette)."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
