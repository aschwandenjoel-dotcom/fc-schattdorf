#!/usr/bin/env bash
# ====================================================================
# Deploy: News von der alten Vereinsseite nachtragen
#
# Die Redaktion pflegt die News weiterhin auf www.fcschattdorf.ch. Auf
# der neuen Seite endete der Feed am 30.06.2026. Dieser Deploy trägt
# die 25 seither erschienenen Beiträge nach (Stand 05.09.2026).
#
# Drei Schritte:
#   1. 17 Mediendateien nach wp-content/uploads/2026/09 (16 Bilder und
#      die FCS-Zyttig als PDF). Gezielt Datei für Datei, kein rsync des
#      ganzen Upload-Ordners — dort liegt Redaktions-Material.
#   2. Token-geschütztes PHP samt Datenliste in den Webroot legen und
#      einen Probelauf fahren (auf Hostpoint ist MySQL nur aus
#      Web-Prozessen erreichbar).
#   3. Nach Rückfrage scharf ausführen, Reste entfernen, prüfen.
#
# Unabhängig von den anderen offenen Deploys: fasst weder Theme-Code
# noch deren Felder an und kann jederzeit laufen.
#
# Vorher einmal ./scripts/pull-prod-db.sh laufen lassen — der Dump in
# backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Idempotent: ein Beitrag mit demselben Slug wird übersprungen, ein
# zweiter Lauf meldet überall «SKIP».
#
# Aufruf:  ./deploy/deploy-news-import-0926.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-news-import-0926.php"
JSONNAME="news-import-0926.json"
MEDIEN="wp-content/uploads/2026/09"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Mediendateien übertragen ─────────────────────────────────────
log "1/5  Mediendateien nach ${MEDIEN}/ übertragen…"
[ -d "$MEDIEN" ] || { echo "FEHLER: $MEDIEN fehlt lokal."; exit 1; }
anzahl="$(find "$MEDIEN" -maxdepth 1 -type f | wc -l | tr -d ' ')"
[ "$anzahl" -gt 0 ] || { echo "FEHLER: keine Dateien in $MEDIEN."; exit 1; }
# Der Ordner enthaelt neben den 17 Originalen die von WordPress erzeugten
# Vorschaugroessen. Uebertragen wird alles, geprueft werden die Originale
# aus der Datenliste — die braucht das Importskript.
echo "    $anzahl Dateien (17 Originale plus Vorschaugroessen)"
rsync -avz --exclude '.DS_Store' "$MEDIEN/" "$HOST:$WEBROOT/$MEDIEN/" | tail -6

schlecht=0; geprueft=0
while IFS= read -r name; do
  [ -n "$name" ] || continue
  geprueft=$((geprueft+1))
  code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/$MEDIEN/$name")"
  [ "$code" = "200" ] || { printf '    FEHL %-46s HTTP %s\n' "$name" "$code"; schlecht=$((schlecht+1)); }
done < <(grep -oE '"(bild|pdf)": *"[^"]+"' "deploy/${JSONNAME}" | sed 's/.*: *"//; s/"$//' | sort -u)
[ "$schlecht" = "0" ] || { echo "Abgebrochen – $schlecht Datei(en) live nicht erreichbar."; exit 1; }
echo "    alle $geprueft Originale liefern live HTTP 200"

# ── 2. Skript und Daten hochladen, Probelauf ────────────────────────
log "2/5  Import-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
scp -q "deploy/${JSONNAME}" "$HOST:$WEBROOT/${JSONNAME}"
rm -f "deploy/${PHPNAME}"

lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich 25 Beiträge anlegen? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume Skript und Datenliste vom Server…"
  ssh "$HOST" "rm -f $WEBROOT/${PHPNAME} $WEBROOT/${JSONNAME}"
  echo "HINWEIS: Die Mediendateien sind bereits live. Sie stören nicht und"
  echo "         werden bei einem späteren Lauf wiederverwendet."
  exit 0
fi

# ── 3. Import ausführen ─────────────────────────────────────────────
log "3/5  Beiträge anlegen…"
lcurl -sS --max-time 600 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

# ── 4. Reste entfernen ──────────────────────────────────────────────
log "4/5  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME} $WEBROOT/${JSONNAME}"
for r in "$PHPNAME" "$JSONNAME"; do
  code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/$r")"
  echo "    $r liefert HTTP $code (erwartet 404)"
done

log "     Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 5. Verifikation ─────────────────────────────────────────────────
log "5/5  Seiten prüfen…"
ok=1
pruefe() { # $1 Beschreibung  $2 Pfad  $3 Suchmuster  $4 erwartet (>0|0)
  local body n
  body="$(lcurl -sSL --max-time 60 "$LIVE$2")"
  n="$(printf '%s' "$body" | grep -c "$3" || true)"
  if { [ "$4" = ">0" ] && [ "$n" != "0" ]; } || { [ "$4" = "0" ] && [ "$n" = "0" ]; }; then
    printf "    OK   %s\n" "$1"
  else
    printf "    FEHL %s (%s: %s, erwartet %s)\n" "$1" "$3" "$n" "$4"; ok=0
  fi
}

pruefe "News: neuster Beitrag 04.09."      "/news/" 'Schattdorf holt sich in Eschenbach einen Punkt' ">0"
pruefe "News: Frauen-Auftakt"              "/news/" 'Team Uri Frauen'                                ">0"
pruefe "News: Junioren Da"                 "/news/" 'Gelungener Auftakt der'                         ">0"
pruefe "News: 2. Mannschaft Ibach"         "/news/" 'FC Schattdorf 2 unterliegt dem FC Ibach 2'      ">0"
pruefe "News: Ehrenmitglieder"             "/news/" 'Zwei neue Ehrenmitglieder'                      ">0"
pruefe "News: Bilder aus 2026/09"          "/news/" 'uploads/2026/09/'                               ">0"
pruefe "Startseite: neuste Story im Hero"  "/"      'Team Uri Frauen'                                ">0"

# Reihenfolge: die Beitraege muessen in derselben Folge stehen wie auf
# www.fcschattdorf.ch. Dafuer tragen sie innerhalb eines Tages
# absteigende Uhrzeiten (18:00, 17:59, …). Stichprobe an den ersten drei.
log "     Reihenfolge stichprobenartig prüfen…"
reihenfolge="$(lcurl -sSL --max-time 60 "$LIVE/news/" \
  | grep -oE 'fcx-ncard__title[^>]*>[^<]*' | sed 's/.*>//' | head -3)"
erwartet=$'Team Uri Frauen: 3:2-Heimsieg zum Saisonauftakt\nSchattdorf holt sich in Eschenbach einen Punkt\nBb Jungs mit weisser Weste'
if [ "$reihenfolge" = "$erwartet" ]; then
  printf "    OK   Reihenfolge der ersten drei wie auf der alten Seite\n"
else
  printf "    FEHL Reihenfolge weicht ab. Erhalten:\n%s\n" "$reihenfolge"; ok=0
fi

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – die News der alten Seite sind nachgetragen.\033[0m\n"
  echo "  Der Feed reicht jetzt bis zum 04.09.2026. Neuere Beiträge auf"
  echo "  www.fcschattdorf.ch müssen wieder von Hand oder mit einem"
  echo "  aktualisierten deploy/news-import-*.json nachgezogen werden."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
