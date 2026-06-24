import Link from "next/link";

const links = [
  {
    href: "/aktive",
    icon: "⚽",
    label: "Aktive Teams",
    desc: "1., 2. & 3. Mannschaft",
  },
  {
    href: "/junioren",
    icon: "🌱",
    label: "Junioren",
    desc: "A- bis F-Junioren",
  },
  {
    href: "/helfereinsaetze",
    icon: "🤝",
    label: "Helfer gesucht",
    desc: "Jetzt für Spieltage anmelden",
  },
  {
    href: "/verein/mitglied-werden",
    icon: "🏆",
    label: "Mitglied werden",
    desc: "Teil des FC Schattdorf",
  },
  {
    href: "/events",
    icon: "📅",
    label: "Events",
    desc: "Turniere & Veranstaltungen",
  },
  {
    href: "/sponsoren",
    icon: "🤝",
    label: "Sponsoren",
    desc: "Unsere Partner",
  },
];

export default function QuickLinks() {
  return (
    <section className="py-16 md:py-20 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4">
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
          {links.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="flex flex-col items-center text-center gap-2 p-5 bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md hover:border-primary/20 hover:-translate-y-0.5 transition-all duration-200 group"
            >
              <span className="text-3xl">{item.icon}</span>
              <span className="text-sm font-bold text-gray-800 group-hover:text-primary transition-colors">
                {item.label}
              </span>
              <span className="text-xs text-gray-400">{item.desc}</span>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
