#!/usr/bin/env bash
# ====================================================================
# Korrektur: Porträts Adrian Tresch / Fabian Bachmann (Ca) vertauscht
#
# Beim Deploy vom 16.09.2026 waren die beiden Dateien inhaltlich
# vertauscht (DSC05510 ist Adrian Tresch, DSC05514 Fabian Bachmann).
# Die Dateinamen bleiben, nur der Inhalt wird ersetzt — darum keine
# DB-Änderung. Danach byteweiser Vergleich live gegen lokal.
#
# Aufruf:  ./deploy/deploy-portraets-tresch-bachmann.sh
# ====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="aziwivac@sl1819.web.hostpoint.ch"
WEBROOT="www/fcschattdorf"
. scripts/lib-live.sh

BILDER=( "2026/06/Adi_Tresch_2627.jpg" "2026/06/Fabian_Bachmann_2627.jpg" )

for b in "${BILDER[@]}"; do
  [ -f "wp-content/uploads/$b" ] || { echo "FEHLER: wp-content/uploads/$b fehlt lokal." >&2; exit 1; }
  scp -q "wp-content/uploads/$b" "$HOST:$WEBROOT/wp-content/uploads/$b"
done

ok=1
for b in "${BILDER[@]}"; do
  lcurl -sS --max-time 40 -H 'Cache-Control: no-cache' "$LIVE/wp-content/uploads/$b" -o /tmp/fcs-pruef.jpg
  if [ "$(md5 -q /tmp/fcs-pruef.jpg)" = "$(md5 -q "wp-content/uploads/$b")" ]; then
    printf "    OK   %s identisch mit lokal\n" "$b"
  else
    printf "    FEHL %s weicht live ab\n" "$b"; ok=0
  fi
done
rm -f /tmp/fcs-pruef.jpg

if [ "$ok" = "1" ]; then
  printf "\033[1;32mFertig – beide Porträts getauscht.\033[0m\n"
  echo "  Zeigt der Browser noch das alte Bild: Seite einmal hart neu laden (Cmd+Shift+R)."
else
  printf "\033[1;31mFertig, ABER mindestens eine Datei passt nicht.\033[0m\n"; exit 1
fi
