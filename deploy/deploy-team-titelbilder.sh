#!/usr/bin/env bash
# ====================================================================
# Deploy: Titelbilder der Teamseiten nicht mehr beschneiden
# --------------------------------------------------------------------
# Änderung: assets/fcs-1mannschaft.css, Regel «.fc1m-photo img».
#
# Vorher   height: clamp(300px, 44vw, 620px) + object-fit: cover
#          -> flache Box, das Foto wurde oben und unten weggeschnitten:
#             1440 px Fensterbreite = 35 %, 1920 px = 52 % der Bildhöhe.
# Nachher  height: auto
#          -> jedes Foto behält sein eigenes Seitenverhältnis und ist
#             komplett sichtbar. Nötig, weil die Fotos unterschiedliche
#             Verhältnisse haben (Aktive 1.50, Junioren 1.32–1.71).
#
# Betrifft alle Teamseiten, die fcs-1mannschaft.css laden: 1./2./3.
# Mannschaft, Frauen Uri I+II, Senioren Uri I und die 18 Junioren-Teams.
#
# Nur Theme-Code, die Datenbank wird NICHT angefasst.
#
# Aufruf:  ./deploy/deploy-team-titelbilder.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
THEME="wp-content/themes/fcschattdorf-child"
CSS="assets/fcs-1mannschaft.css"

# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 0. Lokale Vorprüfung ────────────────────────────────────────────
# Geprüft wird der Regelblock selbst, nicht die ganze Datei: die alte
# Höhe ist im erklärenden Kommentar bewusst noch erwähnt.
css_block() { awk '/^\.fc1m-photo img[[:space:]]*\{/,/\}/'; }

log "0/4  Lokale Änderung prüfen…"
BLOCK="$(css_block < "$THEME/$CSS")"
printf '%s\n' "$BLOCK" | sed 's/^/    /'
if ! printf '%s' "$BLOCK" | grep -q "height:[[:space:]]*auto"; then
  echo "FEHLER: «height: auto» fehlt in .fc1m-photo img — nichts zu deployen." >&2
  exit 1
fi
if printf '%s' "$BLOCK" | grep -qE "clamp|object-fit"; then
  echo "FEHLER: alter Zuschnitt (clamp/object-fit) steht noch im Regelblock." >&2
  exit 1
fi

# ── 0b. Schutz gegen Überschreiben von Live-Arbeit ──────────────────
# Der Deploy läuft mit rsync --delete. Weicht live an anderer Stelle ab,
# würde er dort fremde Arbeit löschen (genau die Lage am 12.08.2026:
# 16 von 25 CSS-Dateien wichen ab). Deshalb hier ein Abgleich über
# HTTPS. Achtung: prüfbar sind nur die CSS-Dateien — PHP-Templates
# liefert der Server nicht aus. Bei Abweichung erst
# ./scripts/pull-theme-live.sh laufen lassen.
log "0b/4  Abgleich mit live (Schutz gegen Überschreiben fremder Arbeit)…"
abw=0
for f in "$THEME"/assets/*.css "$THEME"/style.css; do
  rel="${f#"$THEME"/}"
  tmp="$(mktemp)"
  code="$(lcurl -sS -o "$tmp" -w '%{http_code}' --max-time 30 "$LIVE/$THEME/$rel")"
  if [ "$code" != "200" ]; then
    printf "    \033[1;33m?\033[0m  %-32s live HTTP %s (nur lokal vorhanden)\n" "$rel" "$code"; abw=1
  elif ! diff -q "$f" "$tmp" >/dev/null 2>&1; then
    if [ "$rel" = "$CSS" ]; then
      printf "    \033[1;32mok\033[0m %-32s die beabsichtigte Änderung\n" "$rel"
    else
      printf "    \033[1;31m!!\033[0m %-32s weicht ab – live hat einen anderen Stand\n" "$rel"; abw=1
    fi
  fi
  rm -f "$tmp"
done
if [ "$abw" -ne 0 ]; then
  cat >&2 <<'EOF'

ABBRUCH: Der Live-Stand weicht an Stellen ab, die dieser Deploy nicht
ändern soll. Ein Deploy würde diese Arbeit löschen.

  1. ./scripts/pull-theme-live.sh      Live-Stand ins Repo holen
  2. git add … && git commit          Live-Stand festhalten
  3. Änderung neu aufsetzen, dann diesen Deploy erneut starten.
EOF
  exit 1
fi

# ── 1. Trockenlauf ──────────────────────────────────────────────────
log "1/4  Trockenlauf – was würde übertragen?"
rsync -avzn --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -25

printf "\n\033[1;33mWeiter? Das überträgt den obigen Stand nach LIVE. [j/N] \033[0m"
read -r answer
[ "$answer" = "j" ] || [ "$answer" = "J" ] || { echo "Abgebrochen."; exit 0; }

# ── 2. Theme übertragen ─────────────────────────────────────────────
# Cache-Busting läuft über filemtime in den Templates, kein Extraschritt.
log "2/4  Theme übertragen (rsync)…"
rsync -avz --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -15

# ── 3. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "3/4  60 s warten (Hostpoint-Seitencache), sonst Fehlalarme…"
sleep 60

# ── 4. Verifikation ─────────────────────────────────────────────────
log "4/4  Verifikation"
fail=0
check() { if [ "$2" -eq 0 ]; then echo "    OK      $1"; else echo "    FEHLER  $1"; fail=1; fi }

# Liefert Hostpoint das neue CSS aus?
LIVEBLOCK="$(lcurl -sS --max-time 60 "$LIVE/$THEME/$CSS" | css_block)"

printf '%s' "$LIVEBLOCK" | grep -q "height:[[:space:]]*auto"
check "live gilt «.fc1m-photo img { height: auto }»" $?

printf '%s' "$LIVEBLOCK" | grep -qE "clamp|object-fit"
[ $? -ne 0 ]; check "alter Zuschnitt (clamp/object-fit) ist live verschwunden" $?

# Laden die Teamseiten noch fehlerfrei?
for slug in 1-mannschaft 2-mannschaft 3-mannschaft \
            junioren/teams/junioren-a-junioren \
            junioren/teams/junioren-f-junioren \
            junioren/teams/team-uri-ff11; do
  code="$(lcurl -sS -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE/$slug/")"
  [ "$code" = "200" ]; check "/$slug/ lädt (HTTP $code)" $?
done

echo
if [ "$fail" -eq 0 ]; then
  printf "\033[1;32m==> Deploy erfolgreich. Titelbilder werden vollständig gezeigt.\033[0m\n"
  echo "    Im Browser mit Shift-Reload prüfen (lokaler CSS-Cache)."
else
  printf "\033[1;31m==> Deploy mit Auffälligkeiten – bitte oben prüfen.\033[0m\n"
  exit 1
fi
