# Phase 3 Slice 1: Mode-Aware UX Plan

## Goal

Refine the single-player game screen so 3 / 4 / 5 / 6-letter modes feel intentionally tuned rather than merely responsive.

## Scope

- Add mode-aware board sizing and spacing rules.
- Improve active-row visibility for the current attempt.
- Make the whole-word input feel more like part of the game board.
- Clarify hint states with stronger ready / locked / completed treatment.
- Improve result dialog hierarchy so outcomes read faster.

## Product Intent

- 3-letter mode should feel tighter and more focused, not sparse.
- 4-letter mode should stay near the visual baseline.
- 5-letter mode remains the reference layout.
- 6-letter mode should stay readable without crowding the action area.

## Validation

- `flutter analyze`
- `flutter test`
