import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArabicWordRules', () {
    test('preserves distinct hamza and alef letter forms', () {
      expect(ArabicWordRules.normalize('سؤال'), 'سؤال');
      expect(ArabicWordRules.normalize('سوال'), 'سوال');
      expect(ArabicWordRules.normalize('شيئ'), 'شيئ');
      expect(ArabicWordRules.normalize('شيي'), 'شيي');
      expect(ArabicWordRules.normalize('أمر'), 'أمر');
      expect(ArabicWordRules.normalize('امر'), 'امر');
      expect(ArabicWordRules.normalize('إثم'), 'إثم');
      expect(ArabicWordRules.normalize('آدم'), 'آدم');
      expect(ArabicWordRules.normalize('ٱلة'), 'ٱلة');
    });

    test('removes spacing tatweel and diacritics without folding letters', () {
      expect(ArabicWordRules.normalize(' سُــؤال '), 'سؤال');
      expect(ArabicWordRules.normalize(' أَمْر '), 'أمر');
    });

    test('removes zero-width and bidi control characters consistently', () {
      expect(ArabicWordRules.normalize('ك\u200Dتاب'), 'كتاب');
      expect(ArabicWordRules.normalize('\u200Fمدرسة\u200E'), 'مدرسة');
      expect(ArabicWordRules.normalize('م\u2060كتب\u200Cة'), 'مكتبة');
    });

    test('accepts distinct Arabic forms as valid letters', () {
      expect(ArabicWordRules.isValidGuessFormat('سؤال', wordLength: 4), isTrue);
      expect(ArabicWordRules.isValidGuessFormat('أمر', wordLength: 3), isTrue);
      expect(ArabicWordRules.isValidGuessFormat('ٱلة', wordLength: 3), isTrue);
    });

    test('rejects malformed entries after normalization', () {
      expect(ArabicWordRules.isValidGuessFormat('س؟ال', wordLength: 4), isFalse);
      expect(ArabicWordRules.isValidGuessFormat('1234', wordLength: 4), isFalse);
      expect(ArabicWordRules.isValidGuessFormat('بيت!', wordLength: 3), isFalse);
    });

    test('sanitizes pasted input down to supported Arabic letters only', () {
      expect(
        ArabicWordRules.sanitizeGuessInput('abك\u200Dتاب123', maxLength: 4),
        'كتاب',
      );
      expect(
        ArabicWordRules.sanitizeGuessInput('م\u200Fدرسة!', maxLength: 5),
        'مدرسة',
      );
    });
  });
}
