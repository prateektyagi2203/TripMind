import { createFileRoute } from "@tanstack/react-router";
import { MapPin, Navigation } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/tools/cabhub")({
  component: CabHubScreen,
});

const options = [
  { app: "Grab", eta: "3 min", price: "฿180", color: "bg-emerald-500" },
  { app: "Bolt", eta: "5 min", price: "฿165", color: "bg-blue-500" },
  { app: "inDrive", eta: "7 min", price: "฿150", color: "bg-amber-500" },
];

function CabHubScreen() {
  return (
    <Screen>
      <ScreenHeader title="CabHub" back="/tools" />
      <div className="px-5 pt-4">
        <div className="space-y-2 rounded-3xl border border-border bg-card p-4 shadow-soft">
          <div className="flex items-center gap-2 rounded-2xl bg-secondary px-3 py-2.5">
            <MapPin className="h-4 w-4 text-ocean" />
            <span className="text-sm">Riva Arun Bangkok</span>
          </div>
          <div className="flex items-center gap-2 rounded-2xl bg-secondary px-3 py-2.5">
            <Navigation className="h-4 w-4 text-sunset" />
            <span className="text-sm">Chatuchak Weekend Market</span>
          </div>
        </div>
      </div>
      <Section title="Compare rides">
        <div className="space-y-3">
          {options.map((o) => (
            <div
              key={o.app}
              className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-2xl border border-border bg-card p-4 shadow-soft"
            >
              <span
                className={`grid h-10 w-10 place-items-center rounded-2xl text-sm font-semibold text-white ${o.color}`}
              >
                {o.app[0]}
              </span>
              <div className="min-w-0">
                <p className="text-sm font-medium">{o.app}</p>
                <p className="text-xs text-muted-foreground">{o.eta} away</p>
              </div>
              <div className="text-right">
                <p className="font-display text-lg font-semibold">{o.price}</p>
                <button className="text-[11px] font-medium text-ocean">Open app →</button>
              </div>
            </div>
          ))}
        </div>
      </Section>
    </Screen>
  );
}
