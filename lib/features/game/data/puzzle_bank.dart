import 'dart:math';

import 'package:arabic_wordly/features/game/data/default_puzzles.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';

class ArabicPuzzleBank {
  ArabicPuzzleBank(Map<GameMode, List<dynamic>> puzzlesByMode)
    : _puzzlesByMode = Map<GameMode, List<ArabicPuzzle>>.unmodifiable({
        for (final entry in puzzlesByMode.entries)
          entry.key: List<ArabicPuzzle>.unmodifiable(
            _normalizePuzzles(entry.key, entry.value),
          ),
      });

  ArabicPuzzleBank.defaults() : this(_defaultPuzzlesByMode);

  final Map<GameMode, List<ArabicPuzzle>> _puzzlesByMode;

  static final Map<GameMode, List<ArabicPuzzle>> _defaultPuzzlesByMode =
      buildDefaultPuzzles();

  List<ArabicPuzzle> puzzlesForMode(GameMode mode) =>
      _puzzlesByMode[mode] ?? const [];

  List<String> wordsForMode(GameMode mode) {
    return puzzlesForMode(
      mode,
    ).map((puzzle) => puzzle.word).toList(growable: false);
  }

  bool containsAnswer(GameMode mode, String answer) {
    final normalizedAnswer = ArabicWordRules.normalize(answer);
    return puzzlesForMode(
      mode,
    ).any((puzzle) => puzzle.word == normalizedAnswer);
  }

  ArabicPuzzle? puzzleForAnswer(GameMode mode, String answer) {
    final normalizedAnswer = ArabicWordRules.normalize(answer);
    for (final puzzle in puzzlesForMode(mode)) {
      if (puzzle.word == normalizedAnswer) {
        return puzzle;
      }
    }
    return null;
  }

  String? categoryForAnswer(GameMode mode, String answer) {
    return puzzleForAnswer(mode, answer)?.category;
  }

  String? definitionForAnswer(GameMode mode, String answer) {
    return puzzleForAnswer(mode, answer)?.definition;
  }

  ArabicPuzzle pickRandom(GameMode mode, Random random, {String? excluding}) {
    final normalizedExcluding = excluding == null
        ? null
        : ArabicWordRules.normalize(excluding);
    final puzzles = puzzlesForMode(mode);

    final candidates = puzzles.length > 1 && normalizedExcluding != null
        ? puzzles.where((puzzle) => puzzle.word != normalizedExcluding).toList()
        : puzzles;

    return candidates[random.nextInt(candidates.length)];
  }

  static List<ArabicPuzzle> _normalizePuzzles(
    GameMode mode,
    List<dynamic> entries,
  ) {
    final uniqueByWord = <String, ArabicPuzzle>{};

    for (final entry in entries) {
      final puzzle = switch (entry) {
        ArabicPuzzle puzzle => puzzle,
        String word => ArabicPuzzle(word: word, category: 'كلمات عامة'),
        _ => null,
      };

      if (puzzle == null) {
        continue;
      }

      final normalizedWord = ArabicWordRules.normalize(puzzle.word);
      if (!ArabicWordRules.isValidGuessFormat(
        normalizedWord,
        wordLength: mode.wordLength,
      )) {
        continue;
      }

      uniqueByWord[normalizedWord] = ArabicPuzzle(
        word: normalizedWord,
        category: puzzle.category.trim().isEmpty
            ? 'كلمات عامة'
            : puzzle.category,
        definition: puzzle.definition?.trim(),
      );
    }

    return uniqueByWord.values.toList(growable: false);
  }
}
