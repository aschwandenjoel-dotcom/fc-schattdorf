#!/usr/bin/env bash
# ====================================================================
# Deploy: Redaktions-Nachträge vom 10.09.2026
#
# Reine Inhaltsänderung — kein Theme-Code (DB-Teil:
# deploy/fcs-inhalte-1009.php.tpl, Texte: deploy/news-import-1009.json):
#
#   A) Drei neue Beiträge:
#      · «Charaktertest auf dem Grünen Wald» — Matchvorschau gegen den
#        FC Gunzwil vom 12.09.2026 (1. Mannschaft)
#      · «Team Uri Frauen: Erfolgreiche Englische Woche mit 2 Siegen!»
#        (Frauen)
#      · «Cb-Junioren: Urner Derby erst in der Schlussphase
#        entschieden» (Junioren)
#   B) Neues Teamfoto der Ba-Junioren — Teamseite, Teams-Übersicht und
#      der letzte Ba-Beitrag «Erneute Niederlage für die Ba-Junioren».
#   C) Erstes Teamfoto für Team Uri FF14 (bisher Platzhalter).
#
# Ablauf:
#   1. Fünf Bilddateien übertragen, jede auf HTTP 200 prüfen
#   2. Token-geschütztes PHP samt Textliste in den Webroot legen,
#      Probelauf fahren
#   3. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   4. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Zum Titel des Cb-Berichts: die Quelle überschreibt ihn mit «Urner
# Derby erst in der Schlussphase entschieden» — genau wie den Bericht
# der Ca-Junioren vom 02.09.2026 (derselbe Einsender). Damit in der
# News-Liste nicht zweimal dieselbe Zeile steht, ist «Cb-Junioren: »
# vorangestellt. Der Text der Quelle bleibt unverändert.
#
# Vorher einmal ./scripts/pull-prod-db.sh laufen lassen — der Dump in
# backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Idempotent: bestehende Beiträge werden am Slug erkannt, gesetzte
# Felder melden «SKIP». Ein zweiter Lauf ändert nichts.
#
# Aufruf:  ./deploy/deploy-inhalte-1009.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-inhalte-1009.php"
JSONNAME="news-import-1009.json"

# Pfad relativ zu wp-content/uploads/ — Teamfotos nach 2026/06 (dort
# sucht das Seitenfeld «Teamfoto»), News-Bilder in den Monatsordner.
BILDER=(
  "2026/06/Ba_Junioren_26-27.jpg"           # Teamseite + Teams-Übersicht Ba
  "2026/06/FF14_Team_26-27.jpg"             # Teamseite + Teams-Übersicht FF14
  "2026/09/Ba_Junioren_26-27.jpg"           # Bild im Ba-Beitrag
  "2026/09/Cb_Junioren_25-26.jpg"           # Bild im Cb-Beitrag
  "2026/09/Team_Uri_Frauen_09-09-2026.jpg"  # Bild im Frauen-Beitrag
)
# FCS_1_Team_Web.jpg (Gunzwil-Vorschau) liegt bereits live.

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
for b in "${BILDER[@]}"; do
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
  echo "Hinweis: die fünf Bilddateien liegen bereits live. Das stört nichts —"
  echo "         ohne die DB-Änderung bindet sie nur noch niemand ein."
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
G="/charaktertest-auf-dem-gruenen-wald/"
pruefe "Vorschau Gunzwil steht"      "$G" 'Reaktion vor eigenem Publikum'  ">0"
pruefe "Vorschau mit Mannschaftsbild" "$G" 'FCS_1_Team_Web'                ">0"
F="/team-uri-frauen-erfolgreiche-englische-woche-mit-2-siegen/"
pruefe "Frauen-Bericht steht"        "$F" 'Englische Woche'                ">0"
pruefe "Frauen-Bericht mit Bild"     "$F" 'Team_Uri_Frauen_09-09-2026'     ">0"
C="/cb-junioren-urner-derby-erst-in-der-schlussphase-entschieden/"
pruefe "Cb-Bericht steht"            "$C" 'Derbysieg'                      ">0"
pruefe "Cb-Bericht mit Teamfoto"     "$C" 'Cb_Junioren_25-26'              ">0"
pruefe "alle drei auf der Startseite" "/" 'Charaktertest auf dem Gr'       ">0"

echo "  Ba-Junioren"
B="/erneute-niederlage-fuer-die-ba-junioren/"
pruefe "Beitrag zeigt neues Teamfoto" "$B" 'Ba_Junioren_26-27'             ">0"
pruefe "altes Bild weg (auch og:image)" "$B" 'Ba-GeringQWEB'               "0"
pruefe "Teamseite Ba"   "/junioren/teams/junioren-b-junioren-a/" 'Ba_Junioren_26-27\.jpg' ">0"
pruefe "Übersicht Ba"   "/junioren/teams/"                       'Ba_Junioren_26-27\.jpg' ">0"

echo "  Team Uri FF14"
pruefe "Teamseite FF14" "/junioren/teams/team-uri-ff14/" 'FF14_Team_26-27\.jpg' ">0"
pruefe "Übersicht FF14" "/junioren/teams/"               'FF14_Team_26-27\.jpg' ">0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Die Matchvorschau steht auf dem 10.09., das Spiel gegen Gunzwil"
  echo "  ist am Samstag, 12.09.2026, 18.00 Uhr auf dem Grünen Wald."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
