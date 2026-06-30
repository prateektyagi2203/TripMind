import { createFileRoute, Link } from "@tanstack/react-router";
import { Bell, ChevronRight, CreditCard, Globe2, LogOut, Settings, Users } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/profile")({
  component: ProfileScreen,
});

const rows = [
  { to: "/profile/preferences", label: "Travel preferences", icon: Globe2 },
  { to: "/profile/family", label: "Family & sharing", icon: Users },
  { to: "/profile/billing", label: "Subscription", icon: CreditCard },
  { to: "/notifications", label: "Notifications", icon: Bell },
  { to: "/profile/settings", label: "Settings", icon: Settings },
] as const;

function ProfileScreen() {
  return (
    <Screen>
      <ScreenHeader title="Profile" large />
      <div className="px-5">
        <div className="flex items-center gap-4 rounded-3xl border border-border bg-card p-4 shadow-soft">
          <span className="grid h-14 w-14 place-items-center rounded-full gradient-sunset font-display text-lg font-semibold text-white">
            YO
          </span>
          <div className="min-w-0">
            <p className="truncate font-display text-lg font-semibold">Your Name</p>
            <p className="truncate text-xs text-muted-foreground">
              Travel DNA: Explorer · Foodie · Family-first
            </p>
          </div>
        </div>
      </div>

      <Section title="Account">
        <div className="rounded-3xl border border-border bg-card shadow-soft">
          {rows.map((r, i) => (
            <Link
              key={r.to}
              to={r.to}
              className={`grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 px-4 py-3 ${
                i !== 0 ? "border-t border-border/60" : ""
              }`}
            >
              <span className="grid h-9 w-9 place-items-center rounded-xl bg-secondary text-ocean">
                <r.icon className="h-4 w-4" />
              </span>
              <p className="truncate text-sm font-medium">{r.label}</p>
              <ChevronRight className="h-4 w-4 text-muted-foreground" />
            </Link>
          ))}
        </div>
      </Section>

      <div className="px-5 pt-2">
        <Link
          to="/auth"
          className="grid w-full grid-cols-[auto_minmax(0,1fr)] items-center gap-3 rounded-3xl border border-border bg-card px-4 py-3 text-destructive shadow-soft"
        >
          <LogOut className="h-4 w-4" />
          <span className="text-sm font-medium">Sign out</span>
        </Link>
      </div>
    </Screen>
  );
}
