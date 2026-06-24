import Link from "next/link";

interface NewsListItemProps {
  slug: string;
  title: string;
  createdAt?: string | null;
  imageUrl?: string | null;
  teamTag?: string;
}

function formatDate(date?: string | null): string {
  if (!date) return "";
  return new Intl.DateTimeFormat("de-CH", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  }).format(new Date(date));
}

export default function NewsListItem({ slug, title, createdAt, imageUrl, teamTag }: NewsListItemProps) {
  return (
    <Link
      href={`/news/${slug}`}
      className="group flex items-start gap-4 py-4 border-b border-gray-100 last:border-0 hover:bg-gray-50 -mx-4 px-4 rounded-lg transition-colors"
    >
      {/* Thumbnail */}
      <div className="shrink-0 w-16 h-16 rounded-lg bg-gray-100 overflow-hidden">
        {imageUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={imageUrl} alt={title} className="w-full h-full object-cover" />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-primary/10">
            <span className="text-sm font-bold text-primary/30">FCS</span>
          </div>
        )}
      </div>

      {/* Text */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1">
          {createdAt && (
            <span className="text-xs text-gray-400">{formatDate(createdAt)}</span>
          )}
          {teamTag && (
            <span className="text-xs font-semibold text-primary bg-primary/10 rounded px-1.5 py-0.5">
              {teamTag}
            </span>
          )}
        </div>
        <p className="text-sm font-semibold text-gray-800 group-hover:text-primary transition-colors line-clamp-2">
          {title}
        </p>
      </div>

      <svg className="shrink-0 w-4 h-4 text-gray-300 group-hover:text-primary mt-1 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
      </svg>
    </Link>
  );
}
