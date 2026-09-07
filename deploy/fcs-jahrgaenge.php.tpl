<?php
/**
 * Einmal-Skript: Jahrgänge auf «Mitglied werden» auf Platzhalter umstellen.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Die Einstiegswege stehen im Seitenfeld fcs_mw_tracks. Sobald dieses
 * Feld gepflegt ist, greift die Vorgabe der Vorlage nicht mehr — die
 * Umstellung muss deshalb zusätzlich zum Theme-Deploy in die DB:
 *
 *   Titel   «Juniorenbereich · Jahrgang 2012–2006» -> «Juniorenbereich»
 *           «Kinderfussball · Jahrgang 2018–2013»  -> «Kinderfussball»
 *   Text    «Jahrgang 2012 bis 2006» -> «Jahrgang %%fcs_jahrgaenge_junioren%%»
 *           «Jahrgang 2018 bis 2013» -> «Jahrgang %%fcs_jahrgaenge_kinder%%»
 *
 * Die Platzhalter löst inc/fcs-jahrgaenge.php bei jedem Seitenaufruf
 * auf. Der Saisonwechsel braucht danach keinen Deploy mehr.
 *
 * REIHENFOLGE: erst das Theme deployen, dann dieses Skript. Sonst
 * stünden die rohen %%…%% eine Weile auf der Seite.
 *
 * Schutz gegen Überschreiben von Redaktions-Arbeit: geschrieben wird nur,
 * wenn jeder der vier gesuchten Texte genau einmal vorkommt. Wurde das
 * Feld zwischenzeitlich im Admin gepflegt, bricht das Skript ab und
 * rührt nichts an.
 *
 * Idempotent: ein zweiter Lauf meldet «SKIP».
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
 * Führt die Umstellung aus. Als Funktion, damit jeder Abbruch ein
 * schlichtes return ist — das Löschen am Ende läuft trotzdem.
 */
function fcs_jg_umstellen( $dry ) {

	$paare = array(
		'Juniorenbereich · Jahrgang 2012–2006 |' => 'Juniorenbereich |',
		'Kinderfussball · Jahrgang 2018–2013 |'  => 'Kinderfussball |',
		'Jahrgang 2012 bis 2006)'                => 'Jahrgang %%fcs_jahrgaenge_junioren%%)',
		'Jahrgang 2018 bis 2013)'                => 'Jahrgang %%fcs_jahrgaenge_kinder%%)',
	);

	/* ── Seite suchen ────────────────────────────────────────────── */
	$seite = get_page_by_path( 'verein/mitglied-werden' );
	if ( ! $seite ) {
		$seite = get_page_by_path( 'mitglied-werden' );
	}
	if ( ! $seite ) {
		echo "FEHLER: Seite «Mitglied werden» nicht gefunden — nichts geändert.\n";
		return;
	}
	echo "Seite: «{$seite->post_title}» (#{$seite->ID})\n\n";

	/* ── Feld prüfen ─────────────────────────────────────────────── */
	$alt = (string) get_post_meta( $seite->ID, 'fcs_mw_tracks', true );

	if ( '' === trim( $alt ) ) {
		/* Leeres Feld = die Vorlage liefert den Text, und die trägt die
		   Platzhalter bereits. Dann ist hier nichts zu tun. */
		echo "SKIP – fcs_mw_tracks ist leer; es greift die Vorgabe der Vorlage,\n";
		echo "       die die Platzhalter schon enthält.\n";
		return;
	}

	if ( false !== strpos( $alt, '%%fcs_jahrgaenge_' ) ) {
		echo "SKIP – die Platzhalter stehen bereits im Feld. Nichts zu tun.\n";
		return;
	}

	$fehlend = array();
	foreach ( $paare as $suche => $ersatz ) {
		$n = substr_count( $alt, $suche );
		echo sprintf( "   %-44s %dx gefunden\n", '«' . $suche . '»', $n );
		if ( 1 !== $n ) {
			$fehlend[] = $suche;
		}
	}

	if ( $fehlend ) {
		echo "\nABBRUCH – nicht jeder Text kommt genau einmal vor.\n";
		echo "Das Feld wurde vermutlich im Admin gepflegt. Es wurde NICHTS geändert.\n";
		echo "Bitte die Jahrgänge dort von Hand durch die Platzhalter ersetzen:\n";
		echo "   %%fcs_jahrgaenge_junioren%%   bzw.   %%fcs_jahrgaenge_kinder%%\n";
		return;
	}

	/* ── Schreiben ───────────────────────────────────────────────── */
	$neu = strtr( $alt, $paare );

	if ( $dry ) {
		echo "\nWÜRDE SCHREIBEN – neuer Feldwert:\n";
		foreach ( explode( "\n", $neu ) as $zeile ) {
			echo '   ' . $zeile . "\n";
		}
		return;
	}

	update_post_meta( $seite->ID, 'fcs_mw_tracks', $neu );
	clean_post_cache( $seite->ID );

	$kontrolle = (string) get_post_meta( $seite->ID, 'fcs_mw_tracks', true );
	if ( false !== strpos( $kontrolle, '%%fcs_jahrgaenge_junioren%%' )
	  && false !== strpos( $kontrolle, '%%fcs_jahrgaenge_kinder%%' )
	  && false === strpos( $kontrolle, 'Jahrgang 2012–2006' )
	  && false === strpos( $kontrolle, 'Jahrgang 2018–2013' ) ) {
		echo "\nOK – 4 Ersetzungen geschrieben und zurückgelesen.\n";
	} else {
		echo "\nFEHLER – der zurückgelesene Wert passt nicht. Bitte im Admin prüfen.\n";
	}
}

fcs_jg_umstellen( $dry );

/* ── Selbst löschen ─────────────────────────────────────────────── */
if ( ! $dry ) {
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
