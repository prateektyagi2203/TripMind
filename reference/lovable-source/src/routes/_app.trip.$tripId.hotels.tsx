import { createFileRoute } from "@tanstack/react-router";
import { Hotel as HotelIcon, MapPin, Star, Plus } from "lucide-react";
import { Section } from "@/components/screen";
import { hotels } from "@/lib/mock-data";

export const Route = createFileRoute("/_app/trip/$tripId/hotels")({
  component: HotelsScreen,
});

function HotelsScreen() {
  return (
    <div className="pb-6">
      <Section
        title="Stays"
        action={
          <button className="inline-flex items-center gap-1 rounded-full bg-sunset px-3 py-1.5 text-xs font-medium text-sunset-foreground">
            <Plus className="h-3.5 w-3.5" /> Import
          </button>
        }
      >
        <div className="space-y-3">
          {hotels.map((h) => (
            <article
              key={h.id}
              className="overflow-hidden rounded-3xl border border-border bg-card shadow-soft"
            >
              <div className="h-28 gradient-ocean" />
              <div className="p-4">
                <div className="grid grid-cols-[minmax(0,1fr)_auto] items-start gap-2">
                  <div className="min-w-0">
                    <h3 className="truncate font-display text-lg font-semibold">
                      {h.name}
                    </h3>
                    <p className="flex items-center gap-1 text-xs text-muted-foreground">
                      <MapPin className="h-3 w-3" /> {h.city}
                    </p>
                  </div>
                  <span className="flex shrink-0 items-center gap-1 rounded-full bg-secondary px-2 py-1 text-[11px] font-medium">
                    <Star className="h-3 w-3 fill-current text-amber-500" /> {h.rating}
                  </span>
                </div>
                <div className="mt-3 grid grid-cols-3 gap-2 text-xs">
                  <div className="rounded-xl bg-secondary p-2">
                    <p className="text-[10px] uppercase text-muted-foreground">
                      Check in
                    </p>
                    <p className="mt-0.5 font-medium">{h.checkIn}</p>
                  </div>
                  <div className="rounded-xl bg-secondary p-2">
                    <p className="text-[10px] uppercase text-muted-foreground">
                      Check out
                    </p>
                    <p className="mt-0.5 font-medium">{h.checkOut}</p>
                  </div>
                  <div className="rounded-xl bg-secondary p-2">
                    <p className="text-[10px] uppercase text-muted-foreground">
                      Nights
                    </p>
                    <p className="mt-0.5 font-medium">{h.nights}</p>
                  </div>
                </div>
                <div className="mt-3 grid grid-cols-3 gap-2">
                  <button className="rounded-full bg-secondary px-2 py-1.5 text-[11px] font-medium">
                    Nearby food
                  </button>
                  <button className="rounded-full bg-secondary px-2 py-1.5 text-[11px] font-medium">
                    Pharmacy
                  </button>
                  <button className="rounded-full bg-secondary px-2 py-1.5 text-[11px] font-medium">
                    Hospitals
                  </button>
                </div>
              </div>
            </article>
          ))}
        </div>
      </Section>
    </div>
  );
}
