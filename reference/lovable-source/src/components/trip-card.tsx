import { Link } from "@tanstack/react-router";
import { CalendarDays, MapPin, Users } from "lucide-react";
import type { Trip } from "@/lib/mock-data";
import {
  daysUntil,
  formatDateRange,
  getCityImage,
  getCurrentCityForTrip,
} from "@/lib/mock-data";
import { cn } from "@/lib/utils";

const statusLabel: Record<Trip["status"], string> = {
  upcoming: "Upcoming",
  active: "On trip",
  completed: "Completed",
  draft: "Draft",
};

export function TripCard({ trip }: { trip: Trip }) {
  const days = daysUntil(trip.startDate);
  const countdown =
    trip.status === "upcoming" && days > 0
      ? `${days} days to go`
      : trip.status === "active"
        ? "Happening now"
        : trip.status === "draft"
          ? "Not booked yet"
          : "Memory saved";

  const currentCity = getCurrentCityForTrip(trip);
  const bgImage = getCityImage(currentCity);

  return (
    <Link
      to="/trip/$tripId"
      params={{ tripId: trip.id }}
      className="group block overflow-hidden rounded-3xl border border-border bg-card shadow-soft"
    >
      <div className={cn("relative h-40 w-full", !bgImage && trip.coverGradient)}>
        {bgImage ? (
          <img
            src={bgImage}
            alt={`${currentCity} hero`}
            loading="lazy"
            className="absolute inset-0 h-full w-full object-cover"
          />
        ) : null}
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/15 to-transparent" />
        <div className="absolute left-4 top-4 flex gap-2">
          <span className="inline-flex items-center rounded-full bg-white/90 px-2.5 py-1 text-[11px] font-medium text-foreground">
            {statusLabel[trip.status]}
          </span>
          {currentCity && trip.status === "active" ? (
            <span className="inline-flex items-center gap-1 rounded-full bg-sunset px-2.5 py-1 text-[11px] font-medium text-sunset-foreground">
              <MapPin className="h-3 w-3" /> In {currentCity}
            </span>
          ) : null}
        </div>
        <div className="absolute bottom-3 left-4 right-4 text-white">
          <p className="text-[11px] uppercase tracking-[0.18em] opacity-85">
            {currentCity ? `${currentCity} · ${trip.country}` : trip.country}
          </p>
          <h3 className="font-display text-xl font-semibold leading-tight drop-shadow">
            {trip.title}
          </h3>
        </div>
      </div>
      <div className="grid grid-cols-[minmax(0,1fr)_auto] items-center gap-3 px-4 py-3">
        <div className="min-w-0">
          <p className="flex items-center gap-1.5 truncate text-xs text-muted-foreground">
            <CalendarDays className="h-3.5 w-3.5 shrink-0" />
            {formatDateRange(trip.startDate, trip.endDate)}
          </p>
          <p className="mt-1 flex items-center gap-1.5 text-xs text-muted-foreground">
            <Users className="h-3.5 w-3.5 shrink-0" />
            {trip.travelers} travelers
          </p>
        </div>
        <span className="shrink-0 rounded-full bg-sunset/15 px-3 py-1.5 text-[11px] font-medium text-sunset">
          {countdown}
        </span>
      </div>
    </Link>
  );
}
