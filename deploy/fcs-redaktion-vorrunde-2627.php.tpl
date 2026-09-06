<?php
/**
 * Einmal-Skript: Redaktions-Rückmeldungen vom 03.09.2026.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Inhalt (Teil A–G):
 *   A) Aktive: «Frauen Team Uri I» -> «Frauen Team Uri»,
 *      «Senioren Team Uri I» -> «Senioren Team Uri»,
 *      «Frauen Team Uri II» in den Papierkorb (Team gibt es nicht mehr)
 *   B) Junioren-Teams auf die Funktionärsliste Vorrunde 2026/27:
 *      Titel, Betreuerstab, Reihenfolge; Mannschaftsfotos raus
 *      (Feld leeren -> Übersicht zeigt Silhouette); Df und Ef in den
 *      Papierkorb; Juniorinnen FF14 und FF17 neu anlegen
 *   C) Vorstand: Monja Deplazes -> Robin Lindauer (Silhouette),
 *      René Gnos neu «Sportchef»
 *   D) Vorfall melden: Kontakt Administration -> Robin Lindauer
 *   E) Mitglied werden: Jahrgänge ergänzt, Rubrik «Passivmitglied» neu
 *   F) Fussballschule: Stand gemäss Flyer Herbst 2026
 *   G) Trainingslager: Datum «Juli 2027», Anmeldung/Flyer/«Bist du
 *      dabei?» abgeschaltet (Felder leeren -> Vorlage blendet aus)
 *   H) Bilder: neues Brückli-Logo, neues Zurich-Logo (Generalagentur
 *      Simon Mani), sechs Spieler-Sponsorenlogos in höherer Auflösung,
 *      Fotos der vier Schiedsrichter aus der Serie vom August 2026,
 *      neuer Fussballschul-Flyer
 *   I) 2. Mannschaft: Betreuerstab neu (Igor Sureta, Roger Zurfluh,
 *      Robin Lindauer)
 *   J) Vorstand: vier Querformat-Fotos auf hochkant zugeschnittene
 *      Fassungen umgehaengt (Rene Gnos, Patrick Schorno, Iwan Herger,
 *      Markus Indergand)
 *   K) Gruempelturnier: Druckerei Kuster mit dem Farblogo statt der
 *      Schwarz-Variante
 *   L) Juniorinnen: Betreuerstab und Trikotsponsor der drei Teams
 *      Uri FF11, FF14 und FF17 (Angaben der Redaktion vom 05.09.2026)
 *   M) Vereinsgeschichte: Chronik-Eintrag «Erste Gruendung» (1916) in
 *      den Papierkorb
 *   N) Vereinsgeschichte: Yoast-Beschreibung nannte «110 Jahre» und die
 *      «erste Gruendung 1916» — beides ab 1916 gerechnet
 *
 * Schutz gegen Überschreiben von Redaktions-Arbeit: Teile, die einen
 * bestehenden Text ersetzen, prüfen vorher den erwarteten alten Wert.
 * Weicht er ab, meldet das Skript «ABBRUCH» und rührt nichts an —
 * dann mit &force=1 bewusst überschreiben.
 *
 * Idempotent: schon Erledigtes meldet «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 300 );

$dry   = ! empty( $_GET['dry'] );
$force = ! empty( $_GET['force'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler = 0;

/* ── Hilfsfunktionen ────────────────────────────────────────────── */

/** Seite über ihren Pfad holen (Slug-Kette ab Wurzel). */
function fcs_seite( $pfad ) {
	$p = get_page_by_path( $pfad );
	return $p instanceof WP_Post ? $p : null;
}

/** Titel einer Seite/eines Beitrags setzen. */
function fcs_titel( $post, $neu, $dry ) {
	if ( ! $post ) { echo "   FEHLER – Seite nicht gefunden.\n"; return false; }
	if ( $post->post_title === $neu ) {
		echo "   SKIP – #{$post->ID} heisst bereits «{$neu}».\n"; return true;
	}
	echo $dry
		? "   würde umbenennen: #{$post->ID} «{$post->post_title}» -> «{$neu}»\n"
		: "   umbenannt: #{$post->ID} «{$post->post_title}» -> «{$neu}»\n";
	if ( ! $dry ) {
		wp_update_post( array( 'ID' => $post->ID, 'post_title' => $neu ) );
	}
	return true;
}

/** Meta-Feld setzen; leerer Wert = Feld löschen (Vorlage nimmt dann ihren Standard). */
function fcs_meta( $post_id, $key, $wert, $dry ) {
	$alt = get_post_meta( $post_id, $key, true );
	$norm = function ( $v ) { return str_replace( "\r\n", "\n", trim( (string) $v ) ); };
	if ( $norm( $alt ) === $norm( $wert ) ) {
		echo "   SKIP – #{$post_id} {$key} steht bereits richtig.\n"; return;
	}
	if ( $dry ) {
		echo '   würde setzen: #' . $post_id . ' ' . $key . ' = '
			. ( '' === $wert ? '(leer -> Feld wird gelöscht)' : '«' . str_replace( "\n", ' ⏎ ', $wert ) . '»' ) . "\n";
		return;
	}
	if ( '' === $wert ) {
		delete_post_meta( $post_id, $key );
		echo "   gelöscht: #{$post_id} {$key}\n";
	} else {
		update_post_meta( $post_id, $key, $wert );
		echo "   gesetzt: #{$post_id} {$key}\n";
	}
}

/**
 * Menüpunkte, die auf eine Seite zeigen, nachführen.
 *
 * $neu_titel = null  -> Menüpunkt löschen (Seite fällt weg)
 * $neu_titel = Text  -> nur nötig, wenn der Punkt einen eigenen Titel trägt;
 *                       Punkte ohne eigenen Titel erben den Seitentitel und
 *                       ziehen von selbst nach.
 */
function fcs_menue_fuer_seite( $post_id, $neu_titel, $dry ) {
	$items = get_posts( array(
		'post_type'      => 'nav_menu_item',
		'post_status'    => 'any',
		'posts_per_page' => -1,
		'meta_key'       => '_menu_item_object_id',
		'meta_value'     => (string) $post_id,
	) );
	foreach ( $items as $item ) {
		if ( 'post_type' !== get_post_meta( $item->ID, '_menu_item_type', true ) ) { continue; }
		if ( null === $neu_titel ) {
			echo $dry ? "   würde Menüpunkt #{$item->ID} entfernen\n"
			          : "   Menüpunkt #{$item->ID} entfernt\n";
			if ( ! $dry ) { wp_delete_post( $item->ID, true ); }
			continue;
		}
		if ( '' === $item->post_title || $item->post_title === $neu_titel ) { continue; }
		echo $dry ? "   würde Menüpunkt #{$item->ID} «{$item->post_title}» -> «{$neu_titel}» umbenennen\n"
		          : "   Menüpunkt #{$item->ID} «{$item->post_title}» -> «{$neu_titel}»\n";
		if ( ! $dry ) { wp_update_post( array( 'ID' => $item->ID, 'post_title' => $neu_titel ) ); }
	}
}

/* ══════════════════════════════════════════════════════════════════
   A) Aktive: Frauen/Senioren Team Uri
   ══════════════════════════════════════════════════════════════════ */
echo "A) Aktive-Teams\n";

fcs_titel( fcs_seite( 'aktive/frauen-uri-1' ),   'Frauen Team Uri',   $dry );
fcs_titel( fcs_seite( 'aktive/senioren-uri-1' ), 'Senioren Team Uri', $dry );

/* Die SportsPress-Teams tragen dieselben Namen (nur im Admin sichtbar). */
foreach ( array( 'frauen-uri-1' => 'Frauen Team Uri', 'senioren-uri-1' => 'Senioren Team Uri' ) as $slug => $neu ) {
	$t = get_posts( array( 'post_type' => 'sp_team', 'name' => $slug, 'posts_per_page' => 1, 'post_status' => 'any' ) );
	if ( $t ) { fcs_titel( $t[0], $neu, $dry ); }
}

/* Frauen Team Uri II gibt es nicht mehr -> Seite und sp_team in den Papierkorb */
$f2 = fcs_seite( 'aktive/frauen-uri-2' );
if ( ! $f2 ) {
	echo "   SKIP – Seite «Frauen Team Uri II» ist bereits weg.\n";
} else {
	fcs_menue_fuer_seite( $f2->ID, null, $dry );
	echo $dry ? "   würde Seite #{$f2->ID} «{$f2->post_title}» in den Papierkorb legen\n"
	          : "   Seite #{$f2->ID} «{$f2->post_title}» in den Papierkorb gelegt\n";
	if ( ! $dry ) { wp_trash_post( $f2->ID ); }
}
$t2 = get_posts( array( 'post_type' => 'sp_team', 'name' => 'frauen-uri-2', 'posts_per_page' => 1, 'post_status' => 'publish' ) );
if ( ! $t2 ) {
	echo "   SKIP – sp_team «frauen-uri-2» ist bereits weg.\n";
} else {
	echo $dry ? "   würde sp_team #{$t2[0]->ID} in den Papierkorb legen\n"
	          : "   sp_team #{$t2[0]->ID} in den Papierkorb gelegt\n";
	if ( ! $dry ) { wp_trash_post( $t2[0]->ID ); }
}

/* Menüpunkte ohne eigenen Titel erben den Seitentitel; die mit eigenem
   Titel werden hier nachgezogen. */
foreach ( array( 'aktive/frauen-uri-1' => 'Frauen Team Uri', 'aktive/senioren-uri-1' => 'Senioren Team Uri' ) as $pfad => $neu ) {
	$s = fcs_seite( $pfad );
	if ( $s ) { fcs_menue_fuer_seite( $s->ID, $neu, $dry ); }
}

/* ══════════════════════════════════════════════════════════════════
   B) Junioren-Teams (Funktionärsliste Vorrunde 2026/27)
   ══════════════════════════════════════════════════════════════════ */
echo "\nB) Junioren-Teams\n";

/* Slug -> Titel, Reihenfolge, Betreuerstab «Rolle | Name | Portrait».
   Portraits ohne vorhandenes Bild bekommen die Silhouette; die
   Redaktion kann sie im Admin durch ein Foto ersetzen.
   Mannschaftsfotos entfallen komplett (Feld fcs_jt_foto wird geleert). */
$SIL  = 'Silhouette_Male_v2.jpg';
$SILF = 'Silhouette_Female.jpg';
$teams = array(
	'junioren-a-junioren' => array( 'titel' => 'Junioren Mannschaft Aa', 'order' => 1, 'staff' => array(
		"Betreuer | Fabrizio Merenda | Fabrizio_Merenda.jpg",
		"Betreuer | Reto Infanger | Reto_Infanger.jpg",
	) ),
	'junioren-b-junioren-a' => array( 'titel' => 'Junioren Mannschaft Ba', 'order' => 2, 'staff' => array(
		"Betreuer | Patrik Müller | Patrik_Mueller.jpg",
		"Betreuer | Robert Gwerder | Robert_Gwerder.jpg",
		"Betreuer | Niels Chab | Niels_Chab.jpg",
	) ),
	'junioren-b-junioren-b' => array( 'titel' => 'Junioren Mannschaft Bb', 'order' => 3, 'staff' => array(
		"Betreuer | Sebastian Herzog | Sebastian_Herzog.jpg",
		"Betreuer | Heiri Stadler | $SIL",
		"Betreuer | Bernhard Gisler | Bernhard_Gisler.jpg",
		"Betreuer | Fabio Moser | Fabio_Moser.jpg",
	) ),
	'junioren-c-junioren-a' => array( 'titel' => 'Junioren Mannschaft Ca', 'order' => 4, 'staff' => array(
		"Betreuer | André Zgraggen | Andre_Zgraggen.jpg",
		"Betreuer | Fabian Bachmann | Fabian_Bachmann.jpg",
		"Betreuer | Adrian Tresch | Adi_Tresch.jpg",
	) ),
	'junioren-c-junioren-b' => array( 'titel' => 'Junioren Mannschaft Cb', 'order' => 5, 'staff' => array(
		"Betreuer | Sandro Zamuner | Sandro_Zamuner.jpg",
		"Betreuer | Endrit Krasniqi | Endrit_Krasniqi.jpg",
		"Betreuer | Bruno Inderbitzin | Bruno_Inderbitzin_2.jpg",
		"Betreuer | Shukri Frangu | $SIL",
	) ),
	'junioren-d-junioren' => array( 'titel' => 'Junioren Mannschaft Da', 'order' => 6, 'staff' => array(
		"Betreuer | Kari Schilter | $SIL",
		"Betreuer | Markus Baumann | Kusi_Baumann.jpg",
	) ),
	'junioren-db-junioren' => array( 'titel' => 'Junioren Mannschaft Db', 'order' => 7, 'staff' => array(
		"Betreuer | Daniel Reichmuth | Reichmuth_Daniel.jpg",
		"Betreuer | René Gnos | Rene_Gnos.jpg",
	) ),
	'junioren-dc-junioren' => array( 'titel' => 'Junioren Mannschaft Dc', 'order' => 8, 'staff' => array(
		"Betreuer | Philippe Waridel | $SIL",
		"Betreuer | Tim Riesen | $SIL",
		"Betreuer | Nico Bissig | NicoBissig.jpg",
		"Betreuer | Andri Baumann | BaumannAndri.jpg",
	) ),
	'junioren-dd-junioren' => array( 'titel' => 'Junioren Mannschaft Dd', 'order' => 9, 'staff' => array(
		"Betreuer | Daniel Triolo | Daniel_Triolo.jpg",
		"Betreuer | Sebi Gisler | $SIL",
		"Betreuer | Elias Müller | Elias_Mueller.jpg",
		"Betreuer | Fabio Achermann | Fabio_Achermann.jpg",
	) ),
	'junioren-de-junioren' => array( 'titel' => 'Junioren Mannschaft De', 'order' => 10, 'staff' => array(
		"Betreuer | Christian Meier | Christian_Meier.jpg",
		"Betreuer | Manuel Gnos | Manuel_Gnos.jpg",
		"Betreuer | Noel Herger | $SIL",
	) ),
	'junioren-e-junioren' => array( 'titel' => 'Junioren Mannschaft Ea/Eb', 'order' => 11, 'staff' => array(
		"Betreuerin | Jacqueline Kempf-Imholz | Jacqueline_Kempf.jpg",
		"Betreuer | Mario Trovatelli | Mario_Trova.jpg",
	) ),
	'junioren-ec-junioren' => array( 'titel' => 'Junioren Mannschaft Ec', 'order' => 12, 'staff' => array(
		"Betreuer | Lulzim Musliu | $SIL",
		"Betreuerin | Jasmin Jaun | Jasmin_Jaun_1.jpg",
		"Betreuerin | Christina Gisler | $SILF",
	) ),
	'junioren-edee-junioren' => array( 'titel' => 'Junioren Mannschaft Ed/Ee', 'order' => 13, 'staff' => array(
		"Betreuer | Andre Deplazes | Andre_Deplazes.jpg",
		"Betreuer | Simon Welti | Simon_Welti.jpg",
		"Betreuer | Mathias Venzin | Ti_Venzin.jpg",
		"Betreuer | Simon Gnos | Simon_Gnos.jpg",
	) ),
	'junioren-f-junioren' => array( 'titel' => 'Junioren Mannschaft Fa/Fb/Fc', 'order' => 14, 'staff' => array(
		"Betreuer | Sandro Zwyssig | Sandro_Zwyssig.jpg",
		"Betreuer | Andre Schelbert | Andre_Schelbert.jpg",
		"Betreuer | Ramanan Ananthavettivelu | Ramanan_Ananthacettivelu.jpg",
		"Betreuer | Luan Krosa | Luan_Krosa.jpg",
	) ),
	/* Slug bleibt «…feff…» (früher Fe/Ff), damit bestehende Links nicht brechen. */
	/* Die drei Juniorinnen-Teams stehen in Teil L – dort sind auch
	   Betreuerstab und Trikotsponsor gepflegt. */
	'junioren-feff-junioren' => array( 'titel' => 'Junioren Mannschaft Fd', 'order' => 15, 'staff' => array(
		"Betreuer | Christian Esins | Christian_Esins.jpg",
		"Betreuer | Filipos Hagos | $SIL",
	) ),
);

foreach ( $teams as $slug => $t ) {
	$seite = fcs_seite( 'junioren/teams/' . $slug );
	if ( ! $seite ) { echo "   FEHLER – Seite «{$slug}» nicht gefunden.\n"; $fehler++; continue; }
	echo "  · {$slug}\n";
	fcs_titel( $seite, $t['titel'], $dry );
	fcs_meta( $seite->ID, 'fcs_jt_titel', $t['titel'], $dry );
	fcs_meta( $seite->ID, 'fcs_jt_betreuer', implode( "\n", $t['staff'] ), $dry );
	fcs_meta( $seite->ID, 'fcs_jt_foto', '', $dry );
	if ( (int) $seite->menu_order !== (int) $t['order'] ) {
		echo $dry ? "   würde Reihenfolge {$seite->menu_order} -> {$t['order']} setzen\n"
		          : "   Reihenfolge {$seite->menu_order} -> {$t['order']}\n";
		if ( ! $dry ) { wp_update_post( array( 'ID' => $seite->ID, 'menu_order' => (int) $t['order'] ) ); }
	}
	/* Menüpunkt (falls vorhanden) auf den neuen Namen ziehen */
	fcs_menue_fuer_seite( $seite->ID, $t['titel'], $dry );
}

/* Aufgelöste Teams in den Papierkorb */
foreach ( array( 'junioren-df-junioren' => 'Df', 'junioren-ef-junioren' => 'Ef' ) as $slug => $kurz ) {
	$s = fcs_seite( 'junioren/teams/' . $slug );
	if ( ! $s ) { echo "   SKIP – Team {$kurz} ist bereits weg.\n"; continue; }
	fcs_menue_fuer_seite( $s->ID, null, $dry );
	echo $dry ? "   würde Team {$kurz} (#{$s->ID}) in den Papierkorb legen\n"
	          : "   Team {$kurz} (#{$s->ID}) in den Papierkorb gelegt\n";
	if ( ! $dry ) { wp_trash_post( $s->ID ); }
}

/* Juniorinnen FF14 und FF17 neu — ohne Foto und ohne Betreuerstab;
   die Vorlage blendet den Betreuer-Block bei leerem Feld aus. */
$eltern = fcs_seite( 'junioren/teams' );
foreach ( array( 'team-uri-ff14' => array( 'Team Uri FF14', 17 ), 'team-uri-ff17' => array( 'Team Uri FF17', 18 ) ) as $slug => $d ) {
	list( $titel, $order ) = $d;
	if ( fcs_seite( 'junioren/teams/' . $slug ) ) {
		echo "   SKIP – «{$titel}» existiert bereits.\n"; continue;
	}
	if ( ! $eltern ) { echo "   FEHLER – Elternseite «junioren/teams» nicht gefunden.\n"; $fehler++; break; }
	if ( $dry ) { echo "   würde anlegen: «{$titel}» (/junioren/teams/{$slug}/)\n"; continue; }
	$id = wp_insert_post( array(
		'post_type'    => 'page',
		'post_status'  => 'publish',
		'post_title'   => $titel,
		'post_name'    => $slug,
		'post_parent'  => $eltern->ID,
		'menu_order'   => $order,
		'post_content' => '',
	), true );
	if ( is_wp_error( $id ) ) { echo "   FEHLER bei «{$titel}»: " . $id->get_error_message() . "\n"; $fehler++; continue; }
	update_post_meta( $id, '_wp_page_template', 'page-junioren-team.php' );
	update_post_meta( $id, 'fcs_jt_titel', $titel );
	echo "   angelegt: «{$titel}» (#{$id})\n";
}

/* ══════════════════════════════════════════════════════════════════
   C) Vorstand
   ══════════════════════════════════════════════════════════════════ */
echo "\nC) Vorstand\n";

$vorstand = fcs_seite( 'verein/vorstand' );
if ( ! $vorstand ) { $vorstand = fcs_seite( 'vorstand' ); }
if ( ! $vorstand ) {
	echo "   FEHLER – Vorstandsseite nicht gefunden.\n"; $fehler++;
} else {
	$c    = $vorstand->post_content;
	$neu  = $c;

	/* C1) Monja Deplazes -> Robin Lindauer (Silhouette statt Foto).
	       Der Bild-Block wird auf das Muster «Markus Indergand» umgestellt
	       (volle Bildgrösse, keine Attachment-ID), weil die Silhouette
	       keine 200x300-Variante hat. */
	if ( false === strpos( $neu, 'Monja Deplazes' ) ) {
		echo "   SKIP – Monja Deplazes steht nicht mehr auf der Seite.\n";
	} else {
		$alt_block = '<!-- wp:image {"id":220,"sizeSlug":"medium"} -->';
		if ( false === strpos( $neu, $alt_block ) && ! $force ) {
			echo "   ABBRUCH – der Bild-Block von Monja sieht anders aus als erwartet.\n"
			   . "             Nichts geändert. Mit &force=1 trotzdem ersetzen.\n";
			$fehler++;
		} else {
			$vorher = $neu;
			$neu = str_replace( $alt_block, '<!-- wp:image {"sizeSlug":"large","linkDestination":"none"} -->', $neu );
			$neu = preg_replace(
				'#<figure class="wp-block-image size-medium"><img src="([^"]*)/uploads/2026/06/Monja_Deplazes-200x300\.jpg" alt="Monja Deplazes" class="wp-image-220" width="200" height="300" /></figure>#',
				'<figure class="wp-block-image size-large"><img src="$1/uploads/2026/06/Silhouette_Male_v2.jpg" alt="Robin Lindauer" /></figure>',
				$neu );
			$neu = str_replace( '<h3 class="wp-block-heading">Monja Deplazes</h3>',
			                    '<h3 class="wp-block-heading">Robin Lindauer</h3>', $neu );
			$neu = str_replace( '<p><strong>Administration</strong><br><a href="mailto:admin@fcschattdorf.ch">E-Mail</a><br>M: 078 658 44 34</p>',
			                    '<p><strong>Administration</strong><br><a href="mailto:admin@fcschattdorf.ch">E-Mail</a><br>M: 079 912 04 80</p>', $neu );
			if ( $neu === $vorher || false !== strpos( $neu, 'Monja Deplazes' ) ) {
				echo "   ABBRUCH – Ersetzen von Monja Deplazes hat nicht vollständig gegriffen.\n";
				$neu = $vorher; $fehler++;
			} else {
				echo $dry ? "   würde ersetzen: Monja Deplazes -> Robin Lindauer (Silhouette, M: 079 912 04 80)\n"
				          : "   ersetzt: Monja Deplazes -> Robin Lindauer\n";
			}
		}
	}

	/* C2) René Gnos: neue Bezeichnung «Sportchef» */
	if ( false !== strpos( $neu, '<p><strong>Sportchef</strong>' ) ) {
		echo "   SKIP – René Gnos ist bereits «Sportchef».\n";
	} elseif ( false === strpos( $neu, '<p><strong>Vizepräsident / Finanzchef</strong>' ) ) {
		echo "   ABBRUCH – Bezeichnung «Vizepräsident / Finanzchef» nicht gefunden.\n"; $fehler++;
	} else {
		$neu = str_replace( '<p><strong>Vizepräsident / Finanzchef</strong>', '<p><strong>Sportchef</strong>', $neu );
		echo $dry ? "   würde ändern: René Gnos «Vizepräsident / Finanzchef» -> «Sportchef»\n"
		          : "   geändert: René Gnos -> «Sportchef»\n";
	}

	if ( $neu !== $c ) {
		if ( ! $dry ) {
			wp_update_post( array( 'ID' => $vorstand->ID, 'post_content' => $neu ) );
			echo "   Vorstandsseite gespeichert.\n";
		}
	} else {
		echo "   SKIP – Vorstandsseite unverändert.\n";
	}
}

/* ══════════════════════════════════════════════════════════════════
   D) Vorfall melden
   ══════════════════════════════════════════════════════════════════ */
echo "\nD) Vorfall melden\n";
$vf = fcs_seite( 'verein/vorfall-melden' );
if ( ! $vf ) { $vf = fcs_seite( 'vorfall-melden' ); }
if ( ! $vf ) { echo "   FEHLER – Seite nicht gefunden.\n"; $fehler++; }
else {
	fcs_meta( $vf->ID, 'fcs_vf_kontakte',
		"Präsident | Ralph Bomatter | praesident@fcschattdorf.ch | 079 390 42 01\n"
		. "Administration | Robin Lindauer | admin@fcschattdorf.ch | 079 912 04 80", $dry );
}

/* ══════════════════════════════════════════════════════════════════
   E) Mitglied werden
   ══════════════════════════════════════════════════════════════════ */
echo "\nE) Mitglied werden\n";
$mw = fcs_seite( 'verein/mitglied-werden' );
if ( ! $mw ) { $mw = fcs_seite( 'mitglied-werden' ); }
if ( ! $mw ) { echo "   FEHLER – Seite nicht gefunden.\n"; $fehler++; }
else {
	fcs_meta( $mw->ID, 'fcs_mw_tracks', implode( "\n", array(
		'Aktivfussball | Aktive Mannschaft | Du spielst Fussball und möchtest auf einem hohen Niveau trainieren? Melde dich unverbindlich bei unserem Sportchef — wir freuen uns auf dich. | René Gnos | Sportchef | renegnos@bluewin.ch | 079 420 61 20',
		'Junioren A–C | Juniorenbereich · Jahrgang 2012–2006 | Für Anmeldungen im Juniorenbereich (A- bis C-Junioren, Jahrgang 2012 bis 2006) wende dich direkt an unseren Juniorenobmann und Vizepräsidenten. | Iwan Herger | Vizepräsident · Juniorenobmann | juniorenabteilung@fcschattdorf.ch | 078 698 91 95',
		'Kinder F–D | Kinderfussball · Jahrgang 2018–2013 | Die Jüngsten (F- bis D-Junioren, Jahrgang 2018 bis 2013) sind bei unserer KIFU-Leiterin in besten Händen. Einfach melden — Fussball macht Spass! | Jacqueline Kempf | Leiterin KIFU · F–D Junioren | jacqueline.kempf-imholz@gmx.ch | 078 795 29 67',
		'Passivmitglied | Verein unterstützen | Du spielst selbst nicht mehr, willst den FC Schattdorf aber weiterhin unterstützen? Als Passivmitglied hältst du dem Verein die Treue. Melde dich bei unserer Administration. | Robin Lindauer | Administration | admin@fcschattdorf.ch | 079 912 04 80',
	) ), $dry );
}

/* ══════════════════════════════════════════════════════════════════
   F) Fussballschule (Flyer Herbst 2026)
   ══════════════════════════════════════════════════════════════════ */
echo "\nF) Fussballschule\n";
$fs = fcs_seite( 'junioren/fussballschule' );
if ( ! $fs ) { $fs = fcs_seite( 'fussballschule' ); }
if ( ! $fs ) { echo "   FEHLER – Seite nicht gefunden.\n"; $fehler++; }
else {
	fcs_meta( $fs->ID, 'fcs_fs_intro',
		'Jeweils **montags von 17:45 bis 19:00 Uhr** trainiert die Fussballschule für Kinder mit Jahrgang 2020 und 2021 auf dem **Hauptplatz «Grüner Wald»** in Schattdorf. Mitnehmen, wenn vorhanden: Fussballschuhe, Schoner, Fussball (Grösse 4), Getränke und wettertaugliche Kleider. **Die Trainings finden bei jeder Witterung statt.** Fragen beantwortet Jacqueline Kempf-Imholz, 078 795 29 67.', $dry );
	fcs_meta( $fs->ID, 'fcs_fs_karten', implode( "\n", array(
		'Wann | Montag · 17:45 – 19:00 Uhr | 17.8. / 24.8. / 31.8. / 7.9. / 14.9. / 21.9. / 28.9. / 12.10. / 19.10. (Abschlussturnier)',
		'Für wen | Jahrgang 2020 & 2021 | Kinder im Vorschul- und Schulalter',
		'Ort | Hauptplatz «Grüner Wald» | Schattdorf',
		'Kosten | CHF 2.– pro Training | Versicherung ist Sache der Teilnehmer',
	) ), $dry );
	fcs_meta( $fs->ID, 'fcs_fs_team', implode( "\n", array(
		'Jacqueline Kempf-Imholz | Leiterin Fussballschule | Jacqueline_Kempf.jpg',
		'Rachel Arnold | Betreuerin Fussballschule | rachel_ajpg.jpg',
		'Nicola Mahrow | Betreuer Fussballschule | Nici_Mahrow_2.jpg',
		'Orlando Gisler | Betreuer Fussballschule | Orlando_Gisler.jpg',
		'Robin Mahrow | Betreuer Fussballschule | Rubi_Mahrow.jpg',
		'Nico Zgraggen | Betreuer Fussballschule | Nico_Zgraggen.jpg',
		'Janic Gisler | Betreuer Fussballschule | ' . $SIL,
		'Fabio Tresch | Betreuer Fussballschule | ' . $SIL,
	) ), $dry );
}

/* ══════════════════════════════════════════════════════════════════
   G) Trainingslager
   ══════════════════════════════════════════════════════════════════ */
echo "\nG) Trainingslager\n";
$tl = fcs_seite( 'junioren/trainingslager' );
if ( ! $tl ) { $tl = fcs_seite( 'trainingslager' ); }
if ( ! $tl ) { echo "   FEHLER – Seite nicht gefunden.\n"; $fehler++; }
else {
	fcs_meta( $tl->ID, 'fcs_tl_daten', 'Juli 2027', $dry );
	/* Leere Felder = Vorlage blendet Anmelde-Buttons, Flyer-Abschnitt und
	   den Aufruf «Bist du dabei?» aus (siehe page-trainingslager.php). */
	fcs_meta( $tl->ID, 'fcs_tl_anmeldung_url', '', $dry );
	fcs_meta( $tl->ID, 'fcs_tl_cta_lead', '', $dry );
	fcs_meta( $tl->ID, 'fcs_tl_flyer_bild', '', $dry );
	fcs_meta( $tl->ID, 'fcs_tl_flyer_text', '', $dry );
	fcs_meta( $tl->ID, 'fcs_tl_facts', implode( "\n", array(
		'5 | Tage Trainingslager',
		'2× | Training täglich',
		'3× | Verpflegung pro Tag',
		'Juli | 2027 · Ort folgt',
	) ), $dry );
}

/* ══════════════════════════════════════════════════════════════════
   H) Bilder und Logos
   ══════════════════════════════════════════════════════════════════ */
echo "\nH) Bilder und Logos\n";

/* Die Dateien liegen in wp-content/uploads/2026/06/ und werden vom
   Deploy-Skript vorher hochgeladen. Fehlt eine, meldet dieser Teil das
   und lässt den betroffenen Eintrag unverändert. */
$dateien = array(
	'gasthaus-brueckli-2026.jpg',
	'zurich-ga-simon-mani-2026.png',
	'Leon_Ziegler.jpg',
	'Lucas_Martins_Ferreira.jpg',
	'Gisler_Stephan_2026.jpg',
	'Silhouette_Female.jpg',
	'ReneHueglin_2026.jpg',
	'FCS_2_Web2627.jpg',
	'Flyer_Fussballschule_Herbst_2026.pdf',
	'kms-2026.png',
	'gotthard-holzbau-2026.png',
	'heidi-nails-2026.png',
	'raiffeisen-2026.png',
	'schelbert-2026.png',
	'boge-2026.png',
	'cash-2026.png',
	'brand-automobile-2026.png',
	'Rene_Gnos_hoch.jpg',
	'Paddi_Schorno_hoch.jpg',
	'Iwan_Herger_hoch.jpg',
	'Markus_Indergand_hoch.jpg',
	'Kuster_farbig.png',
);
$updir = wp_upload_dir();
$fehlt = array();
foreach ( $dateien as $d ) {
	if ( ! file_exists( $updir['basedir'] . '/2026/06/' . $d ) ) { $fehlt[] = $d; }
}
if ( $fehlt ) {
	echo "   FEHLER – diese Dateien fehlen in uploads/2026/06: " . implode( ', ', $fehlt ) . "\n";
	echo "            Zuerst hochladen, dann dieses Skript erneut laufen lassen.\n";
	$fehler++;
}

/** Meta-Wert nur ersetzen, wenn er exakt dem erwarteten alten Wert entspricht. */
function fcs_ersetze_meta( $post_id, $key, $alt_erwartet, $neu, $dry, $force ) {
	$ist = (string) get_post_meta( $post_id, $key, true );
	if ( $ist === $neu ) { echo "   SKIP – #{$post_id} {$key} steht bereits auf «{$neu}».\n"; return; }
	if ( $ist !== $alt_erwartet && ! $force ) {
		echo "   ABBRUCH – #{$post_id} {$key} ist «{$ist}», erwartet war «{$alt_erwartet}».\n"
		   . "             Nichts geändert. Mit &force=1 trotzdem setzen.\n";
		return;
	}
	echo $dry ? "   würde setzen: #{$post_id} {$key} «{$ist}» -> «{$neu}»\n"
	          : "   gesetzt: #{$post_id} {$key} -> «{$neu}»\n";
	if ( ! $dry ) { update_post_meta( $post_id, $key, $neu ); }
}

/** Ersten Beitrag eines Typs mit diesem Titel holen. */
function fcs_nach_titel( $typ, $titel ) {
	$p = get_posts( array( 'post_type' => $typ, 'post_status' => 'any', 'posts_per_page' => 1, 'title' => $titel ) );
	return $p ? $p[0] : null;
}

/* H1) Sponsorenlogos: alte Datei -> neue Datei.
   Die sechs Spieler-Sponsoren stammen aus dem Ordner
   «Spielersponsoren-Logo» und sind durchwegs höher aufgelöst; bei
   Dätwyler, Synaxis, Centralgarage Musch und Apéro & Pasta ist die
   bisherige Datei besser (SVG bzw. grösser) und bleibt deshalb. */
$sponsor_logos = array(
	'gasthaus-brueckli-color.jpg' => 'gasthaus-brueckli-2026.jpg',
	'zurich_vers.png'             => 'zurich-ga-simon-mani-2026.png',
	'kms-orig2.jpg'               => 'kms-2026.png',              /*  456x188 ->  898x380 */
	'gotthard-orig.png'           => 'gotthard-holzbau-2026.png', /*  388x136 grau -> 1126x390 farbig */
	'heidi-nails-orig2.jpg'       => 'heidi-nails-2026.png',      /*  724x202 -> 1020x286 */
	'raiffeisen-color.png'        => 'raiffeisen-2026.png',       /*  348x51  ->  958x278 */
	'schelbert-color.png'         => 'schelbert-2026.png',        /*  300x82  -> 1020x296 */
	'boge-color.jpg'              => 'boge-2026.png',             /*  100x100 ->  340x432 */
	/* cash. und Brand Automobile lagen nur flaechig grau vor (ein
	   einziger Grauwert, Kantenglaettung im Alphakanal). Die neuen
	   Dateien sind dieselbe Grafik in der richtigen Farbe: cash. im
	   Markenblau #0B2A47 von cashsport.ch, Brand Automobile in
	   Schwarz — die Wortmarke der Garage ist einfarbig. */
	'Cash.png'                    => 'cash-2026.png',
	'brand-automobile-color.png'  => 'brand-automobile-2026.png',
);
foreach ( get_posts( array( 'post_type' => 'fcs_sponsor', 'post_status' => 'any', 'posts_per_page' => -1 ) ) as $sp ) {
	$logo = (string) get_post_meta( $sp->ID, 'fcs_sp_logo', true );
	if ( isset( $sponsor_logos[ $logo ] ) ) {
		fcs_ersetze_meta( $sp->ID, 'fcs_sp_logo', $logo, $sponsor_logos[ $logo ], $dry, $force );
	}
}

/* H2) Dieselben Logos in den Team-Sponsorenlisten der Seiten.
   Die Junioren fuehren Brueckli als «sp-gasthaus-brueckli.jpg», die
   1. Mannschaft als «gasthaus-brueckli-color.jpg» — beide alten Namen
   zeigen auf dasselbe alte Logo und werden hier ersetzt. */
$logo_tausch = array(
	'sp-gasthaus-brueckli.jpg'    => 'gasthaus-brueckli-2026.jpg',
	'gasthaus-brueckli-color.jpg' => 'gasthaus-brueckli-2026.jpg',
	'sp-zurich.jpg'               => 'zurich-ga-simon-mani-2026.png',
);
foreach ( array( 'fcs_jt_sponsoren', 'fcs_team_sponsoren' ) as $key ) {
	$seiten = get_posts( array(
		'post_type'      => 'page',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'meta_key'       => $key,
	) );
	foreach ( $seiten as $seite ) {
		$wert = (string) get_post_meta( $seite->ID, $key, true );
		$neu  = strtr( $wert, $logo_tausch );
		if ( $neu === $wert ) { continue; }
		echo $dry ? "   würde Logo(s) tauschen: #{$seite->ID} «{$seite->post_title}» ({$key})\n"
		          : "   Logo(s) getauscht: #{$seite->ID} «{$seite->post_title}» ({$key})\n";
		if ( ! $dry ) { update_post_meta( $seite->ID, $key, $neu ); }
	}
}

/* H3) Schiedsrichter-Fotos */
$sr_fotos = array(
	array( 'Leon Ziegler',           '',                   'Leon_Ziegler.jpg' ),
	array( 'Lucas Martins Ferreira', '',                   'Lucas_Martins_Ferreira.jpg' ),
	/* Stephan Gisler und René Hüglin: einheitliche Serie vom August 2026 */
	array( 'Stephan Gisler',         'Gisler_Stephan.jpg', 'Gisler_Stephan_2026.jpg' ),
	array( 'René Hüglin',            'ReneHueglin.jpg',    'ReneHueglin_2026.jpg' ),
);
foreach ( $sr_fotos as $f ) {
	list( $name, $alt, $neu ) = $f;
	$person = fcs_nach_titel( 'fcs_person', $name );
	if ( ! $person ) { echo "   FEHLER – Person «{$name}» nicht gefunden.\n"; $fehler++; continue; }
	fcs_ersetze_meta( $person->ID, 'fcs_pe_bild', $alt, $neu, $dry, $force );
}

/* H4) Flyer Fussballschule */
if ( isset( $fs ) && $fs ) {
	fcs_meta( $fs->ID, 'fcs_fs_pdf', $updir['baseurl'] . '/2026/06/Flyer_Fussballschule_Herbst_2026.pdf', $dry );
	fcs_meta( $fs->ID, 'fcs_fs_pdf_label', 'Flyer Fussballschule Herbst 2026 (PDF)', $dry );
}

/* ══════════════════════════════════════════════════════════════════
   I) 2. Mannschaft: Betreuerstab
   ══════════════════════════════════════════════════════════════════ */
echo "\nI) 2. Mannschaft\n";
$m2 = fcs_seite( 'aktive/2-mannschaft' );
if ( ! $m2 ) { $m2 = fcs_seite( '2-mannschaft' ); }
if ( ! $m2 ) { echo "   FEHLER – Seite nicht gefunden.\n"; $fehler++; }
else {
	/* Mathias Lussmann entfällt; Igor Sureta und Robin Lindauer neu.
	   Für Roger Zurfluh und Robin Lindauer liegt kein Foto vor. */
	fcs_meta( $m2->ID, 'fcs_team_staff', implode( "\n", array(
		'Betreuer | Igor Sureta | Igor_Sureta.jpg',
		'Betreuer | Roger Zurfluh | ' . $SIL,
		'Betreuer | Robin Lindauer | ' . $SIL,
	) ), $dry );
}

/* ══════════════════════════════════════════════════════════════════
   J) Vorstand: hochkant zugeschnittene Fotos
   ══════════════════════════════════════════════════════════════════ */
echo "\nJ) Vorstand: Hochformat-Zuschnitte\n";

/* Die Karten sind 363x484 (Verhaeltnis 3:4). Vier Fotos liegen quer
   (2500x1667); object-fit:cover schnitt davon die halbe Bildbreite weg
   und der Bildausschnitt war dem Zufall ueberlassen. Die neuen Dateien
   sind auf 1250x1667 vorgeschnitten, also genau 3:4 — die Person sitzt
   im Rahmen und es wird nichts mehr weggeschnitten.

   Wichtig: die neuen Dateien liegen bewusst NICHT als Mediathek-Eintrag
   vor und das <img> traegt keine wp-image-Klasse mehr. Sonst haengt
   WordPress ein srcset mit den alten Querformat-Vorschauen an, und der
   Browser holt sich je nach Bildschirm doch wieder den alten
   Ausschnitt. */
$vorstand_hoch = array(
	'Rene_Gnos'        => 'René Gnos',
	'Paddi_Schorno'    => 'Patrick Schorno',
	'Iwan_Herger'      => 'Iwan Herger',
	'Markus_Indergand' => 'Markus Indergand',
);

if ( ! isset( $vorstand ) || ! $vorstand ) {
	echo "   FEHLER – Vorstandsseite nicht gefunden.\n"; $fehler++;
} else {
	/* Frisch lesen: Teil C hat den Inhalt womoeglich schon geaendert. */
	$vp  = get_post( $vorstand->ID );
	$c   = $vp->post_content;
	$neu = $c;
	foreach ( $vorstand_hoch as $basis => $name ) {
		if ( false !== strpos( $neu, $basis . '_hoch.jpg' ) ) {
			echo "   SKIP – {$name} zeigt bereits auf {$basis}_hoch.jpg.\n";
			continue;
		}
		$muster  = '#<img\s+src="([^"]*)/uploads/2026/06/' . preg_quote( $basis, '#' ) . '\.jpg"([^>]*?)/>#';
		$treffer = preg_match( $muster, $neu );
		if ( ! $treffer ) {
			echo "   ABBRUCH – kein <img> mit {$basis}.jpg gefunden, {$name} unveraendert.\n";
			$fehler++;
			continue;
		}
		$neu = preg_replace(
			$muster,
			'<img src="$1/uploads/2026/06/' . $basis . '_hoch.jpg" alt="' . esc_attr( $name ) . '" width="1250" height="1667" />',
			$neu, 1 );
		echo $dry ? "   würde umhängen: {$name} -> {$basis}_hoch.jpg\n"
		          : "   umgehängt: {$name} -> {$basis}_hoch.jpg\n";
	}
	if ( $neu !== $c && ! $dry ) {
		wp_update_post( array( 'ID' => $vp->ID, 'post_content' => $neu ) );
		echo "   Vorstandsseite gespeichert.\n";
	}
}

/* ══════════════════════════════════════════════════════════════════
   K) Grümpelturnier: Farblogo Druckerei Kuster
   ══════════════════════════════════════════════════════════════════ */
echo "\nK) Grümpelturnier: Logo Druckerei Kuster\n";

/* Auf der Turnierseite lag von Kuster die reine Schwarz-Variante. Die
   Marke ist tatsaechlich farbig (graue Wortmarke, gelbgruenes «K») –
   belegt durch das Favicon der Firma und die Farbfassung derselben
   Datei (287x105, gleiche Abmessung wie ihre heutige Weiss-Fassung). */
$gt = fcs_seite( 'gruempelturnier' );
if ( ! $gt ) {
	echo "   FEHLER – Seite «gruempelturnier» nicht gefunden.\n"; $fehler++;
} else {
	$wert = (string) get_post_meta( $gt->ID, 'fcs_gt_sponsor_event', true );
	if ( false !== strpos( $wert, 'Kuster_farbig.png' ) ) {
		echo "   SKIP – zeigt bereits auf Kuster_farbig.png.\n";
	} elseif ( false === strpos( $wert, 'Kuster.png' ) ) {
		echo "   ABBRUCH – Kuster.png steht nicht im Feld, nichts geändert.\n"; $fehler++;
	} else {
		$neu = str_replace( 'Kuster.png', 'Kuster_farbig.png', $wert );
		echo $dry ? "   würde umhängen: Kuster.png -> Kuster_farbig.png\n"
		          : "   umgehängt: Kuster.png -> Kuster_farbig.png\n";
		if ( ! $dry ) { update_post_meta( $gt->ID, 'fcs_gt_sponsor_event', $neu ); }
	}
}

/* ══════════════════════════════════════════════════════════════════
   L) Juniorinnen: FF11, FF14 und FF17
   ══════════════════════════════════════════════════════════════════ */
echo "\nL) Juniorinnen-Teams\n";

/* Angaben der Redaktion vom 05.09.2026. Wo kein Portraet vorliegt, steht
   die Silhouette — die Mannschaftsfotos werden nachgereicht (FF11 von
   Aline Kempf, FF14 vom FC Altdorf, FF17 vom ESC), das Feld «Teamfoto»
   bleibt deshalb leer und die Uebersicht zeigt das Silhouetten-Symbol. */
$juniorinnen = array(
	'team-uri-ff11' => array(
		'titel' => 'Team Uri FF11', 'order' => 16,
		'staff' => array(
			'Betreuer | Michael Gisler | Michael_Gisler.jpg',
			'Betreuer | Ruedi Herger | Ruedi_Herger.jpg',
			'Betreuer | Marino Arnold | ' . $SIL,
			'Betreuer | Arturo Schneeberger | ' . $SIL,
		),
		'sponsoren' => array( 'Gasthaus Brückli | gasthaus-brueckli-2026.jpg | https://www.brueckli.ch/' ),
	),
	'team-uri-ff14' => array(
		'titel' => 'Team Uri FF14', 'order' => 17,
		'staff' => array(
			'Betreuer | Philipp Bissig | ' . $SIL,
			'Betreuer | Luca Forte | ' . $SIL,
			'Betreuer | Heinz Gisler | ' . $SIL,
		),
		'sponsoren' => array( 'Raiffeisen Urnerland | raiffeisen-2026.png | https://www.raiffeisen.ch/uri' ),
	),
	'team-uri-ff17' => array(
		'titel' => 'Team Uri FF17', 'order' => 18,
		'staff' => array(
			'Betreuer | Sam Bürer | sam_buerer_2.jpg',
			'Betreuerin | Noreen Häfliger | ' . $SILF,
		),
		/* Das Trikot ist das frühere Damen-2-Dress mit Teko-Werbung. */
		'sponsoren' => array( 'TEKO Oberflächentechnik | sp-teko.png | https://www.teko-ag.ch' ),
	),
);

foreach ( $juniorinnen as $slug => $d ) {
	$seite = fcs_seite( 'junioren/teams/' . $slug );
	if ( ! $seite ) { echo "   FEHLER – Seite «{$slug}» nicht gefunden.\n"; $fehler++; continue; }
	echo "  · {$slug}\n";
	fcs_titel( $seite, $d['titel'], $dry );
	fcs_meta( $seite->ID, 'fcs_jt_titel', $d['titel'], $dry );
	fcs_meta( $seite->ID, 'fcs_jt_betreuer', implode( "\n", $d['staff'] ), $dry );
	fcs_meta( $seite->ID, 'fcs_jt_sponsoren', implode( "\n", $d['sponsoren'] ), $dry );
	/* Mannschaftsfotos werden nachgereicht – Feld bleibt leer. */
	fcs_meta( $seite->ID, 'fcs_jt_foto', '', $dry );
	if ( (int) $seite->menu_order !== (int) $d['order'] ) {
		echo $dry ? "   würde Reihenfolge {$seite->menu_order} -> {$d['order']} setzen\n"
		          : "   Reihenfolge {$seite->menu_order} -> {$d['order']}\n";
		if ( ! $dry ) { wp_update_post( array( 'ID' => $seite->ID, 'menu_order' => (int) $d['order'] ) ); }
	}
}

/* ══════════════════════════════════════════════════════════════════
   M) Vereinsgeschichte: Eintrag «Erste Gründung» (1916)
   ══════════════════════════════════════════════════════════════════ */
echo "\nM) Vereinsgeschichte\n";

/* Die Chronik begann mit der ersten Gründung von 1916; der Verein zählt
   aber ab der Neugründung 1933 (Rückmeldung vom 05.09.2026). Der
   Eintrag geht in den Papierkorb, nicht in die endgültige Löschung —
   damit bleibt er im Admin wiederherstellbar.

   Nebenwirkungen, bewusst so: die Jahrzehnt-Leiste verliert den Eintrag
   «1910er», und der Zähler «Kapitel unserer Story» wird um eins
   kleiner. Das Gründungsjahr im Kopf bleibt bei 1933 — es kommt aus dem
   Seitenfeld «Gründungsjahr», nicht aus dem ersten Chronik-Eintrag. */
$ch = get_posts( array(
	'post_type'      => 'fcs_chronik',
	'post_status'    => 'publish',
	'posts_per_page' => -1,
	'meta_key'       => 'fcs_year',
	'meta_value'     => '1916',
) );
if ( ! $ch ) {
	echo "   SKIP – kein veröffentlichter Chronik-Eintrag mit Jahr 1916.\n";
} else {
	foreach ( $ch as $eintrag ) {
		echo $dry ? "   würde in den Papierkorb legen: #{$eintrag->ID} «{$eintrag->post_title}» (1916)\n"
		          : "   in den Papierkorb gelegt: #{$eintrag->ID} «{$eintrag->post_title}» (1916)\n";
		if ( ! $dry ) { wp_trash_post( $eintrag->ID ); }
	}
}

/* ══════════════════════════════════════════════════════════════════
   N) Vereinsgeschichte: Yoast-Beschreibung
   ══════════════════════════════════════════════════════════════════ */
echo "\nN) Vereinsgeschichte: Beschreibung\n";

/* Die Beschreibung stammt aus deploy/fcs-a7-inhalte.php.tpl und rechnete
   ab der ersten Gruendung: «110 Jahre» und «von der ersten Gruendung
   1916 bis heute». Beides widerspricht der Seite, die ab 1933 zaehlt
   (93 Jahre) und den 1916er-Eintrag seit Teil M nicht mehr fuehrt.

   Der neue Text nennt bewusst keine Jahreszahl der Vereinsdauer mehr —
   «110 Jahre» war genau die Sorte Angabe, die still veraltet.

   Das A7-Skript setzt Beschreibungen nur, wo noch keine steht, und
   ruehrt vorhandene nie an. Ein erneuter Lauf wuerde diesen Wert also
   nicht korrigieren; er muss hier gezielt ersetzt werden. */
/* Zielwert mit Platzhaltern: inc/fcs-vereinsjahre.php meldet sie bei
   Yoast an, eingesetzt werden sie bei jedem Seitenaufruf. Der
   Jahreswechsel braucht damit keinen Deploy. */
$vg_neu = '%%fcs_vereinsjahre%% Jahre FC Schattdorf: die Vereinsgeschichte von der Gründung %%fcs_gruendungsjahr%% bis heute – Meilensteine, Aufstiege und drei IFV-Cupsiege.';
/* Erlaubte Vorgaenger: der A7-Stand und die kurzzeitige Fassung ohne
   Jahresangabe. Alles andere ist Handarbeit und wird nicht angetastet. */
$vg_alte = array(
	'110 Jahre FC Schattdorf: die Vereinsgeschichte von der ersten Gründung 1916 bis heute – Meilensteine, Aufstiege und drei IFV-Cupsiege.',
	'Die Vereinsgeschichte des FC Schattdorf von der Gründung 1933 bis heute – Meilensteine, Aufstiege und drei IFV-Cupsiege.',
);
$vg = fcs_seite( 'verein/vereinsgeschichte' );
if ( ! $vg ) { $vg = fcs_seite( 'vereinsgeschichte' ); }
if ( ! $vg ) {
	echo "   FEHLER – Seite nicht gefunden.\n"; $fehler++;
} else {
	$ist = trim( (string) get_post_meta( $vg->ID, '_yoast_wpseo_metadesc', true ) );
	if ( $ist === $vg_neu ) {
		echo "   SKIP – Beschreibung steht bereits richtig.\n";
	} elseif ( ! in_array( $ist, $vg_alte, true ) && ! $force ) {
		echo "   ABBRUCH – Beschreibung lautet «{$ist}»,\n"
		   . "             erwartet war der Stand aus dem A7-Deploy. Nichts geändert.\n";
		$fehler++;
	} else {
		echo $dry ? "   würde setzen: «{$vg_neu}»\n" : "   gesetzt: «{$vg_neu}»\n";
		if ( ! $dry ) { update_post_meta( $vg->ID, '_yoast_wpseo_metadesc', $vg_neu ); }
	}
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
