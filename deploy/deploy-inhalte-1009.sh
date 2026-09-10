#!/usr/bin/env bash
# ====================================================================
# Deploy: Redaktions-Nachträge vom 10.09.2026
#
# Inhalte und Bilddateien (DB-Teil: deploy/fcs-inhalte-1009.php.tpl,
# Texte: deploy/news-import-1009.json). Ein Punkt braucht zusätzlich
# einen Theme-Deploy — siehe D):
#
#   A) Drei neue Beiträge:
#      · «Charaktertest auf dem Grünen Wald» — Matchvorschau gegen den
#        FC Gunzwil vom 12.09.2026 (1. Mannschaft)
#      · «Erfolgreiche Englische Woche mit 2 Siegen!» (Frauen) — im
#        Artikel das Jubelbild, als Beitragsbild (Hero der Startseite
#        und News-Kacheln) das Mannschaftsfoto im Querformat
#      · «Urner Derby erst in der Schlussphase entschieden» (Junioren)
#   B) Neues Teamfoto der Ba-Junioren — Teamseite, Teams-Übersicht und
#      der letzte Ba-Beitrag «Erneute Niederlage für die Ba-Junioren».
#   C) Erstes Teamfoto für Team Uri FF14 (bisher Platzhalter).
#   E) Alle Teamfotos sitzen jetzt senkrecht mittig. Bisher stand die
#      Mannschaft auf mehreren Fotos zu tief im Bild; der Hero zeigte
#      dann viel Himmel und schnitt unten ab. Die Fotos sind oben
#      beschnitten, bis die Mannschaftsmitte auf 50 % liegt, und das
#      CSS steht neu auf `object-position: center` (Theme-Deploy).
#      Deshalb geht auch FCS3_Web2627.jpg nochmals mit — an der
#      3. Mannschaft ändert sich sonst nichts, das Foto ist nur neu
#      beschnitten und braucht dafür keine CSS-Ausnahme mehr.
#
#   F) Nachtrag zum Deploy vom 09.09.: das neue Portraet von Claudia
#      Gisler liegt live zwar als Volldatei richtig, VIER der acht
#      Vorschaugroessen (-1024x1536, -300x300, -200x300, -150x150)
#      zeigten aber weiter das alte Foto. Das DB-Skript von damals liess
#      sie ueber wp_generate_attachment_metadata() auf dem Server neu
#      rechnen — bei diesen vier hat das nicht gegriffen. Weil die
#      Vorstandsseite ein srcset ausspielt, bekam ein Teil der Besucher
#      je nach Bildschirmbreite das alte Bild.
#      Konsequenz: die Vorschaudateien werden nicht mehr auf dem Server
#      gerechnet, sondern hier fertig hochgeladen und danach per
#      Pruefsumme gegen die lokalen verglichen.
#
#   D) Neues Mannschaftsfoto der Frauen auf /aktive/frauen-uri-1/ —
#      die Datei kommt hier mit, der Dateiname steht aber in der
#      Vorlage page-frauen-uri-1.php. Deshalb GEHÖRT DAZU:
#      danach einmal `./scripts/deploy-theme.sh`.
#      Reihenfolge bewusst so: erst die Datei (dieses Skript), dann die
#      Vorlage. Andersherum zeigte die Seite kurzzeitig ein leeres Bild
#      — genau der Fehler vom 09.09. mit muoser-weiss.png.
#
# Ablauf:
#   1. 17 Bilddateien übertragen, jede auf HTTP 200 prüfen
#   2. Token-geschütztes PHP samt Textliste in den Webroot legen,
#      Probelauf fahren
#   3. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   4. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Zum Titel des Cb-Berichts: er lautet wie in der Quelle, also genau
# gleich wie der Bericht der Ca-Junioren vom 02.09.2026 (derselbe
# Einsender). Nur der Slug bekommt die Endung «-cb», weil der Ca-Bericht
# den naheliegenden schon belegt — sonst haengte WordPress ein
# nichtssagendes «-2» an.
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
  "2026/09/Team_Uri_Frauen_09-09-2026.jpg"  # Jubelbild im Frauen-Beitrag
  "2026/09/Team_Uri_Frauen_Team_26-27.jpg"  # Beitragsbild Frauen (Hero/Kachel)
  "2026/06/FrauenUri1_Web2627.jpg"          # Hero /aktive/frauen-uri-1/
  "2026/06/FCS3_Web2627.jpg"                # nur neu beschnitten, siehe unten
  # Portraet Claudia Gisler samt ALLEN Vorschaugroessen — siehe F)
  "2026/06/Claudia_Gisler.jpg"
  "2026/06/Claudia_Gisler-1024x1536.jpg"
  "2026/06/Claudia_Gisler-768x1152.jpg"
  "2026/06/Claudia_Gisler-683x1024.jpg"
  "2026/06/Claudia_Gisler-300x300.jpg"
  "2026/06/Claudia_Gisler-200x300.jpg"
  "2026/06/Claudia_Gisler-150x150.jpg"
  "2026/06/Claudia_Gisler-85x128.jpg"
  "2026/06/Claudia_Gisler-21x32.jpg"
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
  echo "Hinweis: die acht Bilddateien liegen bereits live. Das stört nichts —"
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
F="/erfolgreiche-englische-woche-mit-2-siegen/"
pruefe "Frauen-Bericht steht"        "$F" 'Englische Woche'                ">0"
pruefe "Titel ohne «Team Uri Frauen:»" "$F" '<title>Team Uri Frauen:'      "0"
pruefe "Jubelbild im Artikel"        "$F" 'Team_Uri_Frauen_09-09-2026'     ">0"
pruefe "Mannschaftsfoto als og:image" "$F" 'og:image[^>]*Team_Uri_Frauen_Team_26-27' ">0"
C="/urner-derby-erst-in-der-schlussphase-entschieden-cb/"
pruefe "Cb-Bericht steht"            "$C" 'Derbysieg'                      ">0"
pruefe "Cb-Bericht mit Teamfoto"     "$C" 'Cb_Junioren_25-26'              ">0"
pruefe "alle drei auf der Startseite" "/" 'Charaktertest auf dem Gr'       ">0"

echo "  Ba-Junioren"
B="/erneute-niederlage-fuer-die-ba-junioren/"
pruefe "Beitrag zeigt neues Teamfoto" "$B" 'Ba_Junioren_26-27'             ">0"
pruefe "altes Bild weg (auch og:image)" "$B" 'Ba-GeringQWEB'               "0"
pruefe "Teamseite Ba"   "/junioren/teams/junioren-b-junioren-a/" 'Ba_Junioren_26-27\.jpg' ">0"
pruefe "Übersicht Ba"   "/junioren/teams/"                       'Ba_Junioren_26-27\.jpg' ">0"

echo "  Portraet Claudia Gisler (alle Groessen byteweise)"
for cf in wp-content/uploads/2026/06/Claudia_Gisler*.jpg; do
  case "$cf" in *.bak*) continue;; esac
  rel="${cf#wp-content/uploads/}"
  lcurl -sS --max-time 40 "$LIVE/wp-content/uploads/${rel}" -o /tmp/fcs-claudia-pruef.jpg 2>/dev/null
  if [ "$(md5 -q /tmp/fcs-claudia-pruef.jpg 2>/dev/null)" = "$(md5 -q "$cf")" ]; then
    printf "    OK   %s\n" "$(basename "$cf")"
  else
    printf "    FEHL %s (live weicht ab)\n" "$(basename "$cf")"; ok=0
  fi
done
rm -f /tmp/fcs-claudia-pruef.jpg

echo "  Frauen (Aktive)"
pruefe "neues Mannschaftsfoto" "/aktive/frauen-uri-1/" 'FrauenUri1_Web2627\.jpg' ">0"
pruefe "altes Foto weg"        "/aktive/frauen-uri-1/" 'FrauenUri1_Web2526\.jpg' "0"

echo "  Team Uri FF14"
pruefe "Teamseite FF14" "/junioren/teams/team-uri-ff14/" 'FF14_Team_26-27\.jpg' ">0"
pruefe "Übersicht FF14" "/junioren/teams/"               'FF14_Team_26-27\.jpg' ">0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Die Matchvorschau steht auf dem 10.09., das Spiel gegen Gunzwil"
  echo "  ist am Samstag, 12.09.2026, 18.00 Uhr auf dem Grünen Wald."
  echo
  echo "  NOCH OFFEN: ./scripts/deploy-theme.sh — erst damit zeigt"
  echo "  /aktive/frauen-uri-1/ das neue Mannschaftsfoto (Dateiname"
  echo "  steht in der Vorlage) und greift object-position: center für"
  echo "  alle Team-Heros. Die beiden Frauen-Prüfungen oben schlagen"
  echo "  bis dahin fehl."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
