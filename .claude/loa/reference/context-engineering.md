# Context Engineering Reference

Pointer map for Loa's context/memory surfaces: what exists, where the detail lives, and what is actually wired. (cycle-121 rewrite — this file previously duplicated ~63% of its bytes from protocol files and taught pre-Claude-5 manual token accounting; the live mechanisms below replaced that.)

## What is wired (use these)

| Surface | Detail lives at | Status |
|---------|-----------------|--------|
| Tool-result clearing + NOTES.md synthesis | `context_discipline` blocks in each SKILL.md; `.claude/protocols/tool-result-clearing.md` | Active — the live context rule |
| Session recovery (tiered) | `.claude/protocols/session-continuity.md` | Active |
| Compaction survival | `pre-compact-marker.sh` (PreCompact) + `post-compact-reminder.sh` (UserPromptSubmit) — mechanical, zero thinking-budget | Active (hooks registered in settings.json) |
| Pre-clear validation | `.claude/protocols/synthesis-checkpoint.md` | Active |
| KF ledger surfacing | `loa-kf-surface.sh` (SessionStart) → generated `grimoires/loa/INDEX.md` → `known-failures.md` | Active — three-tier progressive disclosure |
| Cross-session memory | Claude Code auto-memory (harness-managed, per-user) + git-tracked team surfaces (KF ledger, GT files) + untracked per-operator NOTES.md (`.gitignore:293`) | Active |
| Context tooling scripts | `context-manager.sh`, `cache-manager.sh`, `condense.sh`, `early-exit.sh` — each script's `--help` | Available (low adoption) |

## What is NOT wired (do not rely on)

| Spec | Where it moved | Why |
|------|----------------|-----|
| Context-editing API-beta design (CONTEXT_NEAR_LIMIT signals) | `docs/integration/context-editing.md` | Unimplemented spec; only consumer is `docs/integration/runtime-contract.md` |
| Five-YAML memory schema | `docs/integration/memory-schema.md` | Never built; auto-memory owns the scope |
| Attention-budget zones, semantic decay timers, manual token estimation | deleted (cycle-121) | Old-model workarounds; contradicted live thresholds; zero KF evidence of the failure mode they guarded |

## Effort / extended thinking

Configured via `.loa.config.yaml` (see `.loa.config.yaml.example`); model tiers and budgets are governed by the multi-model substrate — see `.claude/loa/reference/multi-model-reference.md`. Do not hardcode model names from this file's history.
