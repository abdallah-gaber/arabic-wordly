import 'package:arabic_wordly/app/app.dart';
import 'package:arabic_wordly/app/services/notification_service.dart';
import 'package:arabic_wordly/features/game/application/game_providers.dart';
import 'package:arabic_wordly/features/game/data/shared_preferences_key_value_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final keyValueStore = SharedPreferencesKeyValueStore(sharedPreferences);
  final notificationService = LocalNotificationService(store: keyValueStore);
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(keyValueStore),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const ArabicWordlyApp(),
    ),
  );
}
