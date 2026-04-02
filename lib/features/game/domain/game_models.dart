import 'dart:math' as math;

import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';

enum LetterMatch { correct, present, absent }

enum SessionOutcome { inProgress, won, lost }

enum RoundResultType { won, lost }

class HintRules {
  const HintRules._();

  static const List<Duration> _cooldownsAfterUse = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
  ];

  static int maxHintsForWordLength(int wordLength) {
    return math.max(1, wordLength - 1);
  }

  static Duration cooldownAfterUse(int usedHintsCount) {
    final index = usedHintsCount - 1;
    if (index < 0) {
      return Duration.zero;
    }

    if (index >= _cooldownsAfterUse.length) {
      return _cooldownsAfterUse.last;
    }

    return _cooldownsAfterUse[index];
  }
}

enum GameMode {
  threeLetters,
  fourLetters,
  fiveLetters,
  sixLetters;

  int get wordLength => switch (this) {
    GameMode.threeLetters => 3,
    GameMode.fourLetters => 4,
    GameMode.fiveLetters => 5,
    GameMode.sixLetters => 6,
  };

  String get cacheKey => switch (this) {
    GameMode.threeLetters => '3',
    GameMode.fourLetters => '4',
    GameMode.fiveLetters => '5',
    GameMode.sixLetters => '6',
  };

  String get label => '$wordLength أحرف';

  String get description => switch (this) {
    GameMode.threeLetters => 'سريع وخفيف للبدايات.',
    GameMode.fourLetters => 'توازن سريع بين السهولة والتحدي.',
    GameMode.fiveLetters => 'الوضع الأساسي الكلاسيكي.',
    GameMode.sixLetters => 'تحدي أطول وتركيز أكبر.',
  };

  static GameMode fromCacheKey(String value) {
    return GameMode.values.firstWhere(
      (mode) => mode.cacheKey == value,
      orElse: () => GameMode.fiveLetters,
    );
  }
}

class LetterEvaluation {
  const LetterEvaluation({required this.letter, required this.match});

  final String letter;
  final LetterMatch match;
}

class EvaluatedGuess {
  const EvaluatedGuess({required this.guess, required this.letters});

  final String guess;
  final List<LetterEvaluation> letters;
}

class GameSession {
  const GameSession({
    required this.round,
    required this.answer,
    required this.guesses,
    this.mode = GameMode.fiveLetters,
    this.maxAttempts = ArabicWordRules.maxAttempts,
    this.revealedHintIndexes = const [],
    this.startedAtEpochMs = 0,
    this.nextHintAvailableAtEpochMs = 0,
  });

  final int round;
  final String answer;
  final List<String> guesses;
  final GameMode mode;
  final int maxAttempts;
  final List<int> revealedHintIndexes;
  final int startedAtEpochMs;
  final int nextHintAvailableAtEpochMs;

  int get wordLength => mode.wordLength;
  int get maxHints => HintRules.maxHintsForWordLength(wordLength);

  int get attemptsRemaining => maxAttempts - guesses.length;
  bool get hasHintsRemaining => revealedHintIndexes.length < maxHints;

  bool get canAcceptGuess => outcome == SessionOutcome.inProgress;

  bool canUseHint(DateTime now) {
    return outcome == SessionOutcome.inProgress &&
        hasHintsRemaining &&
        now.millisecondsSinceEpoch >= nextHintAvailableAtEpochMs;
  }

  Duration remainingHintWait(DateTime now) {
    if (!hasHintsRemaining) {
      return Duration.zero;
    }

    final difference = nextHintAvailableAtEpochMs - now.millisecondsSinceEpoch;
    if (difference <= 0) {
      return Duration.zero;
    }

    return Duration(milliseconds: difference);
  }

  List<String?> get revealedHintLetters {
    final answerLetters = ArabicWordRules.split(answer);
    return List<String?>.generate(
      answerLetters.length,
      (index) =>
          revealedHintIndexes.contains(index) ? answerLetters[index] : null,
      growable: false,
    );
  }

  SessionOutcome get outcome {
    if (guesses.contains(answer)) {
      return SessionOutcome.won;
    }

    if (guesses.length >= maxAttempts) {
      return SessionOutcome.lost;
    }

    return SessionOutcome.inProgress;
  }

  GameSession addGuess(String guess) {
    return copyWith(guesses: [...guesses, guess]);
  }

  GameSession useHintAt(DateTime now, int index) {
    if (!canUseHint(now)) {
      throw StateError('Hint is not available for this session.');
    }

    if (index < 0 || index >= wordLength) {
      throw RangeError.range(index, 0, wordLength - 1, 'index');
    }

    if (revealedHintIndexes.contains(index)) {
      throw StateError('Hint for this index was already revealed.');
    }

    final usedHintsCount = revealedHintIndexes.length + 1;

    return copyWith(
      revealedHintIndexes: [...revealedHintIndexes, index],
      nextHintAvailableAtEpochMs:
          now.millisecondsSinceEpoch +
          HintRules.cooldownAfterUse(usedHintsCount).inMilliseconds,
    );
  }

  GameSession copyWith({
    int? round,
    String? answer,
    List<String>? guesses,
    GameMode? mode,
    int? maxAttempts,
    List<int>? revealedHintIndexes,
    int? startedAtEpochMs,
    int? nextHintAvailableAtEpochMs,
  }) {
    return GameSession(
      round: round ?? this.round,
      answer: answer ?? this.answer,
      guesses: guesses ?? this.guesses,
      mode: mode ?? this.mode,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      revealedHintIndexes: revealedHintIndexes ?? this.revealedHintIndexes,
      startedAtEpochMs: startedAtEpochMs ?? this.startedAtEpochMs,
      nextHintAvailableAtEpochMs:
          nextHintAvailableAtEpochMs ?? this.nextHintAvailableAtEpochMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'answer': answer,
      'guesses': guesses,
      'mode': mode.cacheKey,
      'maxAttempts': maxAttempts,
      'revealedHintIndexes': revealedHintIndexes,
      'startedAtEpochMs': startedAtEpochMs,
      'nextHintAvailableAtEpochMs': nextHintAvailableAtEpochMs,
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      round: json['round'] as int? ?? 1,
      answer: json['answer'] as String? ?? '',
      guesses: List<String>.from(json['guesses'] as List<dynamic>? ?? const []),
      mode: GameMode.fromCacheKey(json['mode'] as String? ?? '5'),
      maxAttempts: json['maxAttempts'] as int? ?? ArabicWordRules.maxAttempts,
      revealedHintIndexes: List<int>.from(
        json['revealedHintIndexes'] as List<dynamic>? ?? const [],
      ),
      startedAtEpochMs: json['startedAtEpochMs'] as int? ?? 0,
      nextHintAvailableAtEpochMs:
          json['nextHintAvailableAtEpochMs'] as int? ?? 0,
    );
  }
}

class RoundResult {
  const RoundResult({
    required this.type,
    required this.answer,
    required this.round,
    required this.attemptsUsed,
  });

  final RoundResultType type;
  final String answer;
  final int round;
  final int attemptsUsed;

  factory RoundResult.fromSession(GameSession session) {
    return RoundResult(
      type: session.outcome == SessionOutcome.won
          ? RoundResultType.won
          : RoundResultType.lost,
      answer: session.answer,
      round: session.round,
      attemptsUsed: session.guesses.length,
    );
  }
}

class GameViewState {
  const GameViewState({
    required this.session,
    this.feedback,
    this.pendingResult,
  });

  final GameSession session;
  final String? feedback;
  final RoundResult? pendingResult;

  GameViewState copyWith({
    GameSession? session,
    String? feedback,
    RoundResult? pendingResult,
    bool clearFeedback = false,
    bool clearPendingResult = false,
  }) {
    return GameViewState(
      session: session ?? this.session,
      feedback: clearFeedback ? null : feedback ?? this.feedback,
      pendingResult: clearPendingResult
          ? null
          : pendingResult ?? this.pendingResult,
    );
  }
}
