import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Static haptic helpers (no instance state). No-ops on web and unsupported platforms.
///
/// Named [AppHaptics] rather than `…Service` because this is a thin facade over
/// [HapticFeedback], not an injectable dependency.
class AppHaptics {
  const AppHaptics._();

  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<void> selection() async {
    if (!_isSupported) {
      return;
    }

    await HapticFeedback.selectionClick();
  }

  static Future<void> lightImpact() async {
    if (!_isSupported) {
      return;
    }

    await HapticFeedback.lightImpact();
  }

  static Future<void> mediumImpact() async {
    if (!_isSupported) {
      return;
    }

    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavyImpact() async {
    if (!_isSupported) {
      return;
    }

    await HapticFeedback.heavyImpact();
  }

  static Future<void> success() async {
    if (!_isSupported) {
      return;
    }

    await HapticFeedback.mediumImpact();
  }

  static Future<void> warning() async {
    if (!_isSupported) {
      return;
    }

    await HapticFeedback.selectionClick();
  }

  static Future<void> failure() async {
    if (!_isSupported) {
      return;
    }

    await HapticFeedback.heavyImpact();
  }
}
