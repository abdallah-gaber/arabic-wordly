import 'package:arabic_wordly/app/services/notification_service.dart';
import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalNotificationService', () {
    test(
      'resets the scheduled streak reminder when a new session is recorded',
      () async {
        final platform = _FakeNotificationSchedulerPlatform();
        final service = LocalNotificationService(
          store: _InMemoryKeyValueStore(),
          platform: platform,
        );

        await service.scheduleDailyStreakReminder(
          lastActiveAt: DateTime(2026, 4, 15, 10),
        );
        await service.scheduleDailyStreakReminder(
          lastActiveAt: DateTime(2026, 4, 15, 18, 30),
        );

        expect(platform.cancelledIds, [5001, 5001]);
        expect(platform.scheduledNotifications, hasLength(2));
        expect(
          platform.scheduledNotifications.last.scheduledFor,
          DateTime(2026, 4, 16, 18, 30),
        );
      },
    );

    test('prompts only until the permission prompt has been seen', () async {
      final service = LocalNotificationService(
        store: _InMemoryKeyValueStore(),
        platform: _FakeNotificationSchedulerPlatform(),
      );

      expect(await service.shouldPromptForPermission(), isTrue);

      await service.markPermissionPromptSeen();

      expect(await service.shouldPromptForPermission(), isFalse);
    });
  });
}

class _FakeNotificationSchedulerPlatform
    implements NotificationSchedulerPlatform {
  final List<int> cancelledIds = <int>[];
  final List<_ScheduledNotification> scheduledNotifications =
      <_ScheduledNotification>[];

  @override
  bool get supportsNotifications => true;

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledFor,
  }) async {
    scheduledNotifications.add(
      _ScheduledNotification(
        id: id,
        title: title,
        body: body,
        scheduledFor: scheduledFor,
      ),
    );
  }
}

class _ScheduledNotification {
  const _ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledFor,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledFor;
}

class _InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}
