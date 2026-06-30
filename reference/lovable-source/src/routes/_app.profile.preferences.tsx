import { createFileRoute } from "@tanstack/react-router";
import { Screen, ScreenHeader, EmptyState } from "@/components/screen";
import { Sliders } from "lucide-react";

export const Route = createFileRoute("/_app/profile/preferences")({
  component: () => (
    <Screen>
      <ScreenHeader title="Travel preferences" back="/profile" />
      <div className="px-5 pt-4">
        <EmptyState
          icon={<Sliders className="h-5 w-5" />}
          title="Tune your Travel DNA"
          description="Pace, cuisine, dietary needs, accessibility — your concierge adapts to it all."
        />
      </div>
    </Screen>
  ),
});
