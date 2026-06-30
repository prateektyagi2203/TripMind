import { createFileRoute, Link, Outlet, useParams, useRouterState } from "@tanstack/react-router";
import { ChevronLeft, Share2 } from "lucide-react";
import { getTrip, formatDateRange, daysUntil } from "@/lib/mock-data";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/_app/trip/$tripId")({
  component: TripLayout,
});

const tabs: ReadonlyArray<{ to: string; label: string; exact?: boolean }> = [
  { to: "/trip/$tripId", label: "Overview", exact: true },
  { to: "/trip/$tripId/itinerary", label: "Itinerary" },
  { to: "/trip/$tripId/flights", label: "Flights" },
  { to: "/trip/$tripId/hotels", label: "Hotels" },
  { to: "/trip/$tripId/expenses", label: "Expenses" },
  { to: "/trip/$tripId/memories", label: "Memories" },
  { to: "/trip/$tripId/family", label: "Family" },
];

function TripLayout() {
  const { tripId } = useParams({ from: "/_app/trip/$tripId" });
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const trip = getTrip(tripId);

  if (!trip) {
    return (
      <div className="p-6 pt-12 text-center">
        <h1 className="font-display text-2xl">Trip not found</h1>
        <Link to="/" className="mt-4 inline-block text-sm text-ocean underline">
          Back to trips
        </Link>
      </div>
    );
  }

  const days = daysUntil(trip.startDate);

  return (
    <div className="pb-28">
      <div className={cn("relative h-56 w-full", trip.coverGradient)}>
        <div className="absolute inset-0 bg-gradient-to-t from-black/55 to-black/10" />
        <div className="absolute inset-x-0 top-0 flex items-center justify-between px-4 pt-5">
          <Link
            to="/"
            className="grid h-9 w-9 place-items-center rounded-full bg-white/90 text-foreground"
            aria-label="Back"
          >
            <ChevronLeft className="h-5 w-5" />
          </Link>
          <button
            className="grid h-9 w-9 place-items-center rounded-full bg-white/90 text-foreground"
            aria-label="Share trip"
          >
            <Share2 className="h-4 w-4" />
          </button>
        </div>
        <div className="absolute bottom-4 left-5 right-5 text-white">
          <p className="text-[11px] uppercase tracking-[0.18em] opacity-85">
            {trip.destination}
          </p>
          <h1 className="font-display text-3xl font-semibold leading-tight">
            {trip.title}
          </h1>
          <p className="mt-1 text-xs opacity-90">
            {formatDateRange(trip.startDate, trip.endDate)}
            {days > 0 ? ` · ${days} days to go` : ""}
          </p>
        </div>
      </div>

      <nav className="sticky top-0 z-30 surface-glass border-b border-border/60">
        <div className="scrollbar-none flex gap-1 overflow-x-auto px-3 py-2">
          {tabs.map((tab) => {
            const target = tab.to.replace("$tripId", tripId);
            const active = tab.exact ? pathname === target : pathname.startsWith(target);
            return (
              <Link
                key={tab.to}
                to={tab.to}
                params={{ tripId }}
                activeOptions={{ exact: tab.exact }}
                className={cn(
                  "shrink-0 rounded-full px-3.5 py-1.5 text-xs font-medium transition-colors",
                  active
                    ? "bg-primary text-primary-foreground"
                    : "bg-secondary text-secondary-foreground",
                )}
              >
                {tab.label}
              </Link>
            );
          })}
        </div>
      </nav>

      <Outlet />
    </div>
  );
}
