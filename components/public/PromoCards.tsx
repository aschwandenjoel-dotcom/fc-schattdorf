"use client";
import { useRef } from "react";
import Link from "next/link";

const GAP = 20; // px between cards

const cards = [
  {
    label: "Werde Teil des FC Schattdorf",
    title: "Mitglied werden",
    href: "/verein/mitglied-werden",
    bg: "#8d9daa",
  },
  {
    label: "Spielerisch den Ball kennenlernen",
    title: "Fussballschule",
    href: "/junioren/fussballschule",
    bg: "#7b8f9e",
  },
  {
    label: "Freiwilliger Helfer an Spieltagen und Events",
    title: "Helfer gesucht",
    href: "/helfereinsaetze",
    bg: "#6a8192",
  },
  {
    label: "Ethikvorfälle im Schweizer Sport melden",
    title: "Vorfall melden",
    href: "/verein/vorfall-melden",
    bg: "#5c7487",
  },
  {
    label: "Das grosse Jahresevent des FC Schattdorf",
    title: "Dorfturnier",
    href: "/events/dorfturnier",
    bg: "#4f677b",
  },
  {
    label: "Ferien buchen und den FCS unterstützen",
    title: "FCS unterstützen",
    href: "/sponsoren",
    bg: "#435b6f",
  },
];

export default function PromoCards() {
  const trackRef = useRef<HTMLDivElement>(null);

  const scroll = (dir: number) => {
    const el = trackRef.current;
    if (!el) return;
    const firstCard = el.querySelector("a") as HTMLElement | null;
    if (!firstCard) return;
    el.scrollBy({ left: dir * (firstCard.offsetWidth + GAP), behavior: "smooth" });
  };

  return (
    <div style={{ position: "relative" }}>
      {/* ← Arrow */}
      <button
        onClick={() => scroll(-1)}
        aria-label="Zurück"
        style={{
          position: "absolute",
          left: "0.5rem",
          top: "50%",
          transform: "translateY(-50%)",
          zIndex: 10,
          width: "44px",
          height: "44px",
          borderRadius: "50%",
          border: "1.5px solid rgba(0,0,0,0.2)",
          background: "white",
          boxShadow: "0 2px 8px rgba(0,0,0,0.15)",
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: "1.375rem",
          color: "#111",
          lineHeight: 1,
        }}
      >
        ‹
      </button>

      {/* Carousel track */}
      <div
        ref={trackRef}
        className="hide-scrollbar"
        style={{
          display: "flex",
          gap: `${GAP}px`,
          overflowX: "auto",
          scrollSnapType: "x mandatory",
          scrollBehavior: "smooth",
        }}
      >
        {cards.map((card) => (
          <Link
            key={card.href}
            href={card.href}
            style={{
              flex: `0 0 calc(33.333% - ${((GAP * 2) / 3).toFixed(2)}px)`,
              aspectRatio: "1 / 1",
              position: "relative",
              overflow: "hidden",
              scrollSnapAlign: "start",
              textDecoration: "none",
              display: "block",
            }}
          >
            {/* Placeholder image */}
            <div
              style={{
                position: "absolute",
                inset: 0,
                backgroundColor: card.bg,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <span
                style={{
                  color: "rgba(255,255,255,0.35)",
                  fontSize: "0.75rem",
                  fontWeight: 700,
                  textTransform: "uppercase",
                  letterSpacing: "0.15em",
                }}
              >
                Foto folgt
              </span>
            </div>

            {/* Bottom gradient */}
            <div
              style={{
                position: "absolute",
                inset: 0,
                background:
                  "linear-gradient(to top, rgba(0,0,0,0.75) 0%, rgba(0,0,0,0.2) 45%, transparent 100%)",
              }}
            />

            {/* Label tag (top) */}
            <div style={{ position: "absolute", top: "1rem", left: "1rem" }}>
              <span
                style={{
                  backgroundColor: "#E30613",
                  color: "white",
                  fontSize: "0.6875rem",
                  fontWeight: 700,
                  padding: "0.25rem 0.625rem",
                  textTransform: "uppercase",
                  letterSpacing: "0.05em",
                  display: "inline-block",
                }}
              >
                {card.label}
              </span>
            </div>

            {/* Title overlay (bottom) */}
            <div
              style={{
                position: "absolute",
                bottom: "1.5rem",
                left: "1.5rem",
                right: "1.5rem",
              }}
            >
              <p
                style={{
                  color: "white",
                  fontSize: "clamp(1rem, 1.6vw, 1.5rem)",
                  fontWeight: 900,
                  textTransform: "uppercase",
                  margin: 0,
                  lineHeight: 1.15,
                  letterSpacing: "-0.01em",
                }}
              >
                {card.title}
              </p>
            </div>
          </Link>
        ))}
      </div>

      {/* → Arrow */}
      <button
        onClick={() => scroll(1)}
        aria-label="Weiter"
        style={{
          position: "absolute",
          right: "0.5rem",
          top: "50%",
          transform: "translateY(-50%)",
          zIndex: 10,
          width: "44px",
          height: "44px",
          borderRadius: "50%",
          border: "1.5px solid rgba(0,0,0,0.2)",
          background: "white",
          boxShadow: "0 2px 8px rgba(0,0,0,0.15)",
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: "1.375rem",
          color: "#111",
          lineHeight: 1,
        }}
      >
        ›
      </button>
    </div>
  );
}
