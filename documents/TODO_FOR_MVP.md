# TODO_FOR_MVP.md - Versimilitude (Godot) MVP Plan

This file is written for a new contributor or another AI agent joining mid-stream.

It should preserve context and project history, not just task status. When updating this file, prefer modifying the relevant sections in place instead of replacing them with a shorter summary.

## Context
**Versimilitude** is a 2D, UI-first corporate noir paperwork game where the player assembles a *plausible* narrative from evidence. The rating is a deterministic, inspectable **imperfect rubric** that is *presented in-world* as "the AI."

### MVP definition (current)
- Screens: **Intake (prep) -> Interview -> Outcome**
- A persistent **Evidence Board overlay** can be toggled from any screen, currently on key **B**.
- Clicking highlighted text, evidence items, or dialogue in Intake/Interview should immediately spawn a new paper on the board.
- Board:
  - Papers are draggable.
  - Each paper has a visible **pin** at the top center; **strings (edges)** attach to that pin.
  - Player will eventually select an edge type and connect two papers.
- Submit conclusion from the board -> deterministic "AI" rating -> Outcome screen.

### Current status (already implemented)
- **Screen routing works** (Pattern A / dynamic screen instancing): `ScreenManager` swaps between screens.
- **Autoload state exists**: `AppState` stores generic pinned board entries and unique instance edges.
- **Evidence DB exists**: `EvidenceDb` loads case evidence from JSON and can convert evidence records into generic board-entry dictionaries.
- **Evidence Board overlay exists**:
  - Toggle with **B**
  - Spawn paper cards from Intake and Interview
  - Drag cards around the board
  - Click pin-to-pin to create string connections
- **Interview flow exists**:
  - Driven by Ink-style source files
  - Uses a lightweight local runner, not a full external Ink runtime
  - Supports branching choices
  - Supports pinnable dialogue
  - Keeps the interviewee on screen while side speakers can enter temporarily
- **Outcome screen exists**, but the deterministic board submission/rating loop is still not implemented.

### Important current design direction
- Prefer **modifying** existing systems over adding parallel replacements.
- If something is superseded, remove or fold the older path instead of carrying both forever.
- Keep the board/data model future-proof enough for evidence, dialogue, and later policy/person/location cards.

---

## Conventions
- **Folders/files**: `snake_case`
- **Node names**: `PascalCase`
- Prefer decoupling via **signals** and/or **Node groups**, not hardcoded node paths.
- Keep the "AI" rubric deterministic. No network dependency in MVP.

---

## Target structure (recommended)
Adjust as needed, but keep authored content separate from runtime code and keep feature-local scenes/scripts together where that helps.

```text
res://
  autoload/
	app_state.gd
	evidence_db.gd

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
		edge_line.tscn

  data/
	cases/
	  case_001/
		evidence.json
		dialogue/
		  characters.json
		  interview_bob.ink

  systems/
	dialogue/
	  ink_story_runner.gd

  addons/
	ink_filesystem/
	  plugin.cfg
	  plugin.gd
```

### Notes about the current codebase
- Evidence is already in `res://data/cases/.../evidence.json`.
- Dialogue authoring belongs under `res://data/cases/.../dialogue/`.
- The lightweight Ink-style runner is runtime code and should not live beside authored case data long-term.
- The `.ink` FileSystem visibility support is editor-only behavior and belongs in `addons/`.

---

# Work plan (small slices)

Each slice should be shippable. Do not jump ahead; later slices assume earlier ones exist.

Keep the history in this file. When something changes, update the relevant slice with:
- what was intended,
- what is actually done,
- what is still missing.

## Slice 0 - Rename "Inbox" -> "Intake" + baseline project wiring - DONE
**Goal:** The project matches the MVP naming and does not regress routing.

**Tasks**
- Rename files/scenes/scripts:
  - `inbox_screen.tscn/gd` -> `intake_screen.tscn/gd`
  - Update any exported `PackedScene` assignments in the Inspector.
- Ensure main scene is set:
  - Project Settings -> Application -> Run -> Main Scene = `res://main/main.tscn`
- Ensure `AppState` autoload is correct:
  - Project Settings -> Autoload -> `AppState` points at `res://autoload/app_state.gd`

**Definition of done**
- Press Play -> Intake loads first -> can navigate to Interview -> Outcome (even if mostly empty).

**Current reality**
- This slice is complete.

---

## Slice 1 - Add Evidence Board overlay skeleton (toggle with B) - DONE
**Goal:** Evidence board exists as a persistent overlay that can be shown/hidden over any active screen.

**Tasks**
- Create `evidence_board_overlay.tscn` as a `CanvasLayer`.
- In `main.tscn`, keep both:
  - `ScreenManager`
  - `EvidenceBoardOverlay`
- Add Input Map action:
  - `toggle_board` bound to key `B`
- Implement show/hide slide animation.

**Implementation notes**
- Prefer handling input in the overlay with `_unhandled_input(event)`.

**Definition of done**
- Running the game: pressing **B** reliably slides the board down/up over any screen.

**Current reality**
- This slice is complete.
- The overlay now also supports a large panning canvas for board space.
- Earlier zoom-based board behavior caused blurry text; board scaling has since been removed in favor of panning an unscaled UI canvas.

---

## Slice 2 - Dummy evidence catalog (6 items) - DONE
**Goal:** A single source of truth for evidence definitions, easy to replace with real story later.

**Tasks**
- JSON approach:
  - Create `res://data/cases/case_001/evidence.json`
  - Fields include `id`, `title`, `body`, `source`, etc.
- Add helper loader function in an autoload or utility.

**Definition of done**
- Code can request evidence by `id` and get a consistent dictionary payload.

**Current reality**
- This slice is complete.
- `EvidenceDb` loads evidence JSON and exposes lookup helpers.
- `EvidenceDb` also converts evidence into generic board-entry dictionaries so the board can support more than just evidence cards.

---

## Slice 3 - Click-to-spawn evidence from Intake - DONE
**Goal:** Intake has clickable dummy objects/text that spawn evidence papers on the board.

**Tasks**
- Build Intake UI minimally:
  - Clickable items mapped to evidence ids.
- On click:
  - Tell the overlay to spawn a paper card for that evidence id.

**How screens talk to the overlay**
- `EvidenceBoardOverlay` should be in group `"evidence_board"`
- Intake calls:
  - `get_tree().call_group("evidence_board", "spawn_paper", evidence_id)`

**Definition of done**
- Clicking any dummy evidence item:
  - Adds it to board state
  - Spawns a visible paper on the board

**Current reality**
- This slice is complete.
- Intake now routes through the generic board-entry path rather than maintaining a separate evidence-only path in UI logic.

---

## Slice 4 - PaperCard visuals + scatter placement + dragging - DONE
**Goal:** Evidence appears as paper cards, placed with slight randomness, draggable on the board.

**Tasks**
- Create `paper_card.tscn` (`Control`) with:
  - Paper background
  - Title label, optional body preview
  - Pin hotspot at top center
- Implement dragging:
  - Click and drag anywhere on the paper
  - Keep movement bounded to the board canvas
- Scatter placement:
  - Spawn in a visible area with jitter / offset
  - Avoid obvious overlap where possible

**Definition of done**
- Spawning evidence produces a paper card.
- Cards can be dragged around smoothly.

**Current reality**
- This slice is complete.
- Cards also support expanded/collapsed behavior.
- Cards currently default to expanded.
- Scrollbars were removed from the card body flow because they conflicted with the card drag interaction and felt dead in practice.

---

## Slice 5 - Pin hotspot + connect mode scaffold - DONE
**Goal:** Player has a clear place to click to connect strings: the pin at top center.

**Tasks**
- Pin hotspot emits `pin_clicked(...)` from `PaperCard`.
- Overlay listens and runs connect logic:
  - First pin click selects A
  - Second pin click selects B -> attempts edge creation

**Definition of done**
- Clicking pin on card A then pin on card B triggers an edge attempt.

**Current reality**
- This slice is complete.
- Existing UX is simple but functional.
- Selected-card visual feedback exists, but could be improved.

---

## Slice 6 - Edge types + colored strings (visual Line2D) - PARTIAL
**Goal:** Player chooses an edge type; connecting papers draws a colored string between pins.

**Tasks**
- Add a small top bar on the overlay with 2-4 edge type buttons:
  - e.g. `POLICY`, `MOTIVE`, `MEANS`, `OPPORTUNITY`
- Store current edge type selection in overlay state.
- On edge creation:
  - Call state method to add unique edge
  - If added, create a visual line
- Critical:
  - Lines must update when cards move

**Definition of done**
- Selecting edge type changes the string style/color.
- Creating an edge draws a line from pin-to-pin.
- Moving either paper updates the line endpoint.

**Current reality**
- Partially done.
- Lines draw between cards.
- They update when cards move.
- Edge uniqueness works.
- The missing piece is the player-facing edge-type selection flow and differentiated edge styling; the system still uses a default type at runtime.

---

## Slice 7 - Interview screen with pinnable dialogue - DONE
**Goal:** Interview is a second source of clickable evidence/text.

**Tasks**
- Create `interview_screen.tscn`
- Add dialogue content
- Support clickable / pinnable interview lines
- Ensure overlay toggle still works

**Definition of done**
- You can navigate Intake -> Interview.
- Clicking dialogue lines spawns new papers on the board.

**Current reality**
- This slice is complete, but evolved from the original MVP wording.
- Interview now uses Ink-style authored content instead of dummy dialogue JSON.
- Active authored content:
  - Bob interview
  - Two branches
  - Three spoken lines deep in each branch
- Dialogue pinning behavior:
  - Current spoken dialogue can be pinned by clicking the dialogue box
  - Dialogue remains pinnable even when the branch has ended and the button has changed to `Finish`
  - Linked evidence is stored as metadata only; the UI should not tell the player which lines are "real evidence"
- Staging behavior:
  - Interviewee remains on screen
  - Detective does not swap portrait
  - Side speakers such as VERA can appear temporarily

**Remaining polish**
- More authored interviews
- Stronger content validation / tooling for larger dialogue sets
- Better separation between authored case content and runtime code if file layout is adjusted

---

## Slice 8 - "Formulate conclusion" + deterministic AI rating - NOT DONE
**Goal:** Clicking Submit computes a deterministic rating and moves to Outcome.

**Tasks**
- Add "Formulate Conclusion" button on the board overlay.
- Implement rubric function using board state:
  - number of pinned items
  - number of edges
  - variety of edge types
  - simple coherence heuristic
- Output:
  - 2-3 numbers or categories
  - a final grade string
- Store result in `AppState` or equivalent
- Navigate to Outcome screen

**Definition of done**
- Submit from board -> Outcome shows a rating and short feedback memo.
- Same board state always yields the same rating.

**Current reality**
- Not done.
- This is still the main missing MVP loop.

---

## Slice 9 - Outcome screen UI + restart loop - PARTIAL
**Goal:** MVP can be replayed quickly.

**Tasks**
- Outcome displays:
  - AI rating label
  - short performance memo
  - optional 3-category summary
- Add restart button:
  - `AppState.reset_day()`
  - navigate to Intake
- Ensure board overlay is hidden appropriately

**Definition of done**
- Full loop: Intake -> Interview -> Board -> Submit -> Outcome -> Restart

**Current reality**
- Partial.
- Outcome screen exists.
- Real deterministic submit/rating data is not wired yet because Slice 8 is not implemented.
- Restart/day-loop validation should happen after Slice 8 is in place so the full loop can be tested end-to-end.

---

# Nice-to-haves (only after the loop works)
- Board open/close sound and easing polish.
- Better spawn scatter / overlap avoidance.
- Better visual feedback for invalid edge attempts.
- Edge delete UX.
- Minimal save/load stub.

---

# Cleanup still needed
- Keep consolidating stale MVP-era references as systems stabilize.
- Keep authored dialogue in `res://data/cases/.../dialogue/`.
- Keep runtime dialogue code separate from authored case content.
- Continue preferring modification of current systems over adding a second path unless the new path is clearly justified.

---

# Debug checklist (common Godot footguns)
- After moving/renaming scenes, re-assign exported `PackedScene` fields in the Inspector if needed.
- Confirm `toggle_board` exists in Input Map.
- Ensure `EvidenceBoardOverlay` is in the `"evidence_board"` group.
- If strings do not follow cards, confirm global vs local positions are used consistently when setting endpoints.
- If `.ink` files do not appear in the FileSystem dock, verify the editor plugin in `addons/ink_filesystem` is enabled.
