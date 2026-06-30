import { useMemo, useState } from "react";
import { MapPin, Star, ArrowRight } from "lucide-react";
import { TransportSheet } from "@/components/transport-sheet";
import { useCurrentLocation } from "@/hooks/use-current-location";
import { haversineKm, type GeoPoint, type ItineraryItem } from "@/lib/mock-data";

export interface NearbyPlace {
  id: string;
  name: string;
  category: string;
  /** Offset in km from origin (used to synthesize coords when no real data). */
  offsetKm?: { north: number; east: number };
  /** Explicit coords override. */
  coords?: GeoPoint;
  rating?: number;
  note?: string;
  icon?: string;
}

interface Props {
  /** Origin to anchor synthetic places when GPS unavailable (e.g. Bangkok). */
  fallbackOrigin: GeoPoint;
  places: NearbyPlace[];
  emptyLabel?: string;
}

// ~111 km per degree latitude. Longitude scales with cos(lat).
function applyOffset(origin: GeoPoint, offsetKm: { north: number; east: number }): GeoPoint {
  const lat = origin.lat + offsetKm.north / 111;
  const lng = origin.lng + offsetKm.east / (111 * Math.cos((origin.lat * Math.PI) / 180));
  return { lat, lng };
}

export function NearbyList({ fallbackOrigin, places, emptyLabel }: Props) {
  const loc = useCurrentLocation();
  const [selected, setSelected] = useState<ItineraryItem | null>(null);

  const origin: GeoPoint = useMemo(() => {
    if (loc.location?.latitude && loc.location?.longitude) {
      return { lat: loc.location.latitude, lng: loc.location.longitude };
    }
    return fallbackOrigin;
  }, [loc.location, fallbackOrigin]);

  const enriched = useMemo(() => {
    return places
      .map((p) => {
        const coords = p.coords ?? (p.offsetKm ? applyOffset(origin, p.offsetKm) : origin);
        return { ...p, coords, distance: haversineKm(origin, coords) };
      })
      .sort((a, b) => a.distance - b.distance);
  }, [places, origin]);

  if (enriched.length === 0) {
    return (
      <p className="rounded-2xl bg-secondary p-4 text-center text-xs text-muted-foreground">
        {emptyLabel ?? "Nothing nearby right now."}
      </p>
    );
  }

  return (
    <>
      <div className="space-y-3">
        {enriched.map((p) => (
          <button
            key={p.id}
            onClick={() =>
              setSelected({
                id: p.id,
                day: 0,
                time: "",
                title: p.name,
                type: "activity",
                location: p.category,
                coords: p.coords,
              })
            }
            className="grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-2xl border border-border bg-card p-4 text-left shadow-soft"
          >
            <span className="grid h-11 w-11 place-items-center rounded-2xl bg-ocean/10 text-lg">
              {p.icon ?? "📍"}
            </span>
            <div className="min-w-0">
              <p className="truncate font-display text-sm font-semibold">{p.name}</p>
              <p className="flex items-center gap-1.5 truncate text-xs text-muted-foreground">
                <MapPin className="h-3 w-3" />
                {p.category}
                {p.rating ? (
                  <>
                    <span className="mx-1">·</span>
                    <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                    {p.rating.toFixed(1)}
                  </>
                ) : null}
              </p>
              {p.note ? (
                <p className="truncate text-[11px] text-muted-foreground/80">{p.note}</p>
              ) : null}
            </div>
            <div className="text-right">
              <p className="font-display text-sm font-semibold">
                {p.distance < 1
                  ? `${Math.round(p.distance * 1000)} m`
                  : `${p.distance.toFixed(1)} km`}
              </p>
              <span className="inline-flex items-center gap-0.5 text-[10px] font-medium text-ocean">
                Go <ArrowRight className="h-3 w-3" />
              </span>
            </div>
          </button>
        ))}
      </div>
      <TransportSheet
        item={selected}
        fallbackOrigin={origin}
        onClose={() => setSelected(null)}
      />
    </>
  );
}
