# FC Schattdorf – Projekt-Instruktionen

## Projektziel
Homepage + Admin-CMS für den FC Schattdorf (Fussballclub, Schattdorf UR, Schweiz).

## Kunden-Briefing
Alle Details zum Kunden: siehe [CLIENT_BRIEF.md](./CLIENT_BRIEF.md)

## Technologie-Stack
- **Framework:** Next.js (App Router) – lies `node_modules/next/dist/docs/` vor dem Coden
- **Styling:** Tailwind CSS
- **Datenbank:** PostgreSQL via Neon
- **Bildupload:** Vercel Blob oder Cloudinary
- **Auth:** NextAuth.js (nur für Admin-Bereich)
- **Deployment:** Vercel

## Architektur-Überblick

```
/app
  /(public)          – Öffentliche Homepage (SSR/SSG)
  /admin             – Login-geschützter CMS-Bereich
/components
  /public            – Homepage-Komponenten
  /admin             – Admin-UI-Komponenten
/lib
  /db.ts             – Datenbank-Verbindung
  /auth.ts           – Auth-Konfiguration
```

## Kernfunktionen

1. **Öffentliche Website:** Alle Inhalte kommen aus der Datenbank (dynamisch)
2. **Admin-Panel:** Texte & Bilder bearbeiten → sofort live auf der Homepage
3. **Kein technisches Wissen nötig** für die Redakteure

## Vereinsfarben (zu definieren)
- Primärfarbe: (aus Logo/Trikot ermitteln)
- Sekundärfarbe: (aus Logo/Trikot ermitteln)
