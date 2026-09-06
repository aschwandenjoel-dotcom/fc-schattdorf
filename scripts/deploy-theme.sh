#!/usr/bin/env bash
# ====================================================================
# Theme-Code ins Live-System übertragen (Repo -> Hostpoint)
# --------------------------------------------------------------------
# Das Gegenstück zu pull-theme-live.sh. Bisher baute jedes Deploy-Skript
# in deploy/ seinen eigenen rsync nach — dieses Skript bündelt den
# Vorgang für alle Fälle, in denen NUR Theme-Code ausgeliefert werden
# soll (kein DB-Teil, keine neuen Uploads).
#
# WARUM MIT VORSICHT: Am 12.08.2026 wich der Live-Stand in 16 von 25
# CSS-Dateien vom Repo ab — in BEIDE Richtungen. Live enthielt Arbeit,
# die nie ins Repo zurückkam. Ein rsync --delete aus dem Repo hätte sie
# gelöscht. Schritt 1 macht deshalb zuerst die Gegenprobe live -> lokal
# und zeigt, was dabei verloren ginge; erst danach wird gefragt.
#
# Cache-Busting der Stylesheets passiert automatisch über filemtime().
#
# Ablauf:
#   0. Git-Zustand prüfen (uncommittete Theme-Änderungen melden)
#   1. Gegenprobe live -> lokal: was hat live, das das Repo nicht hat?
#   2. Trockenlauf Repo -> live inkl. --delete, dann Rückfrage
#   3. Übertragen
#   4. 60 s warten (Hostpoint-Seitencache)
#   5. Prüfen: jede CSS- und JS-Datei live gegen das Repo, dazu ein paar
#      Seitenaufrufe
#
# Aufruf:  ./scripts/deploy-theme.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
THEME="wp-content/themes/fcschattdorf-child"
# Setzt $LIVE und lcurl(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }
frage() { printf "\n\033[1;33m%s [j/N] \033[0m" "$1"; read -r a; [ "$a" = "j" ] || [ "$a" = "J" ]; }

# ── 0. Git-Zustand ──────────────────────────────────────────────────
log "0/5  Git-Zustand prüfen…"
if ! git diff --quiet -- "$THEME" || ! git diff --cached --quiet -- "$THEME"; then
  echo "    HINWEIS: uncommittete Theme-Änderungen —"
  git status --short -- "$THEME" | sed 's/^/      /'
  echo "    Sie gehen mit raus. Nach dem Deploy committen, sonst weiss"
  echo "    später niemand, was live steht."
else
  echo "    sauber ($(git log --oneline -1 --format='%h %s' -- "$THEME"))"
fi

# ── 1. Gegenprobe: was hat live, das das Repo nicht hat? ────────────
log "1/5  Gegenprobe live -> lokal (nur Anzeige, nichts wird geholt)…"
gegen="$(rsync -avzn --itemize-changes --exclude '.DS_Store' \
  "$HOST:$WEBROOT/$THEME/" "$THEME/" 2>/dev/null | grep -E '^[<>ch]f' || true)"
if [ -n "$gegen" ]; then
  echo "$gegen" | sed 's/^/    /'
  echo
  echo "    Diese Dateien sind live neuer oder anders als im Repo. Der"
  echo "    Deploy überschreibt sie. Im Zweifel zuerst abbrechen und"
  echo "    ./scripts/pull-theme-live.sh laufen lassen."
else
  echo "    keine — live entspricht dem Repo oder ist älter."
fi

weg="$(rsync -avzn --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" 2>/dev/null | grep -E '^deleting ' || true)"
if [ -n "$weg" ]; then
  echo
  echo "    Der Deploy LÖSCHT live ausserdem:"
  echo "$weg" | sed 's/^deleting /      /'
fi

# ── 2. Trockenlauf Repo -> live ─────────────────────────────────────
log "2/5  Trockenlauf – was würde übertragen?"
rsync -avzn --delete --itemize-changes --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | grep -vE '^(sending|sent |total )' | tail -30

frage "Weiter? Das überträgt den Repo-Stand nach LIVE und löscht dort Fremdes." \
  || { echo "Abgebrochen."; exit 0; }

# ── 3. Übertragen ───────────────────────────────────────────────────
log "3/5  Theme übertragen…"
rsync -avz --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" | tail -15

# ── 4. Warten ───────────────────────────────────────────────────────
log "4/5  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 5. Prüfen ───────────────────────────────────────────────────────
log "5/5  Live gegen Repo prüfen…"
ok=1

# 5a) Jede CSS- und JS-Datei byteweise vergleichen. Genau so wurde am
#     29.08.2026 festgestellt, dass der Live-Stand wirklich passt.
anz=0; schlecht=0
while IFS= read -r datei; do
  rel="${datei#$THEME/}"
  anz=$((anz+1))
  lokal="$(shasum -a 256 "$datei" | cut -d' ' -f1)"
  live="$(lcurl -sS --max-time 45 "$LIVE/$THEME/$rel" | shasum -a 256 | cut -d' ' -f1)"
  if [ "$lokal" != "$live" ]; then
    printf "    FEHL %s\n" "$rel"; schlecht=$((schlecht+1)); ok=0
  fi
done < <(find "$THEME/assets" -maxdepth 1 -type f \( -name '*.css' -o -name '*.js' \) | sort)
if [ "$schlecht" = "0" ]; then
  echo "    OK   alle $anz CSS-/JS-Dateien live byteidentisch mit dem Repo"
fi

# 5b) Ein paar Seiten müssen weiterhin antworten.
for pfad in / /news/ /aktive/1-mannschaft/ /junioren/teams/ /verein/vorstand/; do
  code="$(lcurl -sSL -o /dev/null -w '%{http_code}' --max-time 60 "$LIVE$pfad")"
  if [ "$code" = "200" ]; then
    printf "    OK   %s\n" "$pfad"
  else
    printf "    FEHL %s liefert HTTP %s\n" "$pfad" "$code"; ok=0
  fi
done

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – der Live-Stand des Themes entspricht dem Repo.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER die Prüfung passt nicht.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  echo "  Einzelne Datei vergleichen:"
  echo "    lcurl -sS \"\$LIVE/$THEME/assets/<datei>\" | shasum -a 256"
  exit 1
fi
