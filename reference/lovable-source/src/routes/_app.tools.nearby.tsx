import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Screen, ScreenHeader, Section } from "@/components/screen";
import { NearbyList, type NearbyPlace } from "@/components/nearby-list";

export const Route = createFileRoute("/_app/tools/nearby")({
  component: NearbyScreen,
});

const FALLBACK = { lat: 13.7461, lng: 100.4906 };

const CATEGORIES = [
  { id: "all", label: "All", icon: "✨" },
  { id: "beach", label: "Beaches", icon: "🏖️" },
  { id: "mall", label: "Malls", icon: "🛍️" },
  { id: "park", label: "Parks", icon: "🌳" },
  { id: "zoo", label: "Zoos", icon: "🦁" },
  { id: "temple", label: "Temples", icon: "🛕" },
  { id: "museum", label: "Museums", icon: "🏛️" },
  { id: "food", label: "Food", icon: "🍜" },
] as const;

type CategoryId = (typeof CATEGORIES)[number]["id"];

const PLACES: (NearbyPlace & { tag: Exclude<CategoryId, "all"> })[] = [
  {
    id: "wat-arun",
    name: "Wat Arun (Temple of Dawn)",
    category: "Iconic riverside temple",
    icon: "🛕",
    rating: 4.7,
    tag: "temple",
    offsetKm: { north: 0.1, east: 0.05 },
    note: "Best at sunset · Entry ฿100",
  },
  {
    id: "grand-palace",
    name: "Grand Palace",
    category: "Historic royal complex",
    icon: "🏛️",
    rating: 4.6,
    tag: "museum",
    offsetKm: { north: 0.4, east: 0.3 },
    note: "Dress code: cover shoulders & knees",
  },
  {
    id: "lumpini",
    name: "Lumpini Park",
    category: "Central city park",
    icon: "🌳",
    rating: 4.5,
    tag: "park",
    offsetKm: { north: -1.2, east: 2.8 },
    note: "Monitor lizards, paddleboats, jogging trail",
  },
  {
    id: "iconsiam",
    name: "ICONSIAM",
    category: "Luxury riverside mall",
    icon: "🛍️",
    rating: 4.6,
    tag: "mall",
    offsetKm: { north: -2.1, east: 1.4 },
    note: "SOOKSIAM floating market on G floor",
  },
  {
    id: "chatuchak",
    name: "Chatuchak Weekend Market",
    category: "15,000+ stalls",
    icon: "🛍️",
    rating: 4.4,
    tag: "mall",
    offsetKm: { north: 6.5, east: 3.2 },
    note: "Sat–Sun · Go early to beat heat",
  },
  {
    id: "safari-world",
    name: "Safari World",
    category: "Drive-through zoo & marine park",
    icon: "🦁",
    rating: 4.3,
    tag: "zoo",
    offsetKm: { north: 8.4, east: 9.1 },
    note: "Full-day · Combo ticket ฿1,800",
  },
  {
    id: "dusit-zoo",
    name: "Khao Kheow Open Zoo",
    category: "Open-concept zoo",
    icon: "🦁",
    rating: 4.5,
    tag: "zoo",
    offsetKm: { north: -12, east: 60 },
    note: "Day trip · Night safari available",
  },
  {
    id: "bang-saen",
    name: "Bang Saen Beach",
    category: "Closest beach to Bangkok",
    icon: "🏖️",
    rating: 4.2,
    tag: "beach",
    offsetKm: { north: -55, east: 35 },
    note: "~1.5 hr drive · Seafood shacks",
  },
  {
    id: "pattaya",
    name: "Pattaya Beach",
    category: "Resort town",
    icon: "🏖️",
    rating: 4.1,
    tag: "beach",
    offsetKm: { north: -65, east: 45 },
    note: "Day trip or weekend stay",
  },
  {
    id: "yaowarat",
    name: "Yaowarat (Chinatown)",
    category: "Street food paradise",
    icon: "🍜",
    rating: 4.7,
    tag: "food",
    offsetKm: { north: 0.8, east: 1.2 },
    note: "Comes alive after 6pm",
  },
  {
    id: "jim-thompson",
    name: "Jim Thompson House",
    category: "Museum & silk gallery",
    icon: "🏛️",
    rating: 4.5,
    tag: "museum",
    offsetKm: { north: 1.6, east: 3.8 },
  },
  {
    id: "benjakitti",
    name: "Benjakitti Forest Park",
    category: "Elevated walkways · wetlands",
    icon: "🌳",
    rating: 4.7,
    tag: "park",
    offsetKm: { north: -0.5, east: 4.2 },
    note: "Great for sunset photos",
  },
];

function NearbyScreen() {
  const [cat, setCat] = useState<CategoryId>("all");
  const filtered = cat === "all" ? PLACES : PLACES.filter((p) => p.tag === cat);

  return (
    <Screen>
      <ScreenHeader
        title="Nearby Places"
        subtitle="Tourist attractions around you"
        back="/tools"
      />
      <div className="-mx-1 overflow-x-auto px-4 pt-4 pb-2">
        <div className="flex gap-2">
          {CATEGORIES.map((c) => (
            <button
              key={c.id}
              onClick={() => setCat(c.id)}
              className={`flex shrink-0 items-center gap-1.5 rounded-full border px-3.5 py-2 text-xs font-medium transition-colors ${
                cat === c.id
                  ? "border-ocean bg-ocean text-white"
                  : "border-border bg-card text-foreground"
              }`}
            >
              <span>{c.icon}</span>
              {c.label}
            </button>
          ))}
        </div>
      </div>
      <Section title={`${filtered.length} ${cat === "all" ? "places" : CATEGORIES.find((c) => c.id === cat)?.label.toLowerCase()} nearby`}>
        <NearbyList
          fallbackOrigin={FALLBACK}
          places={filtered}
          emptyLabel="No places in this category nearby."
        />
      </Section>
    </Screen>
  );
}
