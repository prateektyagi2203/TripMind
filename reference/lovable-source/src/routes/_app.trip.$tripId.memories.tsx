import { createFileRoute } from "@tanstack/react-router";
import { Camera } from "lucide-react";
import { Section } from "@/components/screen";
import { memories } from "@/lib/mock-data";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/_app/trip/$tripId/memories")({
  component: MemoriesScreen,
});

function MemoriesScreen() {
  return (
    <div className="pb-6">
      <Section
        title="Smart albums"
        action={
          <button className="inline-flex items-center gap-1 rounded-full bg-sunset px-3 py-1.5 text-xs font-medium text-sunset-foreground">
            <Camera className="h-3.5 w-3.5" /> Capture
          </button>
        }
      >
        <div className="grid grid-cols-2 gap-3">
          {memories.map((m) => (
            <div
              key={m.id}
              className="overflow-hidden rounded-2xl border border-border bg-card shadow-soft"
            >
              <div className={cn("h-32", m.thumbnail)} />
              <div className="p-3">
                <p className="truncate text-sm font-medium">{m.title}</p>
                <p className="text-[11px] text-muted-foreground">
                  Day {m.day} · {m.count} photos
                </p>
              </div>
            </div>
          ))}
        </div>
      </Section>
    </div>
  );
}
