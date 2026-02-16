import 'package:cowork/shared/domain/services/photo_url_resolver.dart';

class ResolvePhotoUrl {
  final PhotoUrlResolver resolver;

  ResolvePhotoUrl(this.resolver);

  Future<String?> call(String? photoUrl) {
    return resolver.resolve(photoUrl);
  }
}
