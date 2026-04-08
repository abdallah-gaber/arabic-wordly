import 'dart:convert';

import 'package:arabic_wordly/features/game/data/key_value_store.dart';
import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/daily_mode_repository.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';

class LocalDailyModeRepository implements DailyModeRepository {
  LocalDailyModeRepository({
    required KeyValueStore store,
    required ArabicPuzzleBank puzzleBank,
  }) : _store = store,
       _puzzleBank = puzzleBank;

  final KeyValueStore _store;
  final ArabicPuzzleBank _puzzleBank;

  @override
  Future<DailyPuzzle> puzzleForDate({
    required GameMode mode,
    required DateTime date,
  }) async {
    final dateKey = _dateKey(date);
    final puzzles = _puzzleBank.puzzlesForMode(mode);
    final index = _stableIndex(
      mode: mode,
      dateKey: dateKey,
      count: puzzles.length,
    );
    final puzzle = puzzles[index];

    return DailyPuzzle(
      mode: mode,
      dateKey: dateKey,
      answer: puzzle.word,
      category: puzzle.category,
    );
  }

  @override
  Future<DailyProgress?> restoreProgress({
    required GameMode mode,
    required DateTime date,
  }) async {
    final raw = await _store.getString(_progressKey(mode, _dateKey(date)));
    if (raw == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return DailyProgress.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProgress(DailyProgress progress) async {
    await _store.setString(
      _progressKey(progress.mode, progress.dateKey),
      jsonEncode(progress.toJson()),
    );
  }

  int _stableIndex({
    required GameMode mode,
    required String dateKey,
    required int count,
  }) {
    if (count <= 0) {
      throw StateError('No daily puzzles are available for ${mode.cacheKey}.');
    }

    final seed = '$dateKey-${mode.cacheKey}';
    var hash = 2166136261;
    for (final codeUnit in seed.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash % count;
  }

  String _dateKey(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  String _progressKey(GameMode mode, String dateKey) {
    return 'daily_progress_${mode.cacheKey}_$dateKey';
  }
}
