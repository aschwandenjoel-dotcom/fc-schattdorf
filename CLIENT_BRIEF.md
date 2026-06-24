# FC Schattdorf – Kunden-Briefing

## Projektübersicht

**Kunde:** FC Schattdorf  
**Projekttyp:** Homepage + Content-Management-Applikation  
**Ziel:** Neue öffentliche Homepage mit integriertem Admin-Bereich zum Bearbeiten von Texten und Bildern direkt über ein Web-Interface.

---

## Über den Verein

**Name:** FC Schattdorf  
**Gegründet:** 9. September 1933  
**Motto:** *„SEIT 1933 FÜR UNSERE ZUKUNFT AM BALL"*  
**Mitglieder:** ca. 600  
**Anzahl Teams:** 21  
**Kanton:** Uri, Schweiz

### Adresse
```
FC Schattdorf  
Dorfstrasse 100  
6467 Schattdorf UR  
Schweiz
```

### Kontakt
- **Telefon:** 041 870 75 65  
- **Website:** [www.fcschattdorf.ch](https://www.fcschattdorf.ch)  
- **Facebook:** [fcschattdorf.ch](https://www.facebook.com/fcschattdorf.ch/)

---

## Teams & Mannschaften

### Aktive Herren
| Team | Liga |
|------|------|
| 1. Mannschaft | – |
| 2. Mannschaft | – |
| 3. Mannschaft | – |

**Trainer 2. Mannschaft:**
- Mathias Lussmann – +41 79 265 01 68
- Roger Zurfluh – rzurfluh@bosshard.com / 079 372 64 26

### Frauen
- Frauen Uri I
- Frauen Uri II

### Senioren
- Senioren Uri I

### Junioren (Nachwuchs)
Umfangreiches Juniorenprogramm mit Teams von **A-Junioren bis F-Junioren** (mehrere Abteilungen pro Kategorie)

---

## Sponsoren

| Kategorie | Sponsor |
|-----------|---------|
| Hauptsponsor | Muöser |
| Junioren-Patron | Gamma Holding |
| Co-Sponsor | Herger Küchen |
| Co-Sponsor | Brand Automobile |
| Co-Sponsor | Imholz Sport |
| 2. Mannschaft | Porr |
| 2. Mannschaft | Zurich Versicherung |
| 2. Mannschaft | Albert Burch |
| 2. Mannschaft | Christen Automobile |
| 2. Mannschaft | Arnold Coag |

---

## Aktivitäten & Angebote

- Fussballschule für Kinder
- Trainingslager
- Goalietraining
- Schiedsrichter-Ausbildungsprogramm
- Helferportal für Spieltage (Freiwillige)
- Newsletter
- Jährliche Generalversammlung (2026: 21. August 2026)

---

## Mitgliedschaft

- Interessierte melden sich beim **Sportchef** (für Aktive)
- Junioren melden sich beim **Juniorenobmann** oder der **Kinderfussballverantwortlichen**
- Keine öffentlichen Mitgliederbeiträge auf der Website publiziert

---

## Stadion / Sportanlage

**Name:** Grüner Wald  
**Standort:** Schattdorf UR  

---

## Verbandsstruktur

**Verband:** Innerschweizerischer Fussballverband (IFV)  
**Verein-ID:** 329  
**Liga-Informationen:** [matchcenter.ifv.ch](https://matchcenter.ifv.ch)

---

## Bestehende Website – Seitenstruktur

Basierend auf der aktuellen Seite [www.fcschattdorf.ch](https://www.fcschattdorf.ch):

```
/                        – Startseite / News
/verein                  – Vereinsinfo
/verein/mitglied-werden  – Mitglied werden
/kontakt                 – Kontakt
/aktive/                 – Aktive Mannschaften
/aktive/2-mannschaft     – 2. Mannschaft
/junioren/               – Juniorenabteilung
/junioren/teams/...      – Einzelne Juniorenteams
```

---

## Projektanforderungen

### Öffentliche Homepage
- Startseite mit News / Aktuellem
- Vereinsportrait
- Mannschaftsübersicht (Aktive, Junioren, Frauen, Senioren)
- Sponsoren-Seite
- Kontakt / Anfahrt
- Dynamische Inhalte (Texte + Bilder via Admin-Bereich verwaltbar)

### Admin-Applikation (CMS)
- Login-geschützter Bereich
- **Text-Felder:** Texte für alle Seiten direkt bearbeiten und speichern
- **Bild-Felder:** Bilder hochladen/ersetzen, Vorschau, sofort live auf der Website
- Änderungen werden **sofort** auf der öffentlichen Homepage sichtbar
- Einfache, intuitive Bedienung (kein technisches Wissen nötig)

---

## Technologie-Stack (Empfehlung)

| Bereich | Technologie |
|---------|-------------|
| Frontend | Next.js (App Router) |
| Styling | Tailwind CSS |
| CMS/Admin | Eigene Admin-UI |
| Datenbank | PostgreSQL (z.B. Neon) |
| Bildupload | Cloudinary oder Vercel Blob |
| Deployment | Vercel |
| Auth (Admin) | NextAuth.js |

---

## Nächste Schritte

- [ ] Design-Konzept / Wireframes erstellen
- [ ] Farben & Branding des FC Schattdorf definieren (primär: vereinsfarben)
- [ ] Datenbankschema für CMS-Inhalte entwerfen
- [ ] Next.js Projekt initialisieren
- [ ] Admin-Panel aufbauen
- [ ] Homepage-Seiten implementieren
- [ ] Deployment auf Vercel

---

*Erstellt: 24. Juni 2026*
