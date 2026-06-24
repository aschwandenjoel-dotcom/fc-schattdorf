"use client";

import Link from "next/link";
import { useState } from "react";

const navigation = [
  { label: "Home", href: "/" },
  {
    label: "Verein",
    children: [
      { label: "Portrait", href: "/verein" },
      { label: "Vorstand", href: "/verein/vorstand" },
      { label: "Mitglied werden", href: "/verein/mitglied-werden" },
      { label: "Shop", href: "/verein/shop" },
      { label: "Sportanlage Grüner Wald", href: "/verein/anlage" },
      { label: "Schiedsrichter", href: "/verein/schiedsrichter" },
      { label: "Ehrenmitglieder", href: "/verein/ehrenmitglieder" },
      { label: "Geschichte", href: "/verein/geschichte" },
      { label: "Anfahrt", href: "/verein/anfahrt" },
      { label: "Vorfall melden", href: "/verein/vorfall-melden" },
    ],
  },
  { label: "Helfereinsätze", href: "/helfereinsaetze" },
  {
    label: "Aktive",
    children: [
      { label: "Übersicht", href: "/aktive" },
      { label: "1. Mannschaft", href: "/aktive/1-mannschaft" },
      { label: "2. Mannschaft", href: "/aktive/2-mannschaft" },
      { label: "3. Mannschaft", href: "/aktive/3-mannschaft" },
      { label: "Frauen Uri I", href: "/aktive/frauen-uri-1" },
      { label: "Frauen Uri II", href: "/aktive/frauen-uri-2" },
      { label: "Senioren Uri I", href: "/aktive/senioren-uri-1" },
    ],
  },
  {
    label: "Junioren",
    children: [
      { label: "Übersicht", href: "/junioren" },
      { label: "Organisation", href: "/junioren/organisation" },
      { label: "Geschichte", href: "/junioren/geschichte" },
      { label: "Teams", href: "/junioren/teams" },
      { label: "Trainerwesen", href: "/junioren/trainerwesen" },
      { label: "Goalietraining", href: "/junioren/goalietraining" },
      { label: "Fussballschule", href: "/junioren/fussballschule" },
      { label: "Trainingslager", href: "/junioren/trainingslager" },
      { label: "Rekrutierung", href: "/junioren/rekrutierung" },
    ],
  },
  {
    label: "Events",
    children: [
      { label: "Alle Events", href: "/events" },
      { label: "Dorfturnier", href: "/events/dorfturnier" },
    ],
  },
  {
    label: "Sponsoren",
    children: [
      { label: "Unsere Sponsoren", href: "/sponsoren" },
      { label: "Top-Club 88", href: "/sponsoren/top-club-88" },
    ],
  },
  { label: "Kontakt", href: "/kontakt" },
];

export default function Navbar() {
  const [menuOpen, setMenuOpen] = useState(false);
  const [openSection, setOpenSection] = useState<string | null>(null);

  return (
    <>
      {/* Fixed overlay navbar */}
      <header className="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-6 md:px-10 py-5">
        {/* Logo */}
        <Link href="/" onClick={() => setMenuOpen(false)}>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/images/fc-schattdorf-logo.jpg"
            alt="FC Schattdorf"
            style={{ height: "52px", width: "auto", display: "block" }}
          />
        </Link>

        {/* MENU Button */}
        <button
          onClick={() => setMenuOpen(!menuOpen)}
          className="flex items-center gap-2 text-white font-bold text-sm tracking-widest uppercase drop-shadow-lg hover:opacity-80 transition"
          aria-label="Menü"
        >
          <span>MENU</span>
          {/* Grid icon */}
          <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
            <rect x="3" y="3" width="4" height="4" rx="0.5" />
            <rect x="10" y="3" width="4" height="4" rx="0.5" />
            <rect x="17" y="3" width="4" height="4" rx="0.5" />
            <rect x="3" y="10" width="4" height="4" rx="0.5" />
            <rect x="10" y="10" width="4" height="4" rx="0.5" />
            <rect x="17" y="10" width="4" height="4" rx="0.5" />
            <rect x="3" y="17" width="4" height="4" rx="0.5" />
            <rect x="10" y="17" width="4" height="4" rx="0.5" />
            <rect x="17" y="17" width="4" height="4" rx="0.5" />
          </svg>
        </button>
      </header>

      {/* Full-screen overlay menu */}
      {menuOpen && (
        <div className="fixed inset-0 z-50 bg-gray-900/97 flex flex-col overflow-y-auto">
          {/* Close button */}
          <div className="flex items-center justify-between px-6 md:px-10 py-5">
            <Link href="/" onClick={() => setMenuOpen(false)}>
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/images/fc-schattdorf-logo.jpg"
                alt="FC Schattdorf"
                style={{ height: "52px", width: "auto", display: "block" }}
              />
            </Link>
            <button
              onClick={() => setMenuOpen(false)}
              className="text-white font-bold text-sm tracking-widest uppercase flex items-center gap-2 hover:opacity-80 transition"
            >
              <span>SCHLIESSEN</span>
              <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Nav items */}
          <nav className="flex-1 flex flex-col justify-center px-8 md:px-16 py-8">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-16 gap-y-2">
              {navigation.map((item) =>
                item.children ? (
                  <div key={item.label} className="mb-6">
                    <button
                      onClick={() =>
                        setOpenSection(openSection === item.label ? null : item.label)
                      }
                      className="flex items-center gap-2 text-white text-2xl md:text-3xl font-extrabold hover:text-primary transition-colors mb-2"
                    >
                      {item.label}
                      <svg
                        className={`w-5 h-5 transition-transform ${openSection === item.label ? "rotate-180" : ""}`}
                        fill="none" viewBox="0 0 24 24" stroke="currentColor"
                      >
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                      </svg>
                    </button>
                    {openSection === item.label && (
                      <div className="pl-2 space-y-1 mt-1">
                        {item.children.map((child) => (
                          <Link
                            key={child.href}
                            href={child.href}
                            onClick={() => setMenuOpen(false)}
                            className="block text-gray-400 hover:text-white text-sm transition-colors py-0.5"
                          >
                            → {child.label}
                          </Link>
                        ))}
                      </div>
                    )}
                  </div>
                ) : (
                  <div key={item.label} className="mb-6">
                    <Link
                      href={item.href!}
                      onClick={() => setMenuOpen(false)}
                      className="text-white text-2xl md:text-3xl font-extrabold hover:text-primary transition-colors"
                    >
                      {item.label}
                    </Link>
                  </div>
                )
              )}
            </div>
          </nav>

          {/* Footer of menu */}
          <div className="px-8 md:px-16 py-6 border-t border-white/10 flex flex-wrap gap-6 items-center">
            <a
              href="https://www.facebook.com/fcschattdorf.ch/"
              target="_blank" rel="noopener noreferrer"
              className="text-gray-400 hover:text-white transition text-sm"
            >
              Facebook
            </a>
            <a
              href="https://matchcenter.ifv.ch"
              target="_blank" rel="noopener noreferrer"
              className="text-gray-400 hover:text-white transition text-sm"
            >
              IFV Matchcenter
            </a>
            <span className="text-gray-600 text-sm">© {new Date().getFullYear()} FC Schattdorf</span>
          </div>
        </div>
      )}
    </>
  );
}
