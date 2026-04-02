import 'dart:math';

import 'package:arabic_wordly/app/app.dart';
import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameScreen', () {
    testWidgets('fits on a phone-sized viewport without layout overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildTestApp(store: _InMemoryKeyValueStore(), random: _FixedRandom(0)),
      );

      await tester.pumpAndSettle();

      expect(find.text('0 / 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('loads directly into the current puzzle for a new user', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(store: _InMemoryKeyValueStore(), random: _FixedRandom(0)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Arabic Wordly'), findsOneWidget);
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
        _buildTestApp(store: _InMemoryKeyValueStore(), random: _FixedRandom(0)),
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
        _buildTestApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedSequenceRandom([0, 1]),
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
        _buildTestApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedSequenceRandom([0, 1]),
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
        _buildTestApp(
          store: _InMemoryKeyValueStore(),
          random: _FixedSequenceRandom([0, 1]),
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
  });
}

ProviderScope _buildTestApp({
  required KeyValueStore store,
  required Random random,
}) {
  return ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(store),
      randomProvider.overrideWithValue(random),
      puzzleBankProvider.overrideWithValue(
        ArabicPuzzleBank(['حديقة', 'مدرسة', 'مكتبة']),
      ),
    ],
    child: const ArabicWordlyApp(),
  );
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
