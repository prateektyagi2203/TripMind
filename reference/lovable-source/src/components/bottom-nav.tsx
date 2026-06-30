import { Link, useRouterState } from "@tanstack/react-router";
import { Compass, Home, Sparkles, User, Wrench } from "lucide-react";
import { cn } from "@/lib/utils";

const items = [
  { to: "/", label: "Trips", icon: Home, match: (p: string) => p === "/" || p.startsWith("/trip") },
  { to: "/explore", label: "Explore", icon: Compass, match: (p: string) => p.startsWith("/explore") },
  { to: "/tools", label: "Tools", icon: Wrench, match: (p: string) => p.startsWith("/tools") },
  { to: "/concierge", label: "AI", icon: Sparkles, match: (p: string) => p.startsWith("/concierge") },
  { to: "/profile", label: "Me", icon: User, match: (p: string) => p.startsWith("/profile") },
] as const;

export function BottomNav() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  return (
    <nav className="fixed inset-x-0 bottom-0 z-40 border-t border-border/60 surface-glass">
      <div className="mx-auto grid max-w-md grid-cols-5 px-2 pb-[max(0.5rem,env(safe-area-inset-bottom))] pt-2">
        {items.map(({ to, label, icon: Icon, match }) => {
          const active = match(pathname);
          return (
            <Link
              key={to}
              to={to}
              className={cn(
                "flex flex-col items-center gap-1 rounded-2xl py-1.5 text-[11px] font-medium transition-colors",
                active ? "text-ocean" : "text-muted-foreground",
              )}
            >
              <span
                className={cn(
                  "grid h-9 w-9 place-items-center rounded-2xl transition-all",
                  active ? "bg-ocean/10 text-ocean" : "bg-transparent",
                )}
              >
                <Icon className="h-[18px] w-[18px]" strokeWidth={active ? 2.4 : 2} />
              </span>
              {label}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
