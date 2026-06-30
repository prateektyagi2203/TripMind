import { createFileRoute } from "@tanstack/react-router";
import { Bell, CloudRain, Plane, Wallet } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/notifications")({
  component: NotificationsScreen,
});

const items = [
  { icon: Plane, title: "Flight TG 316 on time", time: "2h ago", desc: "Boarding gate updates will appear here." },
  { icon: CloudRain, title: "Showers expected in Bangkok", time: "5h ago", desc: "Pack a light raincoat for Day 2." },
  { icon: Wallet, title: "Priya added an expense", time: "Yesterday", desc: "Airport taxi · ฿1,100" },
];

function NotificationsScreen() {
  return (
    <Screen>
      <ScreenHeader title="Notifications" back="/" right={<Bell className="h-4 w-4" />} />
      <Section title="Today">
        <div className="space-y-2">
          {items.map((n) => (
            <div
              key={n.title}
              className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-start gap-3 rounded-2xl border border-border bg-card p-4 shadow-soft"
            >
              <span className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-secondary text-ocean">
                <n.icon className="h-4 w-4" />
              </span>
              <div className="min-w-0">
                <p className="truncate text-sm font-medium">{n.title}</p>
                <p className="text-xs text-muted-foreground">{n.desc}</p>
              </div>
              <span className="shrink-0 text-[11px] text-muted-foreground">
                {n.time}
              </span>
            </div>
          ))}
        </div>
      </Section>
    </Screen>
  );
}
