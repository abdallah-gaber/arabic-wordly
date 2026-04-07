import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuessEvaluator', () {
    test('marks exact and absent letters correctly', () {
      final result = GuessEvaluator.evaluate(guess: 'حديقه', answer: 'حديقة');

      expect(result.letters.map((letter) => letter.match), [
        LetterMatch.correct,
        LetterMatch.correct,
        LetterMatch.correct,
        LetterMatch.correct,
        LetterMatch.absent,
      ]);
    });

    test('handles duplicate letters without over-counting', () {
      final result = GuessEvaluator.evaluate(guess: 'ددددد', answer: 'دجاجة');

      expect(result.letters.map((letter) => letter.match), [
        LetterMatch.correct,
        LetterMatch.absent,
        LetterMatch.absent,
        LetterMatch.absent,
        LetterMatch.absent,
      ]);
    });

    test('treats hamza variants as distinct letters', () {
      final result = GuessEvaluator.evaluate(guess: 'سوال', answer: 'سؤال');

      expect(result.letters.map((letter) => letter.match), [
        LetterMatch.correct,
        LetterMatch.absent,
        LetterMatch.correct,
        LetterMatch.correct,
      ]);
    });
  });
}
