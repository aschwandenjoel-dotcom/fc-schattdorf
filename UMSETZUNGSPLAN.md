# FC Schattdorf – Detaillierter Umsetzungsplan

*Stand: 24. Juni 2026 · Basis: bestehende Website [www.fcschattdorf.ch](https://www.fcschattdorf.ch) + Kunden-Briefing*

---

## 1. Getroffene Entscheidungen (verbindlich)

| Thema | Entscheidung |
|-------|--------------|
| **Umfang v1** | Vollständige 1:1-Kopie aller bestehenden Seiten |
| **Spielresultate / Tabellen** | Nur Verlinkung zum IFV-Matchcenter (kein eigener Datenimport) |
| **Launch-Termin** | Kein fixer Termin – Qualität vor Tempo |
| **Zusatzfeatures v1** | Newsletter, Helferportal, Events/Termine, Sponsoren-Detailseite |
| **Shop** | Produkt-Schaufenster (CMS-gepflegt, Bestellung per Formular/E-Mail) |
| **Newsletter** | Externer Dienst (Mailchimp / Brevo) – Formular eingebettet |
| **Domain** | Vorerst keine – komplett lokal entwickeln & testen |
| **Inhalte** | Bestehende Texte **und** Bilder 1:1 von der alten Seite übernehmen |
| **Admin-Zugang** | Ein gemeinsamer Login (wie aktuell in `.env.local`) |

---

## 2. Technologie-Stack (final)

| Bereich | Technologie | Status |
|---------|-------------|--------|
| Framework | Next.js 16 (App Router) + TypeScript | ✅ eingerichtet |
| Styling | Tailwind CSS | ✅ eingerichtet |
| Datenbank | PostgreSQL via Neon | ✅ verbunden |
| ORM | Drizzle ORM | ✅ eingerichtet |
| Auth (Admin) | NextAuth.js – Credentials (1 Login) | ✅ eingerichtet |
| Bildupload | Vercel Blob | ⏳ Token nach Deployment |
| Newsletter | Mailchimp/Brevo (Embed) | ⏳ Konto nötig |
| Deployment | Vercel | ⏳ später (erst lokal) |
| Karten | Google Maps Embed (statisch, kein API-Key) | ⏳ |

---

## 3. Vollständige Sitemap (1:1 der aktuellen Seite)

```
/                              Startseite / News-Übersicht
/news/[slug]                   Einzelner News-Artikel

VEREIN
/verein                        Vereinsportrait
/verein/vorstand               Vorstand / Ansprechpersonen
/verein/mitglied-werden        Mitglied werden
/verein/shop                   Shop (Produkt-Schaufenster)
/verein/anlage                 Sportanlage "Grüner Wald"
/verein/schiedsrichter         Schiedsrichter / Ausbildung
/verein/ehrenmitglieder        Ehrenmitglieder
/verein/geschichte             Vereinsgeschichte (seit 1933)
/verein/anfahrt                Anfahrt / Lageplan
/verein/vorfall-melden         Vorfall-Meldeformular

HELFER
/helfereinsaetze               Helferportal (Schichten + Anmeldung)

AKTIVE
/aktive                        Übersicht Aktive
/aktive/1-mannschaft           1. Mannschaft
/aktive/2-mannschaft           2. Mannschaft
/aktive/3-mannschaft           3. Mannschaft
/aktive/frauen-uri-1           Frauen Uri I
/aktive/frauen-uri-2           Frauen Uri II
/aktive/senioren-uri-1         Senioren Uri I

JUNIOREN
/junioren                      Übersicht / Einleitung
/junioren/geschichte           Geschichte Juniorenabteilung
/junioren/organisation         Organisation
/junioren/teams/[slug]         18 Juniorenteams (A bis Ff)
/junioren/trainerwesen         Trainerwesen
/junioren/goalietraining       Goalietraining
/junioren/fussballschule       Fussballschule
/junioren/trainingslager       Trainingslager
/junioren/rekrutierung         Rekrutierung / Schnuppertraining

EVENTS
/events                        Veranstaltungsübersicht
/events/dorfturnier            Dorf-/Plauschturnier

SPONSOREN
/sponsoren                     Sponsoren-Detailseite
/sponsoren/top-club-88         Top-Club 88

KONTAKT
/kontakt                       Kontakt + Karte + Formular

ADMIN  (login-geschützt, /admin/*)
/admin                         Dashboard
/admin/login                   Login
/admin/news                    News verwalten
/admin/teams                   Teams verwalten
/admin/vorstand                Vorstand/Personen
/admin/sponsoren               Sponsoren
/admin/shop                    Shop-Produkte
/admin/events                  Events
/admin/helfereinsaetze         Helferschichten + Anmeldungen
/admin/seiten                  Statische Seiten-Texte (site_content)
```

**Total öffentliche Seiten:** ~45 (inkl. dynamischer Team-/News-Detailseiten)

---

## 4. Feature-Liste (detailliert)

### 4.1 Öffentliche Website
- **Responsive Layout** (Mobile-First), Navbar mit Dropdowns (Verein, Aktive, Junioren, Events, Sponsoren), Hamburger-Menü mobil
- **Startseite:** Hero mit Motto „SEIT 1933 FÜR UNSERE ZUKUNFT AM BALL", News-Grid (neueste Beiträge), Schnellnavigation, Sponsorenleiste, Newsletter-Block, Hinweis nächstes Event (z.B. GV 21.08.2026)
- **News:** Übersicht mit Pagination + Einzelartikel (Bild, Titel, Datum, Text)
- **Teams:** Übersichtskarten + Detailseiten (Foto, Beschreibung, Trainer/Kontakt, Liga, IFV-Matchcenter-Link)
- **Match-Info:** Buttons zu matchcenter.ifv.ch (Resultate/Tabelle/Spielplan) – keine eigene Datenhaltung
- **Sponsoren:** Kategorisiert (Hauptsponsor, Co-Sponsoren, Junioren-Patron, Top-Club 88) mit Logo + Website-Link
- **Shop:** Produkt-Schaufenster (Bild, Name, Beschreibung, Preis) + „Bestellen"-Button (E-Mail/Formular)
- **Events:** Liste kommender/vergangener Termine
- **Newsletter:** eingebettetes Anmeldeformular (externer Dienst)
- **Helferportal:** Liste offener Schichten pro Spieltag, Anmeldung per Formular (Name + E-Mail, ohne eigenen Account)
- **Vorfall melden:** Meldeformular → speichert in DB + E-Mail an Verein
- **Kontakt:** Adresse, Telefon, Facebook, IFV-Link, Google-Maps-Karte, Kontaktformular
- **SEO:** Metadaten pro Seite, Sitemap, OpenGraph, `lang="de"`

### 4.2 Admin-CMS
- Login-geschützt (NextAuth, ein gemeinsamer Zugang)
- **News-Editor:** anlegen/bearbeiten/löschen, Bild-Upload, veröffentlichen/Entwurf
- **Teams-Verwaltung:** alle Mannschaften, Trainer/Kontakt, Foto, Reihenfolge
- **Personen:** Vorstand & Ansprechpersonen
- **Sponsoren:** Logo-Upload, Kategorie, Link, Reihenfolge
- **Shop:** Produkte verwalten
- **Events:** Termine verwalten
- **Helferschichten:** Schichten erstellen, Anmeldungen einsehen/exportieren
- **Seiten-Texte:** alle statischen Texte (Geschichte, Schiedsrichter, Anlage etc.) über `site_content` editierbar
- **Bild-Upload überall:** Vorschau, sofort live
- **Bedienung ohne technisches Wissen** (klare Formulare, Hilfetexte)

---

## 5. Datenbankschema (Erweiterung)

Bereits vorhanden: `news`, `teams`, `site_content`. Zu ergänzen:

```
news              id, slug, title, content, image_url, published, created_at, updated_at
teams             id, slug, name, category(enum), liga, description, image_url,
                  trainer_name, trainer_contact, matchcenter_url, sort_order
people            id, name, role, category(vorstand|trainer|ansprechperson),
                  email, phone, image_url, sort_order
sponsors          id, name, category(haupt|co|junioren_patron|top_club_88),
                  logo_url, website, sort_order
shop_products     id, name, description, image_url, price, available, sort_order
events            id, title, description, event_date, location, image_url
helper_shifts     id, event_title, date, role, slots_total, slots_taken, notes
helper_signups    id, shift_id(fk), name, email, created_at
incident_reports  id, name, email, message, status, created_at
site_content      key, value, updated_at   (generische Seitentexte, key-basiert)
```

`site_content`-Schlüssel z.B.: `home_hero_text`, `geschichte_body`, `anlage_body`, `schiedsrichter_body`, `fussballschule_body` … → so werden alle „statischen" Seiten CMS-editierbar.

---

## 6. Content-Migration (1:1 Übernahme)

1. **Inventarisierung:** Alle Seiten von www.fcschattdorf.ch erfassen (Texte + Bild-URLs)
2. **Texte:** in `site_content` / `news` / Team-Beschreibungen übertragen
3. **Bilder:** von der alten Seite herunterladen → nach Vercel Blob hochladen → URLs in DB
4. **Strukturierte Daten:** Teams, Sponsoren, Vorstand, Events als DB-Einträge anlegen
5. **Kontrolle:** Seite-für-Seite-Abgleich alt ↔ neu

> Hinweis: Solange lokal entwickelt wird, können Bilder vorübergehend in `/public` liegen; Umzug auf Vercel Blob beim Deployment.

---

## 7. Design- & Layout-Prinzipien

- **Gleiche Inhalte, luftigeres Layout:** mehr Weissraum, klarere Hierarchie, keine Überladung
- **Farben:** Primär Dunkelblau `#003399`, Weiss, Hellgrau-Hintergründe, Anthrazit-Text
- **Abstände:** Sections `py-16 md:py-24`, Container `max-w-6xl mx-auto px-4`, Cards `p-6 md:p-8`
- **Typografie:** grosse, gut lesbare Schrift (Inter/System-UI), Hero `text-4xl md:text-6xl`
- **Konsistente Komponenten:** Card, Button, Section-Header, Badge wiederverwendbar
- **Barrierearm:** Kontraste, Alt-Texte, Tastatur-Navigation

---

## 8. Umsetzungsphasen & Aufwand

*Ohne fixes Datum – Reihenfolge & grobe Aufwandsschätzung (Personentage).*

| Phase | Inhalt | Aufwand |
|-------|--------|---------|
| **P0 – Setup** ✅ | Next.js, Tailwind, Neon, Auth, Schema-Basis | erledigt |
| **P1 – Fundament** | Vollständiges DB-Schema, Layouts (public/admin), Navbar+Footer, Design-System (Button/Card/Section), Seed-Daten | 2–3 T |
| **P2 – Admin-CMS** | Alle CRUD-Bereiche (News, Teams, Personen, Sponsoren, Shop, Events, Helfer, Seiten-Texte), Bild-Upload | 4–6 T |
| **P3 – Öffentliche Kernseiten** | Start/News, Verein-Portrait, Aktive + Teamdetails, Junioren + Teamdetails, Kontakt | 4–5 T |
| **P4 – Restliche Seiten** | Vorstand, Anlage, Schiedsrichter, Ehrenmitglieder, Geschichte, Anfahrt, Vorfall-Formular, alle Junioren-Unterseiten | 3–4 T |
| **P5 – Zusatzfeatures** | Sponsoren-Detailseite, Shop-Schaufenster, Events, Helferportal (Schichten+Anmeldung), Newsletter-Embed | 3–4 T |
| **P6 – Content-Migration** | Texte & Bilder 1:1 übernehmen, befüllen, Abgleich | 2–3 T |
| **P7 – Feinschliff & Test** | Responsiveness, SEO, Performance, Korrekturlesen, Bugfixing | 2–3 T |
| **P8 – Deployment** | Vercel-Projekt, Blob, Env-Vars, ggf. Domain später | 1 T |

**Grobtotal:** ca. **21–29 Personentage** für die vollständige 1:1-Umsetzung.

---

## 9. Offene Punkte / noch zu liefern (vom Kunden)

- [ ] **Bildmaterial** in guter Auflösung (oder Freigabe, Bilder von alter Seite zu übernehmen)
- [ ] **Logo** des FC Schattdorf als Vektor/PNG (für Navbar/Favicon)
- [ ] **Vereinsfarben** final bestätigen (Annahme: Dunkelblau/Weiss)
- [ ] **Newsletter-Dienst** wählen + Konto (Mailchimp/Brevo) → Embed-Code
- [ ] **Shop-Produkte** + „Bestellung läuft wie?" (E-Mail-Adresse / Formularziel)
- [ ] **Vorstand / Ansprechpersonen:** Namen, Rollen, Kontakte (Sportchef, Juniorenobmann …)
- [ ] **Vorfall-Meldung:** Ziel-E-Mail-Adresse
- [ ] **Helferportal:** welche Spieltage/Schichten, Bestätigt „ohne Helfer-Login" okay?

---

## 10. Launch-Checkliste (Definition of Done)

- [ ] Alle 45 öffentlichen Seiten vorhanden & befüllt
- [ ] Admin kann jeden Inhalt ohne Code ändern → sofort live
- [ ] Mobile + Desktop sauber
- [ ] Alle Bilder über Vercel Blob, optimiert
- [ ] SEO: Titel, Beschreibungen, Sitemap, OG-Tags
- [ ] Newsletter-Anmeldung funktioniert
- [ ] Helfer-Anmeldung speichert & ist im Admin sichtbar
- [ ] Kontakt-/Vorfall-Formulare versenden korrekt
- [ ] Keine Sicherheits-Warnungen, Auth schützt `/admin`
- [ ] Auf Vercel deployed (Domain-Umzug separat)
```
