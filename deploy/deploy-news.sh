#!/usr/bin/env bash
# ====================================================================
# Deploy: News-Beiträge aus einer Textliste live anlegen
#
# Aufruf:  ./deploy/deploy-news.sh <TAG>          z. B. 1709
#          ./deploy/deploy-news.sh <TAG> --lokal   nur lokal (Docker) durchspielen
#
# Erwartet deploy/news-import-<TAG>.json (Einträge siehe Kopf von
# deploy/fcs-news.php.tpl) und die darin genannten Bilder unter
# wp-content/uploads/<YYYY>/<MM>/ (Monat des Beitragsdatums).
#
# Ablauf live:
#   1. Bilder übertragen (nur die, die live fehlen oder abweichen),
#      jede auf HTTP 200 prüfen
#   2. Token-geschütztes PHP samt Textliste in den Webroot legen,
#      Probelauf fahren
#   3. Nach Rückfrage scharf ausführen; das Skript löscht sich selbst
#   4. Reste entfernen, 60 s warten (Hostpoint-Seitencache), prüfen
#
# Lokal (--lokal): Schritte 2–4 gegen http://localhost:8080 ohne
# Rückfrage, ohne Wartezeit; Probelauf, scharfer Lauf und zweiter Lauf
# («SKIP» erwartet). Vorher ./scripts/pull-prod-db.sh.
#
# Idempotent: bestehende Beiträge werden am Slug erkannt («SKIP»).
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

TAG="${1:-}"
[ -n "$TAG" ] || { echo "Aufruf: $0 <TAG> [--lokal]   (TAG z. B. 1709 -> deploy/news-import-1709.json)" >&2; exit 1; }
LOKAL=0; [ "${2:-}" = "--lokal" ] && LOKAL=1

JSONNAME="news-import-${TAG}.json"
PHPNAME="fcs-news-${TAG}.php"
[ -f "deploy/${JSONNAME}" ] || { echo "FEHLER: deploy/${JSONNAME} fehlt." >&2; exit 1; }

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
. scripts/lib-live.sh   # $LIVE und lcurl()

log() { printf "\n\033[1;32m==> %s\033[0m\n" "$1"; }

# Bilder und Prüfdaten aus der Textliste (Pfad relativ zu uploads/)
# (macOS liefert bash 3.2 ohne mapfile — daher read-Schleifen)
BILDER=(); while IFS= read -r z; do [ -n "$z" ] && BILDER+=("$z"); done < <(python3 - "deploy/${JSONNAME}" <<'PY'
import json,sys
seen=[]
for e in json.load(open(sys.argv[1],encoding='utf-8')):
    o=e['datum'][:4]+'/'+e['datum'][5:7]
    for b in (e.get('bild',''), e.get('beitragsbild','')):
        if b and o+'/'+b not in seen: seen.append(o+'/'+b)
print('\n'.join(seen))
PY
)
PRUEF=(); while IFS= read -r z; do [ -n "$z" ] && PRUEF+=("$z"); done < <(python3 - "deploy/${JSONNAME}" <<'PY'
import json,sys,re
for e in json.load(open(sys.argv[1],encoding='utf-8')):
    # längstes Stück des Titels ohne Umlaute/Sonderzeichen (grep-sicher, min. 8 Zeichen)
    t=e['titel']; st=sorted(re.findall(r"[A-Za-z0-9 .,:;!?-]{8,}",t),key=len)
    print('|'.join([e['slug'], e.get('bild',''), e.get('beitragsbild') or e.get('bild',''), (st[-1].strip() if st else '')]))
PY
)

for b in "${BILDER[@]}"; do
  [ -f "wp-content/uploads/$b" ] || { echo "FEHLER: wp-content/uploads/$b fehlt lokal. Abbruch." >&2; exit 1; }
done

# ── Lokaler Durchlauf ───────────────────────────────────────────────
if [ "$LOKAL" = "1" ]; then
  log "LOKAL: Probelauf, scharfer Lauf, zweiter Lauf gegen localhost:8080"
  TOKEN="lokal$(openssl rand -hex 8)"
  for lauf in "PROBELAUF|&dry=1" "SCHARF|" "ZWEITER LAUF|"; do
    sed -e "s/__TOKEN__/${TOKEN}/" -e "s/__JSON__/${JSONNAME}/" "deploy/fcs-news.php.tpl" > "/tmp/${PHPNAME}"
    docker compose cp "/tmp/${PHPNAME}" "wordpress:/var/www/html/${PHPNAME}" >/dev/null 2>&1
    docker compose cp "deploy/${JSONNAME}" "wordpress:/var/www/html/${JSONNAME}" >/dev/null 2>&1
    rm -f "/tmp/${PHPNAME}"
    printf "\n===== %s =====\n" "${lauf%%|*}"
    curl -sS "http://localhost:8080/${PHPNAME}?token=${TOKEN}${lauf#*|}" | sed 's/^/      /'
  done
  printf "\nSkript danach: HTTP %s (erwartet 404)\n" "$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:8080/${PHPNAME}")"
  LIVE="http://localhost:8080"; lcurl() { curl "$@"; }
fi

# ── Live: Bilder übertragen ─────────────────────────────────────────
if [ "$LOKAL" = "0" ]; then
  log "1/5  Bilddateien übertragen (nur fehlende/abweichende) und prüfen…"
  for b in "${BILDER[@]}"; do
    lcurl -s --max-time 40 "$LIVE/wp-content/uploads/$b" -o /tmp/fcs-news-pruef.bin || true
    if [ "$(md5 -q /tmp/fcs-news-pruef.bin 2>/dev/null)" = "$(md5 -q "wp-content/uploads/$b")" ]; then
      printf "    OK   %s liegt schon live (identisch)\n" "$b"
    else
      scp -q "wp-content/uploads/$b" "$HOST:$WEBROOT/wp-content/uploads/$b"
      c="$(lcurl -s -o /dev/null -w '%{http_code}' --max-time 30 "$LIVE/wp-content/uploads/$b")"
      [ "$c" = "200" ] && printf "    OK   %s übertragen (HTTP %s)\n" "$b" "$c" || { printf "    FEHL %s (HTTP %s)\n" "$b" "$c"; exit 1; }
    fi
  done
  rm -f /tmp/fcs-news-pruef.bin

  log "2/5  DB-Skript samt Textliste hochladen und PROBELAUF fahren (schreibt nichts)…"
  TOKEN="$(openssl rand -hex 24)"
  sed -e "s/__TOKEN__/${TOKEN}/" -e "s/__JSON__/${JSONNAME}/" "deploy/fcs-news.php.tpl" > "deploy/${PHPNAME}"
  scp -q "deploy/${PHPNAME}" "$HOST:$WEBROOT/${PHPNAME}"
  scp -q "deploy/${JSONNAME}" "$HOST:$WEBROOT/${JSONNAME}"
  rm -f "deploy/${PHPNAME}"
  trap 'ssh "$HOST" "rm -f $WEBROOT/${PHPNAME} $WEBROOT/${JSONNAME}"' EXIT
  lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}&dry=1" | sed 's/^/      /'

  printf "\n\033[1;33mProbelauf oben plausibel? Jetzt wirklich in die Live-DB schreiben? [j/N] \033[0m"
  read -r answer
  if [ "$answer" != "j" ] && [ "$answer" != "J" ]; then
    echo "Abgebrochen – räume Skript und Textliste vom Server…"; exit 0
  fi

  log "3/5  DB-Änderung ausführen…"
  lcurl -sS --max-time 300 "$LIVE/${PHPNAME}?token=${TOKEN}" | sed 's/^/      /'
  log "Reste auf dem Server entfernen…"
  ssh "$HOST" "rm -f $WEBROOT/${PHPNAME} $WEBROOT/${JSONNAME}"
  trap - EXIT
  for f in "${PHPNAME}" "${JSONNAME}"; do
    printf "    %s liefert HTTP %s (erwartet 404)\n" "$f" "$(lcurl -s -o /dev/null -w '%{http_code}' "$LIVE/${f}")"
  done

  log "4/5  Warte 60 s (Hostpoint-Seitencache), sonst gibt es Fehlalarme…"
  sleep 60
fi

# ── Verifikation ────────────────────────────────────────────────────
log "5/5  Seiten prüfen…"
ok=1
pruefe() { # $1 Beschreibung  $2 Pfad  $3 Suchmuster  $4 erwartet (>0|0)
  local body n
  body="$(lcurl -sSL --max-time 60 "$LIVE$2")"
  n="$(grep -c "$3" <<< "$body" || true)"   # kein printf|grep -q (pipefail-Fehlalarm)
  if { [ "$4" = ">0" ] && [ "$n" != "0" ]; } || { [ "$4" = "0" ] && [ "$n" = "0" ]; }; then
    printf "    OK   %s (%s: %s)\n" "$1" "$3" "$n"
  else
    printf "    FEHL %s (%s: %s, erwartet %s)\n" "$1" "$3" "$n" "$4"; ok=0
  fi
}
for zeile in "${PRUEF[@]}"; do
  IFS='|' read -r slug bild thumb titel <<< "$zeile"
  pruefe "Beitrag /$slug/ erreichbar"   "/$slug/" '<title>'                       ">0"
  [ -n "$bild" ]  && pruefe "  Bild im Artikel"     "/$slug/" "${bild%.*}"               ">0"
  [ -n "$thumb" ] && pruefe "  og:image"            "/$slug/" "og:image[^>]*${thumb%.*}" ">0"
  [ -n "$titel" ] && pruefe "  auf der Startseite"  "/"       "$titel"                   ">0"
done

echo
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Prüfungen grün.\033[0m\n"
else
  printf "\033[1;31mFertig, ABER mindestens eine Prüfung passt nicht.\033[0m\n"
  echo "  Hinweis: Hostpoint-Seitencache kann nachhängen – nach 1–2 min erneut prüfen."
  exit 1
fi
