#!/usr/bin/env bash
# ====================================================================
# Deploy: Beitragsbild und Kategorie von «Bittere 2:3 Niederlage gegen
# Hünenberg» auf den Stand der Quelle bringen
#
# Der News-Nachtrag vom 07.09.2026 lief mit einer Fehleinschätzung:
# der Beitrag bekam FCS_1_Team_Web.jpg und Kategorie «1. Mannschaft».
# Die alte Vereinsseite bindet dort FCS_2_Web.jpg ein, das
# Mannschaftsfoto der zweiten Mannschaft — der Import folgt der Quelle,
# also gehört beides zurückgesetzt.
#
# Der News-Import selbst kann das nicht nachziehen: er überspringt
# Beiträge, deren Slug schon existiert. Daher dieses gezielte Skript.
#
# Reine DB-Änderung über ein token-geschütztes PHP-Skript im Webroot —
# auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar. Es werden
# keine Dateien übertragen: FCS_2_Web.jpg liegt seit dem ersten
# Nachtrag live.
#
# Idempotent: steht das Bild schon richtig, meldet das PHP-Skript
# «SKIP». Findet es keinen Bildblock, bricht es ab statt zu raten.
#
# Aufruf:  ./deploy/deploy-news-1577-bild.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-news-1577-bild.php"
SEITE="/bittere-2-3-niederlage-gegen-huenenberg/"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Voraussetzung ────────────────────────────────────────────────
log "1/6  Liegt FCS_2_Web.jpg live?"
code="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 30 "$LIVE/wp-content/uploads/2026/09/FCS_2_Web.jpg")"
echo "     HTTP $code (erwartet 200)"
[ "$code" = "200" ] || { printf "\033[1;31m     Bild fehlt live — abgebrochen.\033[0m\n"; exit 1; }

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
log "6/6  Beitrag prüfen…"
body="$(lcurl -sSL --max-time 60 "$LIVE$SEITE")"
code="$(lcurl -sSL -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE$SEITE")"

zaehl() { printf '%s' "$body" | grep -c "$1" || true; }

neu="$(zaehl 'FCS_2_Web')"
alt="$(zaehl 'FCS_1_Team_Web')"
kat_neu="$(zaehl 'category-2-mannschaft')"
kat_alt="$(zaehl 'category-1-mannschaft')"
text="$(zaehl 'Hünenberg dreht die Partie')"

echo "    HTTP ${code}"
echo "    Bild   – FCS_2_Web: ${neu} (erwartet >0), FCS_1_Team_Web: ${alt} (erwartet 0)"
echo "    Kategorie – 2. Mannschaft: ${kat_neu} (erwartet >0), 1. Mannschaft: ${kat_alt} (erwartet 0)"
echo "    Text unbeschädigt – Zwischentitel: ${text} (erwartet >0)"

echo
if [ "$code" = "200" ] && [ "$neu" != "0" ] && [ "$alt" = "0" ] \
   && [ "$kat_neu" != "0" ] && [ "$kat_alt" = "0" ] && [ "$text" != "0" ]; then
  printf "\033[1;32mFertig – der Beitrag zeigt jetzt das Bild der Quelle.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -sL $LIVE$SEITE | grep -c FCS_2_Web"
  exit 1
fi
