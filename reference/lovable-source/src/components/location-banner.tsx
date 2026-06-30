import { MapPin, Loader2 } from "lucide-react";
import { useCurrentLocation } from "@/hooks/use-current-location";

export function LocationBanner() {
  const { status, location } = useCurrentLocation(true);

  const label =
    status === "granted" && location?.city
      ? `${location.city}${location.country ? `, ${location.country}` : ""}`
      : status === "granted"
        ? `${location?.latitude.toFixed(2)}, ${location?.longitude.toFixed(2)}`
        : status === "loading"
          ? `${location?.latitude.toFixed(2)}, ${location?.longitude.toFixed(2)}`
          : status === "denied"
            ? "Location permission needed"
            : status === "unavailable"
              ? "Location not supported"
              : status === "error"
                ? "Couldn't get location"
                : "Locating you…";

  const sub =
    status === "granted"
      ? "Location active"
      : status === "loading"
        ? "Fetching city name…"
        : status === "denied"
          ? "Allow location in your browser settings"
          : status === "error"
            ? "We'll keep trying in the background"
            : "Pinging GPS…";

  const isActive = status === "granted";
  const isLoading = status === "loading";
  const isError = status === "denied" || status === "unavailable" || status === "error";

  return (
    <div className="grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-3xl border border-border bg-card px-4 py-3 shadow-soft">
      <span className="grid h-10 w-10 place-items-center rounded-2xl bg-ocean/10 text-ocean">
        <MapPin className="h-4 w-4" />
      </span>
      <div className="min-w-0">
        <p className="truncate text-sm font-medium">{label}</p>
        <p className="truncate text-xs text-muted-foreground">{sub}</p>
      </div>
      <div className="flex items-center gap-2">
        {isActive && (
          <span className="rounded-full bg-emerald-500/15 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-emerald-600">
            Active
          </span>
        )}
        <span
          aria-hidden
          className={`h-2.5 w-2.5 rounded-full ${
            isActive
              ? "bg-emerald-500"
              : isLoading
                ? "bg-sunset animate-pulse"
                : isError
                  ? "bg-destructive"
                  : "animate-pulse bg-sunset"
          }`}
        />
        {isLoading && (
          <Loader2 className="h-3.5 w-3.5 animate-spin text-sunset" />
        )}
      </div>
    </div>
  );
}
