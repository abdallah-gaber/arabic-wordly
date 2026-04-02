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
  });
}
