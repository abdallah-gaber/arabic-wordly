import 'dart:math';

import 'package:arabic_wordly/features/game/data/game_local_repository.dart';
import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixedNow = DateTime(2026, 4, 2, 8);

  group('GameLocalRepository', () {
    test('creates a new session for a first-time player', () async {
      final repository = GameLocalRepository(
        store: _InMemoryKeyValueStore(),
        puzzleBank: ArabicPuzzleBank({
          GameMode.fiveLetters: [
            const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
            const ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
          ],
        }),
        random: _FixedRandom(0),
        now: () => fixedNow,
      );

      final session = await repository.restoreOrCreateSession(
        GameMode.fiveLetters,
      );

      expect(session.round, 1);
      expect(session.answer, 'حديقة');
      expect(session.category, 'الطبيعة');
      expect(session.guesses, isEmpty);
      expect(session.mode, GameMode.fiveLetters);
      expect(
        session.nextHintAvailableAtEpochMs,
        fixedNow.millisecondsSinceEpoch,
      );
    });

    test('restores an active cached session when available', () async {
      final store = _InMemoryKeyValueStore();
      final repository = GameLocalRepository(
        store: store,
        puzzleBank: ArabicPuzzleBank({
          GameMode.fiveLetters: [
            const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
            const ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
          ],
        }),
        random: _FixedRandom(1),
        now: () => fixedNow,
      );

      await repository.saveSession(
        const GameSession(round: 3, answer: 'مدرسة', guesses: ['حديقة']),
      );

      final session = await repository.restoreOrCreateSession(
        GameMode.fiveLetters,
      );

      expect(session.round, 3);
      expect(session.answer, 'مدرسة');
      expect(session.category, 'التعليم');
      expect(session.guesses, ['حديقة']);
    });

    test(
      'restores a completed cached session until the user advances',
      () async {
        final store = _InMemoryKeyValueStore();
        final repository = GameLocalRepository(
          store: store,
          puzzleBank: ArabicPuzzleBank({
            GameMode.fiveLetters: [
              const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
              const ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
            ],
          }),
          random: _FixedRandom(1),
          now: () => fixedNow,
        );

        await repository.saveSession(
          const GameSession(
            round: 2,
            answer: 'حديقة',
            guesses: ['مدرسة', 'حديقة'],
          ),
        );

        final session = await repository.restoreOrCreateSession(
          GameMode.fiveLetters,
        );

        expect(session.round, 2);
        expect(session.answer, 'حديقة');
        expect(session.category, 'الطبيعة');
        expect(session.outcome, SessionOutcome.won);
      },
    );

    test(
      'creates a different next session when excluding the previous answer',
      () async {
        final repository = GameLocalRepository(
          store: _InMemoryKeyValueStore(),
          puzzleBank: ArabicPuzzleBank({
            GameMode.fiveLetters: [
              const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
              const ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
            ],
          }),
          random: _FixedRandom(0),
          now: () => fixedNow,
        );

        final session = await repository.createNextSession(
          mode: GameMode.fiveLetters,
          round: 2,
          excluding: 'حديقة',
        );

        expect(session.round, 2);
        expect(session.answer, 'مدرسة');
        expect(session.category, 'التعليم');
      },
    );

    test('stores and restores sessions independently per mode', () async {
      final repository = GameLocalRepository(
        store: _InMemoryKeyValueStore(),
        puzzleBank: ArabicPuzzleBank({
          GameMode.threeLetters: [
            const ArabicPuzzle(word: 'بيت', category: 'المنزل'),
            const ArabicPuzzle(word: 'باب', category: 'المنزل'),
          ],
          GameMode.fiveLetters: [
            const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
            const ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
          ],
        }),
        random: _FixedRandom(0),
        now: () => fixedNow,
      );

      await repository.saveSession(
        const GameSession(
          mode: GameMode.threeLetters,
          round: 4,
          answer: 'بيت',
          guesses: ['باب'],
        ),
      );
      await repository.saveSession(
        const GameSession(
          mode: GameMode.fiveLetters,
          round: 2,
          answer: 'حديقة',
          guesses: ['مدرسة'],
        ),
      );

      final shortSession = await repository.restoreOrCreateSession(
        GameMode.threeLetters,
      );
      final longSession = await repository.restoreOrCreateSession(
        GameMode.fiveLetters,
      );

      expect(shortSession.mode, GameMode.threeLetters);
      expect(shortSession.round, 4);
      expect(shortSession.category, 'المنزل');
      expect(longSession.mode, GameMode.fiveLetters);
      expect(longSession.round, 2);
      expect(longSession.category, 'الطبيعة');
    });

    test('restores saved hint progress for a cached session', () async {
      final repository = GameLocalRepository(
        store: _InMemoryKeyValueStore(),
        puzzleBank: ArabicPuzzleBank({
          GameMode.fiveLetters: [
            const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
            const ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
          ],
        }),
        random: _FixedRandom(0),
        now: () => fixedNow,
      );

      await repository.saveSession(
        GameSession(
          mode: GameMode.fiveLetters,
          round: 2,
          answer: 'حديقة',
          guesses: const ['مدرسة'],
          revealedHintIndexes: const [0],
          startedAtEpochMs: fixedNow.millisecondsSinceEpoch,
          nextHintAvailableAtEpochMs: fixedNow
              .add(const Duration(minutes: 1))
              .millisecondsSinceEpoch,
        ),
      );

      final session = await repository.restoreOrCreateSession(
        GameMode.fiveLetters,
      );

      expect(session.revealedHintIndexes, [0]);
      expect(
        session.nextHintAvailableAtEpochMs,
        fixedNow.add(const Duration(minutes: 1)).millisecondsSinceEpoch,
      );
      expect(session.category, 'الطبيعة');
    });

    test('backfills category for older cached sessions missing it', () async {
      final store = _InMemoryKeyValueStore();
      final repository = GameLocalRepository(
        store: store,
        puzzleBank: ArabicPuzzleBank({
          GameMode.fiveLetters: [
            const ArabicPuzzle(word: 'حديقة', category: 'الطبيعة'),
            const ArabicPuzzle(word: 'مدرسة', category: 'التعليم'),
          ],
        }),
        random: _FixedRandom(0),
        now: () => fixedNow,
      );

      await store.setString(
        'active_session_5',
        '{"round":1,"answer":"حديقة","guesses":[],"mode":"5","maxAttempts":6,"revealedHintIndexes":[],"startedAtEpochMs":0,"nextHintAvailableAtEpochMs":0}',
      );

      final session = await repository.restoreOrCreateSession(
        GameMode.fiveLetters,
      );

      expect(session.category, 'الطبيعة');
    });
  });
}

class _InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<bool?> getBool(String key) async {
    return _values[key] as bool?;
  }

  @override
  Future<String?> getString(String key) async {
    return _values[key] as String?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}

class _FixedRandom implements Random {
  _FixedRandom(this._value);

  final int _value;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => _value % max;
}
