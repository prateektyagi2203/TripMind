import { createFileRoute } from "@tanstack/react-router";
import { Phone, ShieldAlert, Hospital, Landmark } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/tools/safety")({
  component: SafetyScreen,
});

function SafetyScreen() {
  return (
    <Screen>
      <ScreenHeader title="Safety" back="/tools" />
      <div className="px-5 pt-4">
        <button className="grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-3xl bg-destructive p-4 text-destructive-foreground shadow-soft">
          <span className="grid h-11 w-11 place-items-center rounded-2xl bg-white/20">
            <ShieldAlert className="h-5 w-5" />
          </span>
          <div className="min-w-0 text-left">
            <p className="font-display text-base font-semibold">Emergency SOS</p>
            <p className="text-xs opacity-90">Hold for 3 seconds to alert family</p>
          </div>
          <Phone className="h-4 w-4" />
        </button>
      </div>
      <Section title="Nearby help">
        <div className="space-y-2">
          {[
            { name: "Bangkok Hospital", dist: "1.2 km", icon: Hospital },
            { name: "Indian Embassy", dist: "4.5 km", icon: Landmark },
            { name: "Tourist Police", dist: "0.8 km", icon: ShieldAlert },
          ].map((s) => (
            <div
              key={s.name}
              className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-2xl border border-border bg-card p-4 shadow-soft"
            >
              <span className="grid h-9 w-9 place-items-center rounded-xl bg-secondary text-ocean">
                <s.icon className="h-4 w-4" />
              </span>
              <div className="min-w-0">
                <p className="truncate text-sm font-medium">{s.name}</p>
                <p className="text-[11px] text-muted-foreground">{s.dist}</p>
              </div>
              <button className="rounded-full bg-secondary px-3 py-1.5 text-[11px] font-medium">
                Directions
              </button>
            </div>
          ))}
        </div>
      </Section>
    </Screen>
  );
}
