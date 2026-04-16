import 'dart:typed_data';

import 'package:arabic_wordly/app/services/share_image_service.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShareImageService', () {
    test(
      'caches the generated screenshot in a temporary directory before sharing',
      () async {
        final writer = _FakeBinaryFileWriter();
        final service = ShareImageService(
          renderer: _FakeShareImageRenderer(),
          temporaryDirectoryProvider: _FakeTemporaryDirectoryProvider(
            '/tmp/share-cache',
          ),
          fileWriter: writer,
        );

        final path = await service.createShareImage(
          const ShareImageCardData(
            variant: ShareImageVariant.result,
            track: GameTrack.daily,
            mode: GameMode.fiveLetters,
            category: 'الطبيعة',
            guesses: ['مكتبة', 'حديقة'],
            answer: 'حديقة',
            statusTitle: 'تم حل اللغز',
            statusSubtitle: '2 / 6 محاولات',
            footer: 'شارك النتيجة وتحدّ أصحابك.',
          ),
        );

        expect(path, startsWith('/tmp/share-cache/5amenha-result-'));
        expect(path, endsWith('.png'));
        expect(writer.lastPath, path);
        expect(writer.lastBytes, isNotEmpty);
      },
    );
  });

  group('FlutterShareImageRenderer', () {
    test('renders help and result cards without throwing', () async {
      final renderer = FlutterShareImageRenderer();

      final resultBytes = await renderer.render(
        const ShareImageCardData(
          variant: ShareImageVariant.result,
          track: GameTrack.daily,
          mode: GameMode.fiveLetters,
          category: 'الطبيعة',
          guesses: ['مكتبة', 'حديقة'],
          answer: 'حديقة',
          statusTitle: 'تم حل اللغز',
          statusSubtitle: '2 / 6 محاولات',
          footer: 'شارك النتيجة وتحدّ أصحابك.',
        ),
      );
      final helpBytes = await renderer.render(
        const ShareImageCardData(
          variant: ShareImageVariant.help,
          track: GameTrack.endless,
          mode: GameMode.fourLetters,
          category: 'الأماكن',
          guesses: ['كتاب', 'طريق'],
          statusTitle: 'ساعدني في هذا اللغز',
          statusSubtitle: 'تقدّم حالي بدون كشف الإجابة',
          footer: 'شارك الصورة مع صديق لتحصل على تلميح.',
        ),
      );

      expect(resultBytes, isNotEmpty);
      expect(helpBytes, isNotEmpty);
    });
  });
}

class _FakeShareImageRenderer implements ShareImageRenderer {
  @override
  Future<Uint8List> render(ShareImageCardData data) async {
    return Uint8List.fromList([1, 2, 3, 4]);
  }
}

class _FakeTemporaryDirectoryProvider implements TemporaryDirectoryProvider {
  const _FakeTemporaryDirectoryProvider(this.path);

  final String path;

  @override
  Future<String> getPath() async => path;
}

class _FakeBinaryFileWriter implements BinaryFileWriter {
  String? lastPath;
  Uint8List? lastBytes;

  @override
  Future<void> writeBytes(String path, Uint8List bytes) async {
    lastPath = path;
    lastBytes = bytes;
  }
}
