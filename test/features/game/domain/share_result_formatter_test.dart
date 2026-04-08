import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/share_result_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShareResultFormatter', () {
    test('formats a completed round with mode and pattern rows', () {
      final output = ShareResultFormatter.formatCompletedRound(
        track: GameTrack.daily,
        mode: GameMode.fiveLetters,
        answer: 'حديقة',
        guesses: const ['مكتبة', 'حديقة'],
      );

      expect(output, contains('خمنها | التحدي اليومي'));
      expect(output, contains('5 أحرف 2/6'));
      expect(output, contains('🟩'));
      expect(output.split('\n').length, greaterThanOrEqualTo(3));
    });
  });
}
