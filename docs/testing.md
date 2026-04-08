# Testing Checklist

Every phase must complete the following before commit:

- Format changed Dart files.
- Run static analysis.
- Run the full automated test suite.
- Smoke-check the startup flow after major UI or persistence changes.

## Commands

From the repo root:

- `dart format lib test docs`
- `flutter analyze`
- `flutter test`

## Phase 1 checks

- Guess evaluation covers exact, present, and absent letters.
- Duplicate-letter handling is validated.
- Cached state restores correctly.
- New puzzle generation happens on win, loss, and manual skip.

## Later slices (automated coverage to preserve)

When changing these areas, extend or run tests that cover:

- **Mode selection** — Widget tests assert the mode picker appears on cold start and lists all length modes (`test/features/game/presentation/game_screen_test.dart`).
- **Arabic text rules** — Distinct letter forms (e.g. hamza / alef variants), stripping tatweel/diacritics without folding letters that should stay distinct.
- **Hints** — `HintSelector` behavior; repository restores hint progress for a cached session.
- **Score and stats** — `PlayerStats` / score rules, persistence via `GameLocalRepository`, invalidation when rounds complete or skip.
- **Puzzle bank** — Minimum word counts per mode; distinct-form words where required.

## Shared test helpers (`test/support/`)

Reuse these instead of duplicating fakes in each file:

| File | Purpose |
|------|---------|
| [`in_memory_key_value_store.dart`](../test/support/in_memory_key_value_store.dart) | `KeyValueStore` fake for persistence tests and widget overrides |
| [`fixed_random.dart`](../test/support/fixed_random.dart) | `FixedRandom`, `FixedSequenceRandom` for deterministic `Random` |
| [`mutable_clock.dart`](../test/support/mutable_clock.dart) | Mutable time source for `clockProvider` overrides |
| [`widget_test_puzzle_bank.dart`](../test/support/widget_test_puzzle_bank.dart) | Curated `ArabicPuzzleBank` for game widget tests |
| [`game_test_overrides.dart`](../test/support/game_test_overrides.dart) | `gameScreenTestApp(...)` — `ProviderScope` + `MaterialApp` around `GameScreen` with standard overrides |

**Convention:** New widget tests that drive `GameScreen` should call `gameScreenTestApp` (and the shared bank) unless a custom bank or scope is required. Repository unit tests should use `InMemoryKeyValueStore` and `FixedRandom` from this folder.

**Imports:** Helpers live under `test/`, not `lib/`, so import them with **relative** paths (for example `import '../../../support/in_memory_key_value_store.dart';` from `test/features/game/data/`), not `package:arabic_wordly/test/...`.
