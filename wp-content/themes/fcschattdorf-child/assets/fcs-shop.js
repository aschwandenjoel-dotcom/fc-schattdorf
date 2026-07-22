/* FC Schattdorf – Fanshop JavaScript */
(function () {
  'use strict';

  /* ── Products (injected from PHP via fcsShopData global) ── */
  const PRODUCTS = window.fcsShopData ? window.fcsShopData.products : [];
  const AJAX_URL = window.fcsShopData ? window.fcsShopData.ajaxUrl : '';
  const NONCE    = window.fcsShopData ? window.fcsShopData.nonce   : '';

  /* ── Cart state ── */
  let cart = [];
  try { cart = JSON.parse(localStorage.getItem('fcs_cart') || '[]'); } catch(e) { cart = []; }

  function saveCart() { localStorage.setItem('fcs_cart', JSON.stringify(cart)); }

  function cartKey(productId, size) { return size ? productId + '|' + size : productId; }

  function addToCart(productId, size, qty) {
    const key = cartKey(productId, size);
    const existing = cart.find(i => i.key === key);
    if (existing) {
      existing.qty += qty;
    } else {
      const p = PRODUCTS.find(p => p.id === productId);
      if (!p) return;
      cart.push({ key, productId, name: p.name, price: p.price, size: size || null, qty, image: p.image });
    }
    saveCart(); renderCart(); updateBadge();
  }

  function removeFromCart(key) {
    cart = cart.filter(i => i.key !== key);
    saveCart(); renderCart(); updateBadge();
  }

  function changeQty(key, delta) {
    const item = cart.find(i => i.key === key);
    if (!item) return;
    item.qty = Math.max(1, item.qty + delta);
    saveCart(); renderCart();
  }

  function clearCart() { cart = []; saveCart(); renderCart(); updateBadge(); }

  function getTotal() { return cart.reduce((s, i) => s + i.price * i.qty, 0); }
  function getCount() { return cart.reduce((s, i) => s + i.qty, 0); }

  /* ── Badge ── */
  function updateBadge() {
    const n = getCount();
    document.querySelectorAll('.fcs-cart-badge').forEach(b => {
      b.textContent = n;
      b.classList.toggle('visible', n > 0);
    });
  }

  /* ── Cart render ── */
  function renderCart() {
    const body = document.getElementById('fcsCartBody');
    const foot = document.getElementById('fcsCartFoot');
    if (!body) return;

    if (cart.length === 0) {
      body.innerHTML = `
        <div class="fcs-cart-empty">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path d="M6 2 3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
            <line x1="3" y1="6" x2="21" y2="6"/>
            <path d="M16 10a4 4 0 01-8 0"/>
          </svg>
          <p>Dein Warenkorb ist leer.</p>
        </div>`;
      if (foot) foot.style.display = 'none';
      return;
    }

    if (foot) foot.style.display = '';

    const uploads = window.fcsShopData ? window.fcsShopData.uploads : '';
    body.innerHTML = cart.map(item => `
      <div class="fcs-cart-item">
        <div class="fcs-cart-item__img">
          <img src="${uploads}${item.image}" alt="${escHtml(item.name)}">
        </div>
        <div class="fcs-cart-item__meta">
          <div class="fcs-cart-item__name">${escHtml(item.name)}</div>
          ${item.size ? `<div class="fcs-cart-item__size">Grösse: ${escHtml(item.size)}</div>` : ''}
          <div class="fcs-cart-item__bottom">
            <div class="fcs-cart-item__qty">
              <button onclick="fcsCartQty('${item.key}',-1)">−</button>
              <span>${item.qty}</span>
              <button onclick="fcsCartQty('${item.key}',1)">+</button>
            </div>
            <div class="fcs-cart-item__price">Fr. ${(item.price * item.qty).toFixed(2)}</div>
          </div>
        </div>
        <button class="fcs-cart-item__remove" onclick="fcsCartRemove('${item.key}')" title="Entfernen">✕</button>
      </div>
    `).join('');

    const sub = document.getElementById('fcsCartSubtotal');
    if (sub) sub.textContent = 'Fr. ' + getTotal().toFixed(2);

    const count = document.getElementById('fcsCartCount');
    if (count) count.textContent = getCount() + (getCount() === 1 ? ' Artikel' : ' Artikel');
  }

  /* expose to inline onclick handlers */
  window.fcsCartRemove = removeFromCart;
  window.fcsCartQty    = changeQty;

  /* ── Product Modal ── */
  let modalProduct = null;
  let modalQty     = 1;
  let modalSize    = null;

  /* ── Modal state tracker ── */
  let _openModal = null; // 'product' | 'cart' | 'order'

  function setModalOpen(which) {
    _openModal = which;
    document.body.classList.add('fcs-modal-open');
    document.body.style.overflow = 'hidden';
    const btn = document.getElementById('fcsGlobalClose');
    if (btn) btn.classList.add('visible');
  }
  function clearModalOpen() {
    _openModal = null;
    document.body.classList.remove('fcs-modal-open');
    document.body.style.overflow = '';
    const btn = document.getElementById('fcsGlobalClose');
    if (btn) btn.classList.remove('visible');
  }

  window.fcsGlobalClose = function() {
    if (_openModal === 'product') closeProductModal();
    else if (_openModal === 'cart') closeCart();
    else if (_openModal === 'order') closeOrderModal();
  };

  function openProductModal(productId) {
    const p = PRODUCTS.find(p => p.id === productId);
    if (!p) return;
    modalProduct = p;
    modalQty  = 1;
    modalSize = null;

    const uploads = window.fcsShopData ? window.fcsShopData.uploads : '';
    document.getElementById('fcsModalImg').src        = uploads + p.image;
    document.getElementById('fcsModalImg').alt        = p.name;
    document.getElementById('fcsModalName').textContent  = p.name;
    document.getElementById('fcsModalPrice').textContent = 'Fr. ' + p.price.toFixed(2);
    document.getElementById('fcsModalDesc').textContent  = p.description;
    document.getElementById('fcsModalQtyVal').textContent = '1';
    document.getElementById('fcsSizeError').classList.remove('visible');

    const sizeBlock = document.getElementById('fcsSizeBlock');
    const picker    = document.getElementById('fcsSizePicker');
    if (p.sizes && p.sizes.length > 0) {
      sizeBlock.style.display = '';
      picker.innerHTML = p.sizes.map(s =>
        `<button class="fcs-size-btn" onclick="fcsSelectSize('${s}')">${escHtml(s)}</button>`
      ).join('');
    } else {
      sizeBlock.style.display = 'none';
    }

    document.getElementById('fcsModalAddBtn').classList.remove('added');
    document.getElementById('fcsModalAddBtn').textContent = 'In den Warenkorb';

    document.getElementById('fcsModalBackdrop').classList.add('open');
    document.getElementById('fcsProductModal').classList.add('open');
    setModalOpen('product');
  }

  window.fcsSelectSize = function(size) {
    modalSize = size;
    document.querySelectorAll('.fcs-size-btn').forEach(b => {
      b.classList.toggle('active', b.textContent === size);
    });
    document.getElementById('fcsSizeError').classList.remove('visible');
  };

  function closeProductModal() {
    document.getElementById('fcsModalBackdrop').classList.remove('open');
    document.getElementById('fcsProductModal').classList.remove('open');
    clearModalOpen();
  }

  window.fcsOpenProduct = openProductModal;
  window.fcsCloseModal  = closeProductModal;

  /* ── Cart sidebar ── */
  function openCart() {
    renderCart();
    document.getElementById('fcsCartSidebar').classList.add('open');
    document.getElementById('fcsCartBackdrop').classList.add('open');
    setModalOpen('cart');
  }
  function closeCart() {
    document.getElementById('fcsCartSidebar').classList.remove('open');
    document.getElementById('fcsCartBackdrop').classList.remove('open');
    clearModalOpen();
  }
  window.fcsOpenCart  = openCart;
  window.fcsCloseCart = closeCart;

  /* ── Order modal ── */
  function openOrderModal() {
    // Close cart first (clears modal state), then re-open as 'order'
    document.getElementById('fcsCartSidebar').classList.remove('open');
    document.getElementById('fcsCartBackdrop').classList.remove('open');

    const lines = document.getElementById('fcsOrderLines');
    lines.innerHTML = cart.map(i => `
      <div class="fcs-order-line">
        <span>${i.qty}× ${escHtml(i.name)}${i.size ? ' ('+escHtml(i.size)+')' : ''}</span>
        <span>Fr. ${(i.price * i.qty).toFixed(2)}</span>
      </div>
    `).join('');
    document.getElementById('fcsOrderTotal').textContent = 'Fr. ' + getTotal().toFixed(2);

    document.getElementById('fcsSuccessState').classList.remove('visible');
    document.getElementById('fcsFormSection').classList.remove('hidden');
    document.getElementById('fcsOrderForm').reset();
    document.getElementById('fcsSubmitBtn').disabled = false;
    document.getElementById('fcsSubmitBtn').textContent = 'Bestellung absenden';

    document.getElementById('fcsOrderModalBackdrop').classList.add('open');
    document.getElementById('fcsOrderModal').classList.add('open');
    setModalOpen('order');
  }
  function closeOrderModal() {
    document.getElementById('fcsOrderModal').classList.remove('open');
    document.getElementById('fcsOrderModalBackdrop').classList.remove('open');
    clearModalOpen();
  }
  window.fcsOpenOrder  = openOrderModal;
  window.fcsCloseOrder = closeOrderModal;

  /* ── Helpers ── */
  function escHtml(s) {
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }

  /* ── Init ── */
  document.addEventListener('DOMContentLoaded', function () {
    updateBadge();
    renderCart();

    /* Modal qty controls */
    document.getElementById('fcsModalQtyMinus').addEventListener('click', function () {
      if (modalQty > 1) { modalQty--; document.getElementById('fcsModalQtyVal').textContent = modalQty; }
    });
    document.getElementById('fcsModalQtyPlus').addEventListener('click', function () {
      modalQty++; document.getElementById('fcsModalQtyVal').textContent = modalQty;
    });

    /* Modal add to cart */
    document.getElementById('fcsModalAddBtn').addEventListener('click', function () {
      if (!modalProduct) return;
      if (modalProduct.sizes && modalProduct.sizes.length > 0 && !modalSize) {
        document.getElementById('fcsSizeError').classList.add('visible');
        return;
      }
      addToCart(modalProduct.id, modalSize, modalQty);
      this.textContent = '✓ Hinzugefügt';
      this.classList.add('added');
      setTimeout(() => { closeProductModal(); }, 800);
    });

    /* Close modal on backdrop */
    document.getElementById('fcsModalBackdrop').addEventListener('click', closeProductModal);

    /* Cart backdrop */
    document.getElementById('fcsCartBackdrop').addEventListener('click', closeCart);

    /* Order modal backdrop */
    document.getElementById('fcsOrderModalBackdrop').addEventListener('click', closeOrderModal);

    /* Order form submit */
    document.getElementById('fcsOrderForm').addEventListener('submit', function (e) {
      e.preventDefault();
      const btn = document.getElementById('fcsSubmitBtn');
      btn.disabled = true;
      btn.textContent = 'Wird gesendet…';

      const fd = new FormData(this);
      const orderLines = cart.map(i =>
        i.qty + '× ' + i.name + (i.size ? ' (Gr. '+i.size+')' : '') + ' – Fr. ' + (i.price*i.qty).toFixed(2)
      ).join('\n');

      fd.append('action', 'fcs_shop_order');
      fd.append('nonce', NONCE);
      fd.append('order_items', orderLines);
      fd.append('order_total', 'Fr. ' + getTotal().toFixed(2));

      fetch(AJAX_URL, { method: 'POST', body: fd })
        .then(r => r.json())
        .then(data => {
          if (data.success) {
            clearCart();
            document.getElementById('fcsFormSection').classList.add('hidden');
            document.getElementById('fcsSuccessState').classList.add('visible');
          } else {
            btn.disabled = false;
            btn.textContent = 'Bestellung absenden';
            alert('Fehler: ' + (data.data || 'Bitte versuche es nochmals.'));
          }
        })
        .catch(() => {
          btn.disabled = false;
          btn.textContent = 'Bestellung absenden';
          alert('Netzwerkfehler – bitte versuche es nochmals.');
        });
    });
  });

})();
