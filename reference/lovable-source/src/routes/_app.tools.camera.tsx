import { createFileRoute } from "@tanstack/react-router";
import { Camera, Image as ImageIcon, Receipt, Scan } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/tools/camera")({
  component: CameraScreen,
});

function CameraScreen() {
  return (
    <Screen>
      <ScreenHeader title="Camera AI" back="/tools" />
      <div className="mx-5 mt-4 grid place-items-center rounded-3xl gradient-ocean p-10 text-white shadow-soft">
        <span className="grid h-20 w-20 place-items-center rounded-full bg-white/15">
          <Camera className="h-8 w-8" />
        </span>
        <p className="mt-3 font-display text-lg font-semibold">Point. Recognize.</p>
        <p className="mt-1 max-w-[16rem] text-center text-xs opacity-85">
          Identify landmarks, translate signs, scan receipts and boarding passes.
        </p>
        <button className="mt-4 rounded-full bg-white px-5 py-2 text-xs font-semibold text-foreground">
          Open camera
        </button>
      </div>
      <Section title="Modes">
        <div className="grid grid-cols-3 gap-3">
          {[
            { label: "Attraction", icon: ImageIcon },
            { label: "Receipt", icon: Receipt },
            { label: "Boarding", icon: Scan },
          ].map(({ label, icon: Icon }) => (
            <div
              key={label}
              className="flex flex-col items-center gap-2 rounded-2xl border border-border bg-card p-3 shadow-soft"
            >
              <Icon className="h-5 w-5 text-ocean" />
              <span className="text-[11px] font-medium">{label}</span>
            </div>
          ))}
        </div>
      </Section>
    </Screen>
  );
}
