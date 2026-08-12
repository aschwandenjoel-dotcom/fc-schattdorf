#!/usr/bin/env bash
# ====================================================================
# Theme-Code von live ins Repo holen (Hostpoint -> lokal)
# --------------------------------------------------------------------
# WARUM: Am 12.08.2026 wich der Live-Stand des Child-Themes in 16 von
# 25 CSS-Dateien vom Repo ab — in BEIDE Richtungen. Live enthielt Arbeit,
# die nie ins Repo zurückkam (z. B. die Focus-Fixes in
# fcs-1mannschaft.css, der neue Creme-Kopf samt Zwei-Block-Aufbau in
# fcs-helfereinsaetze.css), das Repo enthielt Dateien, die live fehlen
# (fcs-top-club-88.css ist live 404).
#
# Ein Deploy aus dem Repo (rsync --delete) hätte die Live-Arbeit
# gelöscht. Deshalb gilt: ERST dieses Skript, dann committen, dann
# Änderungen darauf aufbauen, dann deployen.
#
# Bewusst OHNE --delete: lokale Dateien, die live fehlen, werden nicht
# gelöscht, sondern am Ende nur aufgelistet. Ob sie noch gebraucht
# werden, entscheidest du.
#
# Aufruf:  ./scripts/pull-theme-live.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
THEME="wp-content/themes/fcschattdorf-child"

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# ── 0. Sauberer Arbeitsbaum? ────────────────────────────────────────
log "0/4  Git-Zustand prüfen…"
if ! git diff --quiet -- "$THEME" || ! git diff --cached --quiet -- "$THEME"; then
  echo "WARNUNG: Im Theme liegen uncommittete Änderungen:" >&2
  git status --short -- "$THEME" >&2
  cat >&2 <<'EOF'

Der Pull überschreibt sie mit dem Live-Stand. Erst committen oder
sichern (git stash), danach dieses Skript erneut aufrufen.
EOF
  printf "\n\033[1;33mTrotzdem weiter und lokale Änderungen überschreiben? [j/N] \033[0m"
  read -r a; [ "$a" = "j" ] || [ "$a" = "J" ] || { echo "Abgebrochen."; exit 0; }
fi

# ── 1. Trockenlauf ──────────────────────────────────────────────────
log "1/4  Trockenlauf – was würde live ins Repo übernehmen?"
rsync -avzn --exclude '.DS_Store' \
  "$HOST:$WEBROOT/$THEME/" "$THEME/" | tail -40

printf "\n\033[1;33mDiese Dateien ins Repo übernehmen? [j/N] \033[0m"
read -r answer
[ "$answer" = "j" ] || [ "$answer" = "J" ] || { echo "Abgebrochen."; exit 0; }

# ── 2. Übernehmen ───────────────────────────────────────────────────
log "2/4  Live-Stand ins Repo holen (ohne --delete)…"
rsync -avz --exclude '.DS_Store' \
  "$HOST:$WEBROOT/$THEME/" "$THEME/" | tail -20

# ── 3. Nur lokal vorhandene Dateien melden ──────────────────────────
log "3/4  Dateien, die es NUR lokal gibt (live nicht vorhanden)…"
rsync -avzn --delete --exclude '.DS_Store' \
  "$THEME/" "$HOST:$WEBROOT/$THEME/" 2>/dev/null \
  | grep -E "^deleting " | sed 's/^deleting /    nur lokal:  /' || echo "    keine"
echo "    (nichts davon wurde gelöscht — bitte selbst entscheiden, ob noch gebraucht)"

# ── 4. Ergebnis ─────────────────────────────────────────────────────
log "4/4  Was hat sich im Repo geändert?"
git status --short -- "$THEME"
echo
echo "Nächste Schritte:"
echo "  1. Änderungen durchsehen:  git diff -- $THEME"
echo "  2. Live-Stand festhalten:  git add $THEME && git commit -m 'sync: Live-Stand des Themes ins Repo übernommen'"
echo "  3. Erst danach neue Änderungen darauf aufbauen und deployen."
