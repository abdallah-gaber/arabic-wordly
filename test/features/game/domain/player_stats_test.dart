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
      expect(stats.statsForTrack(GameTrack.endless).totalScore, 180);
      expect(
        stats
            .statsForTrack(GameTrack.endless)
            .statsForMode(GameMode.fiveLetters)
            .solved,
        1,
      );
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
      expect(skipped.statsForTrack(GameTrack.endless).totalFailed, 1);
    });

    test(
      'keeps segmented stats per track while preserving the overall total',
      () {
        final seeded = const PlayerStats().recordRound(
          mode: GameMode.fiveLetters,
          track: GameTrack.endless,
          completion: RoundCompletion.won,
          attemptsUsed: 2,
          pointsEarned: 180,
          elapsed: const Duration(seconds: 45),
        );

        final combined = seeded.recordRound(
          mode: GameMode.fourLetters,
          track: GameTrack.daily,
          completion: RoundCompletion.won,
          attemptsUsed: 3,
          pointsEarned: 130,
          elapsed: const Duration(seconds: 80),
        );

        expect(combined.totalScore, 310);
        expect(combined.totalSolved, 2);
        expect(combined.statsForTrack(GameTrack.endless).totalScore, 180);
        expect(combined.statsForTrack(GameTrack.daily).totalScore, 130);
        expect(
          combined
              .statsForTrack(GameTrack.daily)
              .statsForMode(GameMode.fourLetters)
              .solved,
          1,
        );
      },
    );

    test('migrates legacy cached stats into the endless track', () {
      final restored = PlayerStats.fromJson({
        'totalScore': 244,
        'totalSolved': 1,
        'totalFailed': 1,
        'totalSkipped': 1,
        'currentStreak': 0,
        'bestStreak': 1,
        'totalSolveTimeSeconds': 42,
        'solveDistribution': {'2': 1},
        'modeStats': {
          '5': {
            'mode': '5',
            'totalScore': 244,
            'solved': 1,
            'failed': 1,
            'skipped': 1,
            'currentStreak': 0,
            'bestStreak': 1,
            'totalSolveTimeSeconds': 42,
            'solveDistribution': {'2': 1},
          },
        },
      });

      expect(restored.totalScore, 244);
      expect(restored.statsForTrack(GameTrack.endless).totalScore, 244);
      expect(
        restored
            .statsForTrack(GameTrack.endless)
            .statsForMode(GameMode.fiveLetters)
            .skipped,
        1,
      );
    });
  });
}
