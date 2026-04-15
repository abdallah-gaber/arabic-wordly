import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  Future<void> initialize();
  Future<void> scheduleDailyStreakReminder({required DateTime lastActiveAt});
  Future<bool> shouldPromptForPermission();
  Future<void> markPermissionPromptSeen();
  Future<bool> requestPermission();
}

class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> markPermissionPromptSeen() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDailyStreakReminder({
    required DateTime lastActiveAt,
  }) async {}

  @override
  Future<bool> shouldPromptForPermission() async => false;
}

class LocalNotificationService implements NotificationService {
  LocalNotificationService({
    required KeyValueStore store,
    NotificationSchedulerPlatform? platform,
  }) : _store = store,
       _platform = platform ?? FlutterNotificationSchedulerPlatform();

  static const int _streakReminderId = 5001;
  static const String _permissionPromptSeenKey =
      'streak_notification_permission_prompt_seen';

  final KeyValueStore _store;
  final NotificationSchedulerPlatform _platform;

  @override
  Future<void> initialize() {
    return _platform.initialize();
  }

  @override
  Future<void> scheduleDailyStreakReminder({
    required DateTime lastActiveAt,
  }) async {
    if (!_platform.supportsNotifications) {
      return;
    }

    await _platform.cancel(_streakReminderId);
    await _platform.schedule(
      id: _streakReminderId,
      title: 'سلسلتك تنتظرك 🔥',
      body: 'مرّ يوم كامل. افتح خمنها قبل أن تنكسر السلسلة.',
      scheduledFor: lastActiveAt.add(const Duration(hours: 24)),
    );
  }

  @override
  Future<bool> shouldPromptForPermission() async {
    if (!_platform.supportsNotifications) {
      return false;
    }

    return !(await _store.getBool(_permissionPromptSeenKey) ?? false);
  }

  @override
  Future<void> markPermissionPromptSeen() async {
    await _store.setBool(_permissionPromptSeenKey, true);
  }

  @override
  Future<bool> requestPermission() {
    return _platform.requestPermission();
  }
}

abstract class NotificationSchedulerPlatform {
  bool get supportsNotifications;
  Future<void> initialize();
  Future<void> cancel(int id);
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledFor,
  });
  Future<bool> requestPermission();
}

class FlutterNotificationSchedulerPlatform
    implements NotificationSchedulerPlatform {
  FlutterNotificationSchedulerPlatform({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'daily_streak_reminders',
    'Daily Streak Reminders',
    description: 'Reminders that help the player maintain a streak.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  bool get supportsNotifications => !kIsWeb;

  @override
  Future<void> initialize() async {
    if (!supportsNotifications || _initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {}

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    try {
      await _plugin.initialize(settings: initializationSettings);
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(_channel);
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('Notification initialization skipped: $error\n$stackTrace');
    }
  }

  @override
  Future<void> cancel(int id) async {
    if (!supportsNotifications) {
      return;
    }

    await _plugin.cancel(id: id);
  }

  @override
  Future<bool> requestPermission() async {
    if (!supportsNotifications) {
      return false;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macos != null) {
      return await macos.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledFor,
  }) async {
    if (!supportsNotifications) {
      return;
    }

    await initialize();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledFor, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_streak_reminders',
          'Daily Streak Reminders',
          channelDescription:
              'Reminders that help the player maintain a streak.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
