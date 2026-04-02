# Testing Checklist

Every phase must complete the following before commit:

- Format changed Dart files.
- Run static analysis.
- Run the full automated test suite.
- Smoke-check the startup flow after major UI or persistence changes.

## Phase 1 Checks

- Guess evaluation covers exact, present, and absent letters.
- Duplicate-letter handling is validated.
- Cached state restores correctly.
- New puzzle generation happens on win, loss, and manual skip.
