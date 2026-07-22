#!/usr/bin/env bash
# ====================================================================
# Bild-Downloader für www.fcschattdorf.ch
# --------------------------------------------------------------------
# Crawlt die Seite (gleiche Domain), sammelt alle Bildpfade aus HTML
# und CSS und lädt sie mit Original-Ordnerstruktur nach import/ .
#
#   ⚖️  Nur für den eigenen Vereinsgebrauch / als Vorlage verwenden.
#
# Aufruf:  ./scripts/scrape-images.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="www.fcschattdorf.ch"
BASE="https://$HOST"
OUT="import/fcschattdorf"
UA="Mozilla/5.0 (compatible; FCS-Backup/1.0)"
MAX_PAGES=300

mkdir -p "$OUT"
TMP="$(mktemp -d)"
PAGES_QUEUE="$TMP/queue"      # noch zu besuchen
PAGES_SEEN="$TMP/seen"        # bereits besucht
IMG_LIST="$TMP/images"        # gefundene Bild-URLs
: > "$PAGES_SEEN"; : > "$IMG_LIST"

# Startseite + bekannte Einstiegspunkte
{ echo "/"; echo "/news"; echo "/aktive"; echo "/junioren/teams"; echo "/sponsoren"; } > "$PAGES_QUEUE"

# Normalisiert einen Roh-Pfad zu einer absoluten URL auf der Zieldomain
# (oder gibt nichts aus, wenn extern/ungültig).
normalize() {
  local ref="$1" url
  ref="${ref//&amp;/&}"
  case "$ref" in
    "$BASE"/*)            url="$ref" ;;
    http://"$HOST"/*)     url="$ref" ;;
    http*://*)            return ;;          # andere Domain -> ignorieren
    //"$HOST"/*)          url="https:$ref" ;;
    //*)                  return ;;
    /*)                   url="$BASE$ref" ;;
    *)                    url="$BASE/$ref" ;;
  esac
  url="${url%%\?*}"; url="${url%%#*}"        # Query/Anker entfernen
  # /../ und /./ auflösen
  url="$(printf '%s' "$url" | sed 's#/\./#/#g; s#/\.\.#/#g')"
  printf '%s\n' "$url"
}

count=0
echo "==> Crawle Seiten…"
while [ -s "$PAGES_QUEUE" ] && [ "$count" -lt "$MAX_PAGES" ]; do
  path="$(head -n1 "$PAGES_QUEUE")"; sed -i.bak '1d' "$PAGES_QUEUE"; rm -f "$PAGES_QUEUE.bak"
  url="$(normalize "$path")" || true
  [ -z "${url:-}" ] && continue
  grep -qxF "$url" "$PAGES_SEEN" && continue
  echo "$url" >> "$PAGES_SEEN"
  count=$((count+1))

  html="$(curl -sL -A "$UA" "$url" || true)"
  [ -z "$html" ] && continue
  printf "\r  [%3d] %s\033[K" "$count" "${url#$BASE}"

  # 1) Bildpfade einsammeln (HTML-Attribute + CSS url())
  printf '%s' "$html" \
    | grep -oiE '[^"'\''(), ]+\.(jpg|jpeg|png|gif|svg|webp)' \
    | while read -r ref; do normalize "$ref"; done >> "$IMG_LIST" || true

  # 2) verlinkte CSS-Dateien ebenfalls nach Hintergrundbildern durchsuchen
  printf '%s' "$html" \
    | grep -oiE 'href="[^"]+\.css[^"]*"' | sed -E 's/href="([^"]*)"/\1/' \
    | while read -r css; do
        cssurl="$(normalize "$css")" || true
        [ -z "${cssurl:-}" ] && continue
        curl -sL -A "$UA" "$cssurl" 2>/dev/null \
          | grep -oiE 'url\([^)]+\.(jpg|jpeg|png|gif|svg|webp)' \
          | sed -E 's/url\(["'\'']?//' \
          | while read -r ref; do normalize "$ref"; done
      done >> "$IMG_LIST" || true

  # 3) interne Folgelinks zur Queue hinzufügen
  printf '%s' "$html" \
    | grep -oiE 'href="/[^"]*"' | sed -E 's/href="([^"]*)"/\1/' \
    | grep -viE '\.(jpg|jpeg|png|gif|svg|webp|css|js|pdf|zip|xml)$' \
    | grep -viE '(format=feed|/login|/index.php|/media/)' \
    | sort -u >> "$PAGES_QUEUE" || true
done
echo; echo "==> $count Seiten besucht."

# Bildliste säubern
sort -u "$IMG_LIST" -o "$IMG_LIST"
total="$(wc -l < "$IMG_LIST" | tr -d ' ')"
echo "==> $total eindeutige Bilder gefunden. Lade herunter nach $OUT/ …"

ok=0; fail=0
while read -r img; do
  [ -z "$img" ] && continue
  rel="${img#$BASE/}"
  dest="$OUT/$rel"
  if [ -f "$dest" ]; then ok=$((ok+1)); continue; fi
  mkdir -p "$(dirname "$dest")"
  if curl -sfL -A "$UA" "$img" -o "$dest"; then
    ok=$((ok+1)); printf "\r  geladen: %4d / %d\033[K" "$ok" "$total"
  else
    fail=$((fail+1)); rm -f "$dest"
  fi
done < "$IMG_LIST"
echo

rm -rf "$TMP"
echo "==> Fertig: $ok Bilder gespeichert, $fail fehlgeschlagen."
echo "    Verzeichnis:  $OUT/"
du -sh "$OUT" 2>/dev/null || true
