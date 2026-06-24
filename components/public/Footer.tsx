import Link from "next/link";

const FOOTER_BG = "#212123";
const BAR_BG    = "#151517";
const RED      = "#E30613";

const navButtons = [
  { label: "Kontakt",  href: "/kontakt" },
  { label: "Vorstand", href: "/verein/vorstand" },
  { label: "Lageplan", href: "/verein/anlage" },
  { label: "Login",    href: "/admin" },
];

const sponsorGroups = [
  {
    label: "Hauptsponsor",
    fontSize: "1.75rem",
    letterSpacing: "0.04em",
    items: [{ name: "Muoser" }],
  },
  {
    label: "Nachwuchs-Patronat",
    fontSize: "1.375rem",
    letterSpacing: "0.02em",
    items: [{ name: "GAMMA" }],
  },
  {
    label: "Co-Sponsoren",
    fontSize: "0.9375rem",
    letterSpacing: "0",
    items: [
      { name: "Herger Küchen AG" },
      { name: "Autohaus Uri" },
      { name: "Sport Imholz" },
      { name: "cash." },
    ],
  },
  {
    label: "Club-Sponsoren",
    fontSize: "0.9375rem",
    letterSpacing: "0",
    items: [{ name: "FC Schattdorf Supporters" }],
  },
  {
    label: "Nachwuchs-Sponsoren",
    fontSize: "0.9375rem",
    letterSpacing: "0",
    items: [
      { name: "EWA energieUri" },
      { name: "Urner Kantonalbank" },
      { name: "Arnold AG" },
      { name: "Zahnarzt-URI.ch" },
    ],
  },
];

export default function Footer() {
  return (
    <footer>
      {/* ── Two-column dark section ─────────────────────────── */}
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr" }}>

        {/* ── LEFT: Newsletter ──────────────────────────────── */}
        <div style={{
          backgroundColor: FOOTER_BG,
          padding: "3.5rem 3.5rem",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          minHeight: "420px",
        }}>
          <div>
            {/* Envelope icon */}
            <div style={{ marginBottom: "1rem" }}>
              <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                <rect x="2" y="4" width="20" height="16" rx="2" />
                <path d="M2 7l10 7 10-7" />
              </svg>
            </div>

            {/* Heading */}
            <h2 style={{
              color: "white",
              fontSize: "clamp(2.25rem, 4.5vw, 4rem)",
              fontWeight: 900,
              textTransform: "uppercase",
              letterSpacing: "-0.025em",
              lineHeight: 1,
              margin: "0 0 1.75rem",
            }}>
              Newsletter
            </h2>

            {/* CTA */}
            <Link
              href="/newsletter"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "0.875rem",
                textDecoration: "none",
                marginBottom: "3rem",
              }}
            >
              <span style={{
                color: "white",
                fontSize: "0.8125rem",
                fontWeight: 700,
                textTransform: "uppercase",
                letterSpacing: "0.1em",
              }}>
                Jetzt anmelden
              </span>
              <span style={{
                width: "2.375rem",
                height: "2.375rem",
                borderRadius: "50%",
                border: "1.5px solid rgba(255,255,255,0.45)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                color: "white",
                fontSize: "1.125rem",
                lineHeight: 1,
                flexShrink: 0,
              }}>
                →
              </span>
            </Link>
          </div>

          <div>
            {/* FCS Logo */}
            <div style={{ marginBottom: "2rem" }}>
              <Link href="/" style={{ textDecoration: "none", display: "inline-block" }}>
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src="/images/fc-schattdorf-logo.jpg"
                  alt="FC Schattdorf"
                  style={{ height: "80px", width: "auto", display: "block" }}
                />
              </Link>
            </div>

            {/* Nav buttons */}
            <div style={{ display: "flex", gap: "0.5rem", flexWrap: "wrap" }}>
              {navButtons.map((btn) => (
                <Link
                  key={btn.href}
                  href={btn.href}
                  style={{
                    color: "white",
                    border: "1px solid rgba(255,255,255,0.35)",
                    fontSize: "0.6875rem",
                    fontWeight: 700,
                    textTransform: "uppercase",
                    letterSpacing: "0.1em",
                    padding: "0.5rem 1.125rem",
                    textDecoration: "none",
                    transition: "border-color 0.15s",
                  }}
                >
                  {btn.label}
                </Link>
              ))}
            </div>
          </div>
        </div>

        {/* ── RIGHT: Sponsoren ─────────────────────────────── */}
        <div style={{
          backgroundColor: FOOTER_BG,
          padding: "3.5rem 3.5rem",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          gap: 0,
        }}>
          {sponsorGroups.map((group, idx) => (
            <div
              key={group.label}
              style={{
                borderTop: idx > 0 ? "1px solid rgba(255,255,255,0.07)" : "none",
                paddingTop: idx > 0 ? "1.5rem" : 0,
                paddingBottom: "1.5rem",
              }}
            >
              <p style={{
                color: "rgba(255,255,255,0.3)",
                fontSize: "0.625rem",
                fontWeight: 700,
                textTransform: "uppercase",
                letterSpacing: "0.15em",
                margin: "0 0 0.75rem",
              }}>
                {group.label}
              </p>
              <div style={{
                display: "flex",
                alignItems: "center",
                gap: "2rem",
                flexWrap: "wrap",
              }}>
                {group.items.map((item) => (
                  <span
                    key={item.name}
                    style={{
                      color: "rgba(255,255,255,0.55)",
                      fontSize: group.fontSize,
                      fontWeight: 700,
                      letterSpacing: group.letterSpacing,
                      lineHeight: 1.2,
                    }}
                  >
                    {item.name}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* ── Copyright bar ──────────────────────────────────── */}
      <div style={{
        backgroundColor: BAR_BG,
        padding: "1.125rem 3.5rem",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        flexWrap: "wrap",
        gap: "0.5rem",
      }}>
        <p style={{
          color: "rgba(255,255,255,0.28)",
          fontSize: "0.75rem",
          margin: 0,
          letterSpacing: "0.02em",
        }}>
          © {new Date().getFullYear()} FC Schattdorf
        </p>
        <div style={{ display: "flex", gap: "1.5rem" }}>
          {[
            { label: "Impressum",   href: "/impressum" },
            { label: "Datenschutz", href: "/datenschutz" },
          ].map((l) => (
            <Link
              key={l.href}
              href={l.href}
              style={{
                color: "rgba(255,255,255,0.28)",
                fontSize: "0.75rem",
                textDecoration: "none",
                letterSpacing: "0.06em",
                textTransform: "uppercase",
              }}
            >
              {l.label}
            </Link>
          ))}
        </div>
      </div>
    </footer>
  );
}
