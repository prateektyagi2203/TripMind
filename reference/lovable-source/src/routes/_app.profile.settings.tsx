import { createFileRoute } from "@tanstack/react-router";
import { Screen, ScreenHeader } from "@/components/screen";
import { ChevronRight } from "lucide-react";

export const Route = createFileRoute("/_app/profile/settings")({
  component: SettingsScreen,
});

const groups = [
  {
    title: "App",
    items: ["Appearance", "Language & region", "Units & currency"],
  },
  {
    title: "Privacy",
    items: ["Data & sync", "Permissions", "Export data"],
  },
  {
    title: "Support",
    items: ["Help center", "Contact us", "About TripMind"],
  },
];

function SettingsScreen() {
  return (
    <Screen>
      <ScreenHeader title="Settings" back="/profile" />
      <div className="space-y-5 px-5 pt-4">
        {groups.map((g) => (
          <div key={g.title}>
            <p className="mb-2 text-[11px] uppercase tracking-[0.16em] text-muted-foreground">
              {g.title}
            </p>
            <div className="rounded-3xl border border-border bg-card shadow-soft">
              {g.items.map((label, i) => (
                <button
                  key={label}
                  className={`grid w-full grid-cols-[minmax(0,1fr)_auto] items-center gap-3 px-4 py-3 text-left ${
                    i !== 0 ? "border-t border-border/60" : ""
                  }`}
                >
                  <span className="truncate text-sm font-medium">{label}</span>
                  <ChevronRight className="h-4 w-4 text-muted-foreground" />
                </button>
              ))}
            </div>
          </div>
        ))}
      </div>
    </Screen>
  );
}
