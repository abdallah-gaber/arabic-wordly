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
- [x] **Domain:** Implement `DailyWordProvider` / `DailyModeRepository`. The daily word can be pseudo-random based on the current date seed, preventing users from getting randomized endless words.
- [x] **Tests (Unit):** Test `DailyWordProvider` returns consistent target words for a given date across multiple calls, but different words on different dates.
- [x] **UI:** Add a distinct entry point on the Mode Selection screen. Prevent users from playing multiple times a day on the same date.
- [x] **Tests (Widget):** Ensure playing a daily challenge disables the challenge button until the next day.

#### S3: Daily Streak Push Notification
**Goal:** Send local push notifications saying 'Your streak is waiting 🔥'.
- [x] **Domain:** Integrate `flutter_local_notifications`. Create a `NotificationService` wrapper to schedule notifications 24 hours after the last session.
- [x] **Tests (Unit):** Test notification scheduling logic resets the timer correctly on new sessions.
- [x] **UI:** Prompt users for notification permissions unobtrusively after their first win.
- [x] **Tests (Widget):** Ensure permission dialogues trigger correctly.

#### S4: Word Meaning Reveal
**Goal:** Show definitions/context after solving the puzzle.
- [x] **Domain:** Expand the bundled `word_bank` or dictionary JSON to include a definition or context string per target word, OR fetch from a local fallback list.
- [x] **Tests (Unit):** Verify the `GameController` or `stats` domain can serve a valid definition object string for a given word.
- [x] **UI:** Expand the End Game summary dialog to showcase this 'Educational Fact' cleanly.
- [x] **Tests (Widget):** Verify the definition text populates correctly on win/loss states.

#### S5: Image Share for Help & Results
**Goal:** Generate and share an elegant branded screenshot (including game name, icon, puzzle, category, and status) instead of just emoji text. Allow "Share to get help" if stuck.
- [x] **Domain/UI:** Integrate a widget-to-image package (or use `RepaintBoundary`) to capture a custom off-screen widget containing all relevant data cleanly formatted.
- [x] **Tests (Unit):** Ensure screenshot saving logic caches file to temporary directory before sharing.

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
- [x] **UI Design:** Implement a generic `PageView` or unconstrained `ListView(scrollDirection: Axis.horizontal)` for `ModeSelectionScreen`. Refactor `ModeCard` components to behave securely in a horizontal plane.
- [x] **Tests (Widget):** Swipe right/left gestures verify the mode selection updates.

#### U4: Rename Mode Labels
**Goal:** Update technical mode names to feeling-based names ('⚡ سريع' / '⚖️ متوازن' / '🧠 تحدي').
- [x] **Domain/UI:** Update the localization or string constants mapping enum values (e.g., `GameMode.threeLetter` -> '⚡ سريع').
- [x] **Tests (Unit):** Validate the String extension/mapper maps correctly.

---

## Verification & Manual Testing Guidelines

Once implemented:
1. Play through the endless mode and verify UI changes (U1, U2, U4, S4, S1).
2. Adjust system clock +1 Day and verify Daily Challenge (S2) accessibility.
3. Observe Android/iOS local notifications trigger (S3).
4. Share the results to clipboard and paste in a local text editor to verify emoji outputs.

### Manual Test Guide For Completed Phase 1 Items

#### S2: Daily Challenge Mode
1. Open the mode selection screen and confirm the `التحدي اليومي` card is clearly visible and readable on a physical device.
2. Tap the daily card and verify it opens a daily round instead of endless mode.
3. Complete or lose the daily round, return to the mode selection screen, and confirm the same daily challenge does not reset on the same calendar day.
4. Advance the device date by one day and confirm a fresh daily puzzle becomes available.

#### S3: Daily Streak Push Notification
1. Launch the app and verify it no longer stalls on the splash screen during notification service initialization.
2. Win a round and confirm the one-time permission prompt appears after the result dialog flow.
3. Accept the prompt and verify the app requests local notification permission from the OS.
4. Play another round and confirm the reminder schedule is refreshed instead of stacking duplicate reminders.
5. Decline the prompt on a fresh install and verify the app continues normally without crashing or blocking navigation.

#### S4: Word Meaning Reveal
1. Solve a puzzle and confirm the end-of-round dialog shows a `معنى الكلمة` card beneath the summary.
2. Lose a puzzle and confirm the same definition/context panel still appears.
3. Verify the definition text matches the solved word instead of the category label alone.

#### S5: Image Share For Help & Results
1. Solve a round and confirm the result dialog now offers `مشاركة صورة` in addition to the text share action.
2. Tap `مشاركة صورة` and verify a branded image is shared that includes the game name, mode, category, status, and puzzle grid.
3. Start a round, make at least one guess, and confirm `شارك للمساعدة بصورة` becomes available in the input area.
4. Tap the help share action and verify the generated image shares current progress without revealing the answer.
5. On device, repeat the share flow and confirm the image is generated successfully from a temporary file path rather than failing inline.
