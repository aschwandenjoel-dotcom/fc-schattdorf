import Link from "next/link";

const navItems = [
  { href: "/admin", label: "Dashboard" },
  { href: "/admin/news", label: "News" },
  { href: "/admin/teams", label: "Teams" },
  { href: "/admin/inhalte", label: "Seiten-Inhalte" },
];

export default function AdminSidebar() {
  return (
    <aside className="w-56 min-h-screen bg-primary text-white flex flex-col">
      <div className="p-5 text-lg font-bold border-b border-blue-700">
        FC Schattdorf
        <span className="block text-xs font-normal text-blue-300">Admin</span>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className="block px-3 py-2 rounded-lg text-sm hover:bg-blue-700 transition"
          >
            {item.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
