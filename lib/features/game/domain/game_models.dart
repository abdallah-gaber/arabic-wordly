import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';

enum LetterMatch { correct, present, absent }

enum SessionOutcome { inProgress, won, lost }

enum RoundResultType { won, lost }

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
  });

  final int round;
  final String answer;
  final List<String> guesses;
  final GameMode mode;
  final int maxAttempts;

  int get wordLength => mode.wordLength;

  int get attemptsRemaining => maxAttempts - guesses.length;

  bool get canAcceptGuess => outcome == SessionOutcome.inProgress;

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

  GameSession copyWith({
    int? round,
    String? answer,
    List<String>? guesses,
    GameMode? mode,
    int? maxAttempts,
  }) {
    return GameSession(
      round: round ?? this.round,
      answer: answer ?? this.answer,
      guesses: guesses ?? this.guesses,
      mode: mode ?? this.mode,
      maxAttempts: maxAttempts ?? this.maxAttempts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'answer': answer,
      'guesses': guesses,
      'mode': mode.cacheKey,
      'maxAttempts': maxAttempts,
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      round: json['round'] as int? ?? 1,
      answer: json['answer'] as String? ?? '',
      guesses: List<String>.from(json['guesses'] as List<dynamic>? ?? const []),
      mode: GameMode.fromCacheKey(json['mode'] as String? ?? '5'),
      maxAttempts: json['maxAttempts'] as int? ?? ArabicWordRules.maxAttempts,
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
