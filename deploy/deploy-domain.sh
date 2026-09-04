#!/usr/bin/env bash
# ====================================================================
# Deploy: Domainwechsel in der Live-DB (UMSTELLUNG.md, Schritt B4)
#
# Ersetzt in der Produktions-DB den Test-Host fcschattdorf.dynalias.net
# durch www.fcschattdorf.ch — über ein token-geschütztes PHP-Skript im
# Webroot, weil MySQL auf Hostpoint nur aus Web-Prozessen erreichbar ist.
#
# Reihenfolge am Umstelltag ist zwingend: erst DNS bei cyon (B2), dann
# Zertifikat (B3), DANN dieses Skript. Es prüft beides vorab und bricht
# sonst ab — würde die DB zuerst umgestellt, leitete WordPress alle
# Besucher der Test-Adresse auf www.fcschattdorf.ch, und das wäre noch
# die alte Seite bei cyon.
#
# Erst Probelauf (zählt nur), dann Rückfrage, dann Schreiben. Das
# PHP-Skript bricht ab, wenn siteurl nicht mehr auf dem alten Host steht
# (Doppellauf / falsche Richtung).
#
# Aufruf:  ./deploy/deploy-domain.sh                # dynalias -> www
#          ./deploy/deploy-domain.sh --rueckwaerts  # www -> dynalias (Rollback,
#                                                   # vorher DNS bei cyon zurück)
# Danach:  Branch mergen und Theme per rsync deployen (B5) — erst damit
#          greifen die Weiterleitungen aus inc/fcs-redirects.php.
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
# Setzt $ORIGIN_HOST, lcurl() und enthaelt(); lcurl geht bei falschem DNS direkt auf Hostpoint
. scripts/lib-live.sh
PHPNAME="fcs-domain-switch.php"

ALT_HOST="fcschattdorf.dynalias.net"
NEU_HOST="www.fcschattdorf.ch"
RICHTUNG=""
if [ "${1:-}" = "--rueckwaerts" ]; then
  ALT_HOST="www.fcschattdorf.ch"; NEU_HOST="fcschattdorf.dynalias.net"; RICHTUNG="&rueckwaerts=1"
fi
# Aufgerufen wird über den NEUEN Host: der muss ohnehin schon auf Hostpoint
# zeigen und ein Zertifikat haben, sonst ist es zu früh für diesen Schritt.
BASE="https://${NEU_HOST}"

log()  { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }
stop() { printf "\n\033[1;31mABBRUCH: %s\033[0m\n" "$1" >&2; exit 1; }

# ── 0. Vorprüfungen ─────────────────────────────────────────────────
log "0/6  Vorprüfungen (${ALT_HOST} -> ${NEU_HOST})…"
ORIGIN_IP="$(fcs_origin_ip || true)"
NEU_IP="$(fcs_ip_of "$NEU_HOST" || true)"
echo "    ${NEU_HOST} -> ${NEU_IP:-<keine Antwort>}   Hostpoint -> ${ORIGIN_IP:-<keine Antwort>}"
[ -n "$ORIGIN_IP" ] || stop "Hostpoint-IP nicht auflösbar."
[ "$NEU_IP" = "$ORIGIN_IP" ] || stop "${NEU_HOST} zeigt noch nicht auf Hostpoint — zuerst Schritt B2 (DNS bei cyon)."

code="$(curl -sS -L -o /dev/null -w '%{http_code}' --max-time 30 "$BASE/" 2>&1 || true)"
case "$code" in
  200) echo "    https://${NEU_HOST}/ antwortet mit HTTP 200, Zertifikat gültig." ;;
  *)   stop "https://${NEU_HOST}/ liefert «${code}» — Zertifikat noch nicht da (Schritt B3) oder Domain nicht zugewiesen (A2)." ;;
esac

# Ohne Pipe (kein «| grep -q»): mit pipefail würde ein SIGPIPE an find aus
# einem vorhandenen Dump ein «kein Dump» machen.
if [ -z "$(find backups -name 'prod-db-*.sql.gz' -mmin -180 2>/dev/null)" ]; then
  printf "\n\033[1;33mKein Live-Dump der letzten 3 Stunden in backups/ (Schritt B1: ./scripts/pull-prod-db.sh).\nTrotzdem weiter? [j/N] \033[0m"
  read -r answer
  [ "$answer" = "j" ] || [ "$answer" = "J" ] || exit 0
fi

# ── 1. Skript hochladen und Probelauf ───────────────────────────────
log "1/6  DB-Skript hochladen und PROBELAUF fahren (schreibt nichts)…"
TOKEN="$(openssl rand -hex 24)"
sed "s/__TOKEN__/${TOKEN}/" "deploy/${PHPNAME}.tpl" > "deploy/${PHPNAME}"
scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
rm -f "deploy/${PHPNAME}"

lcurl -sS --max-time 900 "$BASE/${PHPNAME}?token=${TOKEN}&dry=1${RICHTUNG}" | sed 's/^/      /'

printf "\n\033[1;33mProbelauf plausibel (siteurl = alter Host, Trefferzahlen passen)? Jetzt wirklich schreiben? [j/N] \033[0m"
read -r answer
if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
  echo "Abgebrochen – räume das Skript vom Server…"
  ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
  exit 0
fi

# ── 2. Scharf auslösen ──────────────────────────────────────────────
log "2/6  DB umstellen…"
lcurl -sS --max-time 900 "$BASE/${PHPNAME}?token=${TOKEN}${RICHTUNG}" | sed 's/^/      /'

# ── 3. Reste entfernen (falls Selbst-Löschung nicht griff) ──────────
log "3/6  Reste auf dem Server entfernen…"
ssh "$HOST" "rm -f $WEBROOT/${PHPNAME}"
code="$(lcurl -s -o /dev/null -w '%{http_code}' "$BASE/${PHPNAME}")"
echo "    ${PHPNAME} liefert HTTP $code (erwartet 404)"

# ── 4. Warten (Hostpoint-Seitencache) ───────────────────────────────
log "4/6  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
sleep 60

# ── 5. Verifikation ─────────────────────────────────────────────────
log "5/6  Seite prüfen…"
fail=0
json="$(lcurl -sS --max-time 60 "$BASE/wp-json/" | head -c 2000 || true)"
if enthaelt "$json" "\"home\":\"https:\\/\\/${NEU_HOST}\""; then
  echo "    OK     wp-json meldet home = https://${NEU_HOST}"
else
  echo "    FEHLER wp-json meldet nicht den neuen Host: $(printf '%s' "$json" | head -c 200)"; fail=1
fi

html="$(lcurl -sS --max-time 60 "$BASE/" || true)"
reste="$(printf '%s' "$html" | grep -o "$ALT_HOST" | wc -l | tr -d ' ')"
if [ "$reste" = "0" ]; then
  echo "    OK     Startseite ohne ${ALT_HOST}"
else
  echo "    FEHLER Startseite enthält ${ALT_HOST} noch ${reste}×"; fail=1
fi
if enthaelt "$html" "rel=\"canonical\" href=\"https://${NEU_HOST}/\""; then
  echo "    OK     Canonical = https://${NEU_HOST}/"
else
  echo "    FEHLER Canonical zeigt nicht auf https://${NEU_HOST}/"; fail=1
fi

robots="$(lcurl -sS --max-time 30 "$BASE/robots.txt" || true)"
if enthaelt "$robots" "https://${NEU_HOST}/wp-sitemap.xml"; then
  echo "    OK     robots.txt nennt die neue Sitemap"
else
  echo "    FEHLER robots.txt: $(printf '%s' "$robots" | head -1)"; fail=1
fi

# ── 6. Fazit ────────────────────────────────────────────────────────
log "6/6  Fazit"
if [ "$fail" = "0" ]; then
  printf "\033[1;32mDB steht auf %s.\033[0m\n" "$NEU_HOST"
else
  printf "\033[1;31mDB umgestellt, ABER die Prüfung passt nicht — oben nachsehen.\033[0m\n"
  echo "  Hostpoint-Seitencache kann nachhängen: nach 1–2 min erneut prüfen mit"
  echo "  curl -s $BASE/ | grep -c $ALT_HOST     (erwartet 0)"
fi
cat <<EOF

  Nächste Schritte (UMSTELLUNG.md):
    B5  Branch «umstellung» nach main mergen und das Theme deployen:
        rsync -avz wp-content/themes/fcschattdorf-child/ $HOST:$WEBROOT/wp-content/themes/fcschattdorf-child/
        -> erst damit greifen die Weiterleitungen (inc/fcs-redirects.php)
    B6  ./scripts/check-live.sh und die Checkliste in Abschnitt 8
    Optional: WP-Admin -> Yoast SEO -> Werkzeuge -> «SEO-Daten optimieren»
EOF
[ "$fail" = "0" ]
