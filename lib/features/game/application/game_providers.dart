import 'dart:math';

import 'package:arabic_wordly/app/services/notification_service.dart';
import 'package:arabic_wordly/features/game/data/game_local_repository.dart';
import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/local_daily_mode_repository.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/daily_mode_repository.dart';
import 'package:arabic_wordly/features/game/domain/player_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Clock = DateTime Function();

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('Override keyValueStoreProvider in main.'),
);

final randomProvider = Provider<Random>((ref) => Random());
final clockProvider = Provider<Clock>((ref) => DateTime.now);
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => const NoopNotificationService(),
);

final puzzleBankProvider = Provider<ArabicPuzzleBank>(
  (ref) => ArabicPuzzleBank.defaults(),
);

final playerStatsProvider = FutureProvider<PlayerStats>((ref) async {
  return ref.watch(gameRepositoryProvider).restoreStats();
});

final dailyModeRepositoryProvider = Provider<DailyModeRepository>((ref) {
  return LocalDailyModeRepository(
    store: ref.watch(keyValueStoreProvider),
    puzzleBank: ref.watch(puzzleBankProvider),
  );
});

final gameRepositoryProvider = Provider<GameLocalRepository>((ref) {
  return GameLocalRepository(
    store: ref.watch(keyValueStoreProvider),
    puzzleBank: ref.watch(puzzleBankProvider),
    random: ref.watch(randomProvider),
    now: ref.watch(clockProvider),
  );
});
