#!/usr/bin/env bash
# ====================================================================
# Deploy: 1. Mannschaft, Stand Vorrunde 2026/27
#
# Quelle der Angaben: www.fcschattdorf.ch/aktive/1-mannschaft
# (dort pflegt die Redaktion den aktuellen Stand), abgeglichen am
# 04.09.2026. Zwei Punkte waren dort offen und wurden mit dem Verein
# geklärt: Joel Aschwanden (23) ist Verteidigung, und Nico Bissig
# trägt neu die 15, Linus Arnold die 14.
#
# Drei Teile, in dieser Reihenfolge:
#   1. Theme-Code (rsync) — page-1mannschaft.php mit neuem Fallback
#      (Betreuerstab, Kader, Kopfsponsoren) und neuem Mannschaftsfoto.
#   2. 23 neue Dateien nach wp-content/uploads/2026/06 — 14 Porträts
#      und das Mannschaftsfoto aus der Fotoserie vom August 2026,
#      1 Porträt von fcschattdorf.ch (David Baumann) sowie 7
#      Sponsorenlogos in hoher Auflösung. Gezielt Datei für Datei,
#      kein rsync des ganzen Upload-Ordners — dort liegt
#      Redaktions-Material.
#   3. DB-Änderung über ein token-geschütztes PHP-Skript im Webroot
#      (auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar):
#      die Seitenfelder fcs_team_staff und fcs_team_kader der Seite
#      «1. Mannschaft». Siehe Kopf von
#      deploy/fcs-1mannschaft-vorrunde-2627.php.tpl.
#
# Reihenfolge ist wichtig: zuerst der Code, dann die Dateien (das
# DB-Skript verweigert den Kader, wenn eine davon fehlt), zuletzt die
# Daten.
#
# Unabhängig von ./deploy/deploy-redaktion-vorrunde-2627.sh — beide
# fassen verschiedene Felder an. gasthaus-brueckli-2026.jpg liegt in
# beiden Dateilisten, damit jedes Skript für sich vollständig ist;
# rsync überträgt sie beim zweiten Mal einfach nicht mehr.
#
# Vorher unbedingt einmal ./scripts/pull-prod-db.sh laufen lassen —
# der Dump in backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Erst Trockenlauf/Probelauf, dann Rückfrage, dann Schreiben.
# Idempotent: ein zweiter Lauf meldet überall «SKIP».
#
# Aufruf:  ./deploy/deploy-1mannschaft-vorrunde-2627.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
THEME="wp-content/themes/fcschattdorf-child"
PHPNAME="fcs-1mannschaft-vorrunde-2627.php"
UPLOADS="wp-content/uploads/2026/06"
# Neue Bilddateien; das DB-Skript verweigert den Kader, wenn eine fehlt.
NEUE_DATEIEN=(
  Saverio_LaBella.jpg
  Thomas_Zberg_2627.jpg
  Livio_Mahrow.jpg
  GianLuca_Tresch.jpg
  Samuel_Wirth_2627.jpg
  Tim_Riesen.jpg
  Ben_Arnold.jpg
  Noel_Herger.jpg
  Nico_Zgraggen_2627.jpg
  Joel_Aschwanden.jpg
  Sandro_Imbach.jpg
  Robin_Zurfluh.jpg
  Elias_Muoser_2627.jpg
  David_Baumann.jpg
  FCS1_Web2627.jpg
  mazzei-hypnosetherapie-2026.jpg
  psbackup-2026.png
  arnold-umzuege-2026.jpg
  dashauptwerk-2026.png
  schibli-elektrotechnik-2026.png
  zurich-2026.png
  coiffure-atmosphair-2026.png
  gasthaus-brueckli-2026.jpg
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
  printf '    %-34s HTTP %s\n' "$f" "$code"
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
M1="/aktive/1-mannschaft/"
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

# Betreuerstab
pruefe "Trainer Saverio La Bella"        "$M1" 'Saverio La Bella'      ">0"
pruefe "Thomas Zberg ist Coach"          "$M1" '>Coach<'               ">0"
pruefe "Reto Infanger ist raus"          "$M1" 'Reto Infanger'         "0"
pruefe "kein Co-Trainer mehr"            "$M1" '>Co-Trainer<'          "0"

# Zugänge
pruefe "Zugang Livio Mahrow"             "$M1" 'Livio Mahrow'          ">0"
pruefe "Zugang Mario Arnold"             "$M1" 'Mario Arnold'          ">0"
pruefe "Zugang Fabio Moser"              "$M1" 'Fabio Moser'           ">0"
pruefe "Zugang Sandro Imbach"            "$M1" 'Sandro Imbach'         ">0"
pruefe "Zugang Joel Aschwanden"          "$M1" 'Joel Aschwanden'       ">0"
pruefe "Zugang Noel Herger"              "$M1" 'Noel Herger'           ">0"
pruefe "Zugang Ben Arnold"               "$M1" 'Ben Arnold'            ">0"
pruefe "Zugang Tim Riesen"               "$M1" 'Tim Riesen'            ">0"
pruefe "Zugang Gian-Luca Tresch"         "$M1" 'Gian-Luca Tresch'      ">0"
pruefe "Zugang Robin Zurfluh"            "$M1" 'Robin Zurfluh'         ">0"
pruefe "Zugang David Baumann"            "$M1" 'David Baumann'         ">0"

# Abgänge
pruefe "Gian Gisler ist raus"            "$M1" 'Gian Gisler'           "0"
pruefe "Yannick Arnold ist raus"         "$M1" 'Yannick Arnold'        "0"
pruefe "Sandro Stampfli ist raus"        "$M1" 'Sandro Stampfli'       "0"
pruefe "Skander Agrebi ist raus"         "$M1" 'Skander Agrebi'        "0"
pruefe "Livio Gisler ist raus"           "$M1" 'Livio Gisler'          "0"

# Bilder
pruefe "neues Mannschaftsfoto"           "$M1" 'FCS1_Web2627.jpg'      ">0"
pruefe "altes Mannschaftsfoto weg"       "$M1" 'FCS1_Web2526.jpg'      "0"
pruefe "Foto Saverio La Bella"           "$M1" 'Saverio_LaBella.jpg'   ">0"
pruefe "neues Foto Thomas Zberg"         "$M1" 'Thomas_Zberg_2627.jpg' ">0"
pruefe "neues Foto Elias Muoser"         "$M1" 'Elias_Muoser_2627.jpg' ">0"
pruefe "neues Foto Samuel Wirth"         "$M1" 'Samuel_Wirth_2627.jpg' ">0"
pruefe "neues Foto Nico Zgraggen"        "$M1" 'Nico_Zgraggen_2627.jpg' ">0"

# Kopfsponsoren
pruefe "Kopfsponsor Mazzei"              "$M1" 'mazzei-hypnosetherapie-2026'  ">0"
pruefe "Kopfsponsor Physio &amp; Sport BackUp" "$M1" 'psbackup-2026'          ">0"
pruefe "Kopfsponsor Arnold Umzüge"       "$M1" 'arnold-umzuege-2026'          ">0"
pruefe "Kopfsponsor Das Hauptwerk"       "$M1" 'dashauptwerk-2026'            ">0"
pruefe "Kopfsponsor Schibli"             "$M1" 'schibli-elektrotechnik-2026'  ">0"
pruefe "Kopfsponsor Zurich (neu)"        "$M1" 'zurich-2026.png'              ">0"
pruefe "Kopfsponsor AtmospHAIR"          "$M1" 'coiffure-atmosphair-2026'     ">0"
pruefe "Kopfsponsor Herger Küchen"       "$M1" 'sp-herger-kuechen-transparent' ">0"
pruefe "Kopfsponsor Brückli (neu)"       "$M1" 'gasthaus-brueckli-2026.jpg'   ">0"
pruefe "altes Zurich-Logo weg"           "$M1" 'zurich_vers.png'              "0"
pruefe "Brand Automobile ist raus"       "$M1" 'Brand Automobile'             "0"

# Nummern
pruefe "Linus Arnold Nummer 14"          "$M1" 'Linus Arnold'          ">0"
pruefe "Schelbert AG bei Andri Baumann"  "$M1" 'Schelbert_AG.png'      ">0"

# Kader-Reihenfolge: durchgehende Liste nach Rueckennummer,
# keine Positions-Zwischentitel mehr (Position steht auf der Karte).
pruefe "Kader ohne Positionsgruppen"     "$M1" 'fc1m-pos-title'        "0"
pruefe "Position auf der Spielerkarte"   "$M1" 'fc1m-player__pos'      ">0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Danach noch offen (siehe UEBERGABE.md): Logo von Physio & Sport"
  echo "  BackUp liegt nur in 104 px vor; Mario Arnold und Fabio Moser"
  echo "  haben noch kein Porträt (Silhouette)."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
