# Design System Document

## 1. Overview & Creative North Star: "The Orchestrated Workspace"
This design system moves away from the "generic productivity tool" aesthetic toward a **High-End Editorial Workspace**. While the objective is a functional Trello-style mobile experience, we avoid the "boxed-in" feeling of traditional kanban boards.

**Creative North Star: The Orchestrated Workspace**
Instead of a digital grid, we view the UI as a curated desk. We use intentional asymmetry in spacing and a sophisticated hierarchy of "surfaces" rather than structural lines. By utilizing the provided Material 3 token set, we create depth through tonal shifts (`surface-container` tiers) rather than heavy borders. The result is a signature experience that feels authoritative, breathable, and premium.

---

## 2. Colors & Surface Logic
Our palette is rooted in the high-contrast relationship between `primary` (#003d9b) and the `surface` ecosystem. We do not use color simply for decoration; we use it to define the "physicality" of the interface.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders (`outline`) for sectioning or card definition. Boundaries must be defined solely through background color shifts.
* **Application:** A task card (`surface-container-lowest`) should sit on a column background (`surface-container`), which itself sits on the global app background (`surface`).

### Surface Hierarchy & Nesting
We treat the UI as a series of stacked sheets. Depth is achieved by "stepping" through the container tokens:
* **Global Background:** `surface` (#f8f9fb)
* **Board Columns:** `surface-container` (#edeef0) or `surface-container-high` (#e7e8ea) to create a recessed "well" for cards.
* **Interactive Cards:** `surface-container-lowest` (#ffffff) to provide maximum "pop" and perceived elevation.
* **Modals/Overlays:** `surface-bright` (#f8f9fb) to draw focus.

### Signature Accents
To elevate the "Flat" requirement into "High-End," use the `surface-tint` (#0c56d0) at 5-8% opacity over white surfaces for active states. This adds a "chromatic depth" that feels custom and intentional.

---

## 3. Typography: The Editorial Voice
We use **Inter** as a precision instrument. The goal is to move away from "default" system looks by creating extreme contrast between high-level titles and functional labels.

* **Display & Headline (The Brand Voice):** Use `headline-sm` (1.5rem) for board titles. This provides an editorial, magazine-like header that makes the workspace feel permanent and important.
* **Title (The Structural Voice):** `title-sm` (1rem / 16px) is reserved for Column Headers and Card Titles. It must be set to Medium or Bold weight to ensure scannability.
* **Body (The Content Voice):** `body-md` (0.875rem / 14px) is the workhorse for card descriptions and comments.
* **Labels (The Utility Voice):** `label-md` and `label-sm` are used for metadata (dates, tags). These should use `on-surface-variant` (#434654) to recede visually, ensuring they don't compete with the primary task text.

---

## 4. Elevation & Depth
In this system, "Elevation" is a color property, not just a shadow property.

* **The Layering Principle:** Depth is achieved by stacking. A `primary-container` (#0052cc) button should sit on a `surface-container-lowest` (#ffffff) card. The color delta provides all the "lift" required.
* **Ambient Shadows:** For floating action buttons or dragged cards, use **Atmospheric Shadows**.
* **Shadow Value:** Blur: 16px | Spread: 0 | Y: 4px.
* **Shadow Color:** Use `on-surface` (#191c1e) at exactly **6% opacity**. This mimics natural ambient light rather than a "drop shadow" effect.
* **The Ghost Border Fallback:** If a border is required for accessibility (e.g., in high-glare environments), use the `outline-variant` (#c3c6d6) at **20% opacity**. Never use a 100% opaque border.

---

## 5. Components

### Cards (The Core Primitive)
* **Structure:** No borders. `surface-container-lowest` background.
* **Corner Radius:** `lg` (0.5rem/8px) for cards; `md` (0.375rem/6px) for inner elements like tags.
* **Spacing:** Use `spacing-4` (1rem) for internal padding to ensure the text has a "gallery" feel.

### Buttons
* **Primary:** `primary-container` background with `on-primary` text. No shadow when resting; ambient shadow on press.
* **Tertiary (Ghost):** No background or border. Use `primary` text. These are used for "Add a card" actions to keep the interface uncluttered.

### Inputs & Fields
* **Styling:** Use `surface-container-low` (#f3f4f6) as the fill color.
* **Active State:** Instead of a thick border, use a 2px `primary` underline or a subtle `primary-fixed` (#dae2ff) glow.

### Lists & Columns
* **Spacing:** Prohibit divider lines. Use `spacing-3` (0.75rem) of vertical white space to separate items.
* **Nesting:** Columns should use the `surface-container` token to create a distinct "track" for cards to live in.

---

## 6. Do’s and Don’ts

### Do:
* **Use Tonal Shifts:** Distinguish a sidebar from a main board using `surface-dim` vs `surface`.
* **Embrace White Space:** Use the `20` (5rem) spacing scale at the bottom of lists to ensure the "Floating Action Button" never obscures content.
* **Intentional Asymmetry:** Align board titles to the far left, but keep action icons (search/filter) grouped with generous "breathing room" to the right.

### Don’t:
* **Don’t use #000000 for shadows:** Always use a tinted `on-surface` at low opacity.
* **Don’t use Dividers:** Never use a horizontal line to separate cards. If they feel too close, increase the spacing scale or darken the container background.
* **Don’t use Default Material Blue:** Only use the `primary` (#003d9b) or `primary-container` (#0052cc) tokens to maintain the Atlassian-inspired sophisticated palette.
* **Don’t use 100% Opaque Outlines:** This breaks the "Orchestrated Workspace" feel and makes the app look like a wireframe.