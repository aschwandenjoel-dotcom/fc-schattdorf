<?php
/**
 * Personen (Funktionäre) als eigener Inhaltstyp.
 *
 * Die Einträge werden im WP-Admin unter «Personen» gepflegt und von den
 * Seitenvorlagen (z. B. page-junioren-organisation.php, page-schiedsrichter.php)
 * als Karten ausgegeben. Pro Person: Name (WP-Titel) sowie Bereich, Rolle,
 * E-Mail, Telefon, Bild und Link (Feld-Box unterhalb des Titels).
 */
defined( 'ABSPATH' ) || exit;

const FCS_PERSONEN_BEREICHE = array(
	'junioren-organisation' => 'Junioren-Organisation',
	'schiedsrichter'        => 'Schiedsrichter',
);

/* ── Inhaltstyp registrieren ──────────────────────────────────── */
add_action( 'init', function () {
	register_post_type( 'fcs_person', array(
		'labels' => array(
			'name'               => 'Personen',
			'singular_name'      => 'Person',
			'menu_name'          => 'Personen',
			'add_new'            => 'Person hinzufügen',
			'add_new_item'       => 'Person hinzufügen',
			'edit_item'          => 'Person bearbeiten',
			'new_item'           => 'Neue Person',
			'all_items'          => 'Alle Personen',
			'search_items'       => 'Personen durchsuchen',
			'not_found'          => 'Keine Personen gefunden',
			'not_found_in_trash' => 'Keine Personen im Papierkorb',
		),
		/* Keine eigenen Front-URLs – die Ausgabe machen die Seitenvorlagen */
		'public'        => false,
		'show_ui'       => true,
		'show_in_menu'  => true,
		'menu_position' => 24,
		'menu_icon'     => 'dashicons-id',
		'supports'      => array( 'title' ),
		'show_in_rest'  => true,
		'has_archive'   => false,
		'rewrite'       => false,
	) );

	$auth = function () { return current_user_can( 'edit_posts' ); };
	register_post_meta( 'fcs_person', 'fcs_pe_bereich', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => function ( $v ) {
			return array_key_exists( $v, FCS_PERSONEN_BEREICHE ) ? $v : 'junioren-organisation';
		},
		'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_person', 'fcs_pe_rolle', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_person', 'fcs_pe_email', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_email', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_person', 'fcs_pe_tel', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_person', 'fcs_pe_bild', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_person', 'fcs_pe_link', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'esc_url_raw', 'auth_callback' => $auth,
	) );
} );

/* Eingabefeld-Hinweis: der WP-Titel ist der Name der Person */
add_filter( 'enter_title_here', function ( $text, $post ) {
	return 'fcs_person' === $post->post_type ? 'Name der Person' : $text;
}, 10, 2 );

/* ── Feld-Box: Bereich, Rolle, Kontakt, Bild, Link, Reihenfolge ── */
add_action( 'add_meta_boxes_fcs_person', function () {
	add_meta_box( 'fcs-person-felder', 'Personen-Angaben', function ( $post ) {
		wp_nonce_field( 'fcs_person_save', 'fcs_person_nonce' );
		$bereich = get_post_meta( $post->ID, 'fcs_pe_bereich', true );
		$rolle   = get_post_meta( $post->ID, 'fcs_pe_rolle', true );
		$email   = get_post_meta( $post->ID, 'fcs_pe_email', true );
		$tel     = get_post_meta( $post->ID, 'fcs_pe_tel', true );
		$bild    = get_post_meta( $post->ID, 'fcs_pe_bild', true );
		$link    = get_post_meta( $post->ID, 'fcs_pe_link', true );
		?>
		<p>
			<label for="fcs_pe_bereich"><strong>Bereich</strong> – auf welcher Seite die Person erscheint</label><br>
			<select id="fcs_pe_bereich" name="fcs_pe_bereich">
				<?php foreach ( FCS_PERSONEN_BEREICHE as $key => $label ) : ?>
					<option value="<?php echo esc_attr( $key ); ?>" <?php selected( $bereich, $key ); ?>>
						<?php echo esc_html( $label ); ?>
					</option>
				<?php endforeach; ?>
			</select>
		</p>
		<p>
			<label for="fcs_pe_rolle"><strong>Rolle / Funktion</strong> (z.&nbsp;B. Juniorenobmann, SR – Anfänger)</label><br>
			<input type="text" id="fcs_pe_rolle" name="fcs_pe_rolle"
			       value="<?php echo esc_attr( $rolle ); ?>" style="width:100%;">
		</p>
		<p>
			<label for="fcs_pe_email"><strong>E-Mail</strong> (leer lassen, wenn keine angezeigt werden soll)</label><br>
			<input type="email" id="fcs_pe_email" name="fcs_pe_email"
			       value="<?php echo esc_attr( $email ); ?>" style="width:100%;">
		</p>
		<p>
			<label for="fcs_pe_tel"><strong>Telefon</strong> (Anzeige, z.&nbsp;B. 079 123 45 67)</label><br>
			<input type="text" id="fcs_pe_tel" name="fcs_pe_tel"
			       value="<?php echo esc_attr( $tel ); ?>" style="width:16em;">
		</p>
		<p>
			<label for="fcs_pe_bild"><strong>Bild</strong> – Dateiname aus der Mediathek (Ordner 2026/06)
				oder vollständige URL; leer = Platzhalter/kein Bild</label><br>
			<input type="text" id="fcs_pe_bild" name="fcs_pe_bild"
			       value="<?php echo esc_attr( $bild ); ?>" style="width:100%;">
		</p>
		<p>
			<label for="fcs_pe_link"><strong>Link</strong> (z.&nbsp;B. IFV-Daten bei Schiedsrichtern)</label><br>
			<input type="url" id="fcs_pe_link" name="fcs_pe_link"
			       value="<?php echo esc_attr( $link ); ?>" style="width:100%;">
		</p>
		<p>
			<label for="fcs_pe_order"><strong>Reihenfolge</strong> (kleinere Zahl zuerst)</label><br>
			<input type="number" id="fcs_pe_order" name="fcs_pe_order" step="1"
			       value="<?php echo esc_attr( $post->menu_order ); ?>" style="width:8em;">
		</p>
		<?php
	}, 'fcs_person', 'normal', 'high' );
} );

add_action( 'save_post_fcs_person', function ( $post_id ) {
	if ( ! isset( $_POST['fcs_person_nonce'] )
		|| ! wp_verify_nonce( $_POST['fcs_person_nonce'], 'fcs_person_save' )
		|| defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE
		|| ! current_user_can( 'edit_post', $post_id ) ) {
		return;
	}
	$bereich = sanitize_key( $_POST['fcs_pe_bereich'] ?? '' );
	update_post_meta( $post_id, 'fcs_pe_bereich', array_key_exists( $bereich, FCS_PERSONEN_BEREICHE ) ? $bereich : 'junioren-organisation' );
	update_post_meta( $post_id, 'fcs_pe_rolle', sanitize_text_field( wp_unslash( $_POST['fcs_pe_rolle'] ?? '' ) ) );
	update_post_meta( $post_id, 'fcs_pe_email', sanitize_email( wp_unslash( $_POST['fcs_pe_email'] ?? '' ) ) );
	update_post_meta( $post_id, 'fcs_pe_tel', sanitize_text_field( wp_unslash( $_POST['fcs_pe_tel'] ?? '' ) ) );
	update_post_meta( $post_id, 'fcs_pe_bild', sanitize_text_field( wp_unslash( $_POST['fcs_pe_bild'] ?? '' ) ) );
	update_post_meta( $post_id, 'fcs_pe_link', esc_url_raw( wp_unslash( $_POST['fcs_pe_link'] ?? '' ) ) );

	/* Reihenfolge (menu_order) – ohne erneuten save_post-Durchlauf */
	if ( isset( $_POST['fcs_pe_order'] ) ) {
		global $wpdb;
		$wpdb->update( $wpdb->posts, array( 'menu_order' => (int) $_POST['fcs_pe_order'] ), array( 'ID' => $post_id ) );
		clean_post_cache( $post_id );
	}
} );

/* ── Admin-Liste: Spalten Bereich/Rolle, nach Reihenfolge sortiert ── */
add_filter( 'manage_fcs_person_posts_columns', function ( $cols ) {
	return array(
		'cb'             => $cols['cb'],
		'title'          => 'Name',
		'fcs_pe_bereich' => 'Bereich',
		'fcs_pe_rolle'   => 'Rolle',
	);
} );
add_action( 'manage_fcs_person_posts_custom_column', function ( $col, $post_id ) {
	if ( 'fcs_pe_bereich' === $col ) {
		$bereich = get_post_meta( $post_id, 'fcs_pe_bereich', true );
		echo esc_html( FCS_PERSONEN_BEREICHE[ $bereich ] ?? $bereich );
	} elseif ( 'fcs_pe_rolle' === $col ) {
		echo esc_html( get_post_meta( $post_id, 'fcs_pe_rolle', true ) );
	}
}, 10, 2 );
add_filter( 'manage_edit-fcs_person_sortable_columns', function ( $cols ) {
	$cols['fcs_pe_bereich'] = 'fcs_pe_bereich';
	return $cols;
} );
add_action( 'pre_get_posts', function ( $q ) {
	if ( ! is_admin() || ! $q->is_main_query() || 'fcs_person' !== $q->get( 'post_type' ) ) {
		return;
	}
	if ( ! $q->get( 'orderby' ) ) {
		$q->set( 'orderby', array( 'menu_order' => 'ASC', 'title' => 'ASC' ) );
	} elseif ( 'fcs_pe_bereich' === $q->get( 'orderby' ) ) {
		$q->set( 'meta_key', 'fcs_pe_bereich' );
		$q->set( 'orderby', array( 'meta_value' => $q->get( 'order' ) ?: 'ASC', 'menu_order' => 'ASC' ) );
	}
} );

/* ── Abfrage für die Seitenvorlagen ───────────────────────────── */
function fcs_get_personen( $bereich ) {
	$posts = get_posts( array(
		'post_type'      => 'fcs_person',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'meta_key'       => 'fcs_pe_bereich',
		'meta_value'     => $bereich,
		'orderby'        => array( 'menu_order' => 'ASC', 'ID' => 'ASC' ),
	) );
	$personen = array();
	foreach ( $posts as $p ) {
		$personen[] = array(
			'name'  => get_the_title( $p ),
			'rolle' => get_post_meta( $p->ID, 'fcs_pe_rolle', true ),
			'email' => get_post_meta( $p->ID, 'fcs_pe_email', true ),
			'tel'   => get_post_meta( $p->ID, 'fcs_pe_tel', true ),
			'bild'  => get_post_meta( $p->ID, 'fcs_pe_bild', true ),
			'link'  => get_post_meta( $p->ID, 'fcs_pe_link', true ),
		);
	}
	return $personen;
}

/* Bild-Wert -> URL: vollständige URL bleibt, sonst Dateiname im Upload-Ordner 2026/06 */
function fcs_person_bild_url( $bild ) {
	$bild = trim( (string) $bild );
	if ( '' === $bild ) {
		return '';
	}
	if ( preg_match( '#^https?://#i', $bild ) ) {
		return $bild;
	}
	return wp_upload_dir()['baseurl'] . '/2026/06/' . ltrim( $bild, '/' );
}
