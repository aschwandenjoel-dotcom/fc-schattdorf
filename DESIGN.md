---
name: FC Schattdorf
description: Vereins-Website des FC Schattdorf — taktiles, selbstbewusstes Sport-Design in den echten Vereinsfarben
colors:
  primary: "#e63124"
  primary-deep: "#d9261c"
  ink: "#181818"
  ink-soft: "#1f2937"
  neutral-bg: "#f5f5f5"
  neutral-white: "#ffffff"
  neutral-muted: "#6b7280"
typography:
  display:
    fontFamily: "Inter, 'Helvetica Neue', Arial, sans-serif"
    fontSize: "clamp(1.4rem, 3vw, 2.4rem)"
    fontWeight: 900
    lineHeight: 1.1
    letterSpacing: "0.05em"
  headline:
    fontFamily: "Inter, 'Helvetica Neue', Arial, sans-serif"
    fontSize: "1.125rem"
    fontWeight: 800
    lineHeight: 1.3
    letterSpacing: "0.02em"
  label:
    fontFamily: "Inter, 'Helvetica Neue', Arial, sans-serif"
    fontSize: "0.6875rem"
    fontWeight: 700
    letterSpacing: "0.1em"
  body:
    fontFamily: "Inter, 'Helvetica Neue', Arial, sans-serif"
    fontSize: "0.9rem"
    fontWeight: 400
    lineHeight: 1.6
rounded:
  sm: "0px"
  md: "8px"
spacing:
  sm: "0.75rem"
  md: "1.5rem"
  lg: "2.5rem"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.neutral-white}"
    rounded: "{rounded.sm}"
    padding: "0.75rem 1.5rem"
  button-primary-hover:
    backgroundColor: "{colors.primary-deep}"
  badge-date:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.neutral-white}"
    padding: "0.375rem 0.75rem"
  badge-category:
    backgroundColor: "{colors.ink-soft}"
    textColor: "{colors.neutral-white}"
    padding: "0.375rem 0.75rem"
---

# Design System: FC Schattdorf

## 1. Overview

**Creative North Star: "Der Spielfeldrand"**

Der Blick von der Seitenlinie: fokussiert, aufmerksam, immer in Bewegung, nie überladen.
Das System trägt die echte Vereinsidentität — Logo, Rot/Schwarz/Weiss — aber mit der
Präzision eines gut geführten Clubs statt der losen Optik einer Dorfvereinsseite. Jede
Komponente ist taktil und selbstbewusst: klare Kanten, kräftige Kontraste, spürbares
Feedback bei Interaktion. Bewegung (AOS-Fades, Hover-States) verstärkt diese Aufmerksamkeit,
ohne zu choreografieren.

Dieses System lehnt ab: generische "Bootstrap-Sportverein"-Optik, beliebige Card-Raster ohne
Hierarchie, jede Abweichung von der echten Logo-Farbwelt. Inhalte (Texte, Bilder, Links,
PDFs) sind nicht Teil dieses Redesigns — nur ihre Form.

**Key Characteristics:**
- Rot (`#e63124`) ist die einzige Akzentfarbe — sparsam, aber unverkennbar
- Schwarz/Anthrazit trägt Struktur (Header, Footer, Badges), nicht Dekoration
- Inter in Versalien + Letter-Spacing für Navigation/Labels, ruhiger Fliesstext darunter
- Flach bei Ruhe, Bewegung als Antwort auf Zustand (Hover, Scroll-Eintritt via AOS)

## 2. Colors

Eine Zwei-Farben-Welt aus dem echten Vereinslogo (`fcs-logo.svg`), ergänzt um neutrale
Anthrazit-/Grau-/Weisstöne für Struktur und Lesbarkeit.

### Primary
- **FCS Rot** (`#e63124`): Haupt-Akzent — Buttons, Datums-Badges, aktive Navigationspunkte,
  Header-Akzentlinie. Direkt aus dem Logo extrahiert, nicht frei gewählt.
- **FCS Rot Tief** (`#d9261c`): Hover-/Active-Zustand von Rot-Elementen, ebenfalls aus dem
  Logo (zweiter Rotton der Vektorgrafik).

### Neutral
- **Spielfeld-Anthrazit** (`#181818`): Inner-Header-Leiste, dunkle Flächen.
- **Tiefes Graphit** (`#1f2937`): Kategorie-Badges, sekundäre dunkle Flächen.
- **Nebel-Grau** (`#6b7280`): Fliesstext/Excerpt auf hellem Grund — **muss gegen Weiss
  ≥4.5:1 Kontrast halten**, bei Zweifel dunkler ziehen statt heller.
- **Vereinsweiss** (`#ffffff`): Textfarbe auf dunklen Flächen, Kartenhintergrund.
- **Trainingsplatz-Hellgrau** (`#f5f5f5`): Helle Sektionshintergründe.

### Named Rules
**The One-Red Rule.** Es gibt genau eine Akzentfarbe: `#e63124`. Keine zweite "sichere"
Ersatzfarbe, keine Verwässerung. Wo aktuell drei verschiedene Rottöne im CSS existieren
(`#c8102e`, `#9b0c23`, `#E30613` als Altlasten/Platzhalter), werden sie auf `#e63124` /
`#d9261c` konsolidiert.

**The Red-Field Rule.** Rot darf ganze Flächen tragen (Agenda-Band der Startseite,
Tabelle/Spielplan-Band der Teamseiten, Claim-Band als Verlaufs-Tint) – aber **niemals als
Grund für kleinen Text**: Weiss auf `#e63124` erreicht nur 4.35:1. Auf roter Fläche gilt:
Headlines in Weiss (Grossschrift, ≥3:1 reicht), alles Kleinteilige sitzt auf weissen
Karten/Kacheln mit Ink-Text.

**The Solid-Red Rule.** Jede *gefüllte* rote Fläche mit weisser Beschriftung – Knöpfe,
Tags, aktive Seitenzahlen, Termin-/IFV-Bänder – nimmt `#d9261c` (`--fcx-red-solid`,
4.95:1), gedrückt `#c8201a` (`--fcx-red-press`, 5.71:1). Das helle `#e63124` bleibt der
Marke vorbehalten: Markierungslinien, Unterstriche, Icons, grosse Flächen ohne Kleintext.

## 3. Typography

**Display/Body Font:** Inter (400–900), Fallback `'Helvetica Neue', Arial, sans-serif`

**Character:** Eine einzige Schriftfamilie über alle Gewichte — von 400 (Fliesstext) bis 900
(Headlines) — hält das System diszipliniert. Versalien + weite Letter-Spacing markieren
Navigation und Labels als funktional, nicht als Schmuck.

### Hierarchy
- **Display** (900, `clamp(1.4rem, 3vw, 2.4rem)`, 1.1): Seiten-Hero-Headlines (z.B. Helfereinsätze-Hero).
- **Headline** (800, 1.125rem, 1.3): News-Karten-Titel, Sektionstitel. Versalien, 0.02em Tracking.
- **Title** (700, 1rem, 1.4): Karten-/Box-Überschriften innerhalb von Sektionen.
- **Label** (700, 0.6875rem, Versalien, 0.1em Tracking): Sub-Navigation, Tags, Badges.
- **Body** (400, 0.9rem, 1.6): Excerpts, Fliesstext. Max. 65–75ch Zeilenlänge.

### Named Rules
**The Single-Family Rule.** Nur Inter, nie eine zweite Schriftfamilie. Unterscheidung
ausschliesslich über Gewicht, Grösse, Versalien/Tracking.

## 3.a Wärme (Nutzer-Feedback nach Phase 1)

Rückmeldung nach der ersten Umsetzung: die Seiten wirkten "kalt und unherzlich", trotz
korrekter Markenfarben. Ursache war nicht Farbe, sondern **Materialität** — durchgängig
scharfe Kanten + kühles Grau + Schatten nur bei Hover liest sich wie ein Enterprise-Dashboard,
nicht wie ein Fussballverein. Präzisierung, kein Widerspruch zu Abschnitt 4/5:

- **Interaktive Chrome bleibt scharf** (Buttons, Badges, Navigation, Pills) — das ist die
  "taktile, selbstbewusste" Seite der Marke, unverändert `rounded.sm` (0px).
- **Inhalts-/Bildflächen dürfen warm sein**: Fotos, Personen-/Infokarten, Zeitleisten-Karten
  nutzen `rounded.md` (8px, siehe Frontmatter — bisher definiert, aber ungenutzt). Eine
  Person auf einem Foto in einer scharfkantigen Box wirkt wie ein Aktenordner; mit leichter
  Rundung wirkt dieselbe Box einladend, ohne dass die Marke ihre Kanten verliert.
- **Neutralgrau wird zu Vereinsgrau**: reines Kühlgrau (`#f4f4f5`, `#f5f6f8`) bekommt einen
  minimalen Rotstich (`oklch`-Tinting Richtung `#e63124`-Hue, siehe `--fcx-mist`) statt eines
  neutralen Technik-Grautons — derselbe Trick wie ein warmes Vereinsheim-Licht statt
  Neonröhre, ohne dass es dem Auge auffällt.
- **Rot darf mehr Fläche tragen** als nur Label-Text: Akzent-Balken, Hover-Zustände und
  CTA-Rahmen (siehe Top-Club-88 CTA) statt Rot nur als 12px-Overline zu behandeln.
- **Spürbares Feedback bei Berührung**: interaktive Karten/Links bekommen einen leichten
  `scale(0.98)`-Press-Effekt zusätzlich zum Hover-Schatten (siehe emil-design-eng-Skill) —
  das macht die Seite lebendig statt statisch, ohne die Flat-By-Default-Regel zu verletzen
  (der Press-Effekt ist zustandsgebunden, kein Ruhezustand-Schmuck).

## 4. Elevation

Flach in Ruhe. Tiefe entsteht nur als Reaktion auf Zustand: ein Flyout-Untermenü bekommt
einen weichen Schlagschatten beim Öffnen, Hero-/Teaser-Bilder bekommen einen Verlaufs-Scrim
für Textlesbarkeit — beides zweckgebunden, nie dekorativ.

### Shadow Vocabulary
- **Flyout-Schatten** (`box-shadow: 2px 2px 8px rgba(0,0,0,0.4)`): Untermenüs der dritten
  Navigationsebene beim Aufklappen.
- **Bild-Scrim** (`linear-gradient(to top, rgba(0,0,0,.7) 0%, transparent 100%)`): Über
  Hero-/Teaser-Bildern, damit weisser Text darüber lesbar bleibt.

### Named Rules
**The Flat-By-Default Rule.** Karten und Flächen sind im Ruhezustand schattenlos. Schatten
erscheinen nur bei Interaktion (Hover, geöffnetes Menü) oder zur Textlesbarkeit über Bildern.

## 5. Components

### Buttons
- **Shape:** scharfe Kanten, kein Radius (0px) — passt zum taktilen, selbstbewussten Charakter.
- **Primary:** Hintergrund `#e63124`, Text Weiss, Padding `0.75rem 1.5rem`.
- **Hover/Focus:** Hintergrund wechselt zu `#d9261c`, keine Transform-Animation — Farbwechsel
  reicht für spürbares Feedback.

### Badges (Datum / Kategorie)
- **Datums-Badge:** Hintergrund `#e63124`, Text Weiss, über das Kartenbild gezogen.
- **Kategorie-Badge:** Hintergrund `#1f2937`, Text Weiss, neben dem Datums-Badge.
- **Charakter:** Beide overlay-artig auf dem Kartenbild platziert (negative Margin), nicht
  als Teil des Textblocks — markiert sie als Meta-Information, nicht als Inhalt.

### Cards (News-Grid)
- **Corner Style:** kein Radius.
- **Background:** Weiss, Bild full-bleed oben.
- **Shadow Strategy:** keiner im Ruhezustand (siehe Elevation).
- **Title:** Versalien, 800, wird bei Hover Rot (`#e63124`).

### Navigation (Inner Header + Sub-Nav)
- **Hauptleiste:** 96px hohe Anthrazit-Leiste (`#181818`), Logo links, zentrierter Versal-Titel,
  läuft mit der Seite mit (nicht fixed).
- **Sub-Nav:** 44px, dunkler (`#111`), horizontal scrollbar, Labels in Versalien/0.1em Tracking,
  aktiver Punkt in `#e63124`.
- **Mobile:** horizontales Scrollen statt Umbruch, kein Hamburger nötig solange Platz reicht.

### Sponsoren-Grid
- **Style:** Logos standardmässig graustufig (`filter: grayscale(100%)`, 80% Opazität),
  bei Hover volle Farbe — macht die Sponsoren-Hierarchie ruhig, ohne sie zu verstecken.

## 6. Do's and Don'ts

### Do:
- **Do** ausschliesslich `#e63124` / `#d9261c` als Akzentrot verwenden — direkt aus dem
  Vereinslogo, nicht neu interpretiert.
- **Do** Inter in allen Gewichten (400–900) als einzige Schriftfamilie nutzen.
- **Do** Schatten nur zustandsgebunden einsetzen (Hover, geöffnetes Menü, Bild-Scrim).
- **Do** alle Texte, Bilder, PDFs, Sponsorenlogos und Links unverändert übernehmen — nur
  Layout/Spacing/Typografie-Einsatz/Motion ändern.
- **Do** alle 50 bestehenden Seiten (Vorstand, Fanshop, Sponsoren, Startseite, alle
  Aktiv-/Juniorenteams etc.) nach dem Umbau weiterhin erreichbar halten.

### Don't:
- **Don't** eine andere Primärfarbe (z.B. Blau) einführen, um Verwechslungsgefahr zu lösen —
  das wurde explizit verworfen; die Logo-Farben sind verbindlich.
- **Don't** die drei aktuell im CSS verstreuten Rot-Platzhalter (`#c8102e`, `#9b0c23`,
  `#E30613`) weiterführen — auf `#e63124`/`#d9261c` konsolidieren.
- **Don't** generische Card-Raster ohne Hierarchie oder Stock-Foto-Hero-Slider verwenden.
- **Don't** Gradient-Text, Glassmorphismus-Standardeinsatz oder Seiten-Akzentstreifen
  (`border-left`/`border-right` als Farbakzent) einsetzen.
- **Don't** Texte, Bildpfade, PDF-Dateien, Sponsorenlogos oder externe Links (Google Maps,
  Instagram, ifv.ch, Tickaroo) verändern, umbenennen oder entfernen.
