#!/usr/bin/env bash
# ====================================================================
# Deploy: Fotos für Ayman Labib Badr und Giuseppe Accardi
#
# Auf /verein/schiedsrichter/ hatten drei von sieben Schiedsrichtern
# kein Foto. Aus dem Redaktions-Ordner kamen sechs benannte Aufnahmen;
# vier davon sind dieselben Bilder, die schon live liegen (nur
# unrotiert) — neu sind genau diese beiden. Ukaj Alex bleibt vorerst
# ohne Foto.
#
# Die Vorlagen sind unverändert — KEIN Theme-Deploy nötig. Schritt 1
# überträgt die zwei Bilddateien, Schritt 2-3 setzen fcs_pe_bild über
# ein token-geschütztes PHP-Skript im Webroot (auf Hostpoint ist MySQL
# nur aus Web-Prozessen erreichbar).
#
# Die Dateien wurden vor dem Ablegen aus der EXIF-Orientierung 6 heraus
# gedreht und das Tag auf 1 gesetzt — sonst stellt WordPress die
# Vorschaubilder quer. Masse und Dateigroesse entsprechen damit den
# bereits vorhandenen Schiedsrichter-Fotos (480x640).
#
# Idempotent: ein zweiter Lauf meldet «SKIP». Trägt ein Feld schon ein
# anderes Bild, lässt das PHP-Skript es stehen.
#
# Aufruf:  ./deploy/deploy-schiedsrichter-bilder.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
MEDIEN="wp-content/uploads/2026/06"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-schiedsrichter-bilder.php"
SEITE="/verein/schiedsrichter/"
BILDER=(Ayman_Labib_Badr.jpg Giuseppe_Accardi.jpg)

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Bilddateien übertragen ───────────────────────────────────────
log "1/6  Zwei Bilddateien übertragen…"
for bild in "${BILDER[@]}"; do
  [ -f "$MEDIEN/$bild" ] || { printf "\033[1;31m     $bild fehlt lokal — abgebrochen.\033[0m\n"; exit 1; }
done
scp -q "${BILDER[@]/#/$MEDIEN/}" "$HOST:$WEBROOT/$MEDIEN/"
for bild in "${BILDER[@]}"; do
  c="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 30 "$LIVE/$MEDIEN/${bild}")"
  echo "     ${bild}: HTTP $c (erwartet 200)"
  [ "$c" = "200" ] || { printf "\033[1;31m     Übertragung fehlgeschlagen.\033[0m\n"; exit 1; }
done

# ── 2. Skript hochladen und Probelauf ───────────────────────────────
log "2/6  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"
# Bei Abbruch darf das Token-Skript nicht liegen bleiben.
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"' EXIT

lcurl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume das Skript vom Server…"
  exit 0
fi

# ── 3. Scharf auslösen ──────────────────────────────────────────────
log "3/6  DB-Änderung ausführen…"
lcurl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

# ── 4. Reste entfernen (falls Selbst-Löschung nicht griff) ──────────
log "4/6  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
trap - EXIT
code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"
echo "    ${PHPNAME} liefert HTTP $code (erwartet 404)"

# ── 5. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "5/6  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 6. Verifikation ─────────────────────────────────────────────────
log "6/6  Seite prüfen…"
body="$(lcurl -sSL --max-time 60 "$LIVE$SEITE")"
code="$(lcurl -sSL -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE$SEITE")"

zaehl() { printf '%s' "$body" | grep -c "$1" || true; }

ayman="$(zaehl 'Ayman_Labib_Badr.jpg')"
accardi="$(zaehl 'Giuseppe_Accardi.jpg')"
karten="$(zaehl 'fcsr-card__name')"

echo "    HTTP ${code} | Schiedsrichter-Karten: ${karten} (erwartet 7)"
echo "    Ayman Labib Badr: ${ayman}, Giuseppe Accardi: ${accardi} (je erwartet >0)"

echo
if [ "$code" = "200" ] && [ "$karten" = "7" ] \
   && [ "$ayman" != "0" ] && [ "$accardi" != "0" ]; then
  printf "\033[1;32mFertig – sechs von sieben Schiedsrichtern haben jetzt ein Foto.\033[0m\n"
  echo "  Ohne Foto bleibt nur Ukaj Alex – dafür liegt keine Aufnahme vor."
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -sL $LIVE$SEITE | grep -c Ayman_Labib_Badr"
  exit 1
fi
