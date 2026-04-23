# Phase 0: Foundation (SDD)

## Overview
This document serves as the Software Design Document (SDD) and execution checklist for Phase 0 of the `5amenha` roadmap. Phase 0 exists to close the remaining solo-play quality gaps before any later roadmap work continues.

> **Note:** All work in this phase should follow the TDD guidance in `ROADMAP_RULES.md`. Add or update unit and widget tests before or alongside implementation.

---

## Goals

- Make core guess entry feel complete and readable on the first play session.
- Remove reliability issues around validation, persistence, and keyboard/layout behavior.
- Land missing baseline polish without disrupting the current architecture or already-shipped Phase 1 work.

## Non-Goals

- No new backend, auth, multiplayer, or online content dependencies.
- No redesign of game rules, scoring model, or phase 1 social flows.
- No broad architecture rewrite unless a small extraction is required to make testing practical.

---

## Task List & Implementation Details

### 1. Core Gameplay Polish

#### C1: Keyboard letter coloring
**Goal:** Reflect used-letter feedback directly on the on-screen keyboard using the same result hierarchy already shown in the grid.
- [ ] **Domain/Application:** Define the keyboard-state mapping from submitted guesses to key status, with stable precedence so `correct` beats `present`, and `present` beats `absent`.
- [ ] **Tests (Unit):** Cover repeated guesses, duplicate letters, and status upgrades so a key never regresses visually after better evidence.
- [ ] **UI:** Render key colors consistently in the keyboard/input area across supported word lengths and game modes.
- [ ] **Tests (Widget):** Verify representative keys change color after submissions and preserve the highest-earned status.

#### C2: Auto-submit on full word
**Goal:** Reduce friction by automatically verifying a guess once the row reaches the required letter count.
- [ ] **Application:** Add a debounced auto-submit path triggered only when the active guess reaches the exact target length.
- [ ] **Tests (Unit):** Verify auto-submit fires once per completed guess, cancels if the input changes before the delay completes, and does not fire for partial/overflow states.
- [ ] **UI:** Keep manual verification behavior compatible with the new flow so there is still a safe fallback if auto-submit is disabled by state guards.
- [ ] **Tests (Widget):** Simulate typing a full guess and confirm submission occurs after the intended delay without duplicate submits.

#### C3: Tile flip animation
**Goal:** Add clear reveal feedback when a submitted row is evaluated.
- [ ] **UI:** Introduce a staged tile reveal animation for the submitted row without changing the underlying scoring logic.
- [ ] **Tests (Widget):** Verify the row enters the reveal state after submission and the tiles resolve in order rather than all at once.
- [ ] **Integration:** Ensure animation timing does not block end-of-round dialogs, input reset, or screen-reader-safe semantics.

#### C4: Shake animation on invalid word
**Goal:** Give immediate feedback when the submitted word is rejected by validation.
- [ ] **UI:** Add a row shake effect for invalid submissions only.
- [ ] **Tests (Widget):** Verify valid submissions do not trigger the shake and invalid submissions do.
- [ ] **Behavior:** Keep the current error messaging aligned with the shake so both signals describe the same failure case.

#### C5: Letter count progress dots
**Goal:** Show lightweight progress toward a complete guess while typing.
- [ ] **UI:** Add a small progress indicator near the input/composer that reflects entered-letter count against target length.
- [ ] **Tests (Widget):** Verify the indicator updates while typing, resets after submission, and adapts to different word lengths.

### 2. Stability & Bug Fixes

#### B1: Word validation edge cases
**Goal:** Normalize Arabic input and validation behavior across dictionary lookups, submitted guesses, and puzzle data.
- [ ] **Domain/Data:** Audit the current normalization path for hamza variants, ta marbuta, alef forms, and any existing diacritic handling.
- [ ] **Tests (Unit):** Add focused cases covering accepted equivalent forms, rejected malformed entries, and duplicate-letter edge cases.
- [ ] **Implementation:** Centralize normalization rules where practical so validation, puzzle sourcing, and comparison logic cannot silently diverge.

#### B2: State persistence on app kill
**Goal:** Ensure an in-progress round survives backgrounding, termination, and relaunch.
- [ ] **Application/Data:** Trace the current save points for game state and identify whether persistence is delayed, partial, or mode-specific.
- [ ] **Tests (Unit):** Verify state snapshots are written after meaningful progress transitions such as typing completion, submit resolution, skip, and round end.
- [ ] **Tests (Widget/Integration):** Recreate a partially played round, rebuild the screen/controller, and confirm the board/input/session restore cleanly.
- [ ] **Implementation:** Tighten persistence timing without adding redundant writes that would hurt responsiveness.

#### B3: Keyboard overlap fix
**Goal:** Keep the active row and primary input flow visible while the software keyboard is open.
- [ ] **UI/Layout:** Audit the current keyboard-aware layout behavior and remove cases where the keyboard obscures the active row or composer.
- [ ] **Tests (Widget):** Cover common small-height mobile layouts and verify the active play area remains visible when `viewInsets.bottom` is applied.
- [ ] **Behavior:** Preserve the existing compact typing mode and pinned verification affordance while removing overlap regressions.

---

## Suggested Delivery Order

1. B1 word validation edge cases
2. C1 keyboard letter coloring
3. C4 invalid-word shake feedback
4. C5 letter count progress dots
5. C2 auto-submit on full word
6. B3 keyboard overlap fix
7. B2 state persistence on app kill
8. C3 tile flip animation

This order starts with correctness and feedback primitives, then layers on interaction polish and persistence-sensitive behavior.

## Risks & Guardrails

- Auto-submit can create duplicate verification events if it races with the manual submit path.
- Keyboard coloring and validation normalization both need careful duplicate-letter coverage in Arabic word forms.
- Animation work must remain presentation-only and avoid coupling reveal timing to game-state correctness.
- Persistence changes can easily become mode-specific regressions if endless and daily sessions do not share the same save lifecycle.

---

## Verification & Manual Testing Guidelines

Once implementation for this phase is complete:
1. Play one full endless round and verify keyboard colors, progress dots, auto-submit, and reveal animations all feel coherent together.
2. Enter an invalid word and confirm the row shake and validation message appear without corrupting the current input state.
3. Start a round, background or kill the app, relaunch, and confirm the same in-progress board state is restored.
4. Test on a small mobile viewport and confirm the active row plus input flow remain visible when the keyboard is open.
5. Repeat the above on at least two word lengths to catch layout and validation differences.

## Manual Test Guide For Completed Phase 0 Items

### C1: Keyboard letter coloring
1. Start a new round and submit a guess containing at least one correct, one present, and one absent letter.
2. Confirm the on-screen keyboard updates those letters with matching statuses.
3. Submit another guess that upgrades a previously seen letter and confirm the key keeps the stronger status.

### C2: Auto-submit on full word
1. Type letters until the guess reaches the exact target length.
2. Confirm the guess submits automatically after the short delay without requiring a tap.
3. Type a final letter, then immediately edit the guess, and confirm the pending auto-submit does not fire incorrectly.

### C3: Tile flip animation
1. Submit a valid guess.
2. Confirm the tiles in the active row reveal in sequence with a visible flip or equivalent evaluation animation.
3. Verify the next interaction becomes available after the reveal completes.

### C4: Shake animation on invalid word
1. Enter a word that should fail validation.
2. Confirm the active row shakes and the input remains available for correction.
3. Submit a valid word next and confirm the shake does not appear.

### C5: Letter count progress dots
1. Start typing a guess and observe the progress indicator update with each entered letter.
2. Complete and submit the guess, then confirm the indicator resets for the next row.
3. Change to another word length mode and confirm the total dot count adapts correctly.

### B1: Word validation edge cases
1. Try representative Arabic variants already covered by the test cases, including hamza/alef edge forms.
2. Confirm accepted forms submit normally and malformed or unsupported forms are rejected consistently.
3. Verify duplicate-letter guesses still evaluate correctly after normalization changes.

### B2: State persistence on app kill
1. Start a round and make partial progress.
2. Background the app, terminate it fully, then relaunch.
3. Confirm the current puzzle, guesses, and active state resume from the saved session rather than resetting.

### B3: Keyboard overlap fix
1. Open a round on a phone-sized viewport and focus the input.
2. Confirm the software keyboard does not cover the active row or the primary submit flow.
3. Rotate or resize if applicable and verify the layout remains usable.
