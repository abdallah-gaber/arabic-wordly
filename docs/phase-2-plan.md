# Phase 2 Plan

## Goal

Expand Arabic Wordly from a stable five-letter MVP into a richer game system with more replay value, better progression, and stronger platform ergonomics.

## Planned Features

- Add four word-length modes: 3, 4, 5, and 6 letters.
- Curate at least 500 Arabic words for each mode.
- Add a mode selector while preserving cached progress per mode.
- Add a visible player score system.
- Add a celebration animation when a puzzle is solved.
- Add a timed hint system that can later be replaced or extended by rewarded ad unlocks.
- Add richer keyboard ergonomics, including a better on-screen Arabic keyboard direction for web and mobile.

## Delivery Notes

- Stabilize the current five-letter experience before mode expansion.
- Keep the rule engine generic so word-length-specific logic stays reusable.
- Separate answer banks from allowed guess banks to support future balancing.
- Add tests per mode for evaluation, persistence, and scoring.
