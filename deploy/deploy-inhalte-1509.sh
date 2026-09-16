#!/usr/bin/env bash
# ====================================================================
# Deploy: Redaktions-Nachträge vom 15.09.2026
#
# Inhalte und Bilddateien (DB-Teil: deploy/fcs-inhalte-1509.php.tpl,
# Texte: deploy/news-import-1509.json):
#
#   A) Drei neue Beiträge (neuester zuerst, so auch im Hero):
#      · «Schattdorf belohnt sich spät» — Spielbericht 1. Mannschaft,
#        FC Schattdorf – FC Gunzwil 2:1 vom 12.09.2026; Bild ist das
#        Mannschaftsfoto FCS_1_Team_Web.jpg, das schon live liegt
#        (Vorschau vom 10.09. und Eschenbach-Bericht).
#      · «Verdient erkämpftes Unentschieden in letzter Sekunde» —
#        Spielbericht Db-Junioren, SC Kriens – FC Schattdorf Db 3:3
#        vom 12.09.2026 (Junioren), Mannschaftsfoto
#      · «Auch im Cup läuft's rund für die A-Junioren» — 5:1-Cupsieg
#        gegen das Team Wiggertal (Junioren), Kabinenfoto
#   B) 1. Mannschaft, Kader: Joel Aschwanden bekommt den Kopfsponsor
#      «Bilger Mattli Bomatter Gisler» mit dem Logo bmbg-color.svg (liegt schon
#      live in 2026/06, dieselbe Datei wie beim Sponsor «BMBG» auf
#      /sponsoren/) und tauscht die Rückennummer mit Noel Herger:
#      Aschwanden neu 21, Herger neu 23 — damit tauschen die beiden
#      auch den Platz im Kader. Die Werte stehen im Seitenfeld «Kader»
#      der Seite — das setzt das DB-Skript. Der Fallback in der Vorlage
#      page-1mannschaft.php ist im Repo ebenfalls nachgezogen und geht
#      mit dem nächsten ./scripts/deploy-theme.sh mit (nicht zwingend
#      für die Anzeige, das Seitenfeld hat Vorrang).
#   C) Schibli-Logo (Kopfsponsor Ben Arnold) sass im weissen Badge
#      links: die PNG hatte rechts 90 px transparenten Rand. Datei ist
#      auf 426×156 beschnitten und wird ersetzt (Original liegt lokal
#      als schibli-elektrotechnik-2026.orig.png, wird nicht deployt).
#
# Ablauf:
#   1. 3 Bilddateien übertragen, jede auf HTTP 200 prüfen
#   2. Token-geschütztes PHP samt Textliste in den Webroot legen,
#      Probelauf fahren
#   3. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   4. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Vorher einmal ./scripts/pull-prod-db.sh laufen lassen — der Dump in
# backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Idempotent: bestehende Beiträge werden am Slug erkannt, gesetzte
# Kader-Zeilen melden «SKIP». Ein zweiter Lauf ändert nichts.
#
# Aufruf:  ./deploy/deploy-inhalte-1509.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-inhalte-1509.php"
JSONNAME="news-import-1509.json"

# Pfad relativ zu wp-content/uploads/ — News-Bilder in den Monatsordner.
BILDER=(
  "2026/09/A_Junioren_09-09-2026.jpg"        # Kabinenfoto A-Junioren (1600x1200)
  "2026/09/Db_12-09-2026.jpg"                # Mannschaftsfoto Db (1600x901)
  "2026/06/schibli-elektrotechnik-2026.png"  # Schibli-Logo ohne rechten Leerrand (ERSETZT)
)
# FCS_1_Team_Web.jpg (1. Mannschaft) und bmbg-color.svg (Logo) liegen bereits live.

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 0. Dateien und Textliste müssen lokal da sein ───────────────────
for b in "${BILDER[@]}"; do
  if [ ! -f "wp-content/uploads/$b" ]; then
    echo "FEHLER: wp-content/uploads/$b fehlt lokal. Abbruch." >&2
    exit 1
  fi
done
if [ ! -f "deploy/${JSONNAME}" ]; then
  echo "FEHLER: deploy/${JSONNAME} fehlt — ohne die Textliste legt das DB-Skript nichts an." >&2
  exit 1
fi

# ── 1. Bilddateien übertragen ───────────────────────────────────────
log "1/5  Bilddateien übertragen und einzeln prüfen…"
for b in "${BILDER[@]}"; do
  scp -q "wp-content/uploads/$b" "$HOST:$WEBROOT/wp-content/uploads/$b"
done
ok=1
for b in "${BILDER[@]}" "2026/09/FCS_1_Team_Web.jpg" "2026/06/bmbg-color.svg"; do
  c="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 30 "$LIVE/wp-content/uploads/$b")"
  if [ "$c" = "200" ]; then
    printf "    OK   %s (HTTP %s)\n" "$b" "$c"
  else
    printf "    FEHL %s (HTTP %s)\n" "$b" "$c"; ok=0
  fi
done
if [ "$ok" != "1" ]; then
  echo "FEHLER: mindestens eine Datei ist live nicht erreichbar. Abbruch vor der DB-Änderung." >&2
  exit 1
fi

# ── 2. DB-Skript und Textliste hochladen, PROBELAUF ─────────────────
log "2/5  DB-Skript samt Textliste hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
scp -q "deploy/${JSONNAME}" "$HOST:$WEBROOT/${JSONNAME}"
rm -f "deploy/${PHPNAME}"
# Bei Abbruch dürfen Token-Skript und Textliste nicht liegen bleiben.
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME} $WEBROOT/${JSONNAME}"' EXIT

lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume Skript und Textliste vom Server…"
  echo "Hinweis: die drei Bilddateien liegen bereits live. Das stört nichts —"
  echo "         die zwei News-Bilder bindet ohne DB-Änderung niemand ein, das"
  echo "         beschnittene Schibli-Logo ist so oder so richtig."
  exit 0
fi

# ── 3. DB-Änderung scharf auslösen ──────────────────────────────────
log "3/5  DB-Änderung ausführen…"
lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

log "Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME} $WEBROOT/${JSONNAME}"
trap - EXIT
for f in "${PHPNAME}" "${JSONNAME}"; do
  printf "    %s liefert HTTP %s (erwartet 404)\n" "$f" \
    "$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${f}")"
done

# ── 4. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "4/5  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 5. Verifikation ─────────────────────────────────────────────────
log "5/5  Seiten prüfen…"
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

echo "  Neue Beiträge"
A="/auch-im-cup-laeufts-rund-fuer-die-a-junioren/"
pruefe "A-Junioren-Cupsieg steht"     "$A" 'Team Wiggertal'                ">0"
pruefe "A-Junioren mit Kabinenfoto"   "$A" 'A_Junioren_09-09-2026'         ">0"
D="/verdient-erkaempftes-unentschieden-in-letzter-sekunde/"
pruefe "Db-Bericht steht"             "$D" 'Last-Second-Ausgleich'         ">0"
pruefe "Db-Bericht mit Mannschaftsfoto" "$D" 'Db_12-09-2026'               ">0"
M="/schattdorf-belohnt-sich-spaet/"
pruefe "Gunzwil-Bericht steht"        "$M" 'Pflichtspieldeb'               ">0"
pruefe "Gunzwil-Bericht mit Mannschaftsfoto" "$M" 'FCS_1_Team_Web'         ">0"
pruefe "alle drei auf der Startseite" "/" 'Auch im Cup l'                  ">0"
pruefe "Gunzwil-Bericht zuoberst im Hero" "/" '"title":"Schattdorf belohnt sich sp' ">0"

echo "  1. Mannschaft – Kader"
M1="/aktive/1-mannschaft/"
pruefe "Logo bmbg-color.svg im Kader" "$M1" 'bmbg-color\.svg'              ">0"
pruefe "Sponsorname auf der Karte"    "$M1" 'Bilger Mattli Bomatter Gisler'       ">0"
# Nummern: die Karte gibt Nr und Name auf getrennten Zeilen aus. Deshalb
# die Seite auf eine Zeile ziehen, an jedem Kartenanfang umbrechen (eine
# Zeile = eine Karte) und das Paar Nr/Name in derselben Zeile suchen.
m1karten="$(lcurl -sSL --max-time 60 "$LIVE$M1" | tr -d '\n' | tr -s ' ' \
  | sed 's/<div class="fc1m-player">/\
/g')"
for paar in "21 Joel Aschwanden" "23 Noel Herger"; do
  nr="${paar%% *}"; name="${paar#* }"
  if printf '%s\n' "$m1karten" | grep -q "__nr\">${nr}</span>.*__name\">${name}<"; then
    printf "    OK   Nr. %s = %s\n" "$nr" "$name"
  else
    printf "    FEHL Nr. %s = %s nicht gefunden\n" "$nr" "$name"; ok=0
  fi
done

echo "  Schibli-Logo (byteweise)"
lcurl -sS --max-time 40 "$LIVE/wp-content/uploads/2026/06/schibli-elektrotechnik-2026.png" -o /tmp/fcs-schibli-pruef.png 2>/dev/null
if [ "$(md5 -q /tmp/fcs-schibli-pruef.png 2>/dev/null)" = "$(md5 -q wp-content/uploads/2026/06/schibli-elektrotechnik-2026.png)" ]; then
  echo "    OK   schibli-elektrotechnik-2026.png identisch mit lokal (426x156)"
else
  echo "    FEHL schibli-elektrotechnik-2026.png weicht live ab (Cache? nach 1–2 min erneut laden)"; ok=0
fi
rm -f /tmp/fcs-schibli-pruef.png

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Der Fallback in page-1mannschaft.php geht mit dem nächsten"
  echo "  ./scripts/deploy-theme.sh mit (steht ohnehin noch aus)."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
