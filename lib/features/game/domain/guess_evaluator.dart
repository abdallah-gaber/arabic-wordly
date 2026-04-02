import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';

class GuessEvaluator {
  const GuessEvaluator._();

  static EvaluatedGuess evaluate({
    required String guess,
    required String answer,
  }) {
    final normalizedGuess = ArabicWordRules.normalize(guess);
    final normalizedAnswer = ArabicWordRules.normalize(answer);
    final guessLetters = ArabicWordRules.split(normalizedGuess);
    final answerLetters = ArabicWordRules.split(normalizedAnswer);

    assert(guessLetters.length == ArabicWordRules.wordLength);
    assert(answerLetters.length == ArabicWordRules.wordLength);

    final matches = List<LetterMatch?>.filled(ArabicWordRules.wordLength, null);
    final remainingLetters = <String, int>{};

    for (var index = 0; index < ArabicWordRules.wordLength; index++) {
      if (guessLetters[index] == answerLetters[index]) {
        matches[index] = LetterMatch.correct;
      } else {
        final answerLetter = answerLetters[index];
        remainingLetters[answerLetter] =
            (remainingLetters[answerLetter] ?? 0) + 1;
      }
    }

    for (var index = 0; index < ArabicWordRules.wordLength; index++) {
      if (matches[index] != null) {
        continue;
      }

      final guessLetter = guessLetters[index];
      final remainingCount = remainingLetters[guessLetter] ?? 0;

      if (remainingCount > 0) {
        matches[index] = LetterMatch.present;
        remainingLetters[guessLetter] = remainingCount - 1;
      } else {
        matches[index] = LetterMatch.absent;
      }
    }

    return EvaluatedGuess(
      guess: normalizedGuess,
      letters: List<LetterEvaluation>.generate(
        guessLetters.length,
        (index) => LetterEvaluation(
          letter: guessLetters[index],
          match: matches[index]!,
        ),
        growable: false,
      ),
    );
  }
}
