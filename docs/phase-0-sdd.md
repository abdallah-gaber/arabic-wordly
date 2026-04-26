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

#### C1: In-app Arabic keyboard
**Goal:** Replace the system soft keyboard during gameplay with a game-owned Arabic keyboard that supports status coloring, disabled absent keys, and direct tap input.
- [ ] **Domain/Application:** Define the keyboard-state mapping from submitted guesses to key status, with stable precedence so `correct` beats `present`, and `present` beats `absent`.
- [ ] **Domain/Application:** Define the shipped Arabic key layout, plus rules for which keys become disabled after they are proven absent.
- [ ] **Tests (Unit):** Cover repeated guesses, duplicate letters, status upgrades, and disabled-key edge cases so a key never regresses visually after better evidence.
- [ ] **UI:** Replace the gameplay `TextField` input path with an in-app Arabic keyboard surface, letter insertion, backspace, and submit actions.
- [ ] **UI:** Render key colors consistently across supported word lengths and game modes while keeping already-confirmed useful letters tappable.
- [ ] **Tests (Widget):** Verify representative keys change color after submissions, preserve the highest-earned status, and absent-only keys become non-interactive.

#### C2: Auto-submit on full word
**Goal:** Reduce friction by automatically verifying a guess once the in-app keyboard fills the row to the required letter count.
- [ ] **Application:** Add a debounced auto-submit path triggered only when the active guess reaches the exact target length from keyboard taps.
- [ ] **Tests (Unit):** Verify auto-submit fires once per completed guess, cancels if the input changes before the delay completes, and does not fire for partial/overflow states.
- [ ] **UI:** Keep a visible manual verification fallback on the keyboard surface when auto-submit is blocked by state guards or timing.
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
**Goal:** Show lightweight progress toward a complete guess while using the in-app keyboard.
- [ ] **UI:** Add a small progress indicator near the active input surface that reflects entered-letter count against target length.
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

#### B3: Keyboard layout stability
**Goal:** Keep the active row and primary input flow visible while the in-app keyboard is displayed.
- [ ] **UI/Layout:** Rework the current keyboard-aware layout so the game-owned keyboard occupies stable space without obscuring the active row or composer.
- [ ] **Tests (Widget):** Cover common small-height mobile layouts and verify the active play area remains visible with the in-app keyboard mounted.
- [ ] **Behavior:** Preserve the compact play layout and primary verification affordance while removing overlap regressions.

---

## Suggested Delivery Order

1. B1 word validation edge cases
2. C1 in-app Arabic keyboard
3. C4 invalid-word shake feedback
4. C5 letter count progress dots
5. C2 auto-submit on full word
6. B3 keyboard overlap fix
7. B2 state persistence on app kill
8. C3 tile flip animation

This order starts with correctness and feedback primitives, then layers on interaction polish and persistence-sensitive behavior.

## Risks & Guardrails

- Auto-submit can create duplicate verification events if it races with the manual submit path.
- Keyboard status rules and disabled-key behavior both need careful duplicate-letter coverage in Arabic word forms.
- Animation work must remain presentation-only and avoid coupling reveal timing to game-state correctness.
- Persistence changes can easily become mode-specific regressions if endless and daily sessions do not share the same save lifecycle.

## Immediate Follow-Up After Phase 0

These are intentionally queued after the remaining Phase 0 items, not inside them:

1. **Daily challenge completion flow**
   Fix the daily round result flow so a finished daily challenge does not present a misleading "next puzzle" action and always offers a clear exit path back to the broader app flow.
2. **Word bank, categories, and meanings quality pass**
   Review shipped puzzle words, category labels, and meaning text for accuracy and coherence. Replace mismatched category assignments and any placeholder or misleading definitions with curated content.

---

## Verification & Manual Testing Guidelines

Once implementation for this phase is complete:
1. Play one full endless round and verify the in-app keyboard, key colors, progress dots, auto-submit, and reveal animations all feel coherent together.
2. Enter an invalid word and confirm the row shake and validation message appear without corrupting the current input state.
3. Start a round, background or kill the app, relaunch, and confirm the same in-progress board state is restored.
4. Test on a small mobile viewport and confirm the active row plus input flow remain visible while the in-app keyboard is shown.
5. Repeat the above on at least two word lengths to catch layout and validation differences.

## Manual Test Guide For Completed Phase 0 Items

### C1: In-app Arabic keyboard
1. Start a new round and confirm the gameplay surface shows the app-owned Arabic keyboard instead of opening the system soft keyboard.
2. Tap letters to build a guess, use backspace to remove one, and confirm the active input updates immediately.
3. Submit a guess containing at least one correct, one present, and one absent letter.
4. Confirm the keyboard updates those letters with matching statuses and that absent-only keys become unavailable when appropriate.
5. Submit another guess that upgrades a previously seen letter and confirm the key keeps the stronger status.

### C2: Auto-submit on full word
1. Tap letters until the guess reaches the exact target length.
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

### B3: Keyboard layout stability
1. Open a round on a phone-sized viewport and confirm the in-app keyboard is visible without requiring focus.
2. Confirm the keyboard does not cover the active row or the primary submit flow.
3. Rotate or resize if applicable and verify the layout remains usable.
