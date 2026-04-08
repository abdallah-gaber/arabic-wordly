# Architecture

## Naming map

The same product appears under several identifiers. Use this table when wiring stores, imports, or docs.

| Role | Value | Notes |
|------|--------|--------|
| Product / marketing | خمنها, **5amenha** | User-facing name in UI and README. |
| Dart package / imports | `arabic_wordly` | Declared in `pubspec.yaml`; all `package:arabic_wordly/...` imports. |
| Repository folder | `arabic-wordly` | Local path and GitHub repo slug. |
| Android application id | `com.abdallahgaber.arabic_wordly` | Store/build identifier; not the marketing name. |

## Phase 1 goals (baseline)

Phase 1 delivered an offline-first Arabic Wordly-style experience with deterministic game rules and cached puzzle state. Later phases added multiple word lengths, hints, scoring, and UI polish; the layering below still applies.

## Layers and code layout

| Layer | Responsibility | Location |
|--------|----------------|----------|
| App shell | `MaterialApp`, global RTL, theme, entry route | `lib/app/` |
| Presentation | Screens and widgets; Riverpod `Consumer` wiring | `lib/features/game/presentation/` |
| Application | Load/submit/reset/skip flows; Riverpod providers and notifiers | `lib/features/game/application/` (`game_providers.dart` for shared wiring, `game_controller.dart` for `GameController` and its family provider) |
| Domain | Puzzle model, Arabic rules, evaluation, hints, stats rules | `lib/features/game/domain/` |
| Data | Key-value persistence, puzzle bank, repository | `lib/features/game/data/` |

### `lib/app` in detail

- **`app.dart`** — `ArabicWordlyApp` (`MaterialApp`, RTL `Directionality`, initial `home`).
- **`app_branding.dart`** — Shared English/Arabic app naming constants.
- **`theme/app_theme.dart`** — Light theme and typography.
- **`services/`** — Cross-cutting **platform adapters** that are not game rules (e.g. `HapticsService`: static wrappers around `HapticFeedback`, no-op on web). Prefer this folder for similar small platform facades (analytics shape, etc.) rather than putting them under `features/game`.

## App shell and composition root

1. **`lib/main.dart`** calls `WidgetsFlutterBinding.ensureInitialized()`, obtains `SharedPreferences`, and runs the app inside a **`ProviderScope`**.
2. **`keyValueStoreProvider`** (defined in [`game_providers.dart`](../lib/features/game/application/game_providers.dart)) is **overridden** in `main.dart` with `SharedPreferencesKeyValueStore` so all reads/writes go to real storage in production; tests override the same provider with in-memory fakes. Game orchestration lives in [`game_controller.dart`](../lib/features/game/application/game_controller.dart), which re-exports `game_providers.dart` for a single import where useful.
3. **`ArabicWordlyApp`** sets `home` to **`ModeSelectionScreen`** (not directly to the in-game screen).

## Persistence

- Cross-platform **key-value** storage for active sessions **per mode** (word length).
- Session fields include answer, guesses, row state, attempts, completion, hint usage where applicable.
- **Player stats** (scores, streaks, aggregates) are stored through the same repository/cache layer and restored on launch.

## Game flow

1. App launches into the **mode selection** screen (3–6 letter modes).
2. User picks a mode and opens the **game screen** for that mode.
3. If no cached session exists for that mode, create a new puzzle and persist it.
4. If a cached unfinished session exists, restore it.
5. On solve, advance to a fresh puzzle (and update stats).
6. On exhausted attempts, replace with a new puzzle (and update stats).
7. Skip/reset actions replace the current puzzle as implemented in the controller/repository.

## Testing strategy

- **Unit tests** — Arabic normalization and guess evaluation, hint selection, stats/scoring rules, puzzle bank invariants.
- **Repository tests** — Serialization, per-mode isolation, stats persistence, backward-compatible cache fields.
- **Widget tests** — Mode selection, game screen flows (input, verify, win/skip/hints) with `ProviderScope` overrides; see [testing.md](testing.md).

For commands and pre-commit checks, see [testing.md](testing.md).
