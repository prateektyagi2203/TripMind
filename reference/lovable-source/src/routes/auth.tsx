import { createFileRoute, Link } from "@tanstack/react-router";
import { Apple, Mail } from "lucide-react";

export const Route = createFileRoute("/auth")({
  head: () => ({ meta: [{ title: "Sign in · TripMind" }] }),
  component: AuthScreen,
});

function AuthScreen() {
  return (
    <div className="mx-auto flex min-h-dvh w-full max-w-md flex-col bg-background px-6 pb-10 pt-16">
      <div className="flex-1">
        <p className="text-xs uppercase tracking-[0.2em] text-muted-foreground">
          TripMind
        </p>
        <h1 className="mt-2 font-display text-4xl font-semibold leading-[1.05]">
          Your trips, beautifully remembered.
        </h1>
        <p className="mt-3 text-sm text-muted-foreground">
          Plan, travel, and replay every journey with one calm companion built
          for families.
        </p>
      </div>
      <div className="space-y-3">
        <Link
          to="/"
          className="grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-full bg-primary px-5 py-3 text-primary-foreground"
        >
          <Mail className="h-4 w-4" />
          <span className="text-center text-sm font-semibold">Continue with email</span>
          <span className="h-4 w-4" />
        </Link>
        <Link
          to="/"
          className="grid w-full grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 rounded-full bg-foreground px-5 py-3 text-background"
        >
          <Apple className="h-4 w-4" />
          <span className="text-center text-sm font-semibold">Continue with Apple</span>
          <span className="h-4 w-4" />
        </Link>
        <Link
          to="/onboarding"
          className="block py-2 text-center text-xs text-muted-foreground underline"
        >
          New to TripMind? Take the tour
        </Link>
      </div>
    </div>
  );
}
