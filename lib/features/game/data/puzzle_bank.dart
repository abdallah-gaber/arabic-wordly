import 'dart:math';

import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';

class ArabicPuzzleBank {
  ArabicPuzzleBank(Map<GameMode, List<String>> wordsByMode)
    : _wordsByMode = Map<GameMode, List<String>>.unmodifiable({
        for (final entry in wordsByMode.entries)
          entry.key: List<String>.unmodifiable(
            entry.value
                .map(ArabicWordRules.normalize)
                .where(
                  (word) => ArabicWordRules.isValidGuessFormat(
                    word,
                    wordLength: entry.key.wordLength,
                  ),
                )
                .toSet()
                .toList(growable: false),
          ),
      });

  ArabicPuzzleBank.defaults() : this(_defaultWordsByMode);

  final Map<GameMode, List<String>> _wordsByMode;

  static const Map<GameMode, List<String>> _defaultWordsByMode = {
    GameMode.threeLetters: [
      'بيت',
      'باب',
      'ورد',
      'قلم',
      'بحر',
      'نهر',
      'ليل',
      'نور',
      'فجر',
      'شمس',
      'قمر',
      'صوت',
      'خبز',
      'ماء',
      'لون',
      'عين',
      'وجه',
      'درب',
      'نجم',
      'ريح',
    ],
    GameMode.fourLetters: [
      'كتاب',
      'قهوة',
      'وردة',
      'هاتف',
      'صباح',
      'مساء',
      'شتاء',
      'صديق',
      'طائر',
      'حليب',
      'سرير',
      'مطره',
      'حدود',
      'دفتر',
      'كوثر',
      'رصيف',
      'رغيف',
      'شروق',
      'كنوز',
      'موجة',
    ],
    GameMode.fiveLetters: [
      'مدرسة',
      'حديقة',
      'مكتبة',
      'مدينة',
      'مزرعة',
      'فستان',
      'نوافذ',
      'سفينة',
      'حيوان',
      'وسادة',
      'ميدان',
      'بستان',
      'اقلام',
      'كنيسة',
      'حديثة',
      'تفاحة',
      'سيارة',
      'ملاعب',
      'فراشة',
      'جريدة',
      'حقيبة',
      'غزالة',
      'خزانة',
      'جامعة',
      'تجارة',
      'حدائق',
      'دجاجة',
      'هواتف',
      'مكاتب',
      'مسافة',
      'وظيفة',
      'رياضة',
      'فواكه',
      'دوائر',
      'عائلة',
      'طباعة',
      'ابواب',
      'انهار',
      'بحيرة',
      'حافلة',
      'منازل',
      'حجارة',
      'طماطم',
      'بوابة',
      'عناية',
      'مرايا',
      'الوان',
      'احلام',
      'العاب',
      'اوراق',
      'اشراق',
    ],
    GameMode.sixLetters: [
      'سيارات',
      'مدارسك',
      'قناديل',
      'تفاحات',
      'فراشات',
      'جامعات',
      'حافلات',
      'خيارات',
      'بوابات',
      'شوارعك',
      'رسائلك',
      'عصافير',
      'مزارعك',
      'مجلاتك',
      'وظائفك',
      'دراجات',
      'سفائنك',
      'حدائقك',
      'الوانك',
      'اوراقك',
      'نخيلنا',
    ],
  };

  List<String> wordsForMode(GameMode mode) => _wordsByMode[mode] ?? const [];

  bool containsAnswer(GameMode mode, String answer) {
    return wordsForMode(mode).contains(ArabicWordRules.normalize(answer));
  }

  String pickRandom(GameMode mode, Random random, {String? excluding}) {
    final normalizedExcluding = excluding == null
        ? null
        : ArabicWordRules.normalize(excluding);
    final words = wordsForMode(mode);

    final candidates = words.length > 1 && normalizedExcluding != null
        ? words.where((word) => word != normalizedExcluding).toList()
        : words;

    return candidates[random.nextInt(candidates.length)];
  }
}
