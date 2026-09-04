#!/usr/bin/env bash
# ====================================================================
# Deploy: Trainingslager-Seite (Fotos 2026, Galerie, Hero) -> Hostpoint
#
# Deployt ausschliesslich Theme-Code. Die 60 Fotos liegen im Theme
# (assets/img/tl/) und reisen deshalb mit dem rsync mit — es braucht
# KEINEN separaten Upload nach wp-content/uploads/.
#
# Die Datenbank wird NICHT angefasst. Falls die Live-Seite im Flyer-
# Abschnitt noch das alte Mannschaftsfoto zeigt, siehe Schritt 3 unten
# (ein Feld im WP-Backend leeren, kein DB-Skript nötig).
#
# Aufruf:  ./deploy/deploy-trainingslager.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
THEME="wp-content/themes/fcschattdorf-child"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Vorschau: was würde sich ändern? ─────────────────────────────
log "1/4  Trockenlauf – was würde übertragen?"
rsync -avzn --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -25

printf "\n\033[1;33mWeiter? Das überträgt den obigen Stand nach LIVE. [j/N] \033[0m"
read -r answer
[ "$answer" = "j" ] || [ "$answer" = "J" ] || { echo "Abgebrochen."; exit 0; }

# ── 2. Theme übertragen ─────────────────────────────────────────────
# --delete entfernt live auch Dateien, die es lokal nicht mehr gibt
# (z. B. die entfernte fcs-footer.css). Cache-Busting läuft über
# filemtime in den Templates, es ist kein weiterer Schritt nötig.
log "2/4  Theme übertragen (rsync)…"
rsync -avz --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -15

# ── 3. Verifizieren ─────────────────────────────────────────────────
log "3/4  Warte 60 s (Hostpoint-Seitencache), dann prüfen…"
sleep 60

URL="$LIVE/junioren/trainingslager/"
BODY="$(lcurl -sS --max-time 60 "$URL")"
CODE="$(lcurl -sS -o /dev/null -w '%{http_code}' --max-time 60 "$URL")"

echo "    Seite:            HTTP $CODE"
echo "    Galerie-Bilder:   $(printf '%s' "$BODY" | grep -c 'class="tl-gal-item"')  (erwartet 24)"
echo "    Campus-Fotos:     $(printf '%s' "$BODY" | grep -c 'tl-campus-card__photo')  (erwartet 6)"
echo "    Fakten-Leiste:    $(printf '%s' "$BODY" | grep -c 'tl-facts')  (erwartet 1)"
echo "    PHP-Warnungen:    $(printf '%s' "$BODY" | grep -c 'Warning:\|Fatal error')  (erwartet 0)"

log "4/4  Stichprobe: liefern die Bilder aus?"
fail=0
for f in tl26-hero.jpg tl26-flyer.jpg tl26-campus-unterkunft.jpg tl26-gal-01.jpg tl26-gal-24-lg.jpg; do
  c="$(lcurl -sS -o /dev/null -w '%{http_code}' --max-time 60 \
       "$LIVE/$THEME/assets/img/tl/$f")"
  if [ "$c" = "200" ]; then echo "    OK   $f"; else echo "    FEHLER $f -> HTTP $c"; fail=1; fi
done

if [ "$fail" = "0" ] && [ "$CODE" = "200" ]; then
  printf "\n\033[1;32mDeploy erfolgreich.\033[0m\n"
else
  printf "\n\033[1;31mDeploy mit Auffälligkeiten – bitte oben prüfen.\033[0m\n"; exit 1
fi

cat <<EOF

  NOCH EIN SCHRITT VON HAND — ohne ihn bleibt der alte Flyer stehen:

  Auf der Live-Seite ist das Seitenfeld «Flyer: Bild» gefüllt (geprüft:
  zeigt IMG_8904.jpg, das Mannschaftsfoto). Ein gesetztes Feld schlägt
  den Standard aus der Vorlage — der Save-the-Date-Flyer erscheint erst,
  wenn das Feld leer ist:

    wp-admin -> Seiten -> Trainingslager -> Box «Seiteninhalte»
    -> Feld «Flyer: Bild (URL aus der Mediathek)» leeren -> Aktualisieren

  Gegenprobe danach (nach ~60 s wegen Seitencache):
    curl -s $LIVE/junioren/trainingslager/ \
      | grep -o 'tl26-flyer.jpg\|IMG_8904.jpg' | sort -u

EOF
