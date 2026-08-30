#!/usr/bin/env bash
# ====================================================================
# Deploy: drei Darstellungsfehler auf grossen Bildschirmen
# --------------------------------------------------------------------
# Alle drei fielen erst auf einem externen Monitor auf, auf dem Laptop
# nicht — deshalb hier zusammen.
#
# 1) assets/fcs-1mannschaft.css  «.fc1m-photo img»
#    Die Hoehe war bei 620px gedeckelt, waehrend die Breite weiter wuchs.
#    Die Box wurde also immer flacher und schnitt mehr vom Teamfoto weg:
#    35 % bei 1440px, 52 % bei 1920px, 64 % bei 2560px. Jetzt ein festes
#    Verhaeltnis 100/44 (exakt das bisherige 44vw, nur ohne Deckel), damit
#    auf jedem Schirm derselbe Anblick entsteht wie auf dem Laptop.
#    Betrifft alle Teamseiten: Aktive, Frauen, Senioren, 18 Junioren-Teams.
#
# 2) page-vorstand.php  Filter auf «wp_calculate_image_sizes»
#    Die Portraits stehen als «medium» (200 px) im Editor-Inhalt, WordPress
#    schrieb sizes="… 200px". Auf Retina-Laptops laedt der Browser dank
#    2x-Rechnung die 683-px-Datei, auf einem Monitor mit DPR 1 aber die
#    200-px-Datei — auf der 375 px breiten Karte sichtbar unscharf.
#
# 3) page-helfereinsaetze.php  body_class «fcx-wine-page»
#    Astra streckt #content auf grossen Schirmen (#page{min-height:100vh}
#    + #page .site-content{flex-grow:1}). Diese kurze Seite liess dadurch
#    einen hellen Streifen ueber dem Footer stehen. Die Schwesterseiten
#    faerben diese Flaeche ueber genau diese Body-Klasse ein; hier fehlte
#    sie als einziger Seite dieser Familie.
#
# Nur Theme-Code, die Datenbank wird NICHT angefasst.
#
# Aufruf:  ./deploy/deploy-monitor-fixes.sh
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
fail=0
check() { if [ "$2" -eq 0 ]; then printf "    \033[1;32mOK\033[0m      %s\n" "$1"; else printf "    \033[1;31mFEHLER\033[0m  %s\n" "$1"; fail=1; fi; }

css_block() { awk '/^\.fc1m-photo img[[:space:]]*\{/,/\}/'; }

# Textsuche ohne Pipe. Bewusst NICHT «printf … | grep -q»: grep -q endet
# beim ersten Treffer, der Schreiber davor bekommt SIGPIPE, und pipefail
# macht aus dem Treffer einen Fehlschlag — je nachdem, wie frueh die
# Fundstelle im Dokument steht. Genau daran meldete die Verifikation am
# 30.08.2026 einen funktionierenden Fix als fehlend.
enthaelt() { case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac; }

# ── 0. Sind die drei Aenderungen lokal ueberhaupt drin? ─────────────
log "0/5  Lokale Aenderungen pruefen…"
BLOCK="$(css_block < "$THEME/$CSS")"
printf '%s\n' "$BLOCK" | sed 's/^/      /'
# Bewusst durchgehend if/else statt «cmd; check … $?»: unter set -e wuerde
# ein nicht findendes grep das Skript abbrechen, statt FEHLER zu melden.
if enthaelt "$BLOCK" "aspect-ratio: 100 / 44"
  then check "1) Titelbild: festes Verhaeltnis gesetzt" 0; else check "1) Titelbild: aspect-ratio fehlt" 1; fi
if enthaelt "$BLOCK" "clamp("
  then check "1) Titelbild: alte gedeckelte Hoehe steht noch drin" 1; else check "1) Titelbild: alte gedeckelte Hoehe entfernt" 0; fi
if grep -q "wp_calculate_image_sizes" "$THEME/page-vorstand.php"
  then check "2) Vorstand: sizes-Filter vorhanden" 0; else check "2) Vorstand: sizes-Filter fehlt" 1; fi
if grep -q "fcx-wine-page" "$THEME/page-helfereinsaetze.php"
  then check "3) Helfereinsaetze: body_class vorhanden" 0; else check "3) Helfereinsaetze: body_class fehlt" 1; fi
[ "$fail" -eq 0 ] || { echo "ABBRUCH: lokale Aenderungen unvollstaendig." >&2; exit 1; }

# ── 0b. Schutz gegen Ueberschreiben von Live-Arbeit ─────────────────
# Der Deploy laeuft mit rsync --delete. Weicht live an anderer Stelle ab,
# wuerde er dort fremde Arbeit loeschen (am 12.08.2026 wichen 16 von 25
# CSS-Dateien ab). Pruefbar sind nur CSS-Dateien — PHP-Templates liefert
# der Server nicht aus. Bei Abweichung erst ./scripts/pull-theme-live.sh.
log "0b/5  Abgleich mit live (Schutz gegen Ueberschreiben fremder Arbeit)…"
abw=0
for f in "$THEME"/assets/*.css "$THEME"/style.css; do
  rel="${f#"$THEME"/}"
  tmp="$(mktemp)"
  code="$(lcurl -sS -o "$tmp" -w '%{http_code}' --max-time 30 "$LIVE/$THEME/$rel")"
  if [ "$code" != "200" ]; then
    printf "    \033[1;33m?\033[0m  %-32s live HTTP %s (nur lokal vorhanden)\n" "$rel" "$code"; abw=1
  elif ! diff -q "$f" "$tmp" >/dev/null 2>&1; then
    if [ "$rel" = "$CSS" ]; then
      printf "    \033[1;32mok\033[0m %-32s die beabsichtigte Aenderung\n" "$rel"
    else
      printf "    \033[1;31m!!\033[0m %-32s weicht ab – live hat einen anderen Stand\n" "$rel"; abw=1
    fi
  fi
  rm -f "$tmp"
done
if [ "$abw" -ne 0 ]; then
  cat >&2 <<'EOF'

ABBRUCH: Der Live-Stand weicht an Stellen ab, die dieser Deploy nicht
aendern soll. Ein Deploy wuerde diese Arbeit loeschen.

  1. ./scripts/pull-theme-live.sh      Live-Stand ins Repo holen
  2. git add … && git commit           Live-Stand festhalten
  3. Aenderungen neu aufsetzen, dann diesen Deploy erneut starten.
EOF
  exit 1
fi

# ── 1. Trockenlauf ──────────────────────────────────────────────────
log "1/5  Trockenlauf – was wuerde uebertragen?"
rsync -avzn --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -25

printf "\n\033[1;33mWeiter? Das uebertraegt den obigen Stand nach LIVE. [j/N] \033[0m"
read -r answer
[ "$answer" = "j" ] || [ "$answer" = "J" ] || { echo "Abgebrochen."; exit 0; }

# ── 2. Theme uebertragen ────────────────────────────────────────────
# Cache-Busting laeuft ueber filemtime in den Templates, kein Extraschritt.
log "2/5  Theme uebertragen (rsync)…"
rsync -avz --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -15

# ── 3. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "3/5  60 s warten (Hostpoint-Seitencache), sonst Fehlalarme…"
sleep 60

# ── 4. Erreichbarkeit: faengt PHP-Fehler ab ─────────────────────────
# Ein Syntaxfehler in den beiden Templates zeigt sich hier als 500.
log "4/5  Laden die betroffenen Seiten noch?"
fail=0
# -L folgt Weiterleitungen: die Aktivteams liegen unter /aktive/…, ein
# Aufruf der alten Adresse antwortet mit 301. Gewertet wird der Code am
# Ende der Kette, sonst meldet der Check eine funktionierende Seite als
# Fehler (passiert am 30.08.2026).
for slug in aktive/1-mannschaft aktive/2-mannschaft aktive/3-mannschaft \
            junioren/teams/junioren-a-junioren \
            junioren/teams/team-uri-ff11 \
            verein/vorstand helfereinsaetze; do
  code="$(lcurl -sS -L -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE/$slug/")"
  if [ "$code" = "200" ]; then check "/$slug/ (HTTP $code)" 0; else check "/$slug/ (HTTP $code)" 1; fi
done

# ── 5. Wirken die drei Aenderungen live? ────────────────────────────
log "5/5  Verifikation der drei Fixes"

LIVEBLOCK="$(lcurl -sS --max-time 60 "$LIVE/$THEME/$CSS" | css_block)"
if enthaelt "$LIVEBLOCK" "aspect-ratio"
  then check "1) Titelbild: neues Verhaeltnis ist live" 0; else check "1) Titelbild: neues Verhaeltnis fehlt live" 1; fi
if enthaelt "$LIVEBLOCK" "clamp("
  then check "1) Titelbild: alter Zuschnitt steht noch live" 1; else check "1) Titelbild: alter Zuschnitt ist live verschwunden" 0; fi

# Antwort erst in eine Variable, dann pruefen — NICHT «curl | grep -q»:
# grep -q endet beim ersten Treffer, curl kann dann nicht mehr in die Pipe
# schreiben (Fehler 56) und pipefail macht aus dem Treffer einen
# Fehlschlag. Genau das meldete am 30.08.2026 funktionierende Fixes als
# fehlend.
VORSTAND="$(lcurl -sS -L --max-time 60 "$LIVE/verein/vorstand/")"
if enthaelt "$VORSTAND" "45vw, 375px"
  then check "2) Vorstand: korrigiertes sizes wird ausgeliefert" 0; else check "2) Vorstand: sizes unveraendert" 1; fi

HELFER="$(lcurl -sS -L --max-time 60 "$LIVE/helfereinsaetze/")"
if enthaelt "$HELFER" "fcx-wine-page"
  then check "3) Helfereinsaetze: body-Klasse fcx-wine-page ist gesetzt" 0; else check "3) Helfereinsaetze: body-Klasse fehlt" 1; fi

echo
if [ "$fail" -eq 0 ]; then
  printf "\033[1;32m==> Deploy erfolgreich.\033[0m\n"
  echo "    Im Browser mit Shift-Reload pruefen (lokaler CSS-Cache)."
  echo "    Am besten auf dem externen Monitor — dort waren alle drei sichtbar."
else
  printf "\033[1;31m==> Deploy mit Auffaelligkeiten – bitte oben pruefen.\033[0m\n"
  exit 1
fi
