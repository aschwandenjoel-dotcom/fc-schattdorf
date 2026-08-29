#!/usr/bin/env bash
# ====================================================================
# Deploy: Gesamter Design-Stand aus Commit e6e5036
#
# Fasst die beiden bisher nie ausgeführten Einzel-Deploys zusammen
# (deploy-junioren-teams.sh + deploy-junioren-seiten.sh), damit das
# Theme nur EINMAL übertragen und nur EINMAL auf den Cache gewartet
# werden muss. Die beiden Einzelskripte bleiben liegen, werden aber
# von diesem hier abgelöst — nicht zusätzlich ausführen.
#
# Teil A (Theme-Code, rsync — überträgt den kompletten Commit):
#   - assets/fcs-top-club-88.css -> assets/fcs-wine-info.css, erweitert
#     um Teamkacheln, Buttons, Schritte, Aufzählungen
#   - page-junioren-teams.php (NEU): Teamübersicht, Kacheln entstehen
#     automatisch aus den Unterseiten der Seite «Teams»
#   - page-fussball-tauschboerse.php (NEU)
#   - page-juniorenkonzept.php, page-schiedsrichter.php: neues Design,
#     Texte über die Feld-Box «Seiteninhalte»
#   - front-page.php: Hero führt wieder bis zu 5 Storys; Sponsoren-
#     balken unter dem Titelbild entfernt (auch auf den Teamseiten)
#   - footer.php: Newsletter-Spalte entfernt
#   - functions.php: Megamenü-Hülle .fcx-megas, Navigation um
#     Juniorenkonzept und Tauschbörse ergänzt
#   Hinweis: rsync läuft mit --delete — die alte Datei
#   assets/fcs-top-club-88.css verschwindet damit auch auf dem Server.
#
# Teil B (Datenbank, zwei token-geschützte PHP-Skripte im Webroot):
#   - Seite «Teams» (junioren/teams) -> Vorlage page-junioren-teams.php
#   - Seite «Tauschbörse» -> Vorlage page-fussball-tauschboerse.php
#   Beide ersetzen zusätzlich den Editor-Inhalt durch den Pflegehinweis
#   (der bisherige Inhalt wird vorher ins Protokoll geschrieben).
#   «Juniorenkonzept» und «Schiedsrichter» brauchen keine DB-Änderung:
#   ihre neuen Seitenfelder greifen auf Vorlagen-Defaults zurück.
#
# Idempotent: Ein zweiter Lauf meldet in Teil B «SKIP».
# Aufruf:  ./deploy/deploy-designstand.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
LIVE="https://fcschattdorf.dynalias.net"
THEME="wp-content/themes/fcschattdorf-child"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Trockenlauf Theme ────────────────────────────────────────────
log "1/7  Trockenlauf – was würde ans Theme übertragen?"
rsync -avzn --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -30

printf "\n\033[1;33mWeiter? Das überträgt den obigen Stand nach LIVE und ändert die Live-DB. [j/N] \033[0m"
read -r answer
[ "$answer" = "j" ] || [ "$answer" = "J" ] || { echo "Abgebrochen."; exit 0; }

# ── 2. Theme übertragen ─────────────────────────────────────────────
log "2/7  Theme übertragen (rsync)…"
rsync -avz --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -20

# ── 3./4. DB-Skripte: erst Probelauf, dann scharf ───────────────────
# $1 = Dateiname des Skripts (ohne Pfad), $2 = Klartext fürs Protokoll
db_schritt() {
  local phpname="$1" titel="$2" token antwort
  log "$titel – PROBELAUF (schreibt nichts)…"

  token="$(openssl rand -hex 24)"
  sed "s/__TOKEN__/${token}/" "deploy/${phpname}.tpl" > "deploy/${phpname}"
  scp -q "deploy/${phpname}" "$HOST:$WEBROOT/${phpname}"
  rm -f "deploy/${phpname}"

  curl -sS --max-time 120 "$LIVE/${phpname}?token=${token}&dry=1" | sed 's/^/      /'

  printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich schreiben? [j/N] \033[0m"
  read -r antwort
  if [ "$antwort" != "j" ] && [ "$antwort" != "J" ]; then
    echo "Übersprungen – räume das Skript vom Server…"
    ssh "$HOST" "rm -f $WEBROOT/${phpname}"
    return 0
  fi

  echo "    Schreibe…"
  curl -sS --max-time 120 "$LIVE/${phpname}?token=${token}" | sed 's/^/      /'

  # Reste entfernen, falls die Selbst-Löschung nicht griff.
  ssh "$HOST" "rm -f $WEBROOT/${phpname}"
  echo "    ${phpname} liefert HTTP $(curl -s -o /dev/null -w '%{http_code}' "$LIVE/${phpname}") (erwartet 404)"
}

log "3/7  DB: Seite «Teams» auf die neue Vorlage"
db_schritt "fcs-junioren-teams.php" "Teams"

log "4/7  DB: Seite «Tauschbörse» auf die neue Vorlage"
db_schritt "fcs-junioren-seiten.php" "Tauschbörse"

# ── 5. Aufräum-Kontrolle ────────────────────────────────────────────
log "5/7  Kontrolle: liegen noch Deploy-Skripte im Webroot?"
reste="$(ssh "$HOST" "ls $WEBROOT/fcs-*.php 2>/dev/null" || true)"
if [ -n "$reste" ]; then
  printf "\033[1;31m    ACHTUNG – diese Dateien liegen noch im Webroot:\033[0m\n%s\n" "$reste"
  echo "    Von Hand entfernen:  ssh $HOST 'rm -f $WEBROOT/fcs-*.php'"
else
  echo "    Webroot sauber."
fi

# ── 6. Cache abwarten ───────────────────────────────────────────────
log "6/7  Warte 60 s (Hostpoint-Seitencache), dann Seiten prüfen…"
sleep 60

# ── 7. Verifikation ─────────────────────────────────────────────────
log "7/7  Verifikation"
fehler=0

# $1=Pfad  $2=Marke, die vorkommen MUSS  $3=(optional) Marke, die FEHLEN muss
pruefe() {
  local pfad="$1" marke="$2" verboten="${3:-}" body code treffer weg
  body="$(curl -sS --max-time 60 "$LIVE$pfad")"
  code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE$pfad")"
  treffer="$(printf '%s' "$body" | grep -c "$marke" || true)"
  printf "    %-34s HTTP %s | «%s»: %s (erwartet >0)" "$pfad" "$code" "$marke" "$treffer"
  { [ "$code" = "200" ] && [ "$treffer" != "0" ]; } || fehler=1
  if [ -n "$verboten" ]; then
    weg="$(printf '%s' "$body" | grep -c "$verboten" || true)"
    printf " | «%s»: %s (erwartet 0)" "$verboten" "$weg"
    [ "$weg" = "0" ] || fehler=1
  fi
  printf "\n"
}

# Neue bzw. umgestellte Seiten
pruefe "/junioren/teams/"           "fctc-teamgrid"
pruefe "/junioren/tauschboerse/"    "fctc-steps"
pruefe "/junioren/juniorenkonzept/" "fctc-btn"
pruefe "/verein/schiedsrichter/"    "fcsr-referee-grid"

# Regression: Top-Club 88 nutzt dieselbe CSS-Datei und darf nicht brechen
pruefe "/sponsoren/top-club-88/"    "fctc-vorstand-grid"

# Startseite: Megamenü-Hülle da, Sponsorenbalken weg
pruefe "/"                          "fcx-megas"        "fcx-spbar"

# Teamseite: Sponsorenbalken unter dem Titelbild ebenfalls weg
pruefe "/aktive/1-mannschaft/"      "fc1m-ifv"         "fcx-spbar"

# Kachelanzahl der Teamübersicht (eine pro Unterseite)
kacheln="$(curl -sS --max-time 60 "$LIVE/junioren/teams/" | grep -c 'fctc-team__name' || true)"
echo "    Teamkacheln: $kacheln (lokal sind es 18 – Abweichung nur okay, wenn live andere Teamseiten bestehen)"
[ "$kacheln" != "0" ] || fehler=1

# Navigation: beide neuen Einträge im Junioren-Menü
nav="$(curl -sS --max-time 60 "$LIVE/")"
n1="$(printf '%s' "$nav" | grep -c 'junioren/juniorenkonzept' || true)"
n2="$(printf '%s' "$nav" | grep -c 'junioren/tauschboerse' || true)"
echo "    Navigation -> Juniorenkonzept: $n1 | Tauschbörse: $n2 (beide erwartet >0)"
{ [ "$n1" != "0" ] && [ "$n2" != "0" ]; } || fehler=1

# Alte CSS-Datei muss durch --delete verschwunden sein
alt="$(curl -s -o /dev/null -w '%{http_code}' "$LIVE/$THEME/assets/fcs-top-club-88.css")"
neu="$(curl -s -o /dev/null -w '%{http_code}' "$LIVE/$THEME/assets/fcs-wine-info.css")"
echo "    fcs-top-club-88.css: HTTP $alt (erwartet 404) | fcs-wine-info.css: HTTP $neu (erwartet 200)"
{ [ "$alt" = "404" ] && [ "$neu" = "200" ]; } || fehler=1

echo
if [ "$fehler" = "0" ]; then
  printf "\033[1;32mFertig – der Design-Stand läuft live, Top-Club 88 unverändert.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -s $LIVE/junioren/teams/ | grep -c fctc-teamgrid"
  exit 1
fi
