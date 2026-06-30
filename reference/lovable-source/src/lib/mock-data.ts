// Mock data for the TripMind scaffold. Replace with real API/DB calls later.
// Keep types stable so screens can be swapped to live data without refactor.

export type TripStatus = "upcoming" | "active" | "completed" | "draft";

export interface Trip {
  id: string;
  title: string;
  destination: string;
  country: string;
  countryCode: string;
  startDate: string; // ISO
  endDate: string;
  status: TripStatus;
  coverGradient: string; // tailwind utility fallback
  cities: string[]; // ordered list of cities visited in this trip
  travelers: number;
  budget: { spent: number; total: number; currency: string };
}

// City -> hero image (Unsplash, hotlink-safe).
// Extend this map as new destinations are added.
export const cityImages: Record<string, string> = {
  Bangkok:
    "https://images.unsplash.com/photo-1508009603885-50cf7c579365?auto=format&fit=crop&w=900&q=70",
  Phuket:
    "https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?auto=format&fit=crop&w=900&q=70",
  "Chiang Mai":
    "https://images.unsplash.com/photo-1598935898639-81586f7d2129?auto=format&fit=crop&w=900&q=70",
  Tokyo:
    "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=900&q=70",
  Kyoto:
    "https://images.unsplash.com/photo-1493997181344-712f2f19d87a?auto=format&fit=crop&w=900&q=70",
  Lisbon:
    "https://images.unsplash.com/photo-1555881400-74d7acaacd8b?auto=format&fit=crop&w=900&q=70",
  Bengaluru:
    "https://images.unsplash.com/photo-1596176530529-78163a4f7af2?auto=format&fit=crop&w=900&q=70",
};

export function getCityImage(city?: string | null): string | undefined {
  if (!city) return undefined;
  // case-insensitive lookup
  const key = Object.keys(cityImages).find(
    (k) => k.toLowerCase() === city.toLowerCase(),
  );
  return key ? cityImages[key] : undefined;
}

export interface GeoPoint {
  lat: number;
  lng: number;
}

export interface ItineraryItem {
  id: string;
  day: number;
  time: string;
  title: string;
  type: "flight" | "hotel" | "activity" | "meal" | "transport";
  location?: string;
  duration?: string;
  /** Destination of this stop, used for travel-time + deep links. */
  coords?: GeoPoint;
}

export interface Flight {
  id: string;
  airline: string;
  flightNumber: string;
  from: { code: string; city: string; time: string };
  to: { code: string; city: string; time: string };
  date: string;
  status: "on-time" | "delayed" | "boarding" | "departed";
}

export interface Hotel {
  id: string;
  name: string;
  city: string;
  checkIn: string;
  checkOut: string;
  nights: number;
  rating: number;
}

export interface Expense {
  id: string;
  title: string;
  category: "food" | "transport" | "lodging" | "activity" | "shopping" | "other";
  amount: number;
  currency: string;
  amountHome: number;
  date: string;
  paidBy: string;
}

export interface Memory {
  id: string;
  title: string;
  thumbnail: string; // gradient
  day: number;
  count: number;
}

export const trips: Trip[] = [
  {
    id: "thailand-2026",
    title: "Thailand with the family",
    destination: "Bangkok · Phuket · Chiang Mai",
    country: "Thailand",
    countryCode: "TH",
    startDate: "2026-07-12",
    endDate: "2026-07-24",
    status: "upcoming",
    coverGradient: "gradient-sunset",
    cities: ["Bangkok", "Phuket", "Chiang Mai"],
    travelers: 4,
    budget: { spent: 420, total: 3800, currency: "USD" },
  },
  {
    id: "tokyo-2026",
    title: "Tokyo cherry blossoms",
    destination: "Tokyo · Kyoto",
    country: "Japan",
    countryCode: "JP",
    startDate: "2026-04-02",
    endDate: "2026-04-11",
    status: "draft",
    coverGradient: "gradient-ocean",
    cities: ["Tokyo", "Kyoto"],
    travelers: 2,
    budget: { spent: 0, total: 5200, currency: "USD" },
  },
  {
    id: "lisbon-2025",
    title: "Lisbon weekend",
    destination: "Lisbon",
    country: "Portugal",
    countryCode: "PT",
    startDate: "2025-09-14",
    endDate: "2025-09-18",
    status: "completed",
    coverGradient: "gradient-ocean",
    cities: ["Lisbon"],
    travelers: 2,
    budget: { spent: 1180, total: 1200, currency: "USD" },
  },
];

export function getTrip(id: string): Trip | undefined {
  return trips.find((t) => t.id === id);
}

/**
 * Returns the city the traveler is in today, based on hotel bookings for
 * the given trip. Falls back to the first trip city, then to `undefined`.
 * Replace `hotels` with a per-trip lookup once data is real.
 */
export function getCurrentCityForTrip(
  trip: Trip,
  now: Date = new Date(),
): string | undefined {
  const today = now.toISOString().slice(0, 10);
  const tripHotels = hotels.filter((h) => trip.cities.includes(h.city));
  const active = tripHotels.find(
    (h) => h.checkIn <= today && today < h.checkOut,
  );
  if (active) return active.city;
  // Before the trip: show the first city; after: the last one.
  if (today < trip.startDate) return trip.cities[0];
  if (today > trip.endDate) return trip.cities[trip.cities.length - 1];
  return trip.cities[0];
}

/**
 * Returns the current 1-indexed day of the trip based on today's date, or
 * `null` if today is before the trip starts or after it ends.
 */
export function getCurrentTripDay(
  trip: Trip,
  now: Date = new Date(),
): number | null {
  const start = new Date(trip.startDate + "T00:00:00").getTime();
  const end = new Date(trip.endDate + "T23:59:59").getTime();
  const t = now.getTime();
  if (t < start || t > end) return null;
  return Math.floor((t - start) / (1000 * 60 * 60 * 24)) + 1;
}

/** Great-circle distance in kilometres between two lat/lng points. */
export function haversineKm(a: GeoPoint, b: GeoPoint): number {
  const R = 6371;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

export const itinerary: ItineraryItem[] = [
  { id: "i1", day: 1, time: "09:30", title: "Arrival at BKK", type: "flight", location: "Suvarnabhumi Airport", coords: { lat: 13.6900, lng: 100.7501 } },
  { id: "i2", day: 1, time: "11:00", title: "Transfer to hotel", type: "transport", duration: "45m", location: "Riva Arun Bangkok", coords: { lat: 13.7437, lng: 100.4892 } },
  { id: "i3", day: 1, time: "13:00", title: "Check in — Riva Arun Bangkok", type: "hotel", location: "Tha Tien", coords: { lat: 13.7437, lng: 100.4892 } },
  { id: "i4", day: 1, time: "17:00", title: "Sunset at Wat Arun", type: "activity", location: "Temple of Dawn", coords: { lat: 13.7437, lng: 100.4889 } },
  { id: "i5", day: 1, time: "19:30", title: "Dinner — Err Urban Rustic Thai", type: "meal", coords: { lat: 13.7456, lng: 100.4923 } },
  { id: "i6", day: 2, time: "08:00", title: "Grand Palace tour", type: "activity", duration: "3h", coords: { lat: 13.7500, lng: 100.4913 } },
  { id: "i7", day: 2, time: "12:30", title: "Lunch — Jay Fai", type: "meal", coords: { lat: 13.7530, lng: 100.5072 } },
  { id: "i8", day: 2, time: "15:00", title: "Chao Phraya river cruise", type: "activity", duration: "2h", coords: { lat: 13.7244, lng: 100.5147 } },
];

export const flights: Flight[] = [
  {
    id: "f1",
    airline: "Thai Airways",
    flightNumber: "TG 316",
    from: { code: "BLR", city: "Bengaluru", time: "23:45" },
    to: { code: "BKK", city: "Bangkok", time: "06:15" },
    date: "2026-07-12",
    status: "on-time",
  },
  {
    id: "f2",
    airline: "Bangkok Airways",
    flightNumber: "PG 273",
    from: { code: "BKK", city: "Bangkok", time: "09:00" },
    to: { code: "HKT", city: "Phuket", time: "10:25" },
    date: "2026-07-17",
    status: "on-time",
  },
];

export const hotels: Hotel[] = [
  { id: "h1", name: "Riva Arun Bangkok", city: "Bangkok", checkIn: "2026-07-12", checkOut: "2026-07-17", nights: 5, rating: 4.6 },
  { id: "h2", name: "The Surin Phuket", city: "Phuket", checkIn: "2026-07-17", checkOut: "2026-07-22", nights: 5, rating: 4.8 },
];

export const expenses: Expense[] = [
  { id: "e1", title: "Visa fees", category: "other", amount: 160, currency: "USD", amountHome: 160, date: "2026-06-20", paidBy: "You" },
  { id: "e2", title: "Travel insurance", category: "other", amount: 92, currency: "USD", amountHome: 92, date: "2026-06-22", paidBy: "You" },
  { id: "e3", title: "Airport taxi", category: "transport", amount: 1100, currency: "THB", amountHome: 31, date: "2026-07-12", paidBy: "Priya" },
  { id: "e4", title: "Street food — Yaowarat", category: "food", amount: 880, currency: "THB", amountHome: 25, date: "2026-07-12", paidBy: "You" },
];

export const memories: Memory[] = [
  { id: "m1", title: "Wat Arun at golden hour", thumbnail: "gradient-sunset", day: 1, count: 12 },
  { id: "m2", title: "Floating market", thumbnail: "gradient-ocean", day: 2, count: 24 },
  { id: "m3", title: "Phuket beaches", thumbnail: "gradient-sunset", day: 6, count: 41 },
];

export const familyMembers = [
  { id: "u1", name: "You", role: "Trip leader", initials: "YO" },
  { id: "u2", name: "Priya", role: "Co-planner", initials: "PR" },
  { id: "u3", name: "Aarav", role: "Traveler", initials: "AA" },
  { id: "u4", name: "Anaya", role: "Traveler", initials: "AN" },
];

export function formatDateRange(start: string, end: string) {
  const s = new Date(start);
  const e = new Date(end);
  const sameMonth = s.getMonth() === e.getMonth() && s.getFullYear() === e.getFullYear();
  const m = (d: Date) => d.toLocaleString("en-US", { month: "short" });
  if (sameMonth) return `${m(s)} ${s.getDate()}–${e.getDate()}, ${e.getFullYear()}`;
  return `${m(s)} ${s.getDate()} – ${m(e)} ${e.getDate()}, ${e.getFullYear()}`;
}

export function daysUntil(date: string) {
  const diff = new Date(date).getTime() - Date.now();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}
