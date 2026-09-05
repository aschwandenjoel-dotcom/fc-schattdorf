#!/usr/bin/env bash
# ====================================================================
# Live-Seite prüfen: DNS, Erreichbarkeit, Zertifikat
# --------------------------------------------------------------------
# Trennt die zwei Fehlerbilder, die von aussen gleich aussehen:
#
#   A) DNS zeigt woanders hin  -> Seite offline, Server gesund
#   B) Server/WordPress kaputt -> DNS korrekt, Origin antwortet nicht
#
# Genau dieser Unterschied hat am 05.08.2026 Zeit gekostet: der
# A-Record der damaligen Test-Adresse fcschattdorf.dynalias.net zeigte
# auf eine Vercel-IP, WordPress auf Hostpoint lief die ganze Zeit
# einwandfrei. Seit dem Domainwechsel liegt das DNS bei cyon
# (UMSTELLUNG.md) — die Prüfung bleibt dieselbe: A (und AAAA) von
# www.fcschattdorf.ch müssen auf sl1819.web.hostpoint.ch zeigen.
#
# Aufruf:  ./scripts/check-live.sh
# Exit 0 = alles gut, 1 = Handlungsbedarf (für Cron/Monitoring nutzbar)
# ====================================================================
set -uo pipefail
cd "$(dirname "$0")/.."

# lib-live.sh warnt selbst schon — hier soll die eigene Ausgabe reden.
. scripts/lib-live.sh 2>/dev/null

rot=$'\033[1;31m'; gruen=$'\033[1;32m'; gelb=$'\033[1;33m'; aus=$'\033[0m'
fail=0
ok()   { printf '  %sOK%s    %s\n' "$gruen" "$aus" "$1"; }
warn() { printf '  %sHINWEIS%s %s\n' "$gelb" "$aus" "$1"; }
bad()  { printf '  %sFEHLER%s %s\n' "$rot" "$aus" "$1"; fail=1; }

DNS_IP="$(fcs_dns_ip || true)"
ORIGIN_IP="$(fcs_origin_ip || true)"
DNS_IP6="$(fcs_ip6_of "$LIVE_HOST" || true)"
ORIGIN_IP6="$(fcs_ip6_of "$ORIGIN_HOST" || true)"

# ── 1. DNS ──────────────────────────────────────────────────────────
printf '\n%s1/4  DNS%s\n' "$gruen" "$aus"
printf '      %-28s -> %s\n' "$LIVE_HOST" "${DNS_IP:-<keine Antwort>}"
printf '      %-28s -> %s\n' "$ORIGIN_HOST" "${ORIGIN_IP:-<keine Antwort>}"

if [ -z "$ORIGIN_IP" ]; then
  bad "Hostpoint-Server ${ORIGIN_HOST} nicht auflösbar (Internet/Resolver prüfen?)."
elif [ -z "$DNS_IP" ]; then
  bad "${LIVE_HOST} hat keinen A-Record — der Eintrag fehlt oder ist gelöscht."
elif [ "$DNS_IP" = "$ORIGIN_IP" ]; then
  ok "A-Record zeigt korrekt auf Hostpoint."
else
  bad "A-Record zeigt auf ${DNS_IP}, muss aber auf ${ORIGIN_IP} (Hostpoint) zeigen."
fi
# IPv6: ein AAAA-Record, der noch auf den alten Hoster zeigt, schickt
# IPv6-Besucher woanders hin, obwohl der A-Record stimmt.
if [ -n "$DNS_IP6" ]; then
  printf '      %-28s -> %s (AAAA)\n' "$LIVE_HOST" "$DNS_IP6"
  if [ "$DNS_IP6" = "$ORIGIN_IP6" ]; then
    ok "AAAA-Record zeigt korrekt auf Hostpoint."
  else
    bad "AAAA-Record zeigt auf ${DNS_IP6}, muss auf ${ORIGIN_IP6:-die Hostpoint-IPv6} zeigen oder gelöscht werden."
  fi
fi

# ── 2. Wie ein Besucher es sieht (über das echte DNS) ───────────────
printf '\n%s2/4  Abruf über das öffentliche DNS (Besuchersicht)%s\n' "$gruen" "$aus"
BROWSER="$(curl -sS -o /dev/null -w '%{http_code}' -L --max-time 20 "$LIVE" 2>&1)"
if [ "$BROWSER" = "200" ]; then
  ok "https://${LIVE_HOST} liefert HTTP 200."
else
  bad "https://${LIVE_HOST} nicht erreichbar (${BROWSER})."
  # Fremdanbieter erkennen: sagt der Server, wer er ist?
  FREMD="$(curl -sS -D - -o /dev/null --max-time 15 "http://${LIVE_HOST}" 2>/dev/null \
           | grep -iE '^(server|x-vercel-error|x-served-by|x-github-request-id):' | tr -d '\r')"
  [ -n "$FREMD" ] && printf '        Antwort kommt von einem fremden Dienst:\n%s\n' \
    "$(printf '%s\n' "$FREMD" | sed 's/^/          /')"
fi

# ── 3. Ist der Server selbst gesund? (IP direkt, korrektes SNI) ─────
printf '\n%s3/4  Abruf direkt auf Hostpoint (Serversicht)%s\n' "$gruen" "$aus"
if [ -z "$ORIGIN_IP" ]; then
  warn "übersprungen — Hostpoint-IP unbekannt."
else
  ORIGIN_CODE="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 25 \
    --resolve "${LIVE_HOST}:443:${ORIGIN_IP}" "$LIVE/" 2>&1)"
  if [ "$ORIGIN_CODE" = "200" ]; then
    ok "WordPress auf Hostpoint antwortet mit HTTP 200 — Seite und Theme sind in Ordnung."
    [ "$BROWSER" != "200" ] && warn "Fehlerbild A: reines DNS-Problem, nichts am Server oder Code."
  else
    bad "Hostpoint-Origin antwortet nicht wie erwartet (${ORIGIN_CODE}) — Fehlerbild B."
  fi
fi

# ── 4. Zertifikat ───────────────────────────────────────────────────
printf '\n%s4/4  TLS-Zertifikat%s\n' "$gruen" "$aus"
if [ -z "$ORIGIN_IP" ]; then
  warn "übersprungen — Hostpoint-IP unbekannt."
else
  TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT
  openssl s_client -connect "${ORIGIN_IP}:443" -servername "$LIVE_HOST" </dev/null 2>/dev/null \
    | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' > "$TMP"
  if [ -s "$TMP" ]; then
    ENDE="$(openssl x509 -in "$TMP" -noout -enddate 2>/dev/null | cut -d= -f2)"
    ENDE_TS="$(date -j -f '%b %d %T %Y %Z' "$ENDE" +%s 2>/dev/null || echo '')"
    if [ -n "$ENDE_TS" ]; then
      TAGE=$(( (ENDE_TS - $(date +%s)) / 86400 ))
      printf '      gültig bis %s (%s Tage)\n' "$ENDE" "$TAGE"
      if [ "$TAGE" -lt 0 ]; then bad "Zertifikat ist abgelaufen."
      elif [ "$TAGE" -lt 21 ]; then
        warn "Erneuerung steht an. Let's Encrypt prüft über den Hostnamen —"
        warn "solange das DNS nicht auf Hostpoint zeigt, scheitert die Erneuerung."
      else ok "Zertifikat für ${LIVE_HOST} gültig."
      fi
    else
      ok "Zertifikat vorhanden, gültig bis ${ENDE}."
    fi
  else
    bad "Kein Zertifikat vom Hostpoint-Origin erhalten."
  fi
fi

# ── Fazit ───────────────────────────────────────────────────────────
echo
if [ "$fail" -eq 0 ]; then
  printf '%s==> Live-Seite in Ordnung.%s\n\n' "$gruen" "$aus"
  exit 0
fi
printf '%s==> Handlungsbedarf.%s\n' "$rot" "$aus"
if [ -n "$DNS_IP" ] && [ -n "$ORIGIN_IP" ] && [ "$DNS_IP" != "$ORIGIN_IP" ]; then
  cat <<EOF

  So wird der A-Record korrigiert (nur im cyon-Konto möglich, nicht von hier):

    1. Bei my.cyon anmelden (Zugang beim Verein), Domain fcschattdorf.ch
       wählen, Menü «DNS-Editor» — Domain, Nameserver und Mail liegen bei cyon.
    2. Haupt-A-Record «@» von ${DNS_IP} auf ${ORIGIN_IP} ändern und speichern.
       «www» ist ein CNAME auf «@» und folgt automatisch.
       ${ORIGIN_IP} ist die aktuelle IP von ${ORIGIN_HOST} — bei
       Unsicherheit gilt immer, was "dig +short ${ORIGIN_HOST}" sagt.
    3. AAAA-Record ebenso (dig +short ${ORIGIN_HOST} AAAA) oder löschen.
    4. MX, SPF, DMARC und die mail-/webmail-Einträge NICHT anfassen —
       daran hängt die Vereins-Mail.
    5. TTL ist 300 s — nach ~5 min hier erneut prüfen: ./scripts/check-live.sh

  Deploys und ./scripts/pull-prod-db.sh funktionieren in der Zwischenzeit
  weiter, sie gehen bei falschem DNS automatisch direkt auf Hostpoint.
EOF
fi
echo
exit 1
