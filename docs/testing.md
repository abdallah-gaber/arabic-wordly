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

## Shared test setup (convention)

Widget and integration-style tests often use the same Riverpod overrides (`keyValueStoreProvider`, `randomProvider`, `puzzleBankProvider`, `clockProvider`). When adding new tests, **mirror the overrides** from existing files until a shared `test/support/` helper library is introduced; then migrate new tests to use the shared helpers first.
