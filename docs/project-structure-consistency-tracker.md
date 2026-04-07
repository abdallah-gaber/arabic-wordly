# Project structure consistency — tracker

This file is the **canonical, Git-tracked** checklist for the “project structure consistency” effort. Update it whenever a slice merges to `main` or when scope changes.

## Branch and pull request workflow

- **One discrete item = one branch = one PR** into `main`, unless two edits are truly inseparable (avoid bundling).
- **Merge each PR before** starting the next structural item so reviews stay small, `main` stays shippable, and bisect/debug stays easy.
- Suggested branch name pattern: `chore/<short-topic>` or `refactor/<short-topic>` (e.g. `refactor/game-providers`).

## Why this file exists (and Cursor plan TODOs did not)

- Agent “plan” TODOs live under **Cursor’s plan storage** (e.g. `.cursor/plans/` on a machine), which is often **not committed** to the repo.
- Those checkboxes are useful during a single session but are **not shared history** for collaborators or for you on another clone.
- This markdown file **is** in Git, so status is visible in PRs, blame, and `main`.

## Status

| ID | Scope | Status | Notes |
|----|--------|--------|--------|
| `merge-prereq` | Merge prior feature work; sync `main` | **Done** | Score/stats slice merged (e.g. PR #3). |
| `docs-align` | Architecture, testing notes, docs index, README links | **In PR** | Landed on branch `chore/project-structure-consistency` (commit `d681531`). Merge that PR to `main`, then set this row to **Done** here in a tiny follow-up or amend this file when adding the next slice. |
| `split-providers` | Extract Riverpod wiring from `game_controller.dart` | **Todo** | New branch after `docs-align` is on `main`. |
| `split-game-screen` | Split `game_screen.dart` into smaller files | **Todo** | New branch; do after or in parallel with `split-providers` only if you accept a larger PR (prefer sequential). |
| `test-support` | `test/support/` helpers + migrate widget tests | **Todo** | New branch. |
| `naming-cleanup` | `HapticsService` vs utility; `game_models` clarity | **Todo** | New branch. |
| `repo-hygiene` | `everything-claude-code/` ignore / move / document | **Todo** | New branch. |

## After each merge

1. `git checkout main && git pull`
2. Update the **Status** column and **Notes** in the table above.
3. Open the next branch from up-to-date `main`.

## Related docs

- [architecture.md](architecture.md) — layers, naming map, composition root (updated in `docs-align`).
- [testing.md](testing.md) — commands and coverage notes; extend when `test-support` lands.
