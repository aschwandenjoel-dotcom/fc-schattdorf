<?php
/**
 * Fanshop-Produkte als eigener Inhaltstyp.
 *
 * Die Produkte werden im WP-Admin unter «Fanshop-Produkte» gepflegt und von
 * der Seitenvorlage page-fanshop.php als Produktraster mit Warenkorb
 * ausgegeben. Pro Produkt: Name (WP-Titel) sowie Preis, Bild, Grössen,
 * Kategorie und Beschreibung (Feld-Box). Die Reihenfolge im Shop steuert das
 * Feld «Reihenfolge» in den Seiten-Attributen (kleinere Zahl zuerst).
 */
defined( 'ABSPATH' ) || exit;

/* ── Inhaltstyp registrieren ──────────────────────────────────── */
add_action( 'init', function () {
	register_post_type( 'fcs_produkt', array(
		'labels' => array(
			'name'               => 'Fanshop-Produkte',
			'singular_name'      => 'Fanshop-Produkt',
			'menu_name'          => 'Fanshop-Produkte',
			'add_new'            => 'Produkt hinzufügen',
			'add_new_item'       => 'Fanshop-Produkt hinzufügen',
			'edit_item'          => 'Fanshop-Produkt bearbeiten',
			'new_item'           => 'Neues Fanshop-Produkt',
			'all_items'          => 'Alle Produkte',
			'search_items'       => 'Produkte durchsuchen',
			'not_found'          => 'Keine Produkte gefunden',
			'not_found_in_trash' => 'Keine Produkte im Papierkorb',
		),
		/* Keine eigenen Front-URLs – die Ausgabe macht die Seitenvorlage */
		'public'        => false,
		'show_ui'       => true,
		'show_in_menu'  => true,
		'menu_position' => 26,
		'menu_icon'     => 'dashicons-cart',
		'supports'      => array( 'title', 'page-attributes' ),
		'show_in_rest'  => true,
		'has_archive'   => false,
		'rewrite'       => false,
	) );

	$auth = function () { return current_user_can( 'edit_posts' ); };
	register_post_meta( 'fcs_produkt', 'fcs_pr_preis', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_produkt', 'fcs_pr_bild', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_produkt', 'fcs_pr_groessen', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_produkt', 'fcs_pr_kategorie', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_produkt', 'fcs_pr_beschreibung', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_textarea_field', 'auth_callback' => $auth,
	) );
} );

/* ── Feld-Box: Preis, Bild, Grössen, Kategorie, Beschreibung ──── */
add_action( 'add_meta_boxes_fcs_produkt', function () {
	add_meta_box( 'fcs-produkt-felder', 'Produkt-Angaben', function ( $post ) {
		wp_nonce_field( 'fcs_produkt_save', 'fcs_produkt_nonce' );
		$preis  = get_post_meta( $post->ID, 'fcs_pr_preis', true );
		$bild   = get_post_meta( $post->ID, 'fcs_pr_bild', true );
		$groess = get_post_meta( $post->ID, 'fcs_pr_groessen', true );
		$kat    = get_post_meta( $post->ID, 'fcs_pr_kategorie', true );
		$beschr = get_post_meta( $post->ID, 'fcs_pr_beschreibung', true );
		?>
		<p>
			<label for="fcs_pr_preis"><strong>Preis in Franken</strong> (Pflichtfeld, z.&nbsp;B. 25.00)</label><br>
			<input type="number" id="fcs_pr_preis" name="fcs_pr_preis" min="0" step="0.05"
			       value="<?php echo esc_attr( $preis ); ?>" required style="width:8em;">
		</p>
		<p>
			<label for="fcs_pr_bild"><strong>Bild-Dateiname</strong> (Pflichtfeld, z.&nbsp;B. beanie.png)</label><br>
			<input type="text" id="fcs_pr_bild" name="fcs_pr_bild"
			       value="<?php echo esc_attr( $bild ); ?>" required class="regular-text">
		</p>
		<p class="description">
			Die Datei muss in der Mediathek im Ordner 2026/06 liegen
			(Uploads-Verzeichnis <code>2026/06/</code>).
		</p>
		<p>
			<label for="fcs_pr_groessen"><strong>Grössen</strong> (Kommaliste, z.&nbsp;B. Kids, S/M, L/XL – leer lassen für «One Size»)</label><br>
			<input type="text" id="fcs_pr_groessen" name="fcs_pr_groessen"
			       value="<?php echo esc_attr( $groess ); ?>" class="regular-text">
		</p>
		<p>
			<label for="fcs_pr_kategorie"><strong>Kategorie</strong> (z.&nbsp;B. Kopfbedeckung, Accessoires, Regenschirme)</label><br>
			<input type="text" id="fcs_pr_kategorie" name="fcs_pr_kategorie"
			       value="<?php echo esc_attr( $kat ); ?>" class="regular-text">
		</p>
		<p>
			<label for="fcs_pr_beschreibung"><strong>Beschreibung</strong> (kurzer Text für das Produktfenster)</label><br>
			<textarea id="fcs_pr_beschreibung" name="fcs_pr_beschreibung" rows="3"
			          class="large-text"><?php echo esc_textarea( $beschr ); ?></textarea>
		</p>
		<p class="description">
			Reihenfolge im Shop: Feld «Reihenfolge» in den Seiten-Attributen
			(kleinere Zahl zuerst).
		</p>
		<?php
	}, 'fcs_produkt', 'normal', 'high' );
} );

add_action( 'save_post_fcs_produkt', function ( $post_id ) {
	if ( ! isset( $_POST['fcs_produkt_nonce'] )
		|| ! wp_verify_nonce( $_POST['fcs_produkt_nonce'], 'fcs_produkt_save' )
		|| defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE
		|| ! current_user_can( 'edit_post', $post_id ) ) {
		return;
	}
	update_post_meta( $post_id, 'fcs_pr_preis', sanitize_text_field( $_POST['fcs_pr_preis'] ?? '' ) );
	update_post_meta( $post_id, 'fcs_pr_bild', sanitize_text_field( $_POST['fcs_pr_bild'] ?? '' ) );
	update_post_meta( $post_id, 'fcs_pr_groessen', sanitize_text_field( $_POST['fcs_pr_groessen'] ?? '' ) );
	update_post_meta( $post_id, 'fcs_pr_kategorie', sanitize_text_field( $_POST['fcs_pr_kategorie'] ?? '' ) );
	update_post_meta( $post_id, 'fcs_pr_beschreibung', sanitize_textarea_field( $_POST['fcs_pr_beschreibung'] ?? '' ) );
} );

/* ── Admin-Liste: Spalten Kategorie/Preis, nach Reihenfolge sortiert ── */
add_filter( 'manage_fcs_produkt_posts_columns', function ( $cols ) {
	return array(
		'cb'               => $cols['cb'],
		'title'            => 'Produkt',
		'fcs_pr_kategorie' => 'Kategorie',
		'fcs_pr_preis'     => 'Preis',
		'menu_order'       => 'Reihenfolge',
	);
} );
add_action( 'manage_fcs_produkt_posts_custom_column', function ( $col, $post_id ) {
	if ( 'fcs_pr_kategorie' === $col ) {
		echo esc_html( get_post_meta( $post_id, 'fcs_pr_kategorie', true ) );
	} elseif ( 'fcs_pr_preis' === $col ) {
		$preis = get_post_meta( $post_id, 'fcs_pr_preis', true );
		echo '' === $preis ? '—' : 'Fr. ' . esc_html( number_format( (float) $preis, 2 ) );
	} elseif ( 'menu_order' === $col ) {
		echo (int) get_post( $post_id )->menu_order;
	}
}, 10, 2 );
add_filter( 'manage_edit-fcs_produkt_sortable_columns', function ( $cols ) {
	$cols['menu_order'] = 'menu_order';
	return $cols;
} );
add_action( 'pre_get_posts', function ( $q ) {
	if ( ! is_admin() || ! $q->is_main_query() || 'fcs_produkt' !== $q->get( 'post_type' ) ) {
		return;
	}
	if ( ! $q->get( 'orderby' ) || 'menu_order' === $q->get( 'orderby' ) ) {
		$q->set( 'orderby', array( 'menu_order' => $q->get( 'order' ) ?: 'ASC', 'title' => 'ASC' ) );
	}
} );

/* ── Abfrage für die Seitenvorlage ────────────────────────────── */
function fcs_get_produkte() {
	$posts = get_posts( array(
		'post_type'      => 'fcs_produkt',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'orderby'        => array( 'menu_order' => 'ASC', 'title' => 'ASC' ),
	) );
	$produkte = array();
	foreach ( $posts as $p ) {
		$groessen = get_post_meta( $p->ID, 'fcs_pr_groessen', true );
		$groessen = '' === trim( (string) $groessen )
			? array()
			: array_values( array_filter( array_map( 'trim', explode( ',', $groessen ) ), 'strlen' ) );
		$produkte[] = array(
			'id'          => $p->post_name,
			'name'        => get_the_title( $p ),
			'price'       => (float) get_post_meta( $p->ID, 'fcs_pr_preis', true ),
			'image'       => get_post_meta( $p->ID, 'fcs_pr_bild', true ),
			'sizes'       => $groessen,
			'description' => get_post_meta( $p->ID, 'fcs_pr_beschreibung', true ),
			'category'    => get_post_meta( $p->ID, 'fcs_pr_kategorie', true ),
		);
	}
	return $produkte;
}
