import { createFileRoute } from "@tanstack/react-router";
import { UserPlus } from "lucide-react";
import { Section } from "@/components/screen";
import { familyMembers } from "@/lib/mock-data";

export const Route = createFileRoute("/_app/trip/$tripId/family")({
  component: FamilyScreen,
});

function FamilyScreen() {
  return (
    <div className="pb-6">
      <Section
        title="Travelers"
        action={
          <button className="inline-flex items-center gap-1 rounded-full bg-sunset px-3 py-1.5 text-xs font-medium text-sunset-foreground">
            <UserPlus className="h-3.5 w-3.5" /> Invite
          </button>
        }
      >
        <div className="rounded-3xl border border-border bg-card shadow-soft">
          {familyMembers.map((m, i) => (
            <div
              key={m.id}
              className={`grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 px-4 py-3 ${
                i !== 0 ? "border-t border-border/60" : ""
              }`}
            >
              <span className="grid h-10 w-10 place-items-center rounded-full gradient-sunset text-sm font-semibold text-white">
                {m.initials}
              </span>
              <div className="min-w-0">
                <p className="truncate text-sm font-medium">{m.name}</p>
                <p className="text-[11px] text-muted-foreground">{m.role}</p>
              </div>
              <button className="rounded-full bg-secondary px-3 py-1.5 text-[11px] font-medium">
                Manage
              </button>
            </div>
          ))}
        </div>
      </Section>

      <Section title="Shared with family">
        <ul className="space-y-2 text-sm">
          {[
            "Live itinerary updates",
            "Flight & hotel reminders",
            "Shared expense ledger",
            "Photo album auto-sync",
          ].map((s) => (
            <li
              key={s}
              className="rounded-2xl border border-border bg-card px-4 py-3 shadow-soft"
            >
              {s}
            </li>
          ))}
        </ul>
      </Section>
    </div>
  );
}
