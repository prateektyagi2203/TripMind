import { createFileRoute, Link, useParams } from "@tanstack/react-router";
import {
  CalendarRange,
  Car,
  CloudSun,
  CreditCard,
  Hotel,
  Languages,
  MapPin,
  Plane,
  Sparkles,
  Wallet,
} from "lucide-react";
import { Section } from "@/components/screen";
import { getTrip } from "@/lib/mock-data";

export const Route = createFileRoute("/_app/trip/$tripId/")({
  component: TripOverview,
});

const quickActions = [
  { to: "/trip/$tripId/itinerary", label: "Itinerary", icon: CalendarRange },
  { to: "/trip/$tripId/flights", label: "Flights", icon: Plane },
  { to: "/trip/$tripId/hotels", label: "Hotels", icon: Hotel },
  { to: "/tools/cabhub", label: "CabHub", icon: Car },
  { to: "/tools/translator", label: "Translate", icon: Languages },
  { to: "/trip/$tripId/expenses", label: "Expenses", icon: Wallet },
] as const;

function TripOverview() {
  const { tripId } = useParams({ from: "/_app/trip/$tripId/" });
  const trip = getTrip(tripId)!;
  const pct = Math.round((trip.budget.spent / trip.budget.total) * 100);

  return (
    <div className="pb-6">
      <Section title="Quick actions">
        <div className="grid grid-cols-3 gap-3">
          {quickActions.map(({ to, label, icon: Icon }) => (
            <Link
              key={to}
              to={to}
              params={{ tripId }}
              className="flex flex-col items-center gap-2 rounded-2xl border border-border bg-card p-3 text-center shadow-soft"
            >
              <span className="grid h-10 w-10 place-items-center rounded-xl bg-secondary text-ocean">
                <Icon className="h-4 w-4" />
              </span>
              <span className="text-xs font-medium">{label}</span>
            </Link>
          ))}
        </div>
      </Section>

      <Section title="Trip pulse">
        <div className="space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-2xl border border-border bg-card p-4 shadow-soft">
              <div className="flex items-center gap-2 text-xs text-muted-foreground">
                <CloudSun className="h-3.5 w-3.5" /> Weather
              </div>
              <p className="mt-2 font-display text-2xl font-semibold">31°</p>
              <p className="text-xs text-muted-foreground">Humid, scattered showers</p>
            </div>
            <div className="rounded-2xl border border-border bg-card p-4 shadow-soft">
              <div className="flex items-center gap-2 text-xs text-muted-foreground">
                <MapPin className="h-3.5 w-3.5" /> Local time
              </div>
              <p className="mt-2 font-display text-2xl font-semibold">14:42</p>
              <p className="text-xs text-muted-foreground">Asia/Bangkok</p>
            </div>
          </div>

          <div className="rounded-2xl border border-border bg-card p-4 shadow-soft">
            <div className="flex items-center justify-between text-xs text-muted-foreground">
              <span className="flex items-center gap-2">
                <CreditCard className="h-3.5 w-3.5" /> Budget
              </span>
              <span>
                {trip.budget.currency} {trip.budget.spent.toLocaleString()} /{" "}
                {trip.budget.total.toLocaleString()}
              </span>
            </div>
            <div className="mt-3 h-2 overflow-hidden rounded-full bg-secondary">
              <div
                className="h-full rounded-full gradient-sunset"
                style={{ width: `${Math.min(100, pct)}%` }}
              />
            </div>
            <p className="mt-2 text-xs text-muted-foreground">{pct}% spent so far</p>
          </div>
        </div>
      </Section>

      <Section title="Smart suggestion">
        <div className="rounded-3xl border border-border bg-card p-4 shadow-soft">
          <div className="grid grid-cols-[auto_minmax(0,1fr)] items-start gap-3">
            <span className="grid h-9 w-9 shrink-0 place-items-center rounded-2xl gradient-sunset text-white">
              <Sparkles className="h-4 w-4" />
            </span>
            <div className="min-w-0">
              <p className="text-sm font-medium">
                Add a half-day cooking class in Bangkok?
              </p>
              <p className="mt-1 text-xs text-muted-foreground">
                Based on your family's love of street food and a free Wednesday
                morning in your itinerary.
              </p>
              <div className="mt-3 flex gap-2">
                <button className="rounded-full bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground">
                  Add to plan
                </button>
                <button className="rounded-full bg-secondary px-3 py-1.5 text-xs font-medium">
                  Maybe later
                </button>
              </div>
            </div>
          </div>
        </div>
      </Section>
    </div>
  );
}
