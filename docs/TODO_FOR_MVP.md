# TODO_FOR_MVP.md — Versimilitude (Godot) MVP Plan

This file is written for a new contributor / another AI agent joining mid-stream.

## Context
**Versimilitude** is a 2D, UI-first “corporate noir paperwork” game where the player assembles a *plausible* narrative from evidence. The rating is a deterministic, inspectable **imperfect rubric** that is *presented in-world* as “the AI.”

### MVP definition (current)
- Screens: **Intake (prep) → Interview → Outcome**
- A persistent **Evidence Board overlay** can be toggled from *any* screen (e.g., key **B**).
- Clicking highlighted text / objects in Intake or Interview **immediately spawns a new evidence “paper”** on the board.
- Board:
  - Papers are draggable.
  - Each paper has a visible **pin** at the top center; **strings (edges)** attach to that pin.
  - Player selects an edge type (colored string) and connects two papers.
- Submit conclusion from the board → deterministic “AI” rating → Outcome screen.

### Current status (already implemented)
- **Screen routing works** (Pattern A / dynamic screen instancing): ScreenManager swaps between screens.
- **Autoload state exists**: `AppState` stores pinned evidence and unique edges.
- Basic navigation: previously Inbox → Board → Outcome exists; MVP now replaces “Inbox” with **Intake**, and replaces “Board screen” with **Board overlay**.

---

## Conventions
- **Folders/files**: `snake_case`
- **Node names**: `PascalCase`
- Prefer decoupling via **signals** and/or **Node groups**, not hardcoded node paths.
- Keep the “AI” rubric deterministic (no LLM / network dependency in MVP).

---

## Target structure (recommended)
Adjust as needed, but keep “feature-local” scenes + scripts together.

```
res://
  autoload/
	app_state.gd

  main/
	main.tscn
	screen_manager.gd

  ui/
	screens/
	  intake/
		intake_screen.tscn
		intake_screen.gd
	  interview/
		interview_screen.tscn
		interview_screen.gd
	  outcome/
		outcome_screen.tscn
		outcome_screen.gd

	overlays/
	  evidence_board/
		evidence_board_overlay.tscn
		evidence_board_overlay.gd
		paper_card.tscn
		paper_card.gd
		edge_line.tscn            # optional: if you want a dedicated scene for strings

	components/                  # reusable UI widgets (future)
	theme/                       # theme/fonts (future)

  data/
	cases/
	  case_001/
		evidence.json            # 6 dummy evidence items for MVP
		dialogue.json            # dummy clickable dialogue lines for MVP (optional)

  assets/
	/art
	/studio
	/icons
```

---

# Work plan (small slices)

Each slice should be shippable. Don’t jump ahead—later slices assume earlier ones exist.

## Slice 0 — Rename “Inbox” → “Intake” + baseline project wiring - DONE
**Goal:** The project matches the MVP naming and doesn’t regress routing.

**Tasks**
- Rename files/scenes/scripts:
  - `inbox_screen.tscn/gd` → `intake_screen.tscn/gd`
  - Update any exported PackedScene assignments in the Inspector.
- Ensure main scene is set:
  - Project Settings → Application → Run → Main Scene = `res://main/main.tscn`
- Ensure `AppState` autoload is correct:
  - Project Settings → Autoload → `AppState` points at `res://autoload/app_state.gd`

**Definition of done**
- Press Play → Intake loads first → can navigate to Interview → Outcome (even if empty).

---

## Slice 1 — Add Evidence Board overlay skeleton (toggle with B) - DONE
**Goal:** Evidence board exists as a **persistent overlay** that can be shown/hidden over any active screen.

**Tasks**
- Create `evidence_board_overlay.tscn` as a `CanvasLayer` (draws above screens).
  - Child `Panel` (or `NinePatchRect`) as the board background.
  - Start hidden (off-screen above top).
- In `main.tscn`, keep **both**:
  - `ScreenManager` (existing)
  - `EvidenceBoardOverlay` (always loaded)
- Add Input Map action:
  - `toggle_board` bound to key `B`
- Implement show/hide slide animation:
  - Use `Tween` or `AnimationPlayer` to move the board panel from hidden → visible.

**Implementation notes**
- Prefer handling input in the overlay with `_unhandled_input(event)` and calling `accept_event()` when toggled.

**Definition of done**
- Running the game: pressing **B** reliably slides the board down/up over any screen.

---

## Slice 2 — Dummy evidence catalog (6 items) - DONE
**Goal:** A single source of truth for evidence definitions, easy to replace with real story later.

**Tasks (choose one approach)**
- **JSON approach (recommended for MVP):**
  - Create `res://data/cases/case_001/evidence.json` with 6 entries:
	- `id`, `title`, `body` (optional), `source` (Intake/Interview), etc.
  - Add helper loader function (either in `AppState` or a small `evidence_db.gd` utility).
- Or **hardcoded approach** (fastest): an array in a script.

**Definition of done**
- Code can request evidence by `id` and get a consistent `Dictionary` payload.

---

## Slice 3 — Click-to-spawn evidence from Intake - DONE
**Goal:** Intake has clickable dummy objects/text that spawn evidence papers on the board.

**Tasks**
- Build Intake UI minimally:
  - 6 clickable items total (e.g., Buttons/Links), each mapped to an evidence id.
- On click:
  - Call `AppState.pin_evidence(evidence_dict)`
  - Tell the overlay to spawn a paper card for that evidence id.

**How screens talk to the overlay (recommended)**
- Put `EvidenceBoardOverlay` node into group: `"evidence_board"`
- Intake calls:
  - `get_tree().call_group("evidence_board", "spawn_paper", evidence_id)`

**Definition of done**
- Clicking any dummy evidence item:
  - Adds it to `AppState.pinned_evidence`
  - Spawns a visible paper on the board (even if board is currently hidden; it should appear next time board opens).

---

## Slice 4 — PaperCard visuals + scatter placement + dragging - DONE
**Goal:** Evidence appears as paper “cards,” placed with slight randomness, draggable on the board.

**Tasks**
- Create `paper_card.tscn` (`Control`) with:
  - Paper background (Panel/NinePatchRect)
  - Title label, optional body preview
  - **Pin hotspot** at top center (TextureButton recommended)
- Implement dragging:
  - Click and drag anywhere on the paper (or on a drag handle).
  - While dragging, move the card within the board panel.
- Scatter placement:
  - New cards spawn in a “spawn zone” rectangle on the board with random jitter.
  - Avoid spawning directly under existing cards (simple nudge loop is fine).

**Definition of done**
- Spawning evidence produces a paper card.
- Cards can be dragged around smoothly.

---

## Slice 5 — Pin hotspot + “connect mode” UX scaffold (no pin image) - DONE
**Goal:** Player has a clear place to click to connect strings: the pin at top center.

**Tasks**
- Pin hotspot emits `pin_clicked(evidence_id)` from `PaperCard`.
- Overlay listens to each card’s signal and runs connect logic:
  - Maintain `selected_a_id` (or `null` if none).
  - First pin click selects A (visual highlight).
  - Second pin click selects B → attempts to create an edge.

**Definition of done**
- Clicking pin on card A then pin on card B triggers “edge attempt” (even if we don’t draw it yet).

---

## Slice 6 — Edge types + colored strings (visual Line2D) - DONE
**Goal:** Player chooses an edge type; connecting papers draws a colored string between pins.

**Tasks**
- Add a small top bar on the overlay with 2–4 edge type buttons:
  - e.g., `POLICY`, `MOTIVE`, `MEANS`, `OPPORTUNITY`
- Store current edge type selection in overlay state.
- On edge creation:
  - Call `AppState.add_edge(a_id, b_id, edge_type)` (must stay unique).
  - If added, create a `Line2D` (or dedicated `EdgeLine` scene) and render it.
- **Critical:** lines must update when cards move.
  - Simplest: overlay `_process` updates endpoints each frame.
  - Better: update on drag events.

**Definition of done**
- Selecting edge type changes the string style/color.
- Creating an edge draws a line from pin-to-pin.
- Moving either paper updates the line endpoint.

---

## Slice 7 — Interview screen with dummy clickable dialogue evidence
**Goal:** Interview is a second source of clickable evidence/text.

**Tasks**
- Create `interview_screen.tscn` with:
  - Dummy dialogue text lines (Labels + Buttons, or RichTextLabel w/ clickable meta).
  - At least 3 clickable lines that spawn evidence ids (from the same catalog).
- Ensure the overlay toggle still works.

**Definition of done**
- You can navigate Intake → Interview.
- Clicking dialogue lines spawns new papers on the board.

---

## Slice 8 — “Formulate conclusion” + deterministic AI rating
**Goal:** Clicking Submit computes a deterministic rating and moves to Outcome.

**Tasks**
- Add “Formulate Conclusion” button on the board overlay.
- Implement rubric function (deterministic) using current state:
  - Inputs: number of pinned evidence, number of edges, variety of edge types, simple “coherence” heuristic, etc.
  - Output: 2–3 numbers (or categories) + a single grade string.
- Store results in `AppState` (e.g., `last_run_result`) or pass to Outcome screen.
- Navigate to Outcome screen.

**Definition of done**
- Submit from board → Outcome shows a rating and short feedback memo.
- The same board state always yields the same rating.

---

## Slice 9 — Outcome screen UI + restart loop
**Goal:** MVP can be replayed quickly.

**Tasks**
- Outcome displays:
  - “AI rating” label
  - A short performance memo (comedic corporate tone)
  - Optional: 3 categories (Coherence/Compliance/Usefulness)
- Add buttons:
  - “Restart Day” → `AppState.reset_day()` → navigate to Intake
- Ensure board overlay is hidden on Outcome by default (optional but recommended).

**Definition of done**
- Full loop: Intake → Interview → (toggle board) → spawn evidence → connect → submit → Outcome → restart.

---

# Nice-to-haves (only after the loop works)
- Board open/close has sound + easing polish.
- Better spawn scatter (avoid overlap more robustly).
- Visual feedback: highlight selected card A, highlight invalid edge attempts.
- “Edge delete” (right-click a string or card).
- Minimal save/load stub (not required for MVP).

---

# Debug checklist (common Godot footguns)
- After moving/renaming scenes, re-assign `@export PackedScene` fields in the Inspector.
- Confirm `toggle_board` exists in Input Map.
- Ensure `EvidenceBoardOverlay` is in the `"evidence_board"` group.
- If strings don’t follow cards, confirm you’re using **global** vs **local** positions consistently when setting `Line2D.points`.
