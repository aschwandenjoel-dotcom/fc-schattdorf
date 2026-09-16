<?php
/**
 * Einmal-Skript: Redaktions-Nachträge vom 16.09.2026.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Was es tut:
 *
 *   A) Einen neuen Beitrag aus news-import-1609.json anlegen —
 *      Spielbericht der Ca-Junioren «Weiter ohne Verlustpunkte»
 *      (FC Schattdorf Ca – FC Stans Ca 17:1 vom 12.09.2026). Im
 *      Artikel die Spielszene; als Beitragsbild (Hero der Startseite,
 *      News-Kacheln) das Mannschaftsfoto der Ca — der Hero zeigt auf
 *      dem Telefon nur den mittleren Drittel eines Querformats, die
 *      Spielszene wirkte dort zu stark herangezoomt (Rückmeldung vom
 *      16.09.; gleiches Muster wie beim Frauen-Bericht vom 10.09.).
 *      Datiert auf den 15.09., 07:57 — hinter die drei Beiträge vom
 *      15.09., damit die 1. Mannschaft zuoberst im Hero bleibt.
 *      Existiert der Beitrag schon mit der Spielszene als Beitragsbild,
 *      wird nur das Beitragsbild getauscht (erst set_post_thumbnail,
 *      dann wp_update_post — sonst behält Yoast das alte og:image).
 *   B) Teamfotos 2026/27 für 14 Juniorenteams: Seitenfeld «Teamfoto»
 *      (fcs_jt_foto) — wirkt zugleich auf die Kacheln der
 *      Teams-Übersicht. Die Fotos kamen ohne Zuordnung (DSC-Nummern);
 *      zugeordnet über die Betreuer auf dem Bild (deren Porträts folgen
 *      im Ordner jeweils direkt auf das Teamfoto) und über die
 *      Trikotsponsoren, die den Sponsorlisten der Teamseiten
 *      entsprechen. Nur leere Felder werden gesetzt — steht schon ein
 *      Foto drin (Ba, FF14, FF17), bleibt es.
 *   C) 27 Betreuer-Porträts aus derselben Fotosession ersetzen die
 *      bisherigen (neue Dateien <Name>_2627.jpg in 2026/06, alte
 *      bleiben liegen). Getauscht wird der Dateiname überall, wo er in
 *      einem Seitenfeld steht: Betreuerstab der Teamseiten
 *      (fcs_jt_betreuer), Leitungsteam Fussballschule (fcs_fs_team),
 *      Kontakte Trainingslager (fcs_tl_kontakte) und die Person
 *      «Jacqueline Kempf» (fcs_pe_bild). Nur veröffentlichte Beiträge;
 *      Papierkorb (alte Ef-Seite) bleibt unangetastet.
 *   D) 9 Betreuer, die bisher eine Silhouette trugen, bekommen ihr
 *      Porträt (Namen am 16.09. von der Redaktion bestätigt). Hier
 *      wird nicht ein Dateiname getauscht, sondern die Zeile mit dem
 *      Namen im Betreuerstab der jeweiligen Teamseite: dritte Spalte
 *      -> neue Datei. Steht dort schon ein echtes Porträt (keine
 *      Silhouette, nicht die neue Datei), bleibt es und das Skript
 *      meldet HINWEIS. Dazu Tim Riesen (Dc) und Noel Herger (De): sie
 *      bekommen ihr Spielerporträt der 1. Mannschaft (Tim_Riesen.jpg,
 *      Noel_Herger.jpg, liegen schon in 2026/06).
 *
 * Die Bilddateien überträgt das aufrufende Shell-Skript vorher per
 * scp; dieses Skript prüft nur noch, ob sie da sind.
 *
 * Idempotent: der Beitrag wird am Slug erkannt, gesetzte Teamfotos
 * melden «SKIP». Zweiter Lauf ändert nichts.
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

$fehler = 0;
$updir  = wp_upload_dir();

/* News-Bilder liegen im Monatsordner, Teamfotos in 2026/06 (dort sucht
   das Seitenfeld «Teamfoto» der Junioren-Vorlage). */
$news_ordner  = '2026/09';
$news_basedir = $updir['basedir'] . '/' . $news_ordner . '/';
$news_baseurl = $updir['baseurl'] . '/' . $news_ordner . '/';
$team_basedir = $updir['basedir'] . '/2026/06/';

/* Betreuer-Porträts: alter Dateiname => neuer Dateiname (2026/06) */
$portraets = array(
	'Mario_Trova.jpg'         => 'Mario_Trovatelli_2627.jpg',
	'Jacqueline_Kempf.jpg'    => 'Jacqueline_Kempf_2627.jpg',
	'Sandro_Zwyssig.jpg'      => 'Sandro_Zwyssig_2627.jpg',
	'Luan_Krosa.jpg'          => 'Luan_Krosa_2627.jpg',
	'Andre_Schelbert.jpg'     => 'Andre_Schelbert_2627.jpg',
	'Christian_Meier.jpg'     => 'Christian_Meier_2627.jpg',
	'Manuel_Gnos.jpg'         => 'Manuel_Gnos_2627.jpg',
	'Christian_Esins.jpg'     => 'Christian_Esins_2627.jpg',
	'Elias_Mueller.jpg'       => 'Elias_Mueller_2627.jpg',
	'Fabio_Achermann.jpg'     => 'Fabio_Achermann_2627.jpg',
	'Daniel_Triolo.jpg'       => 'Daniel_Triolo_2627.jpg',
	'Endrit_Krasniqi.jpg'     => 'Endrit_Krasniqi_2627.jpg',
	'Sandro_Zamuner.jpg'      => 'Sandro_Zamuner_2627.jpg',
	'Bruno_Inderbitzin_2.jpg' => 'Bruno_Inderbitzin_2627.jpg',
	'Fabian_Bachmann.jpg'     => 'Fabian_Bachmann_2627.jpg',
	'Adi_Tresch.jpg'          => 'Adi_Tresch_2627.jpg',
	'Andre_Zgraggen.jpg'      => 'Andre_Zgraggen_2627.jpg',
	'Rene_Gnos.jpg'           => 'Rene_Gnos_2627.jpg',
	'Reichmuth_Daniel.jpg'    => 'Daniel_Reichmuth_2627.jpg',
	'Michael_Gisler.jpg'      => 'Michael_Gisler_2627.jpg',
	'Ruedi_Herger.jpg'        => 'Ruedi_Herger_2627.jpg',
	'Ti_Venzin.jpg'           => 'Mathias_Venzin_2627.jpg',
	'Simon_Gnos.jpg'          => 'Simon_Gnos_2627.jpg',
	'Simon_Welti.jpg'         => 'Simon_Welti_2627.jpg',
	'Andre_Deplazes.jpg'      => 'Andre_Deplazes_2627.jpg',
	'Bernhard_Gisler.jpg'     => 'Bernhard_Gisler_2627.jpg',
	'Sebastian_Herzog.jpg'    => 'Sebastian_Herzog_2627.jpg',
);
/* Silhouetten -> Porträt: Seiten-Slug => [Name => neue Datei] */
$silhouetten = array(
	'junioren-b-junioren-b'  => array( 'Heiri Stadler'       => 'Heiri_Stadler_2627.jpg' ),
	'junioren-d-junioren'    => array( 'Kari Schilter'       => 'Kari_Schilter_2627.jpg' ),
	'junioren-dc-junioren'   => array( 'Philippe Waridel'    => 'Philippe_Waridel_2627.jpg',
	                                   'Tim Riesen'          => 'Tim_Riesen.jpg' ),
	'junioren-dd-junioren'   => array( 'Sebi Gisler'         => 'Sebi_Gisler_2627.jpg' ),
	'junioren-de-junioren'   => array( 'Noel Herger'         => 'Noel_Herger.jpg' ),
	'junioren-ec-junioren'   => array( 'Lulzim Musliu'       => 'Lulzim_Musliu_2627.jpg',
	                                   'Christina Gisler'    => 'Christina_Gisler_2627.jpg' ),
	'junioren-feff-junioren' => array( 'Filipos Hagos'       => 'Filipos_Hagos_2627.jpg' ),
	'team-uri-ff11'          => array( 'Marino Arnold'       => 'Marino_Arnold_2627.jpg',
	                                   'Arturo Schneeberger' => 'Arturo_Schneeberger_2627.jpg' ),
);

/* Seitenfelder, in denen Porträt-Dateinamen stehen (Dateiname ist
   jeweils eine «|»-Spalte oder der ganze Wert). */
$portraet_felder = array( 'fcs_jt_betreuer', 'fcs_fs_team', 'fcs_tl_kontakte', 'fcs_pe_bild' );

/* Teamfotos: Seiten-Slug => [Datei, Kurzname] */
$teamfotos = array(
	'junioren-b-junioren-b'  => array( 'Bb_Junioren_26-27.jpg',     'Bb' ),
	'junioren-c-junioren-a'  => array( 'Ca_Junioren_26-27.jpg',     'Ca' ),
	'junioren-c-junioren-b'  => array( 'Cb_Junioren_26-27.jpg',     'Cb' ),
	'junioren-d-junioren'    => array( 'Da_Junioren_26-27.jpg',     'Da' ),
	'junioren-db-junioren'   => array( 'Db_Junioren_26-27.jpg',     'Db' ),
	'junioren-dc-junioren'   => array( 'Dc_Junioren_26-27.jpg',     'Dc' ),
	'junioren-dd-junioren'   => array( 'Dd_Junioren_26-27.jpg',     'Dd' ),
	'junioren-de-junioren'   => array( 'De_Junioren_26-27.jpg',     'De' ),
	'junioren-e-junioren'    => array( 'EaEb_Junioren_26-27.jpg',   'Ea/Eb' ),
	'junioren-ec-junioren'   => array( 'Ec_Junioren_26-27.jpg',     'Ec' ),
	'junioren-edee-junioren' => array( 'EdEe_Junioren_26-27.jpg',   'Ed/Ee' ),
	'junioren-f-junioren'    => array( 'FaFbFc_Junioren_26-27.jpg', 'Fa/Fb/Fc' ),
	'junioren-feff-junioren' => array( 'Fd_Junioren_26-27.jpg',     'Fd' ),
	'team-uri-ff11'          => array( 'FF11_Team_26-27.jpg',       'Team Uri FF11' ),
);

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
$noetig = array( $news_basedir . 'Ca_12-09-2026.jpg', $news_basedir . 'Ca_Junioren_26-27.jpg' );
foreach ( $teamfotos as $tf ) { $noetig[] = $team_basedir . $tf[0]; }
foreach ( $portraets as $neu ) { $noetig[] = $team_basedir . $neu; }
foreach ( $silhouetten as $liste ) { foreach ( $liste as $neu ) { $noetig[] = $team_basedir . $neu; } }
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

/* ── A) Neuer Beitrag ───────────────────────────────────────────── */
echo "\nA) Neuer Beitrag\n";

$daten = json_decode( (string) @file_get_contents( __DIR__ . '/news-import-1609.json' ), true );
if ( ! is_array( $daten ) || ! $daten ) {
	echo "   FEHLER – news-import-1609.json fehlt oder ist unlesbar.\n";
	$fehler++;
	$daten = array();
}

foreach ( $daten as $e ) {
	$slug = sanitize_title( $e['slug'] );
	echo "· {$e['datum']}  {$e['titel']}\n";

	$da = get_posts( array( 'post_type' => 'post', 'post_status' => 'any', 'name' => $slug, 'posts_per_page' => 1, 'fields' => 'ids' ) );
	if ( $da ) {
		$pid = (int) $da[0];
		if ( empty( $e['beitragsbild'] ) ) { echo "   SKIP – existiert bereits (#{$pid}).\n"; continue; }
		/* Beitrag steht schon: nur das Beitragsbild nachziehen. */
		$soll = fcs_anhang( $e['beitragsbild'], $e['titel'], $news_ordner, $news_basedir, $news_baseurl, $dry );
		if ( -1 === $soll ) { $fehler++; continue; }
		$ist = (int) get_post_thumbnail_id( $pid );
		if ( $soll > 0 && $ist === $soll ) { echo "   SKIP – existiert bereits (#{$pid}), Beitragsbild ist schon {$e['beitragsbild']}.\n"; continue; }
		echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "Beitrag #{$pid} Beitragsbild -> {$e['beitragsbild']}\n";
		if ( ! $dry ) {
			/* Reihenfolge wichtig: erst Thumbnail, dann wp_update_post —
			   Yoast rechnet das og:image erst beim Speichern neu. */
			set_post_thumbnail( $pid, $soll );
			wp_update_post( array( 'ID' => $pid ) );
		}
		continue;
	}

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
		   . ( $bild_id > 0 ? " (Anhang #{$bild_id} vorhanden)" : ' (neuer Anhang)' )
		   . ( empty( $e['beitragsbild'] ) ? '' : ", Beitragsbild {$e['beitragsbild']}" ) . "\n";
		continue;
	}

	/* Eigenes Beitragsbild (Hero/Kacheln), falls angegeben. */
	$thumb_id = $bild_id;
	if ( ! empty( $e['beitragsbild'] ) ) {
		$eigenes = fcs_anhang( $e['beitragsbild'], $e['titel'], $news_ordner, $news_basedir, $news_baseurl, $dry );
		if ( -1 === $eigenes ) { $fehler++; continue; }
		if ( $eigenes > 0 ) { $thumb_id = $eigenes; }
	}

	$kat = get_term_by( 'name', $e['kategorie'], 'category' );
	/* Beitragsbild als meta_input mit in den Insert — so kennt Yoast es
	   beim Bauen seiner Indexable-Zeile (og:image) schon. */
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
	echo "   angelegt: #{$id}, Kategorie «{$e['kategorie']}», Bild-Anhang #{$bild_id}"
		. ( $thumb_id !== $bild_id ? ", Beitragsbild {$e['beitragsbild']} (#{$thumb_id})" : '' ) . "\n";
}

/* ── B) Teamfotos der Junioren ──────────────────────────────────── */
echo "\nB) Teamfotos Junioren 2026/27\n";

foreach ( $teamfotos as $slug => $tf ) {
	list( $datei, $kurz ) = $tf;
	$seite = get_page_by_path( 'junioren/teams/' . $slug );
	if ( ! $seite ) { $seite = get_page_by_path( $slug ); }
	if ( ! $seite ) {
		$seiten = get_posts( array( 'post_type' => 'page', 'post_status' => 'publish', 'name' => $slug, 'posts_per_page' => 1 ) );
		$seite  = $seiten ? $seiten[0] : null;
	}
	if ( ! $seite ) { echo "   FEHLER – Seite «{$kurz}» ({$slug}) nicht gefunden.\n"; $fehler++; continue; }
	$ist = (string) get_post_meta( $seite->ID, 'fcs_jt_foto', true );
	if ( $ist === $datei ) { echo "   SKIP – {$kurz} #{$seite->ID}: steht schon auf «{$datei}».\n"; continue; }
	if ( '' !== $ist ) {
		echo "   SKIP – {$kurz} #{$seite->ID}: hat schon «{$ist}» — nicht überschrieben (bei Bedarf im Admin tauschen).\n";
		continue;
	}
	echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "{$kurz} #{$seite->ID} Teamfoto «— (Platzhalter)» -> «{$datei}»\n";
	if ( ! $dry ) { update_post_meta( $seite->ID, 'fcs_jt_foto', $datei ); }
}

/* ── C) Betreuer-Porträts tauschen ──────────────────────────────── */
echo "\nC) Betreuer-Porträts 2026/27\n";

global $wpdb;
$felder_sql = "'" . implode( "','", array_map( 'esc_sql', $portraet_felder ) ) . "'";
foreach ( $portraets as $alt => $neu ) {
	$zeilen = $wpdb->get_results( $wpdb->prepare(
		"SELECT m.meta_id, m.post_id, m.meta_key, m.meta_value, p.post_title, p.post_status
		   FROM {$wpdb->postmeta} m JOIN {$wpdb->posts} p ON p.ID = m.post_id
		  WHERE m.meta_key IN ({$felder_sql}) AND p.post_status = 'publish'
		    AND ( m.meta_value LIKE %s OR m.meta_value LIKE %s )",
		'%' . $wpdb->esc_like( $alt ) . '%', '%' . $wpdb->esc_like( $neu ) . '%'
	) );
	if ( ! $zeilen ) { echo "   HINWEIS – «{$alt}» steht in keinem Seitenfeld (nichts zu tun).\n"; continue; }
	foreach ( $zeilen as $z ) {
		if ( false !== strpos( $z->meta_value, $neu ) && false === strpos( $z->meta_value, $alt ) ) {
			echo "   SKIP – #{$z->post_id} {$z->meta_key}: «{$neu}» steht schon.\n";
			continue;
		}
		/* Nur ganze Dateinamen ersetzen: am Wortanfang (nach «| » oder
		   Zeilenanfang) und bis zum Ende des Dateinamens. */
		$neu_wert = preg_replace( '/(?<![A-Za-z0-9_.-])' . preg_quote( $alt, '/' ) . '(?![A-Za-z0-9_.-])/', $neu, $z->meta_value, -1, $n );
		if ( ! $n ) { echo "   HINWEIS – #{$z->post_id} {$z->meta_key}: «{$alt}» nur als Teil eines anderen Namens, nicht ersetzt.\n"; continue; }
		echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "#{$z->post_id} «{$z->post_title}» {$z->meta_key}: {$alt} -> {$neu}\n";
		if ( ! $dry ) { update_post_meta( $z->post_id, $z->meta_key, $neu_wert, $z->meta_value ); }
	}
}

/* ── D) Silhouetten durch Porträts ersetzen ─────────────────────── */
echo "\nD) Betreuer bisher mit Silhouette\n";

foreach ( $silhouetten as $slug => $liste ) {
	$seite = get_page_by_path( 'junioren/teams/' . $slug );
	if ( ! $seite ) { $seite = get_page_by_path( $slug ); }
	if ( ! $seite ) {
		$seiten = get_posts( array( 'post_type' => 'page', 'post_status' => 'publish', 'name' => $slug, 'posts_per_page' => 1 ) );
		$seite  = $seiten ? $seiten[0] : null;
	}
	if ( ! $seite ) { echo "   FEHLER – Seite {$slug} nicht gefunden.\n"; $fehler++; continue; }
	$ist    = str_replace( "\r\n", "\n", (string) get_post_meta( $seite->ID, 'fcs_jt_betreuer', true ) );
	$zeilen = explode( "\n", $ist );
	$geaendert = false;
	foreach ( $liste as $name => $neu ) {
		$gefunden = false;
		foreach ( $zeilen as $i => $zeile ) {
			$t = array_map( 'trim', explode( '|', $zeile ) );
			if ( count( $t ) < 2 || $t[1] !== $name ) { continue; }
			$gefunden = true;
			$bild = $t[2] ?? '';
			if ( $bild === $neu ) { echo "   SKIP – «{$seite->post_title}»: {$name} hat schon {$neu}.\n"; break; }
			if ( '' !== $bild && false === stripos( $bild, 'Silhouette' ) ) {
				echo "   HINWEIS – «{$seite->post_title}»: {$name} trägt schon ein Porträt ({$bild}), nicht ersetzt.\n";
				break;
			}
			$t[2] = $neu;
			$zeilen[ $i ] = implode( ' | ', $t );
			$geaendert = true;
			echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "«{$seite->post_title}» #{$seite->ID}: {$name}: " . ( $bild ?: '—' ) . " -> {$neu}\n";
			break;
		}
		if ( ! $gefunden ) { echo "   HINWEIS – «{$seite->post_title}»: {$name} steht nicht im Betreuerstab (nichts zu tun).\n"; }
	}
	if ( $geaendert && ! $dry ) { update_post_meta( $seite->ID, 'fcs_jt_betreuer', implode( "\n", $zeilen ) ); }
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __DIR__ . '/news-import-1609.json' );
	@unlink( __FILE__ );
	echo "\nSkript und Datenliste haben sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
