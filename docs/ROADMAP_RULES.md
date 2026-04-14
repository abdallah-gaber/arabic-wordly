# Phase Execution Rules

To ensure a smooth, documented, and testable workflow, the following rules apply when executing ANY development phase (e.g., Phase 0 through Phase 4) for `5amenha`.

## 1. Branching Strategy
- **Always branch from `main`** for each phase.
- Use a descriptive naming convention, such as `feature/phase-1-growth` or `chore/phase-1-setup`.

## 2. Planning and System Design Definition (SDD)
- Before writing any code, **create a separate SDD file** for the phase (e.g., `docs/phase-X-sdd.md`).
- The SDD must contain a detailed task list, breaking down the items specified in the phase's roadmap file into executable development steps.

## 3. Test-Driven Development (TDD)
- Implement features using a **TDD approach**.
- Write unit tests for domain/application logic and widget tests for UI components **before** or **alongside** implementation, not as an afterthought.

## 4. Verification and Done Specification
- Once development and testing are completed, **verify** all features manually and automatically (running test suites).
- Clearly specify what has been implemented and is considered **DONE** within the Phase documentation or PR description.

## 5. Manual Testing Guide
- Along with the completed phase, provide a **Manual Guide to Test** the implemented features. This helps reviewers understand how to experience the new features within the app.

By adhering to these rules, we ensure continuous quality, predictable development cycles, and a well-documented progression of the `5amenha` app.
