#!/usr/bin/env bash
# ====================================================================
# Deploy: Fotos über den beiden Organisatoren des Trainingslagers
#
# Sandro Zamuner und René Gnos standen im Aufruf-Block der Seite
# «Juniorentrainingslager» nur als Name mit Telefonnummer. Neu steht
# über jedem ein Hochformat-Porträt, gleich zugeschnitten wie auf den
# Team- und Betreuerseiten (3:4, von oben beschnitten).
#
# Reine DB-Änderung über ein token-geschütztes PHP-Skript im Webroot —
# auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar. Beide
# Bilder liegen bereits in uploads/2026/06, es werden keine Dateien
# übertragen.
#
# VORAUSSETZUNG: Das Theme muss schon deployed sein (./scripts/deploy-theme.sh).
# Ohne die neue Vorlage wertet die Seite das vierte Feld nicht aus —
# kaputt geht nichts, es passiert nur nichts. Schritt 1 prüft das.
#
# Idempotent: ein zweiter Lauf meldet «SKIP». Zeilen mit unbekanntem
# Namen bleiben unberührt.
#
# Aufruf:  ./deploy/deploy-tl-kontaktbilder.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
THEME="wp-content/themes/fcschattdorf-child"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-tl-kontaktbilder.php"
SEITE="/junioren/trainingslager/"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Voraussetzungen ──────────────────────────────────────────────
log "1/6  Voraussetzungen prüfen…"
if ssh "$HOST" "grep -q 'tl-contact-person__photo' $WEBROOT/$THEME/page-trainingslager.php"; then
  echo "     Vorlage live ist aktuell."
else
  printf "\033[1;31m     Die Vorlage live kennt das Foto-Feld noch nicht.\033[0m\n"
  echo "     Zuerst ausführen:  ./scripts/deploy-theme.sh"
  exit 1
fi
for bild in Sandro_Zamuner.jpg Rene_Gnos_hoch.jpg; do
  c="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 20 "$LIVE/wp-content/uploads/2026/06/${bild}")"
  echo "     ${bild}: HTTP $c (erwartet 200)"
  [ "$c" = "200" ] || { printf "\033[1;31m     Bild fehlt live — abgebrochen.\033[0m\n"; exit 1; }
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

kaesten="$(zaehl 'tl-contact-person__photo')"
zamuner="$(zaehl 'Sandro_Zamuner.jpg')"
gnos="$(zaehl 'Rene_Gnos_hoch.jpg')"

echo "    HTTP ${code}"
echo "    Foto-Kästen: ${kaesten} (erwartet 2)"
echo "    Zamuner: ${zamuner}, Gnos: ${gnos} (je erwartet >0)"

echo
if [ "$code" = "200" ] && [ "$kaesten" = "2" ] \
   && [ "$zamuner" != "0" ] && [ "$gnos" != "0" ]; then
  printf "\033[1;32mFertig – über beiden Organisatoren steht jetzt ein Porträt.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -sL $LIVE$SEITE | grep -c tl-contact-person__photo"
  exit 1
fi
