import 'dart:math';

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

  static const Map<GameMode, List<ArabicPuzzle>> _defaultPuzzlesByMode = {
    GameMode.threeLetters: [
      ArabicPuzzle(word: 'بيت', category: 'المنزل'),
      ArabicPuzzle(word: 'باب', category: 'المنزل'),
      ArabicPuzzle(word: 'ورد', category: 'النباتات'),
      ArabicPuzzle(word: 'قلم', category: 'أدوات الدراسة'),
      ArabicPuzzle(word: 'بحر', category: 'الطبيعة'),
      ArabicPuzzle(word: 'نهر', category: 'الطبيعة'),
      ArabicPuzzle(word: 'ليل', category: 'الزمن'),
      ArabicPuzzle(word: 'نور', category: 'الضوء'),
      ArabicPuzzle(word: 'فجر', category: 'الزمن'),
      ArabicPuzzle(word: 'شمس', category: 'السماء'),
      ArabicPuzzle(word: 'قمر', category: 'السماء'),
      ArabicPuzzle(word: 'صوت', category: 'الحواس'),
      ArabicPuzzle(word: 'خبز', category: 'الطعام'),
      ArabicPuzzle(word: 'ماء', category: 'المشروبات'),
      ArabicPuzzle(word: 'لون', category: 'الألوان'),
      ArabicPuzzle(word: 'عين', category: 'الجسم'),
      ArabicPuzzle(word: 'وجه', category: 'الجسم'),
      ArabicPuzzle(word: 'درب', category: 'الأماكن'),
      ArabicPuzzle(word: 'نجم', category: 'السماء'),
      ArabicPuzzle(word: 'ريح', category: 'الطقس'),
    ],
    GameMode.fourLetters: [
      ArabicPuzzle(word: 'كتاب', category: 'القراءة'),
      ArabicPuzzle(word: 'قهوة', category: 'المشروبات'),
      ArabicPuzzle(word: 'وردة', category: 'النباتات'),
      ArabicPuzzle(word: 'هاتف', category: 'التقنية'),
      ArabicPuzzle(word: 'صباح', category: 'الزمن'),
      ArabicPuzzle(word: 'مساء', category: 'الزمن'),
      ArabicPuzzle(word: 'شتاء', category: 'الفصول'),
      ArabicPuzzle(word: 'صديق', category: 'العلاقات'),
      ArabicPuzzle(word: 'طائر', category: 'الحيوانات'),
      ArabicPuzzle(word: 'حليب', category: 'المشروبات'),
      ArabicPuzzle(word: 'سرير', category: 'المنزل'),
      ArabicPuzzle(word: 'مطره', category: 'الطقس'),
      ArabicPuzzle(word: 'حدود', category: 'الجغرافيا'),
      ArabicPuzzle(word: 'دفتر', category: 'أدوات الدراسة'),
      ArabicPuzzle(word: 'كوثر', category: 'أسماء'),
      ArabicPuzzle(word: 'رصيف', category: 'المدينة'),
      ArabicPuzzle(word: 'رغيف', category: 'الطعام'),
      ArabicPuzzle(word: 'شروق', category: 'السماء'),
      ArabicPuzzle(word: 'كنوز', category: 'الأشياء'),
      ArabicPuzzle(word: 'موجة', category: 'البحر'),
    ],
    GameMode.fiveLetters: [
      ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
      ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
      ArabicPuzzle(word: 'مكتبة', category: 'القراءة'),
      ArabicPuzzle(word: 'مدينة', category: 'الأماكن'),
      ArabicPuzzle(word: 'مزرعة', category: 'الزراعة'),
      ArabicPuzzle(word: 'فستان', category: 'الملابس'),
      ArabicPuzzle(word: 'نوافذ', category: 'المنزل'),
      ArabicPuzzle(word: 'سفينة', category: 'المواصلات'),
      ArabicPuzzle(word: 'حيوان', category: 'الحيوانات'),
      ArabicPuzzle(word: 'وسادة', category: 'المنزل'),
      ArabicPuzzle(word: 'ميدان', category: 'المدينة'),
      ArabicPuzzle(word: 'بستان', category: 'الزراعة'),
      ArabicPuzzle(word: 'اقلام', category: 'أدوات الدراسة'),
      ArabicPuzzle(word: 'كنيسة', category: 'المعالم'),
      ArabicPuzzle(word: 'حديثة', category: 'الصفات'),
      ArabicPuzzle(word: 'تفاحة', category: 'الفواكه'),
      ArabicPuzzle(word: 'سيارة', category: 'المواصلات'),
      ArabicPuzzle(word: 'ملاعب', category: 'الرياضة'),
      ArabicPuzzle(word: 'فراشة', category: 'الحشرات'),
      ArabicPuzzle(word: 'جريدة', category: 'الإعلام'),
      ArabicPuzzle(word: 'حقيبة', category: 'الأشياء'),
      ArabicPuzzle(word: 'غزالة', category: 'الحيوانات'),
      ArabicPuzzle(word: 'خزانة', category: 'المنزل'),
      ArabicPuzzle(word: 'جامعة', category: 'التعليم'),
      ArabicPuzzle(word: 'تجارة', category: 'العمل'),
      ArabicPuzzle(word: 'حدائق', category: 'الطبيعة'),
      ArabicPuzzle(word: 'دجاجة', category: 'الحيوانات'),
      ArabicPuzzle(word: 'هواتف', category: 'التقنية'),
      ArabicPuzzle(word: 'مكاتب', category: 'العمل'),
      ArabicPuzzle(word: 'مسافة', category: 'القياس'),
      ArabicPuzzle(word: 'وظيفة', category: 'العمل'),
      ArabicPuzzle(word: 'رياضة', category: 'الرياضة'),
      ArabicPuzzle(word: 'فواكه', category: 'الفواكه'),
      ArabicPuzzle(word: 'دوائر', category: 'الأشكال'),
      ArabicPuzzle(word: 'عائلة', category: 'العلاقات'),
      ArabicPuzzle(word: 'طباعة', category: 'التقنية'),
      ArabicPuzzle(word: 'ابواب', category: 'المنزل'),
      ArabicPuzzle(word: 'انهار', category: 'الطبيعة'),
      ArabicPuzzle(word: 'بحيرة', category: 'الطبيعة'),
      ArabicPuzzle(word: 'حافلة', category: 'المواصلات'),
      ArabicPuzzle(word: 'منازل', category: 'المنزل'),
      ArabicPuzzle(word: 'حجارة', category: 'الطبيعة'),
      ArabicPuzzle(word: 'طماطم', category: 'الخضروات'),
      ArabicPuzzle(word: 'بوابة', category: 'الأماكن'),
      ArabicPuzzle(word: 'عناية', category: 'الصحة'),
      ArabicPuzzle(word: 'مرايا', category: 'المنزل'),
      ArabicPuzzle(word: 'الوان', category: 'الألوان'),
      ArabicPuzzle(word: 'احلام', category: 'المشاعر'),
      ArabicPuzzle(word: 'العاب', category: 'الترفيه'),
      ArabicPuzzle(word: 'اوراق', category: 'القراءة'),
      ArabicPuzzle(word: 'اشراق', category: 'الزمن'),
    ],
    GameMode.sixLetters: [
      ArabicPuzzle(word: 'سيارات', category: 'المواصلات'),
      ArabicPuzzle(word: 'مدارسك', category: 'التعليم'),
      ArabicPuzzle(word: 'قناديل', category: 'المنزل'),
      ArabicPuzzle(word: 'تفاحات', category: 'الفواكه'),
      ArabicPuzzle(word: 'فراشات', category: 'الحشرات'),
      ArabicPuzzle(word: 'جامعات', category: 'التعليم'),
      ArabicPuzzle(word: 'حافلات', category: 'المواصلات'),
      ArabicPuzzle(word: 'خيارات', category: 'الخضروات'),
      ArabicPuzzle(word: 'بوابات', category: 'الأماكن'),
      ArabicPuzzle(word: 'شوارعك', category: 'المدينة'),
      ArabicPuzzle(word: 'رسائلك', category: 'التواصل'),
      ArabicPuzzle(word: 'عصافير', category: 'الحيوانات'),
      ArabicPuzzle(word: 'مزارعك', category: 'الزراعة'),
      ArabicPuzzle(word: 'مجلاتك', category: 'القراءة'),
      ArabicPuzzle(word: 'وظائفك', category: 'العمل'),
      ArabicPuzzle(word: 'دراجات', category: 'المواصلات'),
      ArabicPuzzle(word: 'سفائنك', category: 'المواصلات'),
      ArabicPuzzle(word: 'حدائقك', category: 'الطبيعة'),
      ArabicPuzzle(word: 'الوانك', category: 'الألوان'),
      ArabicPuzzle(word: 'اوراقك', category: 'القراءة'),
      ArabicPuzzle(word: 'نخيلنا', category: 'الطبيعة'),
    ],
  };

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
      );
    }

    return uniqueByWord.values.toList(growable: false);
  }
}
