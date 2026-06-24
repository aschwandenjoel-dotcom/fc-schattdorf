type Color = "blue" | "green" | "gray" | "red" | "yellow";

interface BadgeProps {
  label: string;
  color?: Color;
}

const colorClasses: Record<Color, string> = {
  blue: "bg-blue-50 text-blue-700 ring-blue-100",
  green: "bg-green-50 text-green-700 ring-green-100",
  gray: "bg-gray-50 text-gray-600 ring-gray-100",
  red: "bg-red-50 text-red-700 ring-red-100",
  yellow: "bg-yellow-50 text-yellow-700 ring-yellow-100",
};

export default function Badge({ label, color = "blue" }: BadgeProps) {
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ring-inset ${colorClasses[color]}`}
    >
      {label}
    </span>
  );
}
