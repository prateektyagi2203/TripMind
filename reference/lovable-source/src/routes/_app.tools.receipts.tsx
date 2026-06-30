import { createFileRoute } from "@tanstack/react-router";
import { Camera } from "lucide-react";
import { Screen, ScreenHeader, EmptyState } from "@/components/screen";

export const Route = createFileRoute("/_app/tools/receipts")({
  component: ReceiptsScreen,
});

function ReceiptsScreen() {
  return (
    <Screen>
      <ScreenHeader title="Receipts" back="/tools" />
      <div className="px-5 pt-4">
        <EmptyState
          icon={<Camera className="h-5 w-5" />}
          title="No receipts yet"
          description="Snap a photo to auto-log expenses and split with family."
          action={
            <button className="rounded-full bg-sunset px-4 py-2 text-xs font-semibold text-sunset-foreground">
              Scan receipt
            </button>
          }
        />
      </div>
    </Screen>
  );
}
