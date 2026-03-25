# PRD: DX Hardening — User-Facing Release Communication

**Cycle**: cycle-052
**Created**: 2026-03-25
**Sources**: Issues #445, #394 (community feedback from zkSoju)
**Flatline Review**: Pending

## 1. Problem Statement

Loa's release pipeline communicates effectively with framework operators but poorly with end users. Two related gaps exist:

1. **Opaque update summaries** (#445): `/update-loa` shows raw CHANGELOG output with cycle numbers, PR references, and internal jargon. Users who run `/update-loa` want to know what changed *for them* — not which internal scripts were refactored. The current output requires users to mentally parse conventional commit prefixes, filter out System Zone noise, and infer user-facing impact.

2. **Noisy downstream release notes** (#394): The post-merge automation (`post-merge-orchestrator.sh`, `semver-bump.sh`) treats all commits equally when generating release notes. On downstream projects (midi-interface, loa-finn, etc.), this means Loa framework cycles and System Zone changes appear in user-facing release notes. midi-interface v2.9.0 listed "cycles 016-031" alongside actual features — confusing users who don't know what a "cycle" is.

Both problems share a root cause: the release pipeline has no concept of commit *audience*. Every commit is treated as equally relevant to every reader. The Three-Zone Model already provides the taxonomy (System, State, App) — it just isn't applied to release communication.

> Sources: #445 (zkSoju, /update-loa feedback), #394 (zkSoju, midi-interface release notes)

## 2. Goals & Success Criteria

| Goal | Metric | Source |
|------|--------|--------|
| `/update-loa` shows a human-friendly "What's New" summary | Emoji-prefixed, jargon-free summary appears after successful update | #445 |
| Internal-only changes filtered from user summaries | Commits touching only `.claude/` or `grimoires/` excluded from friendly output | #445 |
| Downstream release notes exclude framework noise | System-only and State-only commits filtered from downstream release notes | #394 |
| Loa repo retains full release notes | All commits included for operator audience when repo is loa itself | #394 |
| Existing pipelines unaffected | No behavioral change without explicit opt-in flags or config | Both |

## 3. User Context

**Primary persona**: Loa user running `/update-loa` on a downstream project (loa-constructs, loa-finn, midi-interface). They want to know what's new in terms they understand — features, fixes, improvements — not framework internals.

**Secondary persona**: Loa operator reviewing release notes on the loa repo itself. They want the full picture including System Zone changes, because those changes are their product.

**Pain points** (from feedback):
- "I ran /update-loa and got a wall of cycle numbers and PR refs — what actually changed for me?" (#445)
- "midi-interface v2.9.0 release notes listed cycles 016-031 — my users don't know what cycles are" (#394)

## 4. Functional Requirements

### FR-1: User-Friendly /update-loa Summaries (#445)

**Problem**: `/update-loa` completes with `log "Update complete."` (line 472 of `update-loa.sh`) and shows raw CHANGELOG or git log output. Users want a concise, friendly summary of what changed.

**Solution**: Create `generate-release-summary.sh` that produces emoji-prefixed "What's New" summaries from CHANGELOG entries or conventional commits.

**Script behavior**:
1. Accept `--from <old_version>` and `--to <new_version>` arguments (or `--changelog <path>`)
2. Parse CHANGELOG.md entries between the two versions, or fall back to `git log --oneline <old_tag>..<new_tag>` conventional commits
3. Map conventional commit types to emojis:
   - `feat` -> (sparkles emoji)
   - `fix` -> (wrench emoji)
   - `docs` -> (memo emoji)
   - `security` / `sec` -> (lock emoji)
   - `perf` -> (rocket emoji)
   - `chore`, `refactor`, `ci`, `test`, `style`, `build` -> filtered out (internal)
4. Filter out commits that touch ONLY System Zone (`.claude/`) or State Zone (`grimoires/`, `.beads/`, `.run/`, `.ck/`) files — these are internal
5. For mixed commits (App + System files), include but describe only the App-facing change
6. Generate 1-5 summary lines, each: emoji + feature name + one-sentence "why it matters"
7. Output to stdout; `--json` flag for structured output

**Integration with update-loa.sh**:
- After successful merge (around line 472), call `generate-release-summary.sh --from <old_version> --to <new_version>`
- Display "What's New in v{version}:" header followed by summary lines
- If summary generation fails, fall back silently to current behavior (no regression)
- Configurable via `.loa.config.yaml`: `update_loa.friendly_summary: true` (default)

**Example output**:
```
What's New in v1.66.0:
(sparkles) Constructs are now first-class — say "observer" and the agent loads it
(sparkles) Personal workflow modes — define your own FEEL/DIG/ARCH/SHIP
(wrench) Stale construct packs now prefer your local fixes automatically
```

**Relationship to existing scripts**:
- `release-notes-gen.sh` (360 lines) generates full Markdown release notes for GitHub Releases — this is the *detailed* output for operators
- `generate-release-summary.sh` is the *condensed* output for end users — different audience, different format
- `upgrade-banner.sh` displays the cyberpunk completion banner — `generate-release-summary.sh` output appears *before* the banner

**Acceptance criteria**:
- `generate-release-summary.sh` parses CHANGELOG and produces emoji-prefixed summary
- Falls back to git log parsing when CHANGELOG section not found
- `update-loa.sh` shows friendly summary after successful update
- Internal changes (commits touching only `.claude/` or `grimoires/`) filtered out
- Each summary line: emoji + feature name + one-sentence description of user impact
- Maximum 5 lines per release (most impactful changes selected)
- `--json` flag outputs structured JSON for programmatic consumption
- Configurable via `.loa.config.yaml`: `update_loa.friendly_summary: true` (default)
- Disabling (`friendly_summary: false`) restores current behavior exactly
- BATS tests cover: CHANGELOG parsing, git log fallback, emoji mapping, internal change filtering, max 5 lines, JSON output, config toggle

### FR-2: Three-Zone-Aware Release Filtering (#394)

**Problem**: `post-merge-orchestrator.sh` (1005 lines) and `semver-bump.sh` (273 lines) include all commits in release notes and version bump computation regardless of audience. On downstream projects, this surfaces framework-internal changes in user-facing release notes.

**Solution**: Add zone-aware commit classification and filtering to the release pipeline.

**Zone classification logic**:
1. For each commit, inspect the list of changed files (`git diff-tree --no-commit-id --name-only -r <sha>`)
2. Classify each file by zone:
   - **System Zone**: paths starting with `.claude/`
   - **State Zone**: paths starting with `grimoires/`, `.beads/`, `.run/`, `.ck/`
   - **App Zone**: everything else
3. Classify each commit:
   - **System-only**: all changed files are System Zone
   - **State-only**: all changed files are State Zone
   - **App**: at least one changed file is App Zone (may also touch System/State)
   - **Mixed-internal**: changes span System + State but no App files

**Filtering rules by repo context**:
- **Downstream projects** (not the loa repo): exclude System-only, State-only, and Mixed-internal commits from release notes
- **Loa repo**: include all commits (operators want full visibility)

**Repo detection** (in priority order):
1. `git remote get-url origin` contains `0xHoneyJar/loa` or path ends in `/loa.git` -> loa repo
2. `.loa.config.yaml` has `project.name: loa` -> loa repo
3. Presence of `.claude/scripts/post-merge-orchestrator.sh` AND `CLAUDE.loa.md` in `.claude/loa/` -> loa repo (heuristic)
4. Default: downstream project

**Integration points**:

1. **`semver-bump.sh`**: Add `--downstream` flag
   - When set, exclude System-only and State-only commits from bump computation
   - A release that only contains System Zone changes gets no version bump on downstream
   - Without the flag, behavior unchanged (all commits count)

2. **`post-merge-orchestrator.sh`**: Add zone-aware filtering to the changelog and release notes phases
   - Changelog phase: filter commits before passing to changelog generation
   - Release notes phase: pass filtered commit list to `release-notes-gen.sh`
   - New `--downstream` flag propagated from orchestrator to semver-bump

3. **Shared helper**: Create `classify-commit-zone.sh` (or add `classify_commit_zone()` function to an existing lib)
   - Input: commit SHA
   - Output: zone classification (system-only | state-only | app | mixed-internal)
   - `--batch` mode for efficient processing of multiple commits (single `git log` call)

**Acceptance criteria**:
- Commits touching only `.claude/` files excluded from downstream release notes
- Commits touching only `grimoires/`, `.beads/`, `.run/`, `.ck/` files excluded from downstream release notes
- Commits touching App Zone files always included regardless of what else they touch
- Mixed commits (App + System) included; System files not separately highlighted
- Detection correctly identifies loa repo vs downstream project (all 3 heuristics)
- `semver-bump.sh --downstream` computes zone-filtered version bumps
- `semver-bump.sh` without `--downstream` behaves identically to current behavior
- `post-merge-orchestrator.sh --downstream` filters release notes by zone
- Existing behavior unchanged when `--downstream` is not passed
- BATS tests cover: zone classification for each category, repo detection heuristics, downstream vs loa filtering, semver bump with/without flag, edge case of release with only System commits

## 5. Technical & Non-Functional

- **System Zone authorization**: Target files include `.claude/scripts/update-loa.sh`, `.claude/scripts/semver-bump.sh`, `.claude/scripts/post-merge-orchestrator.sh`, and new scripts in `.claude/scripts/`. These are framework-internal DX improvements requiring authorized System Zone writes for this cycle. Safety hooks (`team-role-guard-write.sh`) must be accounted for in Agent Teams mode.
- **No new dependencies**: All parsing uses `git log`, `git diff-tree`, `jq`, `sed`, and `awk` — tools already available in the environment
- **Cross-platform**: Must work on macOS (Darwin) and Linux (Ubuntu CI). Use `compat-lib.sh` patterns where needed (e.g., `sed` flag differences)
- **Backward compatible**: Existing release pipelines work unchanged without new flags. `generate-release-summary.sh` is additive; zone filtering is opt-in via `--downstream`
- **All changes must include BATS tests**: Run in isolation (`bats tests/unit/<file>.bats`) to avoid interference with pre-existing failures
- **Config schema**: New config keys under `update_loa.friendly_summary` (boolean, default true). Document in `.loa.config.yaml.example`
- **Performance**: Zone classification must not add significant overhead. Batch mode (`--batch`) processes all commits in a single `git log` call rather than N individual `git diff-tree` calls
- **Existing test suite**: `tests/unit/release-notes-gen.bats` already exists — new tests should be in separate files to avoid conflicts

## 6. Scope

### Sprint breakdown

**Sprint 1**: User-friendly release summaries (FR-1)
- `generate-release-summary.sh`: CHANGELOG parsing, git log fallback, emoji mapping, zone filtering, max 5 lines, JSON output
- `update-loa.sh` integration: call summary script after successful update, config toggle
- `.loa.config.yaml.example` update: document `update_loa.friendly_summary`
- `tests/unit/generate-release-summary.bats`: comprehensive test coverage

**Sprint 2**: Zone-aware release filtering (FR-2)
- `classify-commit-zone.sh` (or shared function): zone classification logic, batch mode
- `semver-bump.sh` modifications: `--downstream` flag, zone-filtered bump computation
- `post-merge-orchestrator.sh` modifications: `--downstream` flag, zone-filtered changelog/release notes
- Repo detection logic (git remote, config, heuristic)
- `tests/unit/classify-commit-zone.bats`: zone classification tests
- `tests/unit/semver-bump-downstream.bats`: downstream bump tests
- Integration test: end-to-end pipeline with zone filtering

### In scope
- FR-1 and FR-2 as described above
- Config schema additions to `.loa.config.yaml.example`
- BATS test suites for all new functionality

### Out of scope
- Rewriting `release-notes-gen.sh` — it serves a different audience (operator-facing GitHub Release notes)
- Internationalization / localization of summary text
- Automatic detection of "user impact" from commit messages (summaries are derived from conventional commit subjects)
- Zone-aware filtering for non-release workflows (e.g., PR descriptions)
- Changes to `upgrade-banner.sh` — it remains a cosmetic post-update display

## 7. Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| CHANGELOG format varies between loa and downstream repos | Fall back to git log parsing when CHANGELOG sections not found |
| Zone classification may mis-categorize commits with unusual file paths | Use strict prefix matching (`.claude/`, `grimoires/`, etc.) with clear documentation of classification rules |
| `--downstream` flag adds API surface to semver-bump.sh and post-merge-orchestrator.sh | Flag is purely additive; without it, behavior is identical to current implementation |
| Emoji rendering varies across terminals | Emojis are decorative; summary text is readable without them. Could add `--no-emoji` flag if needed |
| Repo detection heuristics may false-positive on forks of loa | Priority order ensures git remote check (most reliable) runs first; heuristic is last resort |
| `generate-release-summary.sh` may produce low-quality summaries from terse commit messages | Max 5 lines + filtering ensures noise is bounded; quality improves as commit message discipline improves |
| FR-1 and FR-2 share zone classification logic | Extract shared `classify_commit_zone()` in Sprint 1 so Sprint 2 can reuse it |

## 8. Issue References

| Issue | Status | Disposition |
|-------|--------|-------------|
| #445 | Open | FR-1 (user-friendly /update-loa summaries) |
| #394 | Open | FR-2 (three-zone-aware release filtering) |

## 9. Flatline Review Log

**Phase**: Pending — PRD awaits Flatline review before SDD phase.
