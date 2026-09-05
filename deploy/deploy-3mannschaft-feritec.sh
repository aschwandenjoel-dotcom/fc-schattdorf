#!/usr/bin/env bash
# ====================================================================
# Deploy: 3. Mannschaft – neues Mannschaftsfoto und Teamsponsor
#         Feritec AG (Rückmeldung vom 05.09.2026)
#
# Drei Teile, in dieser Reihenfolge:
#   1. Theme-Code (rsync) — page-3mannschaft.php zeigt im Hero neu
#      FCS3_Web2627.jpg und führt Feritec AG als einzigen
#      Standard-Team-Sponsor.
#   2. Zwei neue Dateien nach wp-content/uploads/2026/06
#      (Mannschaftsfoto und Feritec-Logo). Gezielt Datei für Datei,
#      kein rsync des ganzen Upload-Ordners — dort liegt
#      Redaktions-Material.
#   3. DB-Änderung über ein token-geschütztes PHP-Skript im Webroot
#      (auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar):
#      Team-Sponsoren der 3. Mannschaft — Feritec AG ist alleiniger
#      Sponsor, Binary One faellt weg. Siehe Kopf von
#      deploy/fcs-3mannschaft-feritec.php.tpl.
#
# Reihenfolge ist wichtig: zuerst der Code, dann die Dateien (das
# DB-Skript prüft, ob sie da sind), zuletzt die Daten.
#
# ACHTUNG, Zusammenspiel mit den anderen offenen Deploys: der rsync in
# Schritt 2 überträgt den ganzen Theme-Ordner. Solange
# deploy-redaktion-vorrunde-2627.sh und
# deploy-1mannschaft-vorrunde-2627.sh nicht gelaufen sind, nimmt er
# deren Code-Änderungen mit — deren DB-Teile fehlen dann aber noch.
# Am saubersten dieses Skript zuletzt fahren.
#
# Vorher unbedingt einmal ./scripts/pull-prod-db.sh laufen lassen —
# der Dump in backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Erst Trockenlauf/Probelauf, dann Rückfrage, dann Schreiben.
# Idempotent: ein zweiter Lauf meldet überall «SKIP».
#
# Aufruf:  ./deploy/deploy-3mannschaft-feritec.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
THEME="wp-content/themes/fcschattdorf-child"
PHPNAME="fcs-3mannschaft-feritec.php"
UPLOADS="wp-content/uploads/2026/06"
# Neue Bilddateien; das DB-Skript rührt die Sponsorenliste nicht an,
# wenn eine davon fehlt.
NEUE_DATEIEN=(
  FCS3_Web2627.jpg
  feritec-2026.png
)

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Theme: Trockenlauf ───────────────────────────────────────────
log "1/8  Trockenlauf Theme – was würde übertragen (bzw. gelöscht)?"
rsync -avzn --delete --itemize-changes --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | grep -v '^$' | tail -30

log "     Gegenprobe – Unterschiede live -> lokal (nur Anzeige):"
rsync -avzn --itemize-changes --exclude '.DS_Store' \
  "$HOST:$WEBROOT/$THEME/" "$THEME/" | grep '^[<>ch]' | tail -20 \
  || echo "     (keine)"

printf "\n\033[1;33mWeiter? Das überträgt den lokalen Theme-Stand nach LIVE und löscht dort Fremdes. [j/N] \033[0m"
read -r answer
[ "$answer" = "j" ] || [ "$answer" = "J" ] || { echo "Abgebrochen."; exit 0; }

# ── 2. Theme übertragen ─────────────────────────────────────────────
log "2/8  Theme übertragen (rsync)…"
rsync -avz --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -15

# ── 3. Neue Bilder hochladen ────────────────────────────────────────
log "3/8  Neue Dateien nach ${UPLOADS}/ übertragen…"
fehlend=0
for f in "${NEUE_DATEIEN[@]}"; do
  [ -f "$UPLOADS/$f" ] || { echo "    FEHLT lokal: $UPLOADS/$f"; fehlend=1; }
done
[ "$fehlend" = "0" ] || { echo "Abgebrochen – lokale Dateien unvollständig."; exit 1; }

printf '%s\n' "${NEUE_DATEIEN[@]/#/$UPLOADS/}" \
  | rsync -avz --files-from=- ./ "$HOST:$WEBROOT/" | tail -12

for f in "${NEUE_DATEIEN[@]}"; do
  code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/$UPLOADS/$f")"
  printf '    %-40s HTTP %s\n' "$f" "$code"
  [ "$code" = "200" ] || { echo "Abgebrochen – Datei ist live nicht erreichbar."; exit 1; }
done

# ── 4. DB-Skript hochladen und PROBELAUF ────────────────────────────
log "4/8  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
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
  echo "HINWEIS: Theme-Code und Dateien sind bereits live. Die DB-Änderung fehlt noch."
  exit 0
fi

# ── 5. DB-Änderung scharf auslösen ──────────────────────────────────
log "5/8  DB-Änderung ausführen…"
lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'

# ── 6. Reste entfernen (falls Selbst-Löschung nicht griff) ──────────
log "6/8  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${PHPNAME}")"
echo "    ${PHPNAME} liefert HTTP $code (erwartet 404)"

# ── 7. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "7/8  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 8. Verifikation ─────────────────────────────────────────────────
log "8/8  Seite prüfen…"
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

pruefe "3. Mannschaft: neues Teamfoto"      "/aktive/3-mannschaft/" 'FCS3_Web2627.jpg'      ">0"
pruefe "3. Mannschaft: altes Foto ist weg"  "/aktive/3-mannschaft/" 'FCS3_Web2526.jpg'      "0"
pruefe "3. Mannschaft: Feritec-Logo"        "/aktive/3-mannschaft/" 'feritec-2026.png'      ">0"
pruefe "3. Mannschaft: Sponsorname"         "/aktive/3-mannschaft/" 'Feritec AG'            ">0"
pruefe "3. Mannschaft: Link feritec.ch"     "/aktive/3-mannschaft/" 'www.feritec.ch'        ">0"
pruefe "3. Mannschaft: Binary One ist raus" "/aktive/3-mannschaft/" 'Binary One'            "0"
pruefe "3. Mannschaft: Betreuerstab steht"  "/aktive/3-mannschaft/" 'Yannic Jäger'          ">0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Hinweis: Feritec AG ist damit alleiniger Team-Sponsor der"
  echo "  3. Mannschaft. Auf /sponsoren/ erscheint die Firma nicht — das"
  echo "  wäre ein eigener Eintrag im Admin unter «Sponsoren»."
  echo "  Binary One stand nur auf dieser Seite und ist damit von der"
  echo "  ganzen Website verschwunden; die Logodatei bleibt in der"
  echo "  Mediathek liegen."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
