# Versimilitude — Concept & POC Spec (Living Notes)

## One-line pitch
A story-driven corporate-noir paperwork game set on a company-owned O’Neill Cylinder, where **there is no real mystery**—but you get promoted (up to CEO) for **manufacturing one** that the company finds compelling and useful.

## Core tone
- **World is sincere, stakes are real.** Actions can destabilize life support, infrastructure, and civil order on a closed habitat.
- **People are ridiculous.** Petty agendas, bizarre incentives, and corporate-brain behavior—played straight.
- **Protagonist is “noir competent” in vibe only.**
  - Classic gruff detective delivery.
  - Internally underqualified / confused / improvising.
  - The friction between vibe and reality is the comedic engine.

## Primary inspirations
- **Date Everything** — route/character-driven structure; daily choices of who to engage; storylines can intertwine.
- **Papers, Please** — day-based cadence; bureaucratic UI; rules/policy; score + consequences loop.
- **Shadows of Doubt** — “red string” evidence board; players connect facts to form narratives.

## High-level premise
The company’s hiring system selected you for “Investigator” because the AI was trained on noir tropes (or “noir-coded competence”), not real qualifications. The organization is so large its internal decisions have immediate habitat-wide effects. Your job is to write “Findings” that justify action. The company (but really the AI) rewards you for narratives that are:
- coherent (feel like a case),
- policy-anchored (cite compliance),
- useful (justify control, optimization, or political goals).

**Truth is optional; plausibility is currency.**

---

# Design pillars
1. **Narrative fabrication is the gameplay.** The board is not for solving; it’s for *constructing*.
2. **Deterministic, imperfect rubric (abusable).** Players can learn and exploit the system.
3. **Consequences are immediate and habitat-scale.** “Useful” narratives can cause collateral damage.
4. **Route-first storytelling.** Players “pick who to process” each day; routes can intertwine based on choices.
5. **Multiple valid playstyles.**
   - Power: climb to CEO
   - Curiosity: explore routes and outcomes
   - Ethics: protect the cylinder / reduce harm
   - Truth: insist there’s no mystery

---

# Core game loop (day structure)
**Daily cadence (Papers, Please-style):**
1. **Inbox / Briefing**
   - Daily memo(s), alerts, policy updates, performance feedback.
2. **Pre-interview review**
   - Optional: inspect a target’s “company computer” (emails, search history, logs) and click items to pin them to the board.
3. **Interview**
   - Branching dialogue.
   - Dialogue lines can be added as evidence.
4. **Vision Board**
   - Add evidence nodes (facts, people, quotes, documents).
   - Draw typed edges to imply relationships.
5. **Submit Official Finding**
   - Choose from unlocked conclusion templates (not freeform).
   - The rubric scores your narrative and triggers consequences.
6. **Outcome + Feedback**
   - Promotion/discipline, new access, new political constraints.
   - Habitat impacts visible quickly (next-day memos, changed conditions, windows in your office show the cylinder).

---

# Vision Board mechanics (Shadows of Doubt-style)
## Nodes
- **Evidence nodes**: emails, logs, documents, physical notes, “computer artifacts,” interview quotes.
- **Person nodes**: the interview subject (and later other entities).
- Optional later: **policy nodes** (for citations) and **location/system nodes** (habitat subsystems).

## Typed edges
Edges are player-chosen interpretations (not “truth”):
- MOTIVE
- MEANS
- OPPORTUNITY
- COVER_UP
- PATTERN
- POLICY
- TRUST
- CONTRADICTION

These edges aren't set in stone, just ideas

## Why typed edges matter
They let a non-AI algorithm evaluate the **structure** of your story:
- chains (Motive → Means → Opportunity),
- triangles (Person–Evidence–Person),
- suspect centrality (one person becomes a narrative hub),
- policy anchoring,
- contradiction handling (resolve vs amplify).

---

# The “Imperfect Rubric” scoring system (non-LLM, deterministic)
**Goal:** feel intelligent, remain learnable, and be intentionally exploitable.

## Evidence metadata (authorable knobs)
Each evidence card can carry tags like:
- severity (1–5)
- legibility (how “clean” it looks to compliance)
- evidence_type (log/email/witness/rumor/physical)
- reliability (0–3)
- noir_value (0–3)
- dept (Ops/Security/HR/Maintenance/Exec/etc.)
- topic (access, money, sabotage, blackmail, romance, etc.)

## Scores (example trio)
- **Narrative Coherence**: rewards noir-shaped graphs (chains, triads, central suspect).
- **Compliance Vibe**: rewards policy edges, legible docs, “proper” evidence types.
- **Corporate Usefulness**: rewards actionable blame and outcomes that enable control/optimization.

*(Optional later scoring axes: Truth, Collateral Damage, Cylinder Health.)*

## Conclusion unlocking
Players don’t type accusations; they choose from **conclusion templates** that unlock when the board matches patterns, e.g.:
- Single Actor: Negligence
- Coordinated Cover-Up
- Insider Threat
- Systemic Failure
- Policy Violation Cascade

Each conclusion has structural requirements (counts of edge types, centrality thresholds, severity thresholds, policy anchors).

## Intentional exploits (feature, not bug)
Build in biases that reward the “wrong” behaviors:
- **Hub exploit**: over-weight central suspect graphs → scapegoating is effective.
- **Policy spam**: policy edges multiply score too strongly.
- **Legibility bias**: clean logs outscore messy human testimony.
- **Pattern overfit**: repeating a topic increases coherence → players force themes.
- **Contradiction laundering**: contradictions hurt unless “resolved” via COVER_UP edges → players invent cover-ups.

This aligns with the premise: the company promotes narrative engineers.

---

# Route-based narrative structure (Date Everything-style)
## Daily “who do you process?” selection
- Each day offers a roster of possible interviews/interactions.
- Picking someone advances their route and affects which facts enter the ecosystem.

## Intertwining storylines (ambitious, handcrafted intent)
- Routes are distinct and authored with bespoke consequences.
- Intersections happen via shared evidence, shared departments, or triggered outcomes (e.g., a finding forces another route into crisis).
- Long-term: a mix of handcrafted consequences plus systemic levers can reduce authoring burden, but the initial vision emphasizes handcrafted route outcomes.

---

# Setting & stakes: the company-owned O’Neill Cylinder
- The habitat is managed like a product.
- “Corporate actions” have immediate environmental and social effects.
- Consequences should reflect a closed system:
  - maintenance backlog,
  - power and air allocation,
  - surveillance vs trust,
  - layoffs vs infrastructure stability,
  - political unrest vs “efficiency.”

---

# Long-term goals (feature set)
## 1) Dynamic company guidelines book (retroactive policy)
- A “rulebook” that updates daily.
- New rules can retroactively classify old evidence as violations (“it wasn’t illegal then, but it is now”).
- Supports the theme: policy is a moving target; narrative can be rewritten.

## 2) Pre-interview computer inspection
- Clickable email threads, logs, search history.
- Any artifact can be pinned to the board as evidence.
- Supports investigative theater and story construction.

## 3) Daily background sheet / dossier selection UI
- Before interviewing, you see a profile and clickable “known facts” to pin.
- Helps set expectations and primes the board-building loop.

## 4) Branching interviews
- Dialogue choices shape route outcomes.
- Lines spoken can be added as evidence nodes.
- Optional: “pressure” mechanics (interrupt, accuse, reassure) later.
- Optional: Maybe Date Everything style skill points in different areas for exploring different routes with people?

## 5) Persistent cases + revisiting boards
- Boards persist per day and/or per case.
- Ability to import evidence from prior days into current boards.
- Supports long arcs and route interweaving.
- Potential Solution - Have "case boards" that persist every day, and when clicking evidence, it adds it to a board of your choosing. You can create as many as you'd like.

## 6) Multiple endings with meaningful tradeoffs
Core themes discussed:
- **Best Detective, Terrible Outcomes** (max rubric score, habitat damage)
- **Best Detective, Company Survives** (high power + managed harm)
- **There Was No Mystery** (truth-forward play; low power but integrity)

## 7) Intro/tutorial with banter
- Noir protagonist voice + corporate system/AI voice in a back-and-forth banter.
- Establishes tone, explains rubric feedback, teaches board connections.

## 8) Real consequences
- Findings trigger tangible shifts: access changes, departments sanctioned, resource allocations altered, public trust impacts.
- Consequences should be visible via next-day world state, memos, and the view outside if drastic enough.

---

# Core UI screens (eventual)
- Inbox / memos
- Guidelines book (daily updates + retroactive rule evaluation)
- Dossier / selection roster (within your own company computer)
- Target computer (emails/logs/search)
- Interview
- Vision Board (nodes + edges)
- Finding submission (conclusion menu + severity + recommended action)
- Outcome + performance feedback

---

# Proof of Concept deliverables (time-efficient, “ship a day”)
## POC philosophy
Build a **vertical slice** that proves:
- the board mechanic,
- the imperfect rubric,
- the feeling of consequence,
without getting blocked by polish or full freeform board UI.

## POC v0 (minimum playable “one day”)
**Single session, single character**
- One interview scene (can be linear at first).
- ~6 pre-authored evidence items available to pin.
- A simple “board” (start as list-based if needed).
- Create exactly one connection:
  - choose Evidence A, Evidence B, Edge Type.
- Submit finding:
  - show Coherence/Compliance/Usefulness scores.
  - show one of 3 outcomes (e.g., Promotion / Warning / Fired OR Lockdown / Audit / HR Review).

## POC v0.5 (adds the hook)
- Add branching dialogue (2 choices, a couple branches).
- Allow selected dialogue lines to be pinned as evidence nodes.

## POC v1 (first true vertical slice)
- Day 1 memo + rubric feedback flavor text.
- Pre-interview “computer artifacts” screen (a few clickable emails/logs).
- Interview screen with branching.
- Board with multiple nodes + multiple edges.
- Finding submission offers 3–5 conclusion templates (unlocked via board patterns).
- Outcome screen with a clear habitat-scale consequence + performance memo (banter voice).

## POC non-goals (defer until after slice works)
- Full draggable/freeform board (can start list-based).
- Multi-day persistence and importing old evidence.
- Full guideline book with retroactive rules (stub the UI first).
- Large route roster and deep intertwining consequences.

---

# Implementation notes (Godot learning approach)
- Learn only what the POC demands:
  - Scenes + Nodes
  - UI Controls
  - Signals (decouensure)
  - Data-driven content (JSON first; Resources later)
- Start with screen swapping and data flow before visuals.
- Keep the rubric deterministic and inspectable (debug view) during development; hide raw numbers in the final UI behind “performance memos.”

---

# Open questions (intentionally deferred)
- How fast can CEO be reached in a full run (days/weeks structure)?
- What’s the exact set of conclusion templates and corporate actions?
- How is “cylinder health” represented: multi-system model)
- Persistence model: per-day boards vs per-case boards vs hybrid.
- How much handcrafted interweaving vs systemic levers in v2+?

---

**Working title:** Versimilitude
