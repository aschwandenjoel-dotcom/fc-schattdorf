<?php
/**
 * Domainwechsel in der PRODUKTIONS-DB: alten Host durch den neuen ersetzen
 * (UMSTELLUNG.md, Schritt B4; Aufruf über deploy/deploy-domain.sh).
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Was es tut:
 *   1. Vorprüfung: siteurl muss noch auf dem alten Host stehen, sonst
 *      Abbruch (Schutz gegen Doppellauf und falsche Richtung; &force=1
 *      übergeht das bewusst).
 *   2. In allen Tabellen, in allen Textspalten: alter Host -> neuer Host.
 *      Nur der Hostname, ohne Schema — so werden auch protokoll-relative
 *      und JSON-escapte URLs (https:\/\/…) erfasst. Serialisierte Werte
 *      (Options, Postmeta, Widgets, Yoast, SportsPress) werden entpackt,
 *      ersetzt und neu gepackt, damit die Längenangaben stimmen.
 *   3. Aufräumen: Transients löschen, rewrite_rules verwerfen (WordPress
 *      baut sie beim nächsten Aufruf neu — entspricht «Permalinks
 *      speichern»), Yoast-permalink_hash nachziehen.
 *
 * Richtung:  Standard        fcschattdorf.dynalias.net -> www.fcschattdorf.ch
 *            &rueckwaerts=1  umgekehrt (Rollback). Achtung: das erwischt
 *                            auch bewusst gesetzte Links auf www.fcschattdorf.ch
 *                            (z. B. Trainingslager-Anmeldung) — nach einem
 *                            Rollback im Admin nachsehen.
 * Probelauf: &dry=1          zählt nur, schreibt nichts
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 900 );
ignore_user_abort( true );   // ein abgebrochener Aufruf soll keinen halben Stand hinterlassen

$dry   = ! empty( $_GET['dry'] );
$force = ! empty( $_GET['force'] );
$rueck = ! empty( $_GET['rueckwaerts'] );

$ALT = $rueck ? 'www.fcschattdorf.ch'       : 'fcschattdorf.dynalias.net';
$NEU = $rueck ? 'fcschattdorf.dynalias.net' : 'www.fcschattdorf.ch';

echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n" : "MODUS: Schreiben\n";
echo "RICHTUNG: {$ALT} -> {$NEU}\n\n";

/* ── 1. Vorprüfung ──────────────────────────────────────────────── */
$siteurl = (string) get_option( 'siteurl' );
$home    = (string) get_option( 'home' );
echo "1) Vorprüfung\n   siteurl = {$siteurl}\n   home    = {$home}\n";
/* Host samt Port vergleichen (lokal: localhost:8090; live ohne Port). */
$teile        = wp_parse_url( $siteurl );
$siteurl_host = strtolower( (string) ( $teile['host'] ?? '' ) ) . ( ! empty( $teile['port'] ) ? ':' . $teile['port'] : '' );
if ( $siteurl_host !== $ALT ) {
	echo "   ABBRUCH – siteurl steht nicht auf {$ALT}. Läuft das Skript doppelt oder in der falschen Richtung?\n";
	if ( $force ) {
		echo "   &force=1 gesetzt – fahre trotzdem fort.\n";
	} else {
		echo "   Bewusst übergehen: denselben Aufruf mit &force=1 wiederholen.\n";
		exit;
	}
}

/* ── 2. Ersetzen ────────────────────────────────────────────────── */
echo "\n2) Tabellen\n";

global $wpdb;
$stat = array( 'zeilen' => 0, 'zellen' => 0, 'fehler' => 0, 'incomplete' => 0 );

/* Rekursiv über entpackte Daten; unbekannte Objektklassen bleiben unangetastet. */
function fcs_ds_rek( $d, $alt, $neu, &$stat ) {
	if ( is_string( $d ) ) {
		return is_serialized( $d ) ? fcs_ds_wert( $d, $alt, $neu, $stat ) : str_replace( $alt, $neu, $d );
	}
	if ( is_array( $d ) ) {
		foreach ( $d as $k => $v ) { $d[ $k ] = fcs_ds_rek( $v, $alt, $neu, $stat ); }
		return $d;
	}
	if ( is_object( $d ) ) {
		if ( $d instanceof __PHP_Incomplete_Class ) { $stat['incomplete']++; return $d; }
		foreach ( get_object_vars( $d ) as $k => $v ) { $d->$k = fcs_ds_rek( $v, $alt, $neu, $stat ); }
		return $d;
	}
	return $d;
}

/* Ein Zellenwert: serialisiert -> entpacken/ersetzen/packen, sonst str_replace. */
function fcs_ds_wert( $wert, $alt, $neu, &$stat ) {
	if ( is_serialized( $wert ) ) {
		$daten = @unserialize( $wert );
		if ( false !== $daten || 'b:0;' === $wert ) {
			return serialize( fcs_ds_rek( $daten, $alt, $neu, $stat ) );
		}
	}
	return str_replace( $alt, $neu, $wert );
}

$like     = '%' . $wpdb->esc_like( $ALT ) . '%';
$texttyp  = '/^(char|varchar|tinytext|text|mediumtext|longtext|json|enum|set)/i';
$tabellen = $wpdb->get_col( 'SHOW TABLES' );

foreach ( $tabellen as $t ) {
	$spalten = $wpdb->get_results( "SHOW COLUMNS FROM `{$t}`" );
	$text = array(); $pk = array();
	foreach ( $spalten as $s ) {
		if ( preg_match( $texttyp, $s->Type ) ) { $text[] = $s->Field; }
		if ( 'PRI' === $s->Key )                { $pk[]   = $s->Field; }
	}
	if ( ! $text ) { continue; }

	$where = implode( ' OR ', array_map( function ( $c ) use ( $wpdb, $like ) {
		return $wpdb->prepare( "`{$c}` LIKE %s", $like );
	}, $text ) );

	$anzahl = (int) $wpdb->get_var( "SELECT COUNT(*) FROM `{$t}` WHERE {$where}" );
	if ( 0 === $anzahl ) { continue; }

	if ( ! $pk ) {
		echo sprintf( "   %-40s %5d Zeilen – ÜBERSPRUNGEN: kein Primärschlüssel, bitte von Hand ansehen\n", $t, $anzahl );
		$stat['fehler']++;
		continue;
	}

	$zeilen = 0; $zellen = 0; $beispiele = array();

	/* Zeilenweise über einen Cursor auf dem ersten Schlüsselfeld (kein OFFSET:
	   im Schreibmodus fallen geänderte Zeilen aus der Treffermenge). */
	$cursor_col = $pk[0];
	$cursor     = null;
	$einspaltig = ( 1 === count( $pk ) );
	while ( true ) {
		$sql = "SELECT * FROM `{$t}` WHERE ({$where})";
		if ( $einspaltig && null !== $cursor ) {
			$sql .= $wpdb->prepare( " AND `{$cursor_col}` > %s", $cursor );
		}
		$sql .= " ORDER BY `{$cursor_col}` LIMIT 200";
		$rows = $wpdb->get_results( $sql, ARRAY_A );
		if ( ! $rows ) { break; }

		foreach ( $rows as $row ) {
			$neu_werte = array();
			foreach ( $text as $c ) {
				if ( null === $row[ $c ] || false === strpos( $row[ $c ], $ALT ) ) { continue; }
				$n = fcs_ds_wert( $row[ $c ], $ALT, $NEU, $stat );
				if ( $n !== $row[ $c ] ) { $neu_werte[ $c ] = $n; }
			}
			if ( ! $neu_werte ) { continue; }
			$zeilen++; $zellen += count( $neu_werte );
			if ( count( $beispiele ) < 5 ) {
				$beispiele[] = ( $t === $wpdb->options && isset( $row['option_name'] ) )
					? $row['option_name']
					: $cursor_col . '=' . $row[ $cursor_col ] . ' (' . implode( ',', array_keys( $neu_werte ) ) . ')';
			}
			if ( ! $dry ) {
				$where_pk = array();
				foreach ( $pk as $k ) { $where_pk[ $k ] = $row[ $k ]; }
				if ( false === $wpdb->update( $t, $neu_werte, $where_pk ) ) {
					$stat['fehler']++;
					echo "   FEHLER {$t} {$cursor_col}={$row[ $cursor_col ]}: {$wpdb->last_error}\n";
				}
			}
		}

		if ( ! $einspaltig ) { break; }            // zusammengesetzter Schlüssel: eine Runde reicht (kleine Tabellen)
		$cursor = end( $rows )[ $cursor_col ];
		if ( count( $rows ) < 200 ) { break; }
	}

	$stat['zeilen'] += $zeilen; $stat['zellen'] += $zellen;
	echo sprintf( "   %-40s %5d Zeilen, %5d Zellen   z. B. %s\n", $t, $zeilen, $zellen, implode( ', ', $beispiele ) );
}

echo "\n   Total: {$stat['zeilen']} Zeilen, {$stat['zellen']} Zellen";
echo $dry ? " würden geändert.\n" : " geändert.\n";
if ( $stat['incomplete'] ) {
	echo "   HINWEIS: {$stat['incomplete']} serialisierte Objekte unbekannter Klasse unverändert gelassen.\n";
}
if ( $stat['fehler'] ) {
	echo "   FEHLER: {$stat['fehler']} – oben nachsehen.\n";
}

/* ── 3. Aufräumen ───────────────────────────────────────────────── */
echo "\n3) Aufräumen\n";
if ( $dry ) {
	echo "   würde Transients löschen, rewrite_rules verwerfen, Yoast-permalink_hash nachziehen.\n";
} else {
	$n = $wpdb->query( "DELETE FROM `{$wpdb->options}` WHERE option_name LIKE '\\_transient\\_%' OR option_name LIKE '\\_site\\_transient\\_%'" );
	echo "   Transients gelöscht: " . (int) $n . "\n";
	delete_option( 'rewrite_rules' );
	echo "   rewrite_rules verworfen (werden beim nächsten Aufruf neu gebaut).\n";
	$yt = $wpdb->prefix . 'yoast_indexable';
	if ( $wpdb->get_var( $wpdb->prepare( 'SHOW TABLES LIKE %s', $yt ) ) ) {
		$n = $wpdb->query( "UPDATE `{$yt}` SET permalink_hash = CONCAT(LENGTH(permalink), ':', MD5(permalink)) WHERE permalink IS NOT NULL" );
		echo "   Yoast permalink_hash nachgezogen: " . (int) $n . " Zeilen\n";
	}
	wp_cache_flush();
	echo "\n   siteurl = " . get_option( 'siteurl' ) . "\n   home    = " . get_option( 'home' ) . "\n";
}

if ( ! $dry ) {
	@unlink( __FILE__ );
	echo "\nFertig. Skript hat sich selbst gelöscht.\n";
} else {
	echo "\nProbelauf beendet – nichts geschrieben. Skript bleibt liegen.\n";
}
