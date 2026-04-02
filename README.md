# Arabic Wordly

Arabic Wordly is a Flutter implementation of a Wordle-style game using Arabic letters and words.

## Product Direction

The app is being delivered in phases. Phase 1 focuses on a playable single-puzzle experience with cached progress across Android, iOS, and web.

## Current Scope

- Open directly into the game.
- Resume the current puzzle from cache on every supported platform.
- Treat brand new users as new players and generate a fresh random puzzle.
- Move to the next puzzle when the player solves the current one.
- Replace the puzzle with a new random one when the player fails to solve it.
- Allow the player to request a new puzzle if they get stuck.
- Use a minimal, clean interface.
- Maintain automated tests and commit each validated phase before moving forward.

## Platforms

- Android
- iOS
- Web

## Workflow

1. Plan and document each phase in markdown.
2. Implement the phase.
3. Run formatting, analysis, and tests.
4. Commit and push the validated result.
