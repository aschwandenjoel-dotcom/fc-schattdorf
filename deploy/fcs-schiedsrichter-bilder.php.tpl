<?php
/**
 * Einmal-Skript: Fotos für Ayman Labib Badr und Giuseppe Accardi.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Setzt bei beiden Personen das Feld fcs_pe_bild auf die Datei in
 * uploads/2026/06 (Schritt 1 des Deploy-Skripts überträgt sie).
 *
 * Die vier übrigen Schiedsrichter-Fotos aus dem Redaktions-Ordner sind
 * dieselben Aufnahmen, die schon live liegen — sie werden nicht
 * angefasst. Ukaj Alex hat weiterhin kein Foto.
 *
 * Schutz gegen Überschreiben: geschrieben wird nur, wenn das Feld leer
 * ist. Trägt es schon etwas anderes, meldet das Skript das und lässt
 * es stehen. Idempotent: ein zweiter Lauf meldet «SKIP».
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
 * Ordnet die Fotos zu. Als Funktion, damit jeder Abbruch ein
 * schlichtes return ist — das Löschen am Ende läuft trotzdem.
 */
function fcs_sr_bilder( $dry ) {

	$zuordnung = array(
		'Ayman Labib Badr' => 'Ayman_Labib_Badr.jpg',
		'Giuseppe Accardi' => 'Giuseppe_Accardi.jpg',
	);

	$geaendert = 0;

	foreach ( $zuordnung as $name => $datei ) {
		$treffer = get_posts( array(
			'post_type'      => 'fcs_person',
			'post_status'    => array( 'publish', 'draft', 'pending' ),
			'posts_per_page' => -1,
			'title'          => $name,
			'fields'         => 'ids',
		) );

		if ( ! $treffer ) {
			echo "   FEHLT – «{$name}» ist als Person nicht angelegt.\n";
			continue;
		}
		if ( count( $treffer ) > 1 ) {
			echo "   MEHRDEUTIG – «{$name}» existiert " . count( $treffer ) . "x (#" . implode( ', #', $treffer ) . "); nichts geändert.\n";
			continue;
		}

		$id  = $treffer[0];
		$alt = trim( (string) get_post_meta( $id, 'fcs_pe_bild', true ) );

		if ( $alt === $datei ) {
			echo "   SKIP – «{$name}» (#{$id}) hat bereits {$datei}.\n";
			continue;
		}
		if ( '' !== $alt ) {
			echo "   ACHTUNG – «{$name}» (#{$id}) trägt bereits «{$alt}»; nicht überschrieben.\n";
			continue;
		}

		if ( $dry ) {
			echo "   WÜRDE SETZEN – «{$name}» (#{$id}) -> {$datei}\n";
		} else {
			update_post_meta( $id, 'fcs_pe_bild', $datei );
			clean_post_cache( $id );
			$kontrolle = trim( (string) get_post_meta( $id, 'fcs_pe_bild', true ) );
			echo $kontrolle === $datei
				? "   gesetzt – «{$name}» (#{$id}) -> {$datei}\n"
				: "   FEHLER – «{$name}» (#{$id}) liest «{$kontrolle}» zurück.\n";
		}
		$geaendert++;
	}

	echo $geaendert ? "\nFertig: {$geaendert} Zuordnung(en).\n" : "\nNichts zu tun.\n";
}

fcs_sr_bilder( $dry );

/* ── Selbst löschen ─────────────────────────────────────────────── */
if ( ! $dry ) {
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
