import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImageBytes({
  required ImageSource source,
  int imageQuality = 85,
  double? maxWidth = 1024,
}) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: source,
    imageQuality: imageQuality,
    maxWidth: maxWidth,
  );
  if (file == null) return null;
  return file.readAsBytes();
}
