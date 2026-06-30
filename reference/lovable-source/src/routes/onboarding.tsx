import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { ArrowRight, Compass, Sparkles, Users } from "lucide-react";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/onboarding")({
  component: OnboardingScreen,
});

const steps = [
  {
    icon: Compass,
    title: "One companion for every step",
    desc: "Flights, stays, itineraries, expenses, and memories — together at last.",
    gradient: "gradient-sunset",
  },
  {
    icon: Sparkles,
    title: "An AI that knows your trip",
    desc: "Plan a day, translate a menu, or find Indian food nearby in one ask.",
    gradient: "gradient-ocean",
  },
  {
    icon: Users,
    title: "Built for families",
    desc: "Share plans, expenses, and photo albums with everyone traveling.",
    gradient: "gradient-sunset",
  },
];

function OnboardingScreen() {
  const [i, setI] = useState(0);
  const step = steps[i];
  const last = i === steps.length - 1;
  const Icon = step.icon;

  return (
    <div className="mx-auto flex min-h-dvh w-full max-w-md flex-col bg-background">
      <div className={cn("flex-1 p-6", step.gradient)}>
        <div className="flex h-full flex-col items-start justify-end text-white">
          <span className="grid h-14 w-14 place-items-center rounded-3xl bg-white/15 backdrop-blur">
            <Icon className="h-6 w-6" />
          </span>
          <h1 className="mt-6 font-display text-3xl font-semibold leading-tight">
            {step.title}
          </h1>
          <p className="mt-3 max-w-sm text-sm opacity-90">{step.desc}</p>
        </div>
      </div>
      <div className="space-y-4 p-6">
        <div className="flex justify-center gap-1.5">
          {steps.map((_, idx) => (
            <span
              key={idx}
              className={cn(
                "h-1.5 rounded-full transition-all",
                idx === i ? "w-6 bg-foreground" : "w-1.5 bg-border",
              )}
            />
          ))}
        </div>
        {last ? (
          <Link
            to="/"
            className="grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-full bg-sunset px-5 py-3 text-sunset-foreground"
          >
            <span className="h-4 w-4" />
            <span className="text-center text-sm font-semibold">Get started</span>
            <ArrowRight className="h-4 w-4" />
          </Link>
        ) : (
          <button
            onClick={() => setI(i + 1)}
            className="grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-full bg-primary px-5 py-3 text-primary-foreground"
          >
            <span className="h-4 w-4" />
            <span className="text-center text-sm font-semibold">Next</span>
            <ArrowRight className="h-4 w-4" />
          </button>
        )}
      </div>
    </div>
  );
}
