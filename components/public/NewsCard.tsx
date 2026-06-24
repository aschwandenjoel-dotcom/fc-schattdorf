import Link from "next/link";
import Image from "next/image";

interface NewsCardProps {
  slug: string;
  title: string;
  content: string;
  imageUrl?: string | null;
  createdAt?: Date | null;
}

function formatDate(date?: Date | null): string {
  if (!date) return "";
  return new Intl.DateTimeFormat("de-CH", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(new Date(date));
}

function truncate(text: string, max: number) {
  const plain = text.replace(/<[^>]+>/g, "");
  return plain.length > max ? plain.slice(0, max) + "…" : plain;
}

export default function NewsCard({ slug, title, content, imageUrl, createdAt }: NewsCardProps) {
  return (
    <Link
      href={`/news/${slug}`}
      className="group flex flex-col bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all duration-200 overflow-hidden"
    >
      <div className="relative h-48 bg-gray-100 overflow-hidden">
        {imageUrl ? (
          <Image
            src={imageUrl}
            alt={title}
            fill
            className="object-cover group-hover:scale-105 transition-transform duration-300"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center bg-primary/10">
            <span className="text-4xl font-extrabold text-primary/20">FCS</span>
          </div>
        )}
      </div>
      <div className="flex flex-col flex-1 p-6">
        {createdAt && (
          <p className="text-xs text-gray-400 mb-2">{formatDate(createdAt)}</p>
        )}
        <h3 className="text-base font-bold text-gray-900 group-hover:text-primary transition-colors line-clamp-2 mb-2">
          {title}
        </h3>
        <p className="text-sm text-gray-500 line-clamp-3 flex-1">
          {truncate(content, 160)}
        </p>
        <span className="mt-4 text-sm font-medium text-primary group-hover:underline">
          Weiterlesen →
        </span>
      </div>
    </Link>
  );
}
