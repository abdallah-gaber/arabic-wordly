import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';

abstract class DailyModeRepository {
  Future<DailyPuzzle> puzzleForDate({
    required GameMode mode,
    required DateTime date,
  });

  Future<DailyProgress?> restoreProgress({
    required GameMode mode,
    required DateTime date,
  });

  Future<void> saveProgress(DailyProgress progress);
}

class DailyPuzzle {
  const DailyPuzzle({
    required this.mode,
    required this.dateKey,
    required this.answer,
    required this.category,
  });

  final GameMode mode;
  final String dateKey;
  final String answer;
  final String category;
}

class DailyProgress {
  const DailyProgress({
    required this.mode,
    required this.dateKey,
    required this.answer,
    required this.category,
    this.guesses = const [],
    this.revealedHintIndexes = const [],
    this.pointsEarned = 0,
  });

  final GameMode mode;
  final String dateKey;
  final String answer;
  final String category;
  final List<String> guesses;
  final List<int> revealedHintIndexes;
  final int pointsEarned;

  bool get isComplete => outcome != SessionOutcome.inProgress;

  SessionOutcome get outcome {
    if (guesses.contains(answer)) {
      return SessionOutcome.won;
    }

    if (guesses.length >= ArabicWordRules.maxAttempts) {
      return SessionOutcome.lost;
    }

    return SessionOutcome.inProgress;
  }

  DailyProgress copyWith({
    GameMode? mode,
    String? dateKey,
    String? answer,
    String? category,
    List<String>? guesses,
    List<int>? revealedHintIndexes,
    int? pointsEarned,
  }) {
    return DailyProgress(
      mode: mode ?? this.mode,
      dateKey: dateKey ?? this.dateKey,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      guesses: guesses ?? this.guesses,
      revealedHintIndexes: revealedHintIndexes ?? this.revealedHintIndexes,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.cacheKey,
      'dateKey': dateKey,
      'answer': answer,
      'category': category,
      'guesses': guesses,
      'revealedHintIndexes': revealedHintIndexes,
      'pointsEarned': pointsEarned,
    };
  }

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      mode: GameMode.fromCacheKey(json['mode'] as String? ?? '5'),
      dateKey: json['dateKey'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String? ?? '',
      guesses: List<String>.from(json['guesses'] as List<dynamic>? ?? const []),
      revealedHintIndexes: List<int>.from(
        json['revealedHintIndexes'] as List<dynamic>? ?? const [],
      ),
      pointsEarned: json['pointsEarned'] as int? ?? 0,
    );
  }
}
