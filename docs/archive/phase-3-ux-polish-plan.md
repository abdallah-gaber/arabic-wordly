# Phase 3 UX Polish Plan

## Goal

Refine moment-to-moment gameplay before multiplayer work starts, so the game feels more tactile, responsive, and intentionally animated across Android, iOS, and web.

## Scope

- Add haptic feedback on supported platforms for:
  - valid ready-to-submit input
  - hint reveal
  - skip/new puzzle
  - solved round
  - failed round
  - blocked or invalid actions
- Improve motion and visual rhythm for:
  - board reveal and tile state transitions
  - feedback banner updates
  - hint panel reveal states
  - round result dialog presentation
  - page atmosphere/background
- Refine interaction clarity:
  - stronger emphasis on ready states
  - softer transitions instead of abrupt updates
  - cleaner visual hierarchy around the active puzzle

## Constraints

- Keep the current minimal clean direction.
- Preserve responsiveness on phone, tablet, and web.
- Avoid heavy dependencies unless clearly needed.
- Keep behavior deterministic and testable.

## Validation

- `flutter analyze`
- `flutter test`
- Add or update widget tests where UX state changes affect rendering
