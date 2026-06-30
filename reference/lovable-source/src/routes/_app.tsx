import { createFileRoute, Outlet } from "@tanstack/react-router";
import { BottomNav } from "@/components/bottom-nav";

export const Route = createFileRoute("/_app")({
  component: AppLayout,
});

function AppLayout() {
  return (
    <div className="mx-auto min-h-dvh w-full max-w-md bg-background">
      <Outlet />
      <BottomNav />
    </div>
  );
}
