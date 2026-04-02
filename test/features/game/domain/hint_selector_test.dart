import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/hint_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 4, 2, 10);

  group('HintSelector', () {
    test('skips indexes that are already solved in the correct position', () {
      const session = GameSession(
        mode: GameMode.threeLetters,
        round: 1,
        answer: 'بيت',
        guesses: ['باب'],
      );

      expect(HintSelector.nextHintIndex(session), 1);
    });

    test(
      'prioritizes undiscovered letters before misplaced discovered ones',
      () {
        const session = GameSession(
          mode: GameMode.threeLetters,
          round: 1,
          answer: 'بيت',
          guesses: ['تاج'],
        );

        expect(HintSelector.nextHintIndex(session), 0);
      },
    );

    test(
      'falls back to misplaced discovered letters after unknown ones are gone',
      () {
        const session = GameSession(
          mode: GameMode.sixLetters,
          round: 1,
          answer: 'مفاتيح',
          guesses: ['محرررر'],
          revealedHintIndexes: [1, 2, 3, 4],
        );

        expect(HintSelector.nextHintIndex(session), 5);
      },
    );

    test(
      'reports no useful hints when only solved or already revealed indexes remain',
      () {
        const session = GameSession(
          mode: GameMode.threeLetters,
          round: 1,
          answer: 'بيت',
          guesses: ['بيا'],
          revealedHintIndexes: [2],
        );

        expect(HintSelector.nextHintIndex(session), isNull);
        expect(HintSelector.hasUsefulHints(session), isFalse);
        expect(HintSelector.canUseHint(session, now), isFalse);
      },
    );
  });
}
