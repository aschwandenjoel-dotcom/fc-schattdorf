"use client";

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";

interface SlideItem {
  slug: string;
  title: string;
  imageUrl?: string | null;
  createdAt?: string | null;
  teamTag?: string;
}

interface HeroSliderProps {
  slides: SlideItem[];
}

function formatDate(date?: string | null): string {
  if (!date) return "";
  return new Intl.DateTimeFormat("de-CH", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  }).format(new Date(date));
}

export default function HeroSlider({ slides }: HeroSliderProps) {
  const [current, setCurrent] = useState(0);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const prev = useCallback(() => {
    setCurrent((c) => (c === 0 ? slides.length - 1 : c - 1));
  }, [slides.length]);

  const next = useCallback(() => {
    setCurrent((c) => (c === slides.length - 1 ? 0 : c + 1));
  }, [slides.length]);

  useEffect(() => {
    if (!mounted || slides.length <= 1) return;
    const t = setTimeout(next, 7000);
    return () => clearTimeout(t);
  }, [current, next, slides.length, mounted]);

  const slide = slides[current] ?? null;

  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        height: "100vh",
        minHeight: "600px",
        overflow: "hidden",
        backgroundColor: "#212123",
      }}
    >
      {/* Background image */}
      {slide?.imageUrl && (
        <div
          style={{
            position: "absolute",
            inset: 0,
            backgroundImage: `url(${slide.imageUrl})`,
            backgroundSize: "cover",
            backgroundPosition: "center",
          }}
        />
      )}

      {/* Dark overlay */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: "linear-gradient(to bottom, rgba(0,0,0,0) 0%, rgba(0,0,0,0) 45%, rgba(0,0,0,0.9) 100%)",
        }}
      />

      {/* Content – bottom left */}
      <div
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          right: 0,
          padding: "0 2.5rem 6rem",
        }}
      >
        <div style={{ maxWidth: "800px" }}>
          {slide && (
            <>
              {/* Tag + date */}
              <div style={{ display: "flex", alignItems: "center", gap: "0.75rem", marginBottom: "1rem" }}>
                {slide.teamTag && (
                  <span
                    style={{
                      background: "#E30613",
                      color: "white",
                      fontSize: "0.75rem",
                      fontWeight: 700,
                      padding: "0.25rem 0.75rem",
                      textTransform: "uppercase",
                      letterSpacing: "0.05em",
                    }}
                  >
                    {slide.teamTag}
                  </span>
                )}
                {slide.createdAt && (
                  <span style={{ color: "rgba(255,255,255,0.7)", fontSize: "0.875rem", fontWeight: 500 }}>
                    {formatDate(slide.createdAt)}
                  </span>
                )}
              </div>

              {/* Headline */}
              <Link href={`/news/${slide.slug}`}>
                <h1
                  style={{
                    fontSize: "clamp(2rem, 5vw, 4rem)",
                    fontWeight: 900,
                    color: "white",
                    textTransform: "uppercase",
                    lineHeight: 1.1,
                    letterSpacing: "-0.02em",
                    textShadow: "0 2px 20px rgba(0,0,0,0.5)",
                    cursor: "pointer",
                    margin: 0,
                  }}
                >
                  {slide.title}
                </h1>
              </Link>
            </>
          )}

          {/* Slider controls */}
          {slides.length > 1 && (
            <div style={{ display: "flex", alignItems: "center", gap: "1rem", marginTop: "1.5rem" }}>
              <span style={{ color: "rgba(255,255,255,0.6)", fontSize: "0.875rem", fontWeight: 700 }}>
                {current + 1} / {slides.length}
              </span>
              <button
                onClick={prev}
                aria-label="Vorheriger Artikel"
                style={{
                  width: "36px", height: "36px",
                  borderRadius: "50%",
                  border: "1px solid rgba(255,255,255,0.4)",
                  background: "transparent",
                  color: "white",
                  cursor: "pointer",
                  display: "flex", alignItems: "center", justifyContent: "center",
                }}
              >
                ‹
              </button>
              <button
                onClick={next}
                aria-label="Nächster Artikel"
                style={{
                  width: "36px", height: "36px",
                  borderRadius: "50%",
                  border: "1px solid rgba(255,255,255,0.4)",
                  background: "transparent",
                  color: "white",
                  cursor: "pointer",
                  display: "flex", alignItems: "center", justifyContent: "center",
                }}
              >
                ›
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Bottom-right: Hauptsponsor + Socials */}
      <div
        style={{
          position: "absolute",
          bottom: "1.5rem",
          right: "2.5rem",
          display: "flex",
          flexDirection: "column",
          alignItems: "flex-end",
          gap: "0.75rem",
        }}
      >
        <div style={{ textAlign: "right" }}>
          <p style={{ color: "rgba(255,255,255,0.4)", fontSize: "0.625rem", textTransform: "uppercase", letterSpacing: "0.15em", fontWeight: 600, margin: "0 0 0.25rem" }}>
            Hauptsponsor
          </p>
          <p style={{ color: "white", fontWeight: 900, fontSize: "1.25rem", letterSpacing: "0.05em", margin: 0 }}>
            MUOSER
          </p>
        </div>
        <div style={{ display: "flex", gap: "0.75rem" }}>
          <a href="https://www.facebook.com/fcschattdorf.ch/" target="_blank" rel="noopener noreferrer" style={{ color: "rgba(255,255,255,0.6)" }}>
            <svg width="20" height="20" fill="currentColor" viewBox="0 0 24 24">
              <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
            </svg>
          </a>
          <a href="https://www.instagram.com/fcschattdorf/" target="_blank" rel="noopener noreferrer" style={{ color: "rgba(255,255,255,0.6)" }}>
            <svg width="20" height="20" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
            </svg>
          </a>
        </div>
      </div>

      {/* Scroll indicator */}
      <a
        href="#inhalt"
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          background: "#E30613",
          color: "white",
          display: "flex",
          alignItems: "center",
          gap: "0.75rem",
          padding: "1rem 1.5rem",
          fontSize: "0.75rem",
          fontWeight: 700,
          textTransform: "uppercase",
          letterSpacing: "0.1em",
          textDecoration: "none",
        }}
      >
        ↓ Bitte nach unten scrollen
      </a>
    </div>
  );
}
