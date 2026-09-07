#!/usr/bin/env bash
# ====================================================================
# Deploy: Jahrgänge auf «Mitglied werden» rechnen sich selbst
#
# Auf der Seite standen die Jahrgänge zweimal fest im Text — im Titel
# («Juniorenbereich · Jahrgang 2012–2006») und im Fliesstext. Neu:
#   - die Jahrgänge stehen nur noch im Text, nicht mehr im Titel
#   - dort als Platzhalter, die inc/fcs-jahrgaenge.php bei jedem
#     Seitenaufruf aus dem Saisonjahr rechnet
#
# Der Wechsel passiert im August (Saisonwechsel), nicht am 1. Januar:
#   Saison 2026/27 -> Junioren 2012 bis 2006, Kinder 2018 bis 2013
#   Saison 2027/28 -> Junioren 2013 bis 2007, Kinder 2019 bis 2014
#
# Reine DB-Änderung über ein token-geschütztes PHP-Skript im Webroot —
# auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar.
#
# VORAUSSETZUNG: Das Theme muss schon deployed sein (./scripts/deploy-theme.sh),
# sonst stünden die rohen %%…%% auf der Seite. Schritt 1 prüft das und
# bricht ab, wenn das Modul live fehlt.
#
# Idempotent: ein zweiter Lauf meldet «SKIP». Wurde das Feld
# zwischenzeitlich im Admin gepflegt, bricht das PHP-Skript ab statt
# zu überschreiben.
#
# Aufruf:  ./deploy/deploy-jahrgaenge.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
THEME="wp-content/themes/fcschattdorf-child"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-jahrgaenge.php"
SEITE="/verein/mitglied-werden/"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Liegt das Theme-Modul schon live? ────────────────────────────
log "1/6  Voraussetzung prüfen: liegt inc/fcs-jahrgaenge.php live?"
if ssh "$HOST" "test -f $WEBROOT/$THEME/inc/fcs-jahrgaenge.php"; then
  echo "     ja – das Modul ist da."
else
  printf "\033[1;31m     FEHLT.\033[0m Das Theme ist noch nicht deployed.\n"
  echo "     Ohne das Modul stünden die rohen %%fcs_jahrgaenge_…%% auf der Seite."
  echo "     Zuerst ausführen:  ./scripts/deploy-theme.sh"
  exit 1
fi

# ── 2. Skript hochladen und Probelauf ───────────────────────────────
log "2/6  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"

lcurl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume das Skript vom Server…"
  ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
  exit 0
fi

# ── 3. Scharf auslösen ──────────────────────────────────────────────
log "3/6  DB-Änderung ausführen…"
lcurl -sS --max-time 120 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

# ── 4. Reste entfernen (falls Selbst-Löschung nicht griff) ──────────
log "4/6  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
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

# Die Jahrgänge der laufenden Saison hier genauso rechnen wie das Theme:
# ab August zählt das laufende Jahr, davor noch das Vorjahr.
jahr="$(date +%Y)"; monat="$(date +%-m)"
saison=$(( monat >= 8 ? jahr : jahr - 1 ))
jun="$(( saison - 14 )) bis $(( saison - 20 ))"
kin="$(( saison - 8 )) bis $(( saison - 13 ))"
echo "    Saison ${saison}/$(( (saison + 1) % 100 )) – erwartet: Junioren «${jun}», Kinder «${kin}»"

t_jun_titel="$(zaehl 'fcmb-track__title">Juniorenbereich<')"
t_kin_titel="$(zaehl 'fcmb-track__title">Kinderfussball<')"
t_jun_text="$(zaehl "Jahrgang $jun)")"
t_kin_text="$(zaehl "Jahrgang $kin)")"
t_titel_jahr="$(zaehl 'fcmb-track__title">[^<]*Jahrgang')"
t_roh="$(zaehl '%%fcs_')"

echo "    HTTP $code"
echo "    Titel ohne Jahrgang  – Juniorenbereich: $t_jun_titel, Kinderfussball: $t_kin_titel (je erwartet 1)"
echo "    Jahrgang im Text     – Junioren: $t_jun_text, Kinder: $t_kin_text (je erwartet >0)"
echo "    Jahrgang noch im Titel: $t_titel_jahr (erwartet 0)"
echo "    Rohe Platzhalter:       $t_roh (erwartet 0)"

echo
if [ "$code" = "200" ] \
   && [ "$t_jun_titel" = "1" ] && [ "$t_kin_titel" = "1" ] \
   && [ "$t_jun_text" != "0" ] && [ "$t_kin_text" != "0" ] \
   && [ "$t_titel_jahr" = "0" ] && [ "$t_roh" = "0" ]; then
  printf "\033[1;32mFertig – die Jahrgänge stehen nur noch im Text und rechnen sich ab jetzt selbst.\033[0m\n"
  echo "  Im August $(( saison + 1 )) springt die Seite von allein auf"
  echo "  Junioren «$(( saison - 13 )) bis $(( saison - 19 ))» und Kinder «$(( saison - 7 )) bis $(( saison - 12 ))» — ohne Deploy."
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -sL $LIVE$SEITE | grep -o 'fcmb-track__title\">[^<]*'"
  exit 1
fi
