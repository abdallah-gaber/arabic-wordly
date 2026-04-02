import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/player_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScoreRules', () {
    test('rewards cleaner and faster solves with more points', () {
      final strongerScore = ScoreRules.pointsForSolvedRound(
        attemptsUsed: 2,
        maxAttempts: 6,
        hintsUsed: 0,
        elapsed: const Duration(seconds: 30),
      );
      final weakerScore = ScoreRules.pointsForSolvedRound(
        attemptsUsed: 5,
        maxAttempts: 6,
        hintsUsed: 2,
        elapsed: const Duration(minutes: 4),
      );

      expect(strongerScore, greaterThan(weakerScore));
    });
  });

  group('PlayerStats', () {
    test('records solved rounds, score, and solve distribution', () {
      final stats = const PlayerStats().recordRound(
        mode: GameMode.fiveLetters,
        completion: RoundCompletion.won,
        attemptsUsed: 2,
        pointsEarned: 180,
        elapsed: const Duration(seconds: 50),
      );

      expect(stats.totalScore, 180);
      expect(stats.totalSolved, 1);
      expect(stats.totalFailed, 0);
      expect(stats.currentStreak, 1);
      expect(stats.bestStreak, 1);
      expect(stats.solveDistribution[2], 1);
      expect(stats.statsForMode(GameMode.fiveLetters).totalScore, 180);
      expect(stats.statsForMode(GameMode.fiveLetters).solveDistribution[2], 1);
    });

    test('treats skipped puzzles as failed rounds and resets the streak', () {
      final seeded = const PlayerStats().recordRound(
        mode: GameMode.fiveLetters,
        completion: RoundCompletion.won,
        attemptsUsed: 3,
        pointsEarned: 150,
        elapsed: const Duration(seconds: 60),
      );

      final skipped = seeded.recordRound(
        mode: GameMode.fiveLetters,
        completion: RoundCompletion.skipped,
        attemptsUsed: 1,
        pointsEarned: 0,
        elapsed: const Duration(seconds: 20),
      );

      expect(skipped.totalFailed, 1);
      expect(skipped.totalSkipped, 1);
      expect(skipped.currentStreak, 0);
      expect(skipped.bestStreak, 1);
      expect(skipped.statsForMode(GameMode.fiveLetters).failed, 1);
      expect(skipped.statsForMode(GameMode.fiveLetters).skipped, 1);
    });
  });
}
