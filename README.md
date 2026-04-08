# خمنها | 5amenha

`5amenha` is a Flutter word game built around Arabic letters, offline-friendly play, and a clean multi-platform experience across Android, iOS, and web.

## What It Does

- Starts at a mode picker with 3, 4, 5, and 6-letter puzzle modes.
- Restores the current puzzle locally on every supported platform.
- Keeps progress cached independently for each mode.
- Supports replay flow with next puzzle, skip puzzle, and result dialogs.
- Adds timed hints that reveal correct letters and can later be connected to ads or rewards.

## Platforms

- Android
- iOS
- Web

## Current Roadmap

- Phase 1: Playable single-player core
- Phase 2: Mode expansion, hints, scoring, celebration, larger dictionaries
- Phase 3: Accessibility, polish, release readiness
- Phase 4: Multiplayer play

More planning details live in [docs/phases.md](docs/phases.md).

## Local Development

1. Install the Flutter SDK matching the repo toolchain.
2. Run `flutter pub get`.
3. Start the app with `flutter run -d chrome`, `flutter run -d ios`, or `flutter run -d android`.

## Validation

- `dart format lib test docs`
- `flutter analyze`
- `flutter test`

## Project Structure

- [lib/app](lib/app): app shell, theme, shared branding, and cross-cutting `services/` (e.g. `AppHaptics`)
- [lib/features/game](lib/features/game): game domain, persistence, controller, and UI
- [test/features/game](test/features/game): repository, rules, and widget coverage
- [test/support](test/support): shared test fakes and `gameScreenTestApp` (see [docs/testing.md](docs/testing.md))
- [docs](docs): phase plans, delivery notes, and roadmap docs — see [docs/README.md](docs/README.md) for an index

Layering, product vs package naming, and bootstrap (`main` / Riverpod) are summarized in [docs/architecture.md](docs/architecture.md).

## Contributing

Contributions are welcome as long as we keep the game stable, tested, and consistent with the Arabic-first UX.

1. Branch from `main`.
2. Add or update markdown planning notes when the change affects scope or roadmap.
3. Keep logic generic where possible so word-length modes and future multiplayer remain compatible.
4. Run formatting, analysis, and tests before opening a PR.
5. Prefer focused commits with clear messages.

## Design Direction

- Arabic-first UI with RTL support
- Minimal, readable layouts
- Offline-first game loop
- Configurable progression systems so hints, rewards, and future monetization hooks can evolve without rewriting the core puzzle flow

## Multiplayer Direction

The multiplayer planning pass is documented in [docs/phase-4-multiplayer-plan.md](docs/phase-4-multiplayer-plan.md). That document includes the recommended implementation shape and the product decisions still needed from your side.
