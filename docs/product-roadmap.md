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

- Shorten the top intro copy and make it more purposeful.
- Remove or rewrite low-value supporting copy.
- Add more game spirit while keeping the clean Arabic-first direction.
- Improve Arabic wording and hierarchy around the summary stats.
- Make mode cards feel more rewarding and easier to scan quickly.

### Game screen

- Keep the board visually central while typing.
- Make `تحقق` the clearest primary action during guess entry.
- Reduce the visual dominance of hints before the player needs them.
- Collapse secondary panels on tighter mobile layouts.
- Make keyboard-aware flow less awkward on small screens.
- Keep win/loss moments more animated and emotionally readable.

## Gameplay and content strategy

### Near term

- Finish UX hierarchy and interaction polish on the two live screens.
- Add daily mode with one deterministic puzzle per mode per date.
- Add shareable round summaries for daily and endless play.
- Add settings for haptics and sound plus a lightweight local profile layer.

### Content direction

- Keep the bundled puzzle bank as the offline quality floor.
- Treat future content replenishment as an additive system, not a dependency.
- If online refresh is explored later, validate, deduplicate, and curate before new content becomes playable.
- Preserve a manual curation path so content quality never depends entirely on external APIs.

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

## Next execution slices

### Next slice

**UX hierarchy and flow polish**

- Refine mode-selection copy, hierarchy, and visual energy
- Strengthen the verify-first input flow
- Reduce hint-panel dominance and make it collapsible on mobile
- Keep the board easier to verify while the keyboard is open
- Push win/loss states further without losing clarity

### Slice after that

**Daily mode and sharing**

- One daily puzzle per mode per date
- Daily completion stored separately from endless progress
- Compact share result formatter
- Daily stats added under a separate track

### Later

- Settings and local profile layer
- Backend abstraction and Firebase infrastructure
- Guest auth with upgrade path
- Private-room multiplayer v1

### Exploration

- Renewable content pipeline
- Silent background refresh
- Category-aware sourcing and deduplication
- Future public matchmaking or ranked systems after private rooms prove out
