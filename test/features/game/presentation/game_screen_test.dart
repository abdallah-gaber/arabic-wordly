import 'dart:math';

import 'package:arabic_wordly/app/app.dart';
import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/presentation/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clock = _MutableClock(DateTime(2026, 4, 2, 8));

  group('GameScreen', () {
    testWidgets('opens first to mode selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            keyValueStoreProvider.overrideWithValue(_InMemoryKeyValueStore()),
            randomProvider.overrideWithValue(_FixedRandom(0)),
            puzzleBankProvider.overrideWithValue(_testPuzzleBank),
            clockProvider.overrideWithValue(clock.call),
          ],
          child: const ArabicWordlyApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('اختر وضع اللعب'), findsOneWidget);
      expect(find.text('3 أحرف'), findsOneWidget);
      expect(find.text('4 أحرف'), findsOneWidget);
      expect(find.text('5 أحرف'), findsOneWidget);
      expect(find.text('6 أحرف'), findsOneWidget);
    });

    testWidgets('fits on a phone-sized viewport without layout overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildGameApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0 / 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a selected mode with the correct word length', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGameApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedRandom(0),
          mode: GameMode.threeLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('الوضع الحالي: 3 أحرف'), findsOneWidget);
      expect(find.text('0 / 3'), findsOneWidget);
    });

    testWidgets('loads directly into the current puzzle for a new user', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGameApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('خمنها'), findsOneWidget);
      expect(find.text('5amenha'), findsOneWidget);
      expect(find.text('الجولة'), findsOneWidget);
      expect(find.text('تحقق'), findsOneWidget);
      expect(find.text('0 / 5'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    });

    testWidgets('enables verify only after the required number of letters', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGameApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'حدي');
      await tester.pump();

      expect(find.text('3 / 5'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );

      await tester.enterText(find.byType(TextField), 'حديقة');
      await tester.pump();

      expect(find.text('5 / 5'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('advances to the next round when the puzzle is solved', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGameApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedSequenceRandom([0, 1]),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'حديقة');
      await tester.pump();
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'تحقق'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'تحقق'));
      await tester.pumpAndSettle();

      expect(find.text('أحسنت!'), findsOneWidget);
      expect(find.text('الكلمة الصحيحة: حديقة'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('starts a fresh puzzle when the player skips the current one', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGameApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedSequenceRandom([0, 1]),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('لغز جديد'));
      await tester.tap(find.text('لغز جديد'));
      await tester.pumpAndSettle();

      expect(
        find.text('تم فتح لغز جديد. يمكنك المحاولة من جديد.'),
        findsOneWidget,
      );
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('shows the correct answer after a failed puzzle', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGameApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedSequenceRandom([0, 1]),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      for (var attempt = 0; attempt < 6; attempt++) {
        await tester.enterText(find.byType(TextField), 'مكتبة');
        await tester.pump();
        await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'تحقق'));
        await tester.tap(find.widgetWithText(ElevatedButton, 'تحقق'));
        await tester.pumpAndSettle();
      }

      expect(find.text('انتهت المحاولات'), findsOneWidget);
      expect(find.text('الكلمة الصحيحة: حديقة'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'جرب لغزاً جديداً'));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('reveals a hint immediately and starts the next countdown', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildGameApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('التلميح التالي جاهز الآن.'), findsOneWidget);
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'استخدم تلميحاً'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'استخدم تلميحاً'));
      await tester.pumpAndSettle();

      expect(find.textContaining('تم كشف الحرف رقم 1'), findsOneWidget);
      expect(find.textContaining('التلميح التالي بعد 01:'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });
  });
}

ProviderScope _buildGameApp({
  required KeyValueStore store,
  required Random random,
  required GameMode mode,
  required Clock clock,
}) {
  return ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(store),
      randomProvider.overrideWithValue(random),
      puzzleBankProvider.overrideWithValue(_testPuzzleBank),
      clockProvider.overrideWithValue(clock),
    ],
    child: MaterialApp(home: GameScreen(mode: mode)),
  );
}

final _testPuzzleBank = ArabicPuzzleBank({
  GameMode.threeLetters: ['بيت', 'باب', 'نور'],
  GameMode.fourLetters: ['كتاب', 'قهوة', 'وردة'],
  GameMode.fiveLetters: ['حديقة', 'مدرسة', 'مكتبة'],
  GameMode.sixLetters: ['سيارات', 'مدارسك', 'تفاحات'],
});

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

class _FixedSequenceRandom implements Random {
  _FixedSequenceRandom(this._values);

  final List<int> _values;
  int _index = 0;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) {
    final value = _values[_index % _values.length] % max;
    _index += 1;
    return value;
  }
}

class _MutableClock {
  _MutableClock(this._now);

  DateTime _now;

  DateTime call() => _now;

  void set(DateTime value) {
    _now = value;
  }
}
