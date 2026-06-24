import { db } from "@/lib/db";
import { news, events, siteContent } from "@/lib/schema";
import { desc, eq, gte } from "drizzle-orm";
import HeroSlider from "@/components/public/HeroSlider";
import PromoCards from "@/components/public/PromoCards";
import Link from "next/link";

export const revalidate = 60;

const RED = "#E30613";
const DARK_GRAY = "#1f2937";

function fmtDate(d?: string | null): string {
  if (!d) return "";
  return new Intl.DateTimeFormat("de-CH", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  }).format(new Date(d));
}

export default async function HomePage() {
  const allNews = await db
    .select()
    .from(news)
    .where(eq(news.published, true))
    .orderBy(desc(news.createdAt))
    .limit(10);

  const upcomingEvents = await db
    .select()
    .from(events)
    .where(gte(events.eventDate, new Date()))
    .orderBy(events.eventDate)
    .limit(5);

  const allContent = await db.select().from(siteContent);
  const get = (key: string, fallback = "") =>
    allContent.find((c) => c.key === key)?.value ?? fallback;

  const matchDate     = get("last_match_date",      "13.06.2026");
  const matchHome     = get("last_match_home_team", "FC Rothenburg");
  const matchAway     = get("last_match_away_team", "FC Schattdorf");
  const matchScore    = get("last_match_score",     "2 : 3");
  const matchReportUrl = get("last_match_report_url", "https://matchcenter.ifv.ch");

  // Slider bekommt das FCS1-Bild als Fallback wenn kein imageUrl in der DB
  const teamFallback = (slug: string, index: number): string | null => {
    if (slug.includes("fcs-2") || slug.includes("2-mannschaft")) return "/images/fcs2-web.jpg";
    if (slug.includes("junioren-aa") || slug.includes("junioren-a"))  return "/images/aa-junioren-2526.jpg";
    if (slug.includes("junioren-cb") || slug.includes("junioren-c"))  return "/images/cb-junioren-2526.jpg";
    if (index === 0) return "/images/fcs1-web.jpg";
    return null;
  };

  const sliderNews = allNews.slice(0, 5).map((a, i) => ({
    slug:      a.slug,
    title:     a.title,
    imageUrl:  a.imageUrl ?? teamFallback(a.slug, i),
    createdAt: a.createdAt?.toISOString() ?? null,
    teamTag:   "FCS I",
  }));

  const [featured, ...rest] = allNews;

  const ifvLinks = [
    { label: "Tabelle",        url: "https://matchcenter.ifv.ch" },
    { label: "Spielplan",      url: "https://matchcenter.ifv.ch" },
    { label: "Spielbetrieb FCS", url: "https://matchcenter.ifv.ch" },
    { label: "Matchcenter",   url: "https://matchcenter.ifv.ch" },
    { label: "Liveticker",    url: "https://matchcenter.ifv.ch" },
  ];

  return (
    <>
      {/* ── Fixiertes Hintergrundbild – nur durch das transparente Fenster sichtbar ── */}
      <div style={{ position: "fixed", inset: 0, zIndex: -1, pointerEvents: "none" }}>
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src="/images/fcschattdorf_junioren1.jpg"
          alt=""
          style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }}
        />
      </div>

      {/* ── Inhalte im Vordergrund (z-index: 1, decken das Hintergrundbild ab) ── */}
      <div style={{ position: "relative", zIndex: 1, backgroundColor: "#212123" }}>
        <HeroSlider slides={sliderNews} />
      </div>

      <div id="inhalt" style={{ position: "relative", zIndex: 1 }}>
        {/* ── Zweispaltig: Rot (links) + News (rechts) ───────── */}
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr" }}>

          {/* ── LINKE SPALTE ──────────────────────────────────── */}
          <div style={{ display: "flex", flexDirection: "column", height: "100%" }}>
            {/* Roter Bereich – Match-Widget + IFV-Links */}
            <div style={{ backgroundColor: RED, padding: "2.5rem", flex: "9 1 auto", display: "flex", flexDirection: "column", justifyContent: "center" }}>

              {/* Match-Widget */}
              <div style={{ border: "1px solid rgba(255,255,255,0.35)", padding: "2.25rem 1.75rem", marginBottom: "1.5rem" }}>
                {/* Datum */}
                <div style={{ textAlign: "center", marginBottom: "1.5rem" }}>
                  <span style={{
                    border: "1px solid rgba(255,255,255,0.65)",
                    color: "white",
                    fontSize: "0.8125rem",
                    fontWeight: 700,
                    padding: "0.25rem 1rem",
                    letterSpacing: "0.1em",
                    display: "inline-block",
                  }}>
                    {matchDate}
                  </span>
                </div>

                {/* Teams + Resultat */}
                <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                  {/* Heimteam */}
                  <div style={{ textAlign: "center", flex: "1 1 0", minWidth: 0 }}>
                    <div style={{
                      width: "80px", height: "80px",
                      background: "rgba(255,255,255,0.18)",
                      borderRadius: "4px",
                      margin: "0 auto 0.625rem",
                      display: "flex", alignItems: "center", justifyContent: "center",
                    }}>
                      <span style={{ fontSize: "0.625rem", fontWeight: 700, color: "rgba(255,255,255,0.45)", textTransform: "uppercase" }}>Logo</span>
                    </div>
                    <p style={{ fontSize: "1rem", fontWeight: 700, textTransform: "uppercase", letterSpacing: "0.04em", color: "white", margin: 0, lineHeight: 1.3 }}>{matchHome}</p>
                  </div>

                  {/* Resultat */}
                  <div style={{ textAlign: "center", flexShrink: 0, padding: "0 1.5rem" }}>
                    <p style={{ fontSize: "5rem", fontWeight: 900, color: "white", margin: 0, letterSpacing: "-0.03em", lineHeight: 1 }}>{matchScore}</p>
                  </div>

                  {/* Auswärtsteam */}
                  <div style={{ textAlign: "center", flex: "1 1 0", minWidth: 0 }}>
                    <div style={{
                      width: "80px", height: "80px",
                      background: "rgba(255,255,255,0.18)",
                      borderRadius: "4px",
                      margin: "0 auto 0.625rem",
                      display: "flex", alignItems: "center", justifyContent: "center",
                    }}>
                      <span style={{ fontSize: "0.875rem", fontWeight: 800, color: "rgba(255,255,255,0.85)", textTransform: "uppercase" }}>FCS</span>
                    </div>
                    <p style={{ fontSize: "1rem", fontWeight: 700, textTransform: "uppercase", letterSpacing: "0.04em", color: "white", margin: 0, lineHeight: 1.3 }}>{matchAway}</p>
                  </div>
                </div>

                {/* Matchbericht-Link */}
                <div style={{ textAlign: "center", marginTop: "1.5rem" }}>
                  <a
                    href={matchReportUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "0.5rem",
                      border: "1px solid rgba(255,255,255,0.65)",
                      color: "white",
                      fontSize: "0.6875rem",
                      fontWeight: 700,
                      textTransform: "uppercase",
                      letterSpacing: "0.12em",
                      padding: "0.625rem 1.75rem",
                      textDecoration: "none",
                    }}
                  >
                    Matchbericht
                    <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </a>
                </div>
              </div>

              {/* IFV Quick-Links */}
              <div style={{ display: "flex", flexWrap: "wrap", gap: "0.5rem" }}>
                {ifvLinks.map((link) => (
                  <a
                    key={link.label}
                    href={link.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    style={{
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "0.25rem",
                      border: "1px solid rgba(255,255,255,0.5)",
                      color: "white",
                      fontSize: "0.6875rem",
                      fontWeight: 700,
                      textTransform: "uppercase",
                      letterSpacing: "0.08em",
                      padding: "0.375rem 0.75rem",
                      textDecoration: "none",
                    }}
                  >
                    {link.label}
                    <svg width="10" height="10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </a>
                ))}
              </div>
            </div>

            {/* Weisser Bereich – Termine */}
            <div style={{ backgroundColor: "white", padding: "2.5rem", flexGrow: 1 }}>
              <h2 style={{ fontSize: "3rem", fontWeight: 900, color: "#111827", textTransform: "uppercase", margin: "0 0 2rem", letterSpacing: "-0.02em" }}>
                Termine
              </h2>

              {upcomingEvents.length > 0 ? (
                <div>
                  {upcomingEvents.map((event) => {
                    const d = new Date(event.eventDate.toISOString());
                    const day   = d.getDate();
                    const month = new Intl.DateTimeFormat("de-CH", { month: "short" }).format(d).toUpperCase();
                    const fullDate = new Intl.DateTimeFormat("de-CH", { day: "2-digit", month: "2-digit", year: "numeric" }).format(d);
                    return (
                      <div key={event.id} style={{ display: "flex", gap: "1.5rem", padding: "1.5rem 0", borderBottom: "1px solid #f3f4f6", alignItems: "flex-start" }}>
                        {/* Grosses Datum-Box */}
                        <div style={{
                          flexShrink: 0,
                          width: "80px", height: "80px",
                          border: `2px solid ${RED}`,
                          display: "flex", flexDirection: "column",
                          alignItems: "center", justifyContent: "center",
                        }}>
                          <span style={{ fontSize: "2.25rem", fontWeight: 900, color: "#111827", lineHeight: 1 }}>{day}</span>
                          <span style={{ fontSize: "0.75rem", fontWeight: 700, color: "#9ca3af", letterSpacing: "0.08em", marginTop: "2px" }}>{month}</span>
                        </div>
                        {/* Text */}
                        <div style={{ display: "flex", flexDirection: "column", justifyContent: "center", paddingTop: "0.5rem" }}>
                          <p style={{ fontWeight: 800, color: "#111827", fontSize: "1.125rem", margin: "0 0 0.375rem", lineHeight: 1.2 }}>{event.title}</p>
                          {event.location && (
                            <p style={{ fontSize: "0.875rem", color: "#6b7280", margin: "0 0 0.25rem" }}>{event.location}</p>
                          )}
                          <p style={{ fontSize: "0.8125rem", color: "#9ca3af", margin: 0, display: "flex", alignItems: "center", gap: "0.25rem" }}>
                            <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" style={{ flexShrink: 0 }}>
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            {fullDate}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                </div>
              ) : (
                <p style={{ color: "#9ca3af", fontSize: "0.875rem" }}>Keine Termine vorhanden.</p>
              )}

              <Link
                href="/events"
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "0.5rem",
                  marginTop: "2rem",
                  backgroundColor: RED,
                  color: "white",
                  fontSize: "0.75rem",
                  fontWeight: 700,
                  textTransform: "uppercase",
                  letterSpacing: "0.1em",
                  padding: "0.875rem 1.5rem",
                  textDecoration: "none",
                }}
              >
                Weitere Termine
                <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" />
                </svg>
              </Link>
            </div>
          </div>

          {/* ── RECHTE SPALTE: NEWS ───────────────────────────── */}
          <div style={{ backgroundColor: "#f9fafb", padding: "2.5rem", borderLeft: "1px solid #e5e7eb" }}>
            <h2 style={{ fontSize: "3rem", fontWeight: 900, color: "#111827", textTransform: "uppercase", margin: "0 0 1.5rem", letterSpacing: "-0.02em" }}>
              News
            </h2>

            {/* Featured Artikel */}
            {featured && (
              <Link href={`/news/${featured.slug}`} style={{ display: "block", textDecoration: "none", marginBottom: "2rem" }}>
                {/* Bild */}
                <div style={{ position: "relative", overflow: "hidden", aspectRatio: "16/10", backgroundColor: "#e5e7eb" }}>
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={featured.imageUrl ?? "/images/fcs1-web.jpg"}
                    alt={featured.title}
                    style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }}
                  />
                  {/* Datum + Team-Tag Overlay */}
                  <div style={{ position: "absolute", bottom: 0, left: 0, display: "flex" }}>
                    {featured.createdAt && (
                      <span style={{ backgroundColor: RED, color: "white", fontSize: "0.875rem", fontWeight: 700, padding: "0.375rem 0.75rem" }}>
                        {fmtDate(featured.createdAt.toISOString())}
                      </span>
                    )}
                    <span style={{ backgroundColor: DARK_GRAY, color: "white", fontSize: "0.875rem", fontWeight: 700, padding: "0.375rem 0.75rem" }}>
                      FCS I
                    </span>
                  </div>
                </div>

                {/* Titel + Teaser */}
                <div style={{ marginTop: "1rem" }}>
                  <h3 style={{ fontSize: "1.25rem", fontWeight: 900, color: "#111827", margin: "0 0 0.5rem", lineHeight: 1.3 }}>
                    {featured.title}
                  </h3>
                  {featured.content && (
                    <p style={{ fontSize: "0.875rem", color: "#6b7280", margin: 0, lineHeight: 1.6, display: "-webkit-box", WebkitLineClamp: 3, WebkitBoxOrient: "vertical", overflow: "hidden" }}>
                      {featured.content}
                    </p>
                  )}
                </div>
              </Link>
            )}

            {/* News-Liste: Rot-Datum | Grau-Tag | Titel */}
            <div style={{ borderTop: "1px solid #e5e7eb" }}>
              {rest.slice(0, 5).map((article) => {
                const tag = article.slug.includes("junioren-cb") ? "Junioren Cb"
                  : article.slug.includes("junioren-b") ? "Junioren B"
                  : article.slug.includes("junioren-aa") || article.slug.includes("junioren-a") ? "Junioren Aa"
                  : article.slug.includes("frauen") ? "Frauen Uri"
                  : article.slug.includes("senioren") ? "Senioren"
                  : article.slug.includes("fcs-2") || article.slug.includes("2-mannschaft") ? "FCS II"
                  : "FCS I";
                return (
                  <Link
                    key={article.id}
                    href={`/news/${article.slug}`}
                    style={{ display: "flex", alignItems: "center", padding: "0.35rem 0", borderBottom: "1px solid #e5e7eb", textDecoration: "none", gap: 0 }}
                  >
                    {/* Rotes Datum */}
                    {article.createdAt && (
                      <span style={{
                        flexShrink: 0,
                        backgroundColor: RED,
                        color: "white",
                        fontSize: "0.8125rem",
                        fontWeight: 700,
                        padding: "0.375rem 0.625rem",
                        whiteSpace: "nowrap",
                      }}>
                        {fmtDate(article.createdAt.toISOString())}
                      </span>
                    )}
                    {/* Grauer Team-Tag */}
                    <span style={{
                      flexShrink: 0,
                      backgroundColor: "#e5e7eb",
                      color: "#4b5563",
                      fontSize: "0.8125rem",
                      fontWeight: 600,
                      padding: "0.375rem 0.625rem",
                      whiteSpace: "nowrap",
                      width: "6.5rem",
                      display: "inline-block",
                      textAlign: "center",
                    }}>
                      {tag}
                    </span>
                    {/* Titel */}
                    <span style={{
                      flex: 1,
                      fontSize: "0.9375rem",
                      fontWeight: 500,
                      color: "#111827",
                      paddingLeft: "0.875rem",
                      overflow: "hidden",
                      textOverflow: "ellipsis",
                      whiteSpace: "nowrap",
                    }}>
                      {article.title}
                    </span>
                  </Link>
                );
              })}
            </div>

            {/* Roter "Weitere News"-Button */}
            <Link
              href="/news"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "0.5rem",
                marginTop: "2rem",
                backgroundColor: RED,
                color: "white",
                fontSize: "0.75rem",
                fontWeight: 700,
                textTransform: "uppercase",
                letterSpacing: "0.1em",
                padding: "0.875rem 1.5rem",
                textDecoration: "none",
              }}
            >
              Weitere News
              <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" />
              </svg>
            </Link>
          </div>
        </div>
      </div>

      {/* ── Transparentes Fenster – Hintergrundbild scheint durch ── */}
      <div style={{ position: "relative", zIndex: 1, height: "55vh" }}>
        {/* Gradient für Lesbarkeit des Textes */}
        <div style={{ position: "absolute", inset: 0, background: "linear-gradient(to top, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0.1) 55%, transparent 100%)" }} />
        <div style={{ position: "absolute", bottom: "2.5rem", left: "3rem" }}>
          <p style={{ color: "white", fontSize: "1.125rem", fontWeight: 400, letterSpacing: "0.1em", margin: "0 0 0.375rem", textTransform: "uppercase" }}>
            FC Schattdorf
          </p>
          <h2 style={{ color: "white", fontSize: "clamp(2rem, 4vw, 3.5rem)", fontWeight: 900, textTransform: "uppercase", margin: 0, lineHeight: 1.1, letterSpacing: "-0.02em" }}>
            Seit 1933 für unsere Zukunft<br />am Ball
          </h2>
        </div>
      </div>

      {/* ── Restlicher Inhalt, deckt das Hintergrundbild wieder ab ── */}
      <div style={{ position: "relative", zIndex: 1, backgroundColor: "white" }}>
        {/* Promo Cards */}
        <div style={{ padding: "3rem 2.5rem", backgroundColor: "white" }}>
          <PromoCards />
        </div>

      </div>
    </>
  );
}
