import { createFileRoute, Link } from "@tanstack/react-router";
import { Camera, Car, Languages, Receipt, ShieldCheck, CloudSun, ArrowRight, Landmark, Compass } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/tools")({
  component: ToolsHub,
});

const tools = [
  { to: "/tools/cabhub", label: "CabHub", desc: "Compare Grab, Bolt, inDrive", icon: Car, tint: "bg-amber-500/15 text-amber-700" },
  { to: "/tools/nearby", label: "Nearby Places", desc: "Beaches, malls, parks, zoos", icon: Compass, tint: "bg-teal-500/15 text-teal-700" },
  { to: "/tools/atms", label: "Nearby ATMs", desc: "Cash points with travel time", icon: Landmark, tint: "bg-indigo-500/15 text-indigo-700" },
  { to: "/tools/translator", label: "Translator", desc: "Camera, voice, text", icon: Languages, tint: "bg-emerald-500/15 text-emerald-700" },
  { to: "/tools/camera", label: "Camera AI", desc: "Recognize, scan receipts", icon: Camera, tint: "bg-rose-500/15 text-rose-700" },
  { to: "/tools/safety", label: "Safety", desc: "Hospitals, embassy, SOS", icon: ShieldCheck, tint: "bg-blue-500/15 text-blue-700" },
  { to: "/tools/weather", label: "Weather", desc: "Local forecast", icon: CloudSun, tint: "bg-sky-500/15 text-sky-700" },
  { to: "/tools/receipts", label: "Receipts", desc: "Scan and log", icon: Receipt, tint: "bg-purple-500/15 text-purple-700" },
] as const;

function ToolsHub() {
  return (
    <Screen>
      <ScreenHeader title="Tools" subtitle="Everything for the road" large />
      <Section title="Your travel toolkit">
        <div className="space-y-3">
          {tools.map(({ to, label, desc, icon: Icon, tint }) => (
            <Link
              key={to}
              to={to}
              className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-3xl border border-border bg-card p-4 shadow-soft"
            >
              <span className={`grid h-11 w-11 place-items-center rounded-2xl ${tint}`}>
                <Icon className="h-5 w-5" />
              </span>
              <div className="min-w-0">
                <p className="font-display text-base font-semibold">{label}</p>
                <p className="truncate text-xs text-muted-foreground">{desc}</p>
              </div>
              <ArrowRight className="h-4 w-4 text-muted-foreground" />
            </Link>
          ))}
        </div>
      </Section>
    </Screen>
  );
}
