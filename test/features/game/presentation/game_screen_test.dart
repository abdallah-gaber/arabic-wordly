import 'package:arabic_wordly/app/app.dart';
import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import '../../../support/fixed_random.dart';
import '../../../support/game_test_overrides.dart';
import '../../../support/in_memory_key_value_store.dart';
import '../../../support/mutable_clock.dart';
import '../../../support/widget_test_puzzle_bank.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clock = MutableClock(DateTime(2026, 4, 2, 8));

  group('GameScreen', () {
    testWidgets('opens first to mode selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            keyValueStoreProvider.overrideWithValue(InMemoryKeyValueStore()),
            randomProvider.overrideWithValue(FixedRandom(0)),
            puzzleBankProvider.overrideWithValue(widgetTestPuzzleBank),
            clockProvider.overrideWithValue(clock.call),
          ],
          child: const ArabicWordlyApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('اختر طول التحدي وابدأ فوراً'), findsOneWidget);
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
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0 / 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the 6-letter mode readable on a phone-sized viewport', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedRandom(0),
          mode: GameMode.sixLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('الوضع الحالي: 6 أحرف'), findsOneWidget);
      expect(find.text('ابدأ التخمين'), findsOneWidget);
      expect(find.text('0 / 6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a selected mode with the correct word length', (
      tester,
    ) async {
      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedRandom(0),
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
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('خمنها'), findsOneWidget);
      expect(find.text('5amenha'), findsOneWidget);
      expect(find.text('الجولة'), findsOneWidget);
      expect(find.text('الفئة: الطبيعة'), findsOneWidget);
      expect(find.text('أكمل الكلمة أولاً'), findsOneWidget);
      expect(find.text('0 / 5'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    });

    testWidgets('enters typing mode when the input is focused', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('5amenha'), findsOneWidget);

      await tester.showKeyboard(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('5amenha'), findsNothing);
      expect(find.text('المتبقي 6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('enables verify only after the required number of letters', (
      tester,
    ) async {
      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedRandom(0),
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

    testWidgets('strips non-Arabic characters from the guess field', (
      tester,
    ) async {
      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'abحديقةxyz');
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, 'حديقة');
      expect(find.text('5 / 5'), findsOneWidget);
    });

    testWidgets('advances to the next round when the puzzle is solved', (
      tester,
    ) async {
      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedSequenceRandom([0, 1]),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'حديقة');
      await tester.pump();
      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'تحقق الآن'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'تحقق الآن'));
      await tester.pumpAndSettle();

      expect(find.text('أحسنت!'), findsOneWidget);
      expect(find.text('الكلمة الصحيحة: حديقة'), findsOneWidget);
      expect(find.text('+244 نقطة'), findsOneWidget);
      expect(find.text('المجموع 244'), findsOneWidget);
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.pumpAndSettle();

      expect(find.text('بدأ لغز جديد. يمكنك المتابعة.'), findsOneWidget);
    });

    testWidgets('starts a fresh puzzle when the player skips the current one', (
      tester,
    ) async {
      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedSequenceRandom([0, 1]),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('لغز جديد'));
      await tester.tap(find.text('لغز جديد'));
      await tester.pumpAndSettle();

      expect(
        find.text('تم فتح لغز جديد. تم احتساب التخطي كخسارة في الإحصاءات.'),
        findsOneWidget,
      );
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('shows the correct answer after a failed puzzle', (
      tester,
    ) async {
      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedSequenceRandom([0, 1]),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      for (var attempt = 0; attempt < 6; attempt++) {
        await tester.enterText(find.byType(TextField), 'مكتبة');
        await tester.pump();
        await tester.ensureVisible(
          find.widgetWithText(ElevatedButton, 'تحقق الآن'),
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'تحقق الآن'));
        await tester.pumpAndSettle();
      }

      expect(find.text('انتهت المحاولات'), findsOneWidget);
      expect(find.text('الكلمة الصحيحة: حديقة'), findsOneWidget);

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'جرب لغزاً جديداً'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'جرب لغزاً جديداً'));
      await tester.pumpAndSettle();

      expect(find.text('بدأ لغز جديد. يمكنك المتابعة.'), findsOneWidget);
    });

    testWidgets('reveals a hint immediately and starts the next countdown', (
      tester,
    ) async {
      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('hint-panel-toggle')),
      );
      await tester.tap(find.byKey(const ValueKey('hint-panel-toggle')));
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

    testWidgets(
      'shows hints as a collapsible secondary panel on compact layouts',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          gameScreenTestApp(
            store: InMemoryKeyValueStore(),
            random: FixedRandom(0),
            mode: GameMode.fiveLetters,
            clock: clock.call,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('التلميحات'), findsOneWidget);
        expect(
          find.widgetWithText(FilledButton, 'استخدم تلميحاً'),
          findsNothing,
        );

        await tester.ensureVisible(
          find.byKey(const ValueKey('hint-panel-toggle')),
        );
        await tester.tap(find.byKey(const ValueKey('hint-panel-toggle')));
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(FilledButton, 'استخدم تلميحاً'),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const ValueKey('hint-panel-toggle')));
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(FilledButton, 'استخدم تلميحاً'),
          findsNothing,
        );
      },
    );
  });
}
