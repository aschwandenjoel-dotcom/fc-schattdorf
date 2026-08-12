#!/usr/bin/env bash
# ====================================================================
# Gemeinsame Helfer für Zugriffe auf die Live-Seite
# --------------------------------------------------------------------
# Die Live-Seite läuft auf Hostpoint (sl1819) und ist über den
# Hostnamen fcschattdorf.dynalias.net erreichbar. Dieser Hostname ist
# ein dynamisches DNS (dynalias.net, Nameserver bei Oracle) — und
# damit die empfindlichste Stelle des ganzen Setups: zeigt der
# A-Record nicht mehr auf Hostpoint, ist die Seite offline, obwohl
# Server, WordPress und Theme einwandfrei laufen.
#
# Genau das ist am 05.08.2026 passiert: der A-Record zeigte auf eine
# Vercel-IP (216.198.79.1), Vercel antwortete mit
# DEPLOYMENT_NOT_FOUND und hatte kein Zertifikat für den Namen.
#
# Damit Deploys und DB-Pulls in so einem Fall nicht ebenfalls
# ausfallen, laufen alle Live-Aufrufe über lcurl(): das prüft beim
# Einbinden den A-Record und zwingt curl per --resolve auf die
# Hostpoint-IP, sobald das DNS woanders hin zeigt. Hostname, SNI und
# Zertifikatsprüfung bleiben dabei korrekt — nur die IP wird gesetzt.
#
# Einbinden:  . "$(dirname "$0")/../scripts/lib-live.sh"
# Diagnose:   ./scripts/check-live.sh
# ====================================================================

LIVE_HOST="fcschattdorf.dynalias.net"
LIVE="https://${LIVE_HOST}"
ORIGIN_HOST="sl1819.web.hostpoint.ch"   # Hostpoint-Server dieser Seite

# IPv4 eines Hostnamens. Die Hostpoint-IP wird absichtlich nicht
# hartkodiert — Hostpoint kann sie ändern, sl1819 bleibt gültig.
fcs_ip_of() {
  if command -v dig >/dev/null 2>&1; then
    dig +short "$1" A 2>/dev/null | grep -m1 -E '^[0-9]+(\.[0-9]+){3}$'
  else
    # Fallback ohne dig (dscacheutil auf macOS, sonst getent)
    { dscacheutil -q host -a name "$1" 2>/dev/null || getent hosts "$1" 2>/dev/null; } \
      | grep -o -m1 -E '[0-9]+(\.[0-9]+){3}'
  fi
}

fcs_origin_ip() { fcs_ip_of "$ORIGIN_HOST"; }
fcs_dns_ip()    { fcs_ip_of "$LIVE_HOST"; }

# ── DNS prüfen und ggf. Umleitung auf die Hostpoint-IP vorbereiten ──
FCS_CURL_OPTS=()
FCS_DNS_OK=1

fcs_live_init() {
  local dns origin
  dns="$(fcs_dns_ip || true)"
  origin="$(fcs_origin_ip || true)"

  if [ -z "$origin" ]; then
    echo "WARNUNG: IP von ${ORIGIN_HOST} nicht auflösbar — kein DNS-Fallback möglich." >&2
    return 0
  fi
  if [ "$dns" = "$origin" ]; then
    return 0
  fi

  FCS_DNS_OK=0
  FCS_CURL_OPTS=(--resolve "${LIVE_HOST}:443:${origin}"
                 --resolve "${LIVE_HOST}:80:${origin}")
  printf '\n\033[1;33m!! DNS-Problem: %s zeigt auf %s statt auf Hostpoint (%s).\n' \
    "$LIVE_HOST" "${dns:-<keine Antwort>}" "$origin" >&2
  printf '   Die Seite ist damit für Besucher offline, der Server selbst läuft.\n' >&2
  printf '   Dieses Skript arbeitet trotzdem weiter (direkt auf %s).\n' "$origin" >&2
  printf '   A-Record im dynalias.net-Konto korrigieren, Details: ./scripts/check-live.sh\033[0m\n\n' >&2
}

fcs_live_init

# curl gegen die Live-Seite — immer diese Funktion statt curl direkt.
# Die Fallunterscheidung ist nötig: ein leeres Array darf nicht als
# leeres Argument an curl geraten («option : blank argument where
# content is expected»). Diese Form verhält sich in bash 3.2 wie in zsh.
lcurl() {
  if [ "${#FCS_CURL_OPTS[@]}" -gt 0 ]; then
    curl "${FCS_CURL_OPTS[@]}" "$@"
  else
    curl "$@"
  fi
}
