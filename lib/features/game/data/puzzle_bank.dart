import 'dart:math';

import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';

class ArabicPuzzleBank {
  ArabicPuzzleBank(List<String> words)
    : _words = List.unmodifiable(
        words
            .map(ArabicWordRules.normalize)
            .where(ArabicWordRules.isValidGuessFormat)
            .toSet(),
      );

  ArabicPuzzleBank.defaults() : this(_defaultWords);

  final List<String> _words;

  static const List<String> _defaultWords = [
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
  ];

  List<String> get words => _words;

  bool containsAnswer(String answer) {
    return _words.contains(ArabicWordRules.normalize(answer));
  }

  String pickRandom(Random random, {String? excluding}) {
    final normalizedExcluding = excluding == null
        ? null
        : ArabicWordRules.normalize(excluding);

    final candidates = _words.length > 1 && normalizedExcluding != null
        ? _words.where((word) => word != normalizedExcluding).toList()
        : _words;

    return candidates[random.nextInt(candidates.length)];
  }
}
