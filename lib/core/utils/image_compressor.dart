import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  /// Target: ~500 KB, max 1024px, JPEG.
  static const int targetBytes = 500 * 1024;

  static Future<Uint8List> compress(
    Uint8List bytes, {
    int maxSide = 1024,
    int startQuality = 85,
  }) async {
    var quality = startQuality;
    var result = bytes;

    while (quality >= 40) {
      result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: maxSide,
        minHeight: maxSide,
        quality: quality,
        format: CompressFormat.jpeg, // PNG also becomes JPEG
      );
      if (result.length <= targetBytes) break;
      quality -= 15; // 85 -> 70 -> 55 -> 40
    }
    return result;
  }
}