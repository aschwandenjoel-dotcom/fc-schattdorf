#!/usr/bin/env bash
# ====================================================================
# Datei-Downloader für www.fcschattdorf.ch
# --------------------------------------------------------------------
# Crawlt die Seite und lädt alle herunterladbaren Dokumente
# (PDF, Office, ZIP, Kalender …) mit Original-Ordnerstruktur nach
# import/ . Ergänzung zu scrape-images.sh.
#
#   ⚖️  Nur für den eigenen Vereinsgebrauch / als Vorlage verwenden.
#
# Aufruf:  ./scripts/scrape-files.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="www.fcschattdorf.ch"
BASE="https://$HOST"
OUT="import/fcschattdorf"
UA="Mozilla/5.0 (compatible; FCS-Backup/1.0)"
MAX_PAGES=300

# Welche Dateitypen gelten als "Datei zum Download"
EXT='pdf|docx?|xlsx?|pptx?|odt|ods|odp|zip|rar|7z|ics|csv|txt|rtf|mp3|mp4|mov'

mkdir -p "$OUT"
TMP="$(mktemp -d)"
PAGES_QUEUE="$TMP/queue"; PAGES_SEEN="$TMP/seen"; FILE_LIST="$TMP/files"
: > "$PAGES_SEEN"; : > "$FILE_LIST"
{ echo "/"; echo "/news"; echo "/verein/vorstand"; echo "/juniorenkonzept"; echo "/sponsoren"; } > "$PAGES_QUEUE"

normalize() {
  local ref="$1" url
  ref="${ref//&amp;/&}"
  case "$ref" in
    "$BASE"/*)        url="$ref" ;;
    http://"$HOST"/*) url="$ref" ;;
    http*://*)        return ;;
    //"$HOST"/*)      url="https:$ref" ;;
    //*)              return ;;
    /*)               url="$BASE$ref" ;;
    *)                url="$BASE/$ref" ;;
  esac
  url="${url%%#*}"
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
  echo "$url" >> "$PAGES_SEEN"; count=$((count+1))

  html="$(curl -sL -A "$UA" "$url" || true)"
  [ -z "$html" ] && continue
  printf "\r  [%3d] %s\033[K" "$count" "${url#$BASE}"

  # Datei-Links einsammeln (href/src auf passende Endungen, auch mit ?query)
  printf '%s' "$html" \
    | grep -oiE '(href|src)="[^"]+\.('"$EXT"')(\?[^"]*)?"' \
    | sed -E 's/.*="([^"]*)"/\1/' \
    | while read -r ref; do normalize "$ref"; done >> "$FILE_LIST" || true

  # interne Folgelinks
  printf '%s' "$html" \
    | grep -oiE 'href="/[^"]*"' | sed -E 's/href="([^"]*)"/\1/' \
    | grep -viE '\.(jpg|jpeg|png|gif|svg|webp|css|js|'"$EXT"')$' \
    | grep -viE '(format=feed|/login|/index.php|/media/)' \
    | sort -u >> "$PAGES_QUEUE" || true
done
echo; echo "==> $count Seiten besucht."

sort -u "$FILE_LIST" -o "$FILE_LIST"
total="$(wc -l < "$FILE_LIST" | tr -d ' ')"
echo "==> $total eindeutige Dateien gefunden."
[ "$total" = "0" ] && { echo "Keine herunterladbaren Dokumente entdeckt."; rm -rf "$TMP"; exit 0; }

ok=0; fail=0
while read -r f; do
  [ -z "$f" ] && continue
  clean="${f%%\?*}"; rel="${clean#$BASE/}"; dest="$OUT/$rel"
  [ -f "$dest" ] && { ok=$((ok+1)); continue; }
  mkdir -p "$(dirname "$dest")"
  if curl -sfL -A "$UA" "$f" -o "$dest"; then
    ok=$((ok+1)); echo "  + $rel"
  else
    fail=$((fail+1)); rm -f "$dest"
  fi
done < "$FILE_LIST"

rm -rf "$TMP"
echo "==> Fertig: $ok Dateien gespeichert, $fail fehlgeschlagen."
