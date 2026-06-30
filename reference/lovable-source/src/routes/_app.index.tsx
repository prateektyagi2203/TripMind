import { createFileRoute, Link } from "@tanstack/react-router";
import { Bell, Plus, Sparkles } from "lucide-react";
import { Screen, Section } from "@/components/screen";
import { LocationBanner } from "@/components/location-banner";
import { TripCard } from "@/components/trip-card";
import { trips } from "@/lib/mock-data";

export const Route = createFileRoute("/_app/")({
  head: () => ({
    meta: [
      { title: "TripMind — Your trips" },
      { name: "description", content: "All your trips, plans, and travel memories in one place." },
    ],
  }),
  component: TripsHome,
});

function TripsHome() {
  const upcoming = trips.filter((t) => t.status !== "completed");
  const past = trips.filter((t) => t.status === "completed");

  return (
    <Screen>
      <header className="px-5 pb-2 pt-6">
        <div className="grid grid-cols-[minmax(0,1fr)_auto_auto] items-center gap-3">
          <div className="min-w-0">
            <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">
              Welcome back
            </p>
            <h1 className="truncate font-display text-3xl font-semibold tracking-tight">
              Where to next?
            </h1>
          </div>
          <Link
            to="/notifications"
            className="grid h-10 w-10 shrink-0 place-items-center rounded-full bg-card text-foreground shadow-soft"
            aria-label="Notifications"
          >
            <Bell className="h-4 w-4" />
          </Link>
          <Link
            to="/trip/new"
            className="grid h-10 w-10 shrink-0 place-items-center rounded-full bg-sunset text-sunset-foreground shadow-soft"
            aria-label="New trip"
          >
            <Plus className="h-4 w-4" />
          </Link>
        </div>
      </header>

      <section className="px-5 pt-4">
        <LocationBanner />
      </section>

      <section className="px-5 pt-3">
        <Link
          to="/concierge"
          className="block overflow-hidden rounded-3xl border border-border bg-card p-4 shadow-soft"
        >
          <div className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3">
            <span className="grid h-10 w-10 place-items-center rounded-2xl gradient-sunset text-white">
              <Sparkles className="h-4 w-4" />
            </span>
            <div className="min-w-0">
              <p className="text-sm font-medium">Ask your AI concierge</p>
              <p className="truncate text-xs text-muted-foreground">
                Plan a day, find restaurants, translate menus.
              </p>
            </div>
            <span className="rounded-full bg-secondary px-3 py-1.5 text-[11px] font-medium">
              Try
            </span>
          </div>
        </Link>
      </section>

      <Section title="Your trips">
        <div className="space-y-4">
          {upcoming.map((trip) => (
            <TripCard key={trip.id} trip={trip} />
          ))}
        </div>
      </Section>

      {past.length > 0 && (
        <Section title="Travel memories">
          <div className="space-y-4">
            {past.map((trip) => (
              <TripCard key={trip.id} trip={trip} />
            ))}
          </div>
        </Section>
      )}
    </Screen>
  );
}
