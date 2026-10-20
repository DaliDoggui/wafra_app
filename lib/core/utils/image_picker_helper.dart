import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

Future<String?> pickImageAsDataUrl({ImageSource source = ImageSource.gallery}) async {
  try {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 82,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;

    final mime = file.mimeType ?? 'image/jpeg';
    final base64String = base64Encode(bytes);
    return 'data:$mime;base64,$base64String';
  } catch (e) {
    debugPrint('⚠️ Image picking error: $e');
    return null;
  }
}
