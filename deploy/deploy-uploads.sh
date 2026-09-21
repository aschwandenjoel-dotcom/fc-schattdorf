#!/usr/bin/env bash
# ====================================================================
# Einzelne Upload-Dateien live ersetzen und byteweise prüfen
#
# Aufruf:  ./deploy/deploy-uploads.sh <pfad relativ zu wp-content/uploads> …
#   z. B.  ./deploy/deploy-uploads.sh 2026/06/Heiri_Stadler_2627.jpg 2026/06/Bernhard_Gisler_2627.jpg
#
# Für Korrekturen, bei denen nur eine Datei unter gleichem Namen
# getauscht wird (vertauschte Porträts, neu beschnittenes Foto) —
# keine DB-Änderung. Überträgt per scp, lädt danach jede Datei live
# und vergleicht die Prüfsumme mit der lokalen.
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."
[ $# -ge 1 ] || { echo "Aufruf: $0 <pfad relativ zu wp-content/uploads> …" >&2; exit 1; }

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
. scripts/lib-live.sh

for b in "$@"; do
  [ -f "wp-content/uploads/$b" ] || { echo "FEHLER: wp-content/uploads/$b fehlt lokal." >&2; exit 1; }
done
for b in "$@"; do
  scp -q "wp-content/uploads/$b" "$HOST:$WEBROOT/wp-content/uploads/$b"
done
ok=1
for b in "$@"; do
  lcurl -sS --max-time 40 -H 'Cache-Control: no-cache' "$LIVE/wp-content/uploads/$b" -o /tmp/fcs-upload-pruef.bin
  if [ "$(md5 -q /tmp/fcs-upload-pruef.bin)" = "$(md5 -q "wp-content/uploads/$b")" ]; then
    printf "    OK   %s identisch mit lokal\n" "$b"
  else
    printf "    FEHL %s weicht live ab\n" "$b"; ok=0
  fi
done
rm -f /tmp/fcs-upload-pruef.bin
if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – alle Dateien live ersetzt.\033[0m\n"
  echo "  Zeigt der Browser noch das alte Bild: Seite einmal hart neu laden (Cmd+Shift+R)."
else
  printf "\033[1;31mFertig, ABER mindestens eine Datei passt nicht.\033[0m\n"; exit 1
fi
