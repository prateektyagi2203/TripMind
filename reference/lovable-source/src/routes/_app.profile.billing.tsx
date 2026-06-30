import { createFileRoute } from "@tanstack/react-router";
import { Screen, ScreenHeader } from "@/components/screen";
import { Check } from "lucide-react";

export const Route = createFileRoute("/_app/profile/billing")({
  component: BillingScreen,
});

function BillingScreen() {
  return (
    <Screen>
      <ScreenHeader title="Subscription" back="/profile" />
      <div className="px-5 pt-4">
        <div className="rounded-3xl gradient-sunset p-5 text-white shadow-soft">
          <p className="text-xs uppercase tracking-[0.16em] opacity-85">Current plan</p>
          <p className="mt-1 font-display text-3xl font-semibold">TripMind Pro</p>
          <ul className="mt-4 space-y-2 text-sm">
            {[
              "Unlimited trips & destination packs",
              "AI concierge with full context",
              "Family sharing up to 6",
              "Offline maps & translator",
            ].map((f) => (
              <li key={f} className="flex items-center gap-2">
                <Check className="h-4 w-4" /> {f}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </Screen>
  );
}
