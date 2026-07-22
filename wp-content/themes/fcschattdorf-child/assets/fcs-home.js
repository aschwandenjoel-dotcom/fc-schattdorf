/* FC Schattdorf – Startseite: Slider, Promo-Carousel, Menü-Overlay */
(function () {
  "use strict";

  document.addEventListener("DOMContentLoaded", function () {
    /* ── Menü-Overlay ──────────────────────────────── */
    var openBtn  = document.querySelector("[data-fcsh-menu-open]");
    var overlay  = document.querySelector(".fcsh-overlay");
    var closeBtn = document.querySelector("[data-fcsh-menu-close]");
    if (openBtn && overlay) {
      openBtn.addEventListener("click", function () { overlay.classList.add("is-open"); document.body.style.overflow = "hidden"; });
    }
    if (closeBtn && overlay) {
      closeBtn.addEventListener("click", function () { overlay.classList.remove("is-open"); document.body.style.overflow = ""; });
    }
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && overlay) { overlay.classList.remove("is-open"); document.body.style.overflow = ""; }
    });
    // Aufklappbare Menü-Sektionen
    Array.prototype.forEach.call(document.querySelectorAll("[data-fcsh-section]"), function (btn) {
      btn.addEventListener("click", function () { btn.closest(".fcsh-mitem").classList.toggle("is-open"); });
    });

    /* ── Kopfzeile: schrumpft beim Runterscrollen ──── */
    var hdrEl = document.querySelector("[data-fcx-hdr]");
    if (hdrEl) {
      var setScrolled = function () {
        hdrEl.classList.toggle("is-scrolled", window.scrollY > 40);
      };
      setScrolled();
      window.addEventListener("scroll", setScrolled, { passive: true });
    }

    /* ── Kopfzeile: Unterkategorien-Panel ──────────── */
    var hdr = document.querySelector("[data-fcx-hdr]");
    if (hdr) {
      var toggles = Array.prototype.slice.call(hdr.querySelectorAll("[data-fcx-toggle]"));
      var panels  = Array.prototype.slice.call(hdr.querySelectorAll("[data-fcx-mega]"));
      var closeTimer = null;

      function closeAll() {
        panels.forEach(function (p) { p.classList.remove("is-open"); });
        toggles.forEach(function (t) { t.setAttribute("aria-expanded", "false"); });
      }
      function open(key) {
        clearTimeout(closeTimer);
        panels.forEach(function (p) {
          p.classList.toggle("is-open", p.getAttribute("data-fcx-mega") === key);
        });
        toggles.forEach(function (t) {
          t.setAttribute("aria-expanded", t.getAttribute("data-fcx-toggle") === key ? "true" : "false");
        });
      }

      toggles.forEach(function (t) {
        var key = t.getAttribute("data-fcx-toggle");
        t.addEventListener("mouseenter", function () { open(key); });
        t.addEventListener("focus", function () { open(key); });
        t.addEventListener("click", function () {
          if (t.getAttribute("aria-expanded") === "true") { closeAll(); } else { open(key); }
        });
      });

      // Nur schliessen, wenn die Maus die ganze Kopfzeile verlässt
      hdr.addEventListener("mouseleave", function () {
        closeTimer = setTimeout(closeAll, 120);
      });
      hdr.addEventListener("mouseenter", function () { clearTimeout(closeTimer); });
      document.addEventListener("keydown", function (e) { if (e.key === "Escape") closeAll(); });
      document.addEventListener("click", function (e) { if (!hdr.contains(e.target)) closeAll(); });
    }

    /* ── Scroll-Reveal (nur mit JS; Inhalt ist ohne JS sichtbar) ── */
    var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var revealGroups = document.querySelectorAll(".fcx-newsgrid, .fcx-termine, .fcx-spgroup__items, .fcx-people .fcx-prose .wp-block-columns");
    if (revealGroups.length && "IntersectionObserver" in window && !reduceMotion) {
      document.documentElement.classList.add("fcx-reveal-ready");
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) return;
          entry.target.classList.add("is-in");
          io.unobserve(entry.target);
        });
      }, { rootMargin: "0px 0px -8% 0px", threshold: 0.1 });

      Array.prototype.forEach.call(revealGroups, function (group) {
        Array.prototype.forEach.call(group.children, function (child, i) {
          child.classList.add("fcx-reveal");
          child.style.setProperty("--fcx-i", Math.min(i, 5));
          io.observe(child);
        });
      });
    }

    /* ── Hero-Slider ───────────────────────────────── */
    var slides = Array.prototype.slice.call(document.querySelectorAll(".fcsh-hero__slide"));
    var titleEls = {
      tag:   document.querySelector("[data-hero-tag]"),
      date:  document.querySelector("[data-hero-date]"),
      title: document.querySelector("[data-hero-title]"),
      link:  document.querySelector("[data-hero-link]"),
      count: document.querySelector("[data-hero-count]")
    };
    var heroData = [];
    try { heroData = JSON.parse(document.getElementById("fcsh-hero-data").textContent); } catch (e) {}
    var cur = 0, timer = null;
    function render(i) {
      slides.forEach(function (s, idx) { s.classList.toggle("is-active", idx === i); });
      var d = heroData[i];
      if (d && titleEls.title) {
        if (titleEls.tag)  titleEls.tag.textContent = d.tag || "";
        if (titleEls.date) titleEls.date.textContent = d.date || "";
        if (titleEls.title) titleEls.title.textContent = d.title || "";
        if (titleEls.link) titleEls.link.setAttribute("href", d.url || "#");
        if (titleEls.count) titleEls.count.textContent = (i + 1) + " / " + slides.length;
      }
    }
    function go(n) { cur = (n + slides.length) % slides.length; render(cur); schedule(); }
    function schedule() { if (slides.length > 1) { clearTimeout(timer); timer = setTimeout(function () { go(cur + 1); }, 7000); } }
    var prev = document.querySelector("[data-hero-prev]"), next = document.querySelector("[data-hero-next]");
    if (prev) prev.addEventListener("click", function () { go(cur - 1); });
    if (next) next.addEventListener("click", function () { go(cur + 1); });
    if (slides.length) { render(0); schedule(); }

    /* ── Promo-Carousel ────────────────────────────── */
    var track = document.querySelector(".fcsh-promo__track");
    if (track) {
      var GAP = 20;
      function scrollBy(dir) {
        var card = track.querySelector(".fcsh-card");
        if (!card) return;
        track.scrollBy({ left: dir * (card.offsetWidth + GAP), behavior: "smooth" });
      }
      var pl = document.querySelector("[data-promo-prev]"), pr = document.querySelector("[data-promo-next]");
      if (pl) pl.addEventListener("click", function () { scrollBy(-1); });
      if (pr) pr.addEventListener("click", function () { scrollBy(1); });
    }
  });
})();
