import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';

enum LetterMatch { correct, present, absent }

enum SessionOutcome { inProgress, won, lost }

enum RoundResultType { won, lost }

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
    this.maxAttempts = ArabicWordRules.maxAttempts,
  });

  final int round;
  final String answer;
  final List<String> guesses;
  final int maxAttempts;

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
    int? maxAttempts,
  }) {
    return GameSession(
      round: round ?? this.round,
      answer: answer ?? this.answer,
      guesses: guesses ?? this.guesses,
      maxAttempts: maxAttempts ?? this.maxAttempts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'answer': answer,
      'guesses': guesses,
      'maxAttempts': maxAttempts,
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      round: json['round'] as int? ?? 1,
      answer: json['answer'] as String? ?? '',
      guesses: List<String>.from(json['guesses'] as List<dynamic>? ?? const []),
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
