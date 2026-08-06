<?php
/**
 * Einmal-Skript: Seite «Fussball Tauschbörse» auf die neue Vorlage
 * page-fussball-tauschboerse.php umstellen.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Es rührt GENAU eine Seite an (Pfad junioren/tauschboerse):
 *   1. _wp_page_template  -> page-fussball-tauschboerse.php
 *   2. post_content       -> Pflegehinweis (der bisherige Editor-Inhalt
 *      – Text + WhatsApp-Button – steckt jetzt in der Vorlage bzw. in
 *      der Feld-Box «Seiteninhalte»; er wird vorher ausgegeben, damit
 *      er im Deploy-Protokoll nachlesbar bleibt)
 *
 * Die Seite «Juniorenkonzept» braucht KEINE DB-Änderung: Vorlagenname
 * und Seitenfelder (fcs_jk_titel / fcs_jk_text / fcs_jk_pdf) bleiben
 * gleich, die neuen Felder greifen auf Vorlagen-Defaults zurück.
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

$TPL    = 'page-fussball-tauschboerse.php';
$HINWEIS = '<!-- wp:paragraph -->' . "\n"
	. '<p><strong>Hinweis zur Pflege dieser Seite:</strong> Die Inhalte werden in der Box <strong>«Seiteninhalte»</strong> unterhalb dieses Editors gepflegt. Dieser Editor-Text selbst wird nicht angezeigt.</p>' . "\n"
	. '<!-- /wp:paragraph -->';

$seite = get_page_by_path( 'junioren/tauschboerse' );
if ( ! $seite ) {
	$seite = get_page_by_path( 'tauschboerse' );
}

if ( ! $seite ) {
	echo "FEHLER – Seite «tauschboerse» nicht gefunden. Nichts geändert.\n";
	echo "\nAbbruch. Skript bleibt liegen und muss von Hand entfernt werden.\n";
	exit;
}

echo "Seite gefunden: #{$seite->ID} «{$seite->post_title}» (" . get_permalink( $seite ) . ")\n\n";

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

if ( ! $dry ) {
	clean_post_cache( $seite->ID );
	@unlink( __FILE__ );
	echo "\nFertig. Skript hat sich selbst gelöscht.\n";
} else {
	echo "\nProbelauf beendet – nichts geschrieben. Skript bleibt liegen.\n";
}
