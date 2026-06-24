import Link from "next/link";

export default function MatchResultBox() {
  return (
    <div className="bg-white border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4 bg-gray-50 rounded-xl p-5 border border-gray-200">
          {/* Match Info */}
          <div className="flex items-center gap-6">
            <div className="text-center">
              <p className="text-xs text-gray-400 mb-1">13.06.2026</p>
              <div className="flex items-center gap-4">
                <div className="text-center">
                  <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center text-xs font-bold text-gray-500 mx-auto">FCR</div>
                  <p className="text-xs text-gray-600 mt-1">FC Rothenburg</p>
                </div>
                <div className="text-center">
                  <p className="text-2xl font-extrabold text-gray-900 tracking-tight">2 : 3</p>
                  <p className="text-xs text-primary font-semibold">Sieg ✓</p>
                </div>
                <div className="text-center">
                  <div className="w-10 h-10 bg-primary rounded-full flex items-center justify-center text-xs font-bold text-white mx-auto">FCS</div>
                  <p className="text-xs text-gray-600 mt-1">FC Schattdorf</p>
                </div>
              </div>
            </div>
          </div>

          {/* Links */}
          <div className="flex flex-wrap gap-2">
            <a
              href="https://matchcenter.ifv.ch"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs font-medium text-primary hover:underline border border-primary/30 rounded-lg px-3 py-1.5 hover:bg-primary/5 transition"
            >
              Matchbericht
            </a>
            <a
              href="https://matchcenter.ifv.ch"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs font-medium text-primary hover:underline border border-primary/30 rounded-lg px-3 py-1.5 hover:bg-primary/5 transition"
            >
              Tabelle
            </a>
            <a
              href="https://matchcenter.ifv.ch"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs font-medium text-primary hover:underline border border-primary/30 rounded-lg px-3 py-1.5 hover:bg-primary/5 transition"
            >
              Spielplan
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
