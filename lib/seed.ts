import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";
import * as schema from "./schema";

const sql = neon(process.env.DATABASE_URL!);
const db = drizzle(sql, { schema });

async function seed() {
  console.log("🌱 Seeding database...");

  // ─── News ────────────────────────────────────────────────────────────────
  await db.insert(schema.news).values([
    {
      slug: "kantersieg-rueckrundenabschluss",
      title: "Kantersieg zum Rückrundenabschluss",
      content:
        "Mit einem überzeugenden 6:2-Sieg gegen den FC Hochdorf beendete die 1. Mannschaft des FC Schattdorf die Rückrunde auf starkem Kurs. Die Mannschaft zeigte eine konzentrierte Leistung und belohnte sich mit einem verdienten Erfolg.",
      published: true,
    },
    {
      slug: "derby-sieg-junioren-cb",
      title: "Derbysieg für die Junioren Cb",
      content:
        "Grosser Jubel bei den Junioren Cb des FC Schattdorf: Im heiss umkämpften Derby setzte sich das Team knapp durch und feierte einen wichtigen Sieg im Abstiegskampf.",
      published: true,
    },
    {
      slug: "saisonfinale-fcs-1-2",
      title: "Saisonfinale für FCS I und II",
      content:
        "Beide Aktivmannschaften des FC Schattdorf bestreiten am kommenden Wochenende ihr Saisonfinale. Die Fans sind herzlich eingeladen, die Teams zu unterstützen.",
      published: true,
    },
    {
      slug: "saisonabschluss-fcs-2",
      title: "Gelungener Saisonabschluss",
      content:
        "Die 2. Mannschaft des FC Schattdorf hat die Saison mit einem gelungenen Abschluss beendet. Das Team blickt auf eine erfolgreiche Spielzeit zurück und freut sich auf die neue Saison.",
      published: true,
    },
    {
      slug: "saisonabschluss-junioren-aa",
      title: "A-Junioren gewinnen gegen den Leader",
      content:
        "Die Junioren Aa des FC Schattdorf haben in einem spannenden Spiel den Tabellenführer bezwungen. Ein grossartiger Erfolg für das Nachwuchsteam.",
      published: true,
    },
  ]).onConflictDoNothing();

  // ─── Teams ───────────────────────────────────────────────────────────────
  await db.insert(schema.teams).values([
    {
      slug: "1-mannschaft",
      name: "1. Mannschaft",
      category: "aktive",
      description: "Die 1. Mannschaft des FC Schattdorf – das Aushängeschild unseres Vereins.",
      matchcenterUrl: "https://matchcenter.ifv.ch",
      sortOrder: 1,
    },
    {
      slug: "2-mannschaft",
      name: "2. Mannschaft",
      category: "aktive",
      description: "Die 2. Mannschaft des FC Schattdorf.",
      trainerName: "Mathias Lussmann / Roger Zurfluh",
      trainerContact: "+41 79 265 01 68",
      matchcenterUrl: "https://matchcenter.ifv.ch",
      sortOrder: 2,
    },
    {
      slug: "3-mannschaft",
      name: "3. Mannschaft",
      category: "aktive",
      description: "Die 3. Mannschaft des FC Schattdorf.",
      matchcenterUrl: "https://matchcenter.ifv.ch",
      sortOrder: 3,
    },
    {
      slug: "frauen-uri-1",
      name: "Frauen Uri I",
      category: "frauen",
      description: "Das erste Frauenteam von FC Schattdorf / Frauen Uri.",
      matchcenterUrl: "https://matchcenter.ifv.ch",
      sortOrder: 4,
    },
    {
      slug: "frauen-uri-2",
      name: "Frauen Uri II",
      category: "frauen",
      description: "Das zweite Frauenteam von FC Schattdorf / Frauen Uri.",
      matchcenterUrl: "https://matchcenter.ifv.ch",
      sortOrder: 5,
    },
    {
      slug: "senioren-uri-1",
      name: "Senioren Uri I",
      category: "senioren",
      description: "Das Seniorenteam des FC Schattdorf / Uri.",
      matchcenterUrl: "https://matchcenter.ifv.ch",
      sortOrder: 6,
    },
    // Junioren
    { slug: "a-junioren", name: "A-Junioren", category: "junioren", sortOrder: 10 },
    { slug: "b-junioren-a", name: "B-Junioren A", category: "junioren", sortOrder: 11 },
    { slug: "b-junioren-b", name: "B-Junioren B", category: "junioren", sortOrder: 12 },
    { slug: "c-junioren-a", name: "C-Junioren A", category: "junioren", sortOrder: 13 },
    { slug: "c-junioren-b", name: "C-Junioren B", category: "junioren", sortOrder: 14 },
    { slug: "d-junioren-a", name: "D-Junioren A", category: "junioren", sortOrder: 15 },
    { slug: "d-junioren-b", name: "D-Junioren B", category: "junioren", sortOrder: 16 },
    { slug: "e-junioren-a", name: "E-Junioren A", category: "junioren", sortOrder: 17 },
    { slug: "e-junioren-b", name: "E-Junioren B", category: "junioren", sortOrder: 18 },
    { slug: "e-junioren-c", name: "E-Junioren C", category: "junioren", sortOrder: 19 },
    { slug: "f-junioren-a", name: "F-Junioren A", category: "junioren", sortOrder: 20 },
    { slug: "f-junioren-b", name: "F-Junioren B", category: "junioren", sortOrder: 21 },
    { slug: "f-junioren-c", name: "F-Junioren C", category: "junioren", sortOrder: 22 },
    { slug: "ff-junioren-a", name: "Ff-Junioren A", category: "junioren", sortOrder: 23 },
    { slug: "ff-junioren-b", name: "Ff-Junioren B", category: "junioren", sortOrder: 24 },
    { slug: "ff-junioren-c", name: "Ff-Junioren C", category: "junioren", sortOrder: 25 },
  ]).onConflictDoNothing();

  // ─── Sponsors ────────────────────────────────────────────────────────────
  await db.insert(schema.sponsors).values([
    { name: "Muöser", category: "hauptsponsor", sortOrder: 1 },
    { name: "Gamma Holding", category: "junioren_patron", sortOrder: 2 },
    { name: "Herger Küchen", category: "co_sponsor", sortOrder: 3 },
    { name: "Brand Automobile", category: "co_sponsor", sortOrder: 4 },
    { name: "Imholz Sport", category: "co_sponsor", sortOrder: 5 },
    { name: "Cash Sport", category: "co_sponsor", sortOrder: 6 },
    { name: "Porr", category: "top_club_88", sortOrder: 7 },
    { name: "Zurich Versicherung", category: "top_club_88", sortOrder: 8 },
    { name: "Albert Burch", category: "top_club_88", sortOrder: 9 },
    { name: "Christen Automobile", category: "top_club_88", sortOrder: 10 },
    { name: "Arnold Coag", category: "top_club_88", sortOrder: 11 },
  ]).onConflictDoNothing();

  // ─── Events ──────────────────────────────────────────────────────────────
  await db.insert(schema.events).values([
    {
      title: "93. Generalversammlung",
      description: "Jährliche Generalversammlung des FC Schattdorf. Alle Mitglieder sind herzlich eingeladen.",
      eventDate: new Date("2026-08-21T19:00:00"),
      location: "Sportanlage Grüner Wald, Schattdorf",
      published: true,
    },
  ]).onConflictDoNothing();

  // ─── Site Content ────────────────────────────────────────────────────────
  const contents = [
    { key: "verein_portrait", value: "Der FC Schattdorf wurde am 9. September 1933 gegründet und ist seither ein fester Bestandteil des Dorflebens in Schattdorf UR. Mit rund 600 Mitgliedern und 21 Teams bietet der Verein Fussball für alle Altersklassen – von den kleinsten Ff-Junioren bis zu den Aktiven und Senioren." },
    { key: "verein_geschichte_intro", value: "Der FC Schattdorf blickt auf eine stolze Geschichte von über 90 Jahren zurück. Seit der Gründung am 9. September 1933 hat der Verein Generationen von Fussballer-innen begleitet und geprägt." },
    { key: "anlage_text", value: "Die Sportanlage Grüner Wald in Schattdorf bietet dem FC Schattdorf ein erstklassiges Zuhause für Training und Wettkampf. Die Anlage verfügt über mehrere Rasenplätze und moderne Infrastruktur." },
    { key: "junioren_intro", value: "Die Juniorenabteilung des FC Schattdorf ist das Herzstück unseres Vereins. Von der Fussballschule für die Kleinsten bis zu den A-Junioren begleiten wir die Nachwuchsspieler auf ihrem Weg." },
    { key: "schiedsrichter_text", value: "Der FC Schattdorf beteiligt sich aktiv an der Schiedsrichter-Ausbildung. Interessierte können sich beim Verein melden, um eine Schiedsrichter-Karriere zu starten." },
    { key: "mitglied_werden_text", value: "Du möchtest Teil des FC Schattdorf werden? Egal ob als Spieler, Spielerin oder als passives Mitglied – du bist herzlich willkommen. Interessierte Aktive wenden sich an den Sportchef, Junioren an den Juniorenobmann oder die Kinderfussballverantwortliche." },
    { key: "kontakt_zusatz", value: "Bei allgemeinen Anfragen erreichst du uns telefonisch oder per Facebook. Für spezifische Anliegen wende dich direkt an die zuständige Person im Verein." },
    { key: "fussballschule_text", value: "Die Fussballschule des FC Schattdorf richtet sich an Kinder ab dem Vorschulalter. In einer spielerischen Umgebung lernen die Kleinsten die ersten Schritte mit dem Ball." },
    { key: "trainingslager_text", value: "Jährlich organisiert der FC Schattdorf Trainingslager für verschiedene Teams. Diese Lager stärken den Zusammenhalt und fördern die sportliche Weiterentwicklung." },
    { key: "goalietraining_text", value: "Der FC Schattdorf bietet spezifisches Goalietraining für Torhüter aller Altersklassen an. Interessierte wenden sich an den Verein." },
    { key: "rekrutierung_text", value: "Wir freuen uns immer über neue Talente! Interessierte Nachwuchsspieler können jederzeit ein Schnuppertraining absolvieren. Melde dich beim Juniorenobmann." },
    // Match-Widget Homepage
    { key: "last_match_date", value: "13.06.2026" },
    { key: "last_match_home_team", value: "FC Rothenburg" },
    { key: "last_match_away_team", value: "FC Schattdorf" },
    { key: "last_match_score", value: "2 : 3" },
    { key: "last_match_report_url", value: "https://matchcenter.ifv.ch" },
  ];

  for (const c of contents) {
    await db
      .insert(schema.siteContent)
      .values(c)
      .onConflictDoNothing();
  }

  console.log("✅ Seeding complete!");
}

seed().catch((err) => {
  console.error("❌ Seed failed:", err);
  process.exit(1);
});
