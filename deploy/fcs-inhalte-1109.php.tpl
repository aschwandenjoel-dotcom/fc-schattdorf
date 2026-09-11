<?php
/**
 * Einmal-Skript: Team Uri FF17 komplett, IFV-Teams für alle Juniorenseiten
 * (11.09.2026).
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Was es tut:
 *
 *   A) Team Uri FF17: erstes Teamfoto (bisher Platzhalter) und die
 *      Porträts der beiden Betreuer — Sam Bürer neu im Team-Uri-Dress,
 *      Noreen Häfliger bisher Silhouette.
 *   B) Seitenfeld «IFV-Teams» auf 16 Juniorenseiten: Kürzel und
 *      Team-Nummer aus dem IFV-Matchcenter. Daraus baut die Vorlage
 *      (page-junioren-team.php, Helfer inc/fcs-ifv.php) die Kacheln
 *      «Tabelle» und «Spielplan» je Team — bisher führten alle auf die
 *      IFV-Vereinsseite mit dem Spielbetrieb des ganzen Vereins.
 *      E-, F-Teams und FF11 tragen «ohne Tabelle» (Kinderfussball, nur
 *      Spielplan-Kachel).
 *      FF14 ist beim FC Altdorf gemeldet (v=326, t=79188), FF17 beim
 *      ESC Erstfeld (v=327, t=78478) — beide Nummern von der Redaktion
 *      am 11.09. geliefert, das Archiv kannte sie nicht.
 *   C) FF17: Teamfoto im Hero auf 15 % (Feld «senkrechte Lage»), damit
 *      die Köpfe der hinteren Reihe nicht abgeschnitten werden.
 *   D) Vorstand: das Porträt von Claudia Gisler (neue Brille) bekommt
 *      den neuen Dateinamen Claudia_Gisler_2026.jpg. Der Tausch vom
 *      09./10.09. lief unter dem ALTEN Namen — byteweise korrekt, aber
 *      Browser und Hostpoint-Cache lieferten weiter das alte Bild.
 *      Mediathek-Eintrag #218 wird auf die neue Datei umgehängt (mit
 *      lokal gerechneten Vorschaugrössen — der Server rechnet nichts),
 *      der Bildblock auf der Vorstandsseite auf den neuen Namen gesetzt.
 *
 * Die Bilddateien überträgt das aufrufende Shell-Skript vorher per
 * scp; dieses Skript prüft nur noch, ob sie da sind.
 *
 * Idempotent: gesetzte Felder melden «SKIP», ein zweiter Lauf ändert
 * nichts. Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 300 );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler = 0;
$updir  = wp_upload_dir();
$basedir = $updir['basedir'] . '/2026/06/';

/** Junioren-Teamseite unter /junioren/teams/ finden (Rückfall: Slug allein). */
function fcs_teamseite( $slug ) {
	foreach ( array( 'junioren/teams/' . $slug, $slug ) as $pfad ) {
		$seite = get_page_by_path( $pfad );
		if ( $seite ) { return $seite; }
	}
	return null;
}

/** Ein Seitenfeld setzen — mit SKIP, wenn der Wert schon steht. */
function fcs_feld( $slug, $key, $wert, $bezeichnung, $dry, &$fehler ) {
	$seite = fcs_teamseite( $slug );
	if ( ! $seite ) {
		echo "   FEHLER – Seite «{$bezeichnung}» ({$slug}) nicht gefunden.\n";
		$fehler++;
		return;
	}
	$ist = (string) get_post_meta( $seite->ID, 'fcs_' . $key, true );
	if ( trim( $ist ) === trim( $wert ) ) {
		echo "   SKIP – {$bezeichnung} #{$seite->ID}: {$key} steht schon.\n";
		return;
	}
	$kurz_ist = '' === $ist ? '—' : str_replace( "\n", ' / ', $ist );
	$kurz_neu = str_replace( "\n", ' / ', $wert );
	echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' )
		. "{$bezeichnung} #{$seite->ID} {$key}: «{$kurz_ist}» -> «{$kurz_neu}»\n";
	if ( ! $dry ) {
		if ( '' === $wert ) { delete_post_meta( $seite->ID, 'fcs_' . $key ); }
		else { update_post_meta( $seite->ID, 'fcs_' . $key, $wert ); }
	}
}

/* ── 0) Bilddateien müssen vor dem Schreiben da sein ────────────── */
echo "0) Bilddateien\n";
$noetig = array( 'FF17_Team_26-27.jpg', 'Sam_Buerer_2627.jpg', 'Noreen_Haefliger.jpg' );
/* Claudia Gisler: Volldatei plus alle Vorschaugrössen aus den Metadaten */
$claudia_meta = json_decode( '{"width":1280,"height":1920,"file":"2026\\/06\\/Claudia_Gisler_2026.jpg","filesize":550161,"sizes":{"medium":{"file":"Claudia_Gisler_2026-200x300.jpg","width":200,"height":300,"mime-type":"image\\/jpeg","filesize":12507},"large":{"file":"Claudia_Gisler_2026-683x1024.jpg","width":683,"height":1024,"mime-type":"image\\/jpeg","filesize":83008},"thumbnail":{"file":"Claudia_Gisler_2026-150x150.jpg","width":150,"height":150,"mime-type":"image\\/jpeg","filesize":6295},"medium_large":{"file":"Claudia_Gisler_2026-768x1152.jpg","width":768,"height":1152,"mime-type":"image\\/jpeg","filesize":101266},"1536x1536":{"file":"Claudia_Gisler_2026-1024x1536.jpg","width":1024,"height":1536,"mime-type":"image\\/jpeg","filesize":168647},"sportspress-crop-medium":{"file":"Claudia_Gisler_2026-300x300.jpg","width":300,"height":300,"mime-type":"image\\/jpeg","filesize":16618},"sportspress-fit-medium":{"file":"Claudia_Gisler_2026-200x300.jpg","width":200,"height":300,"mime-type":"image\\/jpeg","filesize":12507},"sportspress-fit-icon":{"file":"Claudia_Gisler_2026-85x128.jpg","width":85,"height":128,"mime-type":"image\\/jpeg","filesize":3976},"sportspress-fit-mini":{"file":"Claudia_Gisler_2026-21x32.jpg","width":21,"height":32,"mime-type":"image\\/jpeg","filesize":1035}},"image_meta":{"aperture":"3.5","credit":"Sandro Tresch","camera":"NIKON Z 8","caption":"","created_timestamp":"1787591038","copyright":"Sandro Tresch Photography","focal_length":"50","iso":"200","shutter_speed":"0.004","title":"","orientation":"0","keywords":["FC Schattdorf","Portraits","Vorstand"],"alt":""}}', true );
$noetig[] = basename( $claudia_meta['file'] );
foreach ( $claudia_meta['sizes'] as $sz ) { $noetig[] = $sz['file']; }
$noetig = array_values( array_unique( $noetig ) );
$fehlt  = array();
foreach ( $noetig as $datei ) {
	if ( ! file_exists( $basedir . $datei ) ) { $fehlt[] = '2026/06/' . $datei; }
}
if ( $fehlt ) {
	echo '   FEHLER – diese Dateien fehlen: ' . implode( ', ', $fehlt ) . "\n";
	echo "            Ohne sie zeigte die Seite leere Kästen. Abbruch.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo '   OK – alle ' . count( $noetig ) . " Dateien sind da.\n";

/* ── A) Team Uri FF17 ───────────────────────────────────────────── */
echo "\nA) Team Uri FF17\n";
fcs_feld( 'team-uri-ff17', 'jt_foto', 'FF17_Team_26-27.jpg', 'Team Uri FF17', $dry, $fehler );
fcs_feld( 'team-uri-ff17', 'jt_betreuer',
	"Betreuer | Sam Bürer | Sam_Buerer_2627.jpg\nBetreuerin | Noreen Häfliger | Noreen_Haefliger.jpg",
	'Team Uri FF17', $dry, $fehler );
fcs_feld( 'team-uri-ff17', 'jt_foto_pos', '15', 'Team Uri FF17', $dry, $fehler );

/* ── B) IFV-Teams je Juniorenseite ──────────────────────────────── */
echo "\nB) IFV-Teams (Kürzel | Team-Nummer im Matchcenter)\n";
/* Nummern aus der Matchcenter-Vereinsseite v=329, Stand Saison 2025/26
   (Webarchiv 21.10.2025). Team-Nummern bleiben über die Saisons gleich;
   die Zuordnung der Buchstaben folgt der Teammeldung 2026/27 — siehe
   UEBERGABE.md, Abschnitt zum 11.09.2026, für die Prüfliste. */
$ifv = array(
	'junioren-a-junioren'   => array( 'Aa', 'Aa | 30617' ),
	'junioren-b-junioren-a' => array( 'Ba', 'Ba | 42180' ),
	'junioren-b-junioren-b' => array( 'Bb', 'Bb | 30618' ),
	'junioren-c-junioren-a' => array( 'Ca', 'Ca | 30619' ),
	'junioren-c-junioren-b' => array( 'Cb', 'Cb | 30620' ),
	'junioren-d-junioren'   => array( 'Da', 'Da | 30622' ),
	'junioren-db-junioren'  => array( 'Db', 'Db | 30623' ),
	'junioren-dc-junioren'  => array( 'Dc', 'Dc | 50554' ),
	'junioren-dd-junioren'  => array( 'Dd', 'Dd | 58109' ),
	'junioren-de-junioren'  => array( 'De', 'De | 76734' ),
	'junioren-e-junioren'   => array( 'Ea/Eb', "Ea | 30625 | ohne Tabelle\nEb | 30626 | ohne Tabelle" ),
	'junioren-ec-junioren'  => array( 'Ec', 'Ec | 47203 | ohne Tabelle' ),
	'junioren-edee-junioren'=> array( 'Ed/Ee', "Ed | 52702 | ohne Tabelle\nEe | 54128 | ohne Tabelle" ),
	'junioren-f-junioren'   => array( 'Fa/Fb/Fc', "Fa | 71266 | ohne Tabelle\nFb | 46556 | ohne Tabelle\nFc | 50565 | ohne Tabelle" ),
	'junioren-feff-junioren'=> array( 'Fd', 'Fd | 48899 | ohne Tabelle' ),
	'team-uri-ff11'         => array( 'FF11', 'FF11 | 76737 | ohne Tabelle' ),
	'team-uri-ff14'         => array( 'FF14', 'FF14 | 79188 | 326' ),
	'team-uri-ff17'         => array( 'FF17', 'FF17 | 78478 | 327' ),
);
foreach ( $ifv as $slug => $e ) {
	fcs_feld( $slug, 'jt_ifv', $e[1], 'Junioren ' . $e[0], $dry, $fehler );
}

/* Die freien Link-Felder von FF14/FF17 waren im lokalen Zwischenstand
   als Übergang auf die Vereinsseiten gesetzt — leeren, damit allein
   «IFV-Teams» gilt (live waren sie nie gesetzt: SKIP). */
echo "\n   FF14 / FF17: freie Link-Felder leeren\n";
foreach ( array( 'team-uri-ff14' => 'FF14', 'team-uri-ff17' => 'FF17' ) as $slug => $kurz ) {
	fcs_feld( $slug, 'jt_tabelle',   '', 'Team Uri ' . $kurz, $dry, $fehler );
	fcs_feld( $slug, 'jt_spielplan', '', 'Team Uri ' . $kurz, $dry, $fehler );
}

/* ── D) Vorstand: Claudia Gisler unter neuem Dateinamen ─────────── */
echo "\nD) Vorstand — Claudia Gisler (Claudia_Gisler_2026.jpg)\n";
$cl_neu = $claudia_meta['file']; // 2026/06/Claudia_Gisler_2026.jpg
$cl = get_posts( array(
	'post_type' => 'attachment', 'post_status' => 'inherit', 'posts_per_page' => 1, 'fields' => 'ids',
	'meta_query' => array( array( 'key' => '_wp_attached_file', 'value' => array( '2026/06/Claudia_Gisler.jpg', $cl_neu ), 'compare' => 'IN' ) ),
) );
if ( ! $cl ) {
	echo "   FEHLER – Mediathek-Eintrag zu Claudia Gisler nicht gefunden.\n";
	$fehler++;
} else {
	$cid = (int) $cl[0];
	if ( get_post_meta( $cid, '_wp_attached_file', true ) === $cl_neu ) {
		echo "   SKIP – Anhang #{$cid} hängt schon an {$cl_neu}.\n";
	} else {
		echo '   ' . ( $dry ? 'würde umhängen: ' : 'umgehängt: ' ) . "Anhang #{$cid} Claudia_Gisler.jpg -> {$cl_neu} (" . count( $claudia_meta['sizes'] ) . " Vorschaugrössen)\n";
		if ( ! $dry ) {
			update_attached_file( $cid, $cl_neu );
			wp_update_attachment_metadata( $cid, $claudia_meta );
			/* Smush-Backup zeigt auf den alten Namen; weg damit, sonst
			   stellt «Restore» das alte Bild wieder her. */
			delete_post_meta( $cid, '_wp_attachment_backup_sizes' );
			/* GUID direkt: wp_update_post() lässt sie unangetastet. */
			global $wpdb;
			$wpdb->update( $wpdb->posts, array( 'guid' => $updir['baseurl'] . '/' . $cl_neu ), array( 'ID' => $cid ) );
			clean_post_cache( $cid );
		}
	}
	/* Bildblock auf der Vorstandsseite: src steht fest im Inhalt. */
	$vs = get_page_by_path( 'verein/vorstand' ) ?: get_page_by_path( 'vorstand' );
	if ( ! $vs ) {
		echo "   FEHLER – Seite «Vorstand» nicht gefunden.\n";
		$fehler++;
	} else {
		$neu = preg_replace( '#/2026/06/Claudia_Gisler(-\d+x\d+)?\.jpg#', '/2026/06/Claudia_Gisler_2026$1.jpg', $vs->post_content );
		if ( $neu === $vs->post_content ) {
			echo "   SKIP – Vorstandsseite #{$vs->ID} verweist schon auf den neuen Namen.\n";
		} else {
			echo '   ' . ( $dry ? 'würde ersetzen: ' : 'ersetzt: ' ) . "Vorstandsseite #{$vs->ID}, Bild-URL -> Claudia_Gisler_2026.jpg\n";
			if ( ! $dry ) { wp_update_post( array( 'ID' => $vs->ID, 'post_content' => $neu ) ); }
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
