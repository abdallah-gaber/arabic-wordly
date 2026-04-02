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
  }) : _store = store,
       _puzzleBank = puzzleBank,
       _random = random;

  static const _hasStartedKey = 'has_started';

  final KeyValueStore _store;
  final ArabicPuzzleBank _puzzleBank;
  final Random _random;

  Future<GameSession> restoreOrCreateSession(GameMode mode) async {
    final cachedJson = await _store.getString(_sessionKey(mode));
    if (cachedJson != null) {
      final cachedSession = _decodeSession(cachedJson);
      if (cachedSession != null &&
          cachedSession.mode == mode &&
          _puzzleBank.containsAnswer(mode, cachedSession.answer)) {
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
    final session = GameSession(
      mode: mode,
      round: round,
      answer: _puzzleBank.pickRandom(mode, _random, excluding: excluding),
      guesses: const [],
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
