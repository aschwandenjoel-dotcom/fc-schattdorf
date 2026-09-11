#!/usr/bin/env bash
# ====================================================================
# Deploy: Team Uri FF17 komplett, IFV-Teams für alle Juniorenseiten
# (11.09.2026)
#
# Inhalte und Bilddateien (DB-Teil: deploy/fcs-inhalte-1109.php.tpl).
# GEHÖRT ZUSAMMEN mit einem Theme-Deploy — siehe unten:
#
#   A) Team Uri FF17: erstes Teamfoto (2026/06/FF17_Team_26-27.jpg, vom
#      ESC geliefert) und die Porträts von Sam Bürer (neu, im
#      Team-Uri-Dress) und Noreen Häfliger (bisher Silhouette).
#   B) Seitenfeld «IFV-Teams» auf 16 Juniorenseiten (Aa … Fd, FF11):
#      Team-Nummern aus dem IFV-Matchcenter. Daraus baut die neue
#      Vorlage die Kacheln «Tabelle» und «Spielplan» je Team; E-, F-Teams
#      und FF11 nur «Spielplan». FF14 beim FC Altdorf (t=79188), FF17
#      beim ESC Erstfeld (t=78478).
#   C) FF17-Hero: Foto auf 15 % geschoben, damit alle Köpfe sichtbar sind.
#   D) Vorstand: Porträt Claudia Gisler (neue Brille) unter NEUEM
#      Dateinamen Claudia_Gisler_2026.jpg samt allen Vorschaugrössen.
#      Der Tausch vom 09./10.09. lief unter dem alten Namen und blieb
#      in Browser- und Hostpoint-Caches unsichtbar. Alle Grössen werden
#      lokal gerechnet hochgeladen und byteweise geprüft.
#
#   DANACH ./scripts/deploy-theme.sh — erst damit greifen die Nummern
#   (neue Vorlage page-junioren-team.php + inc/fcs-ifv.php). Zugleich
#   bekommen die Aktiv-Teams und die Startseite saisonfeste
#   Spielplan-Links: die alten trugen die Gruppe der Saison 2025/26.
#   Reihenfolge ist Absicht: erst Bilder + Felder, dann die Vorlage.
#   Andersherum wäre nichts kaputt (die neue Vorlage fällt ohne Feld
#   auf die Vereinsseite zurück), aber so sitzt alles mit einem Schlag.
#
# Ablauf:
#   1. 12 Bilddateien übertragen, jede auf HTTP 200 prüfen
#   2. Token-geschütztes PHP in den Webroot legen, Probelauf fahren
#   3. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   4. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Vorher einmal ./scripts/pull-prod-db.sh laufen lassen — der Dump in
# backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Idempotent: gesetzte Felder melden «SKIP». Ein zweiter Lauf ändert nichts.
#
# Aufruf:  ./deploy/deploy-inhalte-1109.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-inhalte-1109.php"

# Pfad relativ zu wp-content/uploads/ — alles nach 2026/06, dort suchen
# die Seitenfelder «Teamfoto» und «Betreuerstab».
BILDER=(
  "2026/06/FF17_Team_26-27.jpg"     # Teamseite + Teams-Übersicht FF17
  "2026/06/Sam_Buerer_2627.jpg"     # Betreuer FF17
  "2026/06/Noreen_Haefliger.jpg"    # Betreuerin FF17
  # Claudia Gisler samt ALLEN Vorschaugroessen (lokal gerechnet) — siehe D)
  "2026/06/Claudia_Gisler_2026.jpg"
  "2026/06/Claudia_Gisler_2026-1024x1536.jpg"
  "2026/06/Claudia_Gisler_2026-150x150.jpg"
  "2026/06/Claudia_Gisler_2026-200x300.jpg"
  "2026/06/Claudia_Gisler_2026-21x32.jpg"
  "2026/06/Claudia_Gisler_2026-300x300.jpg"
  "2026/06/Claudia_Gisler_2026-683x1024.jpg"
  "2026/06/Claudia_Gisler_2026-768x1152.jpg"
  "2026/06/Claudia_Gisler_2026-85x128.jpg"
)

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 0. Dateien müssen lokal da sein ─────────────────────────────────
for b in "${BILDER[@]}"; do
  if [ ! -f "wp-content/uploads/$b" ]; then
    echo "FEHLER: wp-content/uploads/$b fehlt lokal. Abbruch." >&2
    exit 1
  fi
done

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

# ── 2. DB-Skript hochladen, PROBELAUF ───────────────────────────────
log "2/5  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"
# Bei Abbruch darf das Token-Skript nicht liegen bleiben.
trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"' EXIT

lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume Skript vom Server…"
  echo "Hinweis: die drei Bilddateien liegen bereits live. Das stört nichts —"
  echo "         ohne die DB-Änderung bindet sie nur noch niemand ein."
  exit 0
fi

# ── 3. DB-Änderung scharf auslösen ──────────────────────────────────
log "3/5  DB-Änderung ausführen…"
lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

log "Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
trap - EXIT
printf "    %s liefert HTTP %s (erwartet 404)\n" "${PHPNAME}" \
  "$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"

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

echo "  Team Uri FF17"
F="/junioren/teams/team-uri-ff17/"
pruefe "Teamfoto im Hero"        "$F" 'FF17_Team_26-27\.jpg'  ">0"
pruefe "Porträt Sam Bürer"       "$F" 'Sam_Buerer_2627\.jpg'  ">0"
pruefe "Porträt Noreen Häfliger" "$F" 'Noreen_Haefliger\.jpg' ">0"
pruefe "Silhouette weg"          "$F" 'Silhouette_Female'     "0"
pruefe "Übersicht FF17"          "/junioren/teams/" 'FF17_Team_26-27\.jpg' ">0"
pruefe "FF17: alter Rückfall weg" "$F" 'Verein-IFV.aspx/v-329' "0"

echo "  Vorstand — Claudia Gisler (neuer Dateiname, alle Groessen byteweise)"
pruefe "Vorstandsseite: neuer Name"  "/verein/vorstand/" 'Claudia_Gisler_2026\.jpg' ">0"
pruefe "Vorstandsseite: alter Name weg" "/verein/vorstand/" 'Claudia_Gisler\.jpg'  "0"
pruefe "srcset mit neuen Groessen"   "/verein/vorstand/" 'Claudia_Gisler_2026-683x1024\.jpg' ">0"
for cf in wp-content/uploads/2026/06/Claudia_Gisler_2026*.jpg; do
  rel="${cf#wp-content/uploads/}"
  lcurl -sS --max-time 40 "$LIVE/wp-content/uploads/${rel}" -o /tmp/fcs-claudia-pruef.jpg 2>/dev/null
  if [ "$(md5 -q /tmp/fcs-claudia-pruef.jpg 2>/dev/null)" = "$(md5 -q "$cf")" ]; then
    printf "    OK   %s\n" "$(basename "$cf")"
  else
    printf "    FEHL %s (live weicht ab)\n" "$(basename "$cf")"; ok=0
  fi
done
rm -f /tmp/fcs-claudia-pruef.jpg

echo "  IFV-Kacheln (greifen erst nach ./scripts/deploy-theme.sh — FEHL hier ist bis dahin normal)"
theme_ok=1
pr_theme() { # wie pruefe, zählt aber nur für theme_ok
  local body n
  body="$(lcurl -sSL --max-time 60 "$LIVE$2")"
  n="$(printf '%s' "$body" | grep -c "$3" || true)"
  if [ "$n" != "0" ]; then printf "    OK   %s\n" "$1"; else printf "    FEHL %s (%s fehlt)\n" "$1" "$3"; theme_ok=0; fi
}
pr_theme "Da: Tabelle t=30622"        "/junioren/teams/junioren-d-junioren/"    't=30622&#038;a=trr'
pr_theme "Da: Spielplan ls=0"         "/junioren/teams/junioren-d-junioren/"    't=30622&#038;ls=0&#038;sg=0&#038;a=pt'
pr_theme "Ea/Eb: Spielplan je Team"   "/junioren/teams/junioren-e-junioren/"    'Spielplan Eb'
pr_theme "FF11 nur Spielplan"         "/junioren/teams/team-uri-ff11/"          't=76737&#038;ls=0'
pr_theme "FF17: ESC Erstfeld t=78478" "$F"                                      'v=327&#038;oid=7&#038;lng=1&#038;t=78478&#038;a=trr'
pr_theme "FF17: Spielplan"            "$F"                                      'v=327&#038;t=78478&#038;ls=0&#038;sg=0&#038;a=pt'
pr_theme "FF14: FC Altdorf t=79188"   "/junioren/teams/team-uri-ff14/"          'v=326&#038;oid=7&#038;lng=1&#038;t=79188&#038;a=trr'
pr_theme "FF17: Foto auf 15 %"        "$F"                                      'object-position: center 15%'
pr_theme "Ec: Einzelkachel halbbreit" "/junioren/teams/junioren-ec-junioren/"   'fc1m-ifv__grid--einzeln'
pr_theme "1. Mannschaft: Spielplan ohne alte Gruppe" "/aktive/1-mannschaft/"     't=30614&#038;ls=0&#038;sg=0'
pr_theme "Senioren: Spielplan ohne Gruppe 2022/23"  "/aktive/senioren-uri-1/"   't=30616&#038;ls=0&#038;sg=0'

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – FF17-Prüfungen grün.\033[0m\n"
  if [ "$theme_ok" = "1" ]; then
    echo "  Auch die IFV-Kacheln stehen — der Theme-Deploy ist offenbar schon gelaufen."
  else
    echo
    echo "  JETZT: ./scripts/deploy-theme.sh — erst damit erscheinen die"
    echo "  Team-Kacheln (Tabelle/Spielplan je Mannschaft) und die"
    echo "  saisonfesten Links der Aktiven. Danach diesen Block nochmals"
    echo "  prüfen: ./deploy/deploy-inhalte-1109.sh meldet beim zweiten"
    echo "  Lauf überall SKIP und führt die Prüfungen erneut aus."
  fi
else
  printf "\033[1;31mFertig, ABER mindestens eine FF17-Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
