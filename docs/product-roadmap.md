# Product roadmap

## Current state

`5amenha` is already beyond the original MVP scope.

- Offline-first Arabic word game on Android, iOS, and web
- 3 / 4 / 5 / 6-letter endless modes
- Per-mode cached sessions
- Visible categories
- Cooldown-based smart hints
- Local score, streaks, skips, solve distribution, and per-mode summaries
- Mode-aware board and input layout
- Win/loss dialogs with richer round summaries
- Mobile typing-mode UX with inline verify, pinned verify above keyboard, and compact focused layout
- Riverpod architecture with automated coverage across domain, data, and UI

This means the next milestone is not "make single-player real." It is "turn the current baseline into a polished public-ready release, then prepare for daily mode, identity, and multiplayer safely."

## Locked product decisions

- Duplicate letters stay supported.
- Categories stay visible by default.
- Hints help accessibility and reduce score rather than blocking progression.
- Skips count as losses in stats while still being tracked separately.
- Web stays on text-field input in the near term.
- The first public release target is polished single-player with endless + daily.
- Stats should show one overall summary plus segmented endless / daily / multiplayer sections.
- Firebase is the initial backend target, but only behind app-owned interfaces.
- Multiplayer v1 is private-room based only.

## UX priorities

### Mode selection

- Add stronger emotional hooks around streak, progress, and return motivation.
- Make the screen feel more like a game hub and less like a static picker.
- Improve hierarchy so the most relevant mode choice and progress signals read first.
- Keep the layout simple, Arabic-first, and mobile-friendly.

### Game screen

- Keep the board visible while typing on mobile.
- Make input and verify feel like one interaction, not two disconnected steps.
- Reduce hint dominance and cognitive noise around secondary actions.
- Add more personality and motion to the grid, feedback states, and dialogs.
- Make the early game feel guided rather than harsh, without trivializing the answer.

## Gameplay and content strategy

### Near term

- Finish the UX refinement layer on the mode selection and game screens.
- Reduce friction in the first 10 seconds of play.
- Add daily mode with one deterministic puzzle per mode per date.
- Add shareable round summaries for daily and endless play.
- Add settings for haptics and sound plus a lightweight local profile layer.

### Content direction

- **V1**: keep the bundled static puzzle bank as the shipping dataset.
- **V2**: support remote JSON dataset updates with validation, versioning, and fallback to the bundled set.
- Do not depend on live APIs, scraping, or complex parsing for gameplay content.
- Preserve a manual curation path so content quality never depends entirely on remote automation.

## Backend readiness

### Architectural rule

Do not let Firebase types leak into domain, controller, or presentation layers.

### Contracts to add before cloud work

- `AuthService`
- `UserProfileRepository`
- `StatsSyncRepository`
- `DailyModeRepository`
- `MultiplayerRepository`
- `MatchChannel`

### Delivery order

1. Finish UX hierarchy and mobile flow polish.
2. Add local daily mode and share formatting.
3. Add local settings and lightweight profile placeholders.
4. Introduce app-owned backend interfaces and local-friendly implementations.
5. Add guest-first auth and optional account upgrade.
6. Add private-room multiplayer v1.

## Recent progress

### Mobile flow polish

- Added a typing-mode presentation state
- Moved verify into the composer flow
- Added a pinned verify action above the keyboard
- Tightened focused layout density and secondary content
- Improved mobile tap-to-dismiss and bottom spacing behavior

### Board feedback polish

- Added active-row preview while typing
- Added row shake feedback for rejected submit cases
- Strengthened tile reveal rhythm with a staggered reveal feel

### Dialog emotion polish

- Added a stronger result hero area for win and loss states
- Improved summary hierarchy so streak, retry tone, and answer reveal feel more intentional
- Kept the round-result actions simple while giving the moment more personality

## Next execution slices

### Next slice

**Early-game guidance and support balance**

- Improve the first-round guidance without trivializing the answer
- Rebalance hint visibility and support cues
- Make help systems feel supportive without stealing focus from the board

### Slice after that

**Daily mode and sharing UI**

- Add the daily entry flow on top of the local daily foundations
- Wire a real share action using the existing formatter
- Keep daily progress visually separate from endless mode

### Later

- Daily mode and sharing UI
- Settings and local profile layer
- Backend abstraction and Firebase infrastructure
- Guest auth with upgrade path
- Private-room multiplayer v1

### Exploration

- Renewable content pipeline
- Silent background refresh
- Category-aware sourcing and deduplication
- Future public matchmaking or ranked systems after private rooms prove out

## Focused UX refinement plan

This layer should sit on top of the current implementation. Keep the existing game rules, persistence, and architecture unless a small targeted change is needed to unlock a noticeably better interaction.

### Phase 1: Input and verify flow

**Goal**

Reduce friction between typing and confirming a guess so the main action feels immediate on mobile.

**Layout decision**

Use a keyboard-aware typing mode with this structure on mobile:

```text
[ Compressed Header ]
[ Grid with active row visible ]
[ Composer: input field + inline status ]
[ Fixed Verify Bar above keyboard ]
[ Keyboard ]
```

- The **composer** stays in the screen layout just below the grid.
- The **verify action** is visually tied to the composer, but on mobile typing state it becomes a **fixed bar above the keyboard** so it is always reachable.
- The fixed verify bar is not a second action path with different logic. It is the mobile presentation of the same primary action.
- The composer remains part of the scrollable layout; the fixed verify bar is pinned only while the text field is focused and the keyboard is open.
- Hints stay below the composer in the normal layout, but their body collapses during typing mode.
- The active row and at least part of the recent board must remain visible while typing.

**Changes**

- Turn input and verify into one tighter action area instead of two visually separate steps.
- Keep the active row and enough of the grid visible while the keyboard is open.
- Make the verify action feel inline with the current guess state.
- Reduce the amount of scrolling, header weight, and secondary content shown while typing.
- Add clearer empty, in-progress, and ready-to-submit states.

**Implementation order**

#### Step 1: Introduce typing mode

- Detect focused text-entry state and keyboard-open state.
- Add a dedicated typing-mode layout flag without redesigning the visual system yet.
- Keep the current screen structure, but allow the screen to switch into a reduced-information mode when typing starts.

**Technical approach**

- Detect keyboard visibility from `MediaQuery.viewInsets.bottom > 0`.
- Detect text-entry focus with the existing `TextEditingController` screen state plus a `FocusNode` owned by the `GameScreen` state object.
- Manage `typingMode` as **local widget state** inside `GameScreen` / `_GameScreenState`, not a Riverpod provider, because it is purely presentational and tied to focus/keyboard lifecycle.
- Pass `typingMode` and `keyboardVisible` into the existing layout parts (`screen_layout.dart`, `screen_header.dart`, `screen_input.dart`) through constructor parameters.

**Done criteria**

- Typing mode turns on when the input gains focus and the keyboard is visible.
- Typing mode turns off when focus is lost or the keyboard closes.
- No layout break appears on common phone sizes already covered by widget tests.
- Opening the keyboard does not cause obvious multi-step jumps or repeated scroll corrections.

**Risk notes**

- Focus state and keyboard state can drift if only one source is observed.
- If typing mode is derived in too many places, the UI can become inconsistent across header, grid, and input sections.

**Expected UI after step 1**

- The app can tell when the player is typing.
- The screen enters a stable typing state instead of behaving like the full default layout.
- No major visual redesign yet; this is the behavioral foundation.

#### Step 2: Move verify next to the input flow

- Move the primary verify action into the same visual composer area as the input.
- Remove the feeling that the player types in one place and confirms somewhere else.
- Keep the button disabled for empty and partial states.

**Technical approach**

- Keep the composer in `screen_input.dart`.
- Move the primary verify CTA into the composer widget tree so input, status, and verify share one layout block.
- Reuse the current `_isGuessReady` logic rather than adding a second readiness path.
- Remove any lower separate primary CTA so there is only one in-layout verify action before the fixed keyboard bar is added.

**Done criteria**

- Verify is visually attached to the input/composer area.
- No separate primary verify CTA remains below the composer.
- Empty and partial states still disable verification correctly.
- Current submit behavior remains unchanged when the button is pressed.

**Risk notes**

- Moving the CTA without adjusting composer spacing can make the block feel cramped on 6-letter mode.
- If the old CTA is left behind in compact states, the screen will still feel split.

**Expected UI after step 2**

- Composer reads as one unit: current guess + status + verify.
- Player no longer scans the lower screen to find the main action.

#### Step 3: Add fixed verify above the keyboard

- When typing mode is active on mobile, show a pinned verify bar above the keyboard.
- Keep it synchronized with the same input-validity logic as the inline composer action.
- Ensure the button is reachable without dismissing the keyboard.

**Technical approach**

- Implement the fixed verify bar inside `game_screen.dart` using the existing page `Stack`, not a separate `Overlay`.
- Anchor it with `Positioned` + `SafeArea`, using `MediaQuery.viewInsets.bottom` to place it just above the keyboard.
- Show it only when `typingMode` is true and the keyboard is visible on narrow/mobile layouts.
- Keep the inline composer action visually subordinate or hidden during this typing state so the user perceives one active submit target.

**Done criteria**

- While typing on mobile, verify is visible above the keyboard.
- The fixed verify bar is reachable without dismissing the keyboard.
- The bar uses the same enabled/disabled state as the composer logic.
- The bar disappears cleanly when typing mode ends.

**Risk notes**

- Incorrect bottom offset handling can put the bar under the keyboard or too high above it.
- If both inline and fixed CTAs feel equally primary at once, the UI will feel duplicated instead of clearer.

**Expected UI after step 3**

- While typing, verify is always visible and tappable above the keyboard.
- Player can type and submit without scroll or keyboard dismissal.

#### Step 4: Compress header and collapse hints

- Reduce header height during typing mode.
- Keep only the highest-value information visible while the keyboard is open.
- Collapse the hints panel body into a secondary toggle or summary row during typing.

**Technical approach**

- Keep compression logic in the existing presentation parts rather than creating a new route or screen.
- In `screen_header.dart`, switch to a reduced variant when `typingMode` is true.
- In `screen_input.dart` / `screen_hints.dart`, collapse hints to a summary/toggle row while typing and restore the full panel when typing ends.
- Avoid imperative scrolling as the main solution; let layout reduction create the needed space first.

**Done criteria**

- Header occupies less vertical space during typing.
- Hint details are not fully expanded during typing mode.
- Active row remains visible with more space than in the default layout.
- Returning from typing mode restores the richer layout cleanly.

**Risk notes**

- Over-compressing the header can remove useful context too aggressively.
- Hint collapse state may become confusing if it does not restore predictably after typing ends.

**Expected UI after step 4**

- Grid and active row gain more vertical priority.
- Hints and header stop competing with the main action during entry.

#### Step 5: Polish input states

- Finalize empty, partial, ready, and invalid states.
- Add subtle transitions for state changes.
- Make ready-to-submit feel rewarding without auto-submitting.
- Keep invalid feedback brief and non-blocking.

**Technical approach**

- Keep state styling in `screen_input.dart` with existing derived values such as current letter count and `_isGuessReady`.
- Use lightweight implicit Flutter animations already consistent with the screen, such as `AnimatedContainer`, `AnimatedSwitcher`, and short transform/shake treatment for invalid submit.
- Keep validation rules in the existing game logic and text-sanitization path; this step should refine presentation, not rewrite rules.

**Done criteria**

- Empty, partial, ready, and invalid states are visually distinct.
- Ready state feels clearly stronger than partial state.
- Invalid submit feedback is visible but brief.
- Keyboard `done` still submits only when input is valid and never auto-submits on completion alone.

**Risk notes**

- Too much color or motion can make the composer noisier instead of clearer.
- If invalid styling is applied too early, partial input may feel like an error state.

**Expected UI after step 5**

- The interaction feels intentionally designed rather than mechanically rearranged.
- The player gets clearer guidance from first tap to final verify.

**Affected files**

- `lib/features/game/presentation/game_screen.dart`
- `lib/features/game/presentation/game_screen/screen_layout.dart`
- `lib/features/game/presentation/game_screen/screen_input.dart`
- `lib/features/game/presentation/game_screen/screen_header.dart`
- `test/features/game/presentation/game_screen_test.dart`

**Expected UX result**

The player can type, review the board, and confirm a guess without the screen feeling split, hidden, or awkward under the keyboard.

**Execution constraints**

- Do not redesign the whole screen in one pass.
- Ship each step independently behind the existing gameplay flow.
- Keep each step runnable and testable before moving to the next one.
- Avoid rewriting game logic unless a small targeted change is necessary to support the interaction model.

### Phase 2: Grid feedback and motion

**Goal**

Make the board feel alive and game-like without adding noisy animation.

**Changes**

- Add subtle letter-entry animation in the active row.
- Strengthen valid, invalid, success, and failure feedback on submission.
- Improve tile reveal rhythm and color-state transitions.
- Add a more noticeable invalid-state response when a guess cannot be submitted.
- Make win/lose dialogs land with stronger motion and emotional payoff.

**Affected files**

- `lib/features/game/presentation/game_screen/screen_grid.dart`
- `lib/features/game/presentation/game_screen/screen_dialogs.dart`
- `lib/features/game/presentation/game_screen/screen_chips.dart`
- `lib/app/services/app_haptics.dart`
- `test/features/game/presentation/game_screen_test.dart`

**Expected UX result**

The grid feels responsive and satisfying, and the end-of-round moments feel rewarding rather than merely informative.

### Phase 3: Hints and difficulty balance

**Goal**

Keep hints accessible while making the main gameplay loop feel clearer and less harsh at the start.

**Changes**

- Make hints a secondary action visually in both placement and emphasis.
- Keep hints available, but reduce their dominance before the player engages with the first guess.
- Add light first-guess guidance that does not reveal the answer.
- Explore one small early-game support mechanic:
  - suggested starter prompt
  - first-round guidance copy
  - one-time per-round soft nudge after an invalid or empty start
- Keep duplicate-letter support and visible categories unchanged.
- Define a simple difficulty progression model later through tracks, streaks, or challenge structure rather than by weakening the core rules globally.

**Affected files**

- `lib/features/game/presentation/game_screen/screen_input.dart`
- `lib/features/game/presentation/game_screen/screen_hints.dart`
- `lib/features/game/application/game_controller.dart`
- `lib/features/game/domain/player_stats.dart`
- `test/features/game/presentation/game_screen_test.dart`

**Expected UX result**

Hints remain helpful but no longer pull attention away from guessing, and the first moments of a round feel less intimidating.

### Phase 4: Mode selection polish

**Goal**

Turn the mode picker into a stronger return screen with better emotional weight.

**Changes**

- Increase visual contrast between the hero summary and the mode cards.
- Highlight streak, progress, and “come back” value more clearly.
- Add lightweight progress hooks such as best streak, solved count, or daily readiness.
- Improve the relative weight of the recommended/default mode.
- Add more game-like motion or emphasis on card tap/hover/press states.

**Affected files**

- `lib/features/game/presentation/mode_selection_screen.dart`
- `lib/features/game/domain/player_stats.dart`
- `test/features/game/presentation/game_screen_test.dart`

**Expected UX result**

The mode selection screen feels like the start of a session, not just a router screen.

### Phase 5: Daily mode and simple data strategy

**Goal**

Prepare a practical content and retention path without overcomplicating sourcing.

**Changes**

- Ship V1 daily mode against the bundled static dataset.
- Keep one deterministic daily puzzle per mode per date.
- Add simple share formatting and daily completion persistence.
- Plan V2 around signed or versioned remote JSON updates only.
- Explicitly defer complex external feeds, API-generated words, and automated parsing pipelines.

**Affected files**

- `lib/features/game/domain/daily_mode_repository.dart`
- `lib/features/game/data/local_daily_mode_repository.dart`
- `lib/features/game/domain/share_result_formatter.dart`
- `lib/features/game/application/game_providers.dart`
- `test/features/game/data/local_daily_mode_repository_test.dart`
- `test/features/game/domain/share_result_formatter_test.dart`

**Expected UX result**

The game gains a reliable retention feature and a simple content path without introducing unstable data dependencies.
