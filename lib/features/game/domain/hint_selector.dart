import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';

class HintSelector {
  const HintSelector._();

  static bool hasUsefulHints(GameSession session) {
    if (session.outcome != SessionOutcome.inProgress) {
      return false;
    }

    if (session.revealedHintIndexes.length >= session.maxHints) {
      return false;
    }

    return nextHintIndex(session) != null;
  }

  static bool canUseHint(GameSession session, DateTime now) {
    return hasUsefulHints(session) &&
        now.millisecondsSinceEpoch >= session.nextHintAvailableAtEpochMs;
  }

  static int? nextHintIndex(GameSession session) {
    if (session.outcome != SessionOutcome.inProgress) {
      return null;
    }

    if (session.revealedHintIndexes.length >= session.maxHints) {
      return null;
    }

    final answerLetters = ArabicWordRules.split(session.answer);
    final solvedIndexes = _solvedIndexes(session);
    final discoveredLetters = _discoveredLetters(session);
    final availableIndexes =
        List<int>.generate(answerLetters.length, (index) {
              return index;
            })
            .where((index) {
              return !session.revealedHintIndexes.contains(index) &&
                  !solvedIndexes.contains(index);
            })
            .toList(growable: false);

    if (availableIndexes.isEmpty) {
      return null;
    }

    for (final index in availableIndexes) {
      if (!discoveredLetters.contains(answerLetters[index])) {
        return index;
      }
    }

    return availableIndexes.first;
  }

  static Set<String> _discoveredLetters(GameSession session) {
    final letters = <String>{};

    for (final guess in session.guesses) {
      final evaluation = GuessEvaluator.evaluate(
        guess: guess,
        answer: session.answer,
      );
      for (final letter in evaluation.letters) {
        if (letter.match != LetterMatch.absent) {
          letters.add(letter.letter);
        }
      }
    }

    return letters;
  }

  static Set<int> _solvedIndexes(GameSession session) {
    final indexes = <int>{};

    for (final guess in session.guesses) {
      final evaluation = GuessEvaluator.evaluate(
        guess: guess,
        answer: session.answer,
      );
      for (var index = 0; index < evaluation.letters.length; index++) {
        if (evaluation.letters[index].match == LetterMatch.correct) {
          indexes.add(index);
        }
      }
    }

    return indexes;
  }
}
