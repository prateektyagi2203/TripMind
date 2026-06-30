import { createFileRoute } from "@tanstack/react-router";
import { Send, Sparkles } from "lucide-react";
import { Screen, ScreenHeader } from "@/components/screen";

export const Route = createFileRoute("/_app/concierge")({
  head: () => ({ meta: [{ title: "AI Concierge · TripMind" }] }),
  component: ConciergeScreen,
});

const suggestions = [
  "Plan a relaxed day in Bangkok",
  "Best Indian restaurants near my hotel",
  "Translate this menu",
  "What's the weather like next week?",
];

function ConciergeScreen() {
  return (
    <Screen className="flex flex-col">
      <ScreenHeader
        title="AI Concierge"
        subtitle="Knows your trip inside out"
        right={
          <span className="grid h-9 w-9 place-items-center rounded-full gradient-sunset text-white">
            <Sparkles className="h-4 w-4" />
          </span>
        }
      />
      <div className="flex-1 space-y-4 px-5 py-5">
        <div className="rounded-3xl border border-border bg-card p-4 shadow-soft">
          <p className="text-xs uppercase tracking-[0.16em] text-muted-foreground">
            Concierge
          </p>
          <p className="mt-2 text-sm leading-relaxed">
            Hi! I have your Thailand trip context loaded. I can plan your days,
            book taxis, translate, or surface hidden gems. What would you like
            to do?
          </p>
        </div>
        <div>
          <p className="mb-2 text-xs uppercase tracking-[0.16em] text-muted-foreground">
            Try
          </p>
          <div className="flex flex-wrap gap-2">
            {suggestions.map((s) => (
              <button
                key={s}
                className="rounded-full border border-border bg-card px-3 py-1.5 text-xs"
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>
      <div className="sticky bottom-20 mx-5 mb-4 grid grid-cols-[minmax(0,1fr)_auto] items-center gap-2 rounded-full border border-border bg-card p-1.5 pl-4 shadow-soft">
        <input
          className="bg-transparent text-sm outline-none placeholder:text-muted-foreground"
          placeholder="Ask anything about your trip…"
        />
        <button
          className="grid h-9 w-9 place-items-center rounded-full bg-sunset text-sunset-foreground"
          aria-label="Send"
        >
          <Send className="h-4 w-4" />
        </button>
      </div>
    </Screen>
  );
}
