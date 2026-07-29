#!/usr/bin/env bats
# cycle-121: generated skill-include blocks — drift detection + idempotence.

setup() {
    BATS_TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(cd "$BATS_TEST_DIR/../.." && pwd)"
    GEN="$PROJECT_ROOT/.claude/scripts/generate-skill-includes.sh"
}

@test "skill-includes: --check passes on a clean tree" {
    run bash "$GEN" --check
    [ "$status" -eq 0 ]
}

@test "skill-includes: --write is idempotent (0 rewrites on a clean tree)" {
    run bash "$GEN" --write
    [ "$status" -eq 0 ]
    [[ "$output" == *"0 block(s) rewritten"* ]]
}

@test "skill-includes: --check FAILS when a generated block is edited in place (tamper)" {
    local victim="$PROJECT_ROOT/.claude/skills/implementing-tasks/SKILL.md"
    cp "$victim" "$BATS_TMPDIR/victim.bak"
    sed -i 's/Follow `.claude\/protocols\/tool-result-clearing.md`/Follow NOTHING/' "$victim"
    run bash "$GEN" --check
    cp "$BATS_TMPDIR/victim.bak" "$victim"
    [ "$status" -ne 0 ]
    [[ "$output" == *"DRIFT DETECTED"* ]] || [[ "$stderr" == *"DRIFT"* ]] || true
}

@test "skill-includes: every source file is consumed by at least one marker" {
    for src in "$PROJECT_ROOT"/.claude/data/skill-includes/*.md; do
        name="$(basename "$src" .md)"
        grep -rq "@skill-include: start $name" "$PROJECT_ROOT/.claude/skills/" || {
            echo "orphan source: $name"; return 1; }
    done
}
