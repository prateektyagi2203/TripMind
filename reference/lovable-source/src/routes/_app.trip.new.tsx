import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowRight, Calendar, MapPin, Users } from "lucide-react";
import { Screen, ScreenHeader } from "@/components/screen";

export const Route = createFileRoute("/_app/trip/new")({
  component: NewTripScreen,
});

function NewTripScreen() {
  return (
    <Screen>
      <ScreenHeader title="New trip" back="/" />
      <div className="space-y-4 px-5 pt-4">
        <div className="rounded-3xl gradient-sunset p-5 text-white shadow-soft">
          <p className="text-xs uppercase tracking-[0.18em] opacity-85">Start with AI</p>
          <h2 className="mt-1 font-display text-2xl font-semibold leading-tight">
            "5 days in Thailand with kids, mid-July"
          </h2>
          <p className="mt-2 text-xs opacity-90">
            Describe your trip in your own words. We'll draft an itinerary,
            flights, and stays.
          </p>
          <button className="mt-4 inline-flex items-center gap-2 rounded-full bg-white px-4 py-2 text-xs font-semibold text-foreground">
            Plan with AI <ArrowRight className="h-3.5 w-3.5" />
          </button>
        </div>

        <div className="rounded-3xl border border-border bg-card p-4 shadow-soft">
          <p className="text-xs uppercase tracking-[0.16em] text-muted-foreground">
            Or build manually
          </p>
          <div className="mt-3 space-y-3">
            <Field icon={<MapPin className="h-4 w-4" />} label="Destination" value="Add city or country" />
            <Field icon={<Calendar className="h-4 w-4" />} label="Dates" value="Pick travel dates" />
            <Field icon={<Users className="h-4 w-4" />} label="Travelers" value="2 adults" />
          </div>
          <Link
            to="/trip/$tripId"
            params={{ tripId: "thailand-2026" }}
            className="mt-4 block rounded-full bg-primary py-3 text-center text-sm font-semibold text-primary-foreground"
          >
            Create trip
          </Link>
        </div>
      </div>
    </Screen>
  );
}

function Field({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <button className="grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-2xl bg-secondary px-3 py-3 text-left">
      <span className="grid h-9 w-9 place-items-center rounded-xl bg-card text-ocean">
        {icon}
      </span>
      <div className="min-w-0">
        <p className="text-[10px] uppercase tracking-wider text-muted-foreground">
          {label}
        </p>
        <p className="truncate text-sm font-medium">{value}</p>
      </div>
      <ArrowRight className="h-4 w-4 text-muted-foreground" />
    </button>
  );
}
