# Phase 1: Growth & Virality (SDD)

## Overview
This document serves as the Software Design Document (SDD) and Task List for Phase 1 of the `5amenha` roadmap. Phase 1 focuses on organic growth, social hooks, and UI upgrades to increase virality and user retention.

> **Note:** All tasks must follow the TDD approach prescribed in `ROADMAP_RULES.md`. Write tests before or alongside implementation.

---

## Task List & Implementation Details

### 1. 📤 Share & Social Hooks

#### S1: Share Results Grid 
**Goal:** Allow users to copy a Wordle-style colored emoji grid (🟩🟨⬜) after solving.
- [x] **Domain:** Create `ResultGridFormatter` service to parse game state (attempts vs correct word) to appropriate emojis.
- [x] **Tests (Unit):** Ensure `ResultGridFormatter` returns valid emoji strings for various game states (perfect win, multi-attempt win, loss).
- [x] **UI:** Add a "Share" floating action button or icon to the End Game dialog. Utilize `share_plus` or clipboard APIs to copy text.
- [x] **Tests (Widget):** Mock clipboard copy and ensure tapping "Share" dispatches correct data.

#### S2: Daily Challenge Mode
**Goal:** One shared word per day, identical for all users.
- [ ] **Domain:** Implement `DailyWordProvider` / `DailyModeRepository`. The daily word can be pseudo-random based on the current date seed, preventing users from getting randomized endless words.
- [ ] **Tests (Unit):** Test `DailyWordProvider` returns consistent target words for a given date across multiple calls, but different words on different dates.
- [ ] **UI:** Add a distinct entry point on the Mode Selection screen. Prevent users from playing multiple times a day on the same date.
- [ ] **Tests (Widget):** Ensure playing a daily challenge disables the challenge button until the next day.

#### S3: Daily Streak Push Notification
**Goal:** Send local push notifications saying 'Your streak is waiting 🔥'.
- [ ] **Domain:** Integrate `flutter_local_notifications`. Create a `NotificationService` wrapper to schedule notifications 24 hours after the last session.
- [ ] **Tests (Unit):** Test notification scheduling logic resets the timer correctly on new sessions.
- [ ] **UI:** Prompt users for notification permissions unobtrusively after their first win.
- [ ] **Tests (Widget):** Ensure permission dialogues trigger correctly.

#### S4: Word Meaning Reveal
**Goal:** Show definitions/context after solving the puzzle.
- [ ] **Domain:** Expand the bundled `word_bank` or dictionary JSON to include a definition or context string per target word, OR fetch from a local fallback list.
- [ ] **Tests (Unit):** Verify the `GameController` or `stats` domain can serve a valid definition object string for a given word.
- [ ] **UI:** Expand the End Game summary dialog to showcase this 'Educational Fact' cleanly.
- [ ] **Tests (Widget):** Verify the definition text populates correctly on win/loss states.

#### S5: Image Share for Help & Results
**Goal:** Generate and share an elegant branded screenshot (including game name, icon, puzzle, category, and status) instead of just emoji text. Allow "Share to get help" if stuck.
- [ ] **Domain/UI:** Integrate a widget-to-image package (or use `RepaintBoundary`) to capture a custom off-screen widget containing all relevant data cleanly formatted.
- [ ] **Tests (Unit):** Ensure screenshot saving logic caches file to temporary directory before sharing.

---

### 2. 🎨 UI / Visual Upgrade

#### U1: Tile Depth & Shadow
**Goal:** Add tactile depth via subtle shadows on tiles.
- [x] **UI Design:** Update the core `TileWidget`. Add a subtle `BoxShadow` based on the status of the tile (empty, filled, correct, absent, present).
- [x] **Tests (Widget):** Golden test or property check that the correct shadow is rendered per tile state.

#### U2: Streak Fire Badge In-Game
**Goal:** Highlight the streak counter with 🔥 during gameplay.
- [x] **UI Design:** Place an animated streak badge (using implicitly animated widgets) in the game top app bar or hero layout area.
- [x] **Tests (Widget):** Inject mock `PlayerStats` with an active streak > 0 and verify the badge appears.

#### U3: Mode Selection Redesign
**Goal:** Replace vertical scrolling with horizontal swipe cards for modes.
- [ ] **UI Design:** Implement a generic `PageView` or unconstrained `ListView(scrollDirection: Axis.horizontal)` for `ModeSelectionScreen`. Refactor `ModeCard` components to behave securely in a horizontal plane.
- [ ] **Tests (Widget):** Swipe right/left gestures verify the mode selection updates.

#### U4: Rename Mode Labels
**Goal:** Update technical mode names to feeling-based names ('⚡ سريع' / '⚖️ متوازن' / '🧠 تحدي').
- [ ] **Domain/UI:** Update the localization or string constants mapping enum values (e.g., `GameMode.threeLetter` -> '⚡ سريع').
- [ ] **Tests (Unit):** Validate the String extension/mapper maps correctly.

---

## Verification & Manual Testing Guidelines

Once implemented:
1. Play through the endless mode and verify UI changes (U1, U2, U4, S4, S1).
2. Adjust system clock +1 Day and verify Daily Challenge (S2) accessibility.
3. Observe Android/iOS local notifications trigger (S3).
4. Share the results to clipboard and paste in a local text editor to verify emoji outputs.
