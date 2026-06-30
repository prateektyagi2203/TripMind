import { createFileRoute } from "@tanstack/react-router";
import { CloudRain, Sun } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/tools/weather")({
  component: WeatherScreen,
});

const week = [
  { day: "Mon", icon: Sun, hi: 33, lo: 26 },
  { day: "Tue", icon: CloudRain, hi: 30, lo: 25 },
  { day: "Wed", icon: Sun, hi: 32, lo: 26 },
  { day: "Thu", icon: CloudRain, hi: 29, lo: 25 },
  { day: "Fri", icon: Sun, hi: 33, lo: 27 },
];

function WeatherScreen() {
  return (
    <Screen>
      <ScreenHeader title="Weather" back="/tools" />
      <div className="mx-5 mt-4 rounded-3xl gradient-ocean p-5 text-white shadow-soft">
        <p className="text-xs uppercase tracking-[0.16em] opacity-80">Bangkok</p>
        <p className="mt-1 font-display text-6xl font-semibold">31°</p>
        <p className="text-sm opacity-90">Humid · scattered showers</p>
      </div>
      <Section title="5-day forecast">
        <div className="rounded-3xl border border-border bg-card shadow-soft">
          {week.map((w, i) => (
            <div
              key={w.day}
              className={`grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 px-4 py-3 ${
                i !== 0 ? "border-t border-border/60" : ""
              }`}
            >
              <span className="w-10 text-sm font-medium">{w.day}</span>
              <w.icon className="h-4 w-4 text-ocean" />
              <span className="text-sm">
                {w.hi}° / <span className="text-muted-foreground">{w.lo}°</span>
              </span>
            </div>
          ))}
        </div>
      </Section>
    </Screen>
  );
}
