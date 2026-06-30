import { createFileRoute } from "@tanstack/react-router";
import { Plus, Utensils, Car, ShoppingBag, Bed, Ticket, MoreHorizontal } from "lucide-react";
import { Section } from "@/components/screen";
import { expenses, type Expense } from "@/lib/mock-data";

export const Route = createFileRoute("/_app/trip/$tripId/expenses")({
  component: ExpensesScreen,
});

const iconFor: Record<Expense["category"], typeof Utensils> = {
  food: Utensils,
  transport: Car,
  shopping: ShoppingBag,
  lodging: Bed,
  activity: Ticket,
  other: MoreHorizontal,
};

function ExpensesScreen() {
  const total = expenses.reduce((s, e) => s + e.amountHome, 0);

  return (
    <div className="pb-6">
      <Section title="Spent so far">
        <div className="rounded-3xl gradient-ocean p-5 text-white shadow-soft">
          <p className="text-xs uppercase tracking-[0.16em] opacity-80">Total · USD</p>
          <p className="mt-1 font-display text-4xl font-semibold">
            ${total.toLocaleString()}
          </p>
          <div className="mt-4 grid grid-cols-3 gap-2 text-xs">
            <div className="rounded-xl bg-white/10 p-2">
              <p className="opacity-80">You</p>
              <p className="mt-0.5 font-semibold">$185</p>
            </div>
            <div className="rounded-xl bg-white/10 p-2">
              <p className="opacity-80">Priya</p>
              <p className="mt-0.5 font-semibold">$31</p>
            </div>
            <div className="rounded-xl bg-white/10 p-2">
              <p className="opacity-80">Group</p>
              <p className="mt-0.5 font-semibold">$92</p>
            </div>
          </div>
        </div>
      </Section>

      <Section
        title="Recent"
        action={
          <button className="inline-flex items-center gap-1 rounded-full bg-sunset px-3 py-1.5 text-xs font-medium text-sunset-foreground">
            <Plus className="h-3.5 w-3.5" /> Add
          </button>
        }
      >
        <div className="rounded-3xl border border-border bg-card shadow-soft">
          {expenses.map((e, i) => {
            const Icon = iconFor[e.category];
            return (
              <div
                key={e.id}
                className={`grid grid-cols-[auto_minmax(0,1fr)_auto] items-center gap-3 px-4 py-3 ${
                  i !== 0 ? "border-t border-border/60" : ""
                }`}
              >
                <span className="grid h-9 w-9 place-items-center rounded-2xl bg-secondary text-ocean">
                  <Icon className="h-4 w-4" />
                </span>
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium">{e.title}</p>
                  <p className="text-[11px] text-muted-foreground">
                    {e.date} · paid by {e.paidBy}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-sm font-semibold">
                    {e.currency} {e.amount.toLocaleString()}
                  </p>
                  {e.currency !== "USD" && (
                    <p className="text-[11px] text-muted-foreground">
                      ≈ ${e.amountHome}
                    </p>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </Section>
    </div>
  );
}
