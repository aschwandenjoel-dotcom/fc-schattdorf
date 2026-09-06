<?php
/**
 * Einmal-Skript: 1. Mannschaft, Stand Vorrunde 2026/27.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Quelle der Angaben: www.fcschattdorf.ch/aktive/1-mannschaft,
 * abgeglichen am 04.09.2026 (die Redaktion pflegt dort den aktuellen
 * Stand). Offene Punkte daraus mit dem Verein geklärt:
 *   - Joel Aschwanden (23) ist Verteidigung (dort ohne Angabe).
 *   - Nico Bissig trägt neu die 15, Linus Arnold die 14 (dort stehen
 *     beide auf 15).
 *
 * Inhalt:
 *   A) Betreuerstab: Saverio La Bella neu als Trainer, Thomas Zberg
 *      neu als «Coach» (mit neuem Foto), Reto Infanger entfällt.
 *   B) Kader: 11 Zugänge, 5 Abgänge, neue Fotos für Wirth, Muoser und
 *      Zgraggen, Kopfsponsoren durchgehend nachgeführt. Die Logos auf
 *      fcschattdorf.ch sind 48–162 px breit; die Vorlage zeigt das
 *      Badge mit 64 px (Retina 128), deshalb hier durchgehend die
 *      hochauflösenden Originale der Sponsoren.
 *
 * Nicht angefasst: die Team-Sponsoren-Liste unten auf der Seite. Sie
 * war nicht Teil des Auftrags; auf fcschattdorf.ch fehlt dort neu
 * «Schelbert AG» — bewusst offen gelassen, statt einen Sponsor
 * ungefragt zu entfernen.
 *
 * Schutz gegen Überschreiben von Redaktions-Arbeit: beide Felder
 * prüfen vorher den erwarteten alten Wert. Weicht er ab, meldet das
 * Skript «ABBRUCH» und rührt nichts an — dann mit &force=1 bewusst
 * überschreiben.
 *
 * Idempotent: schon Erledigtes meldet «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 300 );

$dry   = ! empty( $_GET['dry'] );
$force = ! empty( $_GET['force'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler = 0;

/* ── Hilfsfunktionen ────────────────────────────────────────────── */

/** Seite über ihren Pfad holen (Slug-Kette ab Wurzel). */
function fcs_seite( $pfad ) {
	$p = get_page_by_path( $pfad );
	return $p instanceof WP_Post ? $p : null;
}

/** Zeilenenden und Rand vereinheitlichen, damit Vergleiche tragen. */
function fcs_norm( $v ) {
	return trim( str_replace( "\r\n", "\n", (string) $v ) );
}

/**
 * Meta-Feld ersetzen, aber nur wenn der Live-Wert dem erwarteten
 * alten Stand entspricht. Sonst ABBRUCH (es sei denn $force).
 */
function fcs_ersetze_meta( $post_id, $key, $alt_erwartet, $neu, $dry, $force ) {
	global $fehler;
	$ist = get_post_meta( $post_id, $key, true );

	if ( fcs_norm( $ist ) === fcs_norm( $neu ) ) {
		echo "   SKIP – #{$post_id} {$key} steht bereits auf dem neuen Stand.\n";
		return;
	}
	if ( fcs_norm( $ist ) !== fcs_norm( $alt_erwartet ) && ! $force ) {
		echo "   ABBRUCH – #{$post_id} {$key} weicht vom erwarteten alten Stand ab.\n";
		echo "             Da hat jemand im Admin gearbeitet. Mit &force=1 bewusst überschreiben.\n";
		echo "             live: «" . str_replace( "\n", ' ⏎ ', fcs_norm( $ist ) ) . "»\n";
		$fehler++;
		return;
	}
	if ( $dry ) {
		echo "   würde setzen: #{$post_id} {$key}\n";
		foreach ( explode( "\n", fcs_norm( $neu ) ) as $z ) { echo "                 {$z}\n"; }
		return;
	}
	update_post_meta( $post_id, $key, $neu );
	echo "   gesetzt: #{$post_id} {$key}\n";
}

/** Prüfen, ob eine Bilddatei im Upload-Ordner wirklich liegt. */
function fcs_datei_da( $datei ) {
	$dir = wp_upload_dir();
	return file_exists( $dir['basedir'] . '/2026/06/' . $datei );
}

/* ══════════════════════════════════════════════════════════════════
   Seite holen
   ══════════════════════════════════════════════════════════════════ */
$m1 = fcs_seite( 'aktive/1-mannschaft' );
if ( ! $m1 ) { $m1 = fcs_seite( '1-mannschaft' ); }
if ( ! $m1 ) {
	echo "FEHLER – Seite «1. Mannschaft» nicht gefunden. Abbruch.\n";
	exit;
}
echo "Seite: #{$m1->ID} «{$m1->post_title}»\n";

/* ══════════════════════════════════════════════════════════════════
   A) Betreuerstab
   ══════════════════════════════════════════════════════════════════ */
echo "\nA) Betreuerstab\n";

$staff_alt = implode( "\n", array(
	'Trainer | Thomas Zberg | ZbergThomas.jpg',
	'Co-Trainer | Reto Infanger | Reto_Infanger.jpg | infanger_reto.jpg',
	'Torwarttrainer | Thomas Aschwanden | AschwandenThomas.jpg | aschw_tom_orig.jpg',
	'Masseur | Simon Arnold | arnold_simon2122.jpg',
) );

/* Saverio La Bella neu; Thomas Zberg rückt auf «Coach» und bekommt
   das Foto aus der Serie vom August 2026; Reto Infanger entfällt.
   Kopfsponsoren: La Bella = Mazzei Hypnosetherapie,
   Zberg = Physio & Sport BackUp. */
$staff_neu = implode( "\n", array(
	'Trainer | Saverio La Bella | Saverio_LaBella.jpg | mazzei-hypnosetherapie-2026.jpg',
	'Coach | Thomas Zberg | Thomas_Zberg_2627.jpg | psbackup-2026.png',
	'Torwarttrainer | Thomas Aschwanden | AschwandenThomas.jpg | aschw_tom_orig.jpg',
	'Masseur | Simon Arnold | arnold_simon2122.jpg',
) );

fcs_ersetze_meta( $m1->ID, 'fcs_team_staff', $staff_alt, $staff_neu, $dry, $force );

/* ══════════════════════════════════════════════════════════════════
   B) Kader
   ══════════════════════════════════════════════════════════════════ */
echo "\nB) Kader\n";

$kader_alt = implode( "\n", array(
	'Torhüter | 1 | Gian Gisler | GianGisler.jpg | herger_sport.png | Herger Sport',
	'Torhüter | 1 | Yannick Arnold | BoeriArnold.jpg | Boeri_I.png | Zahnarzt-Uri',
	'Verteidigung | 2 | Elias Muoser | EliasMuoser.jpg | Muoser_Elias.jpg | Kebab Häsli',
	'Verteidigung | 3 | Tim Gisler | TimGisler.jpg | Gisler_Tim.jpg | Musch',
	'Verteidigung | 4 | Samuel Wirth | SamuelWirth.jpg | saemi.jpg | KMS AG',
	'Verteidigung | 5 | Sandro Stampfli | StampfliSandro.jpg | Schelbert_AG.png | Schelbert AG',
	'Verteidigung | 18 | Franco Heinzer | HeinzerFranco.jpg | franco_heinzer_sp.jpg | Heidi Nails',
	'Mittelfeld | 6 | Joachim Gisler | GislerJoachim.jpg | Noah_Noel_Joecha.jpg | Synaxis Altdorf',
	'Mittelfeld | 7 | Noel Gisler | Noel_Gisler.jpg | Noah_Noel_Joecha.jpg | Synaxis Altdorf',
	'Mittelfeld | 8 | Simon Wipfli | SimonWipfli.jpg | Wipfli.png | Dätwyler',
	'Mittelfeld | 9 | Robin Mahrow | MahrowRobin.jpg | Mahrow_Robin_Livio.jpg | Apéro & Pasta Association',
	'Mittelfeld | 10 | Cédric Gisler | CediGisler.jpg | Adidach.jpg | Adidach',
	'Mittelfeld | 11 | Andri Baumann | BaumannAndri.jpg | andri_baumann_sp.jpg | Brand Automobile',
	'Mittelfeld | 13 | Skander Agrebi | AgrebiSkander.jpg | skander_II.jpg | BMBG',
	'Mittelfeld | 15 | Linus Arnold | Linus_Arnold.jpg | gotthard_holzbau.png | Gotthard Holzbau',
	'Mittelfeld | 19 | Nico Zgraggen | Nico_Zgraggen.jpg | Muoser_Elias.jpg | Kebab Häsli',
	'Mittelfeld | 20 | Nico Bissig | NicoBissig.jpg | raiffeisen_logo.png | Raiffeisen',
	'Sturm | 12 | Livio Gisler | LivioGisler.jpg | livio_gisler_sp.jpg | Energie Uri',
	'Sturm | 14 | Mattia Schorno | MattiaSchorno.jpg | zurich_vers.png | Zurich Insurance',
	'Sturm | 16 | Patrik Stampfli | StampfliPatrik.jpg | Staempf_Paedi.jpg | Gasthaus Brückli',
) );

/* Zugänge: Mahrow, M. Arnold, Moser, Imbach, J. Aschwanden, Herger,
   B. Arnold, Riesen, Tresch, Zurfluh, D. Baumann.
   Abgänge: Gian Gisler, Yannick Arnold, Sandro Stampfli,
   Skander Agrebi, Livio Gisler.
   Ohne Kopfsponsor (nur vier Spalten): Zurfluh, Aschwanden, Imbach,
   Herger — auf fcschattdorf.ch tragen sie ebenfalls keinen.
   Mario Arnold und Fabio Moser haben dort die Silhouette. */
$kader_neu = implode( "\n", array(
	'Torhüter | 1 | Livio Mahrow | Livio_Mahrow.jpg | Mahrow_Robin_Livio.jpg | Apéro & Pasta Association',
	'Torhüter | 1 | Mario Arnold | Silhouette_Male_v2.jpg | arnold-umzuege-2026.jpg | Arnold Umzüge AG',
	'Torhüter | 1 | Fabio Moser | Silhouette_Male_v2.jpg | dashauptwerk-2026.png | Das Hauptwerk',
	'Verteidigung | 2 | Elias Muoser | Elias_Muoser_2627.jpg | Muoser_Elias.jpg | Kebab Häsli',
	'Verteidigung | 3 | Tim Gisler | TimGisler.jpg | Gisler_Tim.jpg | Musch',
	'Verteidigung | 4 | Samuel Wirth | Samuel_Wirth_2627.jpg | saemi.jpg | KMS AG',
	'Verteidigung | 12 | Tim Riesen | Tim_Riesen.jpg | sp-herger-kuechen-transparent.png | Herger Küchen AG',
	'Verteidigung | 13 | David Baumann | David_Baumann.jpg | gasthaus-brueckli-2026.jpg | Gasthaus Brückli',
	'Verteidigung | 18 | Franco Heinzer | HeinzerFranco.jpg | franco_heinzer_sp.jpg | Heidi Nails',
	'Verteidigung | 22 | Robin Zurfluh | Robin_Zurfluh.jpg',
	'Verteidigung | 23 | Joel Aschwanden | Joel_Aschwanden.jpg',
	'Verteidigung | 24 | Sandro Imbach | Sandro_Imbach.jpg',
	'Mittelfeld | 5 | Gian-Luca Tresch | GianLuca_Tresch.jpg | zurich-2026.png | Zurich',
	'Mittelfeld | 6 | Joachim Gisler | GislerJoachim.jpg | Noah_Noel_Joecha.jpg | Synaxis Altdorf',
	'Mittelfeld | 7 | Noel Gisler | Noel_Gisler.jpg | Noah_Noel_Joecha.jpg | Synaxis Altdorf',
	'Mittelfeld | 8 | Simon Wipfli | SimonWipfli.jpg | Wipfli.png | Dätwyler',
	'Mittelfeld | 9 | Robin Mahrow | MahrowRobin.jpg | Mahrow_Robin_Livio.jpg | Apéro & Pasta Association',
	'Mittelfeld | 10 | Cédric Gisler | CediGisler.jpg | Adidach.jpg | Adidach',
	'Mittelfeld | 11 | Andri Baumann | BaumannAndri.jpg | Schelbert_AG.png | Schelbert AG',
	'Mittelfeld | 14 | Linus Arnold | Linus_Arnold.jpg | gotthard_holzbau.png | Gotthard Holzbau',
	'Mittelfeld | 15 | Nico Bissig | NicoBissig.jpg | raiffeisen_logo.png | Raiffeisen',
	'Mittelfeld | 17 | Ben Arnold | Ben_Arnold.jpg | schibli-elektrotechnik-2026.png | Schibli Elektrotechnik',
	'Mittelfeld | 19 | Nico Zgraggen | Nico_Zgraggen_2627.jpg | gasthaus-brueckli-2026.jpg | Gasthaus Brückli',
	'Mittelfeld | 21 | Noel Herger | Noel_Herger.jpg',
	'Sturm | 16 | Patrik Stampfli | StampfliPatrik.jpg | gasthaus-brueckli-2026.jpg | Gasthaus Brückli',
	'Sturm | 20 | Mattia Schorno | MattiaSchorno.jpg | coiffure-atmosphair-2026.png | Coiffure AtmospHAIR',
) );

/* Erst prüfen, ob alle referenzierten Dateien wirklich hochgeladen
   sind — sonst zeigt die Seite hinterher leere Kästen.
   Die beiden Blöcke haben verschieden viele Spalten vor den Bildern:
   Betreuer «Rolle | Name | Porträt | Logo» (ab Spalte 2),
   Kader «Position | Nr | Name | Porträt | Logo | Sponsorname»
   (Spalten 3 und 4). Ein gemeinsamer Versatz würde Spieler- und
   Sponsornamen als Dateinamen lesen. */
$noetig = array();
$sammle = function ( $text, $ab, $bis ) use ( &$noetig ) {
	foreach ( explode( "\n", $text ) as $zeile ) {
		if ( '' === trim( $zeile ) ) { continue; }
		$t = array_map( 'trim', explode( '|', $zeile ) );
		foreach ( array_slice( $t, $ab, $bis ) as $datei ) {
			if ( '' !== $datei ) { $noetig[ $datei ] = true; }
		}
	}
};
$sammle( $staff_neu, 2, 2 );   // Porträt, Logo
$sammle( $kader_neu, 3, 2 );   // Porträt, Logo
$fehlend = array();
foreach ( array_keys( $noetig ) as $datei ) {
	if ( ! fcs_datei_da( $datei ) ) { $fehlend[] = $datei; }
}
if ( $fehlend ) {
	echo "   ABBRUCH – diese Dateien fehlen in uploads/2026/06:\n";
	foreach ( $fehlend as $datei ) { echo "             {$datei}\n"; }
	$fehler++;
} else {
	echo '   ' . count( $noetig ) . " referenzierte Bilddateien vorhanden.\n";
	fcs_ersetze_meta( $m1->ID, 'fcs_team_kader', $kader_alt, $kader_neu, $dry, $force );
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
