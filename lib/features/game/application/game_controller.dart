import 'dart:math';

import 'package:arabic_wordly/features/game/data/game_local_repository.dart';
import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Clock = DateTime Function();

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('Override keyValueStoreProvider in main.'),
);

final randomProvider = Provider<Random>((ref) => Random());
final clockProvider = Provider<Clock>((ref) => DateTime.now);

final puzzleBankProvider = Provider<ArabicPuzzleBank>(
  (ref) => ArabicPuzzleBank.defaults(),
);

final gameRepositoryProvider = Provider<GameLocalRepository>((ref) {
  return GameLocalRepository(
    store: ref.watch(keyValueStoreProvider),
    puzzleBank: ref.watch(puzzleBankProvider),
    random: ref.watch(randomProvider),
    now: ref.watch(clockProvider),
  );
});

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
    return GameViewState(
      session: session,
      feedback: _feedbackForSession(session),
      pendingResult: _pendingResultForSession(session),
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
      final nextSession = current.session.addGuess(guess);
      await _repository.saveSession(nextSession);

      switch (nextSession.outcome) {
        case SessionOutcome.inProgress:
          state = AsyncData(
            current.copyWith(
              session: nextSession,
              feedback:
                  'محاولة ${nextSession.guesses.length} من ${nextSession.maxAttempts}.',
              clearPendingResult: true,
            ),
          );
        case SessionOutcome.won:
          state = AsyncData(
            current.copyWith(
              session: nextSession,
              feedback: 'أحسنت! تم حل اللغز.',
              pendingResult: RoundResult.fromSession(nextSession),
            ),
          );
        case SessionOutcome.lost:
          state = AsyncData(
            current.copyWith(
              session: nextSession,
              feedback: 'انتهت المحاولات في هذا اللغز.',
              pendingResult: RoundResult.fromSession(nextSession),
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
    if (!current.session.hasHintsRemaining) {
      state = AsyncData(
        current.copyWith(feedback: 'استخدمت كل التلميحات المتاحة لهذا اللغز.'),
      );
      return false;
    }

    if (!current.session.canUseHint(now)) {
      state = AsyncData(
        current.copyWith(
          feedback: 'التلميح التالي سيتاح بعد انتهاء العد التنازلي.',
        ),
      );
      return false;
    }

    _isMutating = true;
    try {
      final nextSession = current.session.useNextHint(now);
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
      final nextSession = await _repository.createNextSession(
        mode: current.session.mode,
        round: current.session.round + 1,
        excluding: current.session.answer,
      );
      state = AsyncData(
        GameViewState(
          session: nextSession,
          feedback: 'تم فتح لغز جديد. يمكنك المحاولة من جديد.',
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

  RoundResult? _pendingResultForSession(GameSession session) {
    return session.outcome == SessionOutcome.inProgress
        ? null
        : RoundResult.fromSession(session);
  }
}
