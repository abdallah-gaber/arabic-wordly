import 'package:arabic_wordly/app/services/notification_service.dart';
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
      // Since it's a PageView centered on page 2 (5 letters), the adjacent pages (4, 6) will be rendered.
      expect(find.text('⚖️ متوازن'), findsOneWidget);
      expect(find.text('🧠 كلاسيكي'), findsOneWidget);
      expect(find.text('🔥 تحدي'), findsOneWidget);

      // Swipe right to reveal 3 letters
      await tester.ensureVisible(find.text('🧠 كلاسيكي'));
      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(find.text('⚡ سريع'), findsOneWidget);
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
      expect(find.byKey(const ValueKey('pinned-verify-bar')), findsOneWidget);
      expect(find.text('أكمل الكلمة أولاً'), findsOneWidget);
      expect(find.text('الفئة: الطبيعة'), findsNothing);
      expect(find.text('تغيير الوضع'), findsNothing);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping outside the field exits typing mode', (tester) async {
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
      await tester.showKeyboard(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('pinned-verify-bar')), findsOneWidget);

      await tester.tap(find.text('المتبقي 6'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('pinned-verify-bar')), findsNothing);
      expect(find.text('5amenha'), findsOneWidget);
    });

    testWidgets(
      'keeps the pinned verify action in sync with input readiness while typing',
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
        await tester.showKeyboard(find.byType(TextField));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('pinned-verify-bar')), findsOneWidget);
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
        expect(find.text('تحقق الآن'), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNotNull,
        );
      },
    );

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
      await tester.showKeyboard(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'حدي');
      await tester.pump();

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
      await tester.showKeyboard(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'حدي');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'حد');
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('guess-tile-0-2')),
          matching: find.text('ي'),
        ),
        findsNothing,
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
      expect(find.text('السلسلة الحالية: 1'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'مشاركة النتيجة'),
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
      expect(find.text('اقتربت من الإجابة هذه المرة'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'مشاركة النتيجة'),
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
      await tester.enterText(find.byType(TextField), 'حديقة');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'تحقق الآن'));
      await tester.pumpAndSettle();

      // Tap Next to begin puzzle #2.
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
      await tester.enterText(find.byType(TextField), 'حديقة');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'تحقق الآن'));
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
