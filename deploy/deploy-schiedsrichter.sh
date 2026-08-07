#!/usr/bin/env bash
# ====================================================================
# Deploy: Schiedsrichter-Seite auf den IFV-Stand vom 08.08.2026
#
# Reine DB-Änderung (kein Theme-Code betroffen) über ein
# token-geschütztes PHP-Skript im Webroot — auf Hostpoint ist MySQL
# nur aus Web-Prozessen erreichbar:
#   A) zwei neue Personen im Bereich «Schiedsrichter»:
#      Lucas Martins Ferreira, Leon Ziegler (beide «SR – Anfänger»)
#   B) Spielleiter-Liste: + Tresch Fabio, + Zamuner Alessandro,
#      − Küttel Thomas, − Zamuner Sandro
#
# Erst Probelauf, dann Rückfrage, dann Schreiben. Idempotent:
# ein zweiter Lauf meldet «SKIP». Wurde die Spielleiter-Liste
# zwischenzeitlich im Admin gepflegt, bricht Teil B ab statt zu
# überschreiben (Hinweis im Ausgabetext).
#
# Aufruf:  ./deploy/deploy-schiedsrichter.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
LIVE="https://fcschattdorf.dynalias.net"
PHPNAME="fcs-schiedsrichter-update.php"
SEITE="/verein/schiedsrichter/"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Skript hochladen und Probelauf ───────────────────────────────
log "1/5  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"

curl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume das Skript vom Server…"
  ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
  exit 0
fi

# ── 2. Scharf auslösen ──────────────────────────────────────────────
log "2/5  DB-Änderung ausführen…"
curl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

# ── 3. Reste entfernen (falls Selbst-Löschung nicht griff) ──────────
log "3/5  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
code="$(curl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"
echo "    ${PHPNAME} liefert HTTP $code (erwartet 404)"

# ── 4. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "4/5  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 5. Verifikation ─────────────────────────────────────────────────
log "5/5  Seite prüfen…"
body="$(curl -sSL --max-time 60 "$LIVE$SEITE")"
code="$(curl -sSL -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE$SEITE")"

zaehl() { printf '%s' "$body" | grep -c "$1" || true; }

lucas="$(zaehl 'Lucas Martins Ferreira')"
leon="$(zaehl 'Leon Ziegler')"
tresch="$(zaehl 'Tresch Fabio')"
zam_neu="$(zaehl 'Zamuner Alessandro')"
zam_alt="$(zaehl 'Zamuner Sandro')"
kuettel="$(zaehl 'Küttel Thomas')"
karten="$(zaehl 'fcsr-card__name')"

echo "    HTTP $code | Schiedsrichter-Karten: $karten (erwartet 7)"
echo "    Neu vorhanden – Lucas: $lucas, Leon: $leon, Tresch Fabio: $tresch, Zamuner Alessandro: $zam_neu (je erwartet >0)"
echo "    Entfernt      – Küttel Thomas: $kuettel, Zamuner Sandro: $zam_alt (je erwartet 0)"

echo
if [ "$code" = "200" ] && [ "$karten" = "7" ] \
   && [ "$lucas" != "0" ] && [ "$leon" != "0" ] \
   && [ "$tresch" != "0" ] && [ "$zam_neu" != "0" ] \
   && [ "$kuettel" = "0" ] && [ "$zam_alt" = "0" ]; then
  printf "\033[1;32mFertig – Schiedsrichter und Spielleiter sind live auf dem IFV-Stand.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -sL $LIVE$SEITE | grep -n 'fcsr-card__name'"
  exit 1
fi
