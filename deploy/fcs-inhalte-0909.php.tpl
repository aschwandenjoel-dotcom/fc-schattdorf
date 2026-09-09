<?php
/**
 * Einmal-Skript: Redaktions-Nachträge vom 09.09.2026.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Was es tut:
 *
 *   A) Veranstaltungen: die vergangene «93. Generalversammlung»
 *      (21.08.2026) in den Papierkorb legen und die sechs neuen
 *      Termine bis Dezember 2027 anlegen. Das Grümpelturnier bekommt
 *      ein Enddatum (fcs_ev_datum_bis), damit es über alle drei Tage
 *      stehen bleibt.
 *   B) Sponsoren: Website-Link bei «Zurich Insurance» und
 *      «Duftruim» hinterlegen, bei Duftruim ausserdem das graue Logo
 *      durch das farbige ersetzen.
 *   C) Vorstand: Porträt von Robin Lindauer (bisher Silhouette) als
 *      Mediathek-Eintrag anlegen und in die Seite setzen; das neue
 *      Foto von Claudia Gisler liegt unter demselben Dateinamen wie
 *      bisher, deshalb dort nur die Vorschaugrössen neu rechnen.
 *   D) 2. Mannschaft: Betreuerbild von Robin Lindauer im Seitenfeld
 *      «Betreuerstab» von der Silhouette auf das Porträt umstellen.
 *   E) Fussballschule: Nico Zgraggen aus dem Betreuerteam nehmen.
 *
 * Die Bilddateien überträgt das aufrufende Shell-Skript vorher per
 * scp; dieses Skript prüft nur noch, ob sie da sind.
 *
 * Idempotent: ein zweiter Lauf meldet überall «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
require_once ABSPATH . 'wp-admin/includes/image.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 300 );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler = 0;
$updir  = wp_upload_dir();
$mdir   = $updir['basedir'] . '/2026/06/';
$murl   = $updir['baseurl'] . '/2026/06/';

/* ── 0) Bilddateien müssen vor dem Schreiben da sein ────────────── */
echo "0) Bilddateien in uploads/2026/06\n";
$noetig = array( 'Robin_Lindauer.jpg', 'Claudia_Gisler.jpg', 'duftruim-2026.png', 'muoser-weiss.png' );
$fehlt  = array();
foreach ( $noetig as $datei ) {
	if ( ! file_exists( $mdir . $datei ) ) { $fehlt[] = $datei; }
}
if ( $fehlt ) {
	echo '   FEHLER – diese Dateien fehlen: ' . implode( ', ', $fehlt ) . "\n";
	echo "            Ohne sie zeigten die Seiten leere Kästen. Abbruch.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo '   OK – alle ' . count( $noetig ) . " Dateien sind da.\n";

/* ── A) Veranstaltungen ─────────────────────────────────────────── */
echo "\nA) Veranstaltungen\n";

/* A1: vergangene Generalversammlung in den Papierkorb.
   Bewusst kein endgültiges Löschen — im Papierkorb bleibt sie für die
   Redaktion wiederherstellbar; von der Website ist sie so oder so weg. */
$gv = get_posts( array(
	'post_type'      => 'fcs_event',
	'post_status'    => 'publish',
	'posts_per_page' => -1,
	'title'          => '93. Generalversammlung',
	'fields'         => 'ids',
) );
if ( ! $gv ) {
	echo "   SKIP – «93. Generalversammlung» ist nicht mehr veröffentlicht.\n";
} else {
	foreach ( $gv as $id ) {
		$datum = get_post_meta( $id, 'fcs_ev_datum', true );
		/* Guard: nur den vergangenen Termin anfassen, nie einen
		   künftigen, den die Redaktion inzwischen erfasst hat. */
		if ( '2026-08-21' !== $datum ) {
			echo "   HINWEIS – #{$id} hat Datum «{$datum}», nicht 2026-08-21. Bleibt stehen.\n";
			continue;
		}
		echo '   ' . ( $dry ? 'würde in den Papierkorb legen: ' : 'in den Papierkorb gelegt: ' ) . "#{$id} 93. Generalversammlung (21.08.2026)\n";
		if ( ! $dry ) { wp_trash_post( $id ); }
	}
}

/* A2: Titel nachziehen, falls dieser Deploy schon einmal mit der
   früheren Schreibweise gelaufen ist. So kommt dasselbe Ergebnis
   heraus, egal ob das Skript zum ersten oder zum zweiten Mal läuft. */
$alt_titel = get_posts( array(
	'post_type'      => 'fcs_event',
	'post_status'    => array( 'publish', 'draft', 'pending' ),
	'posts_per_page' => -1,
	'title'          => 'Ehren-/Freimitglieder- und Sponsorenapéro',
	'fields'         => 'ids',
) );
if ( ! $alt_titel ) {
	echo "   SKIP – kein Termin mit der früheren Schreibweise «Freimitglieder- und».\n";
} else {
	foreach ( $alt_titel as $id ) {
		echo '   ' . ( $dry ? 'würde umbenennen: ' : 'umbenannt: ' )
			. "#{$id} -> «Ehren-/Freimitglieder und Sponsorenapéro»\n";
		if ( ! $dry ) {
			wp_update_post( array( 'ID' => $id, 'post_title' => 'Ehren-/Freimitglieder und Sponsorenapéro' ) );
		}
	}
}

/* A3: die neuen Termine. Reihenfolge = Datum; die Vorlage sortiert
   selbst, die Liste steht hier nur der Lesbarkeit halber chronologisch.
   Leere Felder bleiben leer — «Wird bekannt gegeben» nur dort, wo die
   Angabe wirklich noch aussteht (gleiche Schreibweise wie bisher). */
$neue = array(
	array(
		'titel'    => 'Vorrundenabschluss',
		'datum'    => '2026-10-24',
		'zeit'     => 'ab 17.00 Uhr',
		'ort'      => 'Sportplatz Grüner Wald, Schattdorf',
		'ort_kurz' => 'Grüner Wald',
	),
	array(
		'titel'    => 'Weihnachtsfeier',
		'datum'    => '2026-11-28',
		'zeit'     => 'ab 18.00 Uhr',
		'ort'      => 'Uristier-Saal, Altdorf',
		'ort_kurz' => 'Uristier-Saal',
	),
	array(
		/* Schreibweise wie von der Redaktion geliefert – ohne Bindestrich
		   nach «Freimitglieder» (Rückmeldung vom 09.09.2026). */
		'titel'    => 'Ehren-/Freimitglieder und Sponsorenapéro',
		'datum'    => '2027-04-24',
		'zeit'     => 'Wird bekannt gegeben',
		'zeit_kurz'=> 'Zeit folgt',
		'ort'      => 'Wird bekannt gegeben',
		'ort_kurz' => 'Ort folgt',
	),
	array(
		'titel'    => 'Kick-in-one',
		'datum'    => '2027-05-27',
		'zeit'     => 'Wird bekannt gegeben',
		'zeit_kurz'=> 'Zeit folgt',
		'ort'      => 'Sportplatz Grüner Wald, Schattdorf',
		'ort_kurz' => 'Grüner Wald',
	),
	array(
		'titel'     => 'Dorf- und Grümpelturnier',
		'datum'     => '2027-06-17',
		'datum_bis' => '2027-06-19',
		'zeit'      => 'Wird bekannt gegeben',
		'zeit_kurz' => 'Zeit folgt',
		'ort'       => 'Sportplatz Grüner Wald, Schattdorf',
		'ort_kurz'  => 'Grüner Wald',
	),
	array(
		'titel'    => 'Weihnachtsfeier',
		'datum'    => '2027-12-04',
		'zeit'     => 'Wird bekannt gegeben',
		'zeit_kurz'=> 'Zeit folgt',
		'ort'      => 'Uristier-Saal, Altdorf',
		'ort_kurz' => 'Uristier-Saal',
	),
);

foreach ( $neue as $ev ) {
	/* Idempotenz über das DATUM, nicht über den Titel: jeder der sechs
	   Termine hat ein eigenes Datum (auch die zwei Weihnachtsfeiern),
	   und so legt das Skript auch dann nichts doppelt an, wenn der Titel
	   inzwischen anders lautet — sei es durch A2 oder weil die Redaktion
	   ihn von Hand geändert hat. */
	$vorhanden = get_posts( array(
		'post_type'      => 'fcs_event',
		'post_status'    => array( 'publish', 'draft', 'pending', 'trash' ),
		'posts_per_page' => -1,
		'meta_query'     => array( array( 'key' => 'fcs_ev_datum', 'value' => $ev['datum'] ) ),
	) );
	if ( $vorhanden ) {
		foreach ( $vorhanden as $p ) {
			echo "   SKIP – am {$ev['datum']} steht schon «" . get_the_title( $p ) . "» (#{$p->ID}).\n";
		}
		continue;
	}
	echo '   ' . ( $dry ? 'würde anlegen: ' : 'angelegt: ' ) . "{$ev['datum']}"
		. ( isset( $ev['datum_bis'] ) ? '…' . $ev['datum_bis'] : '' ) . "  {$ev['titel']}\n";
	if ( $dry ) { continue; }

	$id = wp_insert_post( array(
		'post_type'   => 'fcs_event',
		'post_status' => 'publish',
		'post_title'  => $ev['titel'],
		'post_content'=> '',
	), true );
	if ( is_wp_error( $id ) ) {
		echo '   FEHLER – anlegen fehlgeschlagen: ' . $id->get_error_message() . "\n";
		$fehler++;
		continue;
	}
	update_post_meta( $id, 'fcs_ev_datum', $ev['datum'] );
	update_post_meta( $id, 'fcs_ev_datum_bis', $ev['datum_bis'] ?? '' );
	update_post_meta( $id, 'fcs_ev_zeit', $ev['zeit'] ?? '' );
	update_post_meta( $id, 'fcs_ev_zeit_kurz', $ev['zeit_kurz'] ?? '' );
	update_post_meta( $id, 'fcs_ev_ort', $ev['ort'] ?? '' );
	update_post_meta( $id, 'fcs_ev_ort_kurz', $ev['ort_kurz'] ?? '' );
	update_post_meta( $id, 'fcs_ev_zielgruppe', '' );
	update_post_meta( $id, 'fcs_ev_status', '' );
	update_post_meta( $id, 'fcs_ev_ausgabe', '' );
	update_post_meta( $id, 'fcs_ev_agenda_titel', '' );
	update_post_meta( $id, 'fcs_ev_agenda', '' );
}

/* ── B) Sponsoren: Links und Logo ───────────────────────────────── */
echo "\nB) Sponsoren\n";

$sponsoren = array(
	'Zurich Insurance' => array(
		'url' => 'https://www.zurich.ch/de/standorte/generalagentur-simon-mani-6010-kriens',
	),
	'Duftruim' => array(
		'url'  => 'https://www.duftruim.com/',
		'logo' => 'duftruim-2026.png',
	),
);
foreach ( $sponsoren as $name => $soll ) {
	$treffer = get_posts( array(
		'post_type'      => 'fcs_sponsor',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'title'          => $name,
		'fields'         => 'ids',
	) );
	if ( ! $treffer ) {
		echo "   FEHLER – Sponsor «{$name}» nicht gefunden.\n";
		$fehler++;
		continue;
	}
	foreach ( $treffer as $id ) {
		foreach ( array( 'url' => 'fcs_sp_url', 'logo' => 'fcs_sp_logo' ) as $k => $meta_key ) {
			if ( ! isset( $soll[ $k ] ) ) { continue; }
			$ist = (string) get_post_meta( $id, $meta_key, true );
			if ( $ist === $soll[ $k ] ) {
				echo "   SKIP – {$name} #{$id}: {$meta_key} steht schon auf «{$soll[$k]}».\n";
				continue;
			}
			echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' )
				. "{$name} #{$id} {$meta_key}: «{$ist}» -> «{$soll[$k]}»\n";
			if ( ! $dry ) { update_post_meta( $id, $meta_key, $soll[ $k ] ); }
		}
	}
}

/* ── C) Vorstand: Porträts Robin Lindauer und Claudia Gisler ────── */
echo "\nC) Vorstand\n";

/* C1: Claudia Gisler — das neue Foto liegt unter demselben Dateinamen
   (1280x1920 wie bisher), die Seite muss also nicht angefasst werden.
   Neu gerechnet werden die Vorschaugrössen, sonst zeigt der srcset-
   Eintrag der Mediathek weiter Ausschnitte des alten Bildes. */
$claudia = get_posts( array(
	'post_type'      => 'attachment',
	'post_status'    => 'inherit',
	'posts_per_page' => 1,
	'fields'         => 'ids',
	'meta_query'     => array( array( 'key' => '_wp_attached_file', 'value' => '2026/06/Claudia_Gisler.jpg' ) ),
) );
if ( ! $claudia ) {
	echo "   FEHLER – Mediathek-Eintrag zu Claudia_Gisler.jpg nicht gefunden.\n";
	$fehler++;
} else {
	$cid = (int) $claudia[0];
	echo '   ' . ( $dry ? 'würde Vorschaugrössen neu rechnen: ' : 'Vorschaugrössen neu gerechnet: ' ) . "#{$cid} Claudia_Gisler.jpg\n";
	if ( ! $dry ) {
		$meta = wp_generate_attachment_metadata( $cid, $mdir . 'Claudia_Gisler.jpg' );
		if ( is_wp_error( $meta ) || ! $meta ) {
			echo "   FEHLER – Vorschaugrössen liessen sich nicht rechnen.\n";
			$fehler++;
		} else {
			wp_update_attachment_metadata( $cid, $meta );
		}
	}
}

/* C2: Robin Lindauer — Porträt als Mediathek-Eintrag anlegen (damit
   die Redaktion es findet und WordPress passende Vorschaugrössen
   ausspielt) und in der Seite die Silhouette ersetzen. */
$robin = get_posts( array(
	'post_type'      => 'attachment',
	'post_status'    => 'inherit',
	'posts_per_page' => 1,
	'fields'         => 'ids',
	'meta_query'     => array( array( 'key' => '_wp_attached_file', 'value' => '2026/06/Robin_Lindauer.jpg' ) ),
) );
$rid = $robin ? (int) $robin[0] : 0;
if ( $rid ) {
	echo "   SKIP – Mediathek-Eintrag zu Robin_Lindauer.jpg gibt es schon (#{$rid}).\n";
} elseif ( $dry ) {
	echo "   würde Mediathek-Eintrag «Robin Lindauer» anlegen (Robin_Lindauer.jpg).\n";
} else {
	$rid = wp_insert_attachment( array(
		'post_mime_type' => 'image/jpeg',
		'post_title'     => 'Robin Lindauer',
		'post_status'    => 'inherit',
	), $mdir . 'Robin_Lindauer.jpg', 0, true );
	if ( is_wp_error( $rid ) ) {
		echo '   FEHLER – Mediathek-Eintrag fehlgeschlagen: ' . $rid->get_error_message() . "\n";
		$fehler++;
		$rid = 0;
	} else {
		wp_update_attachment_metadata( $rid, wp_generate_attachment_metadata( $rid, $mdir . 'Robin_Lindauer.jpg' ) );
		echo "   angelegt: Mediathek-Eintrag «Robin Lindauer» (#{$rid}).\n";
	}
}

$seite = get_page_by_path( 'verein/vorstand' );
if ( ! $seite ) { $seite = get_page_by_path( 'vorstand' ); }
if ( ! $seite ) {
	echo "   FEHLER – Vorstandsseite nicht gefunden.\n";
	$fehler++;
} else {
	$alt = $seite->post_content;
	/* Nur im <figure>-Block mit alt="Robin Lindauer" arbeiten, damit
	   die Silhouette anderer Personen unberührt bleibt. */
	$neu = preg_replace_callback(
		'#<figure\b[^>]*>.*?</figure>#s',
		function ( $treffer ) use ( $rid ) {
			$block = $treffer[0];
			if ( false === strpos( $block, 'alt="Robin Lindauer"' )
				|| false === strpos( $block, 'Silhouette_Male' ) ) {
				return $block;
			}
			return '<figure class="wp-block-image size-full"><img src="'
				. esc_url( wp_upload_dir()['baseurl'] . '/2026/06/Robin_Lindauer.jpg' )
				. '" alt="Robin Lindauer"'
				. ( $rid ? ' class="wp-image-' . (int) $rid . '"' : '' )
				. ' width="1280" height="1920" /></figure>';
		},
		$alt
	);
	if ( null === $neu ) {
		echo "   FEHLER – Umschreiben fehlgeschlagen, Seite unverändert.\n";
		$fehler++;
	} elseif ( $neu === $alt ) {
		echo "   SKIP – Vorstandsseite zeigt bei Robin Lindauer schon kein Silhouetten-Bild mehr.\n";
	} else {
		echo '   ' . ( $dry ? 'würde tauschen: ' : 'getauscht: ' ) . "Silhouette -> Robin_Lindauer.jpg (Seite #{$seite->ID})\n";
		if ( ! $dry ) {
			$ok = wp_update_post( array( 'ID' => $seite->ID, 'post_content' => $neu ), true );
			if ( is_wp_error( $ok ) ) {
				echo '   FEHLER – Speichern fehlgeschlagen: ' . $ok->get_error_message() . "\n";
				$fehler++;
			}
		}
	}
}

/* ── D) 2. Mannschaft: Betreuerbild Robin Lindauer ──────────────── */
echo "\nD) 2. Mannschaft\n";

$m2 = get_page_by_path( 'aktive/2-mannschaft' );
if ( ! $m2 ) { $m2 = get_page_by_path( '2-mannschaft' ); }
if ( ! $m2 ) {
	echo "   FEHLER – Seite «2. Mannschaft» nicht gefunden.\n";
	$fehler++;
} else {
	$feld = (string) get_post_meta( $m2->ID, 'fcs_team_staff', true );
	if ( '' === $feld ) {
		echo "   SKIP – Seitenfeld «Betreuerstab» ist leer, es gilt der Stand aus der Vorlage.\n";
	} else {
		/* Nur die Zeile von Robin Lindauer anfassen – Roger Zurfluh
		   behält seine Silhouette, solange kein Foto vorliegt. */
		$neu_feld = preg_replace(
			'#^(\s*Betreuer\s*\|\s*Robin Lindauer\s*\|\s*)Silhouette_Male[^|\r\n]*#mi',
			'$1Robin_Lindauer.jpg',
			$feld
		);
		if ( null === $neu_feld ) {
			echo "   FEHLER – Umschreiben fehlgeschlagen, Feld unverändert.\n";
			$fehler++;
		} elseif ( $neu_feld === $feld ) {
			echo "   SKIP – bei Robin Lindauer steht dort schon keine Silhouette mehr.\n";
		} else {
			echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "Betreuerstab, Robin Lindauer -> Robin_Lindauer.jpg\n";
			if ( ! $dry ) { update_post_meta( $m2->ID, 'fcs_team_staff', $neu_feld ); }
		}
	}
}

/* ── E) Fussballschule: Nico Zgraggen aus dem Betreuerteam ──────── */
echo "\nE) Fussballschule\n";

$fs = get_page_by_path( 'junioren/fussballschule' );
if ( ! $fs ) { $fs = get_page_by_path( 'fussballschule' ); }
if ( ! $fs ) {
	echo "   FEHLER – Seite «Fussballschule» nicht gefunden.\n";
	$fehler++;
} else {
	$feld = (string) get_post_meta( $fs->ID, 'fcs_fs_team', true );
	if ( '' === $feld ) {
		echo "   SKIP – Seitenfeld «Team» ist leer, es gilt der Stand aus der Vorlage.\n";
	} else {
		/* Eine Person pro Zeile («Name | Rolle | Bild»). Gestrichen wird
		   genau die Zeile, die mit «Nico Zgraggen |» beginnt – der
		   gleichnamige Spieler der 1. Mannschaft steht woanders. */
		$zeilen = preg_split( '/\r\n|\r|\n/', $feld );
		$rest   = array_values( array_filter( $zeilen, function ( $z ) {
			return ! preg_match( '/^\s*Nico Zgraggen\s*\|/i', $z );
		} ) );
		$neu_feld = implode( "\n", $rest );
		if ( $neu_feld === $feld ) {
			echo "   SKIP – Nico Zgraggen steht dort nicht (mehr).\n";
		} elseif ( count( $rest ) !== count( $zeilen ) - 1 ) {
			echo '   FEHLER – erwartet war genau eine Zeile weniger, entfernt wurden '
				. ( count( $zeilen ) - count( $rest ) ) . ". Feld unverändert.\n";
			$fehler++;
		} else {
			echo '   ' . ( $dry ? 'würde entfernen: ' : 'entfernt: ' )
				. 'Nico Zgraggen (' . count( $zeilen ) . ' -> ' . count( $rest ) . " Personen)\n";
			if ( ! $dry ) { update_post_meta( $fs->ID, 'fcs_fs_team', $neu_feld ); }
		}
	}
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
