#!/usr/bin/env bash
# ====================================================================
# FC Schattdorf – Automatisches WordPress-Setup (lokal, via Docker)
# --------------------------------------------------------------------
# Installiert WordPress, Theme, Plugins und die komplette
# Seitenstruktur. Das Skript ist "idempotent": mehrfaches Ausführen
# schadet nicht.
# ====================================================================
set -euo pipefail

# In das Projektverzeichnis wechseln (egal von wo gestartet)
cd "$(dirname "$0")/.."

# .env laden
if [ -f .env ]; then
  set -a; . ./.env; set +a
else
  echo "FEHLER: .env fehlt." >&2; exit 1
fi

# Kurz-Helfer für WP-CLI-Befehle im Container
wpc() { docker compose run --rm -T wpcli wp "$@"; }

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# --------------------------------------------------------------------
log "Container starten (db, wordpress, adminer)…"
docker compose up -d db wordpress adminer

# --------------------------------------------------------------------
log "Warte, bis die WordPress-Dateien bereit sind…"
ready=0
for _ in $(seq 1 60); do
  if wpc core version >/dev/null 2>&1; then ready=1; break; fi
  printf "."; sleep 3
done
[ "$ready" = "1" ] || { echo; echo "FEHLER: WordPress wurde nicht rechtzeitig bereit." >&2; exit 1; }
echo

# --------------------------------------------------------------------
log "Warte, bis die Datenbank Verbindungen annimmt…"
ready=0
for _ in $(seq 1 60); do
  # "core is-installed" liefert exit 1 sowohl wenn WP noch nicht installiert
  # ist (DB aber erreichbar) als auch wenn die DB nicht erreichbar ist –
  # daher an der Fehlermeldung unterscheiden statt am Exit-Code.
  out=$(wpc core is-installed 2>&1) || true
  # Mustersuche ohne Pipe: «echo … | grep -q» wertet mit pipefail einen
  # Treffer als Fehlschlag, sobald grep -q vor dem Schreiber endet.
  case "$out" in
    *"Error establishing a database connection"*) ;;   # DB noch nicht bereit
    *) ready=1; break ;;
  esac
  printf "."; sleep 3
done
[ "$ready" = "1" ] || { echo; echo "FEHLER: Datenbank wurde nicht rechtzeitig bereit." >&2; exit 1; }
echo

# --------------------------------------------------------------------
log "WordPress installieren…"
if wpc core is-installed >/dev/null 2>&1; then
  echo "Bereits installiert – überspringe."
else
  wpc core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email
fi

# --------------------------------------------------------------------
log "Sprache auf Deutsch (de_DE) setzen…"
wpc language core install de_DE --activate >/dev/null 2>&1 || true
wpc option update WPLANG de_DE >/dev/null 2>&1 || true
wpc option update timezone_string "Europe/Zurich" >/dev/null
wpc option update date_format "d.m.Y" >/dev/null
wpc option update blogdescription "Fussballclub Schattdorf" >/dev/null

# --------------------------------------------------------------------
log "Theme installieren (Astra) + Child-Theme aktivieren…"
wpc theme is-installed astra >/dev/null 2>&1 || wpc theme install astra
# Child-Theme liegt bereits im gemounteten Ordner -> nur aktivieren
wpc theme activate fcschattdorf-child

# --------------------------------------------------------------------
log "Plugins installieren & aktivieren…"
ensure_plugin() {
  if wpc plugin is-installed "$1" >/dev/null 2>&1; then
    wpc plugin activate "$1" >/dev/null 2>&1 || true
    echo "  • $1 (bereits vorhanden)"
  else
    wpc plugin install "$1" --activate >/dev/null
    echo "  • $1 (installiert)"
  fi
}
ensure_plugin sportspress          # Teams, Kader, Spielpläne, Tabellen
ensure_plugin the-events-calendar  # Events / Kalender
ensure_plugin fluentform           # Kontakt-/Anmeldeformulare
ensure_plugin mailpoet             # Newsletter
ensure_plugin wordpress-seo        # SEO (Yoast)

# --------------------------------------------------------------------
log "Permalinks auf /beitragsname/ stellen…"
wpc rewrite structure '/%postname%/' --hard >/dev/null
wpc rewrite flush --hard >/dev/null

# --------------------------------------------------------------------
log "Seitenstruktur & Hauptmenü anlegen…"
if [ "$(wpc option get fcs_scaffold 2>/dev/null || true)" = "1" ]; then
  echo "Seiten/Menü bereits vorhanden – überspringe."
else
  # Standard-Beispielseite/-beitrag entfernen
  wpc post delete 2 --force >/dev/null 2>&1 || true   # "Beispiel-Seite"
  wpc post delete 1 --force >/dev/null 2>&1 || true   # "Hallo Welt"-Beitrag

  # Hauptmenü erstellen
  wpc menu create "Hauptmenü" >/dev/null 2>&1 || true

  HOME_ID=""
  # Seiten in Menü-Reihenfolge
  for title in Home Verein Aktive Junioren Events Sponsoren Kontakt Helfereinsätze; do
    pid=$(wpc post create --post_type=page --post_status=publish \
          --post_title="$title" --porcelain)
    pid=$(echo "$pid" | tr -dc '0-9')
    wpc menu item add-post hauptmenu "$pid" >/dev/null
    [ "$title" = "Home" ] && HOME_ID="$pid"
  done

  # "Home" als Startseite festlegen
  if [ -n "$HOME_ID" ]; then
    wpc option update show_on_front page >/dev/null
    wpc option update page_on_front "$HOME_ID" >/dev/null
  fi

  # Menü dem Hauptmenü-Standort zuweisen (Astra: "primary")
  wpc menu location assign hauptmenu primary >/dev/null 2>&1 || true

  wpc option update fcs_scaffold 1 >/dev/null
fi

# --------------------------------------------------------------------
log "Fertig! 🎉"
cat <<EOF

  WordPress:   $WP_URL
  Login:       $WP_URL/wp-admin   (Benutzer: $WP_ADMIN_USER / $WP_ADMIN_PASSWORD)
  Datenbank:   http://localhost:${ADMINER_PORT}   (Adminer)

  Nächste Schritte:
    • Inhalte einpflegen (Teams in SportsPress, News als Beiträge)
    • Vereinsfarben/Logo im Child-Theme anpassen
    • Stoppen mit:  docker compose down
    • Komplett zurücksetzen mit:  ./scripts/reset.sh
EOF
