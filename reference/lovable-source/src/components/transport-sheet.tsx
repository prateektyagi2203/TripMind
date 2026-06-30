import { useMemo } from "react";
import {
  Drawer,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerFooter,
  DrawerClose,
} from "@/components/ui/drawer";
import { Footprints, Car, Bike, MapPin, Navigation, ExternalLink } from "lucide-react";
import { useCurrentLocation } from "@/hooks/use-current-location";
import { haversineKm, type GeoPoint, type ItineraryItem } from "@/lib/mock-data";

interface Props {
  item: ItineraryItem | null;
  /** Optional fallback origin (e.g. previous itinerary stop) when live GPS isn't available. */
  fallbackOrigin?: GeoPoint;
  onClose: () => void;
}

interface RideOption {
  app: "Grab" | "Bolt" | "inDrive" | "Line Taxi";
  color: string;
  eta: string;
  price: string;
  deepLink: (o: GeoPoint, d: GeoPoint) => string;
}

const RIDE_APPS: RideOption[] = [
  {
    app: "Grab",
    color: "bg-emerald-500",
    eta: "3 min",
    price: "฿320",
    deepLink: (o, d) =>
      `https://grab.onelink.me/2695613898/transport?pickupLatitude=${o.lat}&pickupLongitude=${o.lng}&dropOffLatitude=${d.lat}&dropOffLongitude=${d.lng}`,
  },
  {
    app: "Bolt",
    color: "bg-blue-500",
    eta: "5 min",
    price: "฿285",
    deepLink: (o, d) =>
      `https://bolt.eu/order/?pickup[latitude]=${o.lat}&pickup[longitude]=${o.lng}&dropoff[latitude]=${d.lat}&dropoff[longitude]=${d.lng}`,
  },
  {
    app: "inDrive",
    color: "bg-amber-500",
    eta: "7 min",
    price: "฿260",
    deepLink: (o, d) =>
      `https://indrive.com/?from=${o.lat},${o.lng}&to=${d.lat},${d.lng}`,
  },
  {
    app: "Line Taxi",
    color: "bg-green-600",
    eta: "6 min",
    price: "฿340",
    deepLink: (o, d) =>
      `https://taxi.line.me/?pickupLat=${o.lat}&pickupLng=${o.lng}&dropoffLat=${d.lat}&dropoffLng=${d.lng}`,
  },
];

function gmapsLink(origin: GeoPoint, dest: GeoPoint, mode: "walking" | "driving" | "two-wheeler") {
  return `https://www.google.com/maps/dir/?api=1&origin=${origin.lat},${origin.lng}&destination=${dest.lat},${dest.lng}&travelmode=${mode}`;
}

export function TransportSheet({ item, fallbackOrigin, onClose }: Props) {
  const loc = useCurrentLocation();
  const open = item !== null;

  const origin: GeoPoint | undefined = useMemo(() => {
    if (loc.location?.latitude && loc.location?.longitude) {
      return { lat: loc.location.latitude, lng: loc.location.longitude };
    }
    return fallbackOrigin;
  }, [loc.location, fallbackOrigin]);

  const dest = item?.coords;
  const distance = origin && dest ? haversineKm(origin, dest) : null;
  const walkable = distance !== null && distance <= 2;
  // rough estimates: walk 5 km/h, scooter 25 km/h, car 30 km/h in city
  const fmt = (km: number, speed: number) => {
    const mins = Math.max(1, Math.round((km / speed) * 60));
    return mins < 60 ? `${mins} min` : `${Math.floor(mins / 60)}h ${mins % 60}m`;
  };

  return (
    <Drawer open={open} onOpenChange={(o) => !o && onClose()}>
      <DrawerContent className="max-h-[88vh]">
        <DrawerHeader className="text-left">
          <DrawerTitle className="font-display text-xl">
            How to get there
          </DrawerTitle>
          <DrawerDescription className="flex items-center gap-1.5 text-xs">
            <MapPin className="h-3 w-3" />
            {item?.location ?? item?.title ?? "Destination"}
            {distance !== null ? (
              <span className="ml-1 rounded-full bg-secondary px-2 py-0.5 text-[10px] font-medium text-foreground">
                {distance.toFixed(distance < 10 ? 1 : 0)} km away
              </span>
            ) : null}
          </DrawerDescription>
        </DrawerHeader>

        <div className="space-y-3 overflow-y-auto px-4 pb-2">
          {!origin ? (
            <p className="rounded-2xl bg-secondary p-3 text-xs text-muted-foreground">
              Waiting for your location to suggest routes…
            </p>
          ) : null}

          {walkable && origin && dest ? (
            <a
              href={gmapsLink(origin, dest, "walking")}
              target="_blank"
              rel="noreferrer"
              className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-2xl border border-ocean/30 bg-ocean/5 p-4"
            >
              <span className="grid h-11 w-11 place-items-center rounded-2xl bg-ocean text-white">
                <Footprints className="h-5 w-5" />
              </span>
              <div className="min-w-0">
                <p className="text-sm font-semibold">Walk</p>
                <p className="text-xs text-muted-foreground">
                  {fmt(distance!, 5)} · opens Google Maps with directions
                </p>
              </div>
              <ExternalLink className="h-4 w-4 text-muted-foreground" />
            </a>
          ) : null}

          {origin && dest ? (
            <div className="grid grid-cols-2 gap-2">
              <a
                href={gmapsLink(origin, dest, "two-wheeler")}
                target="_blank"
                rel="noreferrer"
                className="flex items-center gap-2 rounded-2xl border border-border bg-card p-3 text-xs"
              >
                <Bike className="h-4 w-4 text-sunset" />
                <div>
                  <p className="font-medium">Scooter</p>
                  <p className="text-[11px] text-muted-foreground">
                    {fmt(distance!, 25)}
                  </p>
                </div>
              </a>
              <a
                href={gmapsLink(origin, dest, "driving")}
                target="_blank"
                rel="noreferrer"
                className="flex items-center gap-2 rounded-2xl border border-border bg-card p-3 text-xs"
              >
                <Navigation className="h-4 w-4 text-ocean" />
                <div>
                  <p className="font-medium">Drive</p>
                  <p className="text-[11px] text-muted-foreground">
                    {fmt(distance!, 30)}
                  </p>
                </div>
              </a>
            </div>
          ) : null}

          <div className="pt-2">
            <p className="px-1 pb-2 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
              <Car className="mr-1 inline h-3 w-3" /> Cabs &amp; auto
            </p>
            <div className="space-y-2">
              {RIDE_APPS.map((r) => (
                <a
                  key={r.app}
                  href={origin && dest ? r.deepLink(origin, dest) : "#"}
                  target="_blank"
                  rel="noreferrer"
                  aria-disabled={!origin || !dest}
                  className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-2xl border border-border bg-card p-3 shadow-soft"
                >
                  <span
                    className={`grid h-10 w-10 place-items-center rounded-2xl text-sm font-semibold text-white ${r.color}`}
                  >
                    {r.app[0]}
                  </span>
                  <div className="min-w-0">
                    <p className="text-sm font-medium">{r.app}</p>
                    <p className="text-xs text-muted-foreground">
                      {r.eta} away · pickup &amp; drop prefilled
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="font-display text-base font-semibold">
                      {r.price}
                    </p>
                    <p className="text-[10px] font-medium text-ocean">
                      Book →
                    </p>
                  </div>
                </a>
              ))}
            </div>
          </div>
        </div>

        <DrawerFooter className="pt-2">
          <DrawerClose className="rounded-full bg-secondary py-2.5 text-sm font-medium">
            Close
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}
