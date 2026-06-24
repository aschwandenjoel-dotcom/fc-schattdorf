interface SectionHeaderProps {
  title: string;
  subtitle?: string;
  center?: boolean;
}

export default function SectionHeader({
  title,
  subtitle,
  center = false,
}: SectionHeaderProps) {
  return (
    <div className={center ? "text-center" : ""}>
      <h2 className="text-3xl font-bold text-gray-900 tracking-tight">{title}</h2>
      {subtitle && (
        <p className="mt-3 text-lg text-gray-500 max-w-2xl">{subtitle}</p>
      )}
      <div
        className={`mt-4 h-1 w-12 rounded-full bg-primary ${center ? "mx-auto" : ""}`}
      />
    </div>
  );
}
