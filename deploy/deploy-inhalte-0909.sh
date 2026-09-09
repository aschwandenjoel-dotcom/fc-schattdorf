#!/usr/bin/env bash
# ====================================================================
# Deploy: Redaktions-Nachträge vom 09.09.2026
#
# Bringt vier Rückmeldungen live (DB-Teil:
# deploy/fcs-inhalte-0909.php.tpl):
#
#   A) Veranstaltungen — die vergangene «93. Generalversammlung» in den
#      Papierkorb, die sechs neuen Termine bis Dezember 2027 anlegen.
#      Das Grümpelturnier bekommt ein Enddatum (17.–19.06.2027).
#   B) Sponsoren — Website-Link bei «Zurich Insurance» (Generalagentur
#      Simon Mani) und «Duftruim» (Olivia Bachmann Massagepraxis);
#      bei Duftruim ausserdem das farbige Logo statt des grauen.
#   C) Vorstand — neues Porträt von Claudia Gisler, erstes Porträt von
#      Robin Lindauer (bisher Silhouette).
#   D) 2. Mannschaft — Betreuerbild von Robin Lindauer.
#   E) Fussballschule — Nico Zgraggen aus dem Betreuerteam nehmen.
#
# REIHENFOLGE: Zuerst `./scripts/deploy-theme.sh` laufen lassen. Der
# Theme-Teil bringt das Feld «Enddatum», die Datumsspanne und die
# Automatik für vergangene Termine mit. Ohne ihn stehen die sechs
# Termine zwar korrekt in der DB, das Grümpelturnier zeigt aber nur
# den ersten Tag. Umgekehrt schadet nichts — beide Reihenfolgen sind
# unkritisch, diese hier ist nur die aufgeräumtere.
#
# Ablauf:
#   1. Vier Bilddateien übertragen (vorher Sicherung von
#      Claudia_Gisler.jpg auf dem Server), jede auf HTTP 200 prüfen
#   2. Token-geschütztes PHP in den Webroot legen, Probelauf fahren
#   3. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   4. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Achtung Claudia_Gisler.jpg: Das neue Foto ersetzt die Datei unter
# demselben Namen — nur so bleiben Mediathek-Eintrag (#218) und die
# srcset-Angaben der Vorstandsseite stimmig. Die alte Fassung liegt
# danach als Claudia_Gisler.bak-20260909.jpg daneben; das DB-Skript
# rechnet die Vorschaugrössen neu.
#
# Vorher einmal ./scripts/pull-prod-db.sh laufen lassen — der Dump in
# backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Idempotent: ein zweiter Lauf meldet überall «SKIP».
#
# Aufruf:  ./deploy/deploy-inhalte-0909.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
MEDIEN="wp-content/uploads/2026/06"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-inhalte-0909.php"

BILDER=(
  "muoser-weiss.png"        # weisse Wortmarke für die Hero-Ecke der Startseite
  "Robin_Lindauer.jpg"      # Porträt Vorstand / Betreuer 2. Mannschaft
  "Claudia_Gisler.jpg"      # neues Porträt, ersetzt die bestehende Datei
  "duftruim-2026.png"       # farbiges Logo Duftruim (Olivia Bachmann)
)

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 0. Dateien müssen lokal da sein ─────────────────────────────────
for b in "${BILDER[@]}"; do
  if [ ! -f "$MEDIEN/$b" ]; then
    echo "FEHLER: $MEDIEN/$b fehlt lokal. Abbruch." >&2
    exit 1
  fi
done

# ── 1. Bilddateien übertragen ───────────────────────────────────────
log "1/6  Alte Fassung von Claudia_Gisler.jpg auf dem Server sichern…"
# -n: eine schon vorhandene Sicherung nicht überschreiben, sonst wäre
# beim zweiten Lauf das neue Bild die «Sicherung».
ssh "$HOST" "cp -n $WEBROOT/$MEDIEN/Claudia_Gisler.jpg $WEBROOT/$MEDIEN/Claudia_Gisler.bak-20260909.jpg 2>/dev/null || true; \
             ls -l $WEBROOT/$MEDIEN/Claudia_Gisler.bak-20260909.jpg 2>/dev/null || echo '    (keine Sicherung nötig – Datei war nicht vorhanden)'"

log "2/6  Bilddateien übertragen und einzeln prüfen…"
scp -q "${BILDER[@]/#/$MEDIEN/}" "$HOST:$WEBROOT/$MEDIEN/"
ok=1
for b in "${BILDER[@]}"; do
  c="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 20 "$LIVE/$MEDIEN/${b// /%20}")"
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

# ── 3. DB-Skript hochladen und PROBELAUF ────────────────────────────
log "3/6  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"

lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume das Skript vom Server…"
  ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
  echo "Hinweis: die vier Bilddateien liegen bereits live. Das stört nichts —"
  echo "         ohne die DB-Änderung bindet sie nur noch niemand ein."
  exit 0
fi

# ── 4. DB-Änderung scharf auslösen ──────────────────────────────────
log "4/6  DB-Änderung ausführen…"
lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

log "Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"
echo "    ${PHPNAME} liefert HTTP $code (erwartet 404)"

# ── 5. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "5/6  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 6. Verifikation ─────────────────────────────────────────────────
log "6/6  Seiten prüfen…"
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

echo "  Startseite"
pruefe "Muoser-Wortmarke statt Schriftzug" "/" 'muoser-weiss\.png'              ">0"
pruefe "alter WhatsApp-Kanal weg"          "/" '0029VbCwxidGehEK9HVaJ01G'       "0"
pruefe "neuer WhatsApp-Kanal"              "/" '0029VbDULM4FXUugCV1Kiq1M'       ">0"
pruefe "Termin Vorrundenabschluss"         "/" 'Vorrundenabschluss'             ">0"

echo "  Events"
E="/events/"
pruefe "93. Generalversammlung weg"        "$E" '93\. Generalversammlung'       "0"
pruefe "Vorrundenabschluss"                "$E" 'Vorrundenabschluss'            ">0"
pruefe "Weihnachtsfeier"                   "$E" 'Weihnachtsfeier'               ">0"
pruefe "Sponsorenaperitif"                 "$E" 'Sponsorenap'                   ">0"
pruefe "Schreibweise ohne Bindestrich"     "$E" 'Freimitglieder- und'            "0"
pruefe "Kick-in-one"                       "$E" 'Kick-in-one'                   ">0"
pruefe "Doerf- und Gruempelturnier"        "$E" 'mpelturnier'                   ">0"
pruefe "Datumsspanne Juni 2027"            "$E" '19\. Juni 2027'                ">0"

echo "  Sponsoren"
S="/sponsoren/"
pruefe "Link Zurich (Simon Mani)"          "$S" 'generalagentur-simon-mani'     ">0"
pruefe "Link Duftruim"                     "$S" 'duftruim\.com'                 ">0"
pruefe "farbiges Duftruim-Logo"            "$S" 'duftruim-2026\.png'            ">0"
pruefe "graues Duftruim-Logo weg"          "$S" 'duftruim-color\.png'           "0"

echo "  Vorstand"
V="/verein/vorstand/"
pruefe "Portraet Robin Lindauer"           "$V" 'Robin_Lindauer\.jpg'           ">0"
pruefe "Portraet Claudia Gisler"           "$V" 'Claudia_Gisler\.jpg'           ">0"

echo "  2. Mannschaft"
M="/aktive/2-mannschaft/"
pruefe "Betreuerbild Robin Lindauer"       "$M" 'Robin_Lindauer\.jpg'           ">0"

echo "  Fussballschule"
F="/junioren/fussballschule/"
pruefe "Nico Zgraggen entfernt"            "$F" 'Nico Zgraggen'                 "0"
pruefe "uebrige Betreuer noch da"          "$F" 'Janic Gisler'                  ">0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Die «93. Generalversammlung» liegt im Papierkorb (Veranstaltungen ->"
  echo "  Papierkorb) und ist von der Website verschwunden. Künftig räumt der"
  echo "  tägliche Cron vergangene Termine selbst dorthin."
  echo "  Roger Zurfluh behält auf der 2. Mannschaft die Silhouette — dazu"
  echo "  liegt kein Foto vor."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  echo "  Fehlt nur die Datumsspanne oder die Muoser-Wortmarke, ist der"
  echo "  Theme-Teil noch nicht deployt: ./scripts/deploy-theme.sh"
  exit 1
fi
