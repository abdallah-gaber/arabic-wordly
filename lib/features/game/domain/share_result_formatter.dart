import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';

class ShareResultFormatter {
  const ShareResultFormatter._();

  static String formatCompletedRound({
    required GameTrack track,
    required GameMode mode,
    required String answer,
    required List<String> guesses,
    String? title,
  }) {
    final solved = guesses.contains(answer);
    final attemptLabel = solved ? '${guesses.length}/6' : 'X/6';
    final rows = guesses
        .map(
          (guess) => GuessEvaluator.evaluate(
            guess: guess,
            answer: answer,
          ).letters.map((letter) => _symbolForMatch(letter.match)).join(),
        )
        .join('\n');

    return [
      title ?? 'خمنها | ${track.label}',
      '${mode.label} $attemptLabel',
      rows,
    ].where((line) => line.isNotEmpty).join('\n');
  }

  static String _symbolForMatch(LetterMatch match) {
    return switch (match) {
      LetterMatch.correct => '🟩',
      LetterMatch.present => '🟨',
      LetterMatch.absent => '⬜',
    };
  }
}
