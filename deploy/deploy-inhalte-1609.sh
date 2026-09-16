#!/usr/bin/env bash
# ====================================================================
# Deploy: Redaktions-Nachträge vom 16.09.2026
#
# Inhalte und Bilddateien (DB-Teil: deploy/fcs-inhalte-1609.php.tpl,
# Texte: deploy/news-import-1609.json). Kein Theme-Deploy nötig.
#
#   A) Neuer Beitrag «Weiter ohne Verlustpunkte» — Spielbericht
#      Ca-Junioren, FC Schattdorf Ca – FC Stans Ca 17:1 vom 12.09.2026
#      (Junioren). Im Artikel die Spielszene, als Beitragsbild (Hero der
#      Startseite, News-Kacheln) das Mannschaftsfoto der Ca — der Hero
#      zeigt auf dem Telefon nur den mittleren Drittel eines
#      Querformats, die Spielszene wirkte dort zu stark herangezoomt.
#      Datiert auf den 15.09., 07:57, also hinter die drei Beiträge vom
#      15.09. — so bleibt der Gunzwil-Bericht der 1. Mannschaft
#      zuoberst im Hero.
#   B) Teamfotos 2026/27 für 14 Juniorenteams (Bb, Ca, Cb, Da–De,
#      Ea/Eb, Ec, Ed/Ee, Fa/Fb/Fc, Fd, FF11) — Seitenfeld «Teamfoto»,
#      wirkt zugleich auf die Kacheln der Teams-Übersicht. Ba, FF14 und
#      FF17 hatten schon eines und bleiben. Die Fotos kamen als
#      DSC-Nummern; die Zuordnung (über Betreuer und Trikotsponsoren)
#      steht in UEBERGABE.md, Abschnitt 2v. Alle Fotos sind oben so
#      beschnitten, dass die Mannschaft senkrecht mittig sitzt.
#   C) 27 Betreuer-Porträts aus derselben Fotosession ersetzen die
#      bisherigen: neue Dateien <Name>_2627.jpg (1600 px hoch) in
#      2026/06, die alten bleiben liegen. Getauscht wird der Dateiname
#      in den Seitenfeldern (Betreuerstab der Teamseiten, Leitungsteam
#      Fussballschule, Kontakte Trainingslager, Person Jacqueline
#      Kempf).
#   D) 9 Betreuer, die bisher eine Silhouette trugen, bekommen ihr
#      Porträt (Namen von der Redaktion am 16.09. bestätigt): Heiri
#      Stadler (Bb), Kari Schilter (Da), Philippe Waridel (Dc), Sebi
#      Gisler (Dd), Lulzim Musliu und Christina Gisler (Ec), Filipos
#      Hagos (Fd), Marino Arnold und Arturo Schneeberger (FF11). Dazu
#      Tim Riesen (Dc) und Noel Herger (De) mit ihrem Spielerporträt
#      der 1. Mannschaft (Tim_Riesen.jpg, Noel_Herger.jpg — liegen
#      schon live, werden nicht übertragen).
#
# Ablauf:
#   1. 52 Bilddateien übertragen, jede auf HTTP 200 prüfen
#   2. Token-geschütztes PHP samt Textliste in den Webroot legen,
#      Probelauf fahren
#   3. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   4. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Vorher einmal ./scripts/pull-prod-db.sh laufen lassen — der Dump in
# backups/ ist der Rückweg, falls etwas schiefgeht.
#
# Idempotent: der Beitrag wird am Slug erkannt, gesetzte Teamfotos
# melden «SKIP». Ein zweiter Lauf ändert nichts.
#
# Aufruf:  ./deploy/deploy-inhalte-1609.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-inhalte-1609.php"
JSONNAME="news-import-1609.json"

# Pfad relativ zu wp-content/uploads/ — News-Bild im Monatsordner,
# Teamfotos in 2026/06 (dort sucht das Seitenfeld «Teamfoto»).
BILDER=(
  "2026/09/Ca_12-09-2026.jpg"          # Spielszene Ca-Bericht (1600x1067), im Artikel
  "2026/09/Ca_Junioren_26-27.jpg"      # Mannschaftsfoto Ca in News-Groesse, Beitragsbild (Hero/Kacheln)
  "2026/06/Bb_Junioren_26-27.jpg"
  "2026/06/Ca_Junioren_26-27.jpg"
  "2026/06/Cb_Junioren_26-27.jpg"
  "2026/06/Da_Junioren_26-27.jpg"
  "2026/06/Db_Junioren_26-27.jpg"
  "2026/06/Dc_Junioren_26-27.jpg"
  "2026/06/Dd_Junioren_26-27.jpg"
  "2026/06/De_Junioren_26-27.jpg"
  "2026/06/EaEb_Junioren_26-27.jpg"
  "2026/06/Ec_Junioren_26-27.jpg"
  "2026/06/EdEe_Junioren_26-27.jpg"
  "2026/06/FaFbFc_Junioren_26-27.jpg"
  "2026/06/Fd_Junioren_26-27.jpg"
  "2026/06/FF11_Team_26-27.jpg"
  # Betreuer-Porträts 2026/27 (1600 px hoch), siehe C)
  "2026/06/Mario_Trovatelli_2627.jpg"
  "2026/06/Jacqueline_Kempf_2627.jpg"
  "2026/06/Sandro_Zwyssig_2627.jpg"
  "2026/06/Luan_Krosa_2627.jpg"
  "2026/06/Andre_Schelbert_2627.jpg"
  "2026/06/Christian_Meier_2627.jpg"
  "2026/06/Manuel_Gnos_2627.jpg"
  "2026/06/Christian_Esins_2627.jpg"
  "2026/06/Elias_Mueller_2627.jpg"
  "2026/06/Fabio_Achermann_2627.jpg"
  "2026/06/Daniel_Triolo_2627.jpg"
  "2026/06/Endrit_Krasniqi_2627.jpg"
  "2026/06/Sandro_Zamuner_2627.jpg"
  "2026/06/Bruno_Inderbitzin_2627.jpg"
  "2026/06/Fabian_Bachmann_2627.jpg"
  "2026/06/Adi_Tresch_2627.jpg"
  "2026/06/Andre_Zgraggen_2627.jpg"
  "2026/06/Rene_Gnos_2627.jpg"
  "2026/06/Daniel_Reichmuth_2627.jpg"
  "2026/06/Michael_Gisler_2627.jpg"
  "2026/06/Ruedi_Herger_2627.jpg"
  "2026/06/Mathias_Venzin_2627.jpg"
  "2026/06/Simon_Gnos_2627.jpg"
  "2026/06/Simon_Welti_2627.jpg"
  "2026/06/Andre_Deplazes_2627.jpg"
  "2026/06/Bernhard_Gisler_2627.jpg"
  "2026/06/Sebastian_Herzog_2627.jpg"
  # bisher Silhouette, siehe D)
  "2026/06/Heiri_Stadler_2627.jpg"
  "2026/06/Kari_Schilter_2627.jpg"
  "2026/06/Philippe_Waridel_2627.jpg"
  "2026/06/Sebi_Gisler_2627.jpg"
  "2026/06/Lulzim_Musliu_2627.jpg"
  "2026/06/Christina_Gisler_2627.jpg"
  "2026/06/Filipos_Hagos_2627.jpg"
  "2026/06/Marino_Arnold_2627.jpg"
  "2026/06/Arturo_Schneeberger_2627.jpg"
)

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
  echo "Hinweis: die Bilddateien liegen bereits live. Das stört nichts —"
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

echo "  Neuer Beitrag"
C="/weiter-ohne-verlustpunkte/"
pruefe "Ca-Bericht steht"              "$C" 'Kantersieg'                 ">0"
pruefe "Ca-Bericht mit Spielszene"     "$C" 'Ca_12-09-2026'              ">0"
pruefe "Mannschaftsfoto als og:image"  "$C" 'og:image[^>]*Ca_Junioren_26-27' ">0"
pruefe "Ca-Bericht auf der Startseite" "/"  'Weiter ohne Verlustpunkte'  ">0"
pruefe "1. Mannschaft bleibt zuoberst" "/"  '"title":"Schattdorf belohnt sich sp' ">0"

echo "  Teamfotos Junioren (Teamseite und Übersicht)"
T="/junioren/teams/"
uebersicht="$(lcurl -sSL --max-time 60 "$LIVE$T")"
for tf in \
  "junioren-b-junioren-b|Bb_Junioren_26-27" "junioren-c-junioren-a|Ca_Junioren_26-27" \
  "junioren-c-junioren-b|Cb_Junioren_26-27" "junioren-d-junioren|Da_Junioren_26-27" \
  "junioren-db-junioren|Db_Junioren_26-27" "junioren-dc-junioren|Dc_Junioren_26-27" \
  "junioren-dd-junioren|Dd_Junioren_26-27" "junioren-de-junioren|De_Junioren_26-27" \
  "junioren-e-junioren|EaEb_Junioren_26-27" "junioren-ec-junioren|Ec_Junioren_26-27" \
  "junioren-edee-junioren|EdEe_Junioren_26-27" "junioren-f-junioren|FaFbFc_Junioren_26-27" \
  "junioren-feff-junioren|Fd_Junioren_26-27" "team-uri-ff11|FF11_Team_26-27"; do
  slug="${tf%%|*}"; datei="${tf#*|}"
  pruefe "Teamseite ${datei%%_*}" "$T$slug/" "${datei}\.jpg" ">0"
  # kein «printf | grep -q»: grep -q schliesst die Pipe beim ersten Treffer,
  # printf meldet dann «Broken pipe» und pipefail macht daraus einen Fehlalarm
  if [ "$(grep -c "${datei}\.jpg" <<< "$uebersicht")" != "0" ]; then
    printf "    OK   Übersicht zeigt %s\n" "$datei"
  else
    printf "    FEHL Übersicht zeigt %s nicht\n" "$datei"; ok=0
  fi
done

echo "  Betreuer-Porträts (je eine Stichprobe pro Seite)"
pruefe "Ca: Zgraggen neu"        "${T}junioren-c-junioren-a/" 'Andre_Zgraggen_2627\.jpg'   ">0"
pruefe "Ca: alte Datei weg"      "${T}junioren-c-junioren-a/" 'Andre_Zgraggen\.jpg'        "0"
pruefe "Db: Reichmuth neu"       "${T}junioren-db-junioren/"  'Daniel_Reichmuth_2627\.jpg' ">0"
pruefe "Ed/Ee: Venzin neu"       "${T}junioren-edee-junioren/" 'Mathias_Venzin_2627\.jpg'  ">0"
pruefe "FF11: Herger neu"        "${T}team-uri-ff11/"         'Ruedi_Herger_2627\.jpg'     ">0"
pruefe "Fussballschule: Kempf neu" "/junioren/fussballschule/" 'Jacqueline_Kempf_2627\.jpg' ">0"
pruefe "Trainingslager: Zamuner neu" "/junioren/trainingslager/" 'Sandro_Zamuner_2627\.jpg'   ">0"

echo "  Bisherige Silhouetten"
pruefe "Bb: Stadler"        "${T}junioren-b-junioren-b/"  'Heiri_Stadler_2627\.jpg'       ">0"
pruefe "Da: Schilter"       "${T}junioren-d-junioren/"    'Kari_Schilter_2627\.jpg'       ">0"
pruefe "Dc: Waridel"        "${T}junioren-dc-junioren/"   'Philippe_Waridel_2627\.jpg'    ">0"
pruefe "Dc: Riesen"         "${T}junioren-dc-junioren/"   'Tim_Riesen\.jpg'               ">0"
pruefe "Dc: keine Silhouette mehr" "${T}junioren-dc-junioren/" 'Silhouette'               "0"
pruefe "Dd: Sebi Gisler"    "${T}junioren-dd-junioren/"   'Sebi_Gisler_2627\.jpg'         ">0"
pruefe "De: Herger"         "${T}junioren-de-junioren/"   'Noel_Herger\.jpg'              ">0"
pruefe "De: keine Silhouette mehr" "${T}junioren-de-junioren/" 'Silhouette'               "0"
pruefe "Ec: Musliu"         "${T}junioren-ec-junioren/"   'Lulzim_Musliu_2627\.jpg'       ">0"
pruefe "Ec: Christina Gisler" "${T}junioren-ec-junioren/" 'Christina_Gisler_2627\.jpg'    ">0"
pruefe "Ec: keine Silhouette mehr" "${T}junioren-ec-junioren/" 'Silhouette'               "0"
pruefe "Fd: Hagos"          "${T}junioren-feff-junioren/" 'Filipos_Hagos_2627\.jpg'       ">0"
pruefe "FF11: Arnold"       "${T}team-uri-ff11/"          'Marino_Arnold_2627\.jpg'       ">0"
pruefe "FF11: Schneeberger" "${T}team-uri-ff11/"          'Arturo_Schneeberger_2627\.jpg' ">0"
pruefe "FF11: keine Silhouette mehr" "${T}team-uri-ff11/" 'Silhouette'                    "0"

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
  echo "  Bitte einmal im Browser durch /junioren/teams/ klicken: sitzt eine"
  echo "  Mannschaft im Titelbild zu hoch oder zu tief, im Admin der Teamseite"
  echo "  das Feld «Teamfoto: senkrechte Lage» setzen (z. B. 40)."
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
