# Versimilitude
A story-driven corporate-noir paperwork game set on a company-owned O’Neill Cylinder, where **there is no real mystery**—but you get promoted (up to CEO) for **manufacturing one** that the company finds compelling and useful.

## Inspirations
- **World of Goo 2 (Chapter 4)** — the *primary* tonal inspiration: corporate-noir aesthetics played for comedy and absurd bureaucracy, not grimdark grittiness.
- **Date Everything** — route/character-driven structure; daily choices of who to engage; storylines can intertwine.
- **Papers, Please** — day-based cadence; bureaucratic UI; rules/policy; score + consequences loop.
- **Shadows of Doubt** — “red string” evidence board; players connect facts to form narratives.

## Core concept
You were hired as an “Investigator” because the company’s AI hiring system learned **noir-coded competence** instead of real competence. Your job is to submit official “Findings” that justify corporate action.

**Truth is optional; plausibility is currency.**

## Core loop (day cadence)
1. **Inbox / Briefing** — memos, alerts, policy updates, performance feedback.
2. **Pre-interview review** (later) — inspect a “company computer” (emails/logs/search) and pin artifacts.
3. **Interview** — dialogue that can itself become evidence.
4. **Vision Board** — pin evidence + draw **typed edges** (Motive/Means/Opportunity/Policy/etc.).
5. **Submit Finding** — pick from unlocked conclusion templates (not freeform).
6. **Outcome** — consequences + feedback (promotion/discipline, access changes, habitat impacts).

## Proof-of-concept scope (POC v0)
A single playable “day” proving:
- the board mechanic,
- a deterministic “imperfect rubric” scoring system,
- the feeling of consequence.

Minimum v0 target:
- One interview (can be linear initially)
- ~6 evidence items available to pin
- Create exactly one connection (Evidence A + Evidence B + Edge Type)
- Submit finding → show scores + one of a few outcomes

## Current status
✅ Screen navigation is functional:
- `Inbox → Board → Outcome`

🛠 In progress / next steps:
- List-based “board” UI (pin evidence)
- Add a connection UI (choose A/B/type)
- Deterministic scoring + outcome text
- Seed data for a single case/day

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
  autoload/            # Global singletons (shared state)
	app_state.gd

  docs/                # Design notes / PRD / pitch docs
	BASIC_PITCH_AND_MVP_PLAN.md

  main/                # Bootstrapping + routing
	main.tscn
	screen_manager.gd  # swaps screens at runtime (Pattern A)

  ui/
	screens/           # “Pages” of the game (each screen is its own scene + script)
	  inbox/
	  board/
	  outcome/
	components/        # Reusable UI widgets shared across screens (future)
	theme/             # UI theme, fonts (future)

  data/                # Authored case data (future: JSON/Resources for evidence/dialogue)
  assets/              # Art/audio/etc. (future)

  icon.svg
  README.md
