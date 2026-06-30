import { createFileRoute } from "@tanstack/react-router";
import { Screen, ScreenHeader, EmptyState } from "@/components/screen";
import { Users } from "lucide-react";

export const Route = createFileRoute("/_app/profile/family")({
  component: () => (
    <Screen>
      <ScreenHeader title="Family & sharing" back="/profile" />
      <div className="px-5 pt-4">
        <EmptyState
          icon={<Users className="h-5 w-5" />}
          title="Invite your travel circle"
          description="Share trips, expenses, and itineraries with family in real-time."
        />
      </div>
    </Screen>
  ),
});
