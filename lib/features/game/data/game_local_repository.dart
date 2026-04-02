import 'dart:convert';
import 'dart:math';

import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';

class GameLocalRepository {
  GameLocalRepository({
    required KeyValueStore store,
    required ArabicPuzzleBank puzzleBank,
    required Random random,
    required DateTime Function() now,
  }) : _store = store,
       _puzzleBank = puzzleBank,
       _random = random,
       _now = now;

  static const _hasStartedKey = 'has_started';

  final KeyValueStore _store;
  final ArabicPuzzleBank _puzzleBank;
  final Random _random;
  final DateTime Function() _now;

  Future<GameSession> restoreOrCreateSession(GameMode mode) async {
    final cachedJson = await _store.getString(_sessionKey(mode));
    if (cachedJson != null) {
      final cachedSession = _decodeSession(cachedJson);
      if (cachedSession != null &&
          cachedSession.mode == mode &&
          _puzzleBank.containsAnswer(mode, cachedSession.answer)) {
        final category = _puzzleBank.categoryForAnswer(
          mode,
          cachedSession.answer,
        );
        if (category != null && cachedSession.category != category) {
          final enrichedSession = cachedSession.copyWith(category: category);
          await saveSession(enrichedSession);
          return enrichedSession;
        }
        return cachedSession;
      }
    }

    return createNextSession(mode: mode, round: 1);
  }

  Future<void> saveSession(GameSession session) async {
    await _store.setBool(_hasStartedKey, true);
    await _store.setString(
      _sessionKey(session.mode),
      jsonEncode(session.toJson()),
    );
  }

  Future<GameSession> createNextSession({
    required GameMode mode,
    required int round,
    String? excluding,
  }) async {
    final createdAt = _now();
    final puzzle = _puzzleBank.pickRandom(mode, _random, excluding: excluding);
    final session = GameSession(
      mode: mode,
      round: round,
      answer: puzzle.word,
      category: puzzle.category,
      guesses: const [],
      startedAtEpochMs: createdAt.millisecondsSinceEpoch,
      nextHintAvailableAtEpochMs: createdAt.millisecondsSinceEpoch,
    );

    await saveSession(session);
    return session;
  }

  GameSession? _decodeSession(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return GameSession.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  String _sessionKey(GameMode mode) => 'active_session_${mode.cacheKey}';
}
