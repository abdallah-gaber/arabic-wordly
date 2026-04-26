import 'package:characters/characters.dart';

class ArabicWordRules {
  const ArabicWordRules._();

  static const int maxAttempts = 6;

  static final RegExp _diacriticsPattern = RegExp(r'[\u064B-\u065F\u0670]');
  static final RegExp _invisibleFormattingPattern = RegExp(
    r'[\u200C\u200D\u200E\u200F\u202A-\u202E\u2060-\u2069]',
  );
  static final RegExp _arabicLettersOnly = RegExp(r'^[\u0621-\u064A\u0671]+$');
  static final RegExp _arabicInputCharacters = RegExp(r'[\u0621-\u064A\u0671]');

  static String normalize(String rawInput) {
    return rawInput
        .trim()
        .replaceAll('ـ', '')
        .replaceAll(_diacriticsPattern, '')
        .replaceAll(_invisibleFormattingPattern, '')
        .replaceAll(RegExp(r'\s+'), '');
  }

  static List<String> split(String word) {
    return normalize(word).characters.toList(growable: false);
  }

  static String sanitizeGuessInput(String rawInput, {required int maxLength}) {
    final normalizedInput = normalize(rawInput);
    final filteredCharacters = normalizedInput.characters.where(
      (character) => _arabicInputCharacters.hasMatch(character),
    );

    return filteredCharacters.take(maxLength).toList().join();
  }

  static bool isValidGuessFormat(String rawInput, {required int wordLength}) {
    final normalized = normalize(rawInput);
    return split(normalized).length == wordLength &&
        _arabicLettersOnly.hasMatch(normalized);
  }
}
