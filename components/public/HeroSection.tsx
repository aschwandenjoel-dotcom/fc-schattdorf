import Button from "@/components/ui/Button";

export default function HeroSection() {
  return (
    <section className="relative bg-primary overflow-hidden">
      {/* Background pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0"
          style={{
            backgroundImage: `repeating-linear-gradient(
              45deg,
              transparent,
              transparent 40px,
              rgba(255,255,255,0.3) 40px,
              rgba(255,255,255,0.3) 41px
            )`,
          }}
        />
      </div>

      <div className="relative max-w-7xl mx-auto px-4 py-24 md:py-36">
        <div className="max-w-2xl">
          <p className="text-blue-200 text-sm font-semibold uppercase tracking-widest mb-4">
            Fussballclub Schattdorf UR · Seit 1933
          </p>
          <h1 className="text-4xl md:text-6xl font-extrabold text-white leading-tight tracking-tight">
            SEIT 1933 FÜR UNSERE{" "}
            <span className="text-blue-200">ZUKUNFT</span> AM BALL
          </h1>
          <p className="mt-6 text-lg text-blue-100 leading-relaxed max-w-xl">
            Willkommen beim FC Schattdorf – rund 600 Mitglieder, 21 Teams und
            eine leidenschaftliche Gemeinschaft im Herzen von Uri.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Button href="/verein/mitglied-werden" size="lg" variant="secondary">
              Mitglied werden
            </Button>
            <Button
              href="https://matchcenter.ifv.ch"
              external
              size="lg"
              variant="outline"
              className="border-white text-white hover:bg-white hover:text-primary"
            >
              Spielresultate →
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
}
