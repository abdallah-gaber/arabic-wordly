import 'package:arabic_wordly/features/game/domain/game_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameKeyboard', () {
    test('upgrades a key to the strongest observed state', () {
      final states = GameKeyboard.keyStatesForGuesses(
        guesses: const ['بحر', 'باب'],
        answer: 'باب',
      );

      expect(states['ب'], GameKeyboardKeyState.correct);
      expect(states['ا'], GameKeyboardKeyState.correct);
      expect(states['ح'], GameKeyboardKeyState.absent);
      expect(states['ر'], GameKeyboardKeyState.absent);
    });

    test('keeps duplicate-letter evidence at the strongest status', () {
      final states = GameKeyboard.keyStatesForGuesses(
        guesses: const ['سسس', 'سور'],
        answer: 'سهم',
      );

      expect(states['س'], GameKeyboardKeyState.correct);
      expect(states['و'], GameKeyboardKeyState.absent);
      expect(states['ر'], GameKeyboardKeyState.absent);
    });

    test('disables absent-only keys in the keyboard model', () {
      final keys = GameKeyboard.buildKeys(
        guesses: const ['نور'],
        answer: 'باب',
      ).expand((row) => row);

      final noon = keys.firstWhere((key) => key.letter == 'ن');
      final waw = GameKeyboard.buildKeys(
        guesses: const ['نور'],
        answer: 'باب',
      ).expand((row) => row).firstWhere((key) => key.letter == 'و');
      final baa = GameKeyboard.buildKeys(
        guesses: const ['نور'],
        answer: 'باب',
      ).expand((row) => row).firstWhere((key) => key.letter == 'ب');

      expect(noon.state, GameKeyboardKeyState.absent);
      expect(noon.isEnabled, isFalse);
      expect(waw.state, GameKeyboardKeyState.absent);
      expect(waw.isEnabled, isFalse);
      expect(baa.isEnabled, isTrue);
    });
  });
}
