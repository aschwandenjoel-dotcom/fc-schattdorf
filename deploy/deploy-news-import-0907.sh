#!/usr/bin/env bash
# ====================================================================
# Deploy: drei weitere News von der alten Vereinsseite nachtragen
#
# Der Nachtrag vom 05.09.2026 endete bei Beitrag 1573 (04.09.). Seither
# sind auf www.fcschattdorf.ch drei weitere erschienen (Stand
# 07.09.2026):
#
#   1577  Bittere 2:3 Niederlage gegen Hünenberg      1. Mannschaft
#   1576  Erneute Niederlage für die Ba-Junioren      Junioren
#   1575  Den SC Engelberg gleich zweimal bezwungen   Junioren
#
# Zwei der drei Bilder liegen schon live (aus dem ersten Nachtrag), neu
# ist nur Ba-GeringQWEB.jpg — gezielt eine Datei, kein rsync des ganzen
# Upload-Ordners, dort liegt Redaktions-Material.
#
# Zu 1577: die alte Seite hängt dort das Mannschaftsfoto der ZWEITEN
# Mannschaft an, der Text ist aber ein Bericht der ersten. Jeder echte
# Bericht der zweiten nennt «Schattdorf 2» im Fliesstext (dreimal),
# dieser kein einziges Mal, und die genannten Torschützen stehen im
# Kader der ersten. Der Beitrag bekommt deshalb Kategorie
# «1. Mannschaft» und FCS_1_Team_Web.jpg wie die übrigen Berichte der
# ersten Mannschaft. Wer das anders sieht: in
# deploy/news-import-0907.json Kategorie und Bild ändern, dann dieses
# Skript laufen lassen.
#
# Unabhängig von den anderen offenen Deploys: fasst weder Theme-Code
# noch deren Felder an und kann jederzeit laufen.
#
# Idempotent: ein Beitrag mit demselben Slug wird übersprungen, ein
# zweiter Lauf meldet überall «SKIP».
#
# Aufruf:  ./deploy/deploy-news-import-0907.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-news-import-0907.php"
JSONNAME="news-import-0907.json"
MEDIEN="wp-content/uploads/2026/09"
NEU="Ba-GeringQWEB.jpg"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Bilder ───────────────────────────────────────────────────────
log "1/6  Bilder prüfen und das neue übertragen…"
[ -f "$MEDIEN/$NEU" ] || { echo "FEHLER: $MEDIEN/$NEU fehlt lokal."; exit 1; }
scp -q "$MEDIEN/$NEU" "$HOST:$WEBROOT/$MEDIEN/$NEU"

schlecht=0
while IFS= read -r name; do
  [ -n "$name" ] || continue
  code="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 30 "$LIVE/$MEDIEN/${name}")"
  printf '     %-26s HTTP %s\n' "$name" "$code"
  [ "$code" = "200" ] || schlecht=$((schlecht+1))
done < <(grep -oE '"bild": *"[^"]+"' "deploy/${JSONNAME}" | sed 's/.*: *"//; s/"$//' | sort -u)
[ "$schlecht" = "0" ] || { echo "Abgebrochen – $schlecht Datei(en) live nicht erreichbar."; exit 1; }

# ── 2. Skript und Daten hochladen, Probelauf ────────────────────────
log "2/6  Import-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
scp -q "deploy/${JSONNAME}" "$HOST:$WEBROOT/${JSONNAME}"
rm -f "deploy/${PHPNAME}"
# Bei Abbruch duerfen Skript und Datenliste nicht liegen bleiben.
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME} $WEBROOT/${JSONNAME}"' EXIT

lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich 3 Beiträge anlegen? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume Skript und Datenliste vom Server…"
  exit 0
fi

# ── 3. Scharf auslösen ──────────────────────────────────────────────
log "3/6  Beiträge anlegen…"
lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

# ── 4. Reste entfernen (falls Selbst-Löschung nicht griff) ──────────
log "4/6  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME} $WEBROOT/${JSONNAME}"
trap - EXIT
for r in "${PHPNAME}" "${JSONNAME}"; do
  code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${r}")"
  echo "    ${r} liefert HTTP $code (erwartet 404)"
done

# ── 5. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "5/6  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 6. Verifikation ─────────────────────────────────────────────────
log "6/6  Seite prüfen…"
ok=1
body="$(lcurl -sSL --max-time 60 "$LIVE/news/")"
code="$(lcurl -sSL -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE/news/")"
echo "    /news/ HTTP ${code}"
[ "$code" = "200" ] || ok=0

# Titel: die vollen Titel prüfen, nicht Bruchstücke — «Team Uri Frauen»
# stand beim letzten Mal auch im Fliesstext eines älteren Beitrags und
# meldete den Import faelschlich als erledigt.
while IFS= read -r titel; do
  [ -n "$titel" ] || continue
  n="$(printf '%s' "$body" | grep -c "$titel" || true)"
  if [ "$n" != "0" ]; then
    printf '    OK   %s\n' "$titel"
  else
    printf '    FEHL %s (nicht auf /news/)\n' "$titel"; ok=0
  fi
done < <(python3 -c "
import json,io
for e in json.load(io.open('deploy/${JSONNAME}',encoding='utf-8')): print(e['titel'])
")

# Reihenfolge: die drei müssen zuoberst stehen und in dieser Folge
reihenfolge="$(printf '%s' "$body" | grep -oE 'fcx-ncard__title[^>]*>[^<]*' | sed 's/.*>//' | head -3)"
erwartet="$(python3 -c "
import json,io
for e in json.load(io.open('deploy/${JSONNAME}',encoding='utf-8')): print(e['titel'])
")"
if [ "$reihenfolge" = "$erwartet" ]; then
  printf '    OK   Reihenfolge der ersten drei wie auf der alten Seite\n'
else
  printf '    FEHL Reihenfolge weicht ab. Erhalten:\n%s\n' "$reihenfolge"; ok=0
fi

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – die drei neuen Beiträge sind nachgetragen.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -sL $LIVE/news/ | grep -o 'fcx-ncard__title[^>]*>[^<]*' | head -3"
  exit 1
fi
