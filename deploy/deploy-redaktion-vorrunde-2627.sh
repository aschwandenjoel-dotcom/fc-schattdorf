#!/usr/bin/env bash
# ====================================================================
# Deploy: Redaktions-Rückmeldungen vom 03.09.2026
#
# Zwei Teile, in dieser Reihenfolge:
#   1. Theme-Code (rsync) — Navigation «Frauen Team Uri» /
#      «Senioren Team Uri» / «Ehren-/Freimitglieder», WhatsApp-Kanal
#      neben Facebook und Instagram, Co-Sponsor Herger Küchen von der
#      Startseite entfernt, Gruppenbild auf der Junioren-Übersicht,
#      Vereinsgeschichte zählt ab 1933, Trainingslager kann Anmeldung /
#      Flyer / «Bist du dabei?» über leere Felder ausblenden,
#      Fussballschule und «Mitglied werden» mit neuen Standardtexten,
#      neuer Team-Umschalter auf den Juniorenteam-Seiten (ersetzt das
#      Band mit allen Teamnamen über dem Titelbild).
#   2. 15 neue Dateien nach wp-content/uploads/2026/06 (Logos Brückli
#      und Zurich, sechs Spieler-Sponsorenlogos in höherer Auflösung,
#      vier Schiedsrichter-Fotos, weibliche Silhouette, Mannschaftsfoto
#      der 2. Mannschaft, Flyer Fussballschule) — dazu 81 bereits
#      vorhandene Bilder, die auf eine web-taugliche Grösse verkleinert
#      wurden (Liste: deploy/verkleinerte-bilder.txt). Sie behalten
#      ihre Dateinamen, es sind also reine Ersetzungen. Gezielt Datei
#      für Datei, kein rsync des ganzen Upload-Ordners — dort liegt
#      Redaktions-Material.
#   3. DB-Änderungen über ein token-geschütztes PHP-Skript im Webroot
#      (auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar):
#      Teamnamen, Betreuerstäbe der Junioren, Vorstand, Vorfall melden,
#      Mitglied werden, Fussballschule, Trainingslager, Bildzuordnungen.
#      Siehe Kopf von deploy/fcs-redaktion-vorrunde-2627.php.tpl.
#
# Reihenfolge ist wichtig: zuerst der Code (er kennt die neuen leeren
# Felder), dann die Dateien (das DB-Skript prüft, ob sie da sind),
# zuletzt die Daten.
#
# ACHTUNG, Zusammenspiel mit den anderen offenen Deploys: der rsync in
# Schritt 2 überträgt den ganzen Theme-Ordner, also auch
# page-1mannschaft.php und page-3mannschaft.php aus
# deploy-1mannschaft-vorrunde-2627.sh und deploy-3mannschaft-feritec.sh.
# Diese Vorlagen verweisen fest auf Bilddateien, die erst deren eigene
# Deploys hochladen (FCS1_Web2627.jpg, FCS3_Web2627.jpg,
# feritec-2026.png). Läuft dieses Skript allein, zeigen die Seiten
# 1. und 3. Mannschaft so lange ein kaputtes Titelbild. Schritt 0 prüft
# das und fragt nach. Am saubersten: die drei Deploys hintereinander.
#
# Vorher unbedingt einmal ./scripts/pull-prod-db.sh laufen lassen —
# der Dump in backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Erst Trockenlauf/Probelauf, dann Rückfrage, dann Schreiben.
# Idempotent: ein zweiter Lauf meldet überall «SKIP».
#
# Aufruf:  ./deploy/deploy-redaktion-vorrunde-2627.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
THEME="wp-content/themes/fcschattdorf-child"
PHPNAME="fcs-redaktion-vorrunde-2627.php"
UPLOADS="wp-content/uploads/2026/06"
# Neue Bild-/PDF-Dateien; das DB-Skript verweigert Teil H, wenn eine fehlt.
NEUE_DATEIEN=(
  Leon_Ziegler.jpg
  Lucas_Martins_Ferreira.jpg
  Gisler_Stephan_2026.jpg
  Silhouette_Female.jpg
  ReneHueglin_2026.jpg
  FCS_2_Web2627.jpg
  gasthaus-brueckli-2026.jpg
  zurich-ga-simon-mani-2026.png
  Flyer_Fussballschule_Herbst_2026.pdf
  kms-2026.png
  gotthard-holzbau-2026.png
  heidi-nails-2026.png
  raiffeisen-2026.png
  schelbert-2026.png
  boge-2026.png
  cash-2026.png
  brand-automobile-2026.png
  Rene_Gnos_hoch.jpg
  Paddi_Schorno_hoch.jpg
  Iwan_Herger_hoch.jpg
  Markus_Indergand_hoch.jpg
  Kuster_farbig.png
)
# Bereits vorhandene Bilder, die nur ersetzt werden (gleicher Dateiname).
VERKLEINERT_LISTE="deploy/verkleinerte-bilder.txt"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 0. Fremde Deploys, die im selben Theme-Ordner hängen ────────────
# Dateien, die andere offene Deploys hochladen, auf die der lokale
# Theme-Code aber schon zeigt. Fehlen sie live, liefert der rsync in
# Schritt 2 Vorlagen mit toten Bildverweisen aus.
FREMDE_DATEIEN=(
  FCS1_Web2627.jpg          # deploy-1mannschaft-vorrunde-2627.sh
  FCS3_Web2627.jpg          # deploy-3mannschaft-feritec.sh
  feritec-2026.png          # deploy-3mannschaft-feritec.sh
)
fehlen_live=()
for f in "${FREMDE_DATEIEN[@]}"; do
  code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/$UPLOADS/$f")"
  [ "$code" = "200" ] || fehlen_live+=("$f")
done
if [ "${#fehlen_live[@]}" != "0" ]; then
  printf "\n\033[1;33mACHTUNG: Diese Dateien fehlen live, der lokale Theme-Code zeigt aber darauf:\033[0m\n"
  printf "  %s\n" "${fehlen_live[@]}"
  echo "  Sie gehören zu deploy-1mannschaft-vorrunde-2627.sh bzw."
  echo "  deploy-3mannschaft-feritec.sh. Läuft dieses Skript zuerst, zeigen"
  echo "  die betroffenen Seiten bis zu deren Deploy ein kaputtes Titelbild."
  printf "\033[1;33mTrotzdem weiter? [j/N] \033[0m"
  read -r answer
  [ "$answer" = "j" ] || [ "$answer" = "J" ] || { echo "Abgebrochen."; exit 0; }
fi

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

# ── 3. Neue Bilder und PDF hochladen ────────────────────────────────
log "3/8  Neue Dateien nach ${UPLOADS}/ übertragen…"
fehlend=0
for f in "${NEUE_DATEIEN[@]}"; do
  [ -f "$UPLOADS/$f" ] || { echo "    FEHLT lokal: $UPLOADS/$f"; fehlend=1; }
done
[ "$fehlend" = "0" ] || { echo "Abgebrochen – lokale Dateien unvollständig."; exit 1; }

VERKLEINERT=()
if [ -f "$VERKLEINERT_LISTE" ]; then
  while IFS= read -r zeile; do
    case "$zeile" in ''|'#'*) continue;; esac
    [ -f "$UPLOADS/$zeile" ] || { echo "    FEHLT lokal: $UPLOADS/$zeile"; fehlend=1; }
    VERKLEINERT+=("$zeile")
  done < "$VERKLEINERT_LISTE"
fi
[ "$fehlend" = "0" ] || { echo "Abgebrochen – lokale Dateien unvollständig."; exit 1; }
echo "    ${#NEUE_DATEIEN[@]} neue Dateien, ${#VERKLEINERT[@]} verkleinerte Ersetzungen"

printf '%s\n' "${NEUE_DATEIEN[@]/#/$UPLOADS/}" "${VERKLEINERT[@]/#/$UPLOADS/}" \
  | rsync -avz --files-from=- ./ "$HOST:$WEBROOT/" | tail -6

# Jede Datei einzeln gegen live prüfen; nur Ausreisser ausgeben.
schlecht=0
for f in "${NEUE_DATEIEN[@]}" "${VERKLEINERT[@]}"; do
  code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/$UPLOADS/$f")"
  if [ "$code" != "200" ]; then
    printf '    FEHL %-44s HTTP %s\n' "$f" "$code"; schlecht=$((schlecht+1))
  fi
done
if [ "$schlecht" != "0" ]; then
  echo "Abgebrochen – $schlecht Datei(en) sind live nicht erreichbar."; exit 1
fi
echo "    alle $(( ${#NEUE_DATEIEN[@]} + ${#VERKLEINERT[@]} )) Dateien liefern live HTTP 200"

# Gegenprobe, dass die Ersetzung wirklich griff: das groesste Kamerabild
# war 15,5 MB, die verkleinerte Fassung liegt bei rund 0,2 MB.
groesse="$(lcurl -sI "$LIVE/$UPLOADS/Fabrizio_Merenda.jpg" | tr -d '\r' | awk 'BEGIN{IGNORECASE=1}/^content-length:/{print $2}')"
if [ -n "$groesse" ] && [ "$groesse" -lt 1000000 ] 2>/dev/null; then
  echo "    Fabrizio_Merenda.jpg live: $groesse Bytes (vorher 16253765) – Ersetzung hat gegriffen"
else
  echo "    ACHTUNG: Fabrizio_Merenda.jpg live meldet Content-Length '$groesse' (erwartet < 1000000)"
fi

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
log "8/8  Seiten prüfen…"
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

pruefe "Junioren-Übersicht: Team Aa"          "/junioren/teams/"            '>Aa<'                    ">0"
pruefe "Junioren-Übersicht: Team Fd"          "/junioren/teams/"            '>Fd<'                    ">0"
pruefe "Junioren-Übersicht: FF14"             "/junioren/teams/"            'Team Uri FF14'           ">0"
pruefe "Junioren-Übersicht: FF17"             "/junioren/teams/"            'Team Uri FF17'           ">0"
pruefe "Junioren-Übersicht: Df ist weg"       "/junioren/teams/"            '>Df<'                    "0"
pruefe "Junioren-Übersicht: Ef ist weg"       "/junioren/teams/"            '>Ef<'                    "0"
pruefe "Junioren-Übersicht: Gruppenbild"      "/junioren/teams/"            'fctc-hero'               ">0"
pruefe "Junioren-Übersicht: Silhouetten"      "/junioren/teams/"            'fctc-team__photo--placeholder' ">0"
pruefe "Frauen Team Uri (ohne I)"             "/aktive/frauen-uri-1/"       'Frauen Team Uri<'        ">0"
pruefe "Senioren Team Uri (ohne I)"           "/aktive/senioren-uri-1/"     'Senioren Team Uri<'      ">0"
pruefe "Vorstand: Robin Lindauer"             "/verein/vorstand/"           'Robin Lindauer'          ">0"
pruefe "Vorstand: Monja ist raus"             "/verein/vorstand/"           'Monja Deplazes'          "0"
pruefe "Vorstand: René Gnos ist Sportchef"    "/verein/vorstand/"           '<strong>Sportchef</strong>' ">0"
pruefe "Vorfall melden: Robin Lindauer"       "/verein/vorfall-melden/"     'Robin Lindauer'          ">0"
pruefe "Mitglied werden: Passivmitglied"      "/verein/mitglied-werden/"    'Passivmitglied'          ">0"
pruefe "Mitglied werden: Jahrgang 2018–2013"  "/verein/mitglied-werden/"    'Jahrgang 2018'           ">0"
pruefe "Fussballschule: Jahrgang 2020 & 2021" "/junioren/fussballschule/"   'Jahrgang 2020'           ">0"
pruefe "Trainingslager: Juli 2027"            "/junioren/trainingslager/"   'Juli 2027'               ">0"
pruefe "Trainingslager: keine Anmeldung"      "/junioren/trainingslager/"   'Jetzt anmelden'          "0"
pruefe "Trainingslager: kein «Bist du dabei»" "/junioren/trainingslager/"   'Bist du'                 "0"
pruefe "Trainingslager: kein Flyer-Block"     "/junioren/trainingslager/"   'tl-flyer-row'            "0"
pruefe "Vereinsgeschichte: gegründet 1933"    "/verein/vereinsgeschichte/"  'Gegründet 1933'          ">0"
pruefe "Startseite: WhatsApp-Kanal"           "/"                           'whatsapp.com/channel'    ">0"
pruefe "Startseite: Herger Küchen ist raus"   "/"                           'Herger Küchen'           "0"
pruefe "Startseite: Ehren-/Freimitglieder"    "/"                           'Ehren-/Freimitglieder'   ">0"
pruefe "Footer Unterseite: WhatsApp-Kanal"    "/verein/vorstand/"           'whatsapp.com/channel'    ">0"
pruefe "Schiedsrichter: Foto Leon Ziegler"    "/verein/schiedsrichter/"     'Leon_Ziegler.jpg'        ">0"
pruefe "Schiedsrichter: Foto Lucas Martins"   "/verein/schiedsrichter/"     'Lucas_Martins_Ferreira.jpg' ">0"
pruefe "Schiedsrichter: Foto Stephan Gisler"  "/verein/schiedsrichter/"     'Gisler_Stephan_2026.jpg'  ">0"
pruefe "Startseite: neues Brückli-Logo"       "/"                           'gasthaus-brueckli-2026'   ">0"
pruefe "Sponsoren: neues Brückli-Logo"        "/sponsoren/"                 'gasthaus-brueckli-2026'   ">0"
pruefe "Sponsoren: altes Brückli-Logo weg"    "/sponsoren/"                 'gasthaus-brueckli-color'  "0"
pruefe "1. Mannschaft: neues Brückli-Logo"    "/aktive/1-mannschaft/"       'gasthaus-brueckli-2026'   ">0"
pruefe "1. Mannschaft: altes Brückli-Logo weg" "/aktive/1-mannschaft/"      'gasthaus-brueckli-color'  "0"
pruefe "Junioren Dc: neues Brückli-Logo"      "/junioren/teams/junioren-dc-junioren/" 'gasthaus-brueckli-2026' ">0"
pruefe "Junioren Dc: altes Brückli-Logo weg"  "/junioren/teams/junioren-dc-junioren/" 'sp-gasthaus-brueckli'   "0"
pruefe "Sponsoren: neues Zurich-Logo"         "/sponsoren/"                 'zurich-ga-simon-mani-2026' ">0"
pruefe "Sponsoren: altes Zurich-Logo weg"     "/sponsoren/"                 'zurich_vers.png'          "0"
pruefe "Sponsoren: KMS in hoher Auflösung"    "/sponsoren/"                 'kms-2026.png'             ">0"
pruefe "Sponsoren: Gotthard Holzbau farbig"   "/sponsoren/"                 'gotthard-holzbau-2026.png' ">0"
pruefe "Sponsoren: Heidi Nails neu"           "/sponsoren/"                 'heidi-nails-2026.png'     ">0"
pruefe "Sponsoren: Raiffeisen neu"            "/sponsoren/"                 'raiffeisen-2026.png'      ">0"
pruefe "Sponsoren: Schelbert neu"             "/sponsoren/"                 'schelbert-2026.png'       ">0"
pruefe "Sponsoren: BoGe neu"                  "/sponsoren/"                 'boge-2026.png'            ">0"
pruefe "Sponsoren: kein altes BoGe-Logo"      "/sponsoren/"                 'boge-color.jpg'           "0"
pruefe "Startseite: cash. in Markenblau"      "/"                           'cash-2026.png'            ">0"
pruefe "Startseite: Brand Automobile schwarz" "/"                           'brand-automobile-2026.png' ">0"
pruefe "Sponsoren: cash. in Markenblau"       "/sponsoren/"                 'cash-2026.png'            ">0"
pruefe "Sponsoren: Brand Automobile schwarz"  "/sponsoren/"                 'brand-automobile-2026.png' ">0"
pruefe "Fussballschule: neuer Flyer"          "/junioren/fussballschule/"   'Flyer_Fussballschule_Herbst_2026.pdf' ">0"
pruefe "Team Ec: weibliche Silhouette"        "/junioren/teams/junioren-ec-junioren/" 'Silhouette_Female.jpg' ">0"
pruefe "Teamseite: neuer Umschalter"          "/junioren/teams/junioren-dd-junioren/" 'fcjt-switch'      ">0"
pruefe "Teamseite: altes Teamband weg"        "/junioren/teams/junioren-dd-junioren/" 'fcsh-sub-nav'     "0"
pruefe "Betreuerfotos: Ausschnitt 50%"        "/wp-content/themes/fcschattdorf-child/assets/fcs-1mannschaft.css" 'center 50%' ">0"
pruefe "Termine-Leerzustand wie Spalten-Kopf" "/wp-content/themes/fcschattdorf-child/assets/fcs-front.css" 'fcx-event__empty,$' ">0"
pruefe "Junioren-Gruppenbild: fixierter Grund" "/wp-content/themes/fcschattdorf-child/assets/fcs-wine-info.css" 'background-attachment: fixed' ">0"
pruefe "Junioren-Kopf dockt an"               "/junioren/teams/"            'fctc-dock'                ">0"
pruefe "Andock-Regel im Stylesheet"           "/wp-content/themes/fcschattdorf-child/assets/fcs-wine-info.css" 'fctc-dock .fctc-header' ">0"
# Bilddatei per Status pruefen; pruefe() greppt nur Text und taugt fuer ein JPEG nicht.
jpg_code="$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/wp-content/themes/fcschattdorf-child/assets/img/junioren-gruppenbild.jpg")"
if [ "$jpg_code" = "200" ]; then
  printf "    OK   Junioren-Gruppenbild liegt live (HTTP %s)\n" "$jpg_code"
else
  printf "    FEHL Junioren-Gruppenbild fehlt live (HTTP %s)\n" "$jpg_code"; ok=0
fi
pruefe "Junioren-Uebersicht bindet es ein"    "/junioren/teams/"            'junioren-gruppenbild.jpg' ">0"
pruefe "Vorstand: René Gnos hochkant"         "/verein/vorstand/"           'Rene_Gnos_hoch.jpg'      ">0"
pruefe "Vorstand: Patrick Schorno hochkant"   "/verein/vorstand/"           'Paddi_Schorno_hoch.jpg'  ">0"
pruefe "Vorstand: Iwan Herger hochkant"       "/verein/vorstand/"           'Iwan_Herger_hoch.jpg'    ">0"
pruefe "Vorstand: Markus Indergand hochkant"  "/verein/vorstand/"           'Markus_Indergand_hoch.jpg' ">0"
pruefe "Vorstand: kein srcset mehr dort"      "/verein/vorstand/"           'Rene_Gnos-1024x683'      "0"
pruefe "Startseite: Hero-Story-Block"         "/"                           'fcsh-hero__story'        ">0"
pruefe "Hero: neue Blende (is-leaving)"       "/wp-content/themes/fcschattdorf-child/assets/fcs-front.css" 'is-leaving' ">0"
pruefe "News: früherer Aufdeck-Auslöser"      "/wp-content/themes/fcschattdorf-child/assets/fcs-home.js" '0px 0px 12% 0px' ">0"
pruefe "3. Mannschaft: eigener Bildausschnitt" "/wp-content/themes/fcschattdorf-child/assets/fcs-1mannschaft.css" 'page-template-page-3mannschaft' ">0"
pruefe "Teamseiten: Titelbild füllt Fenster"  "/wp-content/themes/fcschattdorf-child/assets/fcs-1mannschaft.css" '100svh - var(--fcx-hdr-h' ">0"
pruefe "Grümpelturnier: Kuster farbig"        "/gruempelturnier/"           'Kuster_farbig.png'       ">0"
pruefe "Grümpelturnier: kein Schwarz-Kuster"  "/gruempelturnier/"           '06/Kuster.png'           "0"
pruefe "FF11: Arturo Schneeberger"            "/junioren/teams/team-uri-ff11/" 'Arturo Schneeberger'  ">0"
pruefe "FF11: Sponsor Gasthaus Brückli"       "/junioren/teams/team-uri-ff11/" 'Gasthaus Brückli'     ">0"
pruefe "FF14: Luca Forte"                     "/junioren/teams/team-uri-ff14/" 'Luca Forte'           ">0"
pruefe "FF14: Sponsor Raiffeisen"             "/junioren/teams/team-uri-ff14/" 'Raiffeisen'           ">0"
pruefe "FF17: Noreen Häfliger"                "/junioren/teams/team-uri-ff17/" 'Noreen Häfliger'      ">0"
pruefe "FF17: Sponsor TEKO"                   "/junioren/teams/team-uri-ff17/" 'TEKO'                 ">0"
# Nicht auf die blosse Jahreszahl pruefen: die Yoast-Beschreibung der
# Seite nennt «von der ersten Gruendung 1916 bis heute» und liefert
# damit einen Fehlalarm. Der Anker der 1910er-Jahre gibt es nur, wenn
# auch ein Eintrag aus diesem Jahrzehnt in der Chronik steht.
pruefe "Vereinsgeschichte: 1916 ist weg"      "/verein/vereinsgeschichte/"  '#decade-1910'            "0"
pruefe "Vereinsgeschichte: 1930er zuerst"     "/verein/vereinsgeschichte/"  '#decade-1930'            ">0"
pruefe "Schiedsrichter: Foto René Hüglin"     "/verein/schiedsrichter/"     'ReneHueglin_2026.jpg'    ">0"
pruefe "2. Mannschaft: neues Teamfoto"        "/aktive/2-mannschaft/"       'FCS_2_Web2627.jpg'       ">0"
pruefe "2. Mannschaft: Igor Sureta"           "/aktive/2-mannschaft/"       'Igor Sureta'             ">0"
pruefe "2. Mannschaft: Robin Lindauer"        "/aktive/2-mannschaft/"       'Robin Lindauer'          ">0"
pruefe "2. Mannschaft: Lussmann ist raus"     "/aktive/2-mannschaft/"       'Mathias Lussmann'        "0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Danach noch offen (siehe UEBERGABE.md): Fotos der Betreuer mit"
  echo "  Silhouette, Zuordnung der zwei übrigen Schiedsrichter-Fotos,"
  echo "  Fotoqualität auf der Vorstandsseite."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
