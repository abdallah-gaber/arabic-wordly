# Phase 3 Slice 2: Score And Stats Plan

## Goal

Add a local meta-progression layer that makes wins, losses, and skips feel meaningful while preparing the app for future profile sync.

## Scope

- Add persistent local player stats and per-mode progress.
- Introduce a score model with win bonuses and hint tradeoffs.
- Count skipped puzzles as losses while tracking them separately.
- Surface score and streak progress in the game flow and mode selection UI.
- Harden text input so only Arabic letters remain in the guess field across platforms.

## Validation

- `flutter analyze`
- `flutter test`
