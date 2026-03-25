# Sprint Plan: User-Friendly Release Summaries & Zone-Aware Filtering

**Cycle**: cycle-052
**PRD**: grimoires/loa/prd.md
**SDD**: grimoires/loa/sdd.md
**Created**: 2026-03-25
**Sprints**: 2 (global IDs: 107-108)
**Total FRs**: 2

## Sprint Overview

Two sprints delivering user-friendly release summaries and zone-aware downstream filtering. Sprint 107 builds the shared zone classification library and summary generator. Sprint 108 adds downstream filtering to the release pipeline.

| Sprint | Label | FRs | Dependency |
|--------|-------|-----|------------|
| 1 | User-Friendly Release Summaries | FR-1 | None |
| 2 | Zone-Aware Release Filtering | FR-2 | Sprint 1 (zone classification library) |

---

## Sprint 107: User-Friendly Release Summaries

**Global ID**: 107
**FRs**: FR-1
**Rationale**: Builds the shared zone classification library that both FR-1 and FR-2 depend on, plus the summary generator and update-loa.sh integration.

### Tasks

| ID | Task | Acceptance Criteria |
|----|------|---------------------|
| T1.1 | Create `classify-commit-zone.sh` (shared library) | File at `.claude/scripts/classify-commit-zone.sh` (executable). Classifies commits into `system-only`, `state-only`, `app`, `mixed-internal` zones based on files touched. Supports single commit and `--batch <from>..<to>` mode. Exports `is_loa_repo()` function. Uses `git diff-tree` plumbing command. |
| T1.2 | Create `generate-release-summary.sh` | File at `.claude/scripts/generate-release-summary.sh` (executable). Parses CHANGELOG.md for given version. Emoji mapping for conventional commit types. Max 5 summary lines, truncated at 80 chars. `--json` flag for structured output. `--downstream` flag filters via `classify-commit-zone.sh`. Graceful fallback when CHANGELOG section not found. |
| T1.3 | Integrate summary into `update-loa.sh` | Captures `old_version` before update. Calls `generate-release-summary.sh` after successful update. Displays "What's new in v{version}:" header. Reads `update.show_release_summary` from config (default true). Silent fallback if summary script fails or is missing. |
| T1.4 | Write tests for classify-commit-zone.sh and generate-release-summary.sh | `tests/unit/classify-commit-zone.bats` (~14 tests): system-only commit, state-only commit, app commit, mixed-internal commit, batch mode output, empty commit, merge commit, is_loa_repo true/false, path edge cases. `tests/unit/generate-release-summary.bats` (~14 tests): basic parsing, emoji mapping per type, max 5 lines enforcement, 80-char truncation, --json structure, --downstream filtering, missing version fallback, breaking change priority, non-conventional entry fallback. All tests pass in isolation. |

---

## Sprint 108: Zone-Aware Release Filtering

**Global ID**: 108
**FRs**: FR-2
**Rationale**: Builds on the zone classification library from Sprint 107 to add downstream-aware filtering to the release pipeline.

### Tasks

| ID | Task | Acceptance Criteria |
|----|------|---------------------|
| T2.1 | Add `--downstream` flag to `semver-bump.sh` | Filters commits through `classify-commit-zone.sh`. Excludes `system-only` and `state-only` commits from bump calculation. System-only-only releases produce no downstream bump (exit 0, no output). `app` and `mixed-internal` commits drive version computation. Existing behavior unchanged without flag. |
| T2.2 | Add `--downstream` flag to `post-merge-orchestrator.sh` | Passes `--downstream` to `semver-bump.sh`. Filters CHANGELOG entries to exclude system-only changes. Release notes include only downstream-relevant entries. Auto-detect: if repo is not loa source (via `is_loa_repo()`), automatically applies `--downstream`. Existing behavior unchanged without flag. |
| T2.3 | Write downstream tests | `tests/unit/semver-bump-downstream.bats` (~6 tests): system-only commits produce no bump, app commits produce normal bump, mixed commits filter correctly, flag absent preserves default, state-only excluded, edge case with all filtered. Integration tests (~5 tests): end-to-end pipeline with --downstream, auto-detect behavior, CHANGELOG filtering, release notes content, JSON output verification. |
| T2.4 | Update config and docs | `.loa.config.yaml.example`: add `update.show_release_summary: true` with comment. Verify existing config schema compatibility. |
