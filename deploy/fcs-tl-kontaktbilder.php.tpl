<?php
/**
 * Einmal-Skript: Fotos für die beiden Organisatoren des Trainingslagers.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Die Kontaktpersonen stehen im Seitenfeld fcs_tl_kontakte, eine pro
 * Zeile. Das Format bekommt ein viertes Feld für die Bilddatei:
 *
 *   Name | Rolle | Telefon                  (bisher)
 *   Name | Rolle | Telefon | Bilddatei      (neu)
 *
 * Beide Bilder liegen bereits in uploads/2026/06 — es werden keine
 * Dateien übertragen, nur der Feldwert ergänzt.
 *
 * REIHENFOLGE: erst das Theme deployen, dann dieses Skript. Ohne die
 * neue Vorlage wertet die Seite das vierte Feld gar nicht aus; kaputt
 * geht dabei nichts, es passiert nur nichts.
 *
 * Zeilen mit unbekanntem Namen bleiben unberührt, Zeilen mit bereits
 * gesetztem Bild melden SKIP. Ein zweiter Lauf ändert nichts.
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 120 );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

/**
 * Ergänzt die Bilddateien. Als Funktion, damit jeder Abbruch ein
 * schlichtes return ist — das Löschen am Ende läuft trotzdem.
 */
function fcs_tl_bilder( $dry ) {

	$zuordnung = array(
		'Sandro Zamuner' => 'Sandro_Zamuner.jpg',
		'René Gnos'      => 'Rene_Gnos_hoch.jpg',
	);

	$seite = get_page_by_path( 'junioren/trainingslager' );
	if ( ! $seite ) {
		$seite = get_page_by_path( 'trainingslager' );
	}
	if ( ! $seite ) {
		echo "FEHLER: Seite «Trainingslager» nicht gefunden — nichts geändert.\n";
		return;
	}
	echo "Seite: «{$seite->post_title}» (#{$seite->ID})\n\n";

	$alt = (string) get_post_meta( $seite->ID, 'fcs_tl_kontakte', true );
	if ( '' === trim( $alt ) ) {
		/* Leeres Feld = die Vorlage liefert die Zeilen, und die tragen
		   die Bilddateien bereits. Dann ist hier nichts zu tun. */
		echo "SKIP – fcs_tl_kontakte ist leer; es greift die Vorgabe der Vorlage,\n";
		echo "       die die Bilddateien schon enthält.\n";
		return;
	}

	/* preg_split über \R: der gespeicherte Wert kann \n oder \r\n haben. */
	$zeilen    = preg_split( '/\R/', $alt );
	$geaendert = 0;

	foreach ( $zeilen as $i => $zeile ) {
		$teile = array_map( 'trim', explode( '|', $zeile ) );
		if ( '' === $teile[0] ) {
			continue;
		}
		if ( ! isset( $zuordnung[ $teile[0] ] ) ) {
			echo "   unberührt – «{$teile[0]}»: kein Bild hinterlegt.\n";
			continue;
		}
		if ( count( $teile ) >= 4 && '' !== $teile[3] ) {
			echo "   SKIP – «{$teile[0]}» hat bereits ein Bild ({$teile[3]}).\n";
			continue;
		}
		/* Auf drei Felder kürzen, damit ein leeres viertes Feld nicht
		   zu «Name | Rolle | Tel |  | Bild» führt. */
		$teile        = array_slice( $teile, 0, 3 );
		$teile[]      = $zuordnung[ $teile[0] ];
		$zeilen[ $i ] = implode( ' | ', $teile );
		echo "   ergänzt – «{$teile[0]}» -> {$teile[3]}\n";
		$geaendert++;
	}

	if ( ! $geaendert ) {
		echo "\nNichts zu tun.\n";
		return;
	}

	$neu = implode( "\n", $zeilen );

	if ( $dry ) {
		echo "\nWÜRDE SCHREIBEN – neuer Feldwert:\n";
		foreach ( explode( "\n", $neu ) as $zeile ) {
			echo '   ' . $zeile . "\n";
		}
		return;
	}

	update_post_meta( $seite->ID, 'fcs_tl_kontakte', $neu );
	clean_post_cache( $seite->ID );

	$kontrolle = (string) get_post_meta( $seite->ID, 'fcs_tl_kontakte', true );
	if ( false !== strpos( $kontrolle, 'Sandro_Zamuner.jpg' )
	  && false !== strpos( $kontrolle, 'Rene_Gnos_hoch.jpg' ) ) {
		echo "\nOK – $geaendert Zeile(n) ergänzt und zurückgelesen.\n";
	} else {
		echo "\nFEHLER – der zurückgelesene Wert passt nicht. Bitte im Admin prüfen.\n";
	}
}

fcs_tl_bilder( $dry );

/* ── Selbst löschen ─────────────────────────────────────────────── */
if ( ! $dry ) {
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
