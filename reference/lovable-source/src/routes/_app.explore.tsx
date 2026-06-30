import { createFileRoute } from "@tanstack/react-router";
import { Download, MapPin } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/explore")({
  head: () => ({ meta: [{ title: "Explore destinations · TripMind" }] }),
  component: ExploreScreen,
});

const packs = [
  { code: "TH", name: "Thailand", tag: "Available now", gradient: "gradient-sunset", size: "84 MB" },
  { code: "JP", name: "Japan", tag: "Coming soon", gradient: "gradient-ocean", size: "—" },
  { code: "SG", name: "Singapore", tag: "Coming soon", gradient: "gradient-sunset", size: "—" },
  { code: "AE", name: "Dubai", tag: "Coming soon", gradient: "gradient-ocean", size: "—" },
];

function ExploreScreen() {
  return (
    <Screen>
      <ScreenHeader title="Explore" subtitle="Destination packs" large />
      <Section title="Offline destination packs">
        <div className="grid grid-cols-2 gap-3">
          {packs.map((p) => (
            <div
              key={p.code}
              className="overflow-hidden rounded-3xl border border-border bg-card shadow-soft"
            >
              <div className={`relative h-28 ${p.gradient}`}>
                <span className="absolute left-3 top-3 rounded-full bg-white/85 px-2 py-0.5 text-[10px] font-medium">
                  {p.tag}
                </span>
              </div>
              <div className="p-3">
                <p className="font-display text-base font-semibold">{p.name}</p>
                <p className="flex items-center gap-1 text-[11px] text-muted-foreground">
                  <MapPin className="h-3 w-3" /> {p.size}
                </p>
                <button
                  className="mt-2 inline-flex w-full items-center justify-center gap-1 rounded-full bg-secondary px-3 py-1.5 text-[11px] font-medium disabled:opacity-50"
                  disabled={p.tag !== "Available now"}
                >
                  <Download className="h-3 w-3" /> Download
                </button>
              </div>
            </div>
          ))}
        </div>
      </Section>
    </Screen>
  );
}
