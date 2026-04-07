import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArabicPuzzleBank', () {
    test('ships with at least 100 puzzles in every mode', () {
      final bank = ArabicPuzzleBank.defaults();

      for (final mode in GameMode.values) {
        final puzzles = bank.puzzlesForMode(mode);
        expect(
          puzzles.length,
          greaterThanOrEqualTo(100),
          reason: 'Mode ${mode.name} only has ${puzzles.length} puzzles.',
        );

        expect(
          puzzles.every((puzzle) => puzzle.category.trim().isNotEmpty),
          isTrue,
          reason: 'Mode ${mode.name} has puzzles with empty categories.',
        );
      }
    });

    test('keeps distinct hamza and alef letter forms as separate puzzles', () {
      final bank = ArabicPuzzleBank({
        GameMode.fourLetters: const [
          ArabicPuzzle(word: 'سؤال', category: 'عامة'),
          ArabicPuzzle(word: 'سوال', category: 'عامة'),
          ArabicPuzzle(word: 'أمر', category: 'عامة'),
          ArabicPuzzle(word: 'امر', category: 'عامة'),
        ],
        GameMode.threeLetters: const [
          ArabicPuzzle(word: 'أمر', category: 'عامة'),
          ArabicPuzzle(word: 'امر', category: 'عامة'),
        ],
      });

      expect(bank.containsAnswer(GameMode.fourLetters, 'سؤال'), isTrue);
      expect(bank.containsAnswer(GameMode.fourLetters, 'سوال'), isTrue);
      expect(bank.wordsForMode(GameMode.fourLetters), contains('سؤال'));
      expect(bank.wordsForMode(GameMode.fourLetters), contains('سوال'));
      expect(
        bank.wordsForMode(GameMode.threeLetters),
        containsAll(['أمر', 'امر']),
      );
    });
  });
}
