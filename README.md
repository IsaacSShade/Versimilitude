# Versimilitude
A story-driven corporate-noir paperwork game set on a company-owned O’Neill Cylinder, where **there is no real mystery**—but you get promoted (up to CEO) for **manufacturing one** that the company finds compelling and useful.

<img width="9600" height="3600" alt="Title Card" src="https://github.com/user-attachments/assets/0306d914-34d1-4629-82d7-ffa22a8b838a" />

## Inspirations
- **World of Goo 2 (Chapter 4)** — the *primary* tonal inspiration: corporate-noir aesthetics played for comedy and absurd bureaucracy, where the characters are dark and mysterious -we’re doing the opposite with comedic characters, dark and mysterious world.
- **Date Everything** — route/character-driven structure; daily choices of who to engage; storylines can intertwine.
- **Papers, Please** — day-based cadence; bureaucratic UI; rules/policy; score + consequences loop.
- **Shadows of Doubt** — “red string” evidence board; players connect facts to form narratives.

## Core concept
You were hired as an “Investigator” because the company’s AI hiring system was trained on old noir media to detect “investigative talent” instead of real competence.

Your job isn’t to uncover truth — it’s to assemble **plausible corporate narratives** from evidence, then submit “Conclusions” that justify corporate action.

## MVP flow
**Title → Intake → Interview → Outcome**

## Core loop (day cadence)
1. **Inbox / Briefing** — memos, alerts, policy updates, performance feedback.
2. **Pre-interview review** (later) — inspect a “company computer” (emails/logs/search) and pin artifacts.
3. **Interview** — dialogue that can itself become evidence.
4. **Vision Board** — pin evidence + draw **typed edges** (Motive/Means/Opportunity/Policy/etc.).
5. **Submit Finding** — pick from unlocked conclusion templates (not freeform).
6. **Outcome** — consequences + feedback (promotion/discipline, access changes, habitat impacts).

## Proof-of-concept scope (POC v0)
A single playable “day” proving:
- the board overlay + pin/string vibe,
- evidence spawning from UI interactions,
- a deterministic (inspectable) scoring/outcome system (next).

Minimum v0 target:
- One interview (can be linear initially)
- ~6 evidence items available to pin
- Create at least one connection between two pinned papers
- Submit finding → show score breakdown + one of a few outcomes

---

# Current status

## Working now
- ✅ **Screen navigation** via `ScreenManager` (PackedScene swapping):
  - **Title → Intake → Interview → Outcome**
- ✅ **Title sequence (MVP)**:
  - Start menu (single **Start** option)
  - Fade in/out
  - Non-looping intro track plays during title (maybe change later)
- ✅ **Evidence system backbone**:
  - Evidence catalog loaded from JSON (`case_001/evidence.json`)
  - `EvidenceDb` autoload loads/queries evidence
  - `AppState` autoload tracks pinned evidence + instance edges
- ✅ **Evidence Board overlay** (always loaded in `main.tscn`):
  - Toggle with input action `"toggle_board"` (bound to **B**)
  - Clicking evidence in Intake can spawn papers even if the board is hidden
  - Pin-to-pin string connections render and update

## Next steps (near-term)
- Typed edge selection UI (Motive / Means / Opportunity / Policy / etc.)
- “Submit Finding” UI + deterministic scoring + outcome screen content
- Better board UX (selection states, delete edge, reorder, polish)

---

# Controls (current)
- **B** — Toggle Evidence Board (gameplay screens only)
- **Click evidence hotspots** (Intake, later Interview) — Spawn evidence paper to board
- **Click pin on a paper** — Select / connect pins (current: basic connection)

---


# Getting started

## Requirements
- **Godot 4.x** (project created in Godot 4; check `project.godot` if you need the exact version)

## Run the game
1. Open the project in Godot.
2. Ensure the main scene is set to `res://main/main.tscn` (Project Settings → Application → Run → Main Scene).
3. Press **F5** (Run Project).

---

# Project structure

```text
res://
  autoload/                 # Global singletons (shared state)
    app_state.gd            # pinned evidence + edges, day/case state
    evidence_db.gd          # loads case JSON + query helpers

  docs/                     # Design notes / PRD / pitch docs
    BASIC_PITCH_AND_MVP_PLAN.md

  main/                     # Bootstrapping + routing + always-loaded overlays
    main.tscn               # root scene (includes Evidence Board overlay)
    screen_manager.gd       # swaps PackedScene screens at runtime

  ui/  
    screens/                  # “Pages” of the game (each screen is its own scene + script)
    title/                  # Title screen + intro music + Start menu
    intake/                 # Intake 
    interview/
    outcome/

  data/                     # Authored case data (JSON/Resources)
    case_001/
      evidence.json

  assets/                   # Art/audio/etc.

  icon.svg
  README.md
