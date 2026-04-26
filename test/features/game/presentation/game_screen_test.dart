import 'package:arabic_wordly/app/services/notification_service.dart';
import 'package:arabic_wordly/app/services/share_image_service.dart';
import 'package:arabic_wordly/app/services/share_sheet_service.dart';
import 'package:arabic_wordly/app/app.dart';
import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import '../../../support/fixed_random.dart';
import '../../../support/game_test_overrides.dart';
import '../../../support/in_memory_key_value_store.dart';
import '../../../support/mutable_clock.dart';
import '../../../support/widget_test_puzzle_bank.dart';
import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clock = MutableClock(DateTime(2026, 4, 2, 8));

  Future<void> tapLetters(WidgetTester tester, String letters) async {
    for (final letter in letters.characters) {
      final finder = find.byKey(ValueKey('game-key-$letter'));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
    }
  }

  Future<void> backspaceLetters(WidgetTester tester, int count) async {
    for (var index = 0; index < count; index++) {
      final finder = find.byKey(const ValueKey('game-keyboard-backspace'));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
    }
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    final finder = find.byKey(const ValueKey('game-keyboard-submit'));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  Color tileFaceColor(WidgetTester tester, int row, int column) {
    final container = tester.widget<AnimatedContainer>(
      find.byKey(ValueKey('guess-tile-face-$row-$column')),
    );
    return (container.decoration as BoxDecoration).color!;
  }

  group('GameScreen', () {
    testWidgets('opens first to mode selection', (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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
      expect(find.text('⚖️ متوازن'), findsOneWidget);
      expect(find.text('🧠 كلاسيكي'), findsOneWidget);
      expect(find.text('🔥 تحدي'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pump();
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

    testWidgets('keeps the keyboard flow stable on a shorter phone viewport', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 720));
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

      expect(find.byKey(const ValueKey('game-arabic-keyboard')), findsOneWidget);
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

      expect(find.text('الوضع الحالي: 🔥 تحدي'), findsOneWidget);
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

      expect(find.text('الوضع الحالي: ⚡ سريع'), findsOneWidget);
      expect(find.text('0 / 3'), findsOneWidget);
    });

    testWidgets(
      'highlights the daily challenge track with a dedicated header',
      (tester) async {
        await tester.pumpWidget(
          gameScreenTestApp(
            store: InMemoryKeyValueStore(),
            random: FixedRandom(0),
            mode: GameMode.fiveLetters,
            track: GameTrack.daily,
            clock: clock.call,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('التحدي اليومي'), findsOneWidget);
        expect(find.text('اليوم في 🧠 كلاسيكي'), findsOneWidget);
        expect(find.text('كلمة واحدة مشتركة للجميع اليوم.'), findsOneWidget);
      },
    );

    testWidgets('daily win exits back to mode selection instead of offering next puzzle', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(900, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = InMemoryKeyValueStore();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            keyValueStoreProvider.overrideWithValue(store),
            randomProvider.overrideWithValue(FixedRandom(0)),
            puzzleBankProvider.overrideWithValue(widgetTestPuzzleBank),
            clockProvider.overrideWithValue(clock.call),
          ],
          child: const ArabicWordlyApp(),
        ),
      );

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('التحدي اليومي'));
      await tester.tap(find.text('التحدي اليومي'));
      await tester.pumpAndSettle();
      await tapLetters(tester, 'مكتبة');
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text('التالي'), findsNothing);
      expect(find.text('العودة للتحديات'), findsOneWidget);

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'العودة للتحديات'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'العودة للتحديات'));
      await tester.pumpAndSettle();

      expect(find.text('اختر طول التحدي وابدأ فوراً'), findsOneWidget);
      expect(find.text('التحدي اليومي'), findsOneWidget);
    });

    testWidgets('daily loss exits back to mode selection instead of offering next puzzle', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(900, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = InMemoryKeyValueStore();
      await store.setString(
        'daily_progress_5_2026-04-02',
        '{"mode":"5","dateKey":"2026-04-02","answer":"مكتبة","category":"القراءة","guesses":["حديقة","مدرسة","دحيقة","قحيدة","حقدية","ديحقة"],"revealedHintIndexes":[],"pointsEarned":0}',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            keyValueStoreProvider.overrideWithValue(store),
            randomProvider.overrideWithValue(FixedRandom(0)),
            puzzleBankProvider.overrideWithValue(widgetTestPuzzleBank),
            clockProvider.overrideWithValue(clock.call),
          ],
          child: const ArabicWordlyApp(),
        ),
      );

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('التحدي اليومي'));
      await tester.tap(find.text('التحدي اليومي'));
      await tester.pumpAndSettle();

      expect(find.text('التالي'), findsNothing);
      expect(find.text('العودة للتحديات'), findsOneWidget);

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'العودة للتحديات'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'العودة للتحديات'));
      await tester.pumpAndSettle();

      expect(find.text('اختر طول التحدي وابدأ فوراً'), findsOneWidget);
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
      expect(find.byKey(const ValueKey('game-arabic-keyboard')), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('game-keyboard-submit')),
        ).onPressed,
        isNull,
      );
    });

    testWidgets('shows the in-app Arabic keyboard by default', (tester) async {
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
      expect(find.byKey(const ValueKey('game-arabic-keyboard')), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const ValueKey('pinned-verify-bar')), findsNothing);
      expect(find.text('ابدأ التخمين'), findsOneWidget);
      expect(find.text('أكمل الكلمة أولاً'), findsOneWidget);
      expect(find.text('الفئة: الطبيعة'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping keyboard letters updates the active guess display', (
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
      await tapLetters(tester, 'حدي');

      expect(find.byKey(const ValueKey('active-guess-display')), findsOneWidget);
      expect(find.text('حدي'), findsWidgets);
      expect(find.text('3 / 5'), findsOneWidget);
    });

    testWidgets('shows progress dots that fill as letters are tapped', (
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
      expect(find.byKey(const ValueKey('guess-progress-dots')), findsOneWidget);

      final initialDot = tester.widget<Container>(
        find.byKey(const ValueKey('guess-progress-dot-0')),
      );
      expect(
        (initialDot.decoration as BoxDecoration).color,
        const Color(0xFFD8D1C5),
      );

      await tapLetters(tester, 'حد');

      final firstDot = tester.widget<Container>(
        find.byKey(const ValueKey('guess-progress-dot-0')),
      );
      final secondDot = tester.widget<Container>(
        find.byKey(const ValueKey('guess-progress-dot-1')),
      );
      final thirdDot = tester.widget<Container>(
        find.byKey(const ValueKey('guess-progress-dot-2')),
      );
      final fourthDot = tester.widget<Container>(
        find.byKey(const ValueKey('guess-progress-dot-3')),
      );

      expect((firstDot.decoration as BoxDecoration).color, const Color(0xFFC84F4F));
      expect((secondDot.decoration as BoxDecoration).color, const Color(0xFFC84F4F));
      expect((thirdDot.decoration as BoxDecoration).color, const Color(0xFFD8D1C5));
      expect((fourthDot.decoration as BoxDecoration).color, const Color(0xFFD8D1C5));
    });

    testWidgets(
      'keeps the keyboard submit action in sync with guess readiness',
      (tester) async {
        await tester.pumpWidget(
          gameScreenTestApp(
            store: InMemoryKeyValueStore(),
            random: FixedRandom(0),
            mode: GameMode.fiveLetters,
            clock: clock.call,
          ),
        );

        await tester.pumpAndSettle();
        await tapLetters(tester, 'حدي');

        expect(find.text('3 / 5'), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(
            find.byKey(const ValueKey('game-keyboard-submit')),
          ).onPressed,
          isNull,
        );

        await tapLetters(tester, 'قة');

        expect(find.text('5 / 5'), findsOneWidget);
        expect(find.text('تحقق'), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(
            find.byKey(const ValueKey('game-keyboard-submit')),
          ).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets('auto-submits once the keyboard completes a valid guess', (
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
      await tapLetters(tester, 'حديقة');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('أحسنت!'), findsOneWidget);
      expect(find.text('الكلمة الصحيحة: حديقة'), findsOneWidget);
    });

    testWidgets('reveals solved tiles in a staggered flip sequence', (
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
      await tapLetters(tester, 'حديقة');
      await tapSubmit(tester);

      await tester.pump(const Duration(milliseconds: 20));
      expect(tileFaceColor(tester, 0, 0), const Color(0xFF157A6E));
      expect(tileFaceColor(tester, 0, 4), Colors.white);

      await tester.pump(const Duration(milliseconds: 240));
      expect(tileFaceColor(tester, 0, 4), const Color(0xFF157A6E));

      await tester.pumpAndSettle();
      expect(find.text('أحسنت!'), findsOneWidget);
    });

    testWidgets('cancels a pending auto-submit when the guess is edited', (
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
      await tapLetters(tester, 'حديقة');
      await tester.pump(const Duration(milliseconds: 100));
      await backspaceLetters(tester, 1);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('أحسنت!'), findsNothing);
      expect(find.text('4 / 5'), findsOneWidget);
      expect(find.text('حديق'), findsWidgets);
    });

    testWidgets('rejects a word outside the puzzle bank and shakes the row', (
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
      await tapLetters(tester, 'سفينة');
      await tester.pump();

      final initialPosition = tester.getTopLeft(
        find.byKey(const ValueKey('guess-tile-0-0')),
      );

      await tapSubmit(tester);
      await tester.pump(const Duration(milliseconds: 60));

      final shakenPosition = tester.getTopLeft(
        find.byKey(const ValueKey('guess-tile-0-0')),
      );

      expect(find.text('هذه الكلمة غير موجودة في بنك الكلمات الحالي.'), findsOneWidget);
      expect(shakenPosition.dx, isNot(initialPosition.dx));
      expect(find.text('أحسنت!'), findsNothing);

      await tester.pumpAndSettle();
      final settledPosition = tester.getTopLeft(
        find.byKey(const ValueKey('guess-tile-0-0')),
      );
      expect(settledPosition.dx, closeTo(initialPosition.dx, 0.01));
    });

    testWidgets('mirrors the typed guess in the active board row', (
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
      await tapLetters(tester, 'حدي');

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('guess-tile-0-0')),
          matching: find.text('ح'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('guess-tile-0-1')),
          matching: find.text('د'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('guess-tile-0-2')),
          matching: find.text('ي'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('clears the active row preview when deleting letters', (
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
      await tapLetters(tester, 'حدي');
      await backspaceLetters(tester, 1);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('guess-tile-0-2')),
          matching: find.text('ي'),
        ),
        findsNothing,
      );
    });

    testWidgets('restores a saved draft guess after rebuilding the screen', (
      tester,
    ) async {
      final store = InMemoryKeyValueStore();

      await tester.pumpWidget(
        gameScreenTestApp(
          store: store,
          random: FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();
      await tapLetters(tester, 'حد');
      await tester.pumpAndSettle();

      expect(find.text('حد'), findsWidgets);

      await tester.pumpWidget(
        gameScreenTestApp(
          store: store,
          random: FixedRandom(0),
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('active-guess-display')), findsOneWidget);
      expect(find.text('حد'), findsWidgets);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('guess-tile-0-0')),
          matching: find.text('ح'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('guess-tile-0-1')),
          matching: find.text('د'),
        ),
        findsOneWidget,
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
      await tapLetters(tester, 'حديقة');
      await tester.pump();

      expect(find.text('حديقة'), findsWidgets);
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

      await tapLetters(tester, 'حديقة');
      await tester.pump();
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      expect(find.text('أحسنت!'), findsOneWidget);
      expect(find.text('الكلمة الصحيحة: حديقة'), findsOneWidget);
      expect(find.text('معنى الكلمة'), findsOneWidget);
      expect(
        find.text(
          'مساحة مزروعة تضم نباتات وأزهاراً وتُستخدم للراحة أو التنزه.',
        ),
        findsOneWidget,
      );
      expect(find.text('+244 نقطة'), findsOneWidget);
      expect(find.text('المجموع 244'), findsOneWidget);
      expect(find.text('السلسلة الحالية: 1'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'مشاركة صورة'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, 'مشاركة نصية'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.pumpAndSettle();

      expect(find.text('أحسنت!'), findsNothing);
      expect(find.text('المحاولة الحالية'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'لغز جديد'), findsOneWidget);
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

      final losingGuesses = ['دحيقة', 'قحيدة', 'حقدية', 'ديحقة', 'يقةحد', 'قديحة'];
      for (final guess in losingGuesses) {
        await tapLetters(tester, guess);
        await tester.pump();
        await tapSubmit(tester);
        await tester.pumpAndSettle();
      }

      expect(find.text('انتهت المحاولات'), findsOneWidget);
      expect(find.text('الكلمة الصحيحة: حديقة'), findsOneWidget);
      expect(find.text('معنى الكلمة'), findsOneWidget);
      expect(
        find.text(
          'مساحة مزروعة تضم نباتات وأزهاراً وتُستخدم للراحة أو التنزه.',
        ),
        findsOneWidget,
      );
      expect(find.text('اقتربت من الإجابة هذه المرة'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'مشاركة صورة'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, 'مشاركة نصية'),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'جرب لغزاً جديداً'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'جرب لغزاً جديداً'));
      await tester.pumpAndSettle();

      expect(find.text('انتهت المحاولات'), findsNothing);
      expect(find.text('المحاولة الحالية'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'لغز جديد'), findsOneWidget);
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

    testWidgets('shows the 🔥 streak badge only when streak > 0', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(
        const Size(800, 800),
      ); // Non-compact layout
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedSequenceRandom([0, 1]), // answers: حديقة -> مكتبة
          mode: GameMode.fiveLetters,
          clock: clock.call,
        ),
      );

      await tester.pumpAndSettle();

      // Streak starts at 0 -> no fire badge.
      expect(find.text('🔥'), findsNothing);

      // Solve first puzzle.
      await tapLetters(tester, 'حديقة');
      await tester.pump();
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      // Tap Next to begin puzzle #2.
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.pumpAndSettle();

      // Streak is now 1 -> fire badge is visible.
      expect(find.text('🔥'), findsOneWidget);
    });

    testWidgets('prompts for notification permission after the first win', (
      tester,
    ) async {
      final notifications = _FakeNotificationService();

      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedSequenceRandom([0, 1]),
          mode: GameMode.fiveLetters,
          clock: clock.call,
          notificationService: notifications,
        ),
      );

      await tester.pumpAndSettle();
      await tapLetters(tester, 'حديقة');
      await tester.pump();
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'التالي'));
      await tester.pumpAndSettle();

      expect(find.text('ذكّرني بالمحافظة على السلسلة'), findsOneWidget);
      expect(notifications.markPromptSeenCount, 1);

      await tester.tap(find.widgetWithText(FilledButton, 'فعّل التذكير'));
      await tester.pumpAndSettle();

      expect(notifications.requestPermissionCount, 1);
      expect(notifications.scheduledReminders, hasLength(2));
      expect(find.text('المحاولة الحالية'), findsOneWidget);
    });

    testWidgets('shares a branded image from the solved result dialog', (
      tester,
    ) async {
      final shareImageService = _FakeShareImageService();
      final shareSheetService = _FakeShareSheetService();

      await tester.pumpWidget(
        gameScreenTestApp(
          store: InMemoryKeyValueStore(),
          random: FixedSequenceRandom([0, 1]),
          mode: GameMode.fiveLetters,
          clock: clock.call,
          shareImageService: shareImageService,
          shareSheetService: shareSheetService,
        ),
      );

      await tester.pumpAndSettle();
      await tapLetters(tester, 'حديقة');
      await tester.pump();
      await tapSubmit(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'مشاركة صورة'),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'مشاركة صورة'));
      await tester.pumpAndSettle();

      expect(shareImageService.createCalls, 1);
      expect(shareSheetService.sharedFiles, hasLength(1));
      expect(shareSheetService.sharedFiles.single, [
        '/tmp/fake-share-image.png',
      ]);
    });

    testWidgets(
      'shares current progress for help once the player has guessed',
      (tester) async {
        final shareImageService = _FakeShareImageService();
        final shareSheetService = _FakeShareSheetService();

        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          gameScreenTestApp(
            store: InMemoryKeyValueStore(),
            random: FixedRandom(0),
            mode: GameMode.fiveLetters,
            clock: clock.call,
            shareImageService: shareImageService,
            shareSheetService: shareSheetService,
          ),
        );

        await tester.pumpAndSettle();
        await tapLetters(tester, 'مكتبة');
        await tester.pump();
        await tapSubmit(tester);
        await tester.pumpAndSettle();

        await tester.ensureVisible(
          find.widgetWithText(OutlinedButton, 'شارك للمساعدة بصورة'),
        );
        await tester.tap(
          find.widgetWithText(OutlinedButton, 'شارك للمساعدة بصورة'),
        );
        await tester.pumpAndSettle();

        expect(shareImageService.createCalls, 1);
        expect(shareSheetService.sharedFiles, hasLength(1));
      },
    );
  });
}

class _FakeNotificationService implements NotificationService {
  int markPromptSeenCount = 0;
  int requestPermissionCount = 0;
  final List<DateTime> scheduledReminders = <DateTime>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> markPermissionPromptSeen() async {
    markPromptSeenCount++;
  }

  @override
  Future<bool> requestPermission() async {
    requestPermissionCount++;
    return true;
  }

  @override
  Future<void> scheduleDailyStreakReminder({
    required DateTime lastActiveAt,
  }) async {
    scheduledReminders.add(lastActiveAt);
  }

  @override
  Future<bool> shouldPromptForPermission() async {
    return markPromptSeenCount == 0;
  }
}

class _FakeShareImageService extends ShareImageService {
  _FakeShareImageService() : super();

  int createCalls = 0;

  @override
  Future<String> createShareImage(ShareImageCardData data) async {
    createCalls++;
    return '/tmp/fake-share-image.png';
  }
}

class _FakeShareSheetService implements ShareSheetService {
  final List<List<String>> sharedFiles = <List<String>>[];
  final List<String> sharedTexts = <String>[];

  @override
  Future<void> shareFiles(
    List<String> paths, {
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    sharedFiles.add(paths);
  }

  @override
  Future<void> shareText(String text, {Rect? sharePositionOrigin}) async {
    sharedTexts.add(text);
  }
}
