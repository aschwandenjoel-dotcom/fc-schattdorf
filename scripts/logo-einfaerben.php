<?php
/**
 * Einfarbiges Logo umfärben (PNG mit Alphakanal).
 *
 * Viele Sponsorenlogos aus der alten Vereinsseite liegen flächig grau
 * vor: ein einziger Grauwert, die Kantenglättung steckt komplett im
 * Alphakanal. Solche Dateien lassen sich verlustfrei umfärben — Alpha
 * bleibt Pixel für Pixel erhalten, nur RGB wird neu gesetzt.
 *
 * Voraussetzung ist genau das: EIN Ton im Bild. Das Skript prüft es und
 * bricht ab, wenn die Datei mehrere Farben enthält (dann würde das
 * Umfärben Bildinformation zerstören).
 *
 * Aufruf im laufenden Container (GD ist dort vorhanden):
 *
 *   docker compose exec -T wordpress php \
 *     /var/www/html/wp-content/themes/../../../scripts/logo-einfaerben.php \
 *     <quelle.png> <ziel.png> <#RRGGBB>
 *
 * Einfacher über den Repo-Pfad, weil scripts/ nicht gemountet ist:
 *
 *   docker cp scripts/logo-einfaerben.php fc-schattdorf-wordpress-1:/tmp/
 *   docker compose exec -T wordpress php /tmp/logo-einfaerben.php \
 *     /var/www/html/wp-content/uploads/2026/06/Cash.png \
 *     /var/www/html/wp-content/uploads/2026/06/cash-2026.png '#0B2A47'
 *
 * So entstanden am 05.09.2026 cash-2026.png (#0B2A47, Markenblau aus
 * dem Favicon von cashsport.ch) und brand-automobile-2026.png
 * (#000000). Hintergrund: UEBERGABE.md, «Ausgegraute Sponsorenlogos».
 */

if ( $argc < 4 ) {
	fwrite( STDERR, "Aufruf: php logo-einfaerben.php <quelle.png> <ziel.png> <#RRGGBB>\n" );
	exit( 1 );
}
list( , $quelle, $ziel, $farbe ) = $argv;

if ( ! preg_match( '/^#?([0-9a-fA-F]{6})$/', $farbe, $m ) ) {
	fwrite( STDERR, "Farbe muss #RRGGBB sein, bekommen: {$farbe}\n" );
	exit( 1 );
}
$r = hexdec( substr( $m[1], 0, 2 ) );
$g = hexdec( substr( $m[1], 2, 2 ) );
$b = hexdec( substr( $m[1], 4, 2 ) );

$src = @imagecreatefrompng( $quelle );
if ( ! $src ) {
	fwrite( STDERR, "Quelle nicht lesbar: {$quelle}\n" );
	exit( 1 );
}
$w = imagesx( $src );
$h = imagesy( $src );

/* Prüfen: enthält die Quelle wirklich nur einen Ton? Vollständig
   transparente Pixel zählen nicht mit, ihr RGB ist bedeutungslos. */
$toene = array();
for ( $y = 0; $y < $h; $y++ ) {
	for ( $x = 0; $x < $w; $x++ ) {
		$c = imagecolorat( $src, $x, $y );
		if ( ( ( $c >> 24 ) & 0x7F ) >= 127 ) {
			continue;
		}
		$toene[ $c & 0xFFFFFF ] = true;
		if ( count( $toene ) > 1 ) {
			fwrite( STDERR, "Abbruch: {$quelle} enthält mehrere Farben — Umfärben\n"
			              . "würde Bildinformation zerstören. Farbige Vorlage besorgen.\n" );
			exit( 1 );
		}
	}
}
if ( ! $toene ) {
	fwrite( STDERR, "Abbruch: {$quelle} hat keine sichtbaren Pixel.\n" );
	exit( 1 );
}

$dst = imagecreatetruecolor( $w, $h );
imagealphablending( $dst, false );
imagesavealpha( $dst, true );
for ( $y = 0; $y < $h; $y++ ) {
	for ( $x = 0; $x < $w; $x++ ) {
		$a = ( imagecolorat( $src, $x, $y ) >> 24 ) & 0x7F;
		imagesetpixel( $dst, $x, $y, imagecolorallocatealpha( $dst, $r, $g, $b, $a ) );
	}
}
if ( ! imagepng( $dst, $ziel, 9 ) ) {
	fwrite( STDERR, "Ziel nicht schreibbar: {$ziel}\n" );
	exit( 1 );
}
printf( "%s -> %s  (%dx%d, #%02X%02X%02X)\n", basename( $quelle ), basename( $ziel ), $w, $h, $r, $g, $b );
