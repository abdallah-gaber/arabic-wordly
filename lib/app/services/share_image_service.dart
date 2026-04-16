import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:arabic_wordly/app/app_branding.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';
import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum ShareImageVariant { result, help }

class ShareImageCardData {
  const ShareImageCardData({
    required this.variant,
    required this.track,
    required this.mode,
    required this.category,
    required this.guesses,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.footer,
    this.answer,
    this.evaluationAnswer,
  });

  final ShareImageVariant variant;
  final GameTrack track;
  final GameMode mode;
  final String category;
  final List<String> guesses;
  final String statusTitle;
  final String statusSubtitle;
  final String footer;
  final String? answer;
  final String? evaluationAnswer;
}

abstract class ShareImageRenderer {
  Future<Uint8List> render(ShareImageCardData data);
}

abstract class TemporaryDirectoryProvider {
  Future<String> getPath();
}

abstract class BinaryFileWriter {
  Future<void> writeBytes(String path, Uint8List bytes);
}

class ShareImageService {
  ShareImageService({
    ShareImageRenderer? renderer,
    TemporaryDirectoryProvider? temporaryDirectoryProvider,
    BinaryFileWriter? fileWriter,
  }) : _renderer = renderer ?? FlutterShareImageRenderer(),
       _temporaryDirectoryProvider =
           temporaryDirectoryProvider ??
           PathProviderTemporaryDirectoryProvider(),
       _fileWriter = fileWriter ?? DartIoBinaryFileWriter();

  final ShareImageRenderer _renderer;
  final TemporaryDirectoryProvider _temporaryDirectoryProvider;
  final BinaryFileWriter _fileWriter;

  Future<String> createShareImage(ShareImageCardData data) async {
    final directoryPath = await _temporaryDirectoryProvider.getPath();
    final bytes = await _renderer.render(data);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$directoryPath/5amenha-${data.variant.name}-$timestamp.png';
    await _fileWriter.writeBytes(path, bytes);
    return path;
  }
}

class PathProviderTemporaryDirectoryProvider
    implements TemporaryDirectoryProvider {
  @override
  Future<String> getPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
}

class DartIoBinaryFileWriter implements BinaryFileWriter {
  @override
  Future<void> writeBytes(String path, Uint8List bytes) async {
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
  }
}

class FlutterShareImageRenderer implements ShareImageRenderer {
  static const double _width = 1200;
  static const double _height = 1500;
  static const double _padding = 72;
  static const Color _ink = Color(0xFF123032);
  static const Color _muted = Color(0xFF5D635F);
  static const Color _teal = Color(0xFF157A6E);
  static const Color _gold = Color(0xFFE0A93B);
  static const Color _surface = Color(0xFFFFFCF6);
  static const String _appIconAssetPath = 'assets/icons/app_icon.png';

  @override
  Future<Uint8List> render(ShareImageCardData data) async {
    final appIcon = await _loadAppIcon();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, _width, _height));

    _paintBackground(canvas, data);
    _paintCard(canvas);
    _paintBrand(canvas, appIcon);
    _paintHeader(canvas, data);
    _paintGrid(canvas, data);
    _paintFooter(canvas, data);

    final image = await recorder.endRecording().toImage(
      _width.toInt(),
      _height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<ui.Image?> _loadAppIcon() async {
    try {
      final asset = await rootBundle.load(_appIconAssetPath);
      final codec = await ui.instantiateImageCodec(asset.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void _paintBackground(Canvas canvas, ShareImageCardData data) {
    final background = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(_width, _height),
        data.variant == ShareImageVariant.help
            ? const [Color(0xFFFFF4DA), Color(0xFFF2FAF7), Color(0xFFEAF6F2)]
            : const [Color(0xFFF7F1E6), Color(0xFFF4FBF8), Color(0xFFFFF6E2)],
        const [0.0, 0.58, 1.0],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, _width, _height), background);

    final orb = Paint()
      ..shader = ui.Gradient.radial(const Offset(180, 220), 220, const [
        Color(0x33E0A93B),
        Color(0x00FFFFFF),
      ]);
    canvas.drawCircle(const Offset(180, 220), 220, orb);

    final orb2 = Paint()
      ..shader = ui.Gradient.radial(const Offset(1020, 1260), 260, const [
        Color(0x26157A6E),
        Color(0x00FFFFFF),
      ]);
    canvas.drawCircle(const Offset(1020, 1260), 260, orb2);
  }

  void _paintCard(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(46, 42, _width - 92, _height - 84),
      const Radius.circular(42),
    );
    final paint = Paint()..color = _surface;
    canvas.drawShadow(Path()..addRRect(rect), Colors.black26, 26, false);
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFE6DAC0),
    );
  }

  void _paintBrand(Canvas canvas, ui.Image? appIcon) {
    final badgeRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(_width - _padding - 120, 94, 120, 120),
      const Radius.circular(30),
    );
    canvas.drawRRect(badgeRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFE6DAC0),
    );
    if (appIcon != null) {
      canvas.save();
      canvas.clipRRect(badgeRect);
      paintImage(
        canvas: canvas,
        rect: badgeRect.outerRect,
        image: appIcon,
        fit: BoxFit.cover,
      );
      canvas.restore();
    } else {
      canvas.drawRRect(badgeRect, Paint()..color = _teal);
      _paintText(
        canvas,
        'خ',
        Offset(_width - _padding - 60, 116),
        fontSize: 54,
        color: Colors.white,
        fontWeight: FontWeight.w900,
        anchorCenter: true,
      );
    }
    _paintText(
      canvas,
      appNameArabic,
      const Offset(_width - _padding - 148, 108),
      fontSize: 52,
      color: _ink,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.right,
      maxWidth: 340,
      anchorRight: true,
    );
    _paintText(
      canvas,
      appNameEnglish,
      const Offset(_width - _padding - 148, 168),
      fontSize: 28,
      color: _teal,
      fontWeight: FontWeight.w800,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      maxWidth: 320,
      anchorRight: true,
    );
  }

  void _paintHeader(Canvas canvas, ShareImageCardData data) {
    const pillGap = 18.0;
    final trackLabel = _trackShareLabel(data.track);
    final modeLabel = _modeShareLabel(data.mode);
    final trackPillWidth = math.max(
      180.0,
      _measureTextWidth(trackLabel, fontSize: 24, fontWeight: FontWeight.w800) +
          56,
    );
    final modePillWidth = math.max(
      132.0,
      _measureTextWidth(modeLabel, fontSize: 24, fontWeight: FontWeight.w800) +
          56,
    );
    _paintPill(
      canvas,
      label: trackLabel,
      rect: Rect.fromLTWH(
        _width - _padding - trackPillWidth,
        255,
        trackPillWidth,
        58,
      ),
      background: const Color(0xFFEAF3F0),
      foreground: _teal,
    );
    _paintPill(
      canvas,
      label: modeLabel,
      rect: Rect.fromLTWH(
        _width - _padding - trackPillWidth - pillGap - modePillWidth,
        255,
        modePillWidth,
        58,
      ),
      background: const Color(0xFFFFF2D2),
      foreground: const Color(0xFF8A6410),
    );

    _paintText(
      canvas,
      data.statusTitle,
      const Offset(_width - _padding, 344),
      fontSize: 56,
      color: _ink,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.right,
      maxWidth: _width - (_padding * 2),
      anchorRight: true,
    );
    _paintText(
      canvas,
      data.statusSubtitle,
      const Offset(_width - _padding, 420),
      fontSize: 30,
      color: _muted,
      fontWeight: FontWeight.w700,
      textAlign: TextAlign.right,
      maxWidth: _width - (_padding * 2),
      anchorRight: true,
    );

    final categoryLabel = 'الفئة: ${data.category}';
    final categoryTextWidth = _measureTextWidth(
      categoryLabel,
      fontSize: 32,
      fontWeight: FontWeight.w800,
    );
    final categoryWidth = math.min(
      _width - (_padding * 2),
      categoryTextWidth + 72,
    );
    final categoryRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(_width - _padding - categoryWidth, 490, categoryWidth, 94),
      const Radius.circular(28),
    );
    canvas.drawRRect(categoryRect, Paint()..color = const Color(0xFFFFF7E8));
    canvas.drawRRect(
      categoryRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFE8D49A),
    );
    _paintText(
      canvas,
      categoryLabel,
      Offset(_width - _padding - 30, 520),
      fontSize: 32,
      color: const Color(0xFF8A6410),
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.right,
      maxWidth: _width - ((_padding + 30) * 2),
      anchorRight: true,
    );
  }

  void _paintGrid(Canvas canvas, ShareImageCardData data) {
    final answerForEvaluation = data.evaluationAnswer ?? data.answer;
    final rows = answerForEvaluation == null
        ? data.guesses
        : data.guesses
              .map(
                (guess) => GuessEvaluator.evaluate(
                  guess: guess,
                  answer: answerForEvaluation,
                ),
              )
              .toList();
    final top = 640.0;
    final tile = 124.0;
    final gap = 16.0;
    final cols = data.mode.wordLength;
    final totalWidth = (tile * cols) + (gap * (cols - 1));
    final startX = (_width - totalWidth) / 2;

    if (answerForEvaluation == null) {
      for (var row = 0; row < data.guesses.length; row++) {
        final letters = data.guesses[row].characters.toList();
        for (var col = 0; col < math.min(cols, letters.length); col++) {
          final visualCol = cols - 1 - col;
          _paintTile(
            canvas,
            letter: letters[col],
            rect: Rect.fromLTWH(
              startX + (visualCol * (tile + gap)),
              top + (row * (tile + gap)),
              tile,
              tile,
            ),
            background: const Color(0xFFFFF7E8),
            foreground: _ink,
            border: const Color(0xFFE8D49A),
          );
        }
      }
      return;
    }

    for (var row = 0; row < rows.length; row++) {
      final guess = rows[row] as EvaluatedGuess;
      for (var col = 0; col < guess.letters.length; col++) {
        final visualCol = cols - 1 - col;
        final tileRect = Rect.fromLTWH(
          startX + (visualCol * (tile + gap)),
          top + (row * (tile + gap)),
          tile,
          tile,
        );
        final (
          background,
          border,
          foreground,
        ) = switch (guess.letters[col].match) {
          LetterMatch.correct => (
            const Color(0xFF157A6E),
            const Color(0xFF157A6E),
            Colors.white,
          ),
          LetterMatch.present => (
            const Color(0xFFE0A93B),
            const Color(0xFFE0A93B),
            const Color(0xFF4A3510),
          ),
          LetterMatch.absent => (
            const Color(0xFFEDE7DB),
            const Color(0xFFD6CCBC),
            _ink,
          ),
        };
        _paintTile(
          canvas,
          letter: guess.letters[col].letter,
          rect: tileRect,
          background: background,
          foreground: foreground,
          border: border,
        );
      }
    }
  }

  void _paintFooter(Canvas canvas, ShareImageCardData data) {
    final revealLine = data.answer == null
        ? 'الجواب ما زال مخفياً. من يقدر يساعد؟'
        : 'الكلمة: ${data.answer}';
    _paintText(
      canvas,
      revealLine,
      const Offset(_width - _padding, 1220),
      fontSize: 30,
      color: _muted,
      fontWeight: FontWeight.w700,
      textAlign: TextAlign.right,
      maxWidth: _width - (_padding * 2),
      anchorRight: true,
    );
    _paintText(
      canvas,
      data.footer,
      const Offset(_width - _padding, 1280),
      fontSize: 28,
      color: _teal,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.right,
      maxWidth: _width - (_padding * 2),
      anchorRight: true,
    );
  }

  String _trackShareLabel(GameTrack track) {
    return switch (track) {
      GameTrack.daily => 'التحدي اليومي',
      GameTrack.endless => 'المسار المفتوح',
      GameTrack.multiplayer => 'متعدد اللاعبين',
    };
  }

  String _modeShareLabel(GameMode mode) {
    return '${mode.wordLength} أحرف';
  }

  void _paintPill(
    Canvas canvas, {
    required String label,
    required Rect rect,
    required Color background,
    required Color foreground,
  }) {
    final pill = RRect.fromRectAndRadius(rect, const Radius.circular(999));
    canvas.drawRRect(pill, Paint()..color = background);
    _paintText(
      canvas,
      label,
      Offset(rect.right - 24, rect.top + 12),
      fontSize: 24,
      color: foreground,
      fontWeight: FontWeight.w800,
      textAlign: TextAlign.right,
      maxWidth: rect.width - 48,
      anchorRight: true,
    );
  }

  void _paintTile(
    Canvas canvas, {
    required String letter,
    required Rect rect,
    required Color background,
    required Color foreground,
    required Color border,
  }) {
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    canvas.drawRRect(rRect, Paint()..color = background);
    canvas.drawRRect(
      rRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = border,
    );
    _paintText(
      canvas,
      letter,
      Offset(rect.center.dx, rect.top + 34),
      fontSize: 48,
      color: foreground,
      fontWeight: FontWeight.w900,
      textAlign: TextAlign.center,
      maxWidth: rect.width,
      anchorCenter: true,
    );
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
    TextDirection textDirection = TextDirection.rtl,
    TextAlign textAlign = TextAlign.start,
    double? maxWidth,
    bool anchorCenter = false,
    bool anchorRight = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.25,
        ),
      ),
      textDirection: textDirection,
      textAlign: textAlign,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? (_width - (offset.dx * 2)));

    final paintOffset = anchorCenter
        ? Offset(offset.dx - (painter.width / 2), offset.dy)
        : anchorRight
        ? Offset(offset.dx - painter.width, offset.dy)
        : offset;
    painter.paint(canvas, paintOffset);
  }

  double _measureTextWidth(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    TextDirection textDirection = TextDirection.rtl,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.25,
        ),
      ),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();

    return painter.width;
  }
}
