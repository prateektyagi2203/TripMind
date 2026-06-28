# TripMind UI/UX Specification v2.0
## Design Language: Clean & Airy · Family Travel · Flutter

---

## Design System Tokens

### Color Palette

| Token               | Hex       | Usage                             |
|---------------------|-----------|-----------------------------------|
| `brand-red`         | #FF385C   | Primary CTAs, active states, FAB  |
| `brand-red-light`   | #FF6B6B   | Gradient pair, hover states       |
| `brand-red-tint`    | #FFF5F6   | Active pill bg, selected card bg  |
| `brand-red-border`  | #FFCDD2   | Active pill border                |
| `ai-dark`           | #1A1A2E   | AI Concierge header, dark cards   |
| `ai-deep`           | #16213E   | AI gradient end                   |
| `text-primary`      | #1A1A1A   | Headlines, card values            |
| `text-secondary`    | #555555   | Body, descriptions                |
| `text-muted`        | #888888   | Labels, metadata, captions        |
| `surface`           | #FFFFFF   | Cards, nav bar, sheets            |
| `background`        | #F7F7F7   | App background                    |
| `border`            | #F0F0F0   | Card borders (1.5px)              |
| `border-subtle`     | #F5F5F5   | Row dividers (1px)                |
| `input-bg`          | #F5F5F5   | Text field backgrounds            |
| `success`           | #2E7D32   | On time, synced, budget ok        |
| `success-bg`        | #E8F5E9   | Success badge background          |
| `warning`           | #F57F17   | Budget alert, delay               |
| `warning-bg`        | #FFF3E0   | Warning badge background          |
| `error`             | #FF3B30   | SOS button, critical error        |

### Typography Scale

| Role          | Size | Weight | Usage                         |
|---------------|------|--------|-------------------------------|
| Display       | 28px | 800    | Hero numbers, large values    |
| Headline      | 22px | 800    | Screen titles                 |
| Title         | 17px | 700    | Card headings                 |
| Section       | 15px | 700    | Section labels                |
| Body          | 14px | 400    | Descriptions, AI responses    |
| Caption       | 12px | 500    | Metadata, timestamps          |
| Label         | 11px | 700    | Uppercase eyebrows            |
| Micro         | 10px | 600    | Nav labels, category tags     |

Font: SF Pro Display (iOS) / Roboto (Android) via Flutter defaults.
Line height: 1.55 for body, 1.25 for headlines.

### Spacing System (8dp base)

| Token   | Value | Usage                              |
|---------|-------|------------------------------------|
| micro   | 4dp   | Icon gaps, badge offsets           |
| xs      | 8dp   | Inline element gaps                |
| sm      | 12dp  | Card internal spacing              |
| md      | 16dp  | Screen horizontal margins          |
| lg      | 20dp  | Header padding, section spacing    |
| xl      | 24dp  | Between major sections             |

### Corner Radii

| Token   | Value | Applied to                         |
|---------|-------|------------------------------------|
| sm      | 8dp   | Chips, badges, tags                |
| md      | 12dp  | Quick action buttons, inputs       |
| lg      | 16dp  | Small info cards (weather, hotel)  |
| xl      | 18dp  | Main content cards (flight, budget)|
| hero    | 20dp  | Pill filter tabs                   |
| full    | 24dp  | Avatars, FAB, nav AI button        |

---

## Screen Specifications

### HOME-001 — Dashboard

**Purpose:** Day-of travel command centre. Must surface critical info
without scrolling.

**Above-the-fold (no scroll):**
- Header: greeting + avatar + notification bell
- Active trip selector pill (destination flag + name + days away)

**Card order (scroll):**
1. AI Morning Briefing card (dark hero card)
2. Today's plan (horizontal scroll, timeline chips)
3. At a glance row (weather · hotel · family 3-up)
4. Flight card (hidden when no flights ±24h)
5. Budget card (ring + stats)
6. Quick actions row (AI · Translate · Cab · Camera · SOS)

**AI Briefing Card spec:**
- Background: gradient `ai-dark` → `ai-deep`
- Live AI dot animation (pulse, `brand-red` #FF385C)
- Headline: Day N + destination emoji
- Body: weather + first activity + departure tip + budget line
- Actions: "View full plan" (filled white) + "Ask AI" (ghost white)

**Trip pill spec:**
- Background: `brand-red-tint`, border: `brand-red-border`
- Shows: destination flag + trip name + dates + days countdown
- Tap: opens trip switcher bottom sheet

**Flight card:** Hidden when no flight within 24 hours of departure
or arrival. Shows: airline + flight no + route + countdown + status badge.

**Quick Actions:**
5 icons max. Order: AI Chat · Translate · CabHub · Camera · SOS.
SOS icon always last, always red.

---

### AI-001 — AI Concierge

**Purpose:** Natural language travel assistant with full trip awareness.

**Header:**
- Background: `ai-dark` → `ai-deep` gradient
- AI avatar (coral gradient circle, ✨ icon)
- Status: online (green dot) / offline (grey)
- Context strip: horizontal scrollable pills showing
  📍 location · ⛅ weather · 💰 budget · 👨‍👩‍👧‍👦 pax · 🏨 hotel

**Chat bubbles:**
- AI: white card, border `#F0F0F0`, radius 4px 18px 18px 18px
- User: `brand-red` gradient, radius 18px 4px 18px 18px
- Timestamps: 10px, `text-muted`

**Rich card types rendered inside chat:**
- `cab_comparison` — provider list with price + ETA + book deep-link
- `restaurant_list` — restaurant cards with rating + price + distance
- `budget_summary` — mini donut chart + category breakdown
- `weather_detail` — hourly forecast bars
- `expense_confirm` — amount + category + confirm/edit buttons
- `translation_result` — original + translated + phonetic

**Suggested chips:**
- Row below last AI message, horizontal scroll
- Auto-updated based on current itinerary context
- Examples: "Lunch near here" · "Exchange rate" · "Afternoon rain?" · "Scan menu"

**Input bar (sticky bottom):**
- Camera icon (left) → routes to camera flow
- Mic icon → voice input, Whisper STT (v1.1)
- Text field (pill, `input-bg`)
- Send button (coral gradient circle)

**Offline state:**
- Show offline banner (amber, top of chat)
- Disable send button for new queries
- Show last N cached messages
- Show "Using cached trip data" label on context strip

---

### EXP-001 — Expense Dashboard

**Purpose:** Real-time family budget tracking with auto-capture.

**Header:** Title "Expenses" + "+ Add" coral button + trip name sub

**Budget hero:**
- Left: SVG ring chart (58% fill in `brand-red`, track in `border`)
  - Centre: percentage used
- Right: 4-row stats table (total · spent · remaining · daily avg)

**Category tabs:**
- Horizontal scroll filter: All · 🍜 Food · 🚕 Transport · 🏖 Activities · 🛍 Shopping · 🏨 Hotel
- Active tab: `brand-red` fill, white text

**Category breakdown card:**
- Each row: icon (coloured square bg) + name + count + amount + inline bar
- Bars use category-specific colours (food=red, transport=blue,
  activity=green, shopping=purple)

**Transaction list:**
- Each row: category icon + merchant name + meta (date · source) + amount + tag
- Source tags: "SMS parsed ✓" · "Auto-captured" · "Receipt scan" · "Manual"
- Source tags inform the user how the expense was captured

**SMS/Auto-capture logic (display only):**
- Expenses captured from SMS shown with "SMS parsed ✓"
- Expenses from Grab/receipt OCR shown with "Auto-captured"
- This builds trust in the auto-capture feature

---

### TRIP-003 — Trip Details

**Purpose:** Master hub for a single trip.

**Tabs:** Overview · Flights · Hotels · Itinerary · Family · Memories

**Overview tab:**
- Hero: destination photo (from Destination Pack) with gradient overlay
- Trip name + dates + status badge (Planning / Active / Completed)
- Family members strip (avatars)
- Budget summary mini card
- Quick stats: N days · N flights · N activities

**Flights tab:**
- Each leg as a flight card
- Boarding pass accessible via tap
- Flight status badge (live for active flights)

**Family tab:**
- Member list with avatar + name + role (Admin / Member)
- Invite via link or contact
- Shared sync status indicator

---

### AUTH-002 — Welcome / Onboarding

**Purpose:** First impression. Minimal friction.

**Screen 1:** App logo + tagline "Your family travel companion" +
  "Continue with Google" (primary) + "Continue with Apple" + "Email"

**Onboarding flow (3 screens, skippable):**
1. "Plan your trip" — import flight/hotel booking
2. "Travel smarter" — AI concierge preview
3. "Track together" — family sharing preview

Each screen: full-bleed illustration (Destination Pack art) + 1 headline
+ 1 line body + dot progress + skip link.

---

## Navigation Architecture

**Bottom Nav (5 items):**
```
🏠 Home  ·  🗺 Explore  ·  [✨ AI FAB]  ·  💰 Expenses  ·  👤 Profile
```

AI button is elevated FAB (52×52dp, coral gradient, -24dp top offset).
Nav labels: 10px, `text-muted`. Active: `brand-red`.

**Navigation depth rule:** Max 3 taps to any feature from Home.

**Back navigation:** Always preserve scroll position and filter state.

**Global overlays (accessible anywhere):**
- Notification tray (bell icon, top right)
- Search (future)
- SOS (long-press on SOS quick action)

---

## Component Library

### TripCard
Props: icon, label, value, subtext, onTap
Variants: weather | hotel | flight | budget | family
Default padding: 14dp. Radius: 16dp. Border: 1.5px `border`.

### AiBriefingCard
Props: headline, body, actions[], isLoading
Always dark background. Never show partially loaded.
Loading state: skeleton shimmer on body text.

### FlightCard
Props: airline, flightNo, origin, destination, depTime, arrTime,
       terminal, gate, status, countdown
Status badge colours: on_time=success, delayed=warning, cancelled=error.

### BudgetRing
Props: totalThb, spentThb, size (sm=80, md=110, lg=140)
Ring stroke: 10dp. Colour: `brand-red`. Track: `border`.
Centre: percentage + "used" label.

### ConversationBubble
Props: role (ai|user), text, timestamp, cardType?, cardData?
If cardType present: render rich card below text bubble.

### SuggestedChipRow
Props: chips[] (icon, label, onTap)
Auto-refreshes when TripContext changes. Max 6 chips visible.

### QuickActionButton
Props: icon, label, onTap, variant (default|danger)
Danger variant: `error` red border + icon colour.

---

## Interaction Patterns

**Bottom sheets:** Use for: trip switcher, expense details, restaurant info.
  - Always draggable, always dismissible by swipe.
  - Max height: 80% of screen.

**Skeleton loaders:** Show for all async card loads (flights, weather,
  AI briefing). Never show empty white card while loading.

**Pull to refresh:** Home dashboard, Expense list, AI context strip.

**Haptic feedback:**
  - Light: nav tap, chip select
  - Medium: expense logged, itinerary item checked off
  - Heavy: SOS triggered, flight status changed

**Offline indicator:** Amber banner at top of affected screens.
  Text: "You're offline. Showing cached trip data."

---

## Accessibility

- Minimum touch target: 44×44dp
- All icons have semantic labels for screen readers
- Body text minimum 14px; captions minimum 11px
- Contrast ratio ≥ 4.5:1 for all text
- Support Dynamic Type (iOS) / Font Scale (Android)
- Reduce Motion: disable all animations except loaders

---

*Version 2.0 — Replaces Batch 6 UI/UX Specifications (14 files)*
*Designed for: Flutter + Material 3 + Riverpod*
*Last updated: June 2026*
