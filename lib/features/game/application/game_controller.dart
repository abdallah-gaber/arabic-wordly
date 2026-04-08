import 'package:arabic_wordly/features/game/application/game_providers.dart';
import 'package:arabic_wordly/features/game/data/game_local_repository.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/hint_selector.dart';
import 'package:arabic_wordly/features/game/domain/player_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'game_providers.dart';

final gameControllerProvider =
    AsyncNotifierProvider.family<GameController, GameViewState, GameMode>(
      GameController.new,
    );

class GameController extends AsyncNotifier<GameViewState> {
  GameController(this.mode);

  final GameMode mode;
  bool _isMutating = false;

  GameLocalRepository get _repository => ref.read(gameRepositoryProvider);
  DateTime get _now => ref.read(clockProvider)();

  @override
  Future<GameViewState> build() async {
    final session = await _repository.restoreOrCreateSession(mode);
    final stats = await _repository.restoreStats();
    return GameViewState(
      session: session,
      feedback: _feedbackForSession(session),
      pendingResult: _pendingResultForSession(session, stats: stats),
    );
  }

  Future<bool> submitGuess(String rawGuess) async {
    if (_isMutating) {
      return false;
    }

    final current = state.asData?.value;
    if (current == null || !current.session.canAcceptGuess) {
      return false;
    }

    final guess = ArabicWordRules.normalize(rawGuess);
    if (!ArabicWordRules.isValidGuessFormat(
      guess,
      wordLength: current.session.wordLength,
    )) {
      state = AsyncData(
        current.copyWith(
          feedback:
              'اكتب كلمة عربية صحيحة من ${current.session.wordLength} أحرف.',
        ),
      );
      return false;
    }

    _isMutating = true;
    try {
      final existingStats = await _repository.restoreStats();
      var nextSession = current.session.addGuess(guess);

      switch (nextSession.outcome) {
        case SessionOutcome.inProgress:
          await _repository.saveSession(nextSession);
          state = AsyncData(
            current.copyWith(
              session: nextSession,
              feedback:
                  'محاولة ${nextSession.guesses.length} من ${nextSession.maxAttempts}.',
              clearPendingResult: true,
            ),
          );
        case SessionOutcome.won:
          final pointsEarned = ScoreRules.pointsForSolvedRound(
            attemptsUsed: nextSession.guesses.length,
            maxAttempts: nextSession.maxAttempts,
            hintsUsed: nextSession.revealedHintIndexes.length,
            elapsed: nextSession.elapsedAt(_now),
          );
          final updatedStats = _recordStats(
            existingStats,
            session: nextSession,
            completion: RoundCompletion.won,
            pointsEarned: pointsEarned,
          );
          nextSession = nextSession.copyWith(completionPoints: pointsEarned);
          await _repository.saveSession(nextSession);
          await _repository.saveStats(updatedStats);
          ref.invalidate(playerStatsProvider);
          state = AsyncData(
            current.copyWith(
              session: nextSession,
              feedback: 'أحسنت! تم حل اللغز.',
              pendingResult: RoundResult.fromSession(
                nextSession,
                totalScore: updatedStats.totalScore,
                currentStreak: updatedStats.currentStreak,
              ),
            ),
          );
        case SessionOutcome.lost:
          final updatedStats = _recordStats(
            existingStats,
            session: nextSession,
            completion: RoundCompletion.lost,
            pointsEarned: 0,
          );
          await _repository.saveSession(nextSession);
          await _repository.saveStats(updatedStats);
          ref.invalidate(playerStatsProvider);
          state = AsyncData(
            current.copyWith(
              session: nextSession,
              feedback: 'انتهت المحاولات في هذا اللغز.',
              pendingResult: RoundResult.fromSession(
                nextSession,
                totalScore: updatedStats.totalScore,
                currentStreak: updatedStats.currentStreak,
              ),
            ),
          );
      }

      return true;
    } finally {
      _isMutating = false;
    }
  }

  Future<bool> useHint() async {
    if (_isMutating) {
      return false;
    }

    final current = state.asData?.value;
    if (current == null) {
      return false;
    }

    final now = _now;
    if (!HintSelector.hasUsefulHints(current.session)) {
      state = AsyncData(
        current.copyWith(
          feedback: 'لا توجد تلميحات مفيدة إضافية لهذا اللغز الآن.',
        ),
      );
      return false;
    }

    if (!HintSelector.canUseHint(current.session, now)) {
      state = AsyncData(
        current.copyWith(
          feedback: 'التلميح التالي سيتاح بعد انتهاء العد التنازلي.',
        ),
      );
      return false;
    }

    _isMutating = true;
    try {
      final nextHintIndex = HintSelector.nextHintIndex(current.session);
      if (nextHintIndex == null) {
        state = AsyncData(
          current.copyWith(
            feedback: 'لا توجد تلميحات مفيدة إضافية لهذا اللغز الآن.',
          ),
        );
        return false;
      }

      final nextSession = current.session.useHintAt(now, nextHintIndex);
      final revealedIndex = nextSession.revealedHintIndexes.last;
      final revealedLetter = nextSession.revealedHintLetters[revealedIndex]!;
      await _repository.saveSession(nextSession);

      state = AsyncData(
        current.copyWith(
          session: nextSession,
          feedback: 'تم كشف الحرف رقم ${revealedIndex + 1}: $revealedLetter',
        ),
      );
      return true;
    } finally {
      _isMutating = false;
    }
  }

  Future<void> skipPuzzle() async {
    if (_isMutating) {
      return;
    }

    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    _isMutating = true;
    try {
      final existingStats = await _repository.restoreStats();
      final updatedStats = _recordStats(
        existingStats,
        session: current.session,
        completion: RoundCompletion.skipped,
        pointsEarned: 0,
      );
      await _repository.saveStats(updatedStats);
      ref.invalidate(playerStatsProvider);
      final nextSession = await _repository.createNextSession(
        mode: current.session.mode,
        round: current.session.round + 1,
        excluding: current.session.answer,
      );
      state = AsyncData(
        GameViewState(
          session: nextSession,
          feedback: 'تم فتح لغز جديد. تم احتساب التخطي كخسارة في الإحصاءات.',
        ),
      );
    } finally {
      _isMutating = false;
    }
  }

  Future<void> continueToNextPuzzle() async {
    if (_isMutating) {
      return;
    }

    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    _isMutating = true;
    try {
      final nextSession = await _repository.createNextSession(
        mode: current.session.mode,
        round: current.session.round + 1,
        excluding: current.session.answer,
      );
      state = AsyncData(
        GameViewState(
          session: nextSession,
          feedback: 'بدأ لغز جديد. يمكنك المتابعة.',
        ),
      );
    } finally {
      _isMutating = false;
    }
  }

  String _feedbackForSession(GameSession session) {
    return switch (session.outcome) {
      SessionOutcome.inProgress =>
        'اكتب كلمة عربية من ${session.wordLength} أحرف ثم تحقق من النتيجة.',
      SessionOutcome.won => 'أحسنت! تم حل اللغز.',
      SessionOutcome.lost => 'انتهت المحاولات في هذا اللغز.',
    };
  }

  RoundResult? _pendingResultForSession(
    GameSession session, {
    required PlayerStats stats,
  }) {
    return session.outcome == SessionOutcome.inProgress
        ? null
        : RoundResult.fromSession(
            session,
            totalScore: stats.totalScore,
            currentStreak: stats.currentStreak,
          );
  }

  PlayerStats _recordStats(
    PlayerStats currentStats, {
    required GameSession session,
    required RoundCompletion completion,
    required int pointsEarned,
  }) {
    return currentStats.recordRound(
      mode: session.mode,
      completion: completion,
      attemptsUsed: session.guesses.length,
      pointsEarned: pointsEarned,
      elapsed: session.elapsedAt(_now),
    );
  }
}
