import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';

enum GameKeyboardKeyState { unused, absent, present, correct }

class GameKeyboardKey {
  const GameKeyboardKey({
    required this.letter,
    required this.state,
    required this.isEnabled,
  });

  final String letter;
  final GameKeyboardKeyState state;
  final bool isEnabled;
}

class GameKeyboard {
  const GameKeyboard._();

  static const List<String> allLetters = [
    'ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج', 'د', 'ذ',
    'ش', 'س', 'ي', 'ب', 'ل', 'ا', 'أ', 'إ', 'آ', 'ت', 'ن', 'م', 'ك', 'ط',
    'ئ', 'ء', 'ؤ', 'ر', 'ى', 'ة', 'و', 'ز', 'ظ'
  ];

  static List<GameKeyboardKey> buildKeys({
    required List<String> guesses,
    required String answer,
  }) {
    final states = keyStatesForGuesses(guesses: guesses, answer: answer);
    return allLetters
        .map((letter) {
          final state = states[letter] ?? GameKeyboardKeyState.unused;
          return GameKeyboardKey(
            letter: letter,
            state: state,
            isEnabled: state != GameKeyboardKeyState.absent,
          );
        })
        .toList(growable: false);
  }

  static Map<String, GameKeyboardKeyState> keyStatesForGuesses({
    required List<String> guesses,
    required String answer,
  }) {
    final states = <String, GameKeyboardKeyState>{};

    for (final guess in guesses) {
      final evaluated = GuessEvaluator.evaluate(guess: guess, answer: answer);
      for (final letter in evaluated.letters) {
        final next = switch (letter.match) {
          LetterMatch.correct => GameKeyboardKeyState.correct,
          LetterMatch.present => GameKeyboardKeyState.present,
          LetterMatch.absent => GameKeyboardKeyState.absent,
        };
        final current = states[letter.letter];
        if (current == null || _priority(next) > _priority(current)) {
          states[letter.letter] = next;
        }
      }
    }

    return states;
  }

  static int _priority(GameKeyboardKeyState state) => switch (state) {
    GameKeyboardKeyState.unused => 0,
    GameKeyboardKeyState.absent => 1,
    GameKeyboardKeyState.present => 2,
    GameKeyboardKeyState.correct => 3,
  };
}
