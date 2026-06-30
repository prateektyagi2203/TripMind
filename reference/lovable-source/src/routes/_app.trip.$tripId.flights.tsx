import { createFileRoute } from "@tanstack/react-router";
import { Plane, Plus } from "lucide-react";
import { Section } from "@/components/screen";
import { flights } from "@/lib/mock-data";

export const Route = createFileRoute("/_app/trip/$tripId/flights")({
  component: FlightsScreen,
});

function FlightsScreen() {
  return (
    <div className="pb-6">
      <Section
        title="Flights"
        action={
          <button className="inline-flex items-center gap-1 rounded-full bg-sunset px-3 py-1.5 text-xs font-medium text-sunset-foreground">
            <Plus className="h-3.5 w-3.5" /> Import
          </button>
        }
      >
        <div className="space-y-3">
          {flights.map((f) => (
            <article
              key={f.id}
              className="overflow-hidden rounded-3xl border border-border bg-card shadow-soft"
            >
              <header className="flex items-center justify-between border-b border-border/60 px-4 py-2.5">
                <div className="flex items-center gap-2">
                  <span className="grid h-7 w-7 place-items-center rounded-lg bg-secondary text-ocean">
                    <Plane className="h-3.5 w-3.5" />
                  </span>
                  <div>
                    <p className="text-xs font-medium">{f.airline}</p>
                    <p className="text-[11px] text-muted-foreground">
                      {f.flightNumber} · {f.date}
                    </p>
                  </div>
                </div>
                <span className="rounded-full bg-emerald-500/10 px-2.5 py-1 text-[11px] font-medium text-emerald-700">
                  On time
                </span>
              </header>
              <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-3 p-4">
                <div>
                  <p className="font-display text-2xl font-semibold">{f.from.code}</p>
                  <p className="text-xs text-muted-foreground">{f.from.city}</p>
                  <p className="mt-1 text-sm">{f.from.time}</p>
                </div>
                <div className="flex flex-col items-center text-muted-foreground">
                  <div className="h-px w-12 bg-border" />
                  <Plane className="my-1 h-4 w-4 rotate-90 text-ocean" />
                  <div className="h-px w-12 bg-border" />
                </div>
                <div className="text-right">
                  <p className="font-display text-2xl font-semibold">{f.to.code}</p>
                  <p className="text-xs text-muted-foreground">{f.to.city}</p>
                  <p className="mt-1 text-sm">{f.to.time}</p>
                </div>
              </div>
            </article>
          ))}
        </div>
      </Section>
    </div>
  );
}
