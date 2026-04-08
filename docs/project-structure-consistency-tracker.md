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
| `docs-align` | Architecture, testing notes, docs index, README links | **Done** | Merged to `main` (docs slice). |
| `split-providers` | Extract Riverpod wiring from `game_controller.dart` | **Done** | On `main` (`game_providers.dart`, `main` composition root). |
| `split-game-screen` | Split `game_screen.dart` into smaller files | **Done** | On `main` (`presentation/game_screen/*.dart` parts). |
| `test-support` | `test/support/` helpers + migrate widget tests | **Done** | On `main`. |
| `naming-cleanup` | `HapticsService` vs utility; `game_models` clarity | **Done** | `AppHaptics` in `app_haptics.dart`; `game_models.dart` library doc. |
| `repo-hygiene` | `everything-claude-code/` ignore / move / document | **In PR** | Branch `chore/repo-hygiene-ignore-local-bundles`: gitignore + README note. |

## Local-only paths (intentionally not tracked)

- **`everything-claude-code/`** — Optional local Cursor/agent tooling tree. Keep it on disk if you use it; it is **gitignored** so clones and CI stay focused on the Flutter app.

## After each merge

1. `git checkout main && git pull`
2. Update the **Status** column and **Notes** in the table above.
3. Open the next branch from up-to-date `main`.

## Related docs

- [architecture.md](architecture.md) — layers, naming map, composition root (updated in `docs-align`).
- [testing.md](testing.md) — commands and coverage notes; extend when `test-support` lands.
