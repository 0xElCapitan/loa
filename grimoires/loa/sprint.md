# Sprint Plan: Cycle-122 — Mechanical Floor Extensions

> **Cycle**: `cycle-122-mechanical-floor-extensions` (stacked on cycle-121 / PR #1238 — branch from `feat/cycle-121-context-diet`, PR base = that branch)
> **Sprints**: 3 (local sprint-1..3; global 232-234)
> **Ground truth**: cycle-121 SAFE_WITH_MECHANISM backlog (beads `swm-*`, from audit workflow `wf_f9c99bce-302`) + operator decisions 2026-07-29: items 3–6 green-lit; Karpathy trim delegated with the **zero ponytail-parity-degradation condition** (contract: `grimoires/loa/proposals/ponytail-parity-audit-2026-06-16.md` — v1067 doctrine + G1/G2/G6 pinned to CLAUDE.loa.md); Read-before-Write delegated with the **no-quality-degradation condition**.
> **Theme**: build the mechanisms that let prose shrink — wire the parked gate, close the four documented fence gaps, harden the weakest pipeline consumer, fix post-compaction skill-context loss, then (and only then) take the prose reductions those mechanisms unlock.
> **Beads policy**: beads exist (`swm-*` + `bd-c122-*` + `bd-a3ks`); mark in-progress/closed per task. KF-005/KF-022 discipline unchanged (DB authoritative; JSONL export split-brain is upstream).
> **Routing**: `/run sprint-plan` → `/implement` → `/review-sprint` → `/audit-sprint` per sprint. System-Zone writes under cycle authorization (bounded zone-guard marker, delete at run end).
> **PR review**: maintainer (note: `@janitooor` handle does not resolve via GitHub API — PR author is the maintainer's account `deep-name`).

---

## Executive Summary

Cycle-121 removed everything judgment-safe; this cycle builds the mechanical replacements the adversarial verifiers demanded before the remaining prose can move — and takes exactly those unlocked reductions, nothing more.

- **Sprint 1** (P1) — fences: wire the parked `implement-gate.sh`; add `git tag`, FR-SZ `.claude/` root, and stash-swallow pattern families to the existing hook machinery (each with tests + audited overrides, dual-layer twin discipline).
- **Sprint 2** (P1) — pipeline hardening: post-merge unattended agent model bump + C-MERGE constraints in its prompt; post-compaction ACTIVE-SKILL re-surfacing (structural fix for all long-running skills); C-BRIDGE registry render into run-bridge + CLAUDE.loa.md bridge-table removal (~1.6KB/turn).
- **Sprint 3** (P2) — delegated judgment items + E2E: parity-gated conservative Karpathy trim (adversarial parity re-audit is the gate; ANY pinned-clause degradation → NO-CHANGE outcome is a valid completion); Read-before-Write decision record (KEEP + flip-evidence); bd-a3ks template-heading fix; full E2E battery.

## Scope Contract — explicitly OUT

RISKY/KEEP verdicts from the cycle-121 audit stay untouched: Agent Teams section/table (its surfacing mechanism `swm-team-surfacing` is NOT in this cycle — needs design discussion), reviewing-code minimum-quota, Backpressure DO-NOTs, `/spiraling` why-text, Multi-Model/Tiered prose, TaskCreate rows. `swm-runmode-split` deliberately skipped (recovery procedures stay inline). `swm-grounding-ratio` + `swm-bug-eligibility` deferred (small, no urgency). The Karpathy task may NOT touch: the 6-rung ladder, reflex framing, safety floor, runnable-check, `loa:shortcut:` convention, intensity dial (full/ultra, no-lite), G2 output-discipline clause, G6 tie-break + deletion clauses — these are operator-signed parity content; only redundant connective prose may compress.

---

## Sprint Overview

| Sprint | Theme | Key Deliverables | Dependencies |
|--------|-------|------------------|--------------|
| 1 | Fences | implement-gate wired + 3 new pattern families, all tested, dual-layer where applicable; N1/N3/A1/A4 prose collapse AFTER gate proven | None |
| 2 | Pipeline hardening | post-merge agent hardened; post-compact active-skill re-surfacing; C-BRIDGE rendered + bridge table removed | None (parallel-safe with 1) |
| 3 | Delegated judgment + E2E | Parity-gated Karpathy trim (or documented NO-CHANGE); RbW decision record; bd-a3ks; E2E + measurement | Sprints 1–2 (E2E covers all) |

---

## Sprint 1: Fences — wire the gate, close the four documented gaps

**Duration:** ~1 day. **Zone:** System. **Basis:** swm-implement-gate, swm-git-tag-fence, swm-frsz-claude-root, swm-stash-swallow beads; cycle-121 audit mechanical map (11 MECHANICAL / 10 PARTIAL / 7 PROSE-ONLY rows).

### Sprint Goal
Every green-lit fence is wired, tested, and fail-safe in the direction its design demands (implement-gate fail-ASK; pattern fences fail-open per hook-guard discipline), with audited overrides, and the prose rows those fences replace are collapsed through the constraint registry only AFTER the fence's tests prove coverage.

### Deliverables
- [x] **D1.1** — `implement-gate.sh` registered (PreToolUse:Write|Edit via hook-guard wrapper) in BOTH `settings.json` and the `settings.hooks.json` copy-set (KF-021 drift class); its bats suite green; PARKED_HOOK_SCRIPTS lint updated
- [x] **D1.2** — `git tag` creation fence in `block-destructive-bash.sh` (listing forms `-l`/`-n`/`--list` stay allowed) + `Bash(git tag:*)` allowlist entry REMOVED + audited override env + tests; C-MERGE-002 prose row then collapses to pointer via registry
- [x] **D1.3** — FR-SZ `_sz_root` gains `.claude/` (write-intent shapes on System Zone via Bash blocked single-agent) + tests + the existing audited override
- [x] **D1.4** — stash-swallow patterns: `git stash (push|pop)` piped to `tail|head` or with `|| true` in the same segment → BLOCK with remedy naming `stash_with_guard` + tests; `stash-safety.md` then shrinks to interface + origin link
- [x] **D1.5** — N1/N3/A1/A4 prose collapse (registry edit: four rows → one line + gate reference) ONLY after D1.1's gate tests pass in CI-parity run

### Acceptance Criteria
- [ ] `implement-gate.sh` fires on App-Zone Write/Edit outside `/implement` (bats: authoritative + heuristic modes, fail-ASK posture verified, no hard-block)
- [ ] `git tag v9.9.9-test` shape BLOCKED with remedy naming `semver-bump.sh`; `git tag -l` ALLOWED; override env logged to `.run/audit.jsonl`
- [ ] `echo x > .claude/foo` and `sed -i` on `.claude/` paths BLOCKED via Bash (single-agent, no LOA_TEAM_MEMBER); grimoires/ writes unaffected
- [ ] `git stash push | tail -3` and `git stash pop || true` shapes BLOCKED; plain `git stash push`/`pop` ALLOWED
- [ ] All existing hook suites (dcg golden tests, zone-guard ZWG-*) remain green; new patterns have their own bats
- [ ] Registry collapse lands with `generate-constraints.sh` + `validate-constraints.sh` green and AGENTS.md projection still carrying the surviving rules

### Technical Tasks

#### Task 1.1 — Wire implement-gate (bead swm-implement-gate) → **[G-1]**
- [ ] Register via hook-guard wrapper in settings.json PreToolUse + settings.hooks.json copy-set; remove from PARKED_HOOK_SCRIPTS in lint-invariants.sh; run its bats; verify THIS run's own /implement flow still writes (gate must recognize run-mode/implement context)

#### Task 1.2 — git-tag fence (bead swm-git-tag-fence) → **[G-1]**
- [ ] New pattern family in block-destructive-bash.sh with listing-form carve-out; remove allowlist entry; tests incl. FP guard (commit messages MENTIONING git tag must not trip — inert-carrier scrub applies)

#### Task 1.3 — FR-SZ .claude/ root (bead swm-frsz-claude-root) → **[G-1]**
- [ ] Add root + tests; confirm zone-guard marker path (.run/) unaffected; document accepted-bypass deltas in hooks-reference.md

#### Task 1.4 — stash-swallow (bead swm-stash-swallow) → **[G-1]**
- [ ] Pattern + tests + stash-safety.md shrink (MUST rows → interface pointer + origin, rule preserved via fence)

#### Task 1.5 — prose collapse via registry (post-gate) → **[G-1]**
- [ ] constraints.json: N1/N3/A1/A4 rows consolidated; regenerate; AGENTS.md check

### Dependencies
- D1.5 strictly after D1.1 acceptance (fence proven before prose moves).

### Risks & Mitigation
- **implement-gate false-positives block THIS run** → fail-ASK posture (never hard-block) + verify against the live run before commit; hook-guard wrapper means a broken script fails open
- **git-tag fence FP on prose mentioning tags** → inert-carrier scrub already handles carrier values; explicit FP tests
- **Copy-set drift (KF-021)** → both settings files in the same commit; drift check in acceptance

### Success Metrics
- 4 documented gaps closed with tests; 0 regressions across hook suites; ≥4 prose rows collapsed registry-clean

### Security Considerations
- Every new fence ships with an AUDITED override (never a silent bypass) and follows fail-open-on-parse-error via hook-guard (a broken fence must not brick the harness — #1180). The implement-gate is fail-ASK by design: it prompts, never silently blocks.

---

## Sprint 2: Pipeline Hardening — weakest consumer, compaction gap, bridge render

**Duration:** ~1 day. **Zone:** System + .github. **Basis:** swm-postmerge-agent, swm-bridge-render beads; cycle-121 verifier findings (post-compact-reminder re-reads CLAUDE.md only; post-merge agent = Sonnet 4.5, no Skill tool, "continue on failure").

### Sprint Goal
The three structural reliability gaps close: the post-merge failure-recovery agent runs a current model with the pipeline constraints in its own prompt; a mid-loop compaction re-surfaces the ACTIVE skill's contract (all skills, not just run-mode); and the bridge constraints render at point of use so the always-loaded table can go.

### Deliverables
- [ ] **D2.1** — `.github/workflows/post-merge.yml`: agent model bumped `claude-sonnet-4-5-20250929` → `claude-sonnet-5`; the five C-MERGE constraint lines added to its prompt (with a registry-source comment); "continue with remaining phases" softened to "continue EXCEPT when a constraint above would be violated — then stop and report"
- [ ] **D2.2** — post-compaction active-skill re-surfacing: `pre-compact-marker.sh` snapshots the active flow (RUNNING states in `.run/*.json` → active skill name); `post-compact-reminder.sh` adds "re-read `<active skill>/SKILL.md`" to its injected recovery sequence; bats for both (marker present/absent, multiple flows, fail-open)
- [ ] **D2.3** — C-BRIDGE-001..008 rendered into `run-bridge/SKILL.md` via registry (explicit-ID SECTIONS entries in both scripts; fixes C-BRIDGE-006's declared-but-unrendered skill layer; replaces the drifted hand-written list at run-bridge/SKILL.md:320-326); CLAUDE.loa.md bridge table removed, keeping the `.run/bridge-state.json` recovery pointer + a MUST-read routing row (post-compaction re-surfacing from D2.2 covers the mid-loop case)

### Acceptance Criteria
- [ ] post-merge.yml: model id updated; prompt contains all five C-MERGE rule texts verbatim-in-substance; YAML valid (`yq`)
- [ ] After a simulated compaction with `.run/sprint-plan-state.json` RUNNING, the injected reminder names the run-mode skill; with a bridge state active, names run-bridge; with nothing active, unchanged behavior (bats)
- [ ] `run-bridge/SKILL.md` carries the generated block with all 8 C-BRIDGE rules; CLAUDE.loa.md table gone; routing row present; `generate/validate-constraints` green; AGENTS.md loses only the bridge ALWAYS rows (bridge flows are Claude-skill-only — accepted per verifier)
- [ ] Always-loaded byte count re-measured and recorded (expect ~24.3KB)

### Technical Tasks

#### Task 2.1 — post-merge agent hardening (bead swm-postmerge-agent) → **[G-2]**
- [ ] Model bump + prompt constraints + failure-handling scoping; yq validation

#### Task 2.2 — post-compact active-skill re-surfacing → **[G-2]**
- [ ] Marker snapshot + reminder injection + bats (fail-open preserved)

#### Task 2.3 — C-BRIDGE render + table removal (bead swm-bridge-render) → **[G-2]**
- [ ] Registry retarget + both SECTIONS arrays + marker block in run-bridge + CLAUDE.loa.md table removal + routing row

### Dependencies
- D2.3's table removal only after D2.2 lands (the compaction re-surfacing is the verifier's named routing condition) and the generated block is verified in run-bridge/SKILL.md.

### Risks & Mitigation
- **Workflow YAML breakage** → yq validation; no permission/tool changes, only model + prompt
- **Reminder hook grows noisy** → one line added, only when a flow is RUNNING; fail-open preserved
- **C-BRIDGE text_variants missing for skill-md render** → add variants in constraints.json as needed; validator drift-fails if wrong

### Success Metrics
- Weakest-consumer gap closed; compaction contract covers every long-running skill; ~1.6KB/turn further reduction

### Security Considerations
- post-merge.yml prompt change constrains (never widens) the unattended agent; model bump changes capability, not permissions (same allowed_tools).

---

## Sprint 3: Delegated Judgment Items + E2E

**Duration:** ~0.5 day. **Zone:** System + State. **Basis:** operator delegations 2026-07-29 (items 1–2); bd-c122-karpathy-parity, bd-c122-rbw-decision, bd-a3ks.

### Sprint Goal
The two operator-delegated judgment items resolve with their conditions honored and documented — the Karpathy trim happens ONLY if an adversarial parity re-audit confirms zero degradation of the ponytail-pinned content (a documented NO-CHANGE is a valid outcome); the Read-before-Write row is kept with the flip-evidence enumerated — and the whole stacked cycle passes the E2E battery.

### Deliverables
- [ ] **D3.1** — Karpathy conservative trim, parity-gated: (a) pinned-clause checklist extracted from `ponytail-parity-audit-2026-06-16.md` (v1067 doctrine items + G1/G2/G6 texts); (b) draft trim that preserves every pinned clause VERBATIM and compresses only connective/duplicated prose (target ~0.8–1.1KB of the 4.7KB section; the original audit's ~3KB cut is PROHIBITED — it moved pinned content out); (c) adversarial parity re-audit: independent multi-judge comparison of before/after against the checklist; (d) apply ONLY on unanimous no-degradation verdict, else record NO-CHANGE with the failing clause cited
- [ ] **D3.2** — Read-before-Write decision record in NOTES.md Decision Log + `swm-rbw-remeasure` bead note: row KEPT (error class already loss-proof via harness rejection; removal condition requires fleet telemetry showing the ~570/month class collapsed under Claude-5 models — the evidence that flips this)
- [ ] **D3.3** — bd-a3ks: `NOTES.md.template` `## Decisions` → `## Decision Log`; `check-loa.sh check_notes_template` + `notes-template.bats` aligned in the same commit
- [ ] **D3.4** — E2E: full unit + script bats suites; all validators; fresh-mount simulation; always-loaded measurement; cycle report appendix updated

### Acceptance Criteria
- [ ] Parity gate artifact exists (judge verdicts recorded under `grimoires/loa/a2a/sprint-3/parity-audit/`); every pinned clause byte-findable in the post-trim section (mechanical grep list); NO-CHANGE path equally documented if taken
- [ ] NOTES.md Decision Log carries the RbW decision with flip-evidence; bead updated
- [ ] `notes-template.bats` green with the renamed heading; fresh-mount NOTES.md passes `check_notes_template` without the WARN
- [ ] **E2E (end-to-end)**: full `tests/unit/` + `.claude/scripts/tests/` green; `validate-constraints` 0 errors; `validate-skill-capabilities` green; include drift green; `grimoire-index --validate` green; fresh-mount cycle-owned checks green; final always-loaded bytes recorded

### Technical Tasks

#### Task 3.1 — parity-gated Karpathy trim (bead bd-c122-karpathy-parity) → **[G-3]**
- [ ] Checklist → draft → multi-judge parity re-audit → apply-or-NO-CHANGE

#### Task 3.2 — RbW decision record (bead bd-c122-rbw-decision) → **[G-3]**
- [ ] Decision Log entry + bead note

#### Task 3.3 — template heading fix (bead bd-a3ks) → **[G-3]**
- [ ] Template + validator + tests in one commit

#### Task 3.4 — E2E battery + measurement → **[G-1] [G-2] [G-3]**
- [ ] Full battery; record; update report appendix

### Dependencies
- Sprints 1–2 merged into the stacked branch before T3.4.

### Risks & Mitigation
- **Parity judges disagree** → unanimity required for change; any dissent = NO-CHANGE (the operator's condition is absolute)
- **Trim touches a pinned clause by accident** → mechanical grep checklist in acceptance, not judgment alone

### Success Metrics
- Both delegated items resolved with conditions demonstrably honored; suite green; final measurement recorded

### Security Considerations
- The Karpathy floor ("never simplify away", runnable-check) is pinned content — the gate makes weakening it mechanically detectable before merge.

---

## Appendix

### Goal Mapping

| Goal | Statement | Sprints | Verification |
|------|-----------|---------|--------------|
| G-1 | All green-lit fences wired + tested with audited overrides; dependent prose collapsed registry-clean only after proof | 1 | new + existing hook bats; validate-constraints; AGENTS.md grep |
| G-2 | Pipeline reliability gaps closed (weakest consumer, compaction skill-context, bridge point-of-use) | 2 | yq + hook bats + generated-block verification + byte measurement |
| G-3 | Operator-delegated items resolved with conditions honored and auditable | 3 | parity-gate artifact / decision records / suite green |

### Provenance

Operator decisions (this session, 2026-07-29): "1. defer to you… only change if there is not degradation of the pony-tail parity. 2. defer to you… if we can find a way to remove this error type without degrading quality. 3-6 defer to you happy to proceed." Cycle-121 verdicts: workflow `wf_f9c99bce-302` journal + `grimoires/loa/reports/context-diet-cycle-121.md`.
