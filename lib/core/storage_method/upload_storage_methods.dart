import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';

class UploadStorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadImageToStorage(String path, Uint8List file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference ref = _storage.ref().child(path).child(fileName);

    UploadTask uploadTask = ref.putData(
      file,
      SettableMetadata(
        contentType:
            lookupMimeType('', headerBytes: file) ?? 'application/octet-stream',
      ),
    );

    try {
      TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          uploadTask.cancel();
          throw Exception('Upload timed out. Check your internet connection.');
        },
      );

      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      uploadTask.cancel();
      switch (e.code) {
        case 'storage/canceled':
          throw Exception('Upload was cancelled.');
        case 'storage/network-request-failed':
          throw Exception('No internet connection.');
        case 'storage/unauthorized':
          throw Exception('Not authorized to upload.');
        default:
          throw Exception(e.message ?? 'Upload failed. Try again.');
      }
    } on Exception {
      uploadTask.cancel();
      rethrow;
    }
  }
}