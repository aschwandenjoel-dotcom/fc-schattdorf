import { db } from "@/lib/db";
import { sponsors } from "@/lib/schema";
import { asc } from "drizzle-orm";

export default async function SponsorBar() {
  const allSponsors = await db
    .select()
    .from(sponsors)
    .orderBy(asc(sponsors.sortOrder));

  if (allSponsors.length === 0) return null;

  return (
    <section className="py-12 bg-white border-t border-gray-100">
      <div className="max-w-7xl mx-auto px-4">
        <p className="text-center text-xs font-semibold uppercase tracking-widest text-gray-400 mb-8">
          Unsere Sponsoren
        </p>
        <div className="flex flex-wrap items-center justify-center gap-6 md:gap-10">
          {allSponsors.map((sponsor) =>
            sponsor.logoUrl ? (
              <a
                key={sponsor.id}
                href={sponsor.website ?? "#"}
                target="_blank"
                rel="noopener noreferrer"
                title={sponsor.name}
                className="grayscale hover:grayscale-0 opacity-60 hover:opacity-100 transition-all duration-200"
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={sponsor.logoUrl}
                  alt={sponsor.name}
                  className="h-10 object-contain max-w-[120px]"
                />
              </a>
            ) : (
              <a
                key={sponsor.id}
                href={sponsor.website ?? "#"}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm font-semibold text-gray-400 hover:text-primary transition-colors"
              >
                {sponsor.name}
              </a>
            )
          )}
        </div>
      </div>
    </section>
  );
}
