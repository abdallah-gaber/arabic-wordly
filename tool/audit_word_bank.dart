import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';

void main() {
  final bank = ArabicPuzzleBank.defaults();

  for (final mode in GameMode.values) {
    final puzzles = bank.puzzlesForMode(mode);
    final suspicious = puzzles
        .where((puzzle) => _looksLikeAttachedPronoun(puzzle.word))
        .toList(growable: false);

    print('${mode.name}: ${puzzles.length}');
    print('  suspicious_attached_pronouns: ${suspicious.length}');

    final categoryCounts = <String, int>{};
    for (final puzzle in puzzles) {
      categoryCounts.update(
        puzzle.category,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) {
        final countDiff = b.value.compareTo(a.value);
        if (countDiff != 0) {
          return countDiff;
        }
        return a.key.compareTo(b.key);
      });

    for (final entry in sortedCategories) {
      print('  ${entry.key}: ${entry.value}');
    }

    if (suspicious.isNotEmpty) {
      print(
        '  examples: ${suspicious.take(12).map((puzzle) => puzzle.word).join(', ')}',
      );
    }

    print('');
  }
}

bool _looksLikeAttachedPronoun(String word) {
  const singularPronounSuffixes = <String>[
    'ك',
    'ه',
    'ها',
    'هم',
    'هن',
    'نا',
    'كم',
    'كن',
  ];

  return singularPronounSuffixes.any(
    (suffix) => word.length > suffix.length + 1 && word.endsWith(suffix),
  );
}
