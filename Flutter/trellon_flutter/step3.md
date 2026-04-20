# Design System Specification: High-End Digital Workspace

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Lucid Sanctuary."** 

This system rejects the cluttered, line-heavy aesthetic of traditional productivity tools in favor of an editorial-grade clarity. It is defined by "Air" and "Light." We move beyond standard UI by treating every screen as a composition of layered light. By utilizing generous white space, intentional asymmetry in card layouts, and a sophisticated light blue palette, we create an environment that feels cognitively effortless and premium. The design breaks the "template" look by avoiding rigid boxes; instead, it uses tonal depth to guide the eye, ensuring the interface feels organic rather than mechanical.

---

## 2. Colors
Our palette is rooted in a spectrum of sophisticated blues and atmospheric neutrals. The goal is to create a UI that feels like a singular, cohesive surface.

### Core Palette (Material Convention)
*   **Primary Focus:** `primary: #1A56DB` (Matches `primary_color_hex` from theme)
*   **Neutral Base:** `surface: #ffffff` (Matches `neutral_color_hex` from theme)
*   **Surface Hierarchy:** `surface_container_lowest: #ffffff` (Matches `secondary_color_hex` from theme) to `surface_container_highest: #e1e3e4`
*   **Accents:** `tertiary: #852b00` (Use sparingly for high-alert or urgent highlights)

### The "No-Line" Rule
Explicitly prohibit 1px solid borders for sectioning or card definition. Boundaries must be defined solely through background color shifts. For example, a card (`surface_container_lowest`) sitting on a page background (`surface`) provides all the definition required. If a transition feels "mushy," increase the contrast between the surface tiers rather than adding a stroke.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. 
*   **Level 0 (Base):** `surface` or `surface_container_low` for the main background.
*   **Level 1 (Intermediary):Tonal layering is used.
*   **Level 2 (Priority):** `surface_container_lowest` (#ffffff) for primary content cards and message notifications to make them "pop" forward.

### The "Glass & Gradient" Rule
To elevate the experience, use **Glassmorphism** for floating elements (like bottom navigation bars or modal overlays). Apply a 70% opacity to your `surface` token combined with a `backdrop-blur` of 20px. Use subtle gradients for primary CTAs, transitioning from `primary` (#1A56DB) at a 135-degree angle to provide a sense of "soul" and depth.

---

## 3. Typography
The system uses a pairing of **Manrope** (Display/Headlines) and **Inter** (Body/UI) to balance editorial authority with technical precision.

*   **Display & Headline (Manrope):** High-contrast sizing. `display-lg` (3.5rem) should be used for empty states or "hero" greetings to create a bold, modern entry point.
*   **Title & Body (Inter):** `title-md` (1.125rem) is the workhorse for notification headers. `body-md` (0.875rem) ensures high information density without sacrificing legibility.
*   **Labels (Inter):** Used for timestamps and metadata. `label-sm` (0.6875rem) should always be in `on_surface_variant` (#434654) to maintain hierarchy.

---

## 4. Elevation & Depth
Depth is communicated through **Tonal Layering**, not structural lines.

*   **The Layering Principle:** Stacking tiers is mandatory. A message card (`surface_container_lowest`) must sit atop a slightly darker section (`surface_container_low`) to create a natural lift.
*   **Ambient Shadows:** For "floating" components like FABs or active modals, use ultra-diffused shadows. 
    *   *Shadow Specs:* `y: 8px, blur: 24px, color: rgba(25, 28, 29, 0.06)`. 
    *   Never use pure black for shadows; always use a transparent version of `on_surface`.
*   **The "Ghost Border" Fallback:** If accessibility requirements demand a container edge, use a **Ghost Border**: `outline_variant` (#c3c5d7) at 15% opacity. Never use 100% opaque borders.

---

## 5. Components

### Cards (Notifications/Messages)
*   **Container:** Background: `surface_container_lowest` (#ffffff); Radius: `full` (Matches `roundedness` from theme).
*   **Layout:** No dividers between messages. Use 16px of vertical padding and 12px of margin between cards.
*   **Accent:** Use a 4px vertical pill of `primary` (#1A56DB) on the far left or right to indicate "Unread" status.

### Buttons
*   **Primary:** Gradient fill (`primary`), `full` (Matches `roundedness` from theme), `on_primary` text.
*   **Secondary/Chip:** `surface_container_high` background, no border, `on_surface` text. Used for "Filter" states as seen in the Reference Image.

### Input Fields
*   **Styling:** Fill with `surface_container_low`, `sm` (0.5rem) corner radius. 
*   **States:** On focus, transition background to `surface_container_lowest` and apply the "Ghost Border."

### Navigation (Bottom Bar)
*   **Style:** `surface` (#ffffff) at 80% opacity with 20px blur. 
*   **Active State:** Use a soft pill highlight behind the icon using `primary_fixed` (#dbe1ff) with 50% opacity.

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical layouts for notification groups (e.g., varying the width of metadata tags).
*   **Do** leverage the `primary_fixed` (#dbe1ff) color for subtle background highlights behind icons or avatars.
*   **Do** ensure all interactive elements have a maximum corner radius, pill-shaped (Matches `roundedness` from theme).

### Don't
*   **Don't** use 1px dividers to separate items in a list. Use `1.5rem` of whitespace or a tonal shift instead.
*   **Don't** use pure black (#000000) for text. Use `on_surface` (#191c1d) to maintain the "soft" premium feel.
*   **Don't** use heavy "Drop Shadows." If an element needs to feel elevated, use tonal contrast first, ambient shadows second.