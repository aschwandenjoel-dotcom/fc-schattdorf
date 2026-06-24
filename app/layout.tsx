import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "FC Schattdorf",
  description: "Offizielle Website des FC Schattdorf – Fussballclub aus Schattdorf UR, Schweiz",
  openGraph: {
    siteName: "FC Schattdorf",
    locale: "de_CH",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="de">
      <body>{children}</body>
    </html>
  );
}
