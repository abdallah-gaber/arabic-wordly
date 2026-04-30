# Phase 0: Foundation (الأساس)

**Status:** Completed ✅
**Description:** Stabilize solo play before any new features.

---

## 🎮 Core Gameplay Polish (Priority: P0 – Critical)

| ID | Title | Detail | Effort | Impact |
|:---|:---|:---|:---:|:---:|
| **C1** | In-app Arabic keyboard | Replace the soft keyboard with a game-owned Arabic keyboard, then color keys by status (gray/gold/teal) | M | 🔥🔥🔥 |
| **C2** | Auto-submit on full word | Submit when letter count reached (with 300ms delay), remove friction | S | 🔥🔥🔥 |
| **C3** | Tile flip animation | Reveal animation per tile on submit — tactile satisfaction | S | 🔥🔥 |
| **C4** | Shake animation on invalid word | Row shakes if word not in dictionary | XS | 🔥🔥 |
| **C5** | Letter count progress dots | Show ●●○ under input to indicate progress toward full word | XS | 🔥 |

## 🐛 Stability & Bug Fixes (Priority: P0 – Critical)

| ID | Title | Detail | Effort | Impact |
|:---|:---|:---|:---:|:---:|
| **B1** | Word validation edge cases | Ensure all Arabic forms (تشكيل، همزات) handled consistently | M | 🔥🔥🔥 |
| **B2** | State persistence on app kill | Current game state survives app backgrounding/kill | M | 🔥🔥🔥 |
| **B3** | Keyboard layout stability | Ensure the in-app keyboard never hides the active row or primary action flow | S | 🔥🔥 |

---

> [!NOTE]
> See [ROADMAP_RULES.md](./ROADMAP_RULES.md) for how this Phase should be executed.
> The execution breakdown for this phase lives in [phase-0-sdd.md](./phase-0-sdd.md).
