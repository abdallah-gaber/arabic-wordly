import 'dart:math';

import 'package:arabic_wordly/features/game/data/game_local_repository.dart';
import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('Override keyValueStoreProvider in main.'),
);

final randomProvider = Provider<Random>((ref) => Random());

final puzzleBankProvider = Provider<ArabicPuzzleBank>(
  (ref) => ArabicPuzzleBank.defaults(),
);

final gameRepositoryProvider = Provider<GameLocalRepository>((ref) {
  return GameLocalRepository(
    store: ref.watch(keyValueStoreProvider),
    puzzleBank: ref.watch(puzzleBankProvider),
    random: ref.watch(randomProvider),
  );
});

final gameControllerProvider =
    AsyncNotifierProvider<GameController, GameViewState>(GameController.new);

class GameController extends AsyncNotifier<GameViewState> {
  bool _isMutating = false;

  GameLocalRepository get _repository => ref.read(gameRepositoryProvider);

  @override
  Future<GameViewState> build() async {
    final session = await _repository.restoreOrCreateSession();
    return GameViewState(
      session: session,
      feedback: 'اكتب كلمة عربية من خمسة أحرف ثم تحقق من النتيجة.',
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
    if (!ArabicWordRules.isValidGuessFormat(guess)) {
      state = AsyncData(
        current.copyWith(feedback: 'اكتب كلمة عربية صحيحة من خمسة أحرف.'),
      );
      return false;
    }

    _isMutating = true;
    try {
      final nextSession = current.session.addGuess(guess);

      switch (nextSession.outcome) {
        case SessionOutcome.inProgress:
          await _repository.saveSession(nextSession);
          state = AsyncData(
            current.copyWith(
              session: nextSession,
              feedback:
                  'محاولة ${nextSession.guesses.length} من ${nextSession.maxAttempts}.',
            ),
          );
        case SessionOutcome.won:
          final upcomingSession = await _repository.createNextSession(
            round: current.session.round + 1,
            excluding: current.session.answer,
          );
          state = AsyncData(
            GameViewState(
              session: upcomingSession,
              feedback: 'أحسنت! بدأت جولة جديدة مباشرة.',
            ),
          );
        case SessionOutcome.lost:
          final previousAnswer = current.session.answer;
          final upcomingSession = await _repository.createNextSession(
            round: current.session.round + 1,
            excluding: current.session.answer,
          );
          state = AsyncData(
            GameViewState(
              session: upcomingSession,
              feedback:
                  'انتهت المحاولات. كانت الكلمة "$previousAnswer". بدأ لغز جديد.',
            ),
          );
      }

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
}
