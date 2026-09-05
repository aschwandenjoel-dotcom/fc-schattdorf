#!/usr/bin/env bash
# ====================================================================
# Deploy: Inhalte für den Domainwechsel nachziehen (UMSTELLUNG.md, A7)
#
# Reine DB-Änderung über ein token-geschütztes PHP-Skript im Webroot
# (MySQL ist auf Hostpoint nur aus Web-Prozessen erreichbar):
#   A) Yoast-Meta-Descriptions für alle Seiten, die noch keine haben
#   B) Yoast-Standardbild für Social Media (Startseiten-Foto)
#   C) Datenschutzerklärung: Hosting, Cookies, E-Mail/Formulare, Links
#      zu Drittanbietern, Stand September 2026
#
# Erst Probelauf, dann Rückfrage, dann Schreiben. Idempotent: ein
# zweiter Lauf meldet «SKIP». Wurde die Datenschutzerklärung inzwischen
# im Admin bearbeitet, bricht Teil C ab statt zu überschreiben.
#
# Unabhängig vom Domainwechsel — von main aus fahren, jederzeit.
# Aufruf:  ./deploy/deploy-a7-inhalte.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-a7-inhalte.php"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Skript hochladen und Probelauf ───────────────────────────────
log "1/5  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
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

# ── 2. Scharf auslösen ──────────────────────────────────────────────
log "2/5  DB-Änderung ausführen…"
lcurl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

# ── 3. Reste entfernen (falls Selbst-Löschung nicht griff) ──────────
log "3/5  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
trap - EXIT
code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"
echo "    ${PHPNAME} liefert HTTP $code (erwartet 404)"

# ── 4. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "4/5  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 5. Verifikation ─────────────────────────────────────────────────
log "5/5  Seiten prüfen…"
fail=0
pruefe() {  # pruefe <pfad> <muster> <beschreibung>
  local body; body="$(lcurl -sS --max-time 60 "$LIVE$1" || true)"
  if enthaelt "$body" "$2"; then echo "    OK     $3"; else echo "    FEHLER $3  ($1)"; fail=1; fi
}
pruefe /verein/vorstand/       '<meta name="description" content="Der Vorstand des FC Schattdorf'  "Description auf /verein/vorstand/"
pruefe /kontakt/               '<meta name="description" content="Kontakt zum FC Schattdorf'       "Description auf /kontakt/"
pruefe /kontakt/               'property="og:image" content="'                                    "Standardbild (og:image) auf /kontakt/"
pruefe /datenschutzerklaerung/ 'Hostpoint AG'                                                     "Datenschutz nennt Hostpoint"
pruefe /datenschutzerklaerung/ 'Stand: September 2026'                                            "Datenschutz Stand September 2026"

echo
if [ "$fail" = "0" ]; then
  printf "\033[1;32mFertig – A7-Inhalte sind live.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -s $LIVE/kontakt/ | grep -o '<meta name=\"description\"[^>]*>'"
  exit 1
fi
