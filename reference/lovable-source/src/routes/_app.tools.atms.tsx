import { createFileRoute } from "@tanstack/react-router";
import { Screen, ScreenHeader, Section } from "@/components/screen";
import { NearbyList, type NearbyPlace } from "@/components/nearby-list";

export const Route = createFileRoute("/_app/tools/atms")({
  component: ATMsScreen,
});

// Anchor for synthetic positions when no GPS (Riva Arun, Bangkok).
const FALLBACK = { lat: 13.7461, lng: 100.4906 };

const ATMS: NearbyPlace[] = [
  {
    id: "atm-1",
    name: "Bangkok Bank ATM",
    category: "Bangkok Bank · No fee for partners",
    icon: "🏧",
    offsetKm: { north: 0.05, east: 0.08 },
    note: "24/7 · Inside 7-Eleven",
  },
  {
    id: "atm-2",
    name: "Kasikorn Bank ATM",
    category: "K-Bank · ฿220 foreign card fee",
    icon: "🏧",
    offsetKm: { north: -0.12, east: 0.15 },
    note: "Lobby of Riva Arun Hotel",
  },
  {
    id: "atm-3",
    name: "SCB Easy ATM",
    category: "Siam Commercial Bank",
    icon: "🏧",
    offsetKm: { north: 0.3, east: -0.2 },
    note: "Accepts Visa, Mastercard, UnionPay",
  },
  {
    id: "atm-4",
    name: "Krungsri ATM",
    category: "Bank of Ayudhya",
    icon: "🏧",
    offsetKm: { north: -0.4, east: 0.5 },
    note: "Drive-thru available",
  },
  {
    id: "atm-5",
    name: "AEON ATM",
    category: "Lowest withdrawal fee (฿150)",
    icon: "🏧",
    offsetKm: { north: 0.8, east: -0.6 },
    note: "Best for foreign cards",
  },
  {
    id: "atm-6",
    name: "TMB ATM",
    category: "TMBThanachart",
    icon: "🏧",
    offsetKm: { north: -0.9, east: -0.7 },
  },
];

function ATMsScreen() {
  return (
    <Screen>
      <ScreenHeader title="Nearby ATMs" subtitle="Cash withdrawal points around you" back="/tools" />
      <Section title="Closest first">
        <NearbyList fallbackOrigin={FALLBACK} places={ATMS} />
      </Section>
      <div className="px-5 pb-8">
        <p className="rounded-2xl bg-amber-500/10 p-3 text-[11px] text-amber-900">
          💡 Tip: AEON and Bangkok Bank ATMs usually charge the lowest foreign card fees in Thailand.
        </p>
      </div>
    </Screen>
  );
}
