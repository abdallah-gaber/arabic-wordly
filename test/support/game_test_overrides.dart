import 'dart:math';

import 'package:arabic_wordly/app/services/notification_service.dart';
import 'package:arabic_wordly/app/services/share_image_service.dart';
import 'package:arabic_wordly/app/services/share_sheet_service.dart';
import 'package:arabic_wordly/features/game/application/game_providers.dart';
import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/presentation/game_screen.dart';
import 'widget_test_puzzle_bank.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [ProviderScope] + [MaterialApp] with the usual game widget-test overrides.
Widget gameScreenTestApp({
  required KeyValueStore store,
  required Random random,
  required GameMode mode,
  required Clock clock,
  ArabicPuzzleBank? puzzleBank,
  NotificationService notificationService = const NoopNotificationService(),
  ShareImageService? shareImageService,
  ShareSheetService? shareSheetService,
  GameTrack track = GameTrack.endless,
}) {
  return ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(store),
      randomProvider.overrideWithValue(random),
      puzzleBankProvider.overrideWithValue(puzzleBank ?? widgetTestPuzzleBank),
      clockProvider.overrideWithValue(clock),
      notificationServiceProvider.overrideWithValue(notificationService),
      if (shareImageService != null)
        shareImageServiceProvider.overrideWithValue(shareImageService),
      if (shareSheetService != null)
        shareSheetServiceProvider.overrideWithValue(shareSheetService),
    ],
    child: MaterialApp(
      home: GameScreen(mode: mode, track: track),
    ),
  );
}
