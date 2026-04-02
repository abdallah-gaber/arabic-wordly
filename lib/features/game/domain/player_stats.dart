import 'dart:math' as math;

import 'package:arabic_wordly/features/game/domain/game_models.dart';

enum RoundCompletion { won, lost, skipped }

class ScoreRules {
  const ScoreRules._();

  static const int _baseWinScore = 100;
  static const int _bonusPerUnusedAttempt = 18;
  static const int _noHintBonus = 24;
  static const int _hintPenalty = 10;
  static const int _maxSpeedBonus = 30;
  static const int _minWinScore = 40;

  static int pointsForSolvedRound({
    required int attemptsUsed,
    required int maxAttempts,
    required int hintsUsed,
    required Duration elapsed,
  }) {
    final unusedAttempts = math.max(0, maxAttempts - attemptsUsed);
    final attemptBonus = unusedAttempts * _bonusPerUnusedAttempt;
    final hintAdjustment = hintsUsed == 0
        ? _noHintBonus
        : -(hintsUsed * _hintPenalty);
    final speedBonus = math.max(
      0,
      _maxSpeedBonus - ((elapsed.inSeconds ~/ 20) * 2),
    );

    return math.max(
      _minWinScore,
      _baseWinScore + attemptBonus + hintAdjustment + speedBonus,
    );
  }
}

class ModeStats {
  const ModeStats({
    required this.mode,
    this.totalScore = 0,
    this.solved = 0,
    this.failed = 0,
    this.skipped = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalSolveTimeSeconds = 0,
    this.solveDistribution = const {},
  });

  final GameMode mode;
  final int totalScore;
  final int solved;
  final int failed;
  final int skipped;
  final int currentStreak;
  final int bestStreak;
  final int totalSolveTimeSeconds;
  final Map<int, int> solveDistribution;

  int get gamesPlayed => solved + failed;

  double get averageSolveTimeSeconds {
    if (solved == 0) {
      return 0;
    }

    return totalSolveTimeSeconds / solved;
  }

  ModeStats recordRound({
    required RoundCompletion completion,
    required int attemptsUsed,
    required int pointsEarned,
    required Duration elapsed,
  }) {
    final solvedRound = completion == RoundCompletion.won;
    final failedRound = completion != RoundCompletion.won;
    final skippedRound = completion == RoundCompletion.skipped;
    final nextCurrentStreak = solvedRound ? currentStreak + 1 : 0;
    final nextDistribution = Map<int, int>.from(solveDistribution);

    if (solvedRound) {
      nextDistribution.update(
        attemptsUsed,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return ModeStats(
      mode: mode,
      totalScore: totalScore + pointsEarned,
      solved: solved + (solvedRound ? 1 : 0),
      failed: failed + (failedRound ? 1 : 0),
      skipped: skipped + (skippedRound ? 1 : 0),
      currentStreak: nextCurrentStreak,
      bestStreak: math.max(bestStreak, nextCurrentStreak),
      totalSolveTimeSeconds:
          totalSolveTimeSeconds + (solvedRound ? elapsed.inSeconds : 0),
      solveDistribution: nextDistribution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.cacheKey,
      'totalScore': totalScore,
      'solved': solved,
      'failed': failed,
      'skipped': skipped,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalSolveTimeSeconds': totalSolveTimeSeconds,
      'solveDistribution': solveDistribution.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }

  factory ModeStats.fromJson(Map<String, dynamic> json) {
    final distribution = Map<String, dynamic>.from(
      json['solveDistribution'] as Map<String, dynamic>? ?? const {},
    );

    return ModeStats(
      mode: GameMode.fromCacheKey(json['mode'] as String? ?? '5'),
      totalScore: json['totalScore'] as int? ?? 0,
      solved: json['solved'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      skipped: json['skipped'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalSolveTimeSeconds: json['totalSolveTimeSeconds'] as int? ?? 0,
      solveDistribution: {
        for (final entry in distribution.entries)
          int.tryParse(entry.key) ?? 0: entry.value as int,
      }..remove(0),
    );
  }
}

class PlayerStats {
  const PlayerStats({
    this.totalScore = 0,
    this.totalSolved = 0,
    this.totalFailed = 0,
    this.totalSkipped = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalSolveTimeSeconds = 0,
    this.solveDistribution = const {},
    this.modeStats = const {},
  });

  final int totalScore;
  final int totalSolved;
  final int totalFailed;
  final int totalSkipped;
  final int currentStreak;
  final int bestStreak;
  final int totalSolveTimeSeconds;
  final Map<int, int> solveDistribution;
  final Map<GameMode, ModeStats> modeStats;

  int get gamesPlayed => totalSolved + totalFailed;

  double get averageSolveTimeSeconds {
    if (totalSolved == 0) {
      return 0;
    }

    return totalSolveTimeSeconds / totalSolved;
  }

  ModeStats statsForMode(GameMode mode) {
    return modeStats[mode] ?? ModeStats(mode: mode);
  }

  PlayerStats recordRound({
    required GameMode mode,
    required RoundCompletion completion,
    required int attemptsUsed,
    required int pointsEarned,
    required Duration elapsed,
  }) {
    final solvedRound = completion == RoundCompletion.won;
    final failedRound = completion != RoundCompletion.won;
    final skippedRound = completion == RoundCompletion.skipped;
    final nextCurrentStreak = solvedRound ? currentStreak + 1 : 0;
    final nextDistribution = Map<int, int>.from(solveDistribution);

    if (solvedRound) {
      nextDistribution.update(
        attemptsUsed,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final nextModeStats = Map<GameMode, ModeStats>.from(modeStats);
    nextModeStats[mode] = statsForMode(mode).recordRound(
      completion: completion,
      attemptsUsed: attemptsUsed,
      pointsEarned: pointsEarned,
      elapsed: elapsed,
    );

    return PlayerStats(
      totalScore: totalScore + pointsEarned,
      totalSolved: totalSolved + (solvedRound ? 1 : 0),
      totalFailed: totalFailed + (failedRound ? 1 : 0),
      totalSkipped: totalSkipped + (skippedRound ? 1 : 0),
      currentStreak: nextCurrentStreak,
      bestStreak: math.max(bestStreak, nextCurrentStreak),
      totalSolveTimeSeconds:
          totalSolveTimeSeconds + (solvedRound ? elapsed.inSeconds : 0),
      solveDistribution: nextDistribution,
      modeStats: nextModeStats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'totalSolved': totalSolved,
      'totalFailed': totalFailed,
      'totalSkipped': totalSkipped,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalSolveTimeSeconds': totalSolveTimeSeconds,
      'solveDistribution': solveDistribution.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'modeStats': modeStats.map(
        (key, value) => MapEntry(key.cacheKey, value.toJson()),
      ),
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    final distribution = Map<String, dynamic>.from(
      json['solveDistribution'] as Map<String, dynamic>? ?? const {},
    );
    final encodedModeStats = Map<String, dynamic>.from(
      json['modeStats'] as Map<String, dynamic>? ?? const {},
    );

    return PlayerStats(
      totalScore: json['totalScore'] as int? ?? 0,
      totalSolved: json['totalSolved'] as int? ?? 0,
      totalFailed: json['totalFailed'] as int? ?? 0,
      totalSkipped: json['totalSkipped'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalSolveTimeSeconds: json['totalSolveTimeSeconds'] as int? ?? 0,
      solveDistribution: {
        for (final entry in distribution.entries)
          int.tryParse(entry.key) ?? 0: entry.value as int,
      }..remove(0),
      modeStats: {
        for (final entry in encodedModeStats.entries)
          GameMode.fromCacheKey(entry.key): ModeStats.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          ),
      },
    );
  }
}
