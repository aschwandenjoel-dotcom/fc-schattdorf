<?php
/**
 * Events (Veranstaltungen) als eigener Inhaltstyp.
 *
 * Die Einträge werden im WP-Admin unter «Events» gepflegt und von der
 * Seitenvorlage page-events.php als aufklappbare Karten ausgegeben.
 * Pro Event: Titel (WP-Titel), Beschreibung (Editor) sowie Datum, Ort,
 * Uhrzeit, Zielgruppe, Status und Agenda (Feld-Box unterhalb des Editors).
 */
defined( 'ABSPATH' ) || exit;

/* ── Inhaltstyp registrieren ──────────────────────────────────── */
add_action( 'init', function () {
	register_post_type( 'fcs_event', array(
		/* Admin-Label «Veranstaltungen», damit es sich von SportsPress
		   («Events» = Spielbetrieb) unterscheidet. Der CPT-Slug bleibt
		   fcs_event – Inhalte, URLs und die /events/-Seite unverändert. */
		'labels' => array(
			'name'               => 'Veranstaltungen',
			'singular_name'      => 'Veranstaltung',
			'menu_name'          => 'Veranstaltungen',
			'add_new'            => 'Veranstaltung hinzufügen',
			'add_new_item'       => 'Veranstaltung hinzufügen',
			'edit_item'          => 'Veranstaltung bearbeiten',
			'new_item'           => 'Neue Veranstaltung',
			'all_items'          => 'Alle Veranstaltungen',
			'search_items'       => 'Veranstaltungen durchsuchen',
			'not_found'          => 'Keine Veranstaltungen gefunden',
			'not_found_in_trash' => 'Keine Veranstaltungen im Papierkorb',
		),
		/* Keine eigenen Front-URLs – die Ausgabe macht die Seitenvorlage */
		'public'        => false,
		'show_ui'       => true,
		'show_in_menu'  => true,
		'menu_position' => 25,
		'menu_icon'     => 'dashicons-calendar-alt',
		'supports'      => array( 'title', 'editor' ),
		'show_in_rest'  => true,
		'has_archive'   => false,
		'rewrite'       => false,
	) );

	$auth = function () { return current_user_can( 'edit_posts' ); };
	$text = array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	);
	/* Datum im Format JJJJ-MM-TT – sortierbar, alle Anzeige-Formate
	   (Tag/Monat-Badge, «Freitag, 21. August 2026») werden daraus abgeleitet. */
	register_post_meta( 'fcs_event', 'fcs_ev_datum', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => function ( $v ) {
			return preg_match( '/^\d{4}-\d{2}-\d{2}$/', $v ) ? $v : '';
		},
		'auth_callback' => $auth,
	) );
	/* Optionales Enddatum für mehrtägige Anlässe (z. B. Grümpelturnier
	   17.–19. Juni). Leer = eintägig. Bestimmt zusammen mit dem Datum,
	   ab wann ein Event als vergangen gilt – siehe fcs_event_ende(). */
	register_post_meta( 'fcs_event', 'fcs_ev_datum_bis', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => function ( $v ) {
			return preg_match( '/^\d{4}-\d{2}-\d{2}$/', $v ) ? $v : '';
		},
		'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_event', 'fcs_ev_zeit', $text );        // z. B. «19:30 Uhr» oder «Wird bekannt gegeben»
	register_post_meta( 'fcs_event', 'fcs_ev_zeit_kurz', $text );   // Kurzform für die Kopfzeile, z. B. «Zeit folgt»
	register_post_meta( 'fcs_event', 'fcs_ev_ort', $text );         // z. B. «Mehrzweckhalle» oder «Wird bekannt gegeben»
	register_post_meta( 'fcs_event', 'fcs_ev_ort_kurz', $text );    // Kurzform für die Kopfzeile, z. B. «Ort folgt»
	register_post_meta( 'fcs_event', 'fcs_ev_zielgruppe', $text );  // z. B. «Alle Mitglieder»
	register_post_meta( 'fcs_event', 'fcs_ev_status', $text );      // Hinweiszeile, z. B. «Einladung folgt zu gegebener Zeit»
	register_post_meta( 'fcs_event', 'fcs_ev_ausgabe', $text );     // z. B. «93. Generalversammlung»
	register_post_meta( 'fcs_event', 'fcs_ev_agenda_titel', $text );// z. B. «Traktanden (vorläufig)»
	register_post_meta( 'fcs_event', 'fcs_ev_agenda', array(        // ein Agenda-Punkt pro Zeile
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_textarea_field', 'auth_callback' => $auth,
	) );
} );

/* ── Deutsche Datums-Formate (unabhängig von der Server-Locale) ── */
function fcs_event_datum_teile( $datum ) {
	$ts = $datum ? strtotime( $datum . ' 12:00:00' ) : false;
	if ( ! $ts ) {
		return null;
	}
	$wochentage = array( 'Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag' );
	$monate     = array( 1 => 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember' );
	$kurz       = array( 1 => 'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez' );
	$m          = (int) date( 'n', $ts );
	return array(
		'tag'      => date( 'j', $ts ),                                        // 21
		'mon_kurz' => $kurz[ $m ],                                             // Aug
		'jahr'     => date( 'Y', $ts ),                                        // 2026
		'dmy'      => date( 'd.m.Y', $ts ),                                    // 21.08.2026
		'lang'     => $wochentage[ (int) date( 'w', $ts ) ] . ', '
		            . date( 'j', $ts ) . '. ' . $monate[ $m ] . ' ' . date( 'Y', $ts ), // Freitag, 21. August 2026
	);
}

/**
 * Letzter Tag eines Events (Enddatum, sonst das Datum selbst).
 *
 * Massgeblich dafür, ab wann ein Event vergangen ist: ein mehrtägiger
 * Anlass bleibt bis und mit seinem letzten Tag sichtbar.
 * Rückgabe «» bedeutet: kein gültiges Datum erfasst – solche Einträge
 * werden nie automatisch aufgeräumt.
 */
function fcs_event_ende( $post_id ) {
	$von = get_post_meta( $post_id, 'fcs_ev_datum', true );
	$bis = get_post_meta( $post_id, 'fcs_ev_datum_bis', true );
	if ( ! preg_match( '/^\d{4}-\d{2}-\d{2}$/', (string) $von ) ) {
		return '';
	}
	return ( preg_match( '/^\d{4}-\d{2}-\d{2}$/', (string) $bis ) && $bis > $von ) ? $bis : $von;
}

/**
 * Datumszeile für mehrtägige Anlässe, z. B. «17. – 19. Juni 2027».
 *
 * Monat und Jahr stehen nur einmal, solange sie sich nicht ändern
 * («30. Juni – 2. Juli 2027», «30. Dezember 2027 – 1. Januar 2028»).
 * Eintägige Events geben null zurück – dort bleibt die bisherige
 * Langform mit Wochentag («Freitag, 21. August 2026»).
 */
function fcs_event_spanne( $von, $bis ) {
	$a = fcs_event_datum_teile( $von );
	$b = fcs_event_datum_teile( $bis );
	if ( ! $a || ! $b || $bis <= $von ) {
		return null;
	}
	$monate = array( 1 => 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember' );
	$m_a    = $monate[ (int) date( 'n', strtotime( $von . ' 12:00:00' ) ) ];
	$m_b    = $monate[ (int) date( 'n', strtotime( $bis . ' 12:00:00' ) ) ];
	if ( $a['jahr'] !== $b['jahr'] ) {
		return $a['tag'] . '. ' . $m_a . ' ' . $a['jahr'] . ' – ' . $b['tag'] . '. ' . $m_b . ' ' . $b['jahr'];
	}
	if ( $m_a !== $m_b ) {
		return $a['tag'] . '. ' . $m_a . ' – ' . $b['tag'] . '. ' . $m_b . ' ' . $b['jahr'];
	}
	return $a['tag'] . '. – ' . $b['tag'] . '. ' . $m_b . ' ' . $b['jahr'];
}

/* ── Feld-Box: Datum, Ort, Zeit, Zielgruppe, Status, Agenda ───── */
add_action( 'add_meta_boxes_fcs_event', function () {
	add_meta_box( 'fcs-event-felder', 'Event-Angaben', function ( $post ) {
		wp_nonce_field( 'fcs_event_save', 'fcs_event_nonce' );
		$feld = function ( $key ) use ( $post ) {
			return get_post_meta( $post->ID, $key, true );
		};
		?>
		<p>
			<label for="fcs_ev_datum"><strong>Datum</strong> (Pflichtfeld – bestimmt Sortierung und Anzeige)</label><br>
			<input type="date" id="fcs_ev_datum" name="fcs_ev_datum"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_datum' ) ); ?>" required>
		</p>
		<p>
			<label for="fcs_ev_datum_bis"><strong>Enddatum</strong> – nur bei mehrtägigen Anlässen (z.&nbsp;B. Grümpelturnier)</label><br>
			<input type="date" id="fcs_ev_datum_bis" name="fcs_ev_datum_bis"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_datum_bis' ) ); ?>">
			<br><span class="description">Leer lassen, wenn der Anlass an einem Tag stattfindet.</span>
		</p>
		<p>
			<label for="fcs_ev_ort"><strong>Ort</strong> (Detailansicht, z.&nbsp;B. «Mehrzweckhalle» oder «Wird bekannt gegeben»)</label><br>
			<input type="text" id="fcs_ev_ort" name="fcs_ev_ort" class="widefat"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_ort' ) ); ?>">
		</p>
		<p>
			<label for="fcs_ev_ort_kurz"><strong>Ort (Kurzform Kopfzeile)</strong> – leer = wie Ort, z.&nbsp;B. «Ort folgt»</label><br>
			<input type="text" id="fcs_ev_ort_kurz" name="fcs_ev_ort_kurz" class="widefat"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_ort_kurz' ) ); ?>">
		</p>
		<p>
			<label for="fcs_ev_zeit"><strong>Uhrzeit</strong> (Detailansicht, z.&nbsp;B. «19:30 Uhr» oder «Wird bekannt gegeben»)</label><br>
			<input type="text" id="fcs_ev_zeit" name="fcs_ev_zeit" class="widefat"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_zeit' ) ); ?>">
		</p>
		<p>
			<label for="fcs_ev_zeit_kurz"><strong>Uhrzeit (Kurzform Kopfzeile)</strong> – leer = wie Uhrzeit, z.&nbsp;B. «Zeit folgt»</label><br>
			<input type="text" id="fcs_ev_zeit_kurz" name="fcs_ev_zeit_kurz" class="widefat"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_zeit_kurz' ) ); ?>">
		</p>
		<p>
			<label for="fcs_ev_zielgruppe"><strong>Zielgruppe</strong> (Kopfzeile, z.&nbsp;B. «Alle Mitglieder»)</label><br>
			<input type="text" id="fcs_ev_zielgruppe" name="fcs_ev_zielgruppe" class="widefat"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_zielgruppe' ) ); ?>">
		</p>
		<p>
			<label for="fcs_ev_status"><strong>Hinweiszeile</strong> (z.&nbsp;B. «Einladung folgt zu gegebener Zeit» – leer = keine Anzeige)</label><br>
			<input type="text" id="fcs_ev_status" name="fcs_ev_status" class="widefat"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_status' ) ); ?>">
		</p>
		<p>
			<label for="fcs_ev_ausgabe"><strong>Ausgabe</strong> (Detailansicht, z.&nbsp;B. «93. Generalversammlung» – leer = keine Anzeige)</label><br>
			<input type="text" id="fcs_ev_ausgabe" name="fcs_ev_ausgabe" class="widefat"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_ausgabe' ) ); ?>">
		</p>
		<p>
			<label for="fcs_ev_agenda_titel"><strong>Agenda-Titel</strong> (z.&nbsp;B. «Traktanden (vorläufig)»)</label><br>
			<input type="text" id="fcs_ev_agenda_titel" name="fcs_ev_agenda_titel" class="widefat"
			       value="<?php echo esc_attr( $feld( 'fcs_ev_agenda_titel' ) ); ?>">
		</p>
		<p>
			<label for="fcs_ev_agenda"><strong>Agenda</strong> – ein Punkt pro Zeile (leer = keine Agenda-Liste)</label><br>
			<textarea id="fcs_ev_agenda" name="fcs_ev_agenda" class="widefat" rows="8"><?php
				echo esc_textarea( $feld( 'fcs_ev_agenda' ) );
			?></textarea>
		</p>
		<p class="description">
			Die Beschreibung des Events wird im Editor oben gepflegt.
		</p>
		<?php
	}, 'fcs_event', 'normal', 'high' );
} );

add_action( 'save_post_fcs_event', function ( $post_id ) {
	if ( ! isset( $_POST['fcs_event_nonce'] )
		|| ! wp_verify_nonce( $_POST['fcs_event_nonce'], 'fcs_event_save' )
		|| defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE
		|| ! current_user_can( 'edit_post', $post_id ) ) {
		return;
	}
	$datum = $_POST['fcs_ev_datum'] ?? '';
	update_post_meta( $post_id, 'fcs_ev_datum', preg_match( '/^\d{4}-\d{2}-\d{2}$/', $datum ) ? $datum : '' );
	/* Enddatum nur übernehmen, wenn es nach dem Datum liegt – ein
	   versehentlich früheres Datum würde das Event sofort aufräumen. */
	$bis = $_POST['fcs_ev_datum_bis'] ?? '';
	$bis = ( preg_match( '/^\d{4}-\d{2}-\d{2}$/', $bis ) && $bis > $datum ) ? $bis : '';
	update_post_meta( $post_id, 'fcs_ev_datum_bis', $bis );
	foreach ( array( 'fcs_ev_zeit', 'fcs_ev_zeit_kurz', 'fcs_ev_ort', 'fcs_ev_ort_kurz',
	                 'fcs_ev_zielgruppe', 'fcs_ev_status', 'fcs_ev_ausgabe', 'fcs_ev_agenda_titel' ) as $key ) {
		update_post_meta( $post_id, $key, sanitize_text_field( wp_unslash( $_POST[ $key ] ?? '' ) ) );
	}
	update_post_meta( $post_id, 'fcs_ev_agenda', sanitize_textarea_field( wp_unslash( $_POST['fcs_ev_agenda'] ?? '' ) ) );
} );

/* ── Admin-Liste: Spalten Datum/Ort, nach Datum sortiert ──────── */
add_filter( 'manage_fcs_event_posts_columns', function ( $cols ) {
	return array(
		'cb'           => $cols['cb'],
		'fcs_ev_datum' => 'Datum',
		'title'        => 'Titel',
		'fcs_ev_ort'   => 'Ort',
	);
} );
add_action( 'manage_fcs_event_posts_custom_column', function ( $col, $post_id ) {
	if ( 'fcs_ev_datum' === $col ) {
		$von    = get_post_meta( $post_id, 'fcs_ev_datum', true );
		$spanne = fcs_event_spanne( $von, get_post_meta( $post_id, 'fcs_ev_datum_bis', true ) );
		$teile  = fcs_event_datum_teile( $von );
		echo $spanne ? esc_html( $spanne ) : ( $teile ? esc_html( $teile['lang'] ) : '—' );
	} elseif ( 'fcs_ev_ort' === $col ) {
		echo esc_html( get_post_meta( $post_id, 'fcs_ev_ort', true ) ?: '—' );
	}
}, 10, 2 );
add_filter( 'manage_edit-fcs_event_sortable_columns', function ( $cols ) {
	$cols['fcs_ev_datum'] = 'fcs_ev_datum';
	return $cols;
} );
add_action( 'pre_get_posts', function ( $q ) {
	if ( ! is_admin() || ! $q->is_main_query() || 'fcs_event' !== $q->get( 'post_type' ) ) {
		return;
	}
	if ( ! $q->get( 'orderby' ) || 'fcs_ev_datum' === $q->get( 'orderby' ) ) {
		$q->set( 'meta_key', 'fcs_ev_datum' );
		$q->set( 'orderby', 'meta_value' );
		$q->set( 'order', $q->get( 'order' ) ?: 'ASC' );
	}
} );

/* ── Abfrage für Seitenvorlage und Startseite ─────────────────────
   $only_upcoming = true blendet vergangene Events aus (für die Termin-
   kachel der Startseite); $limit begrenzt die Anzahl (-1 = alle).
   Seit 09.09.2026 rufen beide mit true auf: vergangene Termine
   verschwinden am Tag nach ihrem letzten Tag von der Website. */
function fcs_get_events( $only_upcoming = false, $limit = -1 ) {
	/* Immer alle holen und in PHP filtern: massgeblich ist das Ende des
	   Events (fcs_event_ende), das je nach Eintrag im Datum oder im
	   Enddatum steht – als meta_query wäre das zwei Abfragen und ein
	   Sonderfall für Events ohne Enddatum. Die Zahl der Termine ist
	   zweistellig, das kostet nichts. $limit greift nach dem Filtern. */
	$posts = get_posts( array(
		'post_type'      => 'fcs_event',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'meta_key'       => 'fcs_ev_datum',
		'orderby'        => 'meta_value',
		'order'          => 'ASC',
	) );
	if ( $only_upcoming ) {
		/* current_time statt date(): der Server läuft auf UTC, gezählt
		   wird aber der Schweizer Kalendertag. */
		$heute = current_time( 'Y-m-d' );
		$posts = array_filter( $posts, function ( $p ) use ( $heute ) {
			$ende = fcs_event_ende( $p->ID );
			return '' !== $ende && $ende >= $heute;
		} );
	}
	if ( $limit > 0 ) {
		$posts = array_slice( $posts, 0, $limit );
	}
	$events = array();
	foreach ( $posts as $p ) {
		$meta = function ( $key ) use ( $p ) {
			return get_post_meta( $p->ID, $key, true );
		};
		$agenda = array_values( array_filter( array_map( 'trim', explode( "\n", $meta( 'fcs_ev_agenda' ) ) ) ) );
		$events[] = array(
			'id'           => (int) $p->ID,
			'titel'        => get_the_title( $p ),
			'datum'        => fcs_event_datum_teile( $meta( 'fcs_ev_datum' ) ),
			/* null bei eintägigen Events – dort gilt weiter datum.lang */
			'spanne'       => fcs_event_spanne( $meta( 'fcs_ev_datum' ), $meta( 'fcs_ev_datum_bis' ) ),
			'zeit'         => $meta( 'fcs_ev_zeit' ),
			'zeit_kurz'    => $meta( 'fcs_ev_zeit_kurz' ) ?: $meta( 'fcs_ev_zeit' ),
			'ort'          => $meta( 'fcs_ev_ort' ),
			'ort_kurz'     => $meta( 'fcs_ev_ort_kurz' ) ?: $meta( 'fcs_ev_ort' ),
			'zielgruppe'   => $meta( 'fcs_ev_zielgruppe' ),
			'status'       => $meta( 'fcs_ev_status' ),
			'ausgabe'      => $meta( 'fcs_ev_ausgabe' ),
			'beschreibung' => trim( wp_strip_all_tags( $p->post_content ) ),
			'agenda_titel' => $meta( 'fcs_ev_agenda_titel' ),
			'agenda'       => $agenda,
		);
	}
	return $events;
}

/* ── Vergangene Events automatisch aufräumen ──────────────────────
   Zwei Ebenen, damit ein abgelaufener Termin nie auf der Website
   stehen bleibt:

   1. Anzeige: die /events/-Seite und die Termin-Kachel der Startseite
      rufen fcs_get_events( true ) auf. Ein Event verschwindet damit
      am Tag nach seinem letzten Tag von der Website – unabhängig
      davon, ob der Cron gelaufen ist.
   2. Aufräumen: einmal täglich wandern vergangene Events in den
      Papierkorb. Bewusst kein endgültiges Löschen – die Redaktion
      kann einen Eintrag im Papierkorb wiederherstellen (und z. B. für
      die Weihnachtsfeier des Folgejahres kopieren). Von der Website
      sind sie so oder so weg.

   Events ohne gültiges Datum werden nie angefasst. */
add_action( 'init', function () {
	if ( ! wp_next_scheduled( 'fcs_events_aufraeumen' ) ) {
		/* Erste Ausführung leicht verzögert, damit sie nicht in den
		   Deploy-Aufruf selbst fällt. */
		wp_schedule_event( time() + 300, 'daily', 'fcs_events_aufraeumen' );
	}
} );

add_action( 'fcs_events_aufraeumen', function () {
	$heute = current_time( 'Y-m-d' );
	$ids   = get_posts( array(
		'post_type'      => 'fcs_event',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'fields'         => 'ids',
	) );
	foreach ( $ids as $id ) {
		$ende = fcs_event_ende( $id );
		if ( '' === $ende || $ende >= $heute ) {
			continue;
		}
		wp_trash_post( $id );
	}
} );
