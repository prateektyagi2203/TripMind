import { createFileRoute } from "@tanstack/react-router";
import { Camera, Mic, Type } from "lucide-react";
import { Screen, ScreenHeader, Section } from "@/components/screen";

export const Route = createFileRoute("/_app/tools/translator")({
  component: TranslatorScreen,
});

function TranslatorScreen() {
  return (
    <Screen>
      <ScreenHeader title="Translator" back="/tools" />
      <Section title="How do you want to translate?">
        <div className="grid grid-cols-3 gap-3">
          {[
            { label: "Camera", icon: Camera },
            { label: "Voice", icon: Mic },
            { label: "Text", icon: Type },
          ].map(({ label, icon: Icon }) => (
            <button
              key={label}
              className="flex flex-col items-center gap-2 rounded-2xl border border-border bg-card p-4 shadow-soft"
            >
              <span className="grid h-10 w-10 place-items-center rounded-2xl gradient-sunset text-white">
                <Icon className="h-4 w-4" />
              </span>
              <span className="text-xs font-medium">{label}</span>
            </button>
          ))}
        </div>
      </Section>
      <Section title="Languages">
        <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-3">
          <button className="rounded-2xl border border-border bg-card px-3 py-3 text-left shadow-soft">
            <p className="text-[10px] uppercase text-muted-foreground">From</p>
            <p className="text-sm font-semibold">English</p>
          </button>
          <span className="text-xs text-muted-foreground">⇄</span>
          <button className="rounded-2xl border border-border bg-card px-3 py-3 text-left shadow-soft">
            <p className="text-[10px] uppercase text-muted-foreground">To</p>
            <p className="text-sm font-semibold">ไทย Thai</p>
          </button>
        </div>
        <div className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-soft">
          <p className="text-xs text-muted-foreground">Recent</p>
          <ul className="mt-2 space-y-2 text-sm">
            <li>"Where is the nearest pharmacy?"</li>
            <li>"Two waters, no ice please."</li>
            <li>"How much does this cost?"</li>
          </ul>
        </div>
      </Section>
    </Screen>
  );
}
