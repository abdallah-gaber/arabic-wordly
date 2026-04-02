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
  static const _activeSessionKey = 'active_session';

  final KeyValueStore _store;
  final ArabicPuzzleBank _puzzleBank;
  final Random _random;

  Future<GameSession> restoreOrCreateSession() async {
    final cachedJson = await _store.getString(_activeSessionKey);
    if (cachedJson != null) {
      final cachedSession = _decodeSession(cachedJson);
      if (cachedSession != null &&
          _puzzleBank.containsAnswer(cachedSession.answer)) {
        return cachedSession;
      }
    }

    return createNextSession(round: 1);
  }

  Future<void> saveSession(GameSession session) async {
    await _store.setBool(_hasStartedKey, true);
    await _store.setString(_activeSessionKey, jsonEncode(session.toJson()));
  }

  Future<GameSession> createNextSession({
    required int round,
    String? excluding,
  }) async {
    final session = GameSession(
      round: round,
      answer: _puzzleBank.pickRandom(_random, excluding: excluding),
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
}
