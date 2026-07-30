# Sprint Plan: Cycle-121 — Claude-5 Context Diet (SAFE tier)

> **Cycle**: `cycle-121-claude5-context-diet` (NEW — ledger `active_cycle` is stale at `cycle-115`; cycles 116–120 are referenced in NOTES/reports without ledger registration. `/run sprint-plan` MUST register this cycle and assign global sprint numbers from the ledger at kickoff — do NOT trust `next_sprint_number: 227` blindly; reconcile first.)
> **Sprints**: 5 (local sprint-1..5; global numbers assigned at run time)
> **Ground truth**: 2026-07-29 context-engineering audit (11-agent workflow `wf_f9c99bce-302`; 112 findings; 41 removal candidates adversarially verified). Full per-finding verdicts: workflow journal `~/.claude/projects/-home-merlin/81ffdc73-d6f7-4116-83a9-f30230ae4abd/subagents/workflows/wf_f9c99bce-302/journal.jsonl`. Benchmark: Anthropic Claude-5 context-engineering guidance (Thariq, 2026-07-25) + `grimoires/loa/reports/mechanical-floor-methodology-2026-07-07.md` (P4 one-canonical-home, P5 block-message-is-the-repair-prompt).
> **Theme**: Remove dead and obsolete context, dedupe delivery, shrink prose that mechanisms already hold — **without weakening a single guardrail**. Only findings with a verified `SAFE` verdict (or behavior-preserving hygiene that weakens nothing) are in scope.
> **Beads policy**: Beads do NOT yet exist for this cycle. Create them from this plan at `/run sprint-plan` preflight (label `claude5-context-diet`, one bead per Task N.M below, `sprint:<global>` + `cycle-121-context-diet` tags). Beads health is currently **DEGRADED exit 4** (JSONL export stale ~414h) — preflight runs `br sync --flush-only` FIRST; per KF-005 discipline, if beads repair exceeds 5 minutes, STOP repairing and use the markdown fallback protocol. NEVER run `--rebuild`/`--import-only` while ids are DB-only (KF-022).
> **Routing**: `/run sprint-plan` → `/implement` → `/review-sprint` → `/audit-sprint` per sprint. System-Zone (`.claude/`) writes land **inside `/implement` under cycle authorization** (zone-write-guard blocks raw Edit/Write on `.claude/` — use the sanctioned Bash-patcher path, cycle-115 precedent). State-Zone writes (`grimoires/`) are direct.
> **PR review**: @janitooor (CODEOWNERS).

---

## Executive Summary

The audit found Loa already implements the Claude-5 guidance where it matters (progressive disclosure, mechanical enforcement, single-source constraint registry). The verified-SAFE waste is concentrated in the **deep tiers**: ~53% of `.claude/protocols/` (~276KB) is unreachable through any real loading path; a ~107KB semantic-memory subsystem is triple-dead; ~53KB of old-model context-management protocols contradict the current harness; skills carry ~27–29KB of hash-identical pasted boilerplate plus 69KB of `.bak` files and 47MB of committed `node_modules`. The always-loaded files (`CLAUDE.md` + `CLAUDE.loa.md`, ~7.6K tokens/turn) shed only ~1.2–1.5K tokens in this cycle — the bigger cuts are gated behind mechanisms and are **explicitly out of scope** (see Scope Contract).

- **Sprint 1** (P1) — delete dead weight: unreachable protocols, orphaned references, stale skill artifacts. Same-commit validator/reference cleanup so `check-loa.sh` stays green for every consumer repo.
- **Sprint 2** (P1) — shrink obsolete prose in place: tool-result-clearing, karpathy protocol file, context-engineering.md, structured-memory.md, protocols-summary.md.
- **Sprint 3** (P2) — memory consolidation: delete the dead semantic-memory subsystem, stop machine junk polluting NOTES.md, give NOTES.md the KF treatment, fix the KF INDEX recurrence signal.
- **Sprint 4** (P2) — skills layer: single-source the pasted boilerplate, split the two oversized skills into `resources/`, delete judged-safe filler prose, fix invocation-hostile frontmatter.
- **Sprint 5** (P2) — always-loaded diet (SAFE rows only) + full E2E validation and before/after measurement.

**Estimated reduction**: ~205KB deleted/shrunk in protocol+reference tiers, ~40–45KB deduped/split in skills, ~4–5KB off the always-loaded path, 47MB off the repo tree. Zero guardrail weakened; several statements get *stronger* (single canonical home, drift-proof generated delivery).

## Scope Contract — explicitly OUT of this cycle

These carried **RISKY**, **KEEP**, or **SAFE_WITH_MECHANISM** verdicts. Touching them here is an audit-gate violation:

| Item | Verdict | Why out |
|---|---|---|
| CLAUDE.loa.md Karpathy section compression | RISKY | Reverses #960/#1067/#1074 incl. an explicit operator decision; needs operator sign-off + ponytail-parity re-audit. (Wording-contradiction fixes ARE in scope, Sprint 2.) |
| Agent Teams section/table shrink | RISKY/KEEP | Verifier demonstrated 4 live hook bypasses (`git -C` commit, quoted `br`, `sed -i` on `.run/`, Write to `.beads/`) — prose covers real gaps |
| Read-before-Write ALWAYS row | RISKY | #1177-F telemetry (570 err/mo) predates Claude 5; needs re-measurement first |
| TaskCreate-vs-beads NEVER row | RISKY | Harness injects pro-TaskCreate reminders; rule counters live pressure |
| /spiraling why-text shrink | RISKY | Guard has a Bash-write bypass class + fail-open posture (C-PROC-017, critical) |
| Multi-Model / Tiered-Dispatch prose | RISKY | C13 lint is lint-time only; runtime downtier prohibition is prose-only (KF-019) |
| reviewing-code minimum-quota | KEEP | KF-004 (rec ≥28) zero-findings-false-APPROVED class; verdict-derive.sh cannot detect lazy reviews |
| Backpressure six DO-NOTs | RISKY | Six distinct engineered shapes (#391), not one; zero mechanical replacement |
| Bridge/MAY/Merge full table relocation; Agent-Teams constraint surfacing; grounding-enforcement.md deletion; implement-gate wiring; FR-SZ `.claude/` root; git-tag fence; stash-swallow patterns; /bug eligibility validator | SAFE_WITH_MECHANISM | Each needs its named mechanism to land FIRST — candidate follow-up cycle `mechanical-floor-extensions` (Sprint 5 M3–M5 move is the one exception verified SAFE as scoped) |

---

## Sprint Overview

| Sprint | Theme | Key Deliverables | Dependencies |
|--------|-------|------------------|--------------|
| 1 | Dead-weight deletion | ~130KB unreachable protocols/references deleted with same-commit validator cleanup; 47MB skills-tree artifacts removed | None |
| 2 | Shrink-in-place | 5 protocol/reference files rewritten to their load-bearing core (~40KB → ~8KB); CLAUDE.loa.md contradiction fixes | Sprint 1 (dangling-ref targets settled) |
| 3 | Memory consolidation | Semantic-memory subsystem deleted; NOTES.md junk writer fixed + pruned; KF INDEX recurrence signal repaired | Sprint 1 (memory.md/decision-capture.md already gone) |
| 4 | Skills dedup + splits | 9 boilerplate blocks single-sourced; run-mode/simstim `resources/` splits; filler prose deleted; frontmatter descriptions fixed | None (parallel-safe with 2–3) |
| 5 | Always-loaded diet + E2E | 4 SAFE CLAUDE.loa.md/CLAUDE.md shrinks via constraint registry; full-suite E2E + before/after measurement | Sprints 1–4 |

---

## Sprint 1: Dead-Weight Deletion — unreachable protocols, orphans, stale artifacts

**Duration:** ~1 day. **Zone:** System (`.claude/`) + repo tree. **Verdicts consumed:** SAFE (dead protocols, index.yaml blocks¹, attention-budget¹, recursive-context+semantic-cache, context-editing+memory.md, context-compaction, ck-family merge, stale skill artifacts). ¹SAFE_WITH_MECHANISM where the "mechanism" is a same-commit validator edit — included here because the coupling is part of this sprint's diff, not separate infrastructure.

### Sprint Goal
Every file with no real loading path (agent-context reference from CLAUDE.md/CLAUDE.loa.md, SKILL.md bodies/resources, commands, subagents, rules, hooks, or reference files) is deleted or relocated to `docs/`, with all validator couplings and dangling references fixed in the same commits, so `check-loa.sh` and the bats suite stay green in this repo and every downstream mount.

### Deliverables
- [x] **D1.1** — 13 dead protocols deleted; `destructive-command-guard.md` + `error-codes.md` folded into `hooks-reference.md` / `error-codes.json` then deleted (15 files, ~102KB)
- [x] **D1.2** — obsolete old-model context-management family removed: `attention-budget.md`, `context-compaction.md`, `recursive-context.md`, `semantic-cache.md`, `jit-retrieval.md`, `run-mode.md` (protocol) deleted; `context-editing.md` + `memory.md` moved to `docs/integration/`; `decision-capture.md` deleted (~75KB out of the protocol tier)
- [x] **D1.3** — `check-loa.sh` + `validate-prd-requirements.sh` updated in the SAME commits as the deletions they self-certify
- [x] **D1.4** — dead `protocols:` metadata blocks removed from all 13 `index.yaml` files
- [x] **D1.5** — ck-family merge: unique content of `negative-grounding.md`, `self-audit-checkpoint.md`, `edd-verification.md` merged into `citations.md`; the three files deleted. `grounding-enforcement.md` NOT touched (gated, out of scope)
- [x] **D1.6** — reference-tier orphans `permissions-reference.md`, `version-features.md` deleted after a grep-gate proves zero live references
- [x] **D1.7** — skills-tree stale artifacts: `riding-codebase/SKILL.md.bak` + `SKILL.md.bak-270` (69KB) and `flatline-knowledge/resources/__pycache__/` deleted; `bridgebuilder-review/` `node_modules`+`dist`+lockfile (47MB) removed from tree, gitignored, installed on demand via its `entry.sh`
- [x] **D1.8** — dangling-reference sweep + regenerated checksums manifest and grimoire INDEX

### Acceptance Criteria
- [ ] Loading-path grep gate: for every deleted file, `grep -rF "<basename>" .claude/skills .claude/commands .claude/agents .claude/hooks .claude/rules .claude/loa CLAUDE.md` returns ZERO hits post-change (checksums.json/CHANGELOG excluded)
- [ ] `check-loa.sh` exits green on this repo AND on a fresh `mount-loa.sh` test mount (required_protocols arrays no longer name any deleted file — today it hard-FAILs on 5 of them at `check_v090_protocols` lines 143–166)
- [ ] `validate-prd-requirements.sh` magic-string checks (lines 117–144 attention-budget zones; 192–249 grounding strings) retired or retargeted; script exits green or is removed with its callers updated
- [ ] `lib-curl-fallback.sh:131` no longer points at nonexistent `grimoires/loa/protocols/...` path
- [ ] `memory.md`'s secrets prohibition (never store API keys/credentials/PII in git-tracked memory) survives verbatim in `.claude/rules/zone-state.md`
- [ ] Full bats suite green; `git log` shows validator edits and deletions in the same commit per coupling (D1.3)
- [ ] Post-sprint byte count: `.claude/protocols/` ≤ ~290KB (from 519KB) — measured and recorded in the PR body

### Technical Tasks

#### Task 1.1 — Delete the 13 dead protocols + fold-then-delete the 2 mechanism docs → **[G-1]**
- [ ] Delete: `construct-workflow-activation.md`, `skill-forking.md`, `browser-automation.md`, `verification-loops.md`, `bug-lifecycle.md`, `analytics.md`, `session-end.md`, `integrations.md`, `url-registry.md`, `gpt-review-integration.md`, `preflight-integrity.md`, `search-fallback.md`, `shadow-classification.md`
- [ ] Fold operator-relevant lines of `destructive-command-guard.md` into `hooks-reference.md` (the hook IS the enforcement); fold `error-codes.md` prose into `error-codes.json` descriptions / reference; delete both
- [ ] Fix `lib-curl-fallback.sh:131` broken pointer; remove deleted-file rows from `protocols-summary.md`

#### Task 1.2 — Old-model context-management family → **[G-1]**
- [ ] Delete `attention-budget.md` (11.9KB; advisory-only, thresholds contradict 10 live context_discipline blocks, zero KF evidence) — same commit: `check-loa.sh` required_protocols + `validate-prd-requirements.sh` retirement (D1.3)
- [ ] Delete `context-compaction.md` (5.8KB; PreCompact/post-compact hooks own the trigger; CLAUDE.loa.md keeps the run-mode recovery table) — fix refs in `session-continuity.md:52`, `helper-scripts.md`
- [ ] Delete `recursive-context.md` + `semantic-cache.md` (20.5KB; script manuals, cache has 4 entries/47 hits) — fold a 10-line script summary into `reference/scripts-reference.md`; verify `context-manager.sh --help` covers invocation
- [ ] Delete `jit-retrieval.md` + protocol `run-mode.md` (33.7KB; index.yaml-only reachability; run-mode SKILL.md carries the live state machine) — fix refs in `implementation-compliance.md` and `sprint-completion.md`
- [ ] Move `context-editing.md` + `memory.md` to `docs/integration/` beside `runtime-contract.md` (their only real consumer); relocate the secrets prohibition to `zone-state.md` FIRST
- [ ] Delete `decision-capture.md` (orphaned once memory.md moves; mandates a `decisions.yaml` that has never existed)

#### Task 1.3 — index.yaml `protocols:` block removal → **[G-1]**
- [ ] Remove the `protocols:`/`protocol_loading` blocks from all 13 index.yaml files (verified: zero consumers — `skills-adapter.sh` reads only name/description/triggers; Claude Code loads SKILL.md, not index.yaml)
- [ ] Where a block named a genuinely useful file, ensure the SKILL.md body already points to it (pattern: `implementing-tasks/SKILL.md:147`) — add the one-line pointer if not

#### Task 1.4 — ck-family merge + reference orphans → **[G-1]**
- [ ] Merge unique content of `negative-grounding.md`, `self-audit-checkpoint.md`, `edd-verification.md` into `citations.md`; delete the three; keep `citations.md` + `trajectory-evaluation.md` untouched (live loading paths from skill resources)
- [ ] Do NOT touch `grounding-enforcement.md` (its deletion is gated on the ≥0.95 ratio landing in review skills — out of scope)
- [ ] Grep-gate then delete `reference/permissions-reference.md` + `reference/version-features.md` (12.6KB); if the gate finds a live reference, index the file from CLAUDE.loa.md's Reference table instead and record the finding

#### Task 1.5 — Skills-tree stale artifacts → **[G-1]**
- [ ] `git rm` `riding-codebase/SKILL.md.bak`, `SKILL.md.bak-270`, `flatline-knowledge/resources/__pycache__/`
- [ ] Move `bridgebuilder-review/node_modules` + `dist` + lockfile out of the tracked tree: gitignore, add install-on-demand (`npm ci`) to its `entry.sh`; verify the skill still runs end-to-end afterward
- [ ] Regenerate checksums manifest + `bash .claude/scripts/grimoire-index.sh` (D1.8)

### Dependencies
- None external. Internal ordering: secrets-rule relocation (T1.2) BEFORE memory.md moves; validator edits in the SAME commit as their coupled deletions (D1.3); T1.4's grounding-enforcement exclusion is absolute.

### Risks & Mitigation
- **Downstream mounts break on missing protocols** → the check-loa.sh/validate-prd edits ship in the same commit; acceptance runs check-loa on a fresh test mount
- **A "dead" file has an unmapped consumer** → per-file grep gate in acceptance; deletions are individually recoverable from git history; PR review by @janitooor
- **bridgebuilder-review breaks without committed node_modules** → entry.sh install-on-demand verified by running the skill in CI/bats before merge
- **Zone-guard blocks System-Zone deletions** → route through `/implement` cycle authorization + Bash-patcher (established cycle-115 pattern)

### Success Metrics
- ~130KB removed from `.claude/protocols/` + `reference/`; 47MB removed from the tracked tree
- check-loa.sh green here and on fresh mount; bats suite green; zero dangling internal references (zone-state.md fail-closed standard)

### Security Considerations
- The deny rules, hooks, and `settings.deny.json` are untouched. `destructive-command-guard.md` prose deletion does NOT touch `block-destructive-bash.sh` (the enforcement). Secrets-prohibition rule is relocated, never dropped (flagged removal-sensitive in the audit).

---

## Sprint 2: Shrink-in-Place — obsolete prose rewritten to its load-bearing core

**Duration:** ~1 day. **Zone:** System. **Verdicts consumed:** SAFE (tool-result-clearing shrink, karpathy protocol gut, context-editing/memory already handled, structured-memory shrink); plus behavior-preserving rewrites (context-engineering, protocols-summary) and two verifier-endorsed wording fixes.

### Sprint Goal
The five most-duplicated/stale prose files are rewritten in place (same paths — every live pointer keeps resolving) down to their genuinely load-bearing content, and the two internal contradictions in CLAUDE.loa.md's Karpathy section are fixed without compressing it.

### Deliverables
- [x] **D2.1** — `tool-result-clearing.md` 12.9KB → ~2KB (keep thresholds, 4-step extract→synthesize→clear→summary, NOTES.md format, edge cases 1–3; delete semantic-decay wall-clock timers, token-estimation bash, validation/troubleshooting sections)
- [x] **D2.2** — `karpathy-principles.md` 10.8KB → ~1KB stub: config keys (`.loa.config.yaml.example:2789-2812`), hook pointers (`karpathy-surgical-diff-check.sh`, goal-driven gate), and a "canonical text lives in CLAUDE.loa.md" banner. CLAUDE.loa.md's section is NOT touched (RISKY — out of scope) except D2.5
- [x] **D2.3** — `reference/context-engineering.md` 6.3KB → ~1.5KB honest pointer table (what exists, where detail lives, what is wired); stale Opus-4.6/4.7 claims and dead attention-budget references removed
- [x] **D2.4** — `structured-memory.md` ~10KB → ~40 lines in place: NOTES.md location, what-belongs-where (NOTES vs KF vs auto-memory), session-continuity recovery pointer; MUST-section tables and semantic-decay ritual deleted; `check-loa.sh` `check_notes_template` aligned with the survivor
- [x] **D2.5** — CLAUDE.loa.md Karpathy wording fixes ONLY: reconcile "applies on EVERY turn" (heading) vs "every code-touching turn" (body); scope "ask before implementing" so it doesn't contradict Run Mode's "Resume immediately, do NOT ask" (line ~250)
- [x] **D2.6** — `protocols-summary.md` rewritten as a complete one-line-per-file table (name, purpose, loaded-by) covering exactly the surviving protocol set; prose restatements (karpathy, NOTES sections, git-safety) deleted

### Acceptance Criteria
- [ ] All five files keep their exact paths; every inbound reference (grep) still resolves
- [ ] `tool-result-clearing.md`: the 6-line context_discipline summaries in 10 SKILL.md bodies are byte-identical to before (this sprint does not touch skills)
- [ ] `karpathy-principles.md` contains zero restated principle text (grep for "YAGNI ladder" / "Surgical" prose returns only the banner + pointers); CLAUDE.loa.md section diff shows ONLY the two wording fixes
- [ ] `structured-memory.md` survivor names no section that `check-loa.sh` doesn't check and vice versa (three-way drift eliminated)
- [ ] `protocols-summary.md` table row-count == surviving protocol file-count (was 20 of 57)
- [ ] bats suite + validate-constraints.sh green (no generated block touched)

### Technical Tasks

#### Task 2.1 — tool-result-clearing.md shrink → **[G-2]**
- [ ] Rewrite per D2.1 keep/delete list; verify the 15+ inbound skill references still make sense against the shrunk file

#### Task 2.2 — karpathy-principles.md gut → **[G-2]**
- [ ] Reduce to config-keys + enforcement pointers + canonical banner; never soften the CLAUDE.loa.md floor ("the floor above is never softened" stays authoritative there)

#### Task 2.3 — context-engineering.md rewrite → **[G-2]**
- [ ] Pointer-table rewrite; remove duplicated memory/context-editing/recursive-context schemas (their source files were deleted/moved in Sprint 1); remove the false "skills with attention budgets" claim (survives only in a deleted .bak)

#### Task 2.4 — structured-memory.md shrink + validator alignment → **[G-2]**
- [ ] ~40-line survivor; update `check-loa.sh` check_notes_template (WARN-only stays WARN-only) to the survivor's section set; NOTES.md.template stays the mechanical carrier for new mounts

#### Task 2.5 — CLAUDE.loa.md contradiction fixes → **[G-2]**
- [ ] Two wording edits only (verifier: "real and safe to fix"); constraint tables untouched; run generate/validate-constraints to prove no generated block drifted

#### Task 2.6 — protocols-summary.md regeneration → **[G-2]**
- [ ] Hand-author the complete table now; OPTIONAL stretch: derive it via a `grimoire-index.sh`-style generator (if built, add a drift check; if not, leave a `<!-- keep in sync -->` marker and file a bead for the generator)

### Dependencies
- Sprint 1 complete (the survivor set is what D2.6 tabulates; D2.3's deleted duplication targets are gone).

### Risks & Mitigation
- **Over-shrinking removes something a skill quotes** → acceptance greps every inbound reference; rewrites keep the exact keep-lists from the verified findings
- **CLAUDE.loa.md edit collides with generated blocks** → D2.5 touches only hand-written prose; validate-constraints.sh in acceptance
- **check-loa drift (D2.4)** → validator edit ships in the same commit as the survivor

### Success Metrics
- ~40KB → ~8KB across the five files; zero broken inbound references; three-way structured-memory drift (protocol vs validator vs reality) eliminated

### Security Considerations
- The never-simplify-away floor and runnable-check requirement in CLAUDE.loa.md are untouched (D2.2 guts only the protocol restatement; D2.5 is wording-only). No fail-closed gate, hook, or validator behavior changes in this sprint — validator edits (D2.4) only re-align a WARN-only check with the survivor text.

---

## Sprint 3: Memory Consolidation — delete the dead subsystem, fix the junk writers, repair the signal

**Duration:** ~1 day. **Zone:** System + State. **Verdicts consumed:** SAFE (semantic-memory subsystem ×3 findings, memory-inject); plus non-guardrail hygiene (NOTES.md junk/prune, KF INDEX recurrence, .bak ledgers, stale handoff surfacing).

### Sprint Goal
One memory story: auto-memory owns session narrative and discovered patterns; git-tracked grimoire surfaces own only team-shared knowledge (KF ledger, GT, current-cycle NOTES). The dead semantic-memory subsystem and its advertising are gone; nothing machine-writes junk into NOTES.md; the KF INDEX recurrence signal is machine-parseable again.

### Deliverables
- [x] **D3.1** — semantic-memory subsystem deleted end-to-end: 7 scripts (`memory-query/admin/bootstrap/setup/sync/inject/writer`), `memory-utils/`, `grimoires/loa/memory/` (after migrating observation `obs-b8d5ce7d` into a lore entry or KF note), tests (`test-memory-bootstrap.sh`, `test_memory.sh`), and ALL advertising: CLAUDE.loa.md `## Persistent Memory` section + Reference-table row, `memory-reference.md`, `zone-state.md` memory-observations line, `loa-setup.md` toggle, `loa-capabilities.sh`, `okf-export.sh` obs source, `.claude/settings.local.json` permission lines, `recommended-hooks.md` §memory-inject, `hooks/README.md` mentions
- [x] **D3.2** — agent-ergonomics bats fixtures (`agent-ergonomics-unknown-flag.bats:23`, `color-guard.bats:16`) retargeted to a surviving CLI as their DX test subject
- [x] **D3.3** — NOTES.md junk writer fixed: `cache-manager.sh` `on_cache_set` auto-synthesis default flipped to `false` (explicit `--message` path kept); test-mode guard so bats runs never write NOTES.md; junk rows (~lines 261–391) pruned
- [x] **D3.4** — NOTES.md gets the KF treatment: pruned to current-cycle + open blockers + live rollback notes (~8KB); stale content archived to `grimoires/loa/archive/`; `## notes` section added to generated INDEX; rotation step added to the archive-cycle flow
- [x] **D3.5** — KF INDEX signal repair: `kf-write-lib.sh recur` rewrites the leading integer of the Recurrence field; `grimoire-index.sh` emits parse-WARN on non-integer recurrence; Status column truncated in the generated kf table (KF-002's ~700B cell); KF-004's recurrence normalized to its true ≥28
- [x] **D3.6** — `ledger.json.bak.*` files (5, ~300KB) deleted (git is the backup); staleness pruning for `context/` and `handoffs/` surfacing (a May-2026 handoff should not be injected into July sessions by `loa-l6-surface-handoffs.sh`)

### Acceptance Criteria
- [ ] `grep -r "memory-query\|memory-inject\|memory-writer\|observations.jsonl" .claude/ CLAUDE.md` returns zero hits (excluding CHANGELOG/git history)
- [ ] Fresh-mount check-loa.sh green; full bats suite green with retargeted fixtures
- [ ] After a bats run + a cache-write exercise, `git diff grimoires/loa/NOTES.md` is empty (junk writer proven dead)
- [ ] NOTES.md ≤ ~10KB; archived content reachable under `grimoires/loa/archive/`; INDEX `## notes` section present
- [ ] `grimoire-index.sh` regenerated: KF-004 row shows integer ≥28; zero `?` recurrence cells for KF-005/006/007 (prose values normalized); `--validate` green
- [ ] L6 handoff surfacing hook shows only entries younger than the staleness threshold (or explicitly pinned ones)

### Technical Tasks

#### Task 3.1 — subsystem deletion + de-advertising sweep (D3.1, D3.2) → **[G-3]**
- [ ] Migrate the one real observation first; then delete scripts/dirs/tests; then the advertising sweep (grep-driven checklist above); regenerate INDEX

#### Task 3.2 — cache-manager junk fix (D3.3) → **[G-3]**
- [ ] Flip `is_auto_synthesize_enabled` default (`cache-manager.sh:611-615`) to `// false`; add bats/test-mode guard (env-gated, matching the repo's test-mode conventions); prune the junk Decisions rows

#### Task 3.3 — NOTES.md KF treatment (D3.4) → **[G-3]**
- [ ] Prune/archive per D3.4; add INDEX section + rotation step; keep the KF forensics-relevant Decision Log entries the KF ledger cites (KF-002/003 attempts tables reference NOTES 2026-05-09 — archive, don't destroy)

#### Task 3.4 — KF signal repair (D3.5) → **[G-3]**
- [ ] `kf-write-lib.sh recur` integer rewrite + index parse-WARN + Status truncation; normalize KF-004/005/006/007 recurrence fields (field edit via kf-write-lib, not free-form append)

#### Task 3.5 — bak cleanup + staleness pruning (D3.6) → **[G-3]**
- [ ] `git rm` the ledger .baks; add age-based filtering to the L6 surfacing hook / index generator for `handoffs/` and `context/`

### Dependencies
- Sprint 1 (memory.md/decision-capture.md/memory-reference-adjacent deletions settled). D3.1 before D3.2 (fixture retarget follows script deletion).

### Risks & Mitigation
- **Something quietly reads observations.jsonl** → deadness was triple-verified (unregistered hooks, config gate off, 1 entry in 15 months) + framework already stamped it EXPERIMENTAL in cycle-115 (ad7c5f92); grep gate in acceptance
- **NOTES.md pruning destroys KF forensic anchors** → archive (git-tracked), never delete; KF-cited entries explicitly preserved
- **kf-write-lib recurrence rewrite corrupts the append-only ledger** → all edits via kf-write-lib entry points (agent-network invariant); `grimoire-index.sh --validate` in acceptance

### Success Metrics
- Memory write-surfaces reduced 12 → ~6 with documented owners; NOTES.md 48KB → ≤10KB; KF recurrence signal 100% integer-parseable

### Security Considerations
- `settings.local.json` permission-line removal shrinks (never widens) the allowlist. The KF ledger stays append-only via lib-mediated writes; UNTRUSTED-body sanitization at surfacing is unchanged.

---

## Sprint 4: Skills Layer — single-source the boilerplate, split the giants, delete the filler

**Duration:** 1–1.5 days. **Zone:** System. **Verdicts consumed:** SAFE (zone_constraints one-liners, autonomous-agent motivational prose, deploying-infrastructure generic methodology); plus behavior-preserving dedup/splits (generated includes, resources/ splits, within-file collapses, frontmatter port).

### Sprint Goal
Every framework rule pasted across skills is delivered from a single generated source; the two oversized skills use the house `resources/` pattern; judged-safe filler prose is gone; every skill's frontmatter description says when to invoke it.

### Deliverables
- [x] **D4.1** — the 9 hash-identical boilerplate blocks (`input_guardrails` ×9, `context_discipline` ×10, `zone_constraints` ×10, `factual_grounding` ×8, `trajectory_logging` ×8, `integrity_precheck` ×7, `beads_workflow` ×4, `prompt_enhancement_prelude` ×4, `retrospective_postlude` ×3) become generated includes compiled from one canonical source (extend the `@constraint-generated` compiler pattern), parameterized per-skill (skill name, app-zone permission); ~27KB → one canonical copy + thin stamped blocks
- [x] **D4.2** — `run-mode/resources/` created: `templates/` (4 PR bodies, 2 status boxes), `schemas/` (4 `.run/*.json` shapes), jq recipes; SKILL.md keeps state machine, pre-flight, circuit breaker, ICE contract (~15–18KB moved)
- [x] **D4.3** — `simstim-workflow/resources/` split on the same pattern (~12KB moved)
- [x] **D4.4** — filler prose deleted: autonomous-agent Prime Directive + Quality Commitment + ASCII flow diagram (~1.5KB); deploying-infrastructure generic DevOps methodology (~4–6KB, keeping verdict strings, output paths, version-pinning DO-NOTs, integration-context contract); implementing-tasks generic quality bullets (~1KB)
- [x] **D4.5** — within-file collapses: autonomous-agent Flatline block ×3 → one parameterized block + 3-row table (simstim precedent at :484); implementing-tasks beads lifecycle ×2 → one; post-PR phase-sequence restatements in run-mode/simstim/autonomous-agent cut to one line + per-skill exit-code table (the orchestrator script is the spec)
- [x] **D4.6** — frontmatter descriptions ported from index.yaml (description + triggers) for the title-like ones; run-mode vs autonomous-agent vs simstim explicitly disambiguated

### Acceptance Criteria
- [ ] Generated includes carry content hashes + `DO NOT EDIT` markers; a validator (extension of `validate-constraints.sh` or new check in the lint suite) fails on drift; regenerating is idempotent
- [ ] Semantic equivalence gate: for each replaced boilerplate block, the generated rendering preserves the rule text verbatim (diff of normalized text is empty) — this is dedup of DELIVERY, not rule change
- [ ] auditing-security's unique Review Scope Filtering subsection (:83–99) survives; zone one-liners state each skill's app-zone permission
- [ ] `validate-skill-capabilities.sh` green across all 40 skills; every SKILL.md pointer to a new `resources/` file resolves
- [ ] run-mode SKILL.md ≤ ~28KB; simstim ≤ ~25KB; total skills-tier SKILL.md bytes reduced ≥ 35KB
- [ ] No `disallowed-tools`, quota, backpressure, or verdict-machinery line is touched (Scope Contract)

### Technical Tasks

#### Task 4.1 — generated-include compiler + block migration (D4.1) → **[G-4]**
- [ ] Add the 9 blocks to the constraint/include registry with per-skill parameters; regenerate; replace hand-pasted copies; wire the drift validator

#### Task 4.2 — run-mode + simstim resources/ splits (D4.2, D4.3) → **[G-4]**
- [ ] Follow the reviewing-code/auditing-security deferral idiom ("See resources/REFERENCE.md"); keep orchestration logic in SKILL.md

#### Task 4.3 — filler deletion + collapses (D4.4, D4.5) → **[G-4]**
- [ ] Exact keep-lists per the verified findings; every cut traces to a finding (surgical-changes discipline)

#### Task 4.4 — frontmatter port (D4.6) → **[G-4]**
- [ ] Mechanical pass: index.yaml description+triggers → SKILL.md frontmatter description; hand-tune the three orchestrators' when-to-choose-which

### Dependencies
- None on Sprints 2–3 (parallel-safe); D4.1's compiler extension before its migrations.

### Risks & Mitigation
- **A "boilerplate" copy has a meaningful local variant** → the audit hash-verified which are byte-identical vs parameterized; the semantic-equivalence gate catches the rest
- **resources/ split orphans content** (resources are not auto-loaded) → every moved section gets an explicit SKILL.md pointer; acceptance resolves all pointers
- **Frontmatter changes alter invocation behavior** → descriptions only widen accuracy; slash-command routing is unaffected; review by @janitooor

### Success Metrics
- ≥35KB net reduction in always-loaded-on-invocation SKILL.md bytes; 9 rules with exactly one canonical home each; zero drift-prone hand copies remaining

### Security Considerations
- D4.1 dedups the DELIVERY of security-relevant blocks (`input_guardrails`, `factual_grounding`, `zone_constraints`) — the semantic-equivalence gate proves the rule text is preserved verbatim, and the drift validator makes future tampering with any single copy impossible (single-source + hash-stamped). `disallowed-tools` frontmatter, the review quota, verdict machinery, and every hook are untouched (Scope Contract).

---

## Sprint 5: Always-Loaded Diet (SAFE rows only) + E2E Validation

**Duration:** ~1 day. **Zone:** System. **Verdicts consumed:** SAFE (Post-PR section, Safety Hooks section ×2, Merge M3–M5 as scoped by the mechanical verdict, root CLAUDE.md boilerplate, KF-intake trim, Conventions dedup).

### Sprint Goal
The four verified-SAFE shrinks land in the always-loaded files — routed through the constraint registry where rows are generated — and the whole cycle is validated end-to-end with a recorded before/after context measurement.

### Deliverables
- [x] **D5.1** — Post-PR Bridgebuilder Loop section → 2 lines: activation flag + the `.run/bridge-pending-bugs.jsonl` → next-`/bug` consumption contract (verified as the SOLE carrier of that contract — it MUST survive); detail lives in the referenced proposal doc
- [x] **D5.2** — Safety Hooks section → 2–3 lines keeping exactly: "active in ALL modes", the fence-not-boundary caveat, deny-rules pointer, `hooks-reference.md` pointer
- [x] **D5.3** — Merge Constraints: M1 (use orchestrator) + M2 (never hand-tag) rows KEPT in CLAUDE.loa.md; M3–M5 (script properties: RTFM non-blocking, idempotency, cycle-only full pipeline) moved to `post-merge-orchestrator.sh` header + deploying-infrastructure SKILL.md automated_mode section — via constraints.json layer edits + SECTIONS arrays in BOTH `generate-constraints.sh` and `validate-constraints.sh`
- [x] **D5.4** — root CLAUDE.md: "How This Works" boilerplate + stale byte-count deleted; Context-Intake section trimmed ~30% (dead-end parentheticals the KF hook already surfaces) keeping: recurrence-≥3 rule, Reading-guide-only discipline, kf-write-lib contribution commands; Conventions triple-statement deduped
- [x] **D5.5** — cycle E2E: full validation suite + fresh-mount smoke + before/after context measurement recorded in a cycle report

### Acceptance Criteria
- [ ] `generate-constraints.sh` + `validate-constraints.sh` green after D5.3 (generated blocks and SECTIONS arrays consistent); hand-edits never touch generated block interiors
- [ ] `agents-md-gen.sh` output: AGENTS.md still carries M2's NEVER row (hand-tagging is the one out-of-pipeline violation; no hook blocks `git tag` — the row is load-bearing); M1 row present
- [ ] Post-PR contract grep: `bridge-pending-bugs.jsonl` appears in the surviving 2-liner
- [ ] Always-loaded byte count (CLAUDE.md + CLAUDE.loa.md): ≤ ~26KB (from 30.3KB), measured and recorded
- [ ] **E2E (end-to-end)**: full bats suite; `validate-skill-capabilities.sh`; `validate-constraints.sh`; `check-loa.sh` on this repo AND a fresh `mount-loa.sh` mount; `butterfreezone-validate.sh`; `grimoire-index.sh --validate`; a smoke `/loa` + one skill invocation on the fresh mount proving skills load with the slimmed context
- [ ] Cycle report at `grimoires/loa/reports/context-diet-cycle-121.md`: per-tier before/after bytes, list of every deleted/shrunk file with its verdict citation, and the deferred SAFE_WITH_MECHANISM backlog for the follow-up cycle

### Technical Tasks

#### Task 5.1 — Post-PR + Safety Hooks shrinks (D5.1, D5.2) → **[G-5]**
- [ ] Hand-prose edits (neither section is constraint-generated — verified); keep-lists exactly per verdicts

#### Task 5.2 — Merge M3–M5 relocation via registry (D5.3) → **[G-5]**
- [ ] constraints.json layer retarget + both SECTIONS arrays + orchestrator header comments + deploying-infrastructure automated_mode text; regenerate; validate

#### Task 5.3 — root CLAUDE.md trim (D5.4) → **[G-5]**
- [ ] Boilerplate deletion + intake trim per keep-list; verify the SessionStart KF hook output still complements (not duplicates) the surviving intake text

#### Task 5.4 — cycle E2E + measurement report (D5.5) → **[G-1] [G-2] [G-3] [G-4] [G-5]**
- [ ] Run the full E2E battery; author the report; file beads for the deferred SAFE_WITH_MECHANISM items as the follow-up cycle's backlog

### Dependencies
- Sprints 1–4 merged (the measurement and E2E cover the whole cycle).

### Risks & Mitigation
- **Registry edit breaks generated-table validation downstream** → both generator and validator SECTIONS arrays edited together; fresh-mount check in acceptance
- **AGENTS.md projection silently loses a NEVER row** → explicit acceptance grep on agents-md-gen output (the audit's cross-tool-projection lesson)
- **Post-PR contract line dropped in compression** → explicit acceptance grep

### Success Metrics
- Always-loaded context ~7.6K → ~6.5K tokens with every removed statement still present at its point of use or in its enforcer
- Cycle report published; SAFE_WITH_MECHANISM backlog beaded for the next cycle

### Security Considerations
- Fence-not-boundary caveat and "active in ALL modes" survive verbatim (they prevent over-trusting the fence in autonomous mode). M2's hand-tag prohibition keeps an always-loaded row precisely BECAUSE `Bash(git tag:*)` is allowlisted and unfenced.

---

## Appendix

### Goal Mapping

| Goal | Statement | Sprints | Verification |
|------|-----------|---------|--------------|
| G-1 | All context files with no real loading path are deleted/relocated with validator couplings fixed same-commit; zero dangling refs | 1 | grep gates + check-loa fresh-mount + bats |
| G-2 | Obsolete/duplicated prose shrunk in place to its load-bearing core; no inbound pointer breaks; no guardrail floor softened | 2 | inbound-ref greps + validate-constraints |
| G-3 | One memory story (auto-memory personal / grimoire team-shared); dead subsystem gone; NOTES.md junk-free and indexed; KF recurrence machine-parseable | 3 | junk-writer proof + INDEX --validate |
| G-4 | Skills rules single-sourced via generated includes; oversized skills split; filler deleted; frontmatter invocation-accurate | 4 | drift validator + semantic-equivalence diff + skill-capabilities lint |
| G-5 | Always-loaded files shed verified-SAFE weight only, registry-routed, with AGENTS.md projections intact; whole cycle E2E-validated and measured | 5 | byte measurement + agents-md grep + E2E battery |

### Verdict provenance

Every task above cites a finding from workflow `wf_f9c99bce-302` (2026-07-29). Verdict tally over 41 removal candidates: 21 SAFE (this cycle), 10 SAFE_WITH_MECHANISM (deferred — backlog beaded in Task 5.4), 8 RISKY + 2 KEEP (excluded; see Scope Contract). Auditors: 6 layer readers; verifiers ran hooks live to test bypass claims before ruling.

### Out-of-cycle follow-ups (bead at Task 5.4, do NOT implement here)

1. `mechanical-floor-extensions` cycle: wire `implement-gate.sh`; FR-SZ `.claude/` root; `git tag` fence; stash-swallow patterns; `/bug` eligibility validator; C-BRIDGE/C-PERM/C-MERGE/C-TEAM skill-md renders + post-compact SKILL.md re-surfacing; grounding-ratio landing then `grounding-enforcement.md` disposal; input_guardrails hookification
2. Re-measure Read-before-Write error rate under Opus 5/Fable 5 (flips the RISKY row to SAFE or confirms keep)
3. Karpathy section compression — operator decision + ponytail-parity re-audit only
4. post-merge.yml unattended agent: consider model upgrade + rendering C-MERGE into its prompt (SAFE_WITH_MECHANISM finding)
