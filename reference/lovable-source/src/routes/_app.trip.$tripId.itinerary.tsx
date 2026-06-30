import { useMemo, useState } from "react";
import { createFileRoute, useParams } from "@tanstack/react-router";
import { Plane, Hotel, Utensils, Car, MapPin, Plus, ChevronRight } from "lucide-react";
import { Section } from "@/components/screen";
import { TransportSheet } from "@/components/transport-sheet";
import {
  itinerary,
  getTrip,
  getCurrentTripDay,
  type ItineraryItem,
  type GeoPoint,
} from "@/lib/mock-data";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/_app/trip/$tripId/itinerary")({
  component: ItineraryScreen,
});

const iconFor: Record<ItineraryItem["type"], typeof Plane> = {
  flight: Plane,
  hotel: Hotel,
  meal: Utensils,
  transport: Car,
  activity: MapPin,
};

function ItineraryScreen() {
  const { tripId } = useParams({ from: "/_app/trip/$tripId/itinerary" });
  const trip = getTrip(tripId);
  const days = useMemo(() => Array.from(new Set(itinerary.map((i) => i.day))), []);
  const currentDay = trip ? getCurrentTripDay(trip) : null;
  // Default to current day if active, otherwise day 1 (upcoming preview).
  const activeDay = currentDay ?? 1;

  const [selected, setSelected] = useState<ItineraryItem | null>(null);

  // For the selected item, the previous stop's coords act as a fallback
  // origin (useful when permission/GPS hasn't resolved yet).
  const fallbackOrigin: GeoPoint | undefined = useMemo(() => {
    if (!selected) return undefined;
    const idx = itinerary.findIndex((i) => i.id === selected.id);
    for (let i = idx - 1; i >= 0; i--) {
      if (itinerary[i].coords) return itinerary[i].coords;
    }
    return undefined;
  }, [selected]);

  return (
    <div className="pb-6">
      <Section
        title="Day-by-day plan"
        action={
          <button className="inline-flex items-center gap-1 rounded-full bg-sunset px-3 py-1.5 text-xs font-medium text-sunset-foreground">
            <Plus className="h-3.5 w-3.5" /> Add
          </button>
        }
      >
        <div className="space-y-6">
          {days.map((day) => {
            const isToday = day === activeDay && currentDay !== null;
            const isUpcomingPreview = day === activeDay && currentDay === null;
            return (
              <div key={day}>
                <div className="mb-3 flex items-baseline gap-2">
                  <span className="font-display text-2xl font-semibold">
                    Day {day}
                  </span>
                  <span className="text-xs text-muted-foreground">
                    Jul {11 + day}
                  </span>
                  {isToday ? (
                    <span className="ml-auto inline-flex items-center gap-1 rounded-full bg-emerald-500/15 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-emerald-600">
                      <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-emerald-500" />
                      Today
                    </span>
                  ) : isUpcomingPreview ? (
                    <span className="ml-auto rounded-full bg-secondary px-2 py-0.5 text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                      Up next
                    </span>
                  ) : null}
                </div>
                <ol
                  className={cn(
                    "relative space-y-3 border-l border-dashed pl-5",
                    isToday ? "border-emerald-400/60" : "border-border",
                  )}
                >
                  {itinerary
                    .filter((i) => i.day === day)
                    .map((item) => {
                      const Icon = iconFor[item.type];
                      const interactive =
                        item.type === "transport" || item.type === "activity" ||
                        item.type === "meal" || item.type === "hotel";
                      return (
                        <li key={item.id} className="relative">
                          <span
                            className={cn(
                              "absolute -left-[1.625rem] top-1.5 grid h-6 w-6 place-items-center rounded-full bg-card ring-2 ring-background",
                              isToday ? "text-emerald-600" : "text-ocean",
                            )}
                          >
                            <Icon className="h-3 w-3" />
                          </span>
                          <button
                            type="button"
                            onClick={() => interactive && setSelected(item)}
                            disabled={!interactive}
                            className={cn(
                              "w-full rounded-2xl border bg-card p-3 text-left shadow-soft transition-colors",
                              interactive
                                ? "border-border hover:bg-secondary/40 active:scale-[0.99]"
                                : "border-border",
                              item.type === "transport" &&
                                "border-sunset/40 bg-sunset/5",
                            )}
                          >
                            <div className="flex items-center justify-between gap-2">
                              <p
                                className={cn(
                                  "text-xs font-medium",
                                  isToday ? "text-emerald-600" : "text-ocean",
                                )}
                              >
                                {item.time}
                              </p>
                              {item.duration ? (
                                <span className="text-[11px] text-muted-foreground">
                                  {item.duration}
                                </span>
                              ) : null}
                            </div>
                            <div className="mt-1 flex items-center justify-between gap-2">
                              <div className="min-w-0">
                                <p className="text-sm font-medium">{item.title}</p>
                                {item.location ? (
                                  <p className="truncate text-xs text-muted-foreground">
                                    {item.location}
                                  </p>
                                ) : null}
                              </div>
                              {interactive ? (
                                <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground" />
                              ) : null}
                            </div>
                            {item.type === "transport" ? (
                              <p className="mt-2 text-[11px] font-medium text-sunset">
                                Tap for routes, walk & ride options
                              </p>
                            ) : null}
                          </button>
                        </li>
                      );
                    })}
                </ol>
              </div>
            );
          })}
        </div>
      </Section>

      <TransportSheet
        item={selected}
        fallbackOrigin={fallbackOrigin}
        onClose={() => setSelected(null)}
      />
    </div>
  );
}
