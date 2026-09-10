<?php
/**
 * Einmal-Skript: Redaktions-Nachträge vom 10.09.2026.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Was es tut:
 *
 *   A) Drei neue Beiträge aus news-import-1009.json anlegen —
 *      Matchvorschau gegen den FC Gunzwil (1. Mannschaft), Bericht
 *      Team Uri Frauen und Spielbericht der Cb-Junioren. Aufbau wie
 *      beim Nachtrag vom 07.09.: Bildblock, Fliesstext, fett
 *      ausgezeichnete Absätze der Quelle als <h3>-Zwischentitel.
 *   B) Neues Teamfoto der Ba-Junioren: Seitenfeld «Teamfoto» der
 *      Ba-Seite (wirkt zugleich auf die Teams-Übersicht) und Bild im
 *      letzten Ba-Beitrag «Erneute Niederlage für die Ba-Junioren».
 *   C) Erstes Teamfoto für Team Uri FF14 (bisher Platzhalter).
 *
 * Die Bilddateien überträgt das aufrufende Shell-Skript vorher per
 * scp; dieses Skript prüft nur noch, ob sie da sind.
 *
 * Idempotent: bestehende Beiträge werden am Slug erkannt und
 * übersprungen, gesetzte Felder melden «SKIP». Zweiter Lauf ändert
 * nichts.
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
require_once ABSPATH . 'wp-admin/includes/image.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 600 );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler  = 0;
$updir   = wp_upload_dir();

/* News-Bilder liegen im Monatsordner, Teamfotos in 2026/06 (dort sucht
   das Seitenfeld «Teamfoto» der Junioren-Vorlage). */
$news_ordner  = '2026/09';
$news_basedir = $updir['basedir'] . '/' . $news_ordner . '/';
$news_baseurl = $updir['baseurl'] . '/' . $news_ordner . '/';
$team_basedir = $updir['basedir'] . '/2026/06/';

/** Anhang zu einer bereits hochgeladenen Datei finden oder anlegen. */
function fcs_anhang( $datei, $titel, $ordner, $basedir, $baseurl, $dry ) {
	if ( '' === $datei ) { return 0; }
	$pfad = $basedir . $datei;
	if ( ! file_exists( $pfad ) ) {
		echo "   FEHLER – Datei fehlt: uploads/{$ordner}/{$datei}\n";
		return -1;
	}
	$vorhanden = get_posts( array(
		'post_type'   => 'attachment', 'post_status' => 'inherit', 'posts_per_page' => 1,
		'meta_key'    => '_wp_attached_file', 'meta_value' => $ordner . '/' . $datei,
		'fields'      => 'ids',
	) );
	if ( $vorhanden ) { return (int) $vorhanden[0]; }
	if ( $dry ) { return 0; }

	$typ = wp_check_filetype( $datei, null );
	$id  = wp_insert_attachment( array(
		'guid'           => $baseurl . $datei,
		'post_mime_type' => $typ['type'] ? $typ['type'] : 'image/jpeg',
		'post_title'     => $titel,
		'post_content'   => '',
		'post_status'    => 'inherit',
	), $pfad, 0, true );
	if ( is_wp_error( $id ) ) { echo "   FEHLER Anhang «{$datei}»: " . $id->get_error_message() . "\n"; return -1; }
	wp_update_attachment_metadata( $id, wp_generate_attachment_metadata( $id, $pfad ) );
	return (int) $id;
}

/* ── 0) Bilddateien müssen vor dem Schreiben da sein ────────────── */
echo "0) Bilddateien\n";
$noetig = array(
	$news_basedir . 'Ba_Junioren_26-27.jpg',
	$news_basedir . 'Cb_Junioren_25-26.jpg',
	$news_basedir . 'Team_Uri_Frauen_09-09-2026.jpg',
	$news_basedir . 'FCS_1_Team_Web.jpg',
	$news_basedir . 'Team_Uri_Frauen_Team_26-27.jpg',
	$team_basedir . 'Ba_Junioren_26-27.jpg',
	$team_basedir . 'FF14_Team_26-27.jpg',
);
$fehlt = array();
foreach ( $noetig as $pfad ) {
	if ( ! file_exists( $pfad ) ) { $fehlt[] = str_replace( $updir['basedir'] . '/', '', $pfad ); }
}
if ( $fehlt ) {
	echo '   FEHLER – diese Dateien fehlen: ' . implode( ', ', $fehlt ) . "\n";
	echo "            Ohne sie zeigten die Seiten leere Kästen. Abbruch.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo '   OK – alle ' . count( $noetig ) . " Dateien sind da.\n";

/* ── A) Neue Beiträge ───────────────────────────────────────────── */
echo "\nA) Neue Beiträge\n";

$daten = json_decode( (string) @file_get_contents( __DIR__ . '/news-import-1009.json' ), true );
if ( ! is_array( $daten ) || ! $daten ) {
	echo "   FEHLER – news-import-1009.json fehlt oder ist unlesbar.\n";
	$fehler++;
	$daten = array();
}

foreach ( $daten as $e ) {
	$slug = sanitize_title( $e['slug'] );
	echo "· {$e['datum']}  {$e['titel']}\n";

	$da = get_posts( array( 'post_type' => 'post', 'post_status' => 'any', 'name' => $slug, 'posts_per_page' => 1, 'fields' => 'ids' ) );
	if ( $da ) { echo "   SKIP – existiert bereits (#{$da[0]}).\n"; continue; }

	$bild_id = fcs_anhang( $e['bild'], $e['titel'], $news_ordner, $news_basedir, $news_baseurl, $dry );
	if ( -1 === $bild_id ) { $fehler++; continue; }

	/* Inhalt als Gutenberg-Blöcke, wie die bestehenden Beiträge. */
	$bloecke = array();
	if ( $bild_id > 0 ) {
		$url = wp_get_attachment_url( $bild_id );
		$bloecke[] = '<!-- wp:image {"id":' . $bild_id . ',"sizeSlug":"large","linkDestination":"none"} -->' . "\n"
			. '<figure class="wp-block-image size-large"><img src="' . esc_url( $url ) . '" alt="' . esc_attr( $e['titel'] ) . '" class="wp-image-' . $bild_id . '" /></figure>' . "\n"
			. '<!-- /wp:image -->';
	}
	$zwischentitel = isset( $e['zwischentitel'] ) ? (array) $e['zwischentitel'] : array();
	foreach ( $e['absaetze'] as $absatz ) {
		if ( in_array( $absatz, $zwischentitel, true ) ) {
			$bloecke[] = "<!-- wp:heading {\"level\":3} -->\n<h3 class=\"wp-block-heading\">"
				. esc_html( $absatz ) . "</h3>\n<!-- /wp:heading -->";
		} else {
			$bloecke[] = "<!-- wp:paragraph -->\n<p>" . esc_html( $absatz ) . "</p>\n<!-- /wp:paragraph -->";
		}
	}

	/* Ein Datum in der Zukunft würde WordPress zu einem geplanten
	   Beitrag machen — dann stünde er nicht auf der Website. */
	$datum = $e['datum'];
	if ( strtotime( $datum ) > strtotime( current_time( 'mysql' ) ) ) {
		echo "   HINWEIS – {$datum} liegt in der Zukunft, nehme die aktuelle Zeit.\n";
		$datum = current_time( 'mysql' );
	}

	if ( $dry ) {
		echo "   würde anlegen: Kategorie «{$e['kategorie']}», "
		   . count( $e['absaetze'] ) . " Absätze (davon "
		   . count( $zwischentitel ) . " Zwischentitel), Bild "
		   . ( $e['bild'] ? $e['bild'] : 'keines' )
		   . ( empty( $e['beitragsbild'] ) ? '' : ", Beitragsbild {$e['beitragsbild']}" ) . "\n";
		continue;
	}

	/* Optional ein eigenes Beitragsbild: das steckt im Hero der
	   Startseite und in den News-Kacheln. Der Frauen-Bericht nutzt das,
	   weil sein Artikelbild hochkant ist — im breiten Hero bliebe davon
	   nur ein schmaler Streifen sichtbar, stark vergroessert. */
	$thumb_id = $bild_id;
	if ( ! empty( $e['beitragsbild'] ) ) {
		$eigenes = fcs_anhang( $e['beitragsbild'], $e['titel'], $news_ordner, $news_basedir, $news_baseurl, $dry );
		if ( -1 === $eigenes ) { $fehler++; continue; }
		if ( $eigenes > 0 ) { $thumb_id = $eigenes; }
	}

	$kat = get_term_by( 'name', $e['kategorie'], 'category' );
	/* Das Beitragsbild geht als meta_input mit in wp_insert_post statt
	   per set_post_thumbnail danach. Grund: Yoast baut seine
	   Indexable-Zeile (und damit das og:image) waehrend des Speicherns.
	   Nachtraeglich gesetzt, kennt Yoast das Bild noch nicht und nimmt
	   das erste Bild im Text — beim Frauen-Bericht also das hochkante
	   Jubelbild statt des Mannschaftsfotos. */
	$id = wp_insert_post( array(
		'post_type'     => 'post',
		'post_status'   => 'publish',
		'post_title'    => $e['titel'],
		'post_name'     => $slug,
		'post_date'     => $datum,
		'post_content'  => implode( "\n\n", $bloecke ),
		'post_category' => $kat ? array( (int) $kat->term_id ) : array(),
		'meta_input'    => $thumb_id > 0 ? array( '_thumbnail_id' => $thumb_id ) : array(),
	), true );
	if ( is_wp_error( $id ) ) { echo '   FEHLER: ' . $id->get_error_message() . "\n"; $fehler++; continue; }
	echo "   angelegt: #{$id}, Kategorie «{$e['kategorie']}»"
		. ( $thumb_id !== $bild_id ? ", Beitragsbild {$e['beitragsbild']}" : '' ) . "\n";
}

/* ── Helfer: Seitenfeld «Teamfoto» einer Junioren-Seite setzen ──── */
function fcs_teamfoto( $pfade, $datei, $bezeichnung, $dry, &$fehler ) {
	$seite = null;
	foreach ( (array) $pfade as $pfad ) {
		$seite = get_page_by_path( $pfad );
		if ( $seite ) { break; }
	}
	if ( ! $seite ) {
		echo "   FEHLER – Seite «{$bezeichnung}» nicht gefunden.\n";
		$fehler++;
		return;
	}
	$ist = (string) get_post_meta( $seite->ID, 'fcs_jt_foto', true );
	if ( $ist === $datei ) {
		echo "   SKIP – {$bezeichnung} #{$seite->ID}: Teamfoto steht schon auf «{$datei}».\n";
		return;
	}
	echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' )
		. "{$bezeichnung} #{$seite->ID} Teamfoto: «" . ( '' === $ist ? '— (Platzhalter)' : $ist ) . "» -> «{$datei}»\n";
	if ( ! $dry ) { update_post_meta( $seite->ID, 'fcs_jt_foto', $datei ); }
}

/* ── B) Ba-Junioren: neues Teamfoto ─────────────────────────────── */
echo "\nB) Ba-Junioren\n";

fcs_teamfoto( array( 'junioren/teams/junioren-b-junioren-a', 'junioren-b-junioren-a' ), 'Ba_Junioren_26-27.jpg', 'Ba-Junioren', $dry, $fehler );

/* Letzter Ba-Beitrag: Bildblock und Beitragsbild auf das neue Foto.
   Der Beitrag trug bisher Ba-GeringQWEB.jpg (Spielszene aus dem
   Nachtrag vom 07.09.), gewünscht ist das frische Mannschaftsfoto. */
$ba_post = get_posts( array(
	'post_type' => 'post', 'post_status' => 'any', 'posts_per_page' => 1,
	'name' => 'erneute-niederlage-fuer-die-ba-junioren',
) );
if ( ! $ba_post ) {
	echo "   FEHLER – Beitrag «Erneute Niederlage für die Ba-Junioren» nicht gefunden.\n";
	$fehler++;
} else {
	$post    = $ba_post[0];
	$bild_id = fcs_anhang( 'Ba_Junioren_26-27.jpg', 'Ba-Junioren 2026/27', $news_ordner, $news_basedir, $news_baseurl, $dry );
	if ( -1 === $bild_id ) {
		$fehler++;
	} elseif ( 0 === $bild_id && $dry ) {
		echo "   würde Mediathek-Eintrag «Ba-Junioren 2026/27» anlegen und im Beitrag #{$post->ID} setzen.\n";
	} else {
		$url = wp_get_attachment_url( $bild_id );
		$neu = preg_replace_callback(
			'#<!-- wp:image .*?<!-- /wp:image -->#s',
			function ( $treffer ) use ( $bild_id, $url, $post ) {
				return '<!-- wp:image {"id":' . $bild_id . ',"sizeSlug":"large","linkDestination":"none"} -->' . "\n"
					. '<figure class="wp-block-image size-large"><img src="' . esc_url( $url )
					. '" alt="' . esc_attr( get_the_title( $post ) ) . '" class="wp-image-' . $bild_id . '" /></figure>' . "\n"
					. '<!-- /wp:image -->';
			},
			$post->post_content,
			1
		);
		$thumb_ist = (int) get_post_thumbnail_id( $post->ID );
		if ( null === $neu ) {
			echo "   FEHLER – Bildblock liess sich nicht ersetzen.\n";
			$fehler++;
		} elseif ( $neu === $post->post_content && $thumb_ist === $bild_id ) {
			echo "   SKIP – Beitrag #{$post->ID} zeigt schon das neue Teamfoto.\n";
		} else {
			echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' )
				. "Beitrag #{$post->ID} Bild -> Ba_Junioren_26-27.jpg (Anhang #{$bild_id})\n";
			if ( ! $dry ) {
				/* Reihenfolge ist wichtig: erst das Beitragsbild, dann
				   wp_update_post. Yoast legt das og:image-Bild in seiner
				   Indexable-Tabelle ab und rechnet es beim Speichern des
				   Beitrags neu. Andersherum bliebe dort das alte Bild
				   stehen — die Seite selbst zeigte das neue, geteilte
				   Links auf Facebook und WhatsApp aber weiter das alte. */
				set_post_thumbnail( $post->ID, $bild_id );
				wp_update_post( array( 'ID' => $post->ID, 'post_content' => $neu ) );
			}
		}
	}
}

/* ── C) Team Uri FF14: erstes Teamfoto ──────────────────────────── */
echo "\nC) Team Uri FF14\n";

fcs_teamfoto( array( 'junioren/teams/team-uri-ff14', 'team-uri-ff14' ), 'FF14_Team_26-27.jpg', 'Team Uri FF14', $dry, $fehler );

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __DIR__ . '/news-import-1009.json' );
	@unlink( __FILE__ );
	echo "\nSkript und Datenliste haben sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
