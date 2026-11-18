import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:croppy/croppy.dart';

class FileUtils {
  /// Picks an image with restrictions:
  /// - maxSizeInMB: maximum allowed size in MB
  /// - allowedExtensions: list of allowed file extensions (without dot)
  Future<PickedImageResult?> pickImage({
    double maxSizeInMB = 2,
    List<String> allowedExtensions = const ['jpg', 'jpeg', 'png'],
  }) async {
    try {
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true, // ensures bytes are available on web
      );

      if (pickedFile == null) return PickedImageResult(bytes: null);

      final fileBytes = kIsWeb
          ? pickedFile.files.single.bytes
          : await File(pickedFile.files.single.path!).readAsBytes();

      if (fileBytes == null) return PickedImageResult(bytes: null);

      final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
      final tooBig = fileBytes.lengthInBytes > maxSizeInBytes;

      return PickedImageResult(
        bytes: tooBig ? null : fileBytes,
        isTooBig: tooBig,
      );
    } catch (e) {
      debugPrint("Failed to pick image: $e");
      return PickedImageResult(bytes: null);
    }
  }

}

class PickedImageResult {
  final Uint8List? bytes;
  final bool isTooBig;

  PickedImageResult({this.bytes, this.isTooBig = false});
}
