# Karpathy Principles Protocol

> **Version**: 2.0 (cycle-121 — gutted to enforcement pointers; the principle text was fully restated here AND in CLAUDE.loa.md, a proven dual-maintenance burden, e.g. #1074 had to update both)
> **Canonical text**: the **"Karpathy Principles" section of `.claude/loa/CLAUDE.loa.md`** — loaded into context every session. It is the single authoritative statement (cycle-119); NEVER restate the principles here or in skills. Never soften the CLAUDE.loa.md floor ("the floor above is never softened").
> **Source**: [Andrej Karpathy's LLM Coding Guidelines](https://github.com/forrestchang/andrej-karpathy-skills)

## Enforcement map

| Principle | Mechanism | Where |
|-----------|-----------|-------|
| 1 Think Before Coding | judgment + `AskUserQuestion` (prose-only in v1) | CLAUDE.loa.md canonical text |
| 2 Simplicity First | `simplicity_intensity` config + audit-gate floor (C-PROC-011) | `.loa.config.yaml.example` `karpathy_principles:` block (~:2795) |
| 3 Surgical Changes | PostToolUse:Write\|Edit diff-size hook, warn-by-default | `.claude/hooks/quality/karpathy-surgical-diff-check.sh` (#961; `surgical_diff_warning`, `diff_lines_per_task`) |
| 4 Goal-Driven | success-criteria gate at /implement entry | `implementing-tasks/SKILL.md` `<karpathy_goal_driven_gate>` (`require_success_criteria`) |

Trajectory events: `grimoires/loa/a2a/trajectory/karpathy-{date}.jsonl` (schema `.claude/data/trajectory-schemas/karpathy-check.payload.schema.json`).

Config keys: `.loa.config.yaml.example` `karpathy_principles:` — `surface_assumptions`, `simplicity_intensity` (full | ultra; no advise-only level), `surgical_diff_warning`, `diff_lines_per_task` (default 100), `require_success_criteria`, plus v2-reserved keys.

Enforcement history/runbook: `grimoires/loa/runbooks/karpathy-enforcement.md` (PRs #960/#961).
