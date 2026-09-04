<?php
/**
 * Weiterleitungen rund um den Domainwechsel (UMSTELLUNG.md, Abschnitt 7).
 *
 * A) Host: Kommt eine Frontend-Anfrage nicht unter dem Host von home_url()
 *    an (Test-Adresse fcschattdorf.dynalias.net, nackte fcschattdorf.ch),
 *    geht sie per 301 auf denselben Pfad unter home_url(). Lokal harmlos:
 *    dort ist home_url() = http://localhost:8080.
 *
 * B) Pfade der alten Joomla-Seite (www.fcschattdorf.ch bis 2026) auf die
 *    neuen Slugs — nur wenn WordPress selbst nichts findet (404), damit
 *    nie eine bestehende Seite überdeckt wird. Wichtig z. B. für /event/…:
 *    dort liegen die Einzel-Events des Kalenders.
 *
 * Beides hängt an template_redirect und greift damit nur im Frontend —
 * Admin, Login, AJAX, REST und Cron bleiben unberührt. Existiert das
 * Ziel einer Pfadregel nicht (Seite umbenannt), geht es auf die nächste
 * vorhandene Elternseite statt auf ein 404.
 */
defined( 'ABSPATH' ) || exit;

/* ── A) Host ──────────────────────────────────────────────────────── */
add_action( 'template_redirect', 'fcs_redirect_host', 1 );
function fcs_redirect_host() {
	if ( ! in_array( $_SERVER['REQUEST_METHOD'] ?? 'GET', array( 'GET', 'HEAD' ), true ) ) {
		return;
	}
	$soll = wp_parse_url( home_url() );
	$soll_host = strtolower( $soll['host'] ?? '' ) . ( ! empty( $soll['port'] ) ? ':' . $soll['port'] : '' );
	$ist_host  = strtolower( $_SERVER['HTTP_HOST'] ?? '' );
	if ( '' === $soll_host || $ist_host === $soll_host ) {
		return;
	}
	wp_redirect( untrailingslashit( home_url() ) . ( $_SERVER['REQUEST_URI'] ?? '/' ), 301, 'fcs-redirects' );
	exit;
}

/* ── B) Alte Pfade ────────────────────────────────────────────────── */
add_action( 'template_redirect', 'fcs_redirect_alte_pfade', 2 );
function fcs_redirect_alte_pfade() {
	if ( ! is_404() ) {
		return;
	}
	$pfad = wp_parse_url( $_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH );
	$pfad = strtolower( untrailingslashit( $pfad ?: '/' ) );

	/* Joomla ohne URL-Rewriting: /index.php/verein/vorstand */
	$index_php = ( 0 === strpos( $pfad, '/index.php/' ) );
	if ( $index_php ) {
		$pfad = substr( $pfad, strlen( '/index.php' ) );
	}

	$ziel = fcs_redirect_ziel( $pfad );
	if ( null === $ziel && $index_php ) {
		$ziel = $pfad . '/';
	}
	if ( null === $ziel ) {
		return;
	}
	wp_redirect( home_url( fcs_redirect_vorhanden( $ziel ) ), 301, 'fcs-redirects' );
	exit;
}

/* Ziel für einen alten Pfad (ohne Schrägstrich am Ende, kleingeschrieben)
   oder null, wenn keine Regel passt. */
function fcs_redirect_ziel( $pfad ) {
	$map = fcs_redirect_map();
	if ( isset( $map[ $pfad ] ) ) {
		return $map[ $pfad ];
	}
	foreach ( fcs_redirect_praefixe() as $praefix => $ziel ) {
		if ( 0 === strpos( $pfad, $praefix ) ) {
			return $ziel;
		}
	}
	return null;
}

/* Gibt es die Zielseite? Sonst die nächste vorhandene Elternseite, zuletzt «/». */
function fcs_redirect_vorhanden( $ziel ) {
	$teile = array_values( array_filter( explode( '/', $ziel ) ) );
	while ( $teile ) {
		if ( get_page_by_path( implode( '/', $teile ) ) ) {
			return '/' . implode( '/', $teile ) . '/';
		}
		array_pop( $teile );
	}
	return '/';
}

/* Alte Joomla-URL => neue Seite. Unveränderte Pfade (z. B. /verein/vorstand,
   /aktive/1-mannschaft) brauchen keine Regel — WordPress findet sie selbst.
   Team-Zuordnungen mit dem Juniorenobmann gegenprüfen, sie ändern sich
   jede Saison. */
function fcs_redirect_map() {
	return array(
		'/aktive/frauen-team-uri-i'          => '/aktive/frauen-uri-1/',
		'/aktive/frauen-team-uri-ii'         => '/aktive/frauen-uri-2/',
		'/aktive/senioren-team-uri-i'        => '/aktive/senioren-uri-1/',
		'/betreuer'                          => '/junioren/betreuer-werden/',
		'/betreuer-werden'                   => '/junioren/betreuer-werden/',
		'/fussballschule'                    => '/junioren/fussballschule/',
		'/goalietraining'                    => '/junioren/goalietraining/',
		'/juniorengeschichte'                => '/junioren/juniorengeschichte/',
		'/juniorenkonzept'                   => '/junioren/juniorenkonzept/',
		'/organisation'                      => '/junioren/junioren-organisation/',
		'/trainingslager'                    => '/junioren/trainingslager/',
		'/anmeldung-juniorentrainingslager'  => '/junioren/trainingslager/',
		'/verein/so-finden-sie-uns'          => '/verein/anfahrt/',
		'/verein/ehren-und-freimitglieder'   => '/verein/ehrenmitglieder/',
		'/verein/vorfall-verdacht-melden'    => '/verein/vorfall-melden/',
		'/sponsoren/sponsorenpage'           => '/sponsoren/',
		'/event/events'                      => '/events/',
		'/event/dorf-und-gruempelturnier'    => '/gruempelturnier/',
		'/login'                             => '/',
		/* Junioren-Teams (Saison 2026/27) */
		'/junioren/teams/junioren-mannschaft-aa'          => '/junioren/teams/junioren-a-junioren/',
		'/junioren/teams/junioren-mannschaft-ba'          => '/junioren/teams/junioren-b-junioren-a/',
		'/junioren/teams/junioren-mannschaft-bb'          => '/junioren/teams/junioren-b-junioren-b/',
		'/junioren/teams/junioren-mannschaft-ca'          => '/junioren/teams/junioren-c-junioren-a/',
		'/junioren/teams/junioren-mannschaft-cb'          => '/junioren/teams/junioren-c-junioren-b/',
		'/junioren/teams/junioren-mannschaft-da'          => '/junioren/teams/junioren-d-junioren/',
		'/junioren/teams/junioren-mannschaft-db'          => '/junioren/teams/junioren-db-junioren/',
		'/junioren/teams/junioren-mannschaft-dc'          => '/junioren/teams/junioren-dc-junioren/',
		'/junioren/teams/junioren-mannschaft-dd'          => '/junioren/teams/junioren-dd-junioren/',
		'/junioren/teams/junioren-mannschaft-de2'         => '/junioren/teams/junioren-de-junioren/',
		'/junioren/teams/junioren-mannschaft-df'          => '/junioren/teams/junioren-df-junioren/',
		'/junioren/teams/junioren-mannschaft-ea-eb-ec'    => '/junioren/teams/junioren-e-junioren/',
		'/junioren/teams/junioren-mannschaft-ec'          => '/junioren/teams/junioren-ec-junioren/',
		'/junioren/teams/junioren-mannschaft-ed-ee'       => '/junioren/teams/junioren-edee-junioren/',
		'/junioren/teams/junioren-mannschaft-ef-2'        => '/junioren/teams/junioren-ef-junioren/',
		'/junioren/teams/junioren-mannschaft-fa-fb-fc-fd' => '/junioren/teams/junioren-f-junioren/',
		'/junioren/teams/junioren-mannschaft-fe-ff'       => '/junioren/teams/junioren-feff-junioren/',
	);
}

/* Ganze Joomla-Bereiche, die es neu nicht mehr gibt (alte News,
   Spielberichte, Saison-Archive): auf die News-Übersicht. */
function fcs_redirect_praefixe() {
	return array(
		'/newsblog'      => '/news/',
		'/spielberichte' => '/news/',
		'/saison-'       => '/news/',
	);
}
