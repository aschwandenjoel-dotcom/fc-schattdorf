#!/usr/bin/env bash
# ====================================================================
# Deploy: Responsiv-Anpassungen Kontakt + Helfereinsätze (nur Theme)
#
# Kontakt (page-kontakt.php, assets/fcs-kontakt.css):
#   - Karte sitzt auf dem Handy mittig im weinroten Bereich statt oben
#   - E-Mail-Zeile bricht sauber am @ um, der Pfeil bleibt frei
#
# Helfereinsätze (page-helfereinsaetze.php, assets/fcs-helfereinsaetze.css):
#   - erster Bildschirm = Titel + Bild + Portal-Karte;
#     «Anleitung herunterladen» beginnt erst darunter
#
# Reine Code-Änderung, KEINE DB-Änderung. Cache-Busting der Stylesheets
# passiert automatisch über filemtime().
#
# WICHTIG: Der Live-Theme-Code kann neuer sein als der lokale Stand
# (zweiter Entwickler). Schritt 1 ist deshalb ein Trockenlauf inkl.
# Gegenrichtung — was dort unter «nur live vorhanden» auftaucht, würde
# --delete entfernen. Erst prüfen, dann bestätigen.
#
# Aufruf:  ./deploy/deploy-responsiv-kontakt-helfer.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
THEME="wp-content/themes/fcschattdorf-child"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 1. Trockenlauf: was ginge raus, was käme weg? ───────────────────
log "1/4  Trockenlauf – was würde ans Theme übertragen (bzw. gelöscht)?"
rsync -avzn --delete --itemize-changes --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | grep -v '^$' | tail -30

log "     Gegenprobe – Unterschiede live -> lokal (nur Anzeige):"
rsync -avzn --itemize-changes --exclude '.DS_Store' \
  "$HOST:$WEBROOT/$THEME/" "$THEME/" | grep '^[<>ch]' | tail -20 \
  || echo "     (keine)"

printf "\n\033[1;33mWeiter? Das überträgt den lokalen Stand nach LIVE und löscht dort Fremdes. [j/N] \033[0m"
read -r answer
[ "$answer" = "j" ] || [ "$answer" = "J" ] || { echo "Abgebrochen."; exit 0; }

# ── 2. Übertragen ───────────────────────────────────────────────────
log "2/4  Theme übertragen (rsync)…"
rsync -avz --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -15

# ── 3. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "3/4  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 4. Verifikation ─────────────────────────────────────────────────
log "4/4  Seiten prüfen…"
ok=1

pruefe() { # $1 Pfad, $2 Suchmuster, $3 Beschreibung
  local body code treffer
  body="$(lcurl -sSL --max-time 60 "$LIVE$1")"
  code="$(lcurl -sSL -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE$1")"
  treffer="$(printf '%s' "$body" | grep -c "$2" || true)"
  echo "    $1  HTTP $code | $3: $treffer (erwartet >0)"
  [ "$code" = "200" ] && [ "$treffer" != "0" ] || ok=0
}

pruefe "/kontakt/"          'fck-row__value' "E-Mail-Zeile"
pruefe "/helfereinsaetze/"  'fche-screen'    "Erster-Bildschirm-Kasten"

# Stylesheets: kommen sie mit frischem Zeitstempel (Cache-Busting)?
for css in fcs-kontakt fcs-helfereinsaetze; do
  ver="$(lcurl -sSL --max-time 60 "$LIVE/kontakt/" "$LIVE/helfereinsaetze/" \
        | grep -o "${css}\.css?ver=[0-9]*" | head -1)"
  echo "    Stylesheet: ${ver:-NICHT GEFUNDEN}"
  [ -n "$ver" ] || ok=0
done

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – beide Seiten sind live mit dem neuen Stand.\033[0m\n"
  echo "  Sichtprüfung am Handy: Kontakt (Karte mittig, Pfeil frei) und"
  echo "  Helfereinsätze (Download-Block erst nach dem Scrollen sichtbar)."
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen:"
  echo "  curl -sL $LIVE/helfereinsaetze/ | grep -c fche-screen"
  exit 1
fi
