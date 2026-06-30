import type { ReactNode } from "react";
import { Link } from "@tanstack/react-router";
import { ArrowLeft } from "lucide-react";
import { cn } from "@/lib/utils";

interface ScreenProps {
  children: ReactNode;
  className?: string;
}

export function Screen({ children, className }: ScreenProps) {
  return (
    <div className={cn("min-h-dvh pb-28 pt-safe", className)}>{children}</div>
  );
}

interface ScreenHeaderProps {
  title: string;
  subtitle?: string;
  back?: string | true;
  right?: ReactNode;
  large?: boolean;
}

export function ScreenHeader({ title, subtitle, back, right, large }: ScreenHeaderProps) {
  return (
    <header className="sticky top-0 z-30 surface-glass border-b border-border/60 px-5 py-3">
      <div className="grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3">
        {back ? (
          <Link
            to={typeof back === "string" ? back : ".."}
            className="grid h-9 w-9 place-items-center rounded-full bg-secondary text-secondary-foreground"
            aria-label="Back"
          >
            <ArrowLeft className="h-4 w-4" />
          </Link>
        ) : (
          <span className="h-9 w-9" />
        )}
        <div className="min-w-0 text-center">
          <h1
            className={cn(
              "truncate font-display font-semibold",
              large ? "text-2xl" : "text-base",
            )}
          >
            {title}
          </h1>
          {subtitle ? (
            <p className="truncate text-xs text-muted-foreground">{subtitle}</p>
          ) : null}
        </div>
        <div className="flex justify-end">{right ?? <span className="h-9 w-9" />}</div>
      </div>
    </header>
  );
}

interface SectionProps {
  title: string;
  action?: ReactNode;
  children: ReactNode;
  className?: string;
}

export function Section({ title, action, children, className }: SectionProps) {
  return (
    <section className={cn("px-5 py-4", className)}>
      <div className="mb-3 flex items-end justify-between gap-2">
        <h2 className="font-display text-lg font-semibold tracking-tight">{title}</h2>
        {action}
      </div>
      {children}
    </section>
  );
}

interface EmptyStateProps {
  icon?: ReactNode;
  title: string;
  description?: string;
  action?: ReactNode;
}

export function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center rounded-3xl border border-dashed border-border bg-card/50 px-6 py-10 text-center">
      {icon ? (
        <div className="mb-3 grid h-12 w-12 place-items-center rounded-2xl bg-secondary text-secondary-foreground">
          {icon}
        </div>
      ) : null}
      <p className="font-display text-lg font-semibold">{title}</p>
      {description ? (
        <p className="mt-1 max-w-xs text-sm text-muted-foreground">{description}</p>
      ) : null}
      {action ? <div className="mt-4">{action}</div> : null}
    </div>
  );
}
