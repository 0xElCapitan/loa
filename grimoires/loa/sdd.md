# SDD: User-Friendly Release Summaries & Zone-Aware Filtering

**Cycle**: cycle-052
**PRD**: grimoires/loa/prd.md
**Created**: 2026-03-25

## 1. Architecture Overview

Two features that improve the downstream consumer experience for Loa releases:

1. **FR-1: User-Friendly Release Summaries** — Human-readable, emoji-annotated summaries shown during `update-loa.sh` and available standalone via `generate-release-summary.sh`.
2. **FR-2: Zone-Aware Release Filtering** — `--downstream` flag on `semver-bump.sh` and `post-merge-orchestrator.sh` that filters commits by zone relevance, so downstream consumers only see changes that affect them.

Both features share a **zone classification library** (`classify-commit-zone.sh`) that categorizes commits by the files they touch.

**Implementation order** (dependency-driven):
1. Sprint 107: `classify-commit-zone.sh` → `generate-release-summary.sh` → `update-loa.sh` integration → tests
2. Sprint 108: `semver-bump.sh --downstream` → `post-merge-orchestrator.sh --downstream` → tests + config

## 2. Detailed Design

### 2.1 classify-commit-zone.sh (Shared Library)

**New file**: `.claude/scripts/classify-commit-zone.sh`

Classifies a commit (or range) into one of four zones based on files touched:

| Zone | Meaning | Pattern |
|------|---------|---------|
| `system-only` | Only `.claude/` files changed | All paths match `.claude/**` |
| `state-only` | Only state files changed | All paths match `grimoires/**`, `.beads/**`, `.ck/**`, `.run/**` |
| `app` | Only application code changed | All paths match `src/**`, `lib/**`, `app/**`, `tests/**` |
| `mixed-internal` | Multiple zones or unclassifiable | Fallback |

**Interface**:
```bash
# Single commit classification
classify-commit-zone.sh <commit-sha>
# Output: "system-only", "state-only", "app", or "mixed-internal"

# Batch mode: classify a range
classify-commit-zone.sh --batch <from>..<to>
# Output: one line per commit: "<sha> <zone>"

# Library function: is this a loa repo (has .claude/ dir)?
# Sourced by other scripts
is_loa_repo() → exit 0 if .claude/ exists, exit 1 otherwise
```

**Design decisions**:
- Uses `git diff-tree --no-commit-id --name-only -r <sha>` for file listing (plumbing command, stable output).
- Batch mode iterates `git rev-list` — no subshell-per-commit overhead.
- Zone classification is pure path prefix matching — no filesystem access needed beyond git.
- `is_loa_repo()` exported as a sourceable function for `update-loa.sh` and `post-merge-orchestrator.sh`.

### 2.2 generate-release-summary.sh

**New file**: `.claude/scripts/generate-release-summary.sh`

Parses CHANGELOG.md entries and produces a human-readable summary with emoji annotations.

**Interface**:
```bash
generate-release-summary.sh <version> [--json] [--downstream]
# Default: human-readable text to stdout
# --json: structured JSON output
# --downstream: filter out system-only and state-only entries
```

**Emoji mapping** (commit type → emoji):
| Type | Emoji | Example |
|------|-------|---------|
| feat | sparkles | New feature |
| fix | wrench | Bug fix |
| perf | zap | Performance |
| docs | book | Documentation |
| refactor | recycle | Refactoring |
| test | test_tube | Tests |
| chore | broom | Maintenance |
| ci | gear | CI/CD |
| breaking | warning | Breaking change |

**Output constraints**:
- Maximum 5 summary lines (most impactful entries selected by type priority: breaking > feat > fix > perf > rest).
- Lines truncated at 80 characters with ellipsis.
- `--downstream` flag uses `classify-commit-zone.sh` to exclude `system-only` and `state-only` commits.

**CHANGELOG parsing**:
- Reads `## [version]` section from CHANGELOG.md.
- Extracts conventional commit prefixes from entries.
- Falls back to "Update" category for non-conventional entries.

**JSON output schema**:
```json
{
  "version": "1.40.0",
  "summary_lines": ["sparkles New feature X", "wrench Fix for Y"],
  "total_changes": 12,
  "shown_changes": 5,
  "zones": {"system-only": 3, "app": 7, "mixed-internal": 2},
  "filtered": false
}
```

### 2.3 update-loa.sh Integration

**Modified file**: `.claude/scripts/update-loa.sh`

Changes:
1. Capture `old_version` before pull/merge.
2. After successful update, call `generate-release-summary.sh "$new_version"`.
3. Display summary to user with header: `What's new in v{version}:`.
4. Config toggle in `.loa.config.yaml`: `update.show_release_summary: true` (default).
5. Graceful degradation: if `generate-release-summary.sh` fails or is missing, skip summary silently.

### 2.4 semver-bump.sh --downstream (FR-2)

**Modified file**: `.claude/scripts/semver-bump.sh`

New `--downstream` flag:
- Filters commits through `classify-commit-zone.sh` before bump computation.
- Excludes `system-only` commits from the bump calculation.
- A release with only `system-only` changes produces no downstream bump (exit 0, no output).
- `state-only` commits are also excluded from downstream bumps.
- Remaining `app` and `mixed-internal` commits drive the version computation.

**Use case**: Downstream repos that consume Loa as a dependency can use `--downstream` to determine if a new Loa release actually affects them.

### 2.5 post-merge-orchestrator.sh --downstream (FR-2)

**Modified file**: `.claude/scripts/post-merge-orchestrator.sh`

New `--downstream` flag:
- Passes `--downstream` to `semver-bump.sh` for filtered bump.
- Filters CHANGELOG entries to exclude system-only changes.
- Release notes include only downstream-relevant entries.
- Auto-detect: if the repo is not the loa source repo (checked via `is_loa_repo()`), automatically applies `--downstream` behavior.

## 3. Cross-Cutting Concerns

### 3.1 System Zone Authorization

All new and modified scripts are in `.claude/scripts/` (System Zone). Authorized for this cycle.

### 3.2 Test Strategy

~40 tests across 3 test files:
- `tests/unit/classify-commit-zone.bats` (~14 tests): zone classification, batch mode, edge cases
- `tests/unit/generate-release-summary.bats` (~14 tests): parsing, emoji mapping, truncation, --json, --downstream
- `tests/unit/semver-bump-downstream.bats` (~6 tests): filtered bump, system-only skip, mixed commits
- Integration tests (~5 tests): end-to-end downstream pipeline

### 3.3 Config Surface

New keys in `.loa.config.yaml.example`:
```yaml
update:
  show_release_summary: true  # Display summary after update-loa.sh
```

## 4. File Manifest

### New files
| File | FR | Purpose |
|------|-----|---------|
| `.claude/scripts/classify-commit-zone.sh` | FR-1, FR-2 | Shared zone classification library |
| `.claude/scripts/generate-release-summary.sh` | FR-1 | Human-readable release summary generator |
| `tests/unit/classify-commit-zone.bats` | FR-1 | Zone classification tests |
| `tests/unit/generate-release-summary.bats` | FR-1 | Release summary tests |
| `tests/unit/semver-bump-downstream.bats` | FR-2 | Downstream bump tests |

### Modified files
| File | FR | Change |
|------|-----|--------|
| `.claude/scripts/update-loa.sh` | FR-1 | Capture old_version, call summary, config toggle |
| `.claude/scripts/semver-bump.sh` | FR-2 | Add --downstream zone-filtered bump |
| `.claude/scripts/post-merge-orchestrator.sh` | FR-2 | Add --downstream filtering, auto-detect |
| `.loa.config.yaml.example` | FR-1 | Add update.show_release_summary |

## 5. Sprint Mapping

| Sprint | Global ID | FRs | Rationale |
|--------|-----------|-----|-----------|
| Sprint 1 | 107 | FR-1 | Foundation (shared lib) + summary + integration + tests |
| Sprint 2 | 108 | FR-2 | Downstream filtering builds on zone classification from Sprint 1 |
