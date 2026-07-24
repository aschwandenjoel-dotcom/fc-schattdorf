<?php
/**
 * Produktions-DB-Export als SQL-Stream (für scripts/pull-prod-db.sh).
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Reiner PHP-Dump (kein exec/mysqldump nötig): CREATE TABLE +
 * INSERTs in Blöcken. Endmarke «-- FCS-DUMP-COMPLETE» erlaubt dem
 * Abholer, die Vollständigkeit zu prüfen.
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

/* Nur die DB-Konstanten brauchen wir — wp-config lädt auch WP, das ist ok. */
define( 'SHORTINIT', true );
require __DIR__ . '/wp-load.php';

set_time_limit( 600 );
ignore_user_abort( false );
header( 'Content-Type: application/sql; charset=utf-8' );
header( 'Content-Disposition: attachment; filename="fcs-prod.sql"' );

$db = new mysqli( DB_HOST, DB_USER, DB_PASSWORD, DB_NAME );
if ( $db->connect_error ) {
	exit( '-- FEHLER: DB-Verbindung: ' . $db->connect_error . "\n" );
}
$db->set_charset( 'utf8mb4' );

echo "-- FCS Produktions-Dump " . gmdate( 'c' ) . "\n";
echo "SET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS=0;\nSET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';\n\n";

$tables = array();
$res = $db->query( 'SHOW TABLES' );
while ( $row = $res->fetch_row() ) { $tables[] = $row[0]; }

foreach ( $tables as $t ) {
	$tq = '`' . str_replace( '`', '``', $t ) . '`';
	echo "DROP TABLE IF EXISTS $tq;\n";
	$create = $db->query( "SHOW CREATE TABLE $tq" )->fetch_row();
	echo $create[1] . ";\n\n";

	$res = $db->query( "SELECT * FROM $tq", MYSQLI_USE_RESULT );
	$batch = array();
	$flush = function () use ( &$batch, $tq ) {
		if ( $batch ) {
			echo "INSERT INTO $tq VALUES\n" . implode( ",\n", $batch ) . ";\n";
			$batch = array();
		}
	};
	while ( $row = $res->fetch_row() ) {
		$vals = array();
		foreach ( $row as $v ) {
			$vals[] = ( null === $v ) ? 'NULL' : "'" . $db->real_escape_string( $v ) . "'";
		}
		$batch[] = '(' . implode( ',', $vals ) . ')';
		if ( count( $batch ) >= 200 ) { $flush(); }
	}
	$flush();
	$res->free();
	echo "\n";
	flush();
}

echo "SET FOREIGN_KEY_CHECKS=1;\n";
echo "-- FCS-DUMP-COMPLETE\n";
@unlink( __FILE__ );
