import 'package:arabic_wordly/features/game/data/local_daily_mode_repository.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/daily_mode_repository.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import '../../../support/in_memory_key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalDailyModeRepository', () {
    test('returns the same puzzle for the same mode and date', () async {
      final repository = LocalDailyModeRepository(
        store: InMemoryKeyValueStore(),
        puzzleBank: ArabicPuzzleBank({
          GameMode.fiveLetters: [
            const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
            const ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
            const ArabicPuzzle(word: 'مكتبة', category: 'التعليم'),
          ],
        }),
      );

      final first = await repository.puzzleForDate(
        mode: GameMode.fiveLetters,
        date: DateTime(2026, 4, 8, 8, 30),
      );
      final second = await repository.puzzleForDate(
        mode: GameMode.fiveLetters,
        date: DateTime(2026, 4, 8, 23, 59),
      );

      expect(first.answer, second.answer);
      expect(first.category, second.category);
      expect(first.dateKey, '2026-04-08');
    });

    test('stores daily progress independently from endless sessions', () async {
      final store = InMemoryKeyValueStore();
      final repository = LocalDailyModeRepository(
        store: store,
        puzzleBank: ArabicPuzzleBank({
          GameMode.fiveLetters: [
            const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
          ],
        }),
      );

      const progress = DailyProgress(
        mode: GameMode.fiveLetters,
        dateKey: '2026-04-08',
        answer: 'حديقة',
        category: 'الطبيعة',
        guesses: ['مدرسة', 'حديقة'],
        revealedHintIndexes: [0],
        pointsEarned: 180,
      );

      await repository.saveProgress(progress);
      await store.setString(
        'active_session_5',
        '{"round":2,"answer":"مدرسة","guesses":["حديقة"],"mode":"5","maxAttempts":6,"revealedHintIndexes":[],"startedAtEpochMs":0,"nextHintAvailableAtEpochMs":0}',
      );

      final restored = await repository.restoreProgress(
        mode: GameMode.fiveLetters,
        date: DateTime(2026, 4, 8),
      );

      expect(restored?.answer, 'حديقة');
      expect(restored?.guesses, ['مدرسة', 'حديقة']);
      expect(await store.getString('active_session_5'), isNotNull);
    });
  });
}
