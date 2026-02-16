import 'package:firebase_storage/firebase_storage.dart';

import 'package:cowork/shared/domain/services/photo_url_resolver.dart';

class FirebasePhotoUrlResolver implements PhotoUrlResolver {
  final FirebaseStorage storage;

  FirebasePhotoUrlResolver({FirebaseStorage? storage})
      : storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String?> resolve(String? photoUrl) async {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) return null;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('gs://')) {
      return storage.refFromURL(url).getDownloadURL();
    }

    return null;
  }
}
