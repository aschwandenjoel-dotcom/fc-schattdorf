"use client";
import { useEffect, useRef } from "react";

const STICKY_VH = 55;

export default function ParallaxImageSection() {
  const outerRef = useRef<HTMLDivElement>(null);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    const update = () => {
      const outer = outerRef.current;
      const img = imgRef.current;
      if (!outer || !img) return;

      const { top, height } = outer.getBoundingClientRect();
      const vp = window.innerHeight;
      const stickyPx = vp * (STICKY_VH / 100);

      // Progress 0 = section enters from below, 1 = sticky phase ends
      const totalRange = vp + (height - stickyPx);
      const progress = Math.max(0, Math.min(1, (vp - top) / totalRange));

      img.style.objectPosition = `center ${progress * 100}%`;
    };

    window.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update, { passive: true });
    update();
    return () => {
      window.removeEventListener("scroll", update);
      window.removeEventListener("resize", update);
    };
  }, []);

  return (
    <div ref={outerRef} style={{ position: "relative", height: "160vh" }}>
      <div style={{ position: "sticky", top: 0, zIndex: 0, height: `${STICKY_VH}vh` }}>
        <div style={{ position: "absolute", inset: 0, overflow: "hidden" }}>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            ref={imgRef}
            src="/images/fcschattdorf_junioren1.jpg"
            alt="FC Schattdorf – Seit 1933 für unsere Zukunft am Ball"
            style={{
              width: "100%",
              height: "100%",
              objectFit: "cover",
              objectPosition: "center 0%",
              display: "block",
            }}
          />
          <div style={{
            position: "absolute", inset: 0,
            background: "linear-gradient(to top, rgba(0,0,0,0.55) 0%, rgba(0,0,0,0.08) 50%, transparent 100%)",
          }} />
          <div style={{ position: "absolute", bottom: "2.5rem", left: "3rem" }}>
            <p style={{ color: "white", fontSize: "1.125rem", fontWeight: 400, letterSpacing: "0.1em", margin: "0 0 0.375rem", textTransform: "uppercase" }}>
              FC Schattdorf
            </p>
            <h2 style={{ color: "white", fontSize: "clamp(2rem, 4vw, 3.5rem)", fontWeight: 900, textTransform: "uppercase", margin: 0, lineHeight: 1.1, letterSpacing: "-0.02em" }}>
              Seit 1933 für unsere Zukunft<br />am Ball
            </h2>
          </div>
        </div>
      </div>
    </div>
  );
}
