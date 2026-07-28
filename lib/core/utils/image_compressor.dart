import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageCompressor {
  ImageCompressor._();

  static const int defaultMaxWidth = 1600;
  static const int defaultQuality = 75;

  /// Decodes, optionally resizes, then encodes as JPEG.
  static Future<Uint8List> compress(
    Uint8List bytes, {
    int maxWidth = defaultMaxWidth,
    int quality = defaultQuality,
  }) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('تعذر قراءة الصورة. تأكد من اختيار ملف صورة صالح.');
    }

    final resized = decoded.width > maxWidth
        ? img.copyResize(
            decoded,
            width: maxWidth,
            interpolation: img.Interpolation.average,
          )
        : decoded;

    final encoded = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(encoded);
  }
}
