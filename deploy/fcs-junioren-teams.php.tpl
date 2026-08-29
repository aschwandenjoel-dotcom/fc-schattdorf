<?php
/**
 * Einmal-Skript: Seite «Teams» (Junioren) auf die neue Vorlage
 * page-junioren-teams.php umstellen.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Es rührt GENAU eine Seite an (Pfad junioren/teams):
 *   1. _wp_page_template -> page-junioren-teams.php
 *   2. post_content      -> Pflegehinweis (die bisherige Linkliste war
 *      von Hand gepflegt und bereits unvollständig; die Kacheln baut
 *      jetzt die Vorlage automatisch aus den Unterseiten. Der alte
 *      Inhalt wird vorher ausgegeben, damit er im Deploy-Protokoll
 *      nachlesbar bleibt.)
 *
 * Die Teamseiten selbst bleiben unverändert.
 *
 * Idempotent: schon Erledigtes meldet «SKIP».
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

$TPL     = 'page-junioren-teams.php';
$HINWEIS = '<!-- wp:paragraph -->' . "\n"
	. '<p><strong>Hinweis zur Pflege dieser Seite:</strong> Die Teamkacheln entstehen automatisch aus den Unterseiten dieser Seite — Reihenfolge über die Seitenreihenfolge, Bild über das Feld «Teamfoto» der jeweiligen Teamseite. Die Zeile unter dem Seitentitel steht in der Box <strong>«Seiteninhalte»</strong> unterhalb dieses Editors. Dieser Editor-Text selbst wird nicht angezeigt.</p>' . "\n"
	. '<!-- /wp:paragraph -->';

$seite = get_page_by_path( 'junioren/teams' );
if ( ! $seite ) {
	$seite = get_page_by_path( 'teams' );
}

if ( ! $seite ) {
	echo "FEHLER – Seite «teams» nicht gefunden. Nichts geändert.\n";
	echo "\nAbbruch. Skript bleibt liegen und muss von Hand entfernt werden.\n";
	exit;
}

echo "Seite gefunden: #{$seite->ID} «{$seite->post_title}» (" . get_permalink( $seite ) . ")\n";

/* Kontrolle: aus diesen Unterseiten baut die Vorlage die Kacheln. */
$kinder = get_posts( array(
	'post_type'      => 'page',
	'post_parent'    => $seite->ID,
	'post_status'    => 'publish',
	'posts_per_page' => -1,
	'orderby'        => array( 'menu_order' => 'ASC', 'title' => 'ASC' ),
) );
echo 'Unterseiten (= Kacheln): ' . count( $kinder ) . "\n";
foreach ( $kinder as $k ) {
	$foto = get_post_meta( $k->ID, 'fcs_jt_foto', true );
	echo '  · ' . $k->post_title . ' — Teamfoto: ' . ( $foto ?: 'FEHLT (Platzhalter-Icon)' ) . "\n";
}
echo "\n";

/* ── 1. Vorlage setzen ───────────────────────────────────────────── */
$ist_tpl = get_post_meta( $seite->ID, '_wp_page_template', true );
if ( $TPL === $ist_tpl ) {
	echo "Vorlage: SKIP – steht bereits auf {$TPL}.\n";
} elseif ( $dry ) {
	echo "Vorlage: würde «" . ( $ist_tpl ?: '(keine)' ) . "» -> «{$TPL}».\n";
} else {
	update_post_meta( $seite->ID, '_wp_page_template', $TPL );
	echo "Vorlage: gesetzt auf «" . get_post_meta( $seite->ID, '_wp_page_template', true ) . "».\n";
}

/* ── 2. Editor-Inhalt durch Pflegehinweis ersetzen ───────────────── */
if ( trim( $seite->post_content ) === trim( $HINWEIS ) ) {
	echo "Editor-Inhalt: SKIP – enthält bereits den Pflegehinweis.\n";
} else {
	echo "\nBisheriger Editor-Inhalt (zur Sicherung im Protokoll):\n";
	echo "----------------------------------------------------------\n";
	echo $seite->post_content . "\n";
	echo "----------------------------------------------------------\n";

	if ( $dry ) {
		echo "Editor-Inhalt: würde durch den Pflegehinweis ersetzt.\n";
	} else {
		$res = wp_update_post( array(
			'ID'           => $seite->ID,
			'post_content' => $HINWEIS,
		), true );
		if ( is_wp_error( $res ) ) {
			echo 'Editor-Inhalt: FEHLER – ' . $res->get_error_message() . "\n";
		} else {
			echo "Editor-Inhalt: durch den Pflegehinweis ersetzt.\n";
		}
	}
}

/* ── 3. SEO-Beschreibung setzen ──────────────────────────────────────
   Ohne eigene Beschreibung baut Yoast die og:description aus dem
   Editor-Inhalt — dort steht ab jetzt nur noch der Pflegehinweis, der
   beim Teilen des Links sichtbar würde. */
$SEO      = 'Alle Juniorenteams des FC Schattdorf – von den A-Junioren bis zu den Jüngsten. Auf jeder Teamseite: Betreuerstab, Spielplan beim IFV und die Teamsponsoren.';
$seo_alt  = get_post_meta( $seite->ID, '_yoast_wpseo_metadesc', true );
if ( '' !== trim( (string) $seo_alt ) ) {
	echo "SEO-Beschreibung: SKIP – gepflegt («" . $seo_alt . "»).\n";
} elseif ( $dry ) {
	echo "SEO-Beschreibung: würde gesetzt auf «{$SEO}».\n";
} else {
	update_post_meta( $seite->ID, '_yoast_wpseo_metadesc', $SEO );
	echo "SEO-Beschreibung: gesetzt.\n";
}

if ( ! $dry ) {
	clean_post_cache( $seite->ID );
	@unlink( __FILE__ );
	echo "\nFertig. Skript hat sich selbst gelöscht.\n";
} else {
	echo "\nProbelauf beendet – nichts geschrieben. Skript bleibt liegen.\n";
}
