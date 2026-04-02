# Architecture

## Phase 1 Goals

Phase 1 delivers an offline-first Arabic Wordly experience with deterministic game rules and cached puzzle state.

## Proposed Layers

- `presentation`: Flutter widgets, theme, screens, and state wiring.
- `application`: orchestration for loading, submitting, resetting, and progressing puzzles.
- `domain`: puzzle entities, evaluation rules, Arabic word validation, and game policies.
- `data`: local cache persistence and built-in puzzle source.

## Persistence

- Use a cross-platform key-value cache for the active session.
- Persist whether the user has ever started a game.
- Persist the current answer, guesses, row state, attempt count, and completion status.

## Game Flow

1. App launches into the game screen.
2. If no cached session exists, create a new puzzle and mark the user as initialized.
3. If a cached unfinished session exists, restore it.
4. When the user solves the puzzle, immediately advance to a fresh puzzle.
5. When attempts are exhausted, replace the puzzle with a new random one.
6. If the user taps the reset action, replace the current puzzle with a new random one.

## Testing Strategy

- Unit tests for Arabic guess evaluation and state transitions.
- Widget tests for startup and key UI flows.
- Repository tests for cache serialization.
