import 'dart:ui';

import 'package:share_plus/share_plus.dart';

abstract class ShareSheetService {
  Future<void> shareText(String text, {Rect? sharePositionOrigin});
  Future<void> shareFiles(
    List<String> paths, {
    String? text,
    Rect? sharePositionOrigin,
  });
}

class SharePlusSheetService implements ShareSheetService {
  const SharePlusSheetService();

  @override
  Future<void> shareFiles(
    List<String> paths, {
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    await Share.shareXFiles(
      paths.map(XFile.new).toList(growable: false),
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  @override
  Future<void> shareText(String text, {Rect? sharePositionOrigin}) async {
    await Share.share(text, sharePositionOrigin: sharePositionOrigin);
  }
}
