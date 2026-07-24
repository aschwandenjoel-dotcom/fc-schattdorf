<?php
/**
 * Template Name: Fanshop
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

/* ── Enqueue shop assets early (before wp_head in get_header) ── */
add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    $v_css = filemtime( $dir . '/assets/fcs-shop.css' );
    $v_js  = filemtime( $dir . '/assets/fcs-shop.js' );
    wp_enqueue_style(  'fcs-shop', $uri . '/assets/fcs-shop.css', [], $v_css );
    wp_enqueue_script( 'fcs-shop', $uri . '/assets/fcs-shop.js',  [], $v_js, true );
}, 5 );

/* ── Product catalogue (Inhaltstyp fcs_produkt, siehe inc/fcs-produkte.php) ── */
$uploads_base = wp_upload_dir()['baseurl'] . '/2026/06/';
$products = fcs_get_produkte();

/* ── Pass data to JS ── */
add_action( 'wp_footer', function () use ( $products, $uploads_base ) {
    $js_products = array_map( function( $p ) {
        return [
            'id'          => $p['id'],
            'name'        => $p['name'],
            'price'       => (float) $p['price'],
            'image'       => $p['image'],
            'sizes'       => $p['sizes'],
            'description' => $p['description'],
        ];
    }, $products );
    echo '<script>window.fcsShopData=' . json_encode( [
        'products' => $js_products,
        'ajaxUrl'  => admin_url( 'admin-ajax.php' ),
        'nonce'    => wp_create_nonce( 'fcs_shop_order' ),
        'uploads'  => $uploads_base,
    ] ) . ';</script>';
}, 1 );

get_header();
?>

<div class="fcs-shop">

  <!-- ── Shop hero ── -->
  <div class="fcs-shop-hero">
    <div>
      <h1>Fanshop</h1>
      <p>Bei Zustellung per Post wird zusätzlich das Porto verrechnet. &nbsp;·&nbsp; Zahlungsart: Rechnung &nbsp;·&nbsp; Unsere Fanartikel sind auch im Clubhaus erhältlich.</p>
    </div>
    <button class="fcs-shop-cart-btn" onclick="fcsOpenCart()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 2 3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
        <line x1="3" y1="6" x2="21" y2="6"/>
        <path d="M16 10a4 4 0 01-8 0"/>
      </svg>
      Warenkorb
      <span class="fcs-cart-badge" id="fcsCartBadge1"></span>
    </button>
  </div>

  <!-- ── Product grid ── -->
  <div class="fcs-shop-grid">
    <?php foreach ( $products as $p ) :
      $img_url = esc_url( $uploads_base . $p['image'] );
      $has_sizes = ! empty( $p['sizes'] );
    ?>
    <div class="fcs-product-card" onclick="fcsOpenProduct('<?php echo esc_js( $p['id'] ); ?>')">
      <div class="fcs-product-card__img">
        <img src="<?php echo $img_url; ?>" alt="<?php echo esc_attr( $p['name'] ); ?>" loading="lazy">
      </div>
      <div class="fcs-product-card__info">
        <div class="fcs-product-card__cat"><?php echo esc_html( $p['category'] ); ?></div>
        <div class="fcs-product-card__name"><?php echo esc_html( $p['name'] ); ?></div>
        <div class="fcs-product-card__price">Fr. <?php echo number_format( $p['price'], 2 ); ?></div>
        <?php if ( $has_sizes ) : ?>
          <div class="fcs-product-card__sizes">Gr.: <?php echo esc_html( implode( ', ', $p['sizes'] ) ); ?></div>
        <?php else : ?>
          <div class="fcs-product-card__sizes">One Size</div>
        <?php endif; ?>
        <button class="fcs-product-card__add" onclick="event.stopPropagation(); fcsOpenProduct('<?php echo esc_js( $p['id'] ); ?>')">
          Details &amp; bestellen
        </button>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

</div><!-- .fcs-shop -->


<!-- ── Product modal ── -->
<div class="fcs-modal-backdrop" id="fcsModalBackdrop"></div>
<div class="fcs-product-modal" id="fcsProductModal" role="dialog" aria-modal="true">
  <div class="fcs-product-modal__inner">
    <button class="fcs-product-modal__close" onclick="fcsCloseModal()" aria-label="Schliessen">
      <svg viewBox="0 0 16 16" fill="none">
        <path d="M2 2l12 12M14 2L2 14" stroke="#333" stroke-width="2" stroke-linecap="round"/>
      </svg>
    </button>
    <div class="fcs-product-modal__gallery">
      <img id="fcsModalImg" src="" alt="">
    </div>
    <div class="fcs-product-modal__info">
      <div class="fcs-product-modal__label">FC Schattdorf Fanshop</div>
      <h2 class="fcs-product-modal__name" id="fcsModalName"></h2>
      <div class="fcs-product-modal__price" id="fcsModalPrice"></div>
      <p class="fcs-product-modal__desc" id="fcsModalDesc"></p>

      <div id="fcsSizeBlock">
        <span class="fcs-size-label">Grösse wählen</span>
        <div class="fcs-size-picker" id="fcsSizePicker"></div>
        <div class="fcs-size-error" id="fcsSizeError">Bitte wähle eine Grösse.</div>
      </div>

      <div class="fcs-qty-row">
        <span class="fcs-qty-label">Anzahl</span>
        <div class="fcs-qty-ctrl">
          <button id="fcsModalQtyMinus">−</button>
          <span id="fcsModalQtyVal">1</span>
          <button id="fcsModalQtyPlus">+</button>
        </div>
      </div>

      <button class="fcs-modal-add-btn" id="fcsModalAddBtn">In den Warenkorb</button>
    </div>
  </div>
</div>


<!-- ── Cart backdrop ── -->
<div class="fcs-modal-backdrop" id="fcsCartBackdrop" style="z-index:9050"></div>

<!-- ── Cart sidebar ── -->
<aside class="fcs-cart-sidebar" id="fcsCartSidebar" role="dialog" aria-modal="true" aria-label="Warenkorb">
  <div class="fcs-cart-sidebar__head">
    <div>
      <span class="fcs-cart-sidebar__title">Warenkorb</span>
      <span class="fcs-cart-sidebar__count" id="fcsCartCount">0 Artikel</span>
    </div>
    <button class="fcs-cart-sidebar__close" onclick="fcsCloseCart()" aria-label="Schliessen">
      <svg viewBox="0 0 14 14" fill="none">
        <path d="M1 1l12 12M13 1L1 13" stroke="#333" stroke-width="2" stroke-linecap="round"/>
      </svg>
    </button>
  </div>

  <div class="fcs-cart-sidebar__body" id="fcsCartBody">
    <div class="fcs-cart-empty">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
        <path d="M6 2 3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
        <line x1="3" y1="6" x2="21" y2="6"/>
        <path d="M16 10a4 4 0 01-8 0"/>
      </svg>
      <p>Dein Warenkorb ist leer.</p>
    </div>
  </div>

  <div class="fcs-cart-sidebar__foot" id="fcsCartFoot" style="display:none">
    <div class="fcs-cart-subtotal">
      <span>Zwischensumme</span>
      <span id="fcsCartSubtotal">Fr. 0.00</span>
    </div>
    <div class="fcs-cart-shipping-note">Versandkosten werden nach Bestelleingang mitgeteilt.</div>
    <button class="fcs-checkout-btn" onclick="fcsOpenOrder()">Bestellung aufgeben →</button>
  </div>
</aside>


<!-- ── Order modal backdrop ── -->
<div class="fcs-modal-backdrop" id="fcsOrderModalBackdrop" style="z-index:9150"></div>

<!-- ── Order modal ── -->
<div class="fcs-order-modal" id="fcsOrderModal" role="dialog" aria-modal="true" aria-label="Bestellung aufgeben">
  <div class="fcs-order-modal__backdrop" id="fcsOrderModalBackdropInner" onclick="fcsCloseOrder()"></div>
  <div class="fcs-order-modal__inner">
    <button class="fcs-order-modal__close" onclick="fcsCloseOrder()" aria-label="Schliessen">
      <svg viewBox="0 0 14 14" fill="none">
        <path d="M1 1l12 12M13 1L1 13" stroke-width="2" stroke-linecap="round"/>
      </svg>
    </button>

    <div class="fcs-form-section" id="fcsFormSection">
      <h2>Bestellung aufgeben</h2>

      <div class="fcs-order-summary">
        <h3>Deine Bestellung</h3>
        <div id="fcsOrderLines"></div>
        <div class="fcs-order-total-line">
          <span>Total</span>
          <span id="fcsOrderTotal"></span>
        </div>
      </div>

      <form id="fcsOrderForm">
        <div class="fcs-form-grid">
          <div class="fcs-field">
            <label for="fcsVorname">Vorname <span class="req">*</span></label>
            <input type="text" id="fcsVorname" name="vorname" required autocomplete="given-name" placeholder="Max">
          </div>
          <div class="fcs-field">
            <label for="fcsNachname">Nachname <span class="req">*</span></label>
            <input type="text" id="fcsNachname" name="nachname" required autocomplete="family-name" placeholder="Muster">
          </div>
          <div class="fcs-field fcs-field-full">
            <label for="fcsEmail">E-Mail <span class="req">*</span></label>
            <input type="email" id="fcsEmail" name="email" required autocomplete="email" placeholder="max@muster.ch">
          </div>
          <div class="fcs-field">
            <label for="fcsTelefon">Telefon</label>
            <input type="tel" id="fcsTelefon" name="telefon" autocomplete="tel" placeholder="079 000 00 00">
          </div>
          <div class="fcs-field fcs-field-full">
            <label for="fcsAdresse">Strasse &amp; Hausnummer <span class="req">*</span></label>
            <input type="text" id="fcsAdresse" name="adresse" required autocomplete="street-address" placeholder="Musterstrasse 1">
          </div>
          <div class="fcs-field">
            <label for="fcsPlz">PLZ <span class="req">*</span></label>
            <input type="text" id="fcsPlz" name="plz" required autocomplete="postal-code" placeholder="6468" maxlength="6">
          </div>
          <div class="fcs-field">
            <label for="fcsOrt">Ort <span class="req">*</span></label>
            <input type="text" id="fcsOrt" name="ort" required autocomplete="address-level2" placeholder="Attinghausen">
          </div>
          <div class="fcs-field fcs-field-full">
            <label for="fcsBemerkung">Bemerkungen</label>
            <textarea id="fcsBemerkung" name="bemerkung" placeholder="Abholung im Clubhaus, spezielle Wünsche …"></textarea>
          </div>
        </div>
        <p class="fcs-form-note">* Pflichtfelder. Bezahlung per Rechnung nach Lieferung. Bei Postversand wird Porto zusätzlich berechnet.</p>
        <button type="submit" class="fcs-submit-btn" id="fcsSubmitBtn">Bestellung absenden</button>
      </form>
    </div>

    <!-- Success -->
    <div class="fcs-success-state" id="fcsSuccessState">
      <svg viewBox="0 0 64 64" fill="none">
        <circle cx="32" cy="32" r="30" fill="#e8f5ef"/>
        <path d="M20 33l9 9 15-16" stroke="#1a8a3e" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
      <h3>Vielen Dank für deine Bestellung!</h3>
      <p>Wir haben deine Bestellung erhalten und melden uns in Kürze mit einer Bestätigung und Rechnung per E-Mail.</p>
      <button class="fcs-success-close-btn" onclick="fcsCloseOrder()">Weiter shoppen</button>
    </div>

  </div>
</div>

<!-- ── Global close X – shown above all modals/cart (hides WP admin bar) ── -->
<button class="fcs-global-close" id="fcsGlobalClose" aria-label="Schliessen" onclick="fcsGlobalClose()">
  <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round">
    <line x1="5" y1="5" x2="19" y2="19"/>
    <line x1="19" y1="5" x2="5" y2="19"/>
  </svg>
</button>

<?php get_footer(); ?>
