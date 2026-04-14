# Phase 1 Plan

## Goal

Ship a clean, tested MVP that opens directly to a playable Arabic Wordly puzzle and preserves progress across Android, iOS, and web.

## Functional Requirements

- Launch directly into gameplay.
- Create a new random puzzle for a new user.
- Restore the current puzzle when cached progress exists.
- Advance to the next puzzle after a win.
- Start a new random puzzle after a loss.
- Provide a visible action to skip to a new puzzle when stuck.
- Keep the experience offline-first.

## Technical Decisions

- Flutter app with Material 3 and a minimal custom theme.
- `shared_preferences` for lightweight local persistence across platforms.
- `flutter_riverpod` for predictable state management and testability.
- Built-in Arabic word list bundled with the app.
- Pure Dart domain layer for fast unit testing.

## Definition of Done

- App runs on Android, iOS, and web targets.
- Automated tests cover domain logic and the main widget flow.
- `dart format`, `flutter analyze`, and `flutter test` pass.
- Changes are committed on a dedicated branch and pushed to GitHub.
